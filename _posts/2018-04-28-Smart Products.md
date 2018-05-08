---
layout: post
title: ART
category: Android
tags: [Android]
---


## 一 ART

### 1. Dalivk 
1. Android4.4-
2. Apk在打包的过程中: java源代码通过javac编译成**.class文件**，再转换成Dalvik虚拟机执行的.dex文件，也就是JIT(Just in time)即时编译。
3. 启动的时候会先将.dex文件转换成快速运行的机器码.oat文件
4. 缺点：app启动慢。


### 2. ART特点
1. Android4.4+
2. 兼容Dalvik虚拟机的特性
3. 新特性：预编译AOT（ahead of time）—— 安装APK时就将dex直接处理成虚拟机可执行的机器码.oat文件。
4. 优点：
	* 加快APP冷启动速度
	* 提升GC速率，主要是GMS的改善
	* 提供功能全面的debug特性
5. 缺点：
	* App安装速度慢，安装时需要生成.oat文件
	* App占用内存空间大，.oat文件比字节码文件大


## 二 ART GC机制
1. 默认CMS并发标记清除。
2. 应用将进程转换到后台或者缓存等进程状态时，ART将执行对压缩。
3. 引入了一种基于位图的新的内存分配程序，称为RosAlloc(插槽运行分配器)，具有分片锁，当分配规模较小时刻添加线程的本地缓冲区，因而性能优于DlMalloc。
4. 















