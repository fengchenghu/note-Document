### SCF 工程

- contract
	这个包下存放对外暴露的接口
- components
	这个包下存放接口的实现类

- 注解@ServiceContract 		标记接口对外暴露提供服务   注解@OperationContract 标记方法对外暴露  在接口中注解

- 注解@ServiceBehavior 		标记该类对外提供服务 需要实现对外提供的接口 如果客户端需要调用此接口实现类，则该类必须加此注解
- @SCFSerializable	   		实体类若需要进行传输则必须加此注解
- @SCFMember(orderId = 1)	实体类若需要进行传输字段必须加此注解

- SCF实现异步调用，服务端无需修改，客户端修改接口类重载需要异步调用的方法 function(String args,ReceiveHandler cb)
	写回调函数 的类继承ReceiveHandler 重写callback 方法
	
### 使用scf.config配置文件
```
<?xml version="1.0" encoding="utf-8" ?> 
<SCF> 
	<Service name="服务名字" id="1" maxThreadCount="50">
		<Commmunication >   //序列化协议等
			<SocketPool bufferSize="4096" minPoolSize="2" maxPoolSize="5" nagle="true" autoShrink="00:00:20" sendTimeout="00:00:02" receiveTimeout="00:00:02" waitTimeout="00:00:01" maxPakageSize="102400" protected="false"/> 
			<Protocol serialize="SCFV3" encoder="UTF-8" compressType="UnCompress" />
		</Commmunication> 
		<Loadbalance>       //多个服务节点 负载均衡
			<Server deadTimeout="00:00:10"> 
				<add name="demoserver1" host="127.0.0.1" port="16001" />
                .....
			</Server>
		</Loadbalance>
	</Service>
    ......
    <Service name="服务名字" id="1" maxThreadCount="50">
		<Commmunication >   //序列化协议等
			<SocketPool bufferSize="4096" minPoolSize="2" maxPoolSize="5" nagle="true" autoShrink="00:00:20" sendTimeout="00:00:02" receiveTimeout="00:00:02" waitTimeout="00:00:01" maxPakageSize="102400" protected="false"/> 
			<Protocol serialize="SCFV3" encoder="UTF-8" compressType="UnCompress" />
		</Commmunication> 
		<Loadbalance>       //多个服务节点 负载均衡
			<Server deadTimeout="00:00:10"> 
				<add name="demoserver1" host="127.0.0.1" port="16001" />
                .....
			</Server>
		</Loadbalance>
	</Service>
</SCF>

```