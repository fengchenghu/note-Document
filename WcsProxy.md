## 路由Proxy
- indexProxy和queryProxy为一套代码，部署时叫了不同的名字，通过SCF分组为两个分组。提供查询和插入数据
### 四个接口类：
1. ICQueryProxyService
    该接口类为下沉proxy提供的接口，内含八个函数，每个函数有两个版本，分别为同步和异步调用
    ```
    	@OperationContract
        WCSSearchResult getSearchResult(String query) throws Exception;     //同步调用接口
        WCSSearchResult getSearchResult(String query, ReceiveHandler cb) throws Exception;//异步调用接口
        ...........
    ```
2. IIndexProxyService
    该接口类为路由proxy对外提供服务的接口和下沉Proxy的接口声明，包含 put delete update 函数，
    ```
        //路由对外提供接口
        IndexProxyRet put(long appid, long primaryKeyId, String data) throws Exception;
        IndexProxyRet delete(long appid, long primaryKeyId) throws Exception;
        IndexProxyRet update(long appid, long primaryKeyId, String data);

        //下沉提供的接口
        IndexProxyRet put(MetaData metaData, long primaryKeyId, String data) throws Exception;
        IndexProxyRet delete(MetaData metaData, long primaryKeyId) throws Exception;
        IndexProxyRet update(MetaData metaData, long primaryKeyId, String data);
    ```
3. ISQueryProxyService
    该接口类为路由proxy对外提供服务的接口声明
    ```
        WCSSearchResult getSearchResult(String query) throws Exception;
        String getSearchResultStr(String query) throws Exception;
        Integer getSearchCount(String query) throws Exception;
        WCSSearchResult getSearchFacet(String query) throws Exception;
        String getSearchFacetStr(String query) throws Exception;
    ```
4. LoadBalancer
    该接口为负载均衡器提供的接口
### 数据提交服务(index proxy)
- IndexProxyService 实现接口 IIndexProxyService
```
    //对于声明的下沉的三个接口全部给了空实现，自己对外的服务进行了实现
    @Override
    public IndexProxyRet put(MetaData metaData, long primaryKeyId, String data) {
        return null;
    }
    @Override
    public IndexProxyRet delete(MetaData metaData, long primaryKeyId) {
        return null;
    }
    @Override
    public IndexProxyRet update(MetaData metaData, long primaryKeyId, String data) {
        return null;
    }

```
    通过在部署的时候在环境变量中加入 WCS_PROXY_MODE 值  来判断当前为 queryproxy 还是 indexproxy
    通过checkModel函数检查环境变量 WCS_PROXY_MODE 值是否为 index 来提供 数据索引服务，如果检查失败，抛出异常WcsException(ErrorCode.UnsupportedApi)；
    通过负载均衡权重选择算法，找到指定appid应用的一个版本

- ProxyServiceInit 通过实现com.bj58.spat.scf.server.contract.init.IInit来达到初始化服务，通过初始化wconfig 初始化 ClusterConfig  拿到集群中服务的信息
    调用下沉Proxy的相关接口将请求发给下沉Proxy

### 数据查询服务(query proxy)
    通过QueryContext 这个类对用户发来的原始query 进行解析 得到该应用的所在集群 版本等信息，向下沉Proxy发送异步请求
    异步返回结果通过继承了SCF com.bj58.spat.scf.client.proxy.builder.ReceiveHandler 的 ProxyReceiveHandler类的callback函数处理
    1. 异步调用下沉proxy抛出异常：
    ```
        下沉Proxy抛出异常，记录callbackerror  最多的貌似是超时
        if (o instanceof Exception) {
            log.error(String.format("callback error %d %s", queryContext.getAppId(), 
                                     queryContext.getRowQuery()), (Exception)o);
        }
    ```
    2. 正常返回结果：
        解析query时出错 ：fromQuery 抛出异常 主调函数捕获  记录日志 异步回包 给调用方
        通过scf 的AsynBack.send(scfContext.getSessionID(),Object o);异步回包 将结果返回给调用方
        
        
## 下沉Proxy
- QueryProxyServiceInit 实现 SCF 的 com.bj58.spat.scf.server.contract.init.IInit 接口进行了初始化
  通过读取配置文件queryproxy.properties 
  ```
        //此配置文件存储  分词配置  日志机位置  暴露端口  集群id
        cutwordpath=/opt/scf2/service/deploy/wcssinkqueryproxy4/conf-snlp/Snlp.conf
        udpquerylogserver=wcslog.58dns.org:17000
        report.agentport=3366
        clusterno=4
  ```
  初始化wtable  数据上报等服务  生成initOK 文件标志成功
- QueryProxyService 类 实现了 接口IQueryProxyService 提供服务 ，为了适配 某些应用直接走 下沉 不走路由请求，多提供了一些接口（本不该有）
  WCSSearchResult getSearchResult(MetaData metaData, String query) throws Exception
  1. 校验路由传来的appid和metaData 是否合法 若不合法直接返回 
  2. 数据上报查询量 + 1
  3. searcher = ApplicationContext.SEARCHERS.get(appMetaData); 根据appid version clusterNo 等信息获取searcher
     SEARCHERS为hashmap 如果找不到 searcher 数据上报 查询丢弃 
     这里返回的searcher 应该为EsearchSearcher(Searcher 的子类) 
  4. boolean bResult = searcher.getSearchResult(session);  向内核发送查询请求
     getSearchResult：
        - 
       
    

    
