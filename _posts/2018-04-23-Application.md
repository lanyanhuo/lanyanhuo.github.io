---
layout: post
title: Application
category: Audition
tags: [Audition]
---

## <font color=#0099ff size=6> Application </font>

### 1. 点击app icon之后
1. 点击app icon, 启动应用的`LauncherActivity`.
2. 如果`LancerActivity`所在的<font color=#99ffaa size=3> **进程**  </font> 没有创建，则创建新进程。
3. 整体的流程就是一个Activity的启动流程。

#### 1.1 涉及到类
1. `Instrumentation`: 监控应用与系统相关的交互行为。
2. `AMS`：组件管理调度中心，什么都不干，但是什么都管。
3. `ActivityStarter`：Activity启动的控制器，处理Intent与Flag对Activity启动的影响，具体说来有：
	* 寻找符合启动条件的Activity，如果有多个，让用户选择；
	* 校验启动参数的合法性；3 返回int参数，代表Activity是否启动成功。
4. `ActivityStackSupervisior`：这个类的作用你从它的名字就可以看出来，它用来管理任务栈。
5. `ActivityStack`：用来管理任务栈里的Activity。
6. `ActivityThread`：最终干活的人，是ActivityThread的内部类，Activity、Service、BroadcastReceiver的启动、切换、调度等各种操作都在这个类里完成。

#### 1.2 整个流程主要涉及四个进程
1. <font color=#aa99ff size=3> **调用者进程**  </font>，如果是在桌面启动应用就是Launcher应用进程。
2. ActivityManagerService等所在的<font color=#aa99ff size=3> **System Server进程**  </font>，该进程主要运行着系统服务组件。
3. <font color=#aa99ff size=3> **Zygote进程**  </font>，该进程主要用来fork新进程。
4. 新启动的<font color=#aa99ff size=3> **应用进程**  </font>，该进程就是用来承载应用运行的进程了，它也是应用的主线程（新创建的进程就是主线程），处理组件生命周期、界面绘制等相关事情。

#### 1.3 总结
1. 点击桌面App icon，Launcher进程将启动Activity（MainActivity）的请求以Binder的方式发送给了AMS。
2. AMS接收到启动请求后，交付ActivityStarter处理Intent和Flag等信息，然后再交ActivityStackSupervisior/ActivityStack处理Activity进栈相关流程。同时以Socket方式请求Zygote进程fork新进程。
3. Zygote接收到新进程创建请求后fork出新进程。
4. 在新进程里创建ActivityThread对象，新创建的进程就是应用的主线程，在主线程里开启Looper消息循环，开始处理创建Activity。
5. ActivityThread利用ClassLoader去加载Activity、创建Activity实例，并回调Activity的onCreate()方法，加载布局，绘制视图。这样便完成了Activity的启动。


### 2. 四大组件的创建
1. Activity：通过LoadedApk的makeApplication()方法创建。
2. Service：通过LoadedApk的makeApplication()方法创建。
3. BroadcastReceiver：通过其回调方法onReceive()方法的第一个参数指向Application。
4. ContentProvider：无法获取Application，因此此时Application不一定已经初始化。


### 3. 进程和 Application 的生命周期

```
onCreate -> onTerminate -> onLowMemory -> onTrimMemory ->
onConfigurationChanged
```


## <font color=#0099ff size=6> 一 Activity </font>
1. SubClass: 

```
FragmentActivity， TabActivity， ListActivity（LauncherActivity, PreferenceActivity), 
AlasActivity,  ExpandableActivity, PreferenceActivity
```

### 1. 生命周期

#### 1.1 主要
1. `onCreate(Bundle savedInstanceState)`：创建activity时调用。设置在该方法中，还以Bundle的形式提供对以前储存的任何状态的访问！
2. `onStart()`：activity变为在屏幕上对用户可见时调用。(onRestart()之后也会调用）
3. `onResume()`：activity开始与用户交互时调用（无论是启动还是重新启动一个活动，该方法总是被调用的）。
4. `onPause()`：activity被暂停或收回cpu和其他资源时调用，该方法用于保存活动状态的。
5. `nStop()`：activity被停止并转为不可见阶段及后续的生命周期事件时调用。(是否调用取决于新的activity有无透明部分)
6. onRestart()：重新启动activity时调用。该活动仍在栈中，而不是启动新的活动。 
7. OnDestroy()：activity被完全从系统内存中移除时调用，该方法被 2.横竖屏切换时候activity的生命周期
8. 对话框弹出不会执行任何生命周期


#### 1.2 横竖屏切换时
1. 不设置Activity的android:configChanges时，切屏会重新调用各个生命周期，切横屏时会执行一次，切竖屏时会执行两次
2. 设置Activity的android:configChanges="orientation"时，切屏还是会重新调用各个生命周期，切横、竖屏时只会执行一次
3. 设置Activity的android:configChanges="orientation|keyboardHidden"时，切屏不会重新调用各个生命周期，只会执行onConfigurationChanged方法   orientation|screenSize

#### 1.3 按下Home, 或被其他Activity覆盖
1. onPause -> onStop
2. 重新回到应用 onRestart -> onStart -> onResume

#### 1.4 A，B之间跳转
1. A->B: 
	* B为透明时，A只执行onPause
	* A onPause(不要做耗时操作); B onCreate -> onStart -> onResume; A onStop
2. B->A: B onPause; A onRestart -> onStart -> onResume; B onStop -> onDestroy
3. 使用Intent跳转
	```
		Intent intent = new Intent();    // 建立Intent 
		intent.setClass(Forwarding.this, ForwardTarget.class);  // 设置活动
		startActivity(intent);
	```
4. 带有返回值的跳转
	```
		static final private int GET_CODE = 0; 
		startActivityForResult (intent, GET_CODE);
		@Override 
		 protected void onActivityResult(int requestCode, int resultCode, 
		  Intent data) { 
			if (requestCode == GET_CODE) {  
				if (resultCode == RESULT_OK) { ... }
			}
		}// A 
		 
		//在B中
		public void onClick(View v) { 
			setResult(RESULT_OK, (new Intent()).setAction("Corky!")); 
			finish(); 
		}
	```

### 2. 启动方式以及应用场景，Activity栈
1. standard Mode
	* App的Activity栈有`A B `
	* ***App想加载B，则不管栈内有无该实例，都会直接创建实例，压入栈顶***
	* App的Activity栈有`B A B `
2. SingleInstance Mode 
	* App1的Activity栈有`A B `
	* App2的Activity栈有`C`
	* ***App1想加载C，则直接激活App2的C***
	* App1的Activity栈有`C A B`,App2不变。
3. SingleTask Mode
	* App的Activity栈有`A B C`
	* ***App想加载B，则如有该实例，直接将上面的任务终止并移除，重用B，调用onNewIntent***
	* App的Activity栈有`B C`
4. SingleTop Mode
	* App的Activity栈有`A B`
	* ***App想加载B，则如有该实例，直接移到栈顶，重用B,调用onNewIntent***
	* App的Activity栈有`B A`
5. Intent中的Flag
	* FLAG_ACTIVITY_NO_HISTORY, 一旦退出不再存在于栈中。
	* FLAG_ACTIVITY_SINGLE_TOP, SingleTop
	* FLAG_ACTIVITY_NEW_TASK, standard
	* FLAG_ACTIVITY_MULTIPLE_TASK, 
	* FLAG_ACTIVITY_CLEAR_TOP, SingleTask
	* FLAG_ACTIVITY_BROUGHT_TO_FRONT, —— 栈中有A，在A中以这种模式启动B，B在正常启动C,D，此时栈的情况就是A,C,D,B。

### 3. 状态保存与恢复
1. onCreate参数savedInstanceState == null，从而恢复数据
2. savedInstanceState是一个Bundle对象。

#### 3.1 onSaveInstanceState
	• Activity被覆盖或进入后台，由于系统资源不足被kill会被调用
	• 用户改变屏幕方向会被调用
	• 跳转到其它Activity或按Home进入后台会被调用
	• 会在onPause之前被调用

#### 3.2 onRestoreInstanceState
    • 用于恢复保存的临时数据，此方法的Bundle参数也会传递到onCreate方法中，你也可以在onCreate(Bundle savedInstanceState)方法中恢复数据
    • 由于系统资源不足被kill之后又回到此Activity会被调用
    • 用户改变屏幕方向重建Activity时会被调用
    • 会在onStart之后被调用

#### 3.3 onWindowFocusChanged方法
1. 窗口焦点改变时被调用
2. 在onResume之后获得焦点，onPause之后失去焦点


### 4. 其他情况
1. Activity作为对话框
	* 设置为Dialog，android:theme="@style/Theme.Dialog".
	* Activity设置成半透明的对话框，设置如下主题即可：android:theme=”@android:style/Theme.Translucent” 
2. AlertDialog,popupWindow,Activity区别

3. Application 和 Activity 的 Context 对象的区别

### 5. 关闭
1. 退出Activity直接finish即可。
2. 抛异常强制退出,该方法通过抛异常，使程序Force Close。验证可以，但是，需要解决的问题是，如何使程序结束掉，而不弹出Force Close的窗口。
3. 记录打开的Activity：每打开一个Activity，就记录下来。在需要退出时，关闭每一个Activity即可。
4. 发送特定广播：在需要结束应用时，发送一个特定的广播，每个Activity收到广播后，关闭即可。
5. 递归退出：在打开新的Activity时使用startActivityForResult，然后自己加标志，在onActivityResult中处理，递归关闭。最好定义一个Activity基类。

### 6. 当后台的activity被系统回收怎么办
1. 如果程序需要在Activity被回收之前能记录下该Activity运行时的状态信息，则可以从Activity的生命周期着手考虑：
	
* 因为系统在内存紧张时只可能回收处于暂停、停止状态的Activity。当Activity进入暂停状态之前，一定要先回调onPause方法，进行停止状态之前，一定会先回调onPause、onStop方法，因此程序可以通过重写onPause方法，把Activity的运行状态记录到存储设备上，然后重写onResume()方法，并在该方法中判断之前是否存储过Activity的运行状态，如果有记录之前的运行状态，在onResume()方法中恢复该程序的运行状态即可。
	
2. 系统会帮我们记录下回收前activity的状态，再次调用被回收的activity就要重新调用
onCreate()方法，不同直接启动的是这次onCreate()里是带参数的savedInstanceSate；一般可以判断其是否为null，不为null时可以使用它来恢复到回收前的状态。

	```
	public void onSaveInstanceState(Bundle outState) { 
		super.onSaveInstanceState(outState); 
		outState.putLong("id", 1234567890); 
	} 
	public void onSaveInstanceState(Bundle outState) { 
		super.onSaveInstanceState(outState); 
		outState.putLong("id", 1234567890); 
	} 
	```
	
3. B 完成以后又会来找A, 这个时候就有两种情况，一种是A被回收，一种是没有被回收，被回收的A就要重新调用onCreate()方法，不同于直接启动的是这回onCreate()里是带上参数 savedInstanceState，没被收回的就还是onResume就好了。 
	* savedInstanceState是一个Bundle对象，你基本上可以把他理解为系统帮你维护的一个Map对象。在onCreate()里你可能会用到它，如果正常启动onCreate就不会有它，所以用的时候要判断一下是否为空。 
	
	```	
		if(savedInstanceState != null) { 
			long id = savedInstanceState.getLong("id"); 
		} 
	
	　　if(savedInstanceState != null) {
	　　	long id = savedInstanceState.getLong("id"); 
	　　} 
	```


## <font color=#0099ff size=6> 二 Fragment </font>

### 1. 生命周期
1. 打开onAttach-> onCreate-> onCreateView->onActivityCreated->onStart->onResume 
2. 退出onPause->onStop->onDestroyView->onDestroy->onDetach
3. onAttach(Activity):当Fragment和Activity发生关联时使用
4. onCreateView(LayoutInflater, ViewGroup, Bundle):创建该Fragment的视图
5. onActivityCreate(Bundle):当Activity的onCreate方法返回时调用
6. onDestoryView():与onCreateView相对应，当该Fragment的视图被移除时调用
7. onDetach():与onAttach相对应，当Fragment与Activity关联被取消时调用   
8. 注意: 除了onCreateView，其他的所有方法如果你重写了，必须调用父类对于该方法的实现
9. onAttach->onCreate->onCreateView->onActivityCreated->onStart->onResume->onPause->onStop->onDestroyView->onDestroy->onDetach

#### 1.1 其他情况
1. 屏幕灭掉,回到桌面 onPause-> onSaveInstanceState->onStop
2. 屏幕解锁 onStart-> onResume
3. 切换到其他Fragment `onPause->onStop->onDestroyView`
4. 切换回本身的Fragment `onCreateView-> onActivityCreated->onStart-> onResume`

### 2. Fragment滑动，传递数据的方式
1. android.app.Fragment 主要用于定义Fragment
2. android.app.FragmentManager 主要用于在Activity中操作Fragment
3. android.app.FragmentTransaction 保证一些列Fragment操作的原子性，熟悉事务这个词
4. 主要的操作都是FragmentTransaction的方法
```
	getFragmentManager().beginTranscation()
		.addToBackStatck()
		.replace(R.id.container, new MyFragment())
		.commit();
		
	getFragmentManager().popBackStatck();
```

### 5. 如何在Adapter使用中解耦

Activity状态保存于恢复

fragment各种情况下的生命周期

Fragment状态保存startActivityForResult是哪个类的方法，在什么情况下使用？


fragment之间传递数据的方式？


如果在onStop的时候做了网络请求，onResume的时候怎么恢复？
ViewPager使用细节，如何设置成每次只初始化当前的Fragment，其他的不初始化呢？


### 6. Fragment问题
1. Activity与Fragment之间生命周期比较

2. Fragment 在 ViewPager 里面的生命周期，滑动 ViewPager 的页面时 Fragment 的生命周期的变化；
3. 为什么 Google 会推出Fragment ，有什么好处和用途？ 直接用 View 代替不行么？

#### 6.1 ViewPager
1. 如何设置成每次只初始化当前的Fragment，其他的不初始化？


## <font color=#0099ff size=6> 三 Service </font>

### 1. 开启方式, 生命周期
1. 只是用startService()启动服务：`onCreate() -> onStartCommand() -> onDestory()`
2. 只是用bindService()绑定服务：`onCreate() -> onBind() -> onServiceConnected() ->  onUnBind() -> onDestory()`
3. 同时使用startService()启动服务与bindService()绑定服务：`onCreate() -> onStartCommnad() -> onBind() -> onUnBind() -> onDestory()`
4. 两者区别：
	* startService开启服务以后，与Activity就没有关联，不受影响，独立运行。
	* bindService开启服务以后，与Activity存在关联，Activity需要实现ServiceConnected, 并且退出Activity时必须调用unbindService方法，否则会报ServiceConnection泄漏的错误。
5. 无论调用多少次startService()或bindService()方法，onCreate() 该方法在服务被创建时调用，该方法只会被调用一次。onDestroy()该方法在服务被终止时调用，也只被调用一次。
6. 有一个问题:如果startService(),并且bindService()后，如果stopService(),此时Service是否还活着(否)？是否还需要调用unbindService()（否）?

### 3. IPC（Inter-Process-Communication）
1. <font color=#3456ff size=3> 跨进程访问 </font>别的应用程序。
	* `BroadcastReceiver`属于单向通信，也可以跨进程。
	* `ContentProvider`可以将URI接口暴露数据给其他应用访问。
	* `Messenger`单线程跨进程通信。
	* `AIDL`多线程，多客户端并发访问。
2. 谈谈Android的IPC机制
	1. IPC是内部进程通信的简称，是共享”命名管道”的资源。
	2. Android中的IPC工作原理是<font color=#3456ff size=3> 为了让Activity和Service之间可以随时的进行交互 </font>，故在Android中该机制，只适用于Activity和Service之间的通信，类似于远程方法调用，类似于C/S模式的访问。
		* 通过定义AIDL接口文件来定义IPC接口。Servier端实现IPC接口，Client端调用IPC接口本地代理。
		* 有了Intent这种基于消息的进程内或进程间通信模型，我们就可以通过Intent去开启一个Service，可以通过Intent跳转到另一个Activity，不论上面的Service或Activity是在当前进程还是其它进程内即不论是当前应用还是其它应用的Service或Activity，通过消息机制都可以进行通信！
		* 但是通过消息机制实现的进程间通信，有一个弊端就是，如果我们的Activity与Service之间的交往不是简单的Activity开启Service操作，而是要随时发一些控制请求，那么必须就要保证Activity在Service的运行过程中随时可以连接到Service。

3. 音乐播放程序
	* 后台的播放服务往往独立运行，以方便在使用其他程序界面时也能听到音乐。同时这个后台播放服务也会定义一个控制接口，比如播放，暂停，快进等方法，任何时候播放程序的界面都可以连接到播放服务，然后通过这组控制接口方法对其控制。
	* 如上的需求仅仅通过Intent去**开启Service就无法满足了**！从而Android的显得稍微笨重的IPC机制就出现了，然而它的出现只适用于Activity与Service之间的通信，类似于远程方法调用，就像是C/S模式的访问，通过定义AIDL接口文件来定义一个IPC接口，Server端实现IPC接口，Client端调用IPC接口的本地代理。
	* 由于IPC调用是同步的，如果一个IPC服务需要超过几毫秒的时间才能完成的话，你应该避免在Activity的主线程中调用，否则IPC调用会挂起应用程序导致界面失去响应。在这种情况下，应该考虑 <font color=#3456ff size=3> 单起一个线程来处理IPC访问 </font>。两个进程间IPC看起来就象是一个进程进入另一个进程执行代码然后带着执行的结果返回。
	* IPC机制鼓励我们“尽量利用已有功能，利用IPC和包含已有功能的程序协作完成一个完整的项目。
    
#### 3.1 AIDL

1. 解决以下几个问题:
	* 什么是AIDL？
	* AIDL解决了什么问题？<font color=#3456ff size=3>多线程，多客户端并发访问</font>
	* AIDL如何使用？
		* AIDL,两个android应用间的互相调用方法？
    	* AIDL的全称是什么？如何工作？
		* 能处理哪些类型的数据
  
2. 用法
	* 创建一个aidl文件，添加`IRemoteService.aidl`，以及需要实现的接口`getId(), getType()`。
	* 保存后编译器会在gen目录下自动生成`IRemoteService.java`文件
	* 定义`AIDLService.java`
	* `AndroidManifest.xml中注册，并添加“xx.xx.xx.aidl” 的ACTION`
	* 		
		```
		public class AIDLService extends Service {
		   
		    @Override
		    public IBinder onBind(Intent arg0) {
		        return remoteBinder;
		    }
		 
		    private final IRemoteService.Stub remoteBinder = new IRemoteService.Stub() {
		        public int getId(){
		            return "10012";
		        }
		        public int getType() {
		         	  return Type.None;
		         }	
		    };
		 
		}
		```
	* Client实现。
	
		```
		ServiceConnection conn = new ServiceConnection() {
	        @Override
	        public void onServiceDisconnected(ComponentName name) {
	        }
	         
	        @Override
	        public void onServiceConnected(ComponentName name, IBinder service) {
	            remoteService = IRemoteService.Stub.asInterface(service);
	            try {
	                int id = remoteService.getId();
	                int type = remoteService.getType();
	            } catch (RemoteException e) {
	                e.printStackTrace();
	            }
	         }
	    	};
	       
	      public void onStart() {
	        bindService(new Intent("xx.xx.xx.aidl", conn, Context.BIND_AUTO_CREATE);
	      }
	       
	      public void onStop() {
	         unbindService(conn);
	      }
       
		```


#### 3.2 Messenger
1. 比AIDL实现方式简单,单线程处理。
2. 使用Messenger
	* 所有从Activity传过来的消息都会排在一个队列中，不会同时请求Service，所以是线程安全的。
	* 多线程访问Service，就可以用AIDL，不然还是用Messenger。

```
//start
private Messenger messenger;/**向Service发送Message的Messenger对象*/
    private void callMessengerService() throws RemoteException {
        MessengerService service = new MessengerService();
        Message msg = Message.obtain(null, MessengerService.MSG_1, 0, 0);
        if (messenger != null) {
            messenger.send(msg);
        }
    }
    
    public void onStart(Context context) {
        context.bindService(new Intent(context, MessengerService.class),connection, Context.BIND_AUTO_CREATE);
    }
    
    public void onStop(Context context) {
        context.unbindService(connection);
    }

    private ServiceConnection connection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            messenger = new Messenger(service);
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            messenger = null;
        }
    };
//end
    
    class MessengerService extends Service {

        public final static int MSG_1 = 1;
        private final Messenger messenger = new Messenger(new MsgHandler());

        @Nullable
        @Override
        public IBinder onBind(Intent intent) {
            return messenger.getBinder();
        }

        class MsgHandler extends Handler {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                switch (msg.what) {
                    case MSG_1:
                        Toast
                        break;
                }
            }
        }
    }
```

### 4. IntentService
1. 在不与用户直接交互的情况下，完成应用程序指定的耗时的操作。
2. 提供了一定的功能和接口供其他应用程序调用，满足<font color=#aa11 size=3>应用和应用之间的交互</font>。
3. 创建子线程处理耗时操作，不需要自己去new Thread。
4. 处理数据之后自己stop。


#### 4.1 原理
1. IntentService继承Service，专门处理异步请求。
2. 客户端通过调用startService(Intent)发起请求，数据是通过Intent进行传递的。
3. 一旦Service启动后，对于Intent所传递的数据操作都通过工作线程（worker thread）进行处理。
4. getLooper，然后实例化ServiceHandler。在onStartCommand中实现消息的分发
4. 在完成数据的处理之后，ServiceHandler会回调其处理结果。在任务结束后会将自身服务关闭。`handleMessage时 stopself`

#### 4.2 用法
1. startIntentService，或者bindService都可以.

### 5 JobService
1. Android 5.0中引入JobScheduler来执行一些需要满足特定条件但不紧急的后台任务，APP利用JobScheduler来执行这些特殊的后台任务时来减少电量的消耗。
2. 通过JobScheduler调度。
3. `JobScheduler` 5个约束条件：
	* 最小延时 
	* 最晚执行时间
	* 需要充电
	* 需要设备为idle（空闲）状态（一般很难达到这个条件吧）
	* 联网状态（NETWORK_TYPE_NONE--不需要网络，NETWORK_TYPE_ANY--任何可用网络，NETWORK_TYPE_UNMETERED--不按用量计费的网络）
4. JobService中的后台任务是在主线程中执行，这里一定不能执行耗时的任务。虽然在JobService中使用了Binder，但是最后还是通过Handler将任务调度到主线程中来执行。


#### 5.1 原理
1. JobService重写了onBind. 使用AIDL的方式。
	
	```
	//start/stopJob 分别发送了MSG_EXECUTE_JOB和MSG_STOP_JOB两个Message
	IJobService mBinder = new IJobService.Stub() {
        @Override
        public void startJob(JobParameters jobParams) {
            ensureHandler();
            Message m = Message.obtain(mHandler, MSG_EXECUTE_JOB, jobParams);
            m.sendToTarget();
        }
        @Override
        public void stopJob(JobParameters jobParams) {
            ensureHandler();
            Message m = Message.obtain(mHandler, MSG_STOP_JOB, jobParams);
            m.sendToTarget();
        }
    };

    /** @hide */
    void ensureHandler() {
        synchronized (mHandlerLock) {
            if (mHandler == null) {
                mHandler = new JobHandler(getMainLooper());
            }
        }
    }  
	```
2. 处理`execute/stop/finish`等消息。

	```
	class JobHandler extends Handler {
    @Override
    public void handleMessage(Message msg) {
        final JobParameters params = (JobParameters) msg.obj;
        switch (msg.what) {
            case MSG_EXECUTE_JOB:
                try {
                    boolean workOngoing = JobService.this.onStartJob(params);
                    ackStartMessage(params, workOngoing);
                } catch (Exception e) {
                    ...
                }
                break;
            case MSG_STOP_JOB:
                try {
                    boolean ret = JobService.this.onStopJob(params);
                    ackStopMessage(params, ret);
                } catch (Exception e) {
                    ...
                }
                break;
            case MSG_JOB_FINISHED:
                final boolean needsReschedule = (msg.arg2 == 1);
                IJobCallback callback = params.getCallback();
                if (callback != null) {
                    try {
                        callback.jobFinished(params.getJobId(), needsReschedule);
                    } catch (RemoteException e) {
                       ...
                    }
                }
                break;
            default:
                Log.e(TAG, "Unrecognised message received.");
                break;
        }
    }  
}  
	```


### 6. 进程保活，避免被杀掉
1. Service设置成START_STICKY，kill 后会被重启（等待5秒左右），重传Intent，保持与重启前一样
2. 通过`startForeground`将进程设置为前台进程，做前台服务，优先级和前台应用一个级别​，除非在系统内存非常缺，否则此进程不会被 kill
3. 双进程Service：让2个进程互相保护，其中一个Service被清理后，另外没被清理的进程可以立即重启进程
4. 在已经root的设备下，修改相应的权限文件，将App伪装成系统级的应用（Android4.0系列的一个漏洞，已经确认可行）
5. Android系统中当前进程(Process)fork出来的子进程，被系统认为是两个不同的进程。当父进程被杀死的时候，子进程仍然可以存活，并不受影响。鉴于目前提到的在Android-Service层做双守护都会失败，我们可以fork出c进程，多进程守护。死循环在那检查是否还存在，具体的思路如下（Android5.0以下可行）
    1. 用C编写守护进程(即子进程)，守护进程做的事情就是循环检查目标进程是否存在，不存在则启动它。
    2. 在NDK环境中将1中编写的C代码编译打包成可执行文件(BUILD_EXECUTABLE)。
    3. 主进程启动时将守护进程放入私有目录下，赋予可执行权限，启动它即可。
6. 加入到设备的白名单，原理是什么？


## <font color=#0099ff size=6> 四 BroadcastReceiver </font>
### 1. 注册
1. 静态注册：常驻系统，不受组件生命周期影响，即便应用退出，广播还是可以被接收，耗电、占内存。
2. 动态注册：非常驻，跟随组件的生命变化，组件结束，广播结束。在组件结束前，需要先移除广播，否则容易造成内存泄漏。
3. 生命周期只有10秒左右.

### 2. 分类
1. `BroadcastReceiver` 是跨应用广播，利用Binder机制实现。
2. `LocalBroadcastReceiver` 
	* 本地广播是应用内广播，不被其他应用的广播干扰，也不会给其他应用发送广播。
	* Handler实现，利用了IntentFilter的match功能，提供消息的发布与接收功能，实现应用内通信，效率比较高。
	* 不能静态注册，只能采用动态注册方式。
	* 
3. `普通广播`：调用`sendBroadcast(Intent)`发送，最常用的广播。
4. `有序广播`：
	* 调用`sendOrderedBroadcast(Intent, receiverPermission)`
	* 发出去的广播会被广播接受者按照顺序接收，广播接收者按照Priority属性值从大-小排序，Priority属性相同者，动态注册的广播优先，广播接收者还可以选择对广播进行截断和修改。
	* 高级别的或同级别先接收到广播的可以通过abortBroadcast()方法截断广播使其他的接收者无法收到该广播.
	* android:priority = "2147483647"最高优先级
	```
		<receiver android:name=".SMSBroadcastReceiver" >
		　　<intent-filter android:priority = "2147483647" >
		　　　　<action android:name="android.provider.Telephony.SMS_RECEIVED" />
		　　</intent-filter>
		</receiver >
	```
5. `异步广播`：
	* 普通 调用`sendStickyBroadcast(Intent)`
	* 有序 调用`sendStickyOrderedBroadcast(intent, resultReceiver, scheduler,  initialCode, initialData, initialExtras)`
	* 在AndroidManifest中需要添加`BROADCAST_STICKY`权限。
	* 需要`removeStickyBroadcast(intent)`主动把它去掉.


### 3. 发送与接收原理
1. 继承BroadcastReceiver，重写onReceive()方法。
2. 通过Binder机制向ActivityManagerService注册广播。
3. 通过Binder机制向ActivityMangerService发送广播。
4. ActivityManagerService查找符合相应条件的广播（IntentFilter/Permission）的BroadcastReceiver，将广播发送到BroadcastReceiver所在的消息队列中。
5. BroadcastReceiver所在<font color=#398 >消息队列</font>拿到此广播后，回调它的onReceive()方法。


### 4. 其他
1. 场景：
	* 电话呼入事件、数据网络可用通知或者到了晚上时进行通知。
	* 闪背光灯，震动，播放声音。
2. 如何通过Broadcast拦截abort一条短信
3. 广播是否可以请求网络？


## <font color=#0099ff size=6> 五 ContentProvider </font>

### 1. ContentProvider,ContentResolver, ContentObserver
1. 	`ContentProvider`
	* 管理数据，提供数据的增删改查。
	* 数据源可以是db,file,xml,url等。
	* 为这些数据访问提供了统一的接口，进程间数据共享。
2. `ContentResolver`
	* 使用不同url操作不同ContentProvider中的数据。
	* 外部进程通过ContentResolver与ContentProvider进行交互。
3. `ContentObserver`：观察ContentProvider数据变化，通知外界。

### 2.  ContentProvider 权限管理
1. 读写分离，
2. 权限控制-精确到表级
3. URL控制

### 3. 系统为什么会设计ContentProvider
1. 意义：应用间数据共享的一种方式。比如通讯录、短信。
2. 封装：对数据进行封装，提供统一的接口，使用者不必关心数据源
3. 应用程序能够将它们的数据保存到文件或SQLite数据库中，甚至是任何有效的设备中。当需要将数据与其他的应用共享时，内容提供者将会很有用。一个内容提供者类实现了一组标准的方法，从而能够让其他应用程序保存或读取此内容提供者处理的各种数据类型。

### 4. 使用
```
  <provider android:name=".PersonProvider" android:authorities="com.bravestarr.provider.personprovider"/>  
  
  public boolean onCreate();//处理初始化操作

       /** 插入数据到内容提供者(允许其他应用向你的应用中插入数据时重写)
        * @param uri
        * @param initialValues 插入的数据
        * @return
        */
       public Uri insert(Uri uri, ContentValues initialValues);

       /** 从内容提供者中删除数据(允许其他应用删除你应用的数据时重写)
        * @param uri
        * @param selection 条件语句
        * @param selectionArgs 参数
        * @return
        */
       public int delete(Uri uri, String selection, String[] selectionArgs);

       /** 更新内容提供者已存在的数据(允许其他应用更新你应用的数据时重写)
        * @param uri
        * @param values 更新的数据
        * @param selection 条件语句
        * @param selectionArgs 参数
        * @return
        */
       public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs);
       /** 返回数据给调用者(允许其他应用从你的应用中获取数据时重写)
        * @param uri
        * @param projection 列名
        * @param selection 条件语句
        * @param selectionArgs 参数
        * @param sortOrder 排序
        * @return
        */
       public Cursor query(Uri uri, String[] projection, String selection,  String[] selectionArgs, String sortOrder) ;         
       /** 用于返回当前Uri所代表数据的MIME类型
        * 如果操作的数据为集合类型(多条数据),那么返回的类型字符串应该为vnd.android.cursor.dir/开头
        * 例如要得到所有person记录的Uri为content://com.bravestarr.provider.personprovider/person, 　　　　 * 那么返回的MIME类型字符串应该为"vnd.android.cursor.dir/person"
        * 如果操作的数据为单一数据,那么返回的类型字符串应该为vnd.android.cursor.item/开头
        * 例如要得到id为10的person记录的Uri为content://com.bravestarr.provider.personprovider/person/10, 　　　　 *　　　那么返回的MIME类型字符串应该为"vnd.android.cursor.item/person"
        * @param uri
        */
       public String getType(Uri uri)

```

### 5. 结构
1. Browser
2. CallLog
3. Contacts
	* Groups
	* People
	* Phones
	* Photos
4. Images
	* Thumbnails
5. MediaStore
	* Albums
	* Artists
	* Audio
	* Genres
	* Playlists
6. Settings
7. Video

### 6. ContentValues类是做什么的？
1. ContentValues类似于map，也是负责存储key(String)-value(基本类型)。
2. 当程序通过SQLiteDatabase插入、修改数据时经常要用到ContentValues，此时ContentValues中的key代表要列名col_name，而value则代表col_value。

### 7. 实例用法
1. 创建一个属于你自己的Content provider或者将你的数据添加到一个已经存在的Content provider中，前提是有相同数据类型并且有写入Content provider的权限。



## <font color=#0099ff size=6> 六 Intent </font>
1. 实现界面间的切换，可以包含动作和动作数据，连接四大组件的纽带

#### Android里的Intent传递的数据有大小限制吗，如何解决？
1. Intent传递数据大小的限制大概在1M左右，超过这个限制就会静默崩溃。处理方式如下：
2. 进程内：EventBus，文件缓存、磁盘缓存。
3. 进程间：通过ContentProvider进行款进程数据共享和传递。

### 1. IntentFilter 
1. 如果一个Activity要显示一个人的联系方式，则需要声明一个IntentFilter(它知道如何处理VIEW Action和联系方式的URI)。
2. 需要在AndroidManifest中定义。
3. startActivity之后，系统会在应用程序的IntentFilter中查找start的这个。
4. 使用
```
	<intent-filter>
	   <action android:name="android.intent.action.MAIN" />
	   <category android:name="android.intent.category.LAUNCHER" />
	</intent-filter>
```

#### intent-filter属性及其含义

### 2. MAIN, VIEW, PICK, EDIT

### 3. Intent组成
1. 包括Component、 Action、Category、Data、Type、Extra、Flag这些数据，其中Component、 Action、Category、Data、Type主要用于匹配该Intent想要启动的程序组件，Extra属性是一个Bundle对象，该对象的主要用于携带多个组件交互的数据。Flag则用于指定一些启动程序的“旗标”信息，
2. 比如启动Activity时可指定如下常用Flag：
	* `FLAG_ACTIVITY_NEW_TASK`：使用一个新的Task来装载该Activity。
	* `FLAG_ACTIVITY_NO_HISTORY`：通过该Flag启动的Activity不会保存在历史Stack中。
	* `FLAG_ACTIVITY_SINGLE_TOP`：如果当前Task中已有该Activity，通过该Flag启动的Activity将不会被启动（因为要保持只有一个实例）。

### 4. URL和URI区别用法


## <font color=#0099ff size=6> 七 Binder </font>
1. Android Binder是用来做进程通信的，Android的各个应用以及系统服务都运行在独立的进程中，它们的通信都依赖于Binder。

### 1. 为什么要使用Binder
1. 为什么选用Binder，在讨论这个问题之前，我们知道Android也是基于Linux内核，Linux现有的进程通信手段有以下几种：
	* 管道：在创建时分配一个page大小的内存，缓存区大小比较有限；
	* 消息队列：信息复制两次，额外的CPU消耗；不合适频繁或信息量大的通信；
	* 共享内存：无须复制，共享缓冲区直接付附加到进程虚拟地址空间，速度快；但进程间的同步问题操作系统无法实现，必须各进程利用同步工具解决；
	* 套接字：作为更通用的接口，传输效率低，主要用于不通机器或跨网络的通信；
	* 信号量：常作为一种锁机制，防止某进程正在访问共享资源时，其他进程也访问该资源。因此，主要作为进程间以及同一进程内不同线程之间的同步手段。
	* 信号: 不适用于信息交换，更适用于进程中断控制，比如非法内存访问，杀死某个进程等；

2. 既然有现有的IPC方式，为什么重新设计一套Binder机制呢。主要是出于以上三个方面的考量：
3. 高性能：从数据拷贝次数来看Binder只需要进行一次内存拷贝，而管道、消息队列、Socket都需要两次，共享内存不需要拷贝，Binder的性能仅次于共享内存。
4. 稳定性：上面说到共享内存的性能优于Binder，那为什么不适用共享内存呢，因为共享内存需要处理并发同步问题，控制负责，容易出现死锁和资源竞争，稳定性较差。而Binder基于C/S架构，客户端与服务端彼此独立，稳定性较好。
5. 安全性：我们知道Android为每个应用分配了UID，用来作为鉴别进程的重要标志，Android内部也依赖这个UID进行权限管理，包括6.0以前的固定权限和6.0以后的动态权限，传荣IPC只能由用户在数据包里填入UID/PID，这个标记完全是在用户空间控制的，没有放在内核空间，因此有被恶意篡改的可能，因此Binder的安全性更高。


### Broadcast、Content Provider 和 AIDL的区别和联系
1. 这3种都可以实现跨进程的通信，那么从<font color=#492 size=3>效率，适用范围，安全性</font>等方面来比较的话他们3者之间有什么区别？
2. 概括：
	* Broadcast：用于发送和接收广播！实现信息的发送和接收！
	* AIDL：用于不同程序间服务的相互调用！实现了一个程序为另一个程序服务的功能！
	* Content Provider:用于将程序的数据库人为地暴露出来！实现一个程序可以对另个程序的数据库进行相对用的操作！
3. 优缺点：
	* Broadcast,既然是广播，那么它的优点是：注册了这个广播接收器的应用都能够收到广播，范围广。缺点是：速度慢点，而且必须在一定时间内把事情处理完(onReceive执行必须在几秒之内)，否则的话系统给出ANR。
	* AIDL，是进程间通信用的，类似一种协议吧。优点是：速度快(系统底层直接是共享内存)，性能稳，效率高，一般进程间通信就用它。
	* Content Provider,因为只是把自己的数据库暴露出去，其他程序都可以来获取数据，数据本身不是实时的，不像前两者,只是起个数据供应作用。一般是某个成熟的应用来暴露自己的数据用的。 你要是为了进程间通信，还是别用这个了，这个又不是实时数据。


## <font color=#0099ff size=6> 八 进程 </font>

### 1. 前台进程Foreground
1. 用户当前操作所必需的进程。如果一个进程满足以下任一条件，即视为前台进程：
	* 托管用户正在交互的 Activity（已调用 Activity 的 onResume() 方法）
	* 托管某个 Service，后者绑定到用户正在交互的 Activity
	* 托管正在“前台”运行的 Service（服务已调用 startForeground()）
	* 托管正执行一个生命周期回调的 Service（onCreate()、onStart() 或 onDestroy()）
	* 托管正执行其 onReceive() 方法的 BroadcastReceiver
2. 通常，在任意给定时间前台进程都为数不多。只有在内存不足以支持它们同时继续运行这一万不得已的情况下，系统才会终止它们。此时，设备往往已达到内存分页状态，因此需要终止一些前台进程来确保用户界面正常响应。

### 2. 可见进程Visible
1. 没有任何前台组件、但仍会影响用户在屏幕上所见内容的进程。 如果一个进程满足以下任一条件，即视为可见进程：
	* 托管不在前台、但仍对用户可见的 Activity（已调用其 onPause() 方法）。例如，如果前台 Activity 启动了一个对话框，允许在其后显示上一 Activity，则有可能会发生这种情况。
	* 托管绑定到可见（或前台）Activity 的 Service。
2. 可见进程被视为是极其重要的进程，除非为了维持所有前台进程同时运行而必须终止，否则系统不会终止这些进程。

### 3. 服务进程Service
1. 正在运行已使用 startService() 方法启动的服务且不属于上述两个更高类别进程的进程。尽管服务进程与用户所见内容没有直接关联，但是它们通常在执行一些用户关心的操作（例如，在后台播放音乐或从网络下载数据）。因此，除非内存不足以维持所有前台进程和可见进程同时运行，否则系统会让服务进程保持运行状态。

### 4. 后台进程Background
1. 包含目前对用户不可见的 Activity 的进程（已调用 Activity 的 onStop() 方法）。这些进程对用户体验没有直接影响，系统可能随时终止它们，以回收内存供前台进程、可见进程或服务进程使用。 
2. 通常会有很多后台进程在运行，因此它们会保存在 LRU （最近最少使用）列表中，以确保包含用户最近查看的 Activity 的进程最后一个被终止。如果某个 Activity 正确实现了生命周期方法，并保存了其当前状态，则终止其进程不会对用户体验产生明显影响，因为当用户导航回该 Activity 时，Activity 会恢复其所有可见状态。

### 5. 空进程Empty
1. 不含任何活动应用组件的进程。保留这种进程的的唯一目的是用作缓存，以缩短下次在其中运行组件所需的启动时间。 为使总体系统资源在进程缓存和底层内核缓存之间保持平衡，系统往往会终止这些进程。
2. ActivityManagerService负责根据各种策略算法计算进程的adj值，然后交由系统内核进行进程的管理。


## <font color=#0099ff size=6> 九 SettingPreference </font>
1. SP是进程同步的吗?
2. 有什么方法做到同步？


## <font color=#0099ff size=6>  十 AndroidManifest </font>
1. 动态权限适配方案，权限组的概念
2. AndroidManifest.xml文件中主要包括哪些信息？
	* manifest：根节点，描述了package中所有的内容。
	* uses-permission：请求你的package正常运作所需赋予的安全许可。
	* permission：声明了安全许可来限制哪些程序能你package中的组件和功能。
	* instrumentation：声明了用来测试此package或其他package指令组件的代码。
	* application：包含package中application级别组件声明的根节点。
	* activity：用于定义Activity，Activity用于生成与用户交互的窗口界面。
	* receiver：IntentReceiver能使的application获得数据的改变或者发生的操作，即使它当前不在运行。
	* service：Service是能在后台运行任意时间的组件。
	* provider：ContentProvider是用来管理持久化数据并发布给其他应用程序使用的组件。
3. 第一层(Manifest):(属性)

	```
	<manifest xmlns:android="http://schemas.android.com/apk/res/android"          
		package="com.woody.test"
		android:sharedUserId="string"
		android:sharedUserLabel="string resource"
		android:versionCode="integer"
		android:versionName="string"
		android:installLocation=["auto" | "internalOnly" | "preferExternal"] > 	</manifest>
	
	```
	
	* `xmlns:android` 定义android命名空间，一般为`http://schemas.android.com/apk/res/android`，这样使得Android中各种标准属性能在文件中使用，提供了大部分元素中的数据。
	* `package` 指定本应用内java主程序包的包名，它也是一个应用进程的默认名称
	* `sharedUserId`表明数据权限，因为默认情况下，Android给每个APK分配一个唯一的UserID，所以是默认禁止不同APK访问共享数据的。若要共享数据，第一可以采用Share Preference方法，第二种就可以采用sharedUserId了，将不同APK的sharedUserId都设为一样，则这些APK之间就可以互相共享数据了。详见：http://wallage.blog.163.com/blog/static/17389624201011010539408/
	* `sharedUserLabel` 一个共享的用户名，它只有在设置了sharedUserId属性的前提下才会有意义
	* `installLocation`安装参数，是Android2.2中的一个新特性，installLocation有三个值可以选择：`internalOnly、auto、preferExternal`
		* `preferExternal`,系统会优先考虑将APK安装到SD卡上(当然最终用户可以选择为内部ROM存储上，如果SD存储已满，也会安装到内部存储上)
		* `auto`，系统将会根据存储空间自己去适应
		* `internalOnly`是指必须安装到内部才能运行
		* (注：需要进行后台类监控的APP最好安装在内部，而一些较大的游戏APP最好安装在SD卡上。现默认为安装在内部，如果把APP安装在SD卡上，首先得设置你的level为8，并且要配置android:installLocation这个参数的属性为preferExternal)
 4. 第二层(<Application>):属性

	* 一个AndroidManifest.xml中必须含有一个Application标签，这个标签声明了每一个应用程序的组件及其属性(如icon,label,permission等)
	
	```
	<application  android:allowClearUserData=["true" | "false"]
		android:allowTaskReparenting=["true" | "false"]
		android:backupAgent="string"
		android:debuggable=["true" | "false"]
		android:description="string resource"
		android:enabled=["true" | "false"]
		android:hasCode=["true" | "false"]
		android:icon="drawable resource"
		android:killAfterRestore=["true" | "false"]
		android:label="string resource"
		android:manageSpaceActivity="string"
		android:name="string"
		android:permission="string"
		android:persistent=["true" | "false"]
		android:process="string"
		android:restoreAnyVersion=["true" | "false"]
		android:taskAffinity="string"
​		android:theme="resource or theme"> </application>

	```
	
	* android:allowClearUserData('true' or 'false')用户是否能选择自行清除数据，默认为true，程序管理器包含一个选择允许用户清除数据。当为true时，用户可自己清理用户数据，反之亦然
	* android:allowTaskReparenting('true' or 'false')是否允许activity更换从属的任务，比如从短信息任务切换到浏览器任务
	* `android:backupAgent` 设置该APP的备份，属性值应该是一个完整的类名，如com.project.TestCase，此属性并没有默认值，并且类名必须得指定(就是个备份工具，将数据备份到云端的操作)
	* `android:description/android:label` 此两个属性都是为许可提供的，均为字符串资源，当用户去看许可列表(android:label)或者某个许可的详细信息(android:description)时，这些字符串资源就可以显示给用户。label应当尽量简短，之需要告知用户该许可是在保护什么功能就行。而description可以用于具体描述获取该许可的程序可以做哪些事情，实际上让用户可以知道如果他们同意程序获取该权限的话，该程序可以做什么。我们通常用两句话来描述许可，第一句描述该许可，第二句警告用户如果批准该权限会可能有什么不好的事情发生
	* android:enabled 系统是否能够实例化该应用程序的组件，如果为true，每个组件的enabled属性决定那个组件是否可以被 enabled。如果为false，它覆盖组件指定的值；所有组件都是disabled。
	* android:hasCode('true' or 'false') 表示此APP是否包含任何的代码，默认为true，若为false，则系统在运行组件时，不会去尝试加载任何的APP代码
一个应用程序自身不会含有任何的代码，除非内置组件类，比如Activity类，此类使用了AliasActivity类，当然这是个罕见的现象
(在Android2.3可以用标准C来开发应用程序，可在androidManifest.xml中将此属性设置为false,因为这个APP本身已经不含有任何的JAVA代码了)
H、android:icon
这个很简单，就是声明整个APP的图标，图片一般都放在drawable文件夹下
I、android:killAfterRestore
J、android:manageSpaceActivity
K、android:name
为应用程序所实现的Application子类的全名。当应用程序进程开始时，该类在所有应用程序组件之前被实例化。
若该类(比方androidMain类)是在声明的package下，则可以直接声明android:name="androidMain",但此类是在package下面的子包的话，就必须声明为全路径或android:name="package名称.子包名成.androidMain"
L、android:permission
设置许可名，这个属性若在<application>上定义的话，是一个给应用程序的所有组件设置许可的便捷方式，当然它是被各组件设置的许可名所覆盖的
M、android:presistent
该应用程序是否应该在任何时候都保持运行状态,默认为false。因为应用程序通常不应该设置本标识，持续模式仅仅应该设置给某些系统应用程序才是有意义的。
N、android:process
应用程序运行的进程名，它的默认值为<manifest>元素里设置的包名，当然每个组件都可以通过设置该属性来覆盖默认值。如果你想两个应用程序共用一个进程的话，你可以设置他们的android:process相同，但前提条件是他们共享一个用户ID及被赋予了相同证书的时候
O、android:restoreAnyVersion
同样也是android2.2的一个新特性，用来表明应用是否准备尝试恢复所有的备份，甚至该备份是比当前设备上更要新的版本，默认是false
P、android:taskAffinity
拥有相同的affinity的Activity理论上属于相同的Task，应用程序默认的affinity的名字是<manifest>元素中设定的package名
 Q、android:theme
是一个资源的风格，它定义了一个默认的主题风格给所有的activity,当然也可以在自己的theme里面去设置它，有点类似style。
3、第三层(<Activity>):属性
<activity android:allowTaskReparenting=["true" | "false"]           android:alwaysRetainTaskState=["true" | "false"]           android:clearTaskOnLaunch=["true" | "false"]           android:configChanges=["mcc", "mnc", "locale",                                  "touchscreen", "keyboard", "keyboardHidden",                                  "navigation", "orientation", "screenLayout",                                  "fontScale", "uiMode"]           android:enabled=["true" | "false"]           android:excludeFromRecents=["true" | "false"]           android:exported=["true" | "false"]           android:finishOnTaskLaunch=["true" | "false"]           android:icon="drawable resource"           android:label="string resource"           android:launchMode=["multiple" | "singleTop" |                               "singleTask" | "singleInstance"]           android:multiprocess=["true" | "false"]           android:name="string"           android:noHistory=["true" | "false"]             android:permission="string"           android:process="string"           android:screenOrientation=["unspecified" | "user" | "behind" |                                      "landscape" | "portrait" |                                      "sensor" | "nosensor"]           android:stateNotNeeded=["true" | "false"]           android:taskAffinity="string"           android:theme="resource or theme"           android:windowSoftInputMode=["stateUnspecified",                                        "stateUnchanged", "stateHidden",                                        "stateAlwaysHidden", "stateVisible",                                        "stateAlwaysVisible", "adjustUnspecified",                                        "adjustResize", "adjustPan"] >    </activity>
(注：有些在application中重复的就不多阐述了)
1、android:alwaysRetainTaskState
 是否保留状态不变， 比如切换回home, 再从新打开，activity处于最后的状态。比如一个浏览器拥有很多状态(当打开了多个TAB的时候)，用户并不希望丢失这些状态时，此时可将此属性设置为true
2、android:clearTaskOnLaunch  比如 P 是 activity, Q 是被P 触发的 activity, 然后返回Home, 重新启动 P，是否显示 Q
3、android:configChanges
当配置list发生修改时， 是否调用 onConfigurationChanged() 方法  比如 "locale|navigation|orientation".  这个我用过,主要用来看手机方向改变的. android手机在旋转后,layout会重新布局, 如何做到呢? 正常情况下. 如果手机旋转了.当前Activity后杀掉,然后根据方向重新加载这个Activity. 就会从onCreate开始重新加载. 如果你设置了 这个选项, 当手机旋转后,当前Activity之后调用onConfigurationChanged() 方法. 而不跑onCreate方法等.
4、android:excludeFromRecents
是否可被显示在最近打开的activity列表里，默认是false
5、android:finishOnTaskLaunch
当用户重新启动这个任务的时候，是否关闭已打开的activity，默认是false
如果这个属性和allowTaskReparenting都是true,这个属性就是王牌。Activity的亲和力将被忽略。该Activity已经被摧毁并非re-parented
 6、android:launchMode(Activity加载模式)
在多Activity开发中，有可能是自己应用之间的Activity跳转，或者夹带其他应用的可复用Activity。可能会希望跳转到原来某个Activity实例，而不是产生大量重复的Activity。这需要为Activity配置特定的加载模式，而不是使用默认的加载模式
Activity有四种加载模式：
standard、singleTop、singleTask、singleInstance(其中前两个是一组、后两个是一组)，默认为standard  
standard：就是intent将发送给新的实例，所以每次跳转都会生成新的activity。
singleTop：也是发送新的实例，但不同standard的一点是，在请求的Activity正好位于栈顶时(配置成singleTop的Activity)，不会构造新的实例
singleTask：和后面的singleInstance都只创建一个实例，当intent到来，需要创建设置为singleTask的Activity的时候，系统会检查栈里面是否已经有该Activity的实例。如果有直接将intent发送给它。
singleInstance：
首先说明一下task这个概念，Task可以认为是一个栈，可放入多个Activity。比如启动一个应用，那么Android就创建了一个Task，然后启动这个应用的入口Activity，那在它的界面上调用其他的Activity也只是在这个task里面。那如果在多个task中共享一个Activity的话怎么办呢。举个例来说，如果开启一个导游服务类的应用程序，里面有个Activity是开启GOOGLE地图的，当按下home键退回到主菜单又启动GOOGLE地图的应用时，显示的就是刚才的地图，实际上是同一个Activity，实际上这就引入了singleInstance。singleInstance模式就是将该Activity单独放入一个栈中，这样这个栈中只有这一个Activity，不同应用的intent都由这个Activity接收和展示，这样就做到了共享。当然前提是这些应用都没有被销毁，所以刚才是按下的HOME键，如果按下了返回键，则无效
7、android:multiprocess
是否允许多进程，默认是false
具体可看该篇文章：http://www.bangchui.org/simple/?t3181.html
8、android:noHistory
当用户从Activity上离开并且它在屏幕上不再可见时，Activity是否从Activity stack中清除并结束。默认是false。Activity不会留下历史痕迹
9、android:screenOrientation
activity显示的模式
默认为unspecified：由系统自动判断显示方向
landscape横屏模式，宽度比高度大
portrait竖屏模式, 高度比宽度大
user模式，用户当前首选的方向
behind模式：和该Activity下面的那个Activity的方向一致(在Activity堆栈中的)
sensor模式：有物理的感应器来决定。如果用户旋转设备这屏幕会横竖屏切换
nosensor模式：忽略物理感应器，这样就不会随着用户旋转设备而更改了
10、android:stateNotNeeded
activity被销毁或者成功重启时是否保存状态
11、android:windowSoftInputMode
activity主窗口与软键盘的交互模式，可以用来避免输入法面板遮挡问题，Android1.5后的一个新特性。
这个属性能影响两件事情：
【A】当有焦点产生时，软键盘是隐藏还是显示
【B】是否减少活动主窗口大小以便腾出空间放软键盘
各值的含义：
【A】stateUnspecified：软键盘的状态并没有指定，系统将选择一个合适的状态或依赖于主题的设置
【B】stateUnchanged：当这个activity出现时，软键盘将一直保持在上一个activity里的状态，无论是隐藏还是显示
【C】stateHidden：用户选择activity时，软键盘总是被隐藏
【D】stateAlwaysHidden：当该Activity主窗口获取焦点时，软键盘也总是被隐藏的
【E】stateVisible：软键盘通常是可见的
【F】stateAlwaysVisible：用户选择activity时，软键盘总是显示的状态
【G】adjustUnspecified：默认设置，通常由系统自行决定是隐藏还是显示
【H】adjustResize：该Activity总是调整屏幕的大小以便留出软键盘的空间
【I】adjustPan：当前窗口的内容将自动移动以便当前焦点从不被键盘覆盖和用户能总是看到输入内容的部分
4、第四层(<intent-filter>)
结构图：
<intent-filter  android:icon="drawable resource"                android:label="string resource"                android:priority="integer" >
      <action />
      <category />
      <data />
</intent-filter>  
intent-filter属性
android:priority(解释：有序广播主要是按照声明的优先级别，如A的级别高于B，那么，广播先传给A，再传给B。优先级别就是用设置priority属性来确定，范围是从-1000～1000，数越大优先级别越高)
 Intent filter内会设定的资料包括action,data与category三种。也就是说filter只会与intent里的这三种资料作对比动作
 action属性
action很简单，只有android:name这个属性。常见的android:name值为android.intent.action.MAIN，表明此activity是作为应用程序的入口。
category属性
category也只有android:name属性。常见的android:name值为android.intent.category.LAUNCHER(决定应用程序是否显示在程序列表里)
有关android:name具体有哪些值，可参照这个网址：http://chroya.javaeye.com/blog/685871
data属性
<data  android:host="string"       android:mimeType="string"       android:path="string"       android:pathPattern="string"       android:pathPrefix="string"       android:port="string"       android:scheme="string"/>
【1】每个<data>元素指定一个URI和数据类型（MIME类型）。它有四个属性scheme、host、port、path对应于URI的每个部分：  scheme://host:port/path
scheme的值一般为"http"，host为包名，port为端口号，path为具体地址。如：http://com.test.project:200/folder/etc
其中host和port合起来构成URI的凭据(authority)，如果host没有指定，则port也会被忽略
要让authority有意义，scheme也必须要指定。要让path有意义，scheme+authority也必须要指定
【2】mimeType（指定数据类型），若mimeType为'Image'，则会从content Provider的指定地址中获取image类型的数据。还有'video'啥的，若设置为video/mp4，则表示在指定地址中获取mp4格式的video文件
【3】而pathPattern和PathPrefix主要是为了格式化path所使用的
5、第四层<meta-data>
<meta-data android:name="string"            android:resource="resource specification"            android:value="string"/>
这是该元素的基本结构.可以包含在<activity> <activity-alias> <service> <receiver>四个元素中。
android:name（解释：元数据项的名字，为了保证这个名字是唯一的，采用java风格的命名规范，如com.woody.project.fried)
android:resource(解释：资源的一个引用，指定给这个项的值是该资源的id。该id可以通过方法Bundle.getInt()来从meta-data中找到。)
android:value(解释：指定给这一项的值。可以作为值来指定的数据类型并且组件用来找回那些值的Bundle方法：[getString],[getInt],[getFloat],[getString],[getBoolean])
 6、第三层<activity-alias>属性
<activity-alias android:enabled=["true" | "false"]                 android:exported=["true" | "false"]                 android:icon="drawable resource"                 android:label="string resource"                 android:name="string"                 android:permission="string"                 android:targetActivity="string">
<intent-filter/>  <meta-data/> </activity-alias>
<activity-alias>是为activity创建快捷方式的，如下实例：
 <activity android:name=".shortcut">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
            </intent-filter>
</activity>
 <activity-alias android:name=".CreateShortcuts" android:targetActivity=".shortcut" android:label="@string/shortcut">
    <intent-filter>
             <action android:name="android.intent.action.CREATE_SHORTCUT" />
             <category android:name="android.intent.category.DEFAULT" />
     </intent-filter>
 </activity-alias>
其中android.targetActivity是指向对应快捷方式的activity,如上述的shortcut(此Activity名)
android:label是指快捷方式的名称，而快捷方式的图标默认是给定的application图标
 7、第三层<service>
【1】service与activity同级，与activity不同的是，它不能自己启动的，运行在后台的程序，如果我们退出应用时，Service进程并没有结束，它仍然在后台运行。比如听音乐，网络下载数据等，都是由service运行的
【2】service生命周期：Service只继承了onCreate(),onStart(),onDestroy()三个方法，第一次启动Service时，先后调用了onCreate(),onStart()这两个方法，当停止Service时，则执行onDestroy()方法，如果Service已经启动了，当我们再次启动Service时，不会在执行onCreate()方法，而是直接执行onStart()方法
【3】service与activity间的通信
Service后端的数据最终还是要呈现在前端Activity之上的，因为启动Service时，系统会重新开启一个新的进程，这就涉及到不同进程间通信的问题了(AIDL)，Activity与service间的通信主要用IBinder负责。具体可参照：http://zhangyan1158.blog.51cto.com/2487362/491358
【4】
<service android:enabled=["true" | "false"]
         android:exported[="true" | "false"]
         android:icon="drawable resource"
         android:label="string resource"
         android:name="string"
         android:permission="string"
         android:process="string">
</service>
service标签内的属性之前已有描述，在此不重复了～
8、第三层<receiver>
receiver的属性与service一样，这里就不显示了
BroadcastReceiver：用于发送广播，broadcast是在应用程序之间传输信息的一种机制，而BroadcastReceiver是对发送出来的 Broadcast进行过滤接受并响应的一类组件，具体参照http://kevin2562.javaeye.com/blog/686787
9、第三层<provider>属性
<provider android:authorities="list"
          android:enabled=["true" | "false"]
          android:exported=["true" | "false"]
          android:grantUriPermissions=["true" | "false"]
          android:icon="drawable resource"
          android:initOrder="integer"
          android:label="string resource"
          android:multiprocess=["true" | "false"]
          android:name="string"
          android:permission="string"
          android:process="string"
          android:readPermission="string"
          android:syncable=["true" | "false"]
          android:writePermission="string">
           <grant-uri-permission/>
           <meta-data/>
</provider>
contentProvider(数据存储)
【1】android:authorities：
标识这个ContentProvider，调用者可以根据这个标识来找到它
【2】android:grantUriPermission：
对某个URI授予的权限
【3】android:initOrder
10、第三层<uses-library>
用户库，可自定义。所有android的包都可以引用
11、第一层<supports-screens>
<supports-screens  android:smallScreens=["true" | "false"]                    android:normalScreens=["true" | "false"]                    android:largeScreens=["true" | "false"]                    android:anyDensity=["true" | "false"] />
这是在android1.6以后的新特性，支持多屏幕机制
各属性含义：这四个属性，是否支持大屏，是否支持中屏，是否支持小屏，是否支持多种不同密度
12、第二层<uses-configuration />与<uses-feature>性能都差不多
<uses-configuration  android:reqFiveWayNav=["true" | "false"]                      android:reqHardKeyboard=["true" | "false"]                     android:reqKeyboardType=["undefined" | "nokeys" | "qwerty" |   "twelvekey"]                     android:reqNavigation=["undefined" | "nonav" | "dpad" |  "trackball" | "wheel"]                     android:reqTouchScreen=["undefined" | "notouch" | "stylus" | "finger"] />
<uses-feature android:glEsVersion="integer"               android:name="string"               android:required=["true" | "false"] />
这两者都是在描述应用所需要的硬件和软件特性，以便防止应用在没有这些特性的设备上安装。
 13、第二层<uses-sdk />
<uses-sdk android:minSdkVersion="integer"           android:targetSdkVersion="integer"           android:maxSdkVersion="integer"/>
描述应用所需的api level，就是版本，目前是android 2.2 = 8，android2.1 = 7，android1.6 = 4，android1.5=3
在此属性中可以指定支持的最小版本，目标版本以及最大版本
14、第二层<instrumentation />
<instrumentation android:functionalTest=["true" | "false"]                  android:handleProfiling=["true" | "false"]                  android:icon="drawable resource"                  android:label="string resource"                  android:name="string"                  android:targetPackage="string"/>
 定义一些用于探测和分析应用性能等等相关的类，可以监控程序。在各个应用程序的组件之前instrumentation类被实例化
android:functionalTest(解释：instrumentation类是否能运行一个功能测试，默认为false)
15、<permission>、<uses-permission>、<permission-tree />、<permission-group />区别～
最常用的当属<uses-permission>，当我们需要获取某个权限的时候就必须在我们的manifest文件中声明，此<uses-permission>与<application>同级，具体权限列表请看此处
通常情况下我们不需要为自己的应用程序声明某个权限，除非你提供了供其他应用程序调用的代码或者数据。这个时候你才需要使用<permission> 这个标签。很显然这个标签可以让我们声明自己的权限。比如：
<permission android:name="com.teleca.project.MY_SECURITY" . . . />
那么在activity中就可以声明该自定义权限了，如：
 <application . . .>
        <activity android:name="XXX" . . . >
                  android:permission="com.teleca.project.MY_SECURITY"> </activity>
 </application>
当然自己声明的permission也不能随意的使用，还是需要使用<uses-permission>来声明你需要该权限
<permission-group> 就是声明一个标签，该标签代表了一组permissions，而<permission-tree>是为一组permissions声明了一个namespace。这两个标签可以看之前的系列文章。

#### 参考文章
1. [Android基础](https://github.com/guoxiaoxing/android-interview)



