---
layout: post
title: Android BLE
category: Android
tags: [Android]
---

#  Android BLE

## 一 使用
1. 声明相关权限。BLUETOOTH BLUETOOTH_ADMIN
添加蓝牙特性配置来限制支持蓝牙功能uses-feature android.hardware.bluetooth_le
在Android5.0以上使用蓝牙时还需定位权限 Access_coarse_location, access_fine_location
user-feature android.hardware.location.gps, Android 6.0以上的设备需要动态申请定位权限，否则蓝牙功能无法使用。
2. 通过在代码中判断设备是否支持蓝牙功能 hasSystemFeature
3.  初始化蓝牙Adapter 
4. 开始扫描设备前确保手机的蓝牙功能开启。 Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE); // 申请打开蓝牙 startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
5.  扫描设备
startLeScan (可以添加参数UUID[]指定扫描设备)，然后添加一个LeScancallback 因为扫描很耗电，所以如果发现设备立即停止，并且设置超时不要去循环扫描。postDelayed stopLeScan
6. 连接到设备，connectGatt(Context, boolean, GattCallback)真正的连接，设置连接回调。
回调函数中包括几个重要的方法
onConnectionStateChange  连接成功后discoverServices
然后收到onServiceDiscovered之后才算是真正连接上设备
还有2个关于onCharactersticWrite 写操作结果的回调。onCharacteristicChanged 特征状态改变的回调，在这个方法中能够获取到蓝牙发送的数据。不过在接收数据之前，我们必须对Characteristic设置监听才能够接收到蓝牙的数据。
7. Characteristic监听设置
bluetoothGatt,getService(SERVICE_UUID) 通过UUID，找到蓝牙中对应的服务
BluetoothGattService.getCharateristic 得到服务中对应的特征。
BluetoothGatt.setCharateristicNotification 启用通知
则该characteristic状态发生改变后就会回调onCharacteristicChanged方法，而开启蓝牙的 notify 功能需要向 UUID 为 CCCD 的 descriptor 中写入值1，其中 CCCD 的值为：
public static final UUID CCCD = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");
8. 向蓝牙发送数据——理解为给蓝牙的Characteristic设置数据
BluetoothGattCharacteristic.setValue(value); 
mBluetoothGatt.writeCharacteristic(characteristic);
我们一般可以写入string 或byte[]数据
9. 数据分包处理
目前低功耗蓝牙一次性只能发送20个字节的数据，因此需要对大的数据进行分包处理。
存储待发送的数据队列Queue<byte[]> 


## 二 原理

### 1. BluetoothManager

### 2. BluetoothAdapter
1. 执行基本的蓝牙任务：发现设备，配对，使用Mac地址初始设备，监听连接请求，开始扫描等任务。
2. 主要的类和操作：
	* BluetoothManager#getDefaultAdapter —— BluetoothAdapter
	* getBondedDevices()，startDiscovery —— BluetoothDevice
	* listenUsingRfcommWithServiceRecord(String,UUID) —— BluetoothServerSocket
	* startLeScan(LeScanCallback callback)

3. 线程安全

#### 2.1 关于设备
1. Discovery： started, finished.
2. LocalName: changed.
3. ScanMode: NONE, CONNECTABLE, CONNECTABLE_DISCOVERABLE
 

#### 2.3 
1. `getDefaultAdapter` 
	
	```
	IBinder b = ServiceManager.getService(BLUETOOTH_MANAGER_SERVICE);
	new BluetoothAdapter(IBluetoothManager.Stub.asInterface(b));
	```
2. 






























