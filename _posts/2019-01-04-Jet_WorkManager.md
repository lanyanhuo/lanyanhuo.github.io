---
layout: post
title: Jet_WorkManager
category: Android
tags: [Android]
---

## Jetpack WorkManager


### 1. 导航
1. `WorkManager`用于应用程序执行任务，即使退出系统，也可以保证运行。
2. 当应用程序进程消失，`WorkManager`不适用于可以安全终止的进程内后台任务。这时使用`ThreadPools`.
3. `WorkManager`会根据设备API和包含的依赖项，选择适当的方式安排后台任务，如`JobScheduler, Firebase Job Dispatcher 或者 AlarmManager`。


### 2. 基础

#### 2.1 相关类
1. `Worker`: 指定要执行的任务。
2. `WorkRequest`: 代表一项单独的任务。需要`指定Worker`,也可以向`WorkRequest`添加具体信息。
	* `OneTimeWorkRequest, PeriodicWorkRequest`: 一次，还是多次请求。
	* `WorkRequest.Builder`: 创建`WorkRequest`的辅助类。
	* `Constraints`: 指定对任务运行时间的限制。
3. `WorkManager`: 管理类。将`WorkRequest`传递给`WorkManager`给队列任务。`WorkManager`调度任务的方式是分散系统资源负载，遵守指定的约束。
4. `WorkInfo`: 包含有关特定任务的信息。`WorkManager`提供了`LiveData`对每个`WorkRequest`进行监听获取任务状态。

#### 2.2 工作流
1. 定义Worker，实现`doWork`
2. 定义WorkRequest,`OneTimeWorkRequestBuilder<Worker>().build()`
3. 执行请求`WorkManager.getInstance().enqueue(workRequest)`
4. 通过LiveData获取执行状态

	```
	WorkManager.getInstance().getWorkInfoByIdLiveData(worker.id)
		.observe(lifecycleOwner, Observer { workInfo -> 
			if (workInfo != null && workInfo.state.isFinished) {
				// 完成请求
			}
		})
	```

#### 2.3 任务约束
1. `WorkRequest`设置约束

	```
	val constraints = Constraints.Builder()
		.setRequiresDeviceIdle(true)
		.setRequiresCharging(true)
		.build()
	
	val workRequest = OneTimeWorkRequestBuiler<Worker>()
		.setConstraints(constraints)
		.build()
	```

#### 2.4 取消任务
1. 在执行请求后可以取消任务。
2. 通过`WorkRequest`获取ID进行取消。
3. `WorkManager`会尽最大努力取消，但不一定能成功。

```
val requestWorkId: UUID = workRequest.getId()
WorkManager.getInstance().cancelWorkById(requestWorkId)
```

#### 2.5 标记的任务
1. 给`WorkRequest`打标签。`request.setTag("XXX")`
2. 根据TAG取消所有任务`WorkManager.cancelAllWorkByTag(String)`  
3. 根据TAG获取任务执行的状态`WorkManager.getWorkInfosByTagLiveData(String)`

#### 2.6 重复的任务
1. 使用`PeriodicWorkRequestBuilder`创建`WorkRequest`, ` PeriodicWorkRequestBuilder<PhotoCheckWorker>(12, TimeUnit.HOURS).build()`
2. 执行`WorkManager.getInstance().enqueue(workRequest)`

### 3. 进阶


#### 3.1 链式任务
1. 特定顺序执行多个任务。`WorkManager`允许创建和排列指定多个任务的工作序列，以及他们的运行顺序。
2. 使用`WorkContinuation`

	```
	WorkManager.getInstance()
		.beginWith(workRquestA) // WorkContinuation
		.beginWith(Arrays.asList(workA1, workA2)) // // ...when all A tasks are finished, run the single B task:
		.then(workRequestB)
		.then(workRequestC)
		.enqueue()
	```
3. 可以创建复杂的chains。

	```
	val chain1 = WorkManager.getInstance().beginWith(workA).then(workB)
	val chain2 = WorkManager.getInstance().beginWith(workC).then(workD)
	val chain3 = WorkContinuation.combine(Array.asList(chain1, chain2)).then(workE)
	chain3.enqueue()
	```

#### 3.2 特定的工作顺序
1. 使用`beginUniqueWork(String, ExistingWorkPolicy, OneTimeWorkRequest)`创建特定的任务顺序。

#### 3.3 输入参数和返回值
1. `WorkRequest.Builder.setInputData(Data)`将参数传递给任务。
2. 观察任务输出的返回值。`Result.success(Data)`

### 4. 从JobDispatcher迁移
1. `WorkManager`替代`FireBase JobDispatcher`

#### 4.1 Gradle设置
```
dependencies {
    def work_version = "1.0.0-beta01"

    implementation "android.arch.work:work-runtime:$work_version" // use -ktx for Kotlin+Coroutines

    // optional - RxJava2 support
    implementation "android.arch.work:work-rxjava2:$work_version"

    // optional - Test helpers
    androidTestImplementation "android.arch.work:work-testing:$work_version"
}
```

#### 4.2 从JobService到Workers
1. 继承`JobService`，在主线程中调用`onStartJob`,应用程序负责在后台中卸载工作。
2. `WorkManager`的基本单元是`ListenableWorker`,也有其他可用的类型`Worker, RxWorker, CoroutinerWorker`.
3. `ListenableWorker.startWork`类似于`JobService.onStartJob`,也在主线程中调用，返回一个`ListenableFuture`实例，用于异步发出工作完成信号。这里保证线程安全。
4. `ListenableFuture.Result`包括`success, retry, failure`等
5. 当网络不可用，或者调用`WorkManager.cancel()`,或者OS由于其他原因关闭了Worker，`onStop`会被调用。

	```
	class MyWorker(appContext: Context, params: WorkerParameters) :  
    ListenableWorker(appContext, params) {

    override fun startWork(): ListenableFuture<ListenableWorker.Result> {
        // Do your work here.
        TODO("Return a ListenableFuture<Result>")
    }

    override fun onStopped() {
        // Cleanup because you are being stopped.
    }
}
	```
6. `SimpleJobService`映射`Worker`

#### 4.3 JobBuilder映射到WorkRequest
1. `Job.Builder`表示元数据，映射`WorkRequest`包含`OneTimeWorkRequest, PeriodicWorkRequest`。
2. `Job.Builder.setRecurring(true)`对应`PeriodicWorkRequest`.
3. 创建`WorkRequest`

	```
	val data = workDataOf("some_key" to "some_val")
	val constraints: Constraints = Constraints.Builder().apply {
		    setRequiredNetworkType(NetworkType.CONNECTED)
		    setRequiresCharging(true)
		}.build()
	val request: OneTimeWorkRequest = OneTimeWorkRequestBuilder<MyWorker>()
		.setInputData(data)
		.setInitialDelay(60, TimeUnit.SECONDS)
		.setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30000, TimeUnit.MILLISECONDS)
		.setConstrains(constraints)// 限制
		.build()
	```

#### 4.4 调度,取消工作
1. `WorkRequest`使用唯一的标识，执行调度和取消执行

	```
	WorkManager.getInstance().enqueueUniqueWork("my-unique-name", ExistingWorkPolicy.KEEP, request)
	
	WorkManager.getInstance().cancleUniqueWork("my-unique-name")
	```

#### 4.5 初始化WorkManager
1. 在`Application.onCreate`中调用`WorkManager.initialize()`
