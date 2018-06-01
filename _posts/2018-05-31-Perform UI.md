---
layout: post
title: Perform UI
category: Android
tags: [Android]
---

# UI

## 一 启动优化
1. 冷启动
2. 热启动
3. 测试启动时间
	* adb shell am start -W [PackageName]/[PackageName.MainActivity]
	* ThisTime 当前MainActivity的启动时间
	* TotalTime 整个应用的启动时间，Application + Activity使用的时间
	* WaitTime 系统的影响时间，比前2个大

### 1. 启动流程
1. Application从构造方法开始—>attachBaseContext()—>onCreate()—>
2. Activity构造方法—>onCreate()—>设置显示界面布局，
3. 设置主题、背景等等属性—>onStart()—>onResume()—>显示里面的view（测量、布局、绘制，显示到界面上）


## 二 systrace


## 三 Layout Inspector



#### 参考文章




