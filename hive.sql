


create table wcsquery as select b.* from (select appid, query, reason, cnt, row_number() over (partition by appid order by cnt desc)rank from (select appid, query, reason, count(*) as cnt from wcserrorquery where day='2019-08-20' group by appid,query,reason)a)b where b.rank<=3;

	
	
insert overwrite directory "viewfs://58-cluster/home/hdp_teu_search/resultdata/fengchenghu01/res" row format delimited fields terminated by "\t" select b.* from (select appid, query, reason, cnt, row_number() over (partition by appid order by cnt desc)rank from (select appid, query, reason, count(*) as cnt from wcserrorquery where day='2019-08-20' group by appid,query,reason)a)b where b.rank<=300;


http://webhdfs.58corp.com/webhdfs/v1/home/hdp_teu_search/resultdata/fengchenghu01/res.txt/000000_0_0.lzo?op=OPENDECOMPRESS&user.name=hdp_teu_search


select appid,count(*) from wcserrorquery where day='2019-08-20' group by appid;

select b.* from (select appid, query, reason, cnt, row_number() over (partition by appid order by cnt desc)rank from (select appid, query, reason, count(*) as cnt from wcserrorquery where day='2019-08-20' group by appid,query,reason)a)b where b.rank<=300;
