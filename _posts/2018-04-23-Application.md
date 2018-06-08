---
layout: post
title: Application
category: Audition
tags: [Audition]
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


AlertDialog,popupWindow,Activity区别

Application 和 Activity 的 Context 对象的区别

### 3. 进程和 Application 的生命周期
1. onCreate -> onTerminate -> onLowMemory -> onTrimMemory -> onConfigurationChanged


## 一 Activity
1. SubClass: FragmentActivity， TabActivity， ListActivity（LauncherActivity, PreferenceActivity), AlasActivity,  ExpandableActivity, PreferenceActivity.

### 1. 生命周期

#### 1.1 主要
1. onCreate(Bundle savedInstanceState)：创建activity时调用。设置在该方法中，还以Bundle的形式提供对以前储存的任何状态的访问！
2. onStart()：activity变为在屏幕上对用户可见时调用。(onRestart()之后也会调用）
3. onResume()：activity开始与用户交互时调用（无论是启动还是重新启动一个活动，该方法总是被调用的）。
4. onPause()：activity被暂停或收回cpu和其他资源时调用，该方法用于保存活动状态的。
5. onStop()：activity被停止并转为不可见阶段及后续的生命周期事件时调用。(是否调用取决于新的activity有无透明部分)
6. onRestart()：重新启动activity时调用。该活动仍在栈中，而不是启动新的活动。 
7. OnDestroy()：activity被完全从系统内存中移除时调用，该方法被 2.横竖屏切换时候activity的生命周期

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

#### 3.2 onRestoreInstanceState

### 4. 其他情况
1. Activity作为对话框
	* 设置为Dialog，android:theme="@style/Theme.Dialog".
	* Activity设置成半透明的对话框，设置如下主题即可：android:theme=”@android:style/Theme.Translucent” 


### 5. 关闭
1. 退出Activity直接finish即可。
2. 抛异常强制退出,该方法通过抛异常，使程序Force Close。验证可以，但是，需要解决的问题是，如何使程序结束掉，而不弹出Force Close的窗口。
3. 记录打开的Activity：每打开一个Activity，就记录下来。在需要退出时，关闭每一个Activity即可。
4. 发送特定广播：在需要结束应用时，发送一个特定的广播，每个Activity收到广播后，关闭即可。
5. 递归退出：在打开新的Activity时使用startActivityForResult，然后自己加标志，在onActivityResult中处理，递归关闭。最好定义一个Activity基类。


## 二 Fragment

### 1. 生命周期
1. 打开onAttach-> onCreate-> onCreateView->onActivityCreated->onStart->onResume 
2. 退出onPause->onStop->onDestroyView->onDestroy->onDetach
3. onAttach(Activity):当Fragment和Activity发生关联时使用
4. onCreateView(LayoutInflater, ViewGroup, Bundle):创建该Fragment的视图
5. onActivityCreate(Bundle):当Activity的onCreate方法返回时调用
6. onDestoryView():与onCreateView相对应，当该Fragment的视图被移除时调用
7. onDetach():与onAttach相对应，当Fragment与Activity关联被取消时调用   
8. 注意: 除了onCreateView，其他的所有方法如果你重写了，必须调用父类对于该方法的实现

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


### Fragment
Activity与Fragment之间生命周期比较

1. Fragment 在 ViewPager 里面的生命周期，滑动 ViewPager 的页面时 Fragment 的生命周期的变化；
2. 为什么 Google 会推出Fragment ，有什么好处和用途？ 直接用 View 代替不行么？

#### ViewPager
1. 如何设置成每次只初始化当前的Fragment，其他的不初始化？


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
3. 生命周期只有十秒左右.

### 2. 分类
1. `BroadcastReceiver` 是跨应用广播，利用Binder机制实现。
2. `LocalBroadcastReceiver` 是应用内广播，利用Handler实现，利用了IntentFilter的match功能，提供消息的发布与接收功能，实现应用内通信，效率比较高。
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
5. BroadcastReceiver所在消息队列拿到此广播后，回调它的onReceive()方法。


### 场景
1. 电话呼入事件、数据网络可用通知或者到了晚上时进行通知。
2. 闪背光灯，震动，播放声音。
### 6. 其他
1. 如何通过Broadcast拦截abort一条短信



广播是否可以请求网络？

广播引起anr的时间限制是多少？


本地广播和全局广播有什么差别？
广播使用的方式和场景

## 五 ContentProvider

### 1. ContentProvider,ContentResolver, ContentObserver
1. ContentProvider
	* 管理数据，提供数据的增删改查。
	* 数据源可以是db,file,xml,url等。
	* 为这些数据访问提供了统一的接口，进程间数据共享。
2. ContentResolver
	* 使用不同url操作不同ContentProvider中的数据。
	* 外部进程通过ContentResolver与ContentProvider进行交互。
	* 
3. ContentObserver：观察ContentProvider数据变化，通知外界。

### 2. 权限管理
1. 读写分离，
2. 权限控制-精确到表级
3. URL控制
4. ContentProvider的权限管理(解答：读写分离，权限控制-精确到表级，URL控制)

### 3. 系统为什么会设计ContentProvider
1. 意义：应用间数据共享的一种方式。比如通讯录、短信。
2. 封装：对数据进行封装，提供统一的接口，使用者不必关心数据源
3. 应用程序能够将它们的数据保存到文件或SQLite数据库中，甚至是任何有效的设备中。当需要将数据与其他的应用共享时，内容提供者将会很有用。一个内容提供者类实现了一组标准的方法，从而能够让其他应用程序保存或读取此内容提供者处理的各种数据类型。

### 4. 使用
```
  <provider android:name=".PersonProvider" android:authorities="com.bravestarr.provider.personprovider"/>  
  
  public boolean onCreate();//处理初始化操作

       /**        * 插入数据到内容提供者(允许其他应用向你的应用中插入数据时重写)
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


## 六 Intent

#### 1. Android里的Intent传递的数据有大小限制吗，如何解决？
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

### MAIN, VIEW, PICK, EDIT




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



简述IPC？

什么是AIDL？

AIDL解决了什么问题？

AIDL如何使用？

Android 上的 Inter-Process-Communication 跨进程通信时如何工作的？

## 八 进程

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


## 九 SettingPreferenc
1. SP是进程同步的吗?有什么方法做到同步？


## 十 AndroidManifest
1. 动态权限适配方案，权限组的概念


#### 参考文章
1. [Android基础](https://github.com/guoxiaoxing/android-interview)



