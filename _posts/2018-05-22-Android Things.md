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

### 1. 主题
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


### 1. Get Started


#### 1.1 Recommended Kits 
1. 提供SoM, carrier board, peripherals.
2. NXP i.MX7D Starter Kit
3. Raspberry Pi Kit
4. Other Kit

#### 1.2 设置开发环境
1. 下载最新AS
2. 使用API27：Android8.1(Oreo),选择Android Things。
3. 创建一个Things App.


## 二 Build Apps

### 1. 创建1个Android Things 工程

#### 1.1 创建一个工程
1. Prerequisites 预备知识，先决条件
2. Get Started
3. Add Library- ` compileOnly 'com.google.android.things:androidthings:+'`
4. Add `HomeActivity`
	* Action: ACTION_MAIN
	* Category: CATEGORY_DEFAULT
	* Category: CATEGORY_HOME

```
<application>
    <uses-library android:name="com.google.android.things"/>
    <activity android:name=".HomeActivity">
        <!-- Launch activity as default from Android Studio -->
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>

        <!-- Launch activity automatically on boot, and re-launch if the app terminates. -->
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.HOME"/>
            <category android:name="android.intent.category.DEFAULT"/>
        </intent-filter>
    </activity>
</application>
```

#### 1.2 连接硬件
1. 连接一侧按钮选择GPIO输入插口，另一边接地。
2. 连接相同的GPIO输入插口通上3.3V的电。
3. 选择GPIO输出连接到另一侧的串联电阻器。
4. 另一边的电阻连接到阳极一侧。
5. 阴极接地。

#### 1.3 与外设交互
1. GPOP——General Purpose Input Output
2. 使用Peripheral I/O API——找到GPIO端口，并且交互。
3. 可用的外设 `PeripheralManager.getInstance().getGpioList()`.
4. 处理button事件

	```
		import com.google.android.things.pio.PeripheralManager;
	import com.google.android.things.pio.Gpio;
	import com.google.android.things.pio.GpioCallback;
	
	public class ButtonActivity extends Activity {
    private static final String TAG = "ButtonActivity";
    private static final String BUTTON_PIN_NAME = ...; // GPIO port wired to the button

    private Gpio mButtonGpio;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        PeripheralManager manager = PeripheralManager.getInstance();
        try {
            // Step 1. Create GPIO connection.
            mButtonGpio = manager.openGpio(BUTTON_PIN_NAME);
            // Step 2. Configure as an input.
            mButtonGpio.setDirection(Gpio.DIRECTION_IN);
            // Step 3. Enable edge trigger events.
            mButtonGpio.setEdgeTriggerType(Gpio.EDGE_FALLING);
            // Step 4. Register an event callback.
            mButtonGpio.registerGpioCallback(mCallback);
        } catch (IOException e) {
            Log.e(TAG, "Error on PeripheralIO API", e);
        }
    }

    // Step 4. Register an event callback.
    private GpioCallback mCallback = new GpioCallback() {
        @Override
        public boolean onGpioEdge(Gpio gpio) {
            Log.i(TAG, "GPIO changed, button pressed");

            // Step 5. Return true to keep callback active.
            return true;
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // Step 6. Close the resource
        if (mButtonGpio != null) {
            mButtonGpio.unregisterGpioCallback(mCallback);
            try {
                mButtonGpio.close();
            } catch (IOException e) {
                Log.e(TAG, "Error on PeripheralIO API", e);
            }
        }
    }
}
	```
5. Blink闪烁LED—— 在LED上连接GPIO，执行闪烁图案。

	```
	import com.google.android.things.pio.PeripheralManager;
	import com.google.android.things.pio.Gpio;
	...
	
	public class BlinkActivity extends Activity {
	    private static final String TAG = "BlinkActivity";
	    private static final int INTERVAL_BETWEEN_BLINKS_MS = 1000;
	    private static final String LED_PIN_NAME = ...; // GPIO port wired to the LED

    private Handler mHandler = new Handler();

    private Gpio mLedGpio;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Step 1. Create GPIO connection.
        PeripheralManager manager = PeripheralManager.getInstance();
        try {
            mLedGpio = manager.openGpio(LED_PIN_NAME);
            // Step 2. Configure as an output.
            mLedGpio.setDirection(Gpio.DIRECTION_OUT_INITIALLY_LOW);

            // Step 4. Repeat using a handler.
            mHandler.post(mBlinkRunnable);
        } catch (IOException e) {
            Log.e(TAG, "Error on PeripheralIO API", e);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // Step 4. Remove handler events on close.
        mHandler.removeCallbacks(mBlinkRunnable);

        // Step 5. Close the resource.
        if (mLedGpio != null) {
            try {
                mLedGpio.close();
            } catch (IOException e) {
                Log.e(TAG, "Error on PeripheralIO API", e);
            }
        }
    }

    private Runnable mBlinkRunnable = new Runnable() {
        @Override
        public void run() {
            // Exit if the GPIO is already closed
            if (mLedGpio == null) {
                return;
            }

            try {
                // Step 3. Toggle the LED state
                mLedGpio.setValue(!mLedGpio.getValue());

                // Step 4. Schedule another event after delay.
                mHandler.postDelayed(mBlinkRunnable, INTERVAL_BETWEEN_BLINKS_MS);
            } catch (IOException e) {
                Log.e(TAG, "Error on PeripheralIO API", e);
            }
        }
    };
}
	
	```

#### 1.4 整合外设
1. 使用`userDriverManager`绑定外设到Android Fragment。
2. 初始设备library
	* `compile 'com.google.android.things.contrib:driver-button:0.6'`
	* 不同的drivers需要不同的权限，`<uses-permission android:name="com.google.android.things.permission.MANAGE_INPUT_DRIVERS" />`
	* 连接
	
	```
	ButtonInputDriver mButtonInputDriver = new ButtonInputDriver(
                    BUTTON_PIN_NAME,
                    Button.LogicState.PRESSED_WHEN_LOW,
                    KeyEvent.KEYCODE_SPACE);
    
    mButtonInputDriver.close();//关闭连接	
	```
3. 绑定Framework
	* 注册一个`ButtonInputDriver`外设作为framework的key input.

	```
	mButtonInputDriver.register();
	mButtonInputDriver.unregister();
	```


### 2. 连接无线设备

#### 1. Bluetooth
1. 权限 `MANAGE_BLUETOOTH, BLUETOOTH, BLUETOOTH_ADMIN`.
2. 配置设备属性
	* 创建`BluetoothClass`,`BluetoothConfigManager. setBluetoothClass(BluetoothClassFactory.build(XX, XX));`
	* I/O 功能 `manager.setIoCapability(BluetoothConfigManager.IO_CAPABILITY_IO);`
	*  启用配置文件，使用`BluetoothProfileManager.enableAndDisableProfiles();`
3. 配对远程设备——`BluetoothConnectionManager， BluetoothPairingCallback, PairingParams `

	```
	mBluetoothConnectionManager.(un)registerPairingCallback(mBluetoothPairingCallback);
	
	private BluetoothPairingCallback mBluetoothPairingCallback = new BluetoothPairingCallback() {

        @Override
        public void onPairingInitiated(BluetoothDevice bluetoothDevice,
                PairingParams pairingParams) {
            // Handle incoming pairing request or confirmation of outgoing pairing request
            handlePairingRequest(bluetoothDevice, pairingParams);
        }

        @Override
        public void onPaired(BluetoothDevice bluetoothDevice) {
            // Device pairing complete
        }

        @Override
        public void onUnpaired(BluetoothDevice bluetoothDevice) {
            // Device unpaired
        }

        @Override
        public void onPairingError(BluetoothDevice bluetoothDevice,
                BluetoothPairingCallback.PairingError pairingError) {
            // Something went wrong!
        }
    };
    
    private void handlePairingRequest(BluetoothDevice bluetoothDevice, PairingParams pairingParams) {
    switch (pairingParams.getPairingType()) {
        case PairingParams.PAIRING_VARIANT_DISPLAY_PIN:
        case PairingParams.PAIRING_VARIANT_DISPLAY_PASSKEY:
            // Display the required PIN to the user
            Log.d(TAG, "Display Passkey - " + pairingParams.getPairingPin());
            break;
        case PairingParams.PAIRING_VARIANT_PIN:
        case PairingParams.PAIRING_VARIANT_PIN_16_DIGITS:
            // Obtain PIN from the user
            String pin = ...;
            // Pass the result to complete pairing
            mBluetoothConnectionManager.finishPairing(bluetoothDevice, pin);
            break;
        case PairingParams.PAIRING_VARIANT_CONSENT:
        case PairingParams.PAIRING_VARIANT_PASSKEY_CONFIRMATION:
            // Show confirmation of pairing to the user
            ...
            // Complete the pairing process
            mBluetoothConnectionManager.finishPairing(bluetoothDevice);
            break;
    }
}
	```

4. 连接设备——`BluetoothConnectionManager, BluetoothConnectionCallback, ConnectionParams `

	```
	 mBluetoothConnectionManager.(un)registerConnectionCallback(mBluetoothConnectionCallback);
   
	// Set up callbacks for the profile connection process.
    private final BluetoothConnectionCallback mBluetoothConnectionCallback = new BluetoothConnectionCallback() {
        @Override
        public void onConnectionRequested(BluetoothDevice bluetoothDevice, ConnectionParams connectionParams) {
            // Handle incoming connection request
            handleConnectionRequest();
        }

        @Override
        public void onConnectionRequestCancelled(BluetoothDevice bluetoothDevice, int requestType) {
            // Request cancelled
        }

        @Override
        public void onConnected(BluetoothDevice bluetoothDevice, int profile) {
            // Connection completed successfully
        }

        @Override
        public void onDisconnected(BluetoothDevice bluetoothDevice, int profile) {
            // Remote device disconnected
        }
    };
    
    private void handleConnectionRequest(BluetoothDevice bluetoothDevice, ConnectionParams connectionParams) {
    // Determine whether to accept the connection request
    boolean accept = false;
    if (connectionParams.getRequestType() == ConnectionParams.REQUEST_TYPE_PROFILE_CONNECTION) {
        accept = true;
    }

    // Pass that result on to the BluetoothConnectionManager
    mBluetoothConnectionManager.confirmOrDenyConnection(bluetoothDevice, connectionParams, accept);
}
	```	


#### 2. LoWPAN
1. Low-Power —— Wireless Personal Area Networks无线局域网
2. 功能：
	* 扫描附近的低功耗无线网状网络
	* 加入网络
	* 形成一个低功耗无线网状网络
	* 为保证设备可以交互，它们相互之间的网络参数(network identity/credential)都必须一致 —— `LowpanIndentity, LowpanCredential`
3. 权限—— `ACCESS_LOWPAN_STATE, CHANGE_LOWPAN_STATE`
4. 连接—— `LowpanInterface LowpanManager`
	* 得到LowpanInterface `LowpanManager.getInstance().getInterface();`
	* 释放 `LowpanInterface.leave()`
5. 扫描附近的网络——`LowpanScanner `
	
	```
	mLowpanInterface.createScanner();
    mLowpanScanner.setCallback(mScanCallback);
    mLowpanScanner.startNetScan();
    
    private LowpanScanner.Callback mScanCallback = new LowpanScanner.Callback() {
    @Override
    public void onNetScanBeacon(LowpanBeaconInfo beacon) {
        LowpanIdentity network = beacon.getLowpanIdentity();
        Log.d("LoWPAN", "Network Beacon: " + network.getName());

    }

    @Override
    public void onScanFinished() {
        // Release a semaphore
    }
};
	```
6. 加入已存在的网络——`LowpanProvisioningParams `

	```
	private void joinNetwork(LowpanInterface lowpanInterface) throws LowpanException {

    final LowpanIdentity identity = new LowpanIdentity.Builder()
            .setName("YourNetwork")
            .setXpanid("DEBA7AB1E5EAF00D")
            .setPanid(0x1337)
            .setChannel(15)
            .build();

    final LowpanCredential credential = LowpanCredential
            .createMasterKey("00112233445566778899AABBCCDDEEFF");

    final LowpanProvisioningParams provision = new LowpanProvisioningParams.Builder()
            .setLowpanIdentity(identity)
            .setLowpanCredential(credential)
            .build();

    lowpanInterface.join(provision);
}
	```
7. 创建一个新的网络 —— 需要与存在的网络对比
	
	```
	private void formNetwork(LowpanInterface lowpanInterface) throws LowpanException {

    /* We are only specifying the network name here. By
     * doing this we allow the interface to pick reasonable
     * defaults for other required fields. If we specified
     * our own values for those fields, they would be used
     * instead.
     */
    final LowpanIdentity identity = new LowpanIdentity.Builder()
            .setName("MyNetwork")
            .build();

    /* Not specifying a LowpanCredential here tells “form()”
     * that we want the interface to generate the master key
     * for us.
     */
    final LowpanProvisioningParams provision = new LowpanProvisioningParams.Builder()
            .setLowpanIdentity(identity)
            .build();

    lowpanInterface.form(provision);
}
	```

8. 监听连接状态 —— `LowpanInterface.Callback`

	```
	 LowpanInterface.(un)registerCallback(mCallback);
	 private LowpanInterface.Callback mCallback = new LowpanInterface.Callback() {

        @Override
        public void onStateChanged(int state) {
            /* Handle interface state changes. */
        }

        @Override
        public void onLowpanIdentityChanged(LowpanIdentity identity) {
            /* Form, join, or leave completed successfully. */
        }

        @Override
        public void onProvisionException(Exception exception) {
            /* An error occurred during form or join. */
        }
    };
	```


### 3. 配置设备

### 4. 与外围设备交互


### 5. 用户空间驱动


## 三 Prototype Devices

## 四 Manage Products

## 五 Terms



