## 1. AS或IDEA报Android Support插件版本不匹配问题分析及解决

This version of the Android Support plugin for IntelliJ IDEA (or Android Studio) cannot open this project, please retry with version 4.2 or newer. 

作者：GCC酱_0ff1c1a1 https://www.bilibili.com/read/cv11451466 出处：bilibili

#### 我们来分析一下源码,找 Android Gradle Plugin 源码来分析

此处使用 4.2.0 版本

那我们就去对应的文件位置里看看

![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-10-12-15-37-07-image.png)

agp-version-detect
那么我们应该去了解一下这个版本是如何解析的.
此时关注 parseVersion() 方法

![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-10-12-15-37-23-image.png)

android-plugin-ver-idea

### 0x00 IDEA 插件版本解析

根据调试器可以得知这里输入的版本号就是 Android 插件的版本号

对于 IDEA 来说是 10.4.1.1.211.7142.45
![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-10-12-15-39-31-image.png)
精彩的部分是这里,由于年份为 10 不匹配大于 2000 的条件,所以走了最下面的处理

然后使用 Kotlin 的命名函数,在创建对象的时候砍掉了年份,只留下主要和次要版本
所以得到的插件版本是 0.4.1

### 0x01 AGP 版本解析

![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-10-12-15-39-58-image.png)

### 0x02 AS 插件版本解析

AS 里面插件版本跟 IDEA 不一样,拆开插件 jar 之后可以得到
文件在 android/adnroid.jar/META-INF/plugin.xml
部分内容如下

由于B站编辑器代码块过于奇葩,这里就截图了

![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-10-12-15-40-18-image.png)

plugin.xml
这个版本号解析出来是 202.7660 走一遍就是 0.202.7660

### 0x03 版本号比较

此处重写了 compareTo 函数来实现.逻辑如下

```
override fun compareTo(other: MajorMinorVersion): Int {
 var diff = this.yearVersion - other.yearVersion
 if (diff != 0) {
 return diff
 }
 diff = this.majorVersion - other.majorVersion
 if (diff != 0) {
 return diff
 }
 return minorVersion - other.minorVersion
}
```

首先判断年份是否相同
然后判断主要版本
再判断次要版本
都是按照数字大小匹配

那你 0.4.1 肯定比 0.4.2 小,所以这里炸了

![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-10-12-15-40-58-image.png)

agp-debug-version-diff

### 0x04 解决方案

手工关闭检查
在最开始 verifyIDEIsNotOld() 中有这么一段

if (!projectOptions[BooleanOption.ENABLE_STUDIO_VERSION_CHECK]) {
    return
}
去看看这个 BooleanOption.ENABLE_STUDIO_VERSION_CHECK
发现他的选项是这个 android.injected.studio.version.check
也就是我们在 properties 文件里设定这个 Key 为 false 即可跳过检测

### 等待 IDEA 版本更新

根据 IDEA 官方的 YouTrack 下面的讨论.这个插件版本将会在 IDEA 2021.2 中升级.各位可以

### 等待高版本

下面是一些参考

https://youtrack.jetbrains.com/issue/IDEA-264255
https://youtrack.jetbrains.com/issue/IDEA-268850
https://youtrack.jetbrains.com/issue/IDEA-252823

使用 AGP7+
另外还可以尝试一下 AGP7+ 版本

### 在 AGP7+ 中获取最小要求版本的逻辑有变化

val minRequiredVersion = when (androidGradlePluginVersion) {
    MajorMinorVersion(majorVersion = 7, minorVersion = 0) -> MajorMinorVersion(2020, 3, 1)
    else -> androidGradlePluginVersion
}
可以看到这里不再是用 AGP 版本号了,而是定义了一个年份开头的版本
在这个情况下比较的时候,年份设定为 2020
出来的版本号是 2020.3.1
在比较的时候 2020 一定是比 0 大的,这就直接结束了比较.

## 2. Android Studio4.1升级后配置文件及快捷键失效重置问题

之前Android studio 配置文件和快捷键位置在
/Users/用户名/Library/Preferences/AndroidStudio版本号/
升级后配置文件位置改为
/Users/用户名/Library/Application Support/Google/AndroidStudio4.1

快捷键配置文件位置在 keymaps 目录下，我们可以将之前的自定义配置拷贝过来即可，然后重启studio
————————————————
版权声明：本文为CSDN博主「pop1234o」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：[Android Studio4.1升级后配置文件及快捷键失效重置问题_pop1234o的博客-CSDN博客](https://blog.csdn.net/u012203641/article/details/109476602)

### 3. com/android/tools/idea/gradle/run/OutputBuildAction has been compiled by a more recent version of the Java Runtime (class file version 55.0), this version of the Java Runtime only recognizes class file versions up to 52.0

根本原因是Android Studio Dolphin是通过java11来编译的，不再支持java11来直接运行调试，解决方法只能升级到jre java11

![](https://ask.qcloudimg.com/http-save/yehe-1073733/8b6903f0bf1d8531e3f8fd4fa67c2187.png?imageView2/2/w/1620)

![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-10-13-19-43-48-image.png)

### # Android Studio Dolphin | 2021.3.1更新 新版Logcat]([Android Studio Dolphin | 2021.3.1更新 新版Logcat_补补23456的博客-CSDN博客](https://blog.csdn.net/weixin_43873389/article/details/127235507))

logcat更新了，本文复制自官网的更新说明，怕以后网站页面换来换去找不到这个说明了记录一下。试了一下不是很习惯，又在设置里改回去了qaq。慢慢适应

**改回原logcat的方法：**

File - Settings - Experimental 取消勾选 Enable new Logcat tool window 

![](https://img-blog.csdnimg.cn/434c28e7a98f4586b3c8b5220e69809f.png)

**新的筛选功能**

如果不知道如何输入，看提示说的是ctrl+空格，不过我这里测试需要ctrl+alt+空格才有效。比如输入package: ，然后按ctrl+alt+空格就会提示当前正在运行的进程。

![](https://img-blog.csdnimg.cn/fc39802c28144c0c881972625167b221.png)![](https://img-blog.csdnimg.cn/719232be28f04994b91ba67f12710a05.png)

 好了以下是[官网](https://developer.android.com/studio/releases/#logcat "官网")更新说明。（页面可能具有时效性）

## 更新了 Logcat

更新了 Logcat，让您可以更轻松地解析、查询和跟踪日志。

### 新增了格式化功能

Logcat 现在会对日志进行格式化，以便更轻松地扫描有用的信息（例如标记和消息）以及识别不同类型的日志（例如警告和错误）。

![](https://img-blog.csdnimg.cn/807d8135a9b441f39aa10285e046bb99.png)

### 创建多个 Logcat 窗口

您现在可以在 Logcat 中创建多个标签页，以便在不同设备或查询之间轻松切换。右键点击标签页可对其重命名，点击并拖动可重新排列标签页。

此外，为了帮助您更轻松地比较两组日志，您现在可以在一个标签页中拆分视图，方法是右键点击日志视图，然后选择 **Right Right** 或 **Split Down**。如需关闭分屏，请右键点击并选择 **Close**。每个分屏都允许您设置自己的设备连接、视图选项和查询。

![](https://img-blog.csdnimg.cn/05e9555a7eed4f1b9d01dfa898333994.png)

### 在视图预设之间切换

Logcat 现在可允许您在不同视图模式之间快速切换，包括 **Standard**、**Compact** 和 **Custom**。方法是点击 ![](https://img-blog.csdnimg.cn/67d669a504aa46188305882ee91f03f9.png)。 每种视图模式都会提供不同的默认设置，用于向您显示更多或更少的信息，例如时间戳、标记和进程 ID (PID)。您还可以通过选择 **Modify View** 来自定义每个默认视图模式以及自定义视图模式。

 ![](https://img-blog.csdnimg.cn/15d20b8a8f3446818fc4887308d9ce9b.png)

### 新增了键值对搜索

在之前的 Logcat 版本中，您可以选择使用字符串搜索（支持正则表达式），也可以使用 Logcat 界面填充各个字段来创建新的过滤器。第一个选项会使搜索变得更加复杂，第二个选项会使共享和设置查询变得更加困难。现在，我们直接在主查询字段中引入了键值对搜索，从而简化了体验。

![](https://img-blog.csdnimg.cn/9e2280482e8a43d09a461ed92963a40a.png)

借助这个新的查询系统，您无需查询正则表达式即可准确查询内容，还可以从历史记录中撤消以往的查询，并与他人共享这些查询。此外，您仍然可以使用正则表达式，并基于键值对来排除日志。以下示例说明了如何使用新的查询系统，但您也可以直接在查询字段中键入内容以查看相关建议：

- **本地应用项目的 PID**：`package:mine`
- **特定值**：
  - `package:<package-ID>`
  - `tag:<tag>`
  - `level:[VERBOSE | INFO | ASSERT |DEBUG | WARN | ERROR ]`
- 在键前面添加 `-` 以**排除特定值**：
  - `-tag:<exclude-tag>`
- 在给定键后面添加 `~` 以对其**使用正则表达式**：
  - `tag~:<regular-expression-tag>`
  - 与排除标记结合使用：`-tag~:<exclude-regular-expression-tag>`

您还可以查看查询的历史记录，方法是：点击查询字段中的 ![](https://img-blog.csdnimg.cn/082cb561fb254f5694730456c735ad16.png)，然后从下拉列表中选择。如需收藏某个查询，使其在所有 Studio 项目中始终位于列表顶部，请点击查询字段末尾的![](https://img-blog.csdnimg.cn/60eca07e15094690a0e576fc800bc23b.png) 。

![](https://img-blog.csdnimg.cn/77b83d0ab4324addb2637ec8d063a0be.png)

### 跟踪应用崩溃/重启日志

借助新的 Logcat，您现在可以更轻松跟踪应用崩溃和重启日志，以免错过这些事件的重要日志。 当 Logcat 发现您的应用进程已停止并重启时，您会在输出中看到一条消息（例如 `PROCESS ENDED` 和 `PROCESS STARTED`），如下所示：

![](https://img-blog.csdnimg.cn/b75b08ecc81a4638a002abacca2c0725.png)

 重启 Logcat 会保留会话配置（例如标签页拆分、过滤器和视图选项），以便于您轻松继续会话。

### 在AS中找不到JDK路径，可以使用现在配置，或重新下载

ERROR: JAVA_HOME is set to an invalid directory: /Applications/Android Studi

![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-11-01-14-49-46-image.png)

 ![](/Users/renliqin/Library/Application%20Support/marktext/images/2022-11-01-14-50-27-image.png)

#### Unable to load class 'javax.xml.bind.JAXBException'.

导入项目第一次运行时，报Unable to load class javax.xml.bind.JAXBException这个错。  
解决： 将jdk换成电脑[环境变量](https://so.csdn.net/so/search?q=%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F&spm=1001.2101.3001.7020)中配置的jdk1.8 。  
默认的版本是android studio 中自带的jdk11的。

不想用1.8，就想用11，怎么解决

[*最后还是使用了 AS下的jdk，无论版本怎样，都不会影响*]()

# 