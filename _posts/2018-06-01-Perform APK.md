---
layout: post
title: Perform APK
category: Android
tags: [Android]
---


# APK 
## 一 Lint
1. 检测没有用的布局 删除
2. 未使用到的资源 比如 图片 —删除
3. String.xml没有用到的字符。

## 二 图片压缩
1. [Android压缩图片到100K以下并保持不失真的高效方法](http://blog.csdn.net/jdsjlzx/article/details/44229169)
2. [android图片压缩总结](http://blog.csdn.net/jdsjlzx/article/details/44947811)
3. [Android图片压缩（质量压缩和尺寸压缩）&Bitmap转成字符串上传](http://blog.csdn.net/jdsjlzx/article/details/44228935)
4. [bitmap的六种压缩方式，Android图片压缩](http://blog.csdn.net/harryweasley/article/details/51955467)
5. [Android完美加载大图](http://blog.csdn.net/hpc19950723/article/details/64923022)
6. [高效加载图片防止OOM–总结](http://blog.csdn.net/hpc19950723/article/details/53175443)


### 2. 图片格式
1. svg图片:svg图片中包含了一些图片的描述，svg是牺牲CPU的计算能力，达到节省空间目的，复杂的图片不建议用svg。
2. webp：谷歌现在非常提倡的使用。保存图片比较小。webp的无损压缩比PNG文件小45%左右，即使PNG进过其他的压缩工具压缩后，仍然可以减小到PNG的28%。
3. 7zzip工具压缩


## 三 Proguard混淆
1. 可以删除注释和不用的代码。
2. 将java文件名改成短名a.java，b.java 
3. 方法名等 CommonUtil.getDisplayMetrix(); –> a.a()
4. [微信混淆打包](https://github.com/shwenzhang/AndResGuard)

## 四 资源
1. 动态加载：emoji表情、换肤、动态下载的资源、一些模块的插件化动态添加。
2. 


#### 参考文章
1. [Lint](https://blog.csdn.net/hpc19950723/article/details/53574484)
2. [图片优化](https://blog.csdn.net/hpc19950723/article/details/70215902)








