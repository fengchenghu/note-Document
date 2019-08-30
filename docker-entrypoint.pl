#!/usr/bin/perl -w

use warnings;
use strict;
use JSON;
use LWP::Simple;
use List::Util qw(min max);
use Time::HiRes qw(usleep);
use POSIX qw(strftime);
use Net::OpenSSH;


my $is_rollup_rebuild = $ARGV[0];

'rebuild' eq  $is_rollup_rebuild and shift @ARGV;

{
    local $" = "\n";
    print "feed args ==> |@ARGV|\n";
}

# $Net::OpenSSH::debug = -1;

#此脚本作为k8s容器入口做4件事:
#    1. 启动sshd服务: 支撑其他副本scp数据
#    2. 从apiserver查询其他副本的ip地址
#    3. 轮训每个副本的索引段文件,选择最新的的落地段复制数据
#    4. 执行入口命令

my ($apiserver, $data_dir, $multi_meta_file, $pkg_dir, $host_ip, $ssh_retry_times, $retry_interval_s) = (
    $ENV{'SERVERAPI'}
    , '/opt/esearch/searcher/data'
    , '/opt/esearch/searcher/data/indexerdata/data/multi_meta'
    , '/home/work/esearch/package/'
    , qx{hostname -i} # $ENV{'POD_IP'}
    , 5
    , 20
);

chomp ($host_ip);

my $pod_url			= "http://$apiserver/api/v1/namespaces/$ENV{'POD_NAMESPACE'}/pods/$ENV{'HOSTNAME'}";
my $pod_ref			= from_json (get ($pod_url)) or (print "get and parser $pod_url failure.\n" and exit (-1));
my %shard_conf		= %{from_json ($pod_ref->{'metadata'}->{'annotations'}->{'shardconf'})};
my $host_pod_hash   = $pod_ref->{'metadata'}->{'labels'}->{'pod-template-hash'};
my $endpoients_url	= "http://$apiserver/api/v1/namespaces/$ENV{'POD_NAMESPACE'}/endpoints/$shard_conf{'svc_name'}";
my $endpoints_ref	= from_json (get ($endpoients_url)) or (print "get and parser $endpoients_url failure.\n" and exit (-2));
my @subsets			= @{$endpoints_ref->{subsets}};

# TODO : if need to copy old index data($is_rollup_rebuild), we just copy.
#         choose way: the timestamp biggest svc win or strip the timestamp.
#                     so, we just modify the $shard_conf{'svc_name'}


# NO index data we exec @ARGV to make full index

print "now in host $host_ip docker entry, it's pod-template-hash ==> $host_pod_hash.\n";

my @other_endpoints_ip = ();

for (@subsets) {
    my %subset = %{$_};

    # TODO: 'notReadyAddresses' case
    my $net_addresses = 'addresses';

    exists $subset{$net_addresses} or next;

    my @addresses = @{$subset{$net_addresses}};

    for (@addresses) {
        my %address = %{$_};

        exists $address{'ip'} or next;

        $host_ip eq $address{'ip'} and next;

        if ('rebuild' eq $is_rollup_rebuild) {
            my %pod_target_ref  = %{$address{'targetRef'}};
            my $cur_pod_url     = "http://$apiserver/api/v1/namespaces/$ENV{'POD_NAMESPACE'}/pods/$pod_target_ref{'name'}";
            my $cur_pod_ref     = from_json (get ($cur_pod_url)) or (print "get and parser $cur_pod_url failure.\n" and exit (- 2));
            my $cur_pod_hash    = $cur_pod_ref->{'metadata'}->{'labels'}->{'pod-template-hash'};

            $cur_pod_hash eq $host_pod_hash or (print "$address{'ip'} pod-template-hash ==> $cur_pod_hash is not $host_pod_hash, skip it.\n" and next);
        }

        push @other_endpoints_ip, $address{'ip'};

        usleep (200000);
    }
}

print strftime ("%Y/%m/%d %H:%M:%S", localtime), " starting sshd ... \n";
`sudo service sshd start`;

# `nohup indexer start & ; java -cp buider 1`;
0 == 0 + @other_endpoints_ip and print "have no any rc can use, need full build...\n" and exec "@ARGV";

my %index_data_info = ();

for (@other_endpoints_ip) {
    my ($endpoint, $user_name, $pass_word, $timeout_s)	= ($_, 'work', 'work', 3600 * 4);

    my $ssh	= Net::OpenSSH->new ($endpoint,
        user			        => $user_name
        , password		        => $pass_word
        , timeout		        => $timeout_s
        , kill_ssh_on_timeout   => 1
        , master_opts	        => [ -o => "StrictHostKeyChecking=no" ]
    );

    $ssh->error and print "SSH connection $endpoint failed: " . $ssh->error . "\n" and next;

    my ($output, $errput) = $ssh->capture2({timeout => $timeout_s}, "cat $multi_meta_file");
    $ssh->error and print "ssh failed: " . $ssh->error . "$errput\n" and next;

    print "$endpoint ==> $output\n";

    my @partitions = @{from_json($output)->{Partitions}};

    # TODO: we need only 1 rc full build, cuz hava more than 1 rc, should redeploy
    if (0 == 0 + @partitions) {
        print "WARN: $endpoint have no partitions, we need only 1 rc full build, cuz hava more than 1 rc full building, should redeploy!!!!.\n";

        next;
    }

    my $max_flush_time	= -1;
    my @data_dirs		= ();

    for (@partitions) {
        my %partition = %{$_};

        $max_flush_time = max ($max_flush_time, $partition{'TimeStamp'});

        push @data_dirs, $data_dir . '/indexerdata/data/' . $partition{'Directory'};
    }

    $index_data_info{$endpoint} = {
        'ssh'			=> $ssh
        , 'flush_time'	=> $max_flush_time
        , 'data_dirs'	=> [@data_dirs]
    };
}

my @order_endpoints = ();

for (sort {${$index_data_info{$b}}{'flush_time'} <=> ${$index_data_info{$a}}{'flush_time'}} keys %index_data_info) {
    push @order_endpoints, $_;
}

sub destory_sshs {
    my $hash_ref = shift;
    my %rc_info  = %{$hash_ref};

    undef $rc_info{$_}{'ssh'} for keys %rc_info;

    return 1;
}

0 == 0 + @order_endpoints and print strftime ("%Y/%m/%d %H:%M:%S", localtime), " on other rcs, no one have index data, error op.\n" and destory_sshs(\%index_data_info) and exit (-2);

print strftime ("%Y/%m/%d %H:%M:%S", localtime), " choose the rc on endporint $order_endpoints[0].\n";

my @cp_dirs = @{${$index_data_info{$order_endpoints[0]}}{'data_dirs'}};

unshift @cp_dirs, $data_dir . '/indexerdata/data/multi_meta';

my $copy_ssh = ${$index_data_info{$order_endpoints[0]}}{'ssh'};

$copy_ssh->scp_get(
    {recursive => 1, bwlimit => '70000', verbose => 1}
    , @cp_dirs[0 .. $#cp_dirs]
    , $data_dir . '/indexerdata/data/')
    or (print "scp data files from $order_endpoints[0] failure" . $copy_ssh->error . "\n" and destory_sshs(\%index_data_info) and exit (-3));

destory_sshs(\%index_data_info);

print strftime ("%Y/%m/%d %H:%M:%S", localtime), " copy index data finish.\n";

exit (0);

__END__

