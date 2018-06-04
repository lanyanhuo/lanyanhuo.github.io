---
layout: post
title: Perform OOM
category: Android
tags: [Android]
---

# OOM
1. 触发条件: allocated + 新分配的内存 >= getMemoryClass()
2. 会导致不再引用的对象无法即使释放，占用内存，后续需要分配时因为内存不足引起OOM。

## 避免OOM
### 1. 减少对象的内存占用

#### 1.1 使用轻量的数据结构
1. 使用Android专用的ArrayMap/SparseMap。
2. SparseArray避免了key与Value的自动装箱(autoboxing),也不需要拆箱。

#### 1.2 避免使用Enum

#### 1.4 减少Bitmap对象的内存占用
1. Bitmap极易消耗内存
	* inSampleSize: 缩放比例，在把图片载入内存之前，计算出一个合适的比例，避免不必要的大图载入。
	* decode format: 解码格式，ARGB_8888/RBG_565/ARGB_4444/ALPHA_8，占用的字节也有差异。


### 2. 内存对象的重复利用
#### 2.1 复用系统自带的资源
1. Android系统内置的资源：String，color，image, animation, style, layout等等，直接引用即可。

#### 2.2 在ListView/GridView等对ConvertView的复用

#### 2.3 Bitmap对象复用
1. 使用LRU(Least Recently used)
2. 利用inBitmap高级属性，告知Bitmap解码器尝试去使用已经存在内存中的那张Bitmap，所以仅仅只需要占用屏幕锁能显示的图片数量大小的内存而已。不会在堆中创建多个Bitmap。
3. inBitmap的条件
	* API 19，新申请的Bitmap比较<=内存中已存在的Bitmap大小。
	* 必须有相同的解码格式
	* 对待不同解码格式，可以申请Bitmap对象池，创建时就能在内存中找到合适的Bitmap去重用。
4. BitmapFactory.Options中inNativeAlloc是扩大内存，要慎用。

#### 2.4 避免在onDraw中执行对象的创建
1. 频繁创建对象，迅速增加内存。
2. 会引起频繁gc，甚至内存抖动。

#### 2.5 StringBuilder的使用
1. 大量String拼接，可使用StringBuilder代替。


### 3. 避免对象的内存泄漏

#### 3.1 注意Activity的泄漏
1. 内部类持有Activity的引用
2. 典型场景是内部类Handler持有Activity的引用，如果Handler中有延迟任务，或等待执行的任务列过长，在Activity关闭后去执行任务，而导致Activity泄漏。即Looper -> MessageQueue -> Handler -> Activity.
3. 解决以上问题
	* 在Activity onDestroy时就remove Handler队列中的消息与Runnable。
	* 使用static + WeakReference 来断开Handler与Activity之间存在的引用。
4. 内部类尽量使用static + WeakReference。


#### 3.2 使用Application Context 而不是Activity Context

#### 3.3 注意临时Bitmap对象的及时回收
1. 调用Source Bitmap Recycle时一定要去检查Source Bitmap与return Bitmap引用是否相同。

#### 3.4 注意Listener的注销
1. register 和 unRegister一定要一起使用。

#### 3.5 WebView的泄漏
1. 为WebView开启另外一个线程，通过AIDL与主线程进行通信。在合适的时机进行销毁。

#### 3.6 注意Cursor file Stream等是否及时关闭


### 4. 内存优化策略

#### 4.1 谨慎使用Large Heap
1. getMemoryClass()来检查实际获取到的heap大小

#### 4.2 综合考虑内存阈值与其他因素 设计合适的缓存大小
1. 应用程序剩下了多少可用的内存空间?
2. 有多少图片会被一次呈现到屏幕上？有多少图片需要事先缓存好以便快速滑动时能够立即显示到屏幕？
3. 设备的屏幕大小与密度是多少? 一个xhdpi的设备会比hdpi需要一个更大的Cache来hold住同样数量的图片。
4. 不同的页面针对Bitmap的设计的尺寸与配置是什么，大概会花费多少内存？
5. 页面图片被访问的频率？是否存在其中的一部分比其他的图片具有更高的访问频繁？如果是，也许你想要保存那些最常访问的到内存中，或者为不同组别的位图(按访问频率分组)设置多个LruCache容器。

#### 4.3 onLowMemory() onTrimMemory()


#### 4.4 资源文件需要选择合适的文件夹存放
1. hdpi/xhdpi/xxhdpi
2. 不希望被拉伸的图片，需要放到assets或者nodpi的目录下。

#### 4.5 try catch某个大内存分配操作
1. catch OOM，然后做一些降级的内存分配操作。如decode Bitmap时，catch OOM，就尝试把采样比例增加一倍，再decode。

#### 4.6 谨慎使用static对象
#### 4.7 单例对象中不合理的持有
#### 4.8 Services资源—— 尽量使用Intent Service
#### 4.10 谨慎使用abstract编程
1. 抽象会导致一个显著的额外内存开销？

#### 4.11 使用nano protobufs序列化数据
1. Protocol buffers是Google为序列化结构数据而设计，与语言，平台都无关。
2. 具有良好的扩展性，类似XML，但比XML更加快速，简单。
3. 如果需要为数据实现序列化和协议化，可使用nano protobufs。
4. 找了2篇还不错的文章。
	* [在Android中使用Protocol Buffers](https://www.jianshu.com/p/e8712962f0e9) 使用插件protobuf-gradle-plugin 
	* [Google Protocol Buffer 的使用和原理](https://www.ibm.com/developerworks/cn/linux/l-cn-gpb/index.html)

#### 4.12 谨慎使用依赖注入
1. 使用依赖注入DI(Dependency Injection)可以简化代码,在Java中称为注解Annotation
2. 常用的[Dragger](https://www.jianshu.com/p/cd2c1c9f68d4)
3. 做法：目标类(需进程初始化的类)依赖其他的类进行初始，而不是手动编码，这是通过注解方式将其他类的实例注入到目标类中。
4. 
#### 4.13 谨慎使用多线程
#### 4.14 使用不同的方式优化内存占用



## 一 Android Device Monitor设备监视器
1. `DDMS`——Dalvik Debug Monitor Service，Android Studio 3.0中弃用。
2. `TraceView`——检查.trace文件，或者分析已捕获的文件。可以使用CPU Monitor。
3. `Systrace`——检查本机系统进程，并解决丢帧引起的UI问题，可以使用CPU Monitor。
4. `OpenGL ES跟踪器`——[图形API调试器](https://github.com/google/gapid)
5. `Layout Inspector布局查看器`—— 运行时应用的视图层次结构。像素完美等。 


### 1. DDMS Heap Viewer
1. 实时查看APP分配内存，和空闲内存的大小
2. 发现Memory Leaks

![Heap Viewer](https://raw.githubusercontent.com/rlq/image/master/oom/ddms_heap.png)


#### 1.1 Cause GC一栏中
1. `HeapSize` 分配给APP内存的堆空间大小
2. `Allocated` 已分配使用的内存大小
3. `Free` 空闲内存大小
4. `% Used = Allocated / HeapSize`使用率
5. `Object` 对象数量

#### 1.2 Display详情
1. `free` 空闲对象
2. `data object` 数据对象，类对象
3. `class object` 类对象性
4. `1-bytearray(byte[],boolean[])` 一个字节的数组对象
5. `2-bytearray(short[],char[])`  两个字节的数组对象
6. `4-bytearray(long[],double[])`  4个字节的数组对象
7. `non-Java object`  非Java对象
8. 每一列 Count， Total Size， Smallest（将对象占用内存的大小从小往大排，排在第一个的对象占用内存大小），Largest，Median（将对象占用内存的大小从小往大排，拍在中间的对象占用的内存大小),Average.


#### 1.3 Allocation count per size
1. 横坐标是对象内存的大小。随不同对象而不同。纵坐标是内存大小上的对象数量。


#### 1.4 如何使用
1. Heap Viewer的数值会在每次GC时进行更新，所以我们需要在检测OOM的用例执行后，手动GC，然后观察data object一栏中的total size，看看内存是否会回到一个稳定值，多次操作后如果内存稳定在某个值，则没有OOM。如果每次GC后都在增长说明有可能OOM。
2. 检测内存抖动，是因为频繁GC导致，所以观察数据变量，在某段时间内是否频繁更新数据。

## 二 Android Monitors
1. Android Studio 3.0删除了该工具。改用`Android Profiler`。
2. 窗口视图：logcat Memory CPU GPU Network。
	![视图](https://developer.android.com/studio/images/am-androidmon2_2x.png)
3. 选择设备和应用，手机dumpsys系统信息，并创建正在运行的应用的截图和视频。

### 1. 准备工作
1. 硬件
	* USB连接硬件设备，而不是模拟器。
	* Tool > Android > Enable ADB Intergration
	* Android Device Monitor 不能运行。
2. Logcat Monitor
	* 打开设备的`开发者选项，打开USB调试`。
	* 在应用中debuggable=true添加到AndroidManifest或build.gradle。
3. GPU Monitor
	* Android5.0后，在模拟器上打开`开发者选项`，使用`adb shell dumpsys gfxinfo`设置`Profile GPU rending`。

### 2. 显示Android Monitor
1. 点击Android Monitor，默认位于主窗口的底部。
2. 或选择 View > Tool Windows > Android Moniotr.

### 3. 分析正在运行的应用
1. 打开一个应用，使用工具查看


### 4. Allocation Tracker 分配追踪内存
1. Android Studio 3.0中移除了。结合Android Monitor使用。
2. 执行以下操作：
	* 对象分配类型的时间和位置，大小，分配的线程和堆栈跟踪。
	* 通过循环分配/释放模式帮助识别内存流失。
	* 使用Hprof Viewer一起追踪内存泄漏。
 3. 显示信息：分配的Java方法，实例总数，内存总量等。
 4. [分配追踪器](https://developer.android.com/studio/profile/am-allocation)

#### 4.1 获取和显示分配数据的快照
1. 在Memory Monitor中显示正在运行的应用程序。
2. 点击开始分配跟踪  开始分配跟踪图标。
3. 开始分配跟踪图标再次单击开始分配跟踪 以取消选择并结束快照。

	内存监视器显示拍摄快照的时间段。在下图中，您可以看到快照周期，如左侧所示。相比之下，当转储Java堆时，内存监视器只显示堆快照的拍摄点
	
	![如下图所示](https://developer.android.com/images/tools/am-dumpalloc2.png)
	
	例如，Android Studio package_yyyy.mm.dd_hh.mm.ss.alloc使用活动包（或项目）名称，年份，月份，日期，小时，分钟和秒等 创建带有文件名的堆快照文件com.android.calc_2015.11.17_14.58.48.alloc。
	
	分配跟踪器出现。

4. 可选择单击图形图标图形图标以显示数据的可视表示。
5. 选择您想要显示的分组依据菜单选项：
	* 由分配者分组
	* 按方法分组

#### 4.2 分配跟踪文件
1. 点击Captures主窗口。View > Tool Windows > Captures.
2. 打开分配追踪文件夹，即可看到。
3. 在分配追踪器重，右键单击某个方法，然后选择跳转到源文件。


### 5. CPU Monitor

### 6. Memory Monitor
1. 内存分析
	* 显示一段时间内可用和分配的Java内存的图形。
	* 随时间显示垃圾回收（GC）事件。
	* 启动垃圾回收事件。
	* 快速测试应用程序运行缓慢是否与过度垃圾回收事件有关。
	* 快速测试应用程序崩溃是否与内存不足有关。
2. [Memory Monitor](https://developer.android.com/studio/profile/am-memory)

### 7. Network Monitor
1. y轴以千字节每秒为单位，x以分秒开始。

### 7. Method Tracer
1. Android Studio 3.0移除。
2. 与Allocated Tracer类似。
3. [Method Tracer](https://developer.android.com/studio/profile/am-methodtrace)


## 三 Android Profiler
1. Android Studio 3.0 使用Android Profiler 代替Android Monitor。
2. Android Profiler 提供关于应用CPU，内存和网络Activity的实时数据。记录代码执行时间，采集堆转储数据，查看内存分配，以及网络传输文件的详情。
3. [Profile Your App Performance](https://developer.android.com/studio/profile/)

### 1. Android Profiler窗口
1. View > Tool Windows > Android Profiler.(也可点击工具栏中的Android Profiler)
2. 选择要分析的设备与应用。确保启用USB调试。

### 2. 分析内容
1. 共享时间线：CPU，内存，网络使用信息
2. 时间线缩放控件，实时更新跳转按钮，Activity状态，用户输入Event和屏幕旋转Event时间线等。
3. 启动后，会持续手机分析数据，直到断开为止。
4. 并非所有的分析数据都可见，在运行时需要配置`启用高级分析`，`Advances profiling is unavaliable for the selected process`.

### 3. 启用高级分析
1. 功能包括
	* Event时间线
	* 分配对象数量
	* 垃圾回收Event
	* 有关所有传输的文件详情
2. 启用步骤
	* Run > Edit Configurations.
	* 左侧窗格选择应用
	* 点击Profiling标签，选**Enable advanced profiling**.
3. 重新构建应用，获取完整的分析功能。
	
	
### 4. CPU Profiler
1. 监控CPU的使用率和线程Activity。
2. 对于每个线程，可以查看一段时间内执行了那些函数，以及其消耗的CPU资源。可以使用函数跟踪来识别调用方和被调用方。			
3. 可以使用[Systrace](https://developer.android.com/studio/command-line/systrace)解决帧引起的界面卡顿。
4. 使用[TraceView](https://developer.android.com/studio/profile/traceview)分析。
5. 

### 5. Memory Profiler

### 6. Network Profiler 
	
## 四 LeakCanary检测内存
1. 直接对.hprof文件进行分析，找到对象的引用链。
2. 在build.gradle文件中添加

	```
	dependencies { 
    debugCompile 'com.squareup.leakcanary:leakcanary-android:1.3' 
    releaseCompile 'com.squareup.leakcanary:leakcanary-android-no-	op:1.3' 
	}
	```
3. 在Application的onCreate中添加`LeakCanary.install(this);`
4. 如果检测到OOM就会发送到通知栏，点击跳转即可到分析页面。

![leakCanary [kə'neərɪ]](https://raw.githubusercontent.com/rlq/image/master/oom/leakCanary.png)





## 五 TraceView


## 六 systrace
1. systrace 命令允许在系统级别手机和检查设备上所有进程的信息。将内核数据(CPU调度城促，磁盘活动和应用程序的线程)组合为HTML报告。
2. 需要安装python，并且连接到设备。
3. python(不支持python3) systrace.py [options] [categories]
4. 如调用systrace 10s内记录设备进程，包括图形进程，生成一个mynewtrace.html文档`python systrace.py --time=10 -o mynewtrace.html gfx`
5. [systrace](https://developer.android.com/studio/command-line/systrace)

### 1. 命令选项
1. `-o file`写入到文件中
2. `-t N | --time=N`跟踪设备活动N秒，如果不指定则会提示按enter结束
3. `-b N | --buf-size=N`跟踪缓存区的大小
4. `-k functions | --ktrace=functions`指定内核函数活动
5. `-a app-name | --app=app-name`指定应用跟踪。
6. `--from-file=file-path`从文件创建html，而不是运行时跟踪。
7. `-e device-serial | --serial=device-serial`由设备序列号标识的特定连接设备上进程跟踪。
8. `categories`包含指定系统进程的跟踪信息，例如gfx呈现图形进程。

### 2. 调查UI性能问题
1. 分析

## 七 MAT——Memory Analyzer
1. JVM记录系统的运行状态，将其存贮在堆转储Heap Dump文件中。
2. 可通过MAT分析OOM。
3. MAT统计 size:2.2MB Classes:3.3k Objects:50.1k ClassLoader:84 Unreachable Objects Histogram


### 1. 准备环境和测试数据

#### 流程
1. 官网下载 `https://www.eclipse.org/mat/downloads.php`
2. 模拟OOM，可使用Bitmap查看工具GIMP，下载地址`http://www.gimp.org/`
3. 点击AS界面的Monitor按钮打开DDMS界面，点击`Dump HPROF file`按钮导出hprof后缀的文件，保存到platform-tools下(方便转换文件)
4. 由于导出后的文件不能直接被MAT识别，需要通过hprof-conv命令转换下，如`hprof-conv 0521.hprof new0521.hprof`.

![mat](https://raw.githubusercontent.com/rlq/image/master/oom/mat.png)


### 2. 分析

#### 2.1 原因
1. 需要引入新的库。
2. dump和分析内存都很耗时，效率难以接受。
3. OOM时内存已经几乎耗尽，再加载内存dump文件并分析会导致二次OOM，得不偿失。
4. 内存较低，分辨率偏高，出现OOM概率就会高。

#### 2.2 模拟OOM
1. 压力测试。
2. 选取图片资源多且较为复杂的页面。
3. 加载N多次该页面，增加OOM几率。


#### 2.3 分析和解决的3个步骤
1. 对问题发生的时刻的系统内存状态获取一个整体印象。
2. 找对最有可能导致OOM的对象。
3. 内存消耗的具体行为。

#### 2.4 Histogram使用方法
2. 打开MAT，File -> Open Heap Dump,选择hprof文件，等待加载。
3. 在Overview中查看饼状图，可以看到内存占用情况。
4. 点击Histogram按钮，输入应用包名，点击`Retained Heap`查看`当前类`内存占用情况。
5. 从**Retained Heap**排序看，结合不同维度，`Group by class、Group by superclass、Group by class  loader、Group by package`.
6. 只要有溢出，时间久了，溢出类的实例数量或者其占有的内存会越来越多，排名也就越来越前，通过多次对比不同时间点下的Histogram图对比就能很容易把溢出类找出来。
7. 如果是Bitmap对象占用内存很高，选中Buffer到处byte[]，保存到指定目录，文件后缀名为.data。打开安装好的GIMP，文件->打开，选中.data文件，查看是什么图片导
致OOM的。

![import hprof](https://raw.githubusercontent.com/rlq/image/master/oom/mat_import_histogram.png)

![Histogram](https://raw.githubusercontent.com/rlq/image/master/oom/mat_histogram.png)



#### 2.5 Dominator Tree使用方法
1. **Dominator Tree（支配树）**：列出每个`对象(Object instance)`与其引用关系的树状结构，还包含了占有多大内存，所占百分比.
2. 找出percentage比较大的值，多个维度查看对象。
3. 站在对象的角度上分析引用关系。

![dominator_tree](https://raw.githubusercontent.com/rlq/image/master/oom/mat_dominator_tree.png))

#### 2.6 Path to GC Roots
1. 定位到疑是移除的对象和类后，选择Path to GC Roots 或 Merge Shortest Paths to GC Roots,可以添加一些过滤，留下强引用的对象。
2. 直接定位具体代码，看看如何释放这些不该存在的对象，是否被cache，还是别的原因。
3. 找到原因，清理干净，再次对照之前的操作，看看对象是否溢出。
4. 最后用jstat跟踪一段时间，查看Heap内存区域是否稳定在一个范围内。

![Path to](https://raw.githubusercontent.com/rlq/image/master/oom/mat_pathto.png)

![path](https://raw.githubusercontent.com/rlq/image/master/oom/mat_path2.png)

#### 2.7 其他
1. 此外通过list objects或show objects by class也可以达到类似的效果，不过没看GC Roots的方式直观。
2. list objects -- with outgoing references : 查看这个对象持有的外部对象引用。
3. list objects -- with incoming references : 查看这个对象被哪些外部对象引用。
4. show objects by class  --  with outgoing references ：查看这个对象类型持有的外部对象引用
5. show objects by class  --  with incoming references ：查看这个对象类型被哪些外部对象





#### 参考文章
1. [使用 Eclipse Memory Analyzer 进行堆转储文件分析](https://www.ibm.com/developerworks/cn/opensource/os-cn-ecl-ma/index.html)
2. [如何用MAT分析Android程序的内存泄露](https://www.cnblogs.com/baiyi168/p/5684251.html)
3. [揪出内存占用的罪魁祸首——Android MAT工具使用](https://www.jianshu.com/p/0125e1bf0531)
4. [出现Android OOM,如何分析和解决?](https://blog.csdn.net/u013303600/article/details/70187745)
5. [Memory Analyzer Tool 使用手记](http://wensong.iteye.com/blog/1986449)
6. [使用新版Android Studio检测内存泄露和性能](https://blog.csdn.net/yangxi_pekin/article/details/51860998)
7. [TraceView使用](https://blog.csdn.net/hpc19950723/article/details/53574674)
8. [Android内存优化之OOM](https://blog.csdn.net/jdsjlzx/article/details/49107183)




