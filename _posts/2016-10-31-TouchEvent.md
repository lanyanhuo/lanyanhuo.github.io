---
layout: post
title: DispatchTouchEvent 
category: Android
tags: [Android]
---

## 一  DispatchTouchEvent

我们常常会遇到这样的需求：在Android的某个UI中，向上滑动打开A View， 向下滑动会打开B View，而左右滑动会使ViewPager滑动。这个应该是比较简单的需求。
还有就是在RecycleView中有ItemView需要左右滑动，能够删除该ItemView。

类似这样的情况，需要使用DispatchTouchEvent。我举例述说。

以下是各个View个职责：

1. 首先我有一个ActionView, 处理滑动事件，只会对各种状态设置监听；
2. 上滑打开UpView；下滑打开DownView；长按显示CloseView 即为mask；
3. 而当前是Activity，由各种View组成，只是Viewpager可见，并可以左右滑动。
4. 当然每个View都有自己对应的一些点击事件。

#### 所有View的状态

```
public enum DispatchStatus {
    ViewPager,
    Up,
    Down,
    Close,
}
```
#### ActionView
设置 ` void setDispatchListener(DispatchStatus status, boolean isShow); ` 会判断当前触发响应的是哪个从而作出显示。

```
	private static final int LONG_TOUCH_TIME = 1000;
    private static final int ORIENTATION_LEFTRIGHT = 1;
    private static final int ORIENTATION_UPDOWN = 2;
    private float mDownX;
    private float mDownY;
    private long mLastTouchTime;
    private int mOrientationId = 0;
    private float mTouchSlop = 240;
    private View mMask;

	@Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (mMask.getVisibility() != VISIBLE) {
            final float currentX = ev.getX();
            final float currentY = ev.getY();
            switch (ev.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    mDownX = ev.getX();
                    mDownY = ev.getY();
                    if (findViewById(R.id.dispatch_upview).getVisibility() != VISIBLE
                            && findViewById(R.id.dispatch_downview).getVisibility() != VISIBLE) {
                            mDispatchListener.setDispatchListener(DispatchStatus.ViewPager, true);//在Up/Down/Close 这些View都不显示时，ViewPager可以滑动
                    } else {
   		                    mDispatchListener.setDispatchListener(DispatchStatus.ViewPager, false);
                    }
                    mLastTouchTime = System.currentTimeMillis();
                    break;
                case MotionEvent.ACTION_UP:
                    if (mOrientationId == ORIENTATION_LEFTRIGHT) {
		               mDispatchListener.setDispatchListener(DispatchStatus.ViewPager, true);//左右滑动，ViewPager做出响应
 } else if (mOrientationId == ORIENTATION_UPDOWN) {
                        if (currentY - mDownY <= mTouchSlop) {
 				             mDispatchListener.setDispatchListener(DispatchStatus.Up, true);
 } else if (currentY - mDownY > mTouchSlop){               
 			                 mDispatchListener.setDispatchListener(DispatchStatus.Down, true);
                        }
                    } else if (System.currentTimeMillis() - mLastTouchTime > LONG_TOUCH_TIME) {
                        mMask.setVisibility(View.VISIBLE);
                        mDispatchListener.setDispatchListener(DispatchStatus.Close, false);
                    }
                    mOrientationId = 0;
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (mOrientationId == 0) {
                        if (Math.abs(currentX - mDownX) > Math.abs(currentY - mDownY) 
                        && Math.abs(currentX - mDownX) > mTouchSlop) {
                            mOrientationId = ORIENTATION_LEFTRIGHT;
                        } else if (Math.abs(currentX - mDownX) < Math.abs(currentY - mDownY)
                        && Math.abs(currentY - mDownY) > mTouchSlop) {
                            mOrientationId = ORIENTATION_UPDOWN;
                        }
                    }
                    break;
                case MotionEvent.ACTION_CANCEL:
                    mOrientationId = 0;
                    break;
            }
        }
        return super.dispatchTouchEvent(ev);
    }
```

#### UpView or DownView
让ActionView一起处理TouchEvent，只需

```
   @Override
    public boolean onTouchEvent(MotionEvent event) {
        return true;
    }
```

#### Activity
`setContentView(new ActionView(this)); `

将ViewPager的onTouchEvent去做判断，需要滚动时就去响应

```
@Override
    public boolean onTouchEvent(MotionEvent event) {
        if (mIsScroll) {
            mViewPager.onTouchEvent(event);
            return super.onTouchEvent(event);
        } else {
            return true;
        }
    }
    
    设置监听事件
    mActionView.setDispatchListener(new DispatchActionListener() {
            @Override
            public void setDispatchListener(DispatchStatus status, boolean isShow) {
                handleActionEvent(status, isShow);
            }
        });
        
        private void handleActionEvent(DispatchStatus status, boolean isShow) {
        switch (status) {
            case ViewPager:
                mIsScroll = isShow;
                mUpView.setVisibility(View.GONE);
                mDownView.setVisibility(View.GONE);
                break;
            case Up:
                if (mDownView.getVisibility() == View.VISIBLE) {
                    mDownView.setVisibility(View.GONE);
                } else if (mUpView.getVisibility() != View.VISIBLE) {
                    mUpView.setVisibility(View.VISIBLE);
                }
                break;
            case Down:
                if (mUpView.getVisibility() == View.VISIBLE) {
                    mUpView.setVisibility(View.GONE);
                } else if (mDownView.getVisibility() != View.VISIBLE) {
                    mDownView.setVisibility(View.VISIBLE);
                }
                break;
            case Close:
                finish();
                break;
        }
    }
```


#### 源码[here](http://blog.csdn.net/skyflying2012/article/details/23742683).

## 二

从简单一定的理论入手
Android的touch事件主要包括点击onClick，长按onLongClick，拖拽onDrag，滑动onScroll等
点击又包括单击，双击，单指操作和多指操作。
ActionEvent包括许多状态ACTION_DOWN(按下), ACTION_UP(抬起), ACTION_MOVE(移动), ACTION_CABCEL(取消), ACTION_OUTSIDE(滑出屏幕。而Touch的第一个状态是ACTION_DOWN,别的状态都是以此为前提。

举个简单例子：一个Activity中只有一个Button,我们注册一个点击事件和一个触发事件，如下：

```
Button button = (Button) findViewById(R.id.button);
button.setOnClickListener(new OnClickListener() {  
    @Override  
    public void onClick(View v) {  
        Log.d("HEHE", "onClicked");  
    }  
}); 

button.setOnTouchListener(new OnTouchListener() {  
    @Override  
    public boolean onTouch(View v, MotionEvent event) {  
        Log.d("HEHE", "onTouched, action is " + event.getAction());  
        return false;  
    }  
});

```
onTouch 返回了false，执行结果：

```
  onTouched, action is 0
  onTouched, action is 1
  onClicked
```
onTouch若返回true，执行结果如下，此时onClike不再执行，可以理解为这个事件已经被消费了，因此没有继续向下传递。

```
  onTouched, action is 0
  onTouched, action is 1
```
此时我们需要了解，是谁将这些事件进行分发的，我们会想到dispatchTouchEvent。然后在Button以及其父类TextView都没有发现这个方法，直到在View中找到了它。

Dispatch Method：
1. `public boolean dispatchTouchEvent(MotionEvent ev)` 该方法是用来进行事件分发的。如果事件能够传递给当前的View，则此方法被调用，返回结果受到当前View的onTouchEvent和下级dispatchTouchEvent的影响，表示是否消耗当前事件。
2. 	`public boolean onInterceptTouchEvent(MotionEvent event)` 该方法是ViewGroup提供的方法，用来判断是够拦截某个事件，如果当前View拦截了某个事件，那么在已同一个事件序列中，此方法不会被再次调用，返回结果表示是否拦截当前事件。默认返回false，true表示拦截。
3. `public boolean onTouchEvent(MotionEvent event)` 该方法在dispatchTouchEvent方法中调用，用来处理点击事件，返回结果表示是否消耗当前事件，如果不消耗，则在同一事件序列中，当前View无法再次接受事件。view中默认返回true,表示消耗了这次事件。


