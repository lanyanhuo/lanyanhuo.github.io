---
layout: post
title: Application
category: Android
tags: [Android]
---

## Application

### 1. 点击app icon之后
1. 点击应用图标后会去启动应用的LauncherActivity，如果LancerActivity所在的进程没有创建，还会创建新进程，整体的流程就是一个Activity的启动流程。

#### 1.1 涉及到类
1. Instrumentation: 监控应用与系统相关的交互行为。
2. AMS：组件管理调度中心，什么都不干，但是什么都管。
3. ActivityStarter：Activity启动的控制器，处理Intent与Flag对Activity启动的影响，具体说来有：
	* 寻找符合启动条件的Activity，如果有多个，让用户选择；
	* 校验启动参数的合法性；3 返回int参数，代表Activity是否启动成功。
4. ActivityStackSupervisior：这个类的作用你从它的名字就可以看出来，它用来管理任务栈。
5. ActivityStack：用来管理任务栈里的Activity。
6. ActivityThread：最终干活的人，是ActivityThread的内部类，Activity、Service、BroadcastReceiver的启动、切换、调度等各种操作都在这个类里完成。

#### 1.2 整个流程主要涉及四个进程
1. 调用者进程，如果是在桌面启动应用就是Launcher应用进程。
2. ActivityManagerService等所在的System Server进程，该进程主要运行着系统服务组件。
3. Zygote进程，该进程主要用来fork新进程。
4. 新启动的应用进程，该进程就是用来承载应用运行的进程了，它也是应用的主线程（新创建的进程就是主线程），处理组件生命周期、界面绘制等相关事情。

#### 1.3 总结
1. 点击桌面应用图标，Launcher进程将启动Activity（MainActivity）的请求以Binder的方式发送给了AMS。
2. AMS接收到启动请求后，交付ActivityStarter处理Intent和Flag等信息，然后再交ActivityStackSupervisior/ActivityStack处理Activity进栈相关流程。同时以Socket方式请求Zygote进程fork新进程。
3. Zygote接收到新进程创建请求后fork出新进程。
4. 在新进程里创建ActivityThread对象，新创建的进程就是应用的主线程，在主线程里开启Looper消息循环，开始处理创建Activity。
5. ActivityThread利用ClassLoader去加载Activity、创建Activity实例，并回调Activity的onCreate()方法，加载布局，绘制视图。这样便完成了Activity的启动。


### 2. 四大组件的创建
1. Activity：通过LoadedApk的makeApplication()方法创建。
2. Service：通过LoadedApk的makeApplication()方法创建。
3. 静态广播：通过其回调方法onReceive()方法的第一个参数指向Application。
4. ContentProvider：无法获取Application，因此此时Application不一定已经初始化。


## 一 Activity
1. SubClass: FragmentActivity， TabActivity， ListActivity（LauncherActivity, PreferenceActivity), AlasActivity,  ExpandableActivity, PreferenceActivity.

### 1. 生命周期


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



## 二 Fragment

### 1. 生命周期

### 2. Fragment滑动，传递数据的方式

### 5. 如何在Adapter使用中解耦


## 三 Service

### 1. 开启方式, 生命周期
1. 只是用startService()启动服务：`onCreate() -> onStartCommand() -> onDestory()`
2. 只是用bindService()绑定服务：`onCreate() -> onBind() -> onServiceConnected() ->  onUnBind() -> onDestory()`
3. 同时使用startService()启动服务与bindService()绑定服务：`onCreate() -> onStartCommnad() -> onBind() -> onUnBind() -> onDestory()`
4. 两者区别：
	* startService开启服务以后，与Activity就没有关联，不受影响，独立运行。
	* bindService开启服务以后，与Activity存在关联，Activity需要实现ServiceConnected, 并且退出Activity时必须调用unbindService方法，否则会报ServiceConnection泄漏的错误。
5. 无论调用多少次startService()或bindService()方法，onCreate() 该方法在服务被创建时调用，该方法只会被调用一次。onDestroy()该方法在服务被终止时调用，也只被调用一次。

### 3. IPC
1. 跨进程访问别的应用程序。
	* 广播属于单向通信，也可以跨进程。
	* ContentProvider可以将URI接口暴露数据给其他应用访问。
	* Messenger单线程跨进程通信。
	* AIDL多线程，多客户端并发访问。

	
#### 3.1 AIDL
1. 多线程，多客户端并发访问。
2. 用法
	* 创建一个aidl文件，添加`IRemoteService.aidl`，以及需要实现的接口`getId(), getType()`。
	* 保存后编译器会在gen目录下自动生成`IRemoteService.java`文件
	* 定义`AIDLService.java`
	* `AndroidManifest.xml中注册，并添加“xx.xx.xx.aidl” 的ACTION`		
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
2. 提供了一定的功能和接口供其他应用程序调用，满足应用和应用之间的交互。
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

#### 5.2 用法


## 四 BroadcastReceiver
### 1. 注册
1. 静态注册：常驻系统，不受组件生命周期影响，即便应用退出，广播还是可以被接收，耗电、占内存。
2. 动态注册：非常驻，跟随组件的生命变化，组件结束，广播结束。在组件结束前，需要先移除广播，否则容易造成内存泄漏。

### 2. 分类
1. BroadcastReceiver 是跨应用广播，利用Binder机制实现。
2. LocalBroadcastReceiver 是应用内广播，利用Handler实现，利用了IntentFilter的match功能，提供消息的发布与接收功能，实现应用内通信，效率比较高。
3. 普通广播：调用sendBroadcast()发送，最常用的广播。
4. 有序广播：调用sendOrderedBroadcast()，发出去的广播会被广播接受者按照顺序接收，广播接收者按照Priority属性值从大-小排序，Priority属性相同者，动态注册的广播优先，广播接收者还可以选择对广播进行截断和修改。


### 3. 发送与接收原理
1. 继承BroadcastReceiver，重写onReceive()方法。
2. 通过Binder机制向ActivityManagerService注册广播。
3. 通过Binder机制向ActivityMangerService发送广播。
4. ActivityManagerService查找符合相应条件的广播（IntentFilter/Permission）的BroadcastReceiver，将广播发送到BroadcastReceiver所在的消息队列中。
5. BroadcastReceiver所在消息队列拿到此广播后，回调它的onReceive()方法。

### 6. 其他
1. 如何通过Broadcast拦截abort一条短信

## 五 ContentProvider

### 1. ContentProvider,ContentResolver, ContentObserver
1. ContentProvider
	* 管理数据，提供数据的增删改查。
	* 数据源可以时db,file,xml,url等。
	* 为这些数据访问提供了统一的接口，进程间数据共享。
2. ContentResolver
	* 使用不同url操作不同ContentProvider中的数据
	* 外部进程通过ContentResolver与ContentProvider进行交互。
3. ContentObserver：观察ContentProvider数据变化，通知外界。

### 2. 权限管理
1. 读写分离，
2. 权限控制-精确到表级
3. URL控制

### 3. 系统为什么会设计ContentProvider




## 六 Intent


## 七 Binder
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

## 八 进程

### 1. 前台进程
1. 用户当前操作所必需的进程。如果一个进程满足以下任一条件，即视为前台进程：
	* 托管用户正在交互的 Activity（已调用 Activity 的 onResume() 方法）
	* 托管某个 Service，后者绑定到用户正在交互的 Activity
	* 托管正在“前台”运行的 Service（服务已调用 startForeground()）
	* 托管正执行一个生命周期回调的 Service（onCreate()、onStart() 或 onDestroy()）
	* 托管正执行其 onReceive() 方法的 BroadcastReceiver
2. 通常，在任意给定时间前台进程都为数不多。只有在内存不足以支持它们同时继续运行这一万不得已的情况下，系统才会终止它们。此时，设备往往已达到内存分页状态，因此需要终止一些前台进程来确保用户界面正常响应。

### 2. 可见进程
1. 没有任何前台组件、但仍会影响用户在屏幕上所见内容的进程。 如果一个进程满足以下任一条件，即视为可见进程：
	* 托管不在前台、但仍对用户可见的 Activity（已调用其 onPause() 方法）。例如，如果前台 Activity 启动了一个对话框，允许在其后显示上一 Activity，则有可能会发生这种情况。
	* 托管绑定到可见（或前台）Activity 的 Service。
2. 可见进程被视为是极其重要的进程，除非为了维持所有前台进程同时运行而必须终止，否则系统不会终止这些进程。

### 3. 服务进程
1. 正在运行已使用 startService() 方法启动的服务且不属于上述两个更高类别进程的进程。尽管服务进程与用户所见内容没有直接关联，但是它们通常在执行一些用户关心的操作（例如，在后台播放音乐或从网络下载数据）。因此，除非内存不足以维持所有前台进程和可见进程同时运行，否则系统会让服务进程保持运行状态。

### 4. 后台进程
1. 包含目前对用户不可见的 Activity 的进程（已调用 Activity 的 onStop() 方法）。这些进程对用户体验没有直接影响，系统可能随时终止它们，以回收内存供前台进程、可见进程或服务进程使用。 
2. 通常会有很多后台进程在运行，因此它们会保存在 LRU （最近最少使用）列表中，以确保包含用户最近查看的 Activity 的进程最后一个被终止。如果某个 Activity 正确实现了生命周期方法，并保存了其当前状态，则终止其进程不会对用户体验产生明显影响，因为当用户导航回该 Activity 时，Activity 会恢复其所有可见状态。

### 5. 空进程
1. 不含任何活动应用组件的进程。保留这种进程的的唯一目的是用作缓存，以缩短下次在其中运行组件所需的启动时间。 为使总体系统资源在进程缓存和底层内核缓存之间保持平衡，系统往往会终止这些进程。
2. ActivityManagerService负责根据各种策略算法计算进程的adj值，然后交由系统内核进行进程的管理。

#### 参考文章
1. [Android基础](https://github.com/guoxiaoxing/android-interview)



