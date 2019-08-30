### 云搜用到的
- Kubernetes			基础资源管理组件
- SCF 					RPC调用框架
- Spring Boot + Vue 	管理后台后端与前端框架
- Perl					云搜后台脚本   （放弃  古老  不可维护）
- Wtable				云搜数据存储
- kafka					消息队列
- 搜索内核Esearch		提供搜索能力
- ETCD					用作注册中心服务发现？


### 云搜组件

- 路由Proxy				对appid进行路由，分配到不同的集群
- 下沉Proxy				对发来的query进行校验，日志记录，数据上报，将云搜query转为Esearch查询query发给Esearch
- searcher				Esearch进程，提供检索服务，按文档哈希到不同的分片 多副本
- merger				对searcher拿到的文档进行归并返回给下沉proxy，下沉将结果返回给路由，路由返回用户
- indexer				Esearch进程，索引构建
- builder				索引构建，向Esearch内核发送索引构建请求，索引文档
- docker-entrypoint		通过寻找最新副本scp拷贝索引文件，跳过全量重建索引的阶段，提高速度
- datacollector-server	数据上报组件，由下沉proxy将超时，0结果，异常，文档删除添加等数据发送，存入数据库，居然是个二进制可直接执行的文件，可能是C++写的
- wcs-agent				向用户提供接口使用wcs
- wcs-manager			云搜管理后台
- doc-adapter			分词服务
- indexviewtool			把内核中的package包拿出来开了一个pod 通过java程序调用内核提供工具 查询内核相关信息，如： 正排，倒排  管理后台自助工具使用此服务
- wcspreheat			为新版本应用预热



### etcd
- esearchk8s/wcs-online/appmergersvc/		存储app pod merger 对应的service的 名字
- esearchk8s/wcs-online/appsearchersvc		存储app	pod	searcher 对应的service名字
- 二者应该是用来做负载均衡 为loadbalancer 使用 

### 内核索引建立逻辑
- indexer  建立索引，推送给searcher
- Searcher作用主要有2个: 1、接收来自Builder模块的doc，并创建成内核中的索引格式的文件；
						 2、提供查询和排序，返回已经按照某个排序规则排好的所需要的索引给Merger。
- Merger  作用主要有2个：1、负责向分布式searcher节点发送查询请求； 
						 2、把Searcher返回的的搜索结果进行合并。
						 
- UEsearch General Scorer 打分排序插件， 通过插件的形式将打分逻辑和索引searcher 分开， 可以自定义打分规则

