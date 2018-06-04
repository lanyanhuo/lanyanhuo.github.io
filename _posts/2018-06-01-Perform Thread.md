---
layout: post
title: Perform Thread
category: Android
tags: [Android]
---

# 多线程
1. AsyncTask, HandlerThread, IntentService ,ThreadPool, Loader等

## 一 AsyncTask
1. 内部是Thread+Handler。
2. Android1.5	前，AsyncTask执行时顺序的，需要等待上一个task执行完成。
3. Android1.6-> Android2.3,AsyncTask执行顺序修改为并行。当task访问同一个资源时会出现并发问题。
4. Android3.0后AsyncTask修改为顺序执行，新添加了一个函数executeOnExecutor(Executor),如果需要并行执行，只需调用该函数，并把参数设置为并行即可。
	* 创建一个单独的线程池(Executors.newCachedThreadPool())
	* 或者使用executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, Params...params)
5. [源码分析](https://blog.csdn.net/liyuchong2537631/article/details/49760177)


### 1. 流程原理
1. AsyncTask如何实现在doInBackgroud()中执行耗时操作。
2. 如何在onPostExecute,onProgress等中得到返回值。
3. 需要了解的知识：
	* Callable可以理解为产生结果。类似于Runnable，但Runnable不会返回结果，并且无法抛出返回结果的异常。
	* FutureTask拿到异步执行任务的返回值。


#### 1.1 new AsyncTask

```
mWorker = new WorkerRunnable<Params, Result>() {//实现了Callable类
            public Result call() throws Exception {
                mTaskInvoked.set(true);
                Result result = null;
                try {
                    Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
                    //noinspection unchecked
                    //子线程中执行
                    result = doInBackground(mParams);
                    Binder.flushPendingCommands();
                } catch (Throwable tr) {
                    mCancelled.set(true);
                    throw tr;
                } finally {
                		//通过Handler和Message将结果发给InternalHandler处理
                    postResult(result);
                }
                return result;
            }
mFuture = new FutureTask<Result>(mWorker) {//使用FutureTask运行Callable任务
            @Override
            protected void done() {
                try {
                //调用postResult发送给Handler去处理，然后通过onProgressUpdate返回给主线程
                    postResultIfNotInvoked(get());
                } catch (InterruptedException e) {
                	 ...
                } catch (CancellationException e) {
                    postResultIfNotInvoked(null);
                }
            }
        };           
```


#### 1.2 execute
1. 使用执行器 `SerialExecutor implements Executor`
2. 顺序 **execute** 执行任务runnable.run().
3. 并行 **executeOnExecutor**通过判断最终还是执行**exec.execute(mFuture);**


### 2. 内存泄漏
1. AsyncTask是Activity非静态内部类，持有Activity的引用。
2. 在Activity销毁前cancel掉AsyncTask。Activity销毁再跑子线程对UI也没什么意义。
3. 或者使用static + WeakReference的形式。

## 二 HandlerThread
1. HandlerThread用来代替Thread。自己内部带有Looper线程，可以异步处理耗时任务。
2. HandlerThread启动后，通过getLooper取出Looper(主线程)，Looper对象初始化在子线程run中处理。getLooper()方法中的 wait()与run方法中的notifyAll()共同协作，实现了两个线程之间的同步。
3. 实现子线程与UI线程通信，可以两个子线程之间通信
4. 在使用时需要手动回收
5. 使用

```
HandlerThread audioThread = new HandlerThread("audio_thread");
Handler audioHandler;
 //启动线程
        audioThread.start();
        //通过fetchHandler发送的消息，会被audioThread线程创建的轮询器拉取到
        audioHandler = new Handler(fetchThread.getLooper()){
            @Override
            public void handleMessage(Message msg) {
                SystemClock.sleep(1000);

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        tv.setText("audio run");
                    }
                });

                //循环执行
                audioHandler.sendEmptyMessage(1);
            }
        };
    
```

## 三 IntentService
1. Service + HandlerThread + Intent
2. 处理耗时任务，减轻主线程的压力
3. 封装了HandlerThread的实现过程
4. 启动IntentService类型的Service后，系统通过ServiceHandler将携带的Intent消息放入由HandlerThread线程生成的Looper的消息队列中，Looper依次处理队列中的消息并通过dispatchMessage将消息交给ServiceHandler的Handler来具体执行（其实就是Handler的用法，和我们在Activity中创建Handler并在handleMessage中更新ui的用法一样，只不过这里的handleMessage是在HandlerThread这样的后台线程而不是ui线程中执行的）
5. 调用子类的onHandleIntent方法（用来执行费时操作），结束后关闭Service 总之，这种机制通常用于希望按顺序执行（串行）而非并发（并行）执行的费时操作， 
其中每个任务执行完毕的时间是未知的的应用场景。如果希望在任务结束后通知前台可以通过sendBroadCast的方式发送广播。

## 四 ThreadPool


## 五 Loader
1. [Loader机制](https://blog.csdn.net/sk719887916/article/details/51540610)



#### 参考文章
1. [AsyncTask](https://blog.csdn.net/hpc19950723/article/details/70738922)



