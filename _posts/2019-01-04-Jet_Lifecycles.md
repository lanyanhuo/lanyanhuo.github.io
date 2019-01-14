---
layout: post
title: Jet_Lifecycles
category: Android
tags: [Android]
---

## Jetpack Lifecycles

1. 库 `android.arch.lifecycle`
2. 感知UI组件的执行操作的生命周期的更改。


### 1. LifecycleObserver
1. Lifecycle包含Event和State
2. 使用注解监听生命周期。
3. 如图 ![](https://developer.android.com/images/topic/libraries/architecture/lifecycle-states.png)

```
class MyObserver : LifecycleObserver {
	
	@OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
	fun connectListener() {
	
	}
	
	@OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
	fun disconnectListener() {
	
	}
}
```

### 2. LifecycleOwner
1. 必须实现的一个方法`getLifecycle()`,可查看`ProcessLifecycleOwner`
2. Owner提供生命周期，观察者可以注册观察。
3. 定义一个LocationListener,可以完全识别生命周期

	```
internal class MyLocationListener (private val context: Context, private  val lifecycle: Lifecycle, private val callback: (Location) -> Unit) {
	private var enable = false
	
	@OnLifecycleEvent(Lifecycle.Event.ON_START)
	fun start() {
		if (enable) {
			// connect
		}
	}
	
	fun enable() {
		enable = true
		if (lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)) {
			// connect if not connected
		}
	}
	
	@OnLifecycleEvent(Lifecycle.Event.ON_STOP)
	fun stop() {
		// disconnect if connected
	}
}
	```
4. Owner调用LocationListener

	```
	class MyActivity : AppCompatActivity() {
		private lateinit var myLocationListener: MyLocationListener
		
		override fun onCreate() {
			myLocationListener = MyLocationListener(this, lifecycle) {
				location -> // update UI 
			}
			
			Util.checkUserState { result -> 
				if (result) {
					myLocationListener.enable()
				}
			}
		}
	}
	```
5. 实现LifecycleOwner

	```
	class MyActivity : Activity(), LifecycleOwner {
		private lateinit var lifecycleRegistry: LifecycleRegistry
		
		override fun onCreate(...) {
			...
			lifecycleRegistry = LifecycleRegistry(this)
			lifecycleRegistry.markState(Lifecycle.State.CREATED)
		}
		
		public override fun onStart() {
			lifecycleRegistry.markState(Lifecycle.State.STARTED)
		}
		
		public override fun getLifecycle(): Lifecycle {
			return lifecycleRegistry
		}
	
	}
	```

### 3. Lifecycle使用
1. 保持UI控制器（活动和片段）尽可能精简。不要自己去获取处理数据，使用`ViewModel结合LiveData`去实现。
2. 编写数据驱动的UI，UI控制器负责在数据更改时UI，或者将用户操作通知给`ViewModel`。
3. 数据逻辑放在`ViewModel`。 ViewModel应该作为`UI控制器和应用程序其余部分之间`的连接器。
4. 使用DataBinding来维护UI和UI控制器之间的联系。可使用Butter Knife之类的库。
5. 如果UI很复杂,考虑创建一个`presenter类`来处理UI修改。使UI组件更容易测试。
6. 避免引用Activity的context，防止内存泄露ViewModel。


### 4. 各种case
生命周期感知组件可以使您在各种情况下更轻松地管理生命周期。一些例子是：

1. 在粗粒度和细粒度位置更新之间切换。使用Lifecycle可在您的位置应用程序可见时启用细粒度位置更新，并在应用程序位于后台时切换到粗粒度更新。LiveData，一个生命周期感知组件，允许您的应用在用户更改位置时自动更新UI。
2. 停止并开始视频缓冲。使用生命周期感知组件尽快启动视频缓冲，但推迟播放直到应用程序完全启动。您还可以使用生命周期感知组件在销毁应用程序时终止缓冲。
3. 启动和停止网络连接。使用生命周期感知组件在应用程序处于前台时启用网络数据的实时更新（流式传输），并在应用程序进入后台时自动暂停。
4. 暂停和恢复动画drawables。当应用程序在后台时，使用生命周期感知组件处理暂停动画可绘制的内容，并在应用程序位于前台后恢复可绘制内容。

### 5. 处理stop事件
1. Lifecycle的State在`CREATE和ON_STOP`变化时，UI组件的onSaveInstanceState()被调用。
2. Lifecycle的onStop的调用。












