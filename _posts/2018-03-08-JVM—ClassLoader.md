---
layout: post
title: JVM——ClassLoader
category: Java
tags: [Java]
---

Java代码会经过编译器编译成class文件(字节码文件)，再把class文件装载的JVM中，映射到内存的各个区域，那么我们的应用程序就可以在内存中运行了。


## 一 类装载流程
### 1 加载Loading
1. 通过class路径读取到二进制流。
2. 解析二进制流，将其内部的元数据（类型，变量等)载入到方法区；
3. 在Java Heap中生成对应的java.lang.Class对象。


### 2 连接Linking过程：验证，准备，解析
#### 1 验证Varification
1. 验证class文件的合法性。确保JVM的要求。
2. 四类验证：文件格式，元数据，字节码，符号引用验证。

#### 2 准备Preparation
1. 为类变量(static变量)分配内存，并设置初始值0；分配到方法区Method Area。
2. 不包括final static变量，final变量在编译时就会分配内存了。
3. 实例变量随对象一起分配到Java Heap中。

#### 3 解析Resolution
1. 将符号引用替换为直接引用。
2. 如某个类 继承java.lang.object这个符号，直接引用就是直接找到java.lang.object所在的内存地址，建立直接引用关系。
3. 符号引用：一组符号来描述目标，可以时任意字面量。
4. 直接引用：直接指向目标的指针，相对偏移量，或一个间接定位到目标的句柄。
5. 包括类和接口的解析，字段解析，类方法解析，接口方法解析。

### 3 初始化Initialization
1. 包括 类构造方法，static变量赋值语句，static{}语句块。
2. 必先初始化 父类。

## 二 类加载器
1. ClassLoader是一个抽象类。其具体实例负责把Class文件读取到JVM中。
2. 还可以定制以满足不同Class流的加载方式，从网络加载，或文件加载。
3. 按需加载，双亲委派模式。

### 1 启动BootStrap类加载器
1. load JVM自身需要的类，这个类加载 使用C++实现。
2. 出于安全考虑，只加载java, javax, sun等开头的类。
3. 没有父类加载器。

### 2 扩展Extension类加载
1. 是指sun.misc.Launcher$ExtClassLoader类，由java语音实现。
2. 是Launcher的静态内部类。负责加载<JAVA_HOME>/lib/ext目录下或由系统变量-Djava.ext.dir指定位路径中的类库。
3. 父类为null。
4. 使用

```
//ExtClassLoader类中获取路径的代码
private static File[] getExtDirs() {
     //加载<JAVA_HOME>/lib/ext目录中的类库
     String s = System.getProperty("java.ext.dirs");
     File[] dirs;
     if (s != null) {
         StringTokenizer st =
             new StringTokenizer(s, File.pathSeparator);
         int count = st.countTokens();
         dirs = new File[count];
         for (int i = 0; i < count; i++) {
             dirs[i] = new File(st.nextToken());
         }
     } else {
         dirs = new File[0];
     }
     return dirs;
 }
```

### 3 系统System类加载器 (应用程序加载器)
1. sun.misc.Launcher$AppClassLoader。
2. 负责加载类路径`java -classpath` 或 `-D java.class.path`指定路径下的类库。
3. 开发者可通过`ClassLoader#getSystemClassLoader()`方法获取到该类加载器。
4. 父类加载器为ExtClassLoader。

### 4 CustomClassLoader
1. 父类加载器为AppClassLoader。


### 5 ClassLoader的重要方法
1. public ClassL<?> loadClass(String name) throws ClassNotFoundException
2. protected final Class<?> defineClass(byte[] b, int len)
3. protected final Class<?> findClass(String name) throws ClassNotFoundException
4. protected final Class<?> findLoadedClass(String name)查找已经加载的类。

## 三 双亲委派模型
### 1 工作原理
1. 一个类加载器收到类加载请求，先把这个请求委托给父类的加载器去执行。
2. 父类还存在父类加载器就向上委托，依次递归，最终到达顶层的启动类加载器。
3. 父类完成类加载任务后，就成功返回，如父类无法按成加载任务，子类加载器才会自己去加载。

### 2 优势
1. java类因类加载器的层级关系，从而避免了重复加载。
2. 考虑安全因素，java核心API定义中定义类型不会被随意替换，父类加载失败，子类自行加载核心API包时，需访问权限，或报安全异常。

## 四 类与类加载器







> 参考文章
![深入理解Java类加载器(ClassLoader)](https://blog.csdn.net/javazejian/article/details/73413292)
























