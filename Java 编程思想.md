### Java 编程思想

- 对于没有权限修饰符的java数据成员和方法来说，在同一包下的其他类可以像public一样访问它，其他包下等同于private
- 泛型在jdk5以后出现，以前都是存储的Object类型，在取出容器（Map，List）中的对象时不知道为何种具体的类型，只知道为Object
  泛型的出现解决了向下转换的问题 List<Human> lists = new ArrayList<Human>(); 使用<>来表示泛型，记录具体类型
- 在java中对于类中基本类型的成员变量会自动初始化，但对于方法中出现的局部变量必须手动初始化。
- 可在一个构造方法中通过this(参数)这样的形式调用本类的另一个构造方法，但必须将this(参数) 放在构造函数的第一条语句位置，并且只能调用一个其他构造方法。
   只有在构造方法中才可调用构造方法，其他方法中不可调用构造方法。
- 与C++不同的是，java垃圾回收可能并不会执行，当你的资源足够时，java无法手动释放内存，垃圾回收器在回收时会调用一个
   finalize方法，如果有必要在回收前做一下清理工作，可以在此方法中实现，特指的是java调用其他语言，比如C/C++ 时使用了
   malloc  需要手动free 
- gc会导致程序暂停，因为会存在检查所有对象是否存活，将活着的对象去复制到新的一块内存中，释放以前的内存，更新引用的值。
   所有频繁的gc会对程序性能有影响，这是 停止-复制算法 复制以后可以得到连续的堆空间，当产生少量的垃圾或没有垃圾时，gc
   会采取一种 标记-清扫的算法  扫描所有引用 对活着的对象进行标记但并不复制  而是扫描完毕后释放掉没有标记的对象，这样会导致
   堆得空间不连续，造成碎片，但垃圾本来就很少。
- java中可以对于成员变量直接赋初值进行初始化，但C++不能直接去对成员变量赋值
- java中会默认初始化成员变量，即使在构造函数中进行初始化，但在构造函数调用之前还是会初始化为默认值，所以会初始化两次，第一次的引用对象将被丢弃
- int[] arr 和 int arr[] 都是被允许的  但在java中一般都会采用第一种。
- 在继承中必须使用super() 去调用基类的构造函数初始化基类，而且需在子类的构造函数开始位置，如果没有默认构造函数，必须显示调用构造函数
- 在C++中如果父类与子类有着相同名字的方法，即使参数个数和类型不同，子类方法也会覆盖父类方法，这叫重写，不会构成重载
- 在java中如果父类与子类有着相同名字的方法，参数个数和类型不同，子类并不会覆盖父类的方法，依然构成重载，只有当参数类型数量完全一样才会重写
- 组合与继承的关系：
	组合类似于一辆车由发动机和轮胎组成
	继承类似于车是基类，下面有各种类型的车，小车，卡车，客车，是把一个通用的东西给特殊化，具体化。
	尽量使用组合而不是继承，除非需要向上转型，即需要传入的对象不确定是子类还是父类。
- final 在java中修饰常量，不允许变化，对于基本类型是值不可更改，static final String 将会占据一段不能改变的存储空间
  final修饰引用类型时代表引用对象不可更改，即不可以改变引用的指向，但被引用的对象是可以改变的
  使用final修饰方法：
	1. 在继承中不可以重写final修饰的父类方法
	2. 在老版本jvm中编译器可能将final修饰的方法变为内联调用，提升效率，但新版本jvm已经取消 （废弃）
	3. 类中的所有private方法都是隐含的final修饰，但由于继承时private方法对子类不可见，也没有覆盖private方法的可能性存在，即使定义一个相同名字参数的方法也不是覆盖。
	4. final类不可被继承
- 子类不要去尝试重写父类的private修饰的同名方法，子类方法的名字不要与父类的private方法相同，这样无法产生多态，即无法通过父类的接口调用子类的同名方法
- 在接口中声明的方法默认是public的，也只能是public的，接口中的成员变量是static final的。
- Java 泛型与直接使用object 的区别在于List<object> 可以存放任意类型的对象 List<T> 指定只能存放一种类型的对象
```
    public class LinkedStack<T> {
        private static class Node<U>{
            U item;
            Node<U> Next;

            Node() {
                this.item = null;
                Next = null;
            }

            public Node(U item, Node<U> next) {
                this.item = item;
                Next = next;
            }

            boolean isEnd(){
                return item == null && Next == null;
            }
        }

        private Node<T> top = new Node<T>();
        public void push(T item){
            top = new Node<T>(item,top);
        }

        public T Pop(){
            T result = top.item;
            if (!top.isEnd()){
                top = top.Next;
            }
            return result;
        }
    }
```

- C++ 的泛型 是通过二次编译实现可以在泛型中使用一些暂时不存在的方法，当实例化后会进行二次编译，此时会进行检查
- java中不可以向C++一样操作 Java中的泛型类型将会被擦除 在使用泛型代码的内部无法获得任何有关泛型实际类型的信息  实例如下：
```
        Class class1 = new ArrayList<String>().getClass();
        Class class2 = new ArrayList<Integer>().getClass();

        System.out.println(class1 + " -- " + class2);
        System.out.println(class1 == class2);
        
        //输出：
            class java.util.ArrayList -- class java.util.ArrayList
            true
        在java的泛型里所有的类型都会被擦除  泛型T 更像是起到占位符的作用
//C++ Demo
    template<class T> class TemplateDemo{
    private:
        T obj;
    public:
        TemplateDemo(T obj){
            this->obj = obj;
        }

        void testout(){
            obj.func();  //可以使用暂时未定义的方法，只有当对模板参数实例化时才会进行检查，实例化类型是否有此方法
        }
    };
    
 
// Java Demo 
    public class TemplatDemo<T> {
        private T obj;

        public TemplatDemo(T obj) {
            this.obj = obj;
        }

        public T getObj() {
            return obj;
        }

        public void setObj(T obj) {
            this.obj = obj;
        }

        void testfun(){
           // obj.fun();   //java 无法实现 IDE 爆红 无法通过语法检查 C++可以
        }
    }
```
	
	