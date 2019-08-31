### alibaba Java 开发规范
- 对于类命名使用大驼峰命名法UpperCamelCase 每个单词首字母大写
    class UserInfo  
- 对于变量 方法 参数 使用小驼峰命名法lowerCamelCase 第一个单词首字母小写
    String userName
- 常量命名全部大写单词间用下划线分割
    MAX_STOCK_COUNT   stock  货物
- 抽象类命名使用Abstract 或 Base 开头 异常类使用Exception结尾
- 包名使用小写
- 接口类中的方法和属性不加任何修饰符 包括public
- 对于web中的service 类 提供service接口 在impl包下实现后加impl
    SearchService    ==>   SearchServiceImpl
- 枚举类后加Enum后缀  
    ProcessStatusEnum   内部成员变量大写  SUCCESS 
- DAO 层命名
    获取单个对象用get做前缀
    获取多个对象用list做前缀
    获取统计值用count
    插入方法用save/insert
    删除用remove/delete
    修改用update
- 不适用任何未经定义的常量
    String key = "user_" + id;   X
- 对于Long long 类型  后加 大写L
- 单个方法的总行数不超过80行
- 适用常量调用equals方法
    "success".equals(status);
- 对于整形包装类 Integer  使用equals 方法比较  不用==  
    在-127到128  之间的数值使用== 会复用对象  超出不会，所以使用equals ？
- 对于浮点数 基本类型 不用== 判断包装类型不用equals 
    Java中float的精度为6-7位有效数字。double的精度为15-16位。 
    num == 0   ==>   if(num < 0.00000001 && num > -0.00000001)  
    对于包装类 使用BigDecimal 定义后运算 因为浮点数不精确
    BigDecimal b = new BigDecimal(String);
    传参使用String类型     因为本身浮点数不精确   切记
    调用相关函数进行加减乘除
- 禁止使用 BigDecimal b = new BigDecimal(Double);  构造 造成精度问题
- 定义数据库对应的实体对象时类型必须匹配  bigint  必须  使用 Long   不能使用Integer  防止溢出
- 所有实体类基本数据类型必须使用对应的包装类型 RPC 方法的返回值与参数也必须为 包装类型
- 构造方法禁止加入业务逻辑，若有初始化动作 写init函数
- 实体类必须写toString 方法
- 循环中 使用StringBuilder 的 append 方法连接  字符串  最后通过toString 方法返回String对象 
    因为使用String +  来连接时 每次都会创建StringBuilder 对象 造成内存消耗
- 只要重写hashCode 就 必须重写 equals 方法

- 不允许在for 循环里进行集合的 remove  和 add  只有使用 while 迭代器  才可 
- 对于集合初始化 尽量指定初始化大小 默认指定16 
-                               Key                         value               
   HashTable                    !null                       !null           线程安全
   ConcurrentHashMap            !null                       !null           锁分段技术 CAS
   TreeMap                      !null                       可为null        线程不安全
   HashMap                      可为null                    可为null        线程不安全
- 所有线程 通过 线程池提供 不允许直接创建线程
- RuntimeException  可以通过检查  这些异常尽量不要通过catch 处理  比如NullPointerException  
    但是对于NumberFormatException  可以进行catch
- 不要在finally中return， try中return后会继续执行finally 代码块 如果finally return  丢失try中的return信息
  