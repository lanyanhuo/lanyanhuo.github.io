---
layout: post
title: Android Things
category: Android
tags: [Android]
---


# Android Things Devices

以下翻译自[Platform/Release/Devices/Android Things](https://developer.android.com/things/)

## 一 概述
1. 连接消费者，零售和工业应用设备。
2. The ease and power of Android 易用性和强大的功能
3. Repid prototypes to real products 快速原型到真正的产品
4. Security and scalability 提供了安全性和可扩展性

### 主题
1. Get a kit 硬件，外围设备的Kit教程
2. Build a Things app 
3. Build a Things prototype硬件的基本知识并且开始成型设备
4. 加入开发社区[Hackster](https://www.hackster.io/google/products/android-things)—— lantern， sight for blind， sentinel 



## 二 Feature and APIs

### 1. System系统

#### 1.1 Home Activity Support主页面
1. 系统启动自动加载的入口。在AndroidManifest中必须包含`CATEGORY_DEFAULT and CATEGORY_HOME`。

	```
	<activity android:name=".HomeActivity">
       <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>

        <!-- 自动启动Activity，如果终止了则重启。 Launch activity automatically on boot, and re-launch if the app terminates. -->
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.HOME"/>
            <category android:name="android.intent.category.DEFAULT"/>
        </intent-filter>
    </activity>
	```

#### 1.2 Device Updates设备更新
1. Apps可通过`Android Things Console控制台`控制和监听OTA(over the air)的进程。
2. 使用`UpdateManager`去设置更新策略和配置OTA更新之后的重启行为。
3. 使用`DeviceManager`触发设备重启或恢复出厂设置。
4. 开发测试阶段，通过`setChannal()`注册不同的渠道比如canary，beta，在Android Things控制台提供独立的OTA Build。
5. [设备更新指南](https://developer.android.com/things/sdk/apis/update)

### 2. Connectivity连接

#### 2.1 Bluetooth蓝牙
1. 通过蓝牙API得到设备状态管理。
2. [`BluetoothProfileManager`](https://developer.android.com/reference/com/google/android/things/bluetooth/BluetoothProfileManager)激活profiles。
3. `BluetoothConfigManager`去设置设备属性和功能。
4. `BluetoothConnectionManager`配对设备，处理配对请求，控制连接状态。
5. [Bluetooth API指南](https://developer.android.com/things/sdk/apis/bluetooth)

#### 2.2 LoWPAN
1. IP-based Low-Power Wireless Personal Area Networks (LoWPAN)。
2. `LowpanManager`发现设备支持的无线电接口，监听状态改变。
3. `LowpanInterface`创建和加入网络。
4. `LowpanScanner`找到附近的其他网络。
5. [LoWPAN指南](https://developer.android.com/things/sdk/apis/lowpan)


### 3. Peripherals外设

#### 3.1 Peripherals I/O
1. 允许APp与sensor，actuators(执行器)使用行业标准协议和接口交互。
2. 接口包括：GPIO，PWM， I2C, SPI, UART等。
3. `PeripheralManager`打开一个连接到这些接口或可用的端口的使用列表。

#### 3.2 User-space Drivers用户空间驱动
1. 驱动器支持以下策略：Location，Input，Sensor，LoWPAN等。
2. `UserDriverManager`可以绑定设备与framework的驱动器。


### 4. Settings

#### 4.1 Date/Time
1. `TimeManager`设置日期和时间。



## 三 Behavior Changes

### 1. Unsupported Features不支持的功能
1. System UI(状态栏，导航，快速设置)—— `NotificationManager, KeyguardManager, WallpaperManager`.
2. VoiceInteractionsService——`SpeechRecoginzer`.
3. fingerprint——`FlingerprintManager`.
4. nfc——`NfcManager`.
5. telephony——`SmsManager, TelephonyManager`.
6. usb.accessory——`UsbAccessory`.
7. wifi.aware——`WifiAwareManger`.
8. software.app_widgets——`AppWidgetManager`.
9. software.autofill——`AutofillManager`.
10. software.backup——`BackUpManager`.
11. software.companion_device_setup——`CompanionDeviceManager`.
12. software.picture_in_picture——`Activity Picture-in-picture`.
13. software.print——`PrintManager`.
14. software.sip——`SipManager`.

### 2. Common Intents
1. 不包括System apps, ContentProvider。
2. 避免使用以下common Intents：
	* CalendarContract
	* ContactsContract
	* DocumentsContract
	* DownloadManager
	* MediaStore
	* Settings
	* Telephony
	* UserDictionary
	* VoicemailContract


### 3. Runtime Permissions
1. 运行时请求的权限在Manifest文件中声明。
2. IoT不需要UI或输入，所以权限都需要在安装时就全部授权。

### 4. Native Code
1. 结合Android NDK.APK运行时使用extractNativeLibs属性。
2. 在AndroidManifest文件中添加`android:extractNativeLibs="false"`.
3. [Integrating native code](https://developer.android.com/things/sdk/apis/native)


### 5. Google Services
![Google Services](https://raw.githubusercontent.com/rlq/image/master/IoT/Google%20Service.png)



## 四 Release Notes

### 1. Hardware
1. 支持产品 System-on-Modules (SoMs)基于以下平台
	* NXP i.MX8M 恩智浦
	* Qualcomm SDA212高通
	* Qualcomm SDA624
	* MediaTek MT8516 联发科
2. 以下平台支持开发
	* Raspberry Pi 3 Model B 
	* NXP i.MX7D

	
	
### 2. Console
[Android Things Console](https://partner.android.com/things/console)



# Android Things started
以下翻译自[Docs/Guides/Devices/Android Things](https://developer.android.com/things/get-started/)

1. Hardware
2. SDK
3. Console
4. Get started


## 一 Developer Kits










## 二 Build Apps













## 三 Prototype Devices

## 四 Manage Products

## 五 Terms



