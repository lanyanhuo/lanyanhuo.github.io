---
layout: post
title: Jet_Compose
category: Android
tags: [Android]
---

## Jetpack Compose

[Jetpack Compose官方文档](https://developer.android.google.cn/jetpack/compose/tutorial)


### 1. 基础
1. `Compose`用于构建Android UI，使用少量代码，强大的工具和直观的Kotlin API简化并加速Android UI的开发。
2. 无需编辑XML，直接使用Compose函数提供的元素，然后由Compose编译器完成UI构建。
   ![](https://raw.githubusercontent.com/rlq/image/master/android/as2_compose_features.png)


### 2. 可组合功能

#### 2.1 文本元素
1. `setContent`块定义活动的布局。代替使用XML文件定义布局内容，我们调用可组合函数。Jetpack Compose使用自定义的Kotlin编译器插件将这些可组合功能转换为应用程序的UI元素。。

   ```kotlin
   class MainActivity : AppCompatActivity() {
       override fun onCreate(savedInstanceState: Bundle?) {
           super.onCreate(savedInstanceState)
           setContent {
               Text("Hello world!")
           }
       }
   }
   ```

2. 例如，该 `Text()`功能由Compose UI库定义；您可以调用该函数在应用中声明文本元素。

#### 2.2 定义可组合函数
1. 只能从其他可组合函数的范围内调用可组合函数。要使函数可组合，请添加 `@Composable` 注释。要尝试此操作，请定义一个**`Greeting()`**传递名称的 函数，并使用该名称配置文本元素。                              

   ```kotlin
   class MainActivity : AppCompatActivity() {
     override fun onCreate(savedInstanceState: Bundle?) {
       super.onCreate(savedInstanceState)
       setContent {
         Greeting("Android")
       }
     }
   }
   @Composable
   fun Greeting(name: String) {
       Text (text = "Hello $name!")
   }
   ```

#### 2.3 在AS中预览

1. AS Canary4.1支持预览Compose功能。

2. 创建另一个名为的函数`PreviewGreeting()`，该函数 `Greeting()`使用适当的参数进行调用 。在`@Preview`之前添加注释 `@Composable`。

   ```kotlin
   @Composable
   fun Greeting(name: String) {
       Text (text = "Hello $name!")
   }
   
   @Preview
   @Composable
   fun PreviewGreeting() {
       Greeting("Android")
   }            
   ```

3. Rebuild，AS添加了预览窗口，此窗口显示了由带有`@Preview` 注释的可组合函数创建的UI元素的预览。要随时更新预览，请单击预览窗口顶部的**刷新**按钮。

### 3. 布局


#### 3.1 添加一些文本
1. 在setContent()中添加`NewStory()`, 但这几个Text没有层级关系

   ```kotlin
   @Composable
   fun NewsStory() {
       Text("A day in Shark Fin Cove")
       Text("Davenport, California")
       Text("December 2018")
   }
   
   @Preview
   @Composable
   fun DefaultPreview() {
       NewsStory()
   }
   ```

#### 3.2 使用列
1. 该`Column()`功能使您可以垂直堆叠元素。添加`Column()`到`NewsStory()`功能.

   ```kotlin
   @Composable
   fun NewsStory() {
       Column {
           Text("A day in Shark Fin Cove")
           Text("Davenport, California")
           Text("December 2018")
       }
   }
   ```

#### 3.3 添加Style修饰列
1. `WorkRequest.Builder.setInputData(Data)`将参数传递给任务。

   ```kotlin
   @Composable
   fun NewsStory() {
       Column(
           crossAxisSize = LayoutSize.Expand,
           modifier=Spacing(16.dp)
       ) {
           Text("A day in Shark Fin Cove")
           Text("Davenport, California")
           Text("December 2018")
       }
   }`
   ```

#### 3.4 添加一张图片

1.  添加1张图片

   ```java
   @Composable
   fun NewsStory() {
       val image = +imageResource(R.drawable.header) // 这个image为什么不定义到Column中
       Column(
           crossAxisSize = LayoutSize.Expand,
           modifier=Spacing(16.dp)
           ) {
           DrawImage(image) // 这种样式，image全屏显示，3个Text在image的左上角
         	
         	Container(expanded = true, height = 180.dp) {
               DrawImage(image) // 这种样式，image的高被限制，3个Text显示在image下方
           }
         
           Text("A day in Shark Fin Cove")
           Text("Davenport, California")
           Text("December 2018")
       }
   }
   ```

   ![](https://raw.githubusercontent.com/rlq/image/master/android/as1_compose_image.png)

### 4. 材料设计 Material design

1. 构建Compose是为了支持材料设计原则。它的许多UI元素都是开箱即用地实现材料设计。

#### 4.1 shape应用

1. 实现圆角矩形

```kotlin
@Composable
fun NewsStory() {
    val image = +imageResource(R.drawable.header)

    Column(
        crossAxisSize = LayoutSize.Expand,
        modifier=Spacing(16.dp)
    ) {
        Container(expanded = true, height = 180.dp) {
            Clip(shape = RoundedCornerShape(8.dp)) {
                DrawImage(image) // 将image个4角形状改为圆角矩形
            }
        }

        HeightSpacer(16.dp)

        Text("A day in Shark Fin Cove")
        Text("Davenport, California")
        Text("December 2018")
    }
}
```

#### 4.2 设置文字样式
1. 应用`MaterialTheme()` 设置文字样式。

   ```kotlin
   @Composable
   fun NewsStory() {
       val image = +imageResource(R.drawable.header)
   
       MaterialTheme {
           Column(
               crossAxisSize = LayoutSize.Expand,
               modifier=Spacing(16.dp)
           ) {
               Container(expanded = true, height = 180.dp) {
                   Clip(shape = RoundedCornerShape(8.dp)) {
                       DrawImage(image)
                   }
               }
   
               HeightSpacer(16.dp)
   
               Text("A day in Shark Fin Cove",
                   style = +themeTextStyle { h6 })
               Text("Davenport, California",
                   style = +themeTextStyle { body2 })
               Text("December 2018",
                   style = +themeTextStyle { body2 })
             
             // 使用长标题，限制行数等，
               Text("A day wandering through the sandhills in Shark " +
                   "Fin Cove, and a few of the sights I saw",
                   maxLines = 2, overflow = TextOverflow.Ellipsis,
                   style = (+themeTextStyle { h6 }).withOpacity(0.87f))
               Text("Davenport, California",
                   style = (+themeTextStyle { body2 }).withOpacity(0.87f))
               Text("December 2018",
                   style = (+themeTextStyle { body2 }).withOpacity(0.6f))
           }
       }
   }
   ```

### 5 [实例](https://developer.android.google.cn/jetpack/compose/setup#sample)

#### 5.1 [Jetpack sample app](https://github.com/android/compose-samples/)

#### 5.2 创建一个新的Compose APP

#### 5.3 现有Project中添加Compose

1. 配置app build.gradle

   ```java
   android {
       defaultConfig {
           minSdkVersion 21
       }
   
       buildFeatures {
           // Enables Jetpack Compose for this module
           compose true
       }
   
       // Set both the Java and Kotlin compilers to target Java 8.
       compileOptions {
           sourceCompatibility JavaVersion.VERSION_1_8
           targetCompatibility JavaVersion.VERSION_1_8
       }
       kotlinOptions {
           jvmTarget = "1.8"
       }
   }
   dependencies {
       // You also need to include the following Compose toolkit dependencies.
       implementation 'androidx.ui:ui-tooling:0.1.0-dev02'
       implementation 'androidx.ui:ui-layout:0.1.0-dev02'
       implementation 'androidx.ui:ui-material:0.1.0-dev02'
       ...
   }
   ```

2. 配置Project build.gradle

   ```java
   buildscript {
       repositories {
           google()
           jcenter()
           // To download the required version of the Kotlin-Gradle plugin,
           // add the following repository.
           maven { url 'https://dl.bintray.com/kotlin/kotlin-eap' }
       ...
       dependencies {
           classpath 'com.android.tools.build:gradle:4.0.0-alpha01'
           classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.60-eap-25'
       }
   }
   
   allprojects {
       repositories {
           google()
           jcenter()
           maven { url 'https://dl.bintray.com/kotlin/kotlin-eap' }
       }
   }
   ```

#### 5.4 实时预览





### 6 [源码](https://developer.android.google.cn/reference/kotlin/androidx/ui/foundation/shape/corner/package-summary#roundedcornershape_1)

1. 包：androidx.ui.foundation.shape.corner

2. 类：

   | [CornerBasedShape](https://developer.android.google.cn/reference/kotlin/androidx/ui/foundation/shape/corner/CornerBasedShape.html) | Base class for [Shape](https://developer.android.google.cn/reference/kotlin/androidx/ui/engine/geometry/Shape.html)s defined by four [CornerSize](https://developer.android.google.cn/reference/kotlin/androidx/ui/foundation/shape/corner/CornerSize.html)s. |
   | ------------------------------------------------------------ | ------------------------------------------------------------ |
   | [CutCornerShape](https://developer.android.google.cn/reference/kotlin/androidx/ui/foundation/shape/corner/CutCornerShape.html) | A shape describing the rectangle with cut corners.           |
   | [RoundedCornerShape](https://developer.android.google.cn/reference/kotlin/androidx/ui/foundation/shape/corner/RoundedCornerShape.html) | A shape describing the rectangle with rounded corners.       |

