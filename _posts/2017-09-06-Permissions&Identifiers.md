---
layout: post
title: Permissions&Identifiers
category: Training
tags: [Practices——Permissions&Identifiers]
---


[Best Practices for permissions & Identifiers](https://developer.android.com/training/best-permissions-ids.html)


## 1 Permissions and User Data
1. App Permissions and effect users.
2. Permissions protect sensitive information available and is necesseary to access the functions.
3. This doc provides a high-level overview.

### 1.1 Introduction
1. A `manifest` file persents essential information.
2. Request permission.

### 1.2 Permission Groups 
1. **single permission group** 对应于 **serveral permission declaration**
2. 一旦获得组的访问权限，就可以使用该组的API调用，不会再去访问权限。
	* API调用
	* 触发特定权限组访问请求
	* 可以访问组中的所有权限
	* 每项权限可以访问该权限下所有的API
	* [权限组](https://developer.android.com/guide/topics/security/permissions.html#perm-groups)

### 1.3 Permission Requests and App Downloads
1. 请求权限数量越少，下载量越大。
2. 用户可能会认为你的app提出过多权限请求。

### 1.4 Permission Requests Trend Downward
1. 开发者对常用权限的使用逐渐减少。

### 1.5 References



## 2 Best Practices for App Permissions
1. Manage permissions.
2. 无需访问权限即可实现相同的功能。


### 2.1 使用Android权限的原则
1. 仅使用app正常工作所需的权限。
2. 注意库所需的权限。
3. 公开透明。
4. 让系统以显式方式访问。（提示需要相机，麦克风等权限）


### 2.2 Android6.0+中的权限
1. [全新的权限模式](https://developer.android.com/training/permissions/requesting.html) 运行时而不是安装时权限请求。
2. 添加情境背景。描述请求的原因。
3. 在授予权限时更加灵活。确保app不会因用户拒绝权限请求而产生异常。
4. 增加事务负担。用户单独授予权限组的访问权限，而不是以集合的形式授予。

#### 2.2.1 避免请求不必要的权限
1. 使用常见用例的替代方法。免得影响下载量。

#### 2.2.2 通过实时用户请求访问相机/联系人
1. 偶尔访问相机/联系人，基于无需权限的Intent的请求。
2. 使用`MediaStore.ACTION_IMAGE_CAPTHURE`,`MediaStore.ACTION_VIDEO_CAPTURE`的Intent。

#### 2.2.3 丢失音频焦点在后台运行
1. 用户接听电话时，app需转入后台（多媒体需静音或暂停），并在来电停止时重新聚焦。
2. 使用`PhoneStateListener`或`android.intent.action.PHONE_STSTE`的广播来监听来电有无变化。这将强制用户授予敏感数据的权限（设备，SIM硬件ID，来电号码等）。
3. 使用`AudioFocus`可避免，该功能无需显式权限。只需在`onAudioFocusChange()`处理后台音频。[Audio Output](https://developer.android.com/guide/topics/media-apps/volume-and-earphones.html)

#### 2.2.4 确定正在运行实例的设备
1. 需要一个唯一的标识符确定app在哪一个设备上运行。
2. App可能具备设备特定的首选项或消息。有效利用设备标识符，如Device IMEI, 但需要Device ID and call information 权限组(M+中的PHONE)。
3. 可替代这类标识符的方法：
	* 使用`com.google.android.gms.iid` InstanceID API. 通过`getInstance().getID()`得到唯一设备标识符。
	* 使用`randomUUID()`等基本系统函数创建唯一标识符，仅限于app存储空间。

#### 2.2.5 为广告或用户分析创建唯一的标识符
1. 需要唯一标识符为没有登录app的用户构建配置文件。（如，广告定位或测量转化率）
2. 有时需要一个有别的app共享的标识符。如Device IMEI，且用户无法充值。
3. 使用InstanceID API获取的ID作用域并**不适用**。替代方法：`getAdvertisingIdInfo().getId()`获取到**Advertising  Identifer**,不应该从main Thread调用，[具体查看](https://developers.google.com/android/reference/com/google/android/gms/ads/identifier/AdvertisingIdClient).


### 2.3 了解你正在使用的库
1. 第三方库需要的权限。
2. 尽量避免使用`Identity`权限组的库。对于位置功能的库，确保无需请求`FINE_LOCATION`，除非你正在使用基于Location的定位功能。

### 2.4 公开透明
1. 通知用户要访问的内容和原因。
	* 如果仅使用粗略位置，在app说明或者相关帮助文档中通知用户。
	* 访问短信以接收验证码，从而防止用户被骗，在app说明或首次访问数据时通知用户。
2. 使用通知图标通知用户（相机，麦克风等）。


## 3 Best Practices for Unique Identifiers
1. Choose unique Identifiers.
2. 设别安装，可使用实例ID或GUID.


### 3.1 Android 标识符的使用原则
1. 避免使用SSAID(Android ID),IMEI等硬件标识符。
2. 只为用户分析或广告用例使用广告ID。[广告ID](https://play.google.com/intl/zh-CN/about/developer-content-policy/#!?modal_active=none)
3. 为防欺诈支付和电话以外的所用用例使用实例或私密存储GUID。
4. 使用适合的用例API以尽量降低隐私权风险。高价值内容保护[DRM API](https://source.android.com/devices/drm), 滥用预防[SafetyNet API](https://developer.android.com/training/safetynet/index.html).

### 3.2 Android 6.0+的标识符
1. MAC地址全局唯一，用户无法重置。不建议作为用户标识。
2. Android M+ 无法再通过第三方API获得设备MAC地址。（如 WLAN，BT), `WifiInfo.getMacAddress()`和`BluetoothAdapter.getDafaultAdpater().getAddress()`都会返回 02:00:00:00:00:00。且这些方法都需要请求`ACCESS_FINE_LOCATOIN`, `ACCESS_COARSE_LOCATION`权限。

### 3.3 使用广告
1. 广告ID是可由用户重置的标识符。
2. 使用要点：
	* 重置广告ID是尊重用户意图。
	* 始终遵守关联的个性化广告标记。
	* 注意与使用的SDK有关，涉及广告ID使用的任何隐私权或安全性政策。

### 3.4 使用实例ID和GUID
1. 非广告用例中，使用实例ID。只有进行了针对性配置的实例才能访问该标识符，重置起来也很容易，所以最好具有隐私权属性。
2. [什么是实例ID](https://developers.google.com/instance-id/)
3. `UUID.randomUUID().toString()` 获取uniqueID.具有全局性，唯一性。应将其存储在内部空间而非外部（共享）存储设备内。
4. [存储选项](https://developer.android.com/guide/topics/data/data-storage.html).

### 3.4 了解标识符特性
1. Android OS 提供多种具有不同行为特性ID。

#### 3.4.1 作用域
1. Android标识符的作用域分三种：
2. 单一app-ID 仅限app内部访问。
3. 一组app-ID 可供一组预先定义相关app访问。
4. 设备-ID 可供安装在设备上所有app访问。

#### 3.4.2 重置性与持久性
1. 重置触发器包括：应用内重置，通过System Setting重置，启动时重置，安装时重置。
2. Android标识符具有不同的寿命，但寿命通常与ID的重置有关：
3. 仅限会话期间：每次用户重新启动app时使用新的ID。
4. 安装重置：每次卸载重装是使用新的ID。
5. FDR重置：每次恢复出厂设置时使用新的ID。
6. FDR持久化：ID在恢复出厂设置时保持不变。
7. 标识符存在越持久，越可靠，用户被长期跟踪的风险越高。
 
#### 3.4.3 唯一性
1. 标识符具有唯一性（即每个设备/账户组合都具有唯一ID）。
2. 另一方面，标识符在某一群体（一群设备）唯一性越低，隐私保护越好，因为它用于跟踪个别用户的有效性会降低。

#### 3.4.4 完全性保护和不可否认性
1. 难以欺诈或重播的标识符关联设备或账户，这种标识符提供不可否认性。

### 3.5 常见用例和使用标识符
1. 替代使用IMEI或SSAID等硬件ID的方案。

#### 3.5.1 跟踪已注销用户的首选项
1. 在服务端保存设备的状态。
2. 使用实例ID或GUID。
3. 不建议在重新安装后信息依然存在，重装后可重置首选项。

#### 3.5.2 跟踪已注销用户的行为
1. 同一设备上多个app不同会话时创建他们的配置文件。
2. 广告ID。
3. 在广告用例中强制要求使用广告ID，可重置。

#### 3.5.3 生成已注销/匿名用户的分析数据
1. 记录统计信息和数据分析。
2. 实例ID，或GUID。
3. 作用域为app内部，防止他人利用它们跟踪用户在不同app的行为。可清除或卸载app对其重置。

#### 3.5.4 跟踪已注销用户的转化
1. 跟踪转化情况来确认营销策略是否成功。
2. 广告ID。
3. 与广告有关的用例，在不同app中均可使用广告ID。

#### 3.5.5 处理多出安装
1. 同一用户的多个设备上，需要设别正确的app 实例。
2. 实例ID或GUID。
3. 实例ID针对这一用途而设计，作用域app内部。如果实例ID无法满足可使用GUID。

#### 3.5.6 防欺诈：强制执行免费内容限制/检测女巫攻击
1. 限制用户在设备上查看免费内容的数量。
2. 实例ID或GUID。
3. 想要克服内容限制就得卸载重装app。或使用`DRM API`来限制内容的访问。

#### 3.5.7 管理电话和运营商功能
1. app与设备电话和短信互动。
2. IMEI, IMSI, Line1(Android6+运行时)PHONE权限。

#### 3.5.8 滥用检测：发现自动程序和DDoS攻击
1. 发现多态正在攻击后端服务的虚假设备。
2. [Safetynet API](https://developer.android.com/training/safetynet/index.html)
3. 单纯标识符不能有效说明设备的虚伪。`SafetyNet.SafetyNetApi.attest(mGoogleApiClient, nonce)`来验证发起请求的设备的完整性。

#### 3.5.9 滥用检测：检测高价值被盗凭据
1. 发现是否在某一台设备上多次使用了高价值被盗凭据（为了欺诈性支付）。
2. IMEI，IMSI，Line1(Android6+运行时)PHONE权限。
3. 通过盗用凭据，利用设备将多个高价值被盗凭据（如令牌化信用卡）兑现。软件ID可能会被重置规避风险。















