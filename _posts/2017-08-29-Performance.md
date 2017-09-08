---
layout: post
title: Performance
category: Training
tags: [Practices——Performance]
---


[Best Practices for Performance](https://developer.android.com/training/best-performance.html)

1. Build an app that is smooth, responsive, and uses a little battery as possible. 

## 1 Performance Tips
1. Optimize app preformance.
2. Improve responsiveness and battery efficiency.
3. Two basic rules : 
	* Don't do work that you don't need to do.
	* Don't allocate memory if you can avoid it.



#### 1.1 Avoid Creating Unnecessary Objects


#### 1.2 Perfer Static Over Virtual 

#### 1.3 Use Static Final For Constants

#### 1.4 Use Enhanced For Loop Syntax

#### 1.5 Consider Package

#### 1.6 Avoid Using Floating-Point

#### 1.7 Konw and Use the Libraries

#### 1.8 Use Native Methods Carefully

#### 1.9 Performace Myths

#### 1.10 Always Measure
1. Accurately measure.
2. Profiling with [TraceView](https://developer.android.com/studio/profile/traceview.html) and dmtracedump
3. Analyzing UI Performance with [Systrace](https://developer.android.com/studio/profile/systrace.html)



## 2 Improving Layout Performance
1. Layout performance and UI repsonsiveness.
2. Layouts effect UX.
3. Avoid memory hungry.
4. Smooth scrolling interfaces.


### 2.1 Optimizing Layout Hierarchies
1. By SDK tool optimize layout.

#### 2.1.1 Inspect Your Layout
1. Android Studio/VAS/ADV/Hierarchy viewer.

#### 2.1.2 Revise Your Layout
1. User `RelativeLayout`

#### 2.1.3 Use Lint
1. Compound drawables
2. Merge root frame
3. Useless leaf
4. Useless parent
5. Deep layouts
6. Lint is integrated into Android Studio.
7. File>Settings>Project Settings to manage inspection profiles and configure inspections with AS.


### 2.2 Re-using Layouts with <include/>
1. Efficiently re-use layouts, use `<include/>` or `<merge/>` tags to embed another layout inside current layout.


#### 2.2.1 Create a Re-usable Layout
1. Define a new layout such as a title bar layout.
2. `tools:showIn` is a special attribute that is removed during compilation and used, only shows at design-time in Android Studio.

#### 2.2.2 Use the <include> Tag

#### 2.2.3 Use the <merge> Tag
1. The tag helps eliminate redundant view groups in view hierarchy when including one layout within another.
2. When you use <include> tag, the system ingnores the <merge> element.



### 2.3 Delayed Loading of views
1. Complex view rarely used.
2. Reduce memory usage and delay loading.
3. [ViewStub](https://developer.android.com/reference/android/view/ViewStub.html)

#### 2.3.1 Define a ViewStub
1. ViewStub is lightweight view, and simply needs `android:layout` to inflate.

#### 2.3.2 Load the ViewStub Layout
1. `findViewById(R.id.stub)` to setVisibility, inflate;
2. One drawback is it doesn't support <merge> tag.


### 2.4 Making ListView Scrolling Smooth
1. Smoothly scrolling `ListView`.
2. Keep UI thread free from heavy processing.
3. Any disk, network or SQL access in a separate thread.
4. [StrictMode](https://developer.android.com/reference/android/os/StrictMode.html) tests the status of apps.

#### 2.4.1 Use a Bg Thread
1. @WorkerThread
2. Using `AsyncTask`

#### 2.4.2 Hold View Objects in a View Holder 
1. Using `ViewHolder` avoids `findViewById` frequently.
2. A `ViewHolder` object stores views inside the tag field of the layout.



## 3 Optimizing Battery Life
1. Minimize power.
2. Perform power-hungry tasks at proper intervals.



### 3.1 Optimizing for Doze and App Standby

### 3.2 Monitoring the Battery Level and Charging State

### 3.3 Determining and Monitoring the Docking State and Type

### 3.4 Determining and Motnitoring the Connectivity Status


## 4 Sending Operations to Multiple Threads
1. Long-running operations by dispatching work to multiple threads.
2. The speed and efficiency of a long-running, data-intensive operations need to improve.
3. Split into smaller operations running on multiple threads.
4. A CPU with multiple processors(cores) makes the system running threads in parallel not waiting.
5. Use multiple threads and a thread pool object, conmmnunicate between UI thread and others.


### 4.1 Specifying the Code to Run on a Thread
1. Run a seperate [Thread](https://developer.android.com/reference/java/lang/Thread.html).
2. Implement the [Runnable](https://developer.android.com/reference/java/lang/Runnable.html) interface.
3. Runnable Object's thread passes a Runnable attaching another thread.
4. One or more Runnable objects that perform a particular operation are sometimes called a `task`.
5. Basic class: `HandlerThread, AsyncTask, IntentService`, `ThreadPoolExecutor`.

#### 4.1.1 Define a Class that Implements Runnable

#### 4.1.2 Implement the run() Method
1. Implement `Runnable.run()`, not directly modify UI objects.
2. At the begining of the `run()` method, set the thread bg priority by calling `Process.setThreadPriority()` with `THREAD_PRIORITY_BACKGROUND` to reduce res competition between the thread and UI thread.
3. `Thread.currentThread()` to store a reference in the `Runnable()` itself.

	```
	// Moves the current Thread into the background
    android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);
    ...
    /*
     * Stores the current Thread in the PhotoTask instance,
     * so that the instance
     * can interrupt the Thread.
     */
    mPhotoTask.setImageDecodeThread(Thread.currentThread());
	```

### 4.2 Creating a Manager for Multiple Threads
1. Manage a thread pool and a Runnable queue.
2. [ThreadPoolExecutor](https://developer.android.com/reference/java/util/concurrent/ThreadPoolExecutor.html)
3. `IntentService` run a task repeatly, but you only need one execution running at a time.
4. 'ThreadPoolExecutor' automatically run tasks, and run multiple tasks at the same time.
5. Access (static) variables need `thread-saft`, add `synchronized` block.

#### 4.2.1 Define the Thread Pool Class
1. Use static variables for thread pools，a signle static instance.
2. Private constructor ensures it is a singleton.
3. Start tasks `threadPool.execute();`
4. Init `handler` and implement `handleMessage()` to handle message.
	
	
#### 4.2.2 Determine the Thread Pool Parameters
1. Init pool and maximum pool size.
2. Keep alive time and time unit.
3. A queue of tasks， `LinkdBlockingQueue<Runnable>`.

#### 4.2.3 Create a Pool of Threads 
1. `new ThreadPoolExecutor(init pool size, max pool size, alive time, queue)`


### 4.3 Running Code on a Thread Pool Thread
1. Run a Runnable on a thread from the thread pool.
2. 

#### 4.3.1 Run a Task on a Thread in the Thread Pool
1. Start a task by `ThreadPoolExecutor.execute(Runnable）`

#### 4.3.2 Interrupt Running Code
1. Stop a task before, store a handle to the task's thread. `Thread.currentThread()`
2. Stop a task by calling `Thread.interrupt()`. Check the thread has been interrupted `Thread.interrupted()`.


### 4.4 Communicating with the UI Thread
1. Communicate from a thread in the thread pool to the UI thread.


#### 4.4.1 Define a Handler on the UI Thread
1. [Handler](https://developer.android.com/reference/android/os/Handler.html) is part of the Android system's framework for managing threads.
2. `new Handler(Looper)` is connected to a new thread, a existing thread, or UI thread.
3. [Looper](https://developer.android.com/reference/android/os/Looper.html) 
4. Override `handleMessage()`


#### 4.4.2 Move Data from a Task to the UI Thread
Move data from a bg thread to UI thread, and send a message containting the status to the `Handler`.

2. Store data in the task object
3. Send status up the object hierarchy
4. Move data to the UI, `Handler.obtanMessage(state)`, and `UIHandler` handle message.


## 5 Keeping Your app Responsive 
1. UI doesn't lock-up and ANR.
2. For significant periods, feel bad, and the worst thing is the system displays "Application Not Responding" (ANR) dialog.

### 5.1 What Triggers ANR?
1. App cannot respond to user input, then the system displays an ANR.
2. For example, on UI thread operate I/O or network access, database, spend too much time building or a big compitations such as resizing bitmaps, an asynchronous request.
3. Create a worker thread to do most of the work.
4. Application responsiveness is monitored by the ActivityManager and WindowManager system services.
	* Within 5s no response.
	* Within 10s a BroadcastReceiver hasn't finished executing.

### 5.2 How to Avoid ANRs
1. On UI Thread run as little work as possible. Activities set up in key lift-cycle methods `onCreate()` and `onResume()`.
2. The most effective way is that use the `AsyncTask` class ;
3. Use `Thread`, `HandlerThread` to "background" priority and do not call `Thread.wait()/sleep()`.

4. On `BroadcastReceiver`, constraint : small, discrete work in bg such as saving a setting or registering a `Notification`.
5. `IntentService` do intensive tasks, long running action.
6. Another common issue with `BroadcastReceiver` objects occurs when they execute too frequently.

### 5.3 Reinforce Responsiveness
1. The threshold beyond 100 ~ 200ms.
2. In bg do work, show the progress.
3. For games, do calculations for moves in worker thread.
4. A time-consuming initial setup phase, show a splash screen.
5. Use performace tools such as `Systrace` and `TraceView`.


## 6 JNI Tips
1. Use Java Native Interface with the Android NDK.



## 7 SMP Primer for Android
1. On symmetric multiprocessor systems.