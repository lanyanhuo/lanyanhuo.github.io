---
layout: post
title: 设计模式 
category: Java
tags: [Java]
---

# 设计模式


## 一 单例模式

### 1. 常用
```
public class Singleton {
    private static Singleton singleton;
    private Singleton() {}

    public static Singleton getInstance() {
        if (singleton == null) {
            singleton = new Singleton();
        }
        return singleton;
    }
}
```

### 2. 线程安全
```
public class Singleton {
    private static volatile Singleton singleton;
    private Singleton() {}

    public synchronized static Singleton getInstance() {
    	if (synchronized) {
	        if (singleton == null) {
	            singleton = new Singleton();
	        }
        }
        return singleton;
    }
}
```


## 二 观察者模式

### 1. Java的观察者模式
1. Observer 只有一个update，当监听的数据发生变化时被调用
2. Observable add/remove/notify观察者 

### 2. 自定义
1.	分为2部分 
	* 观察者`interface Observer<T>，copy java.util.Observer update`,当Observable有变化时调用update。
  	* 被观察者`Observable<T> add/remove/notifyObservers`等
  	* 实现过程
  		
  		```
  		Observable<Datas> datasObservable = new Observable<>();
  		public Observable getDatasChanged() {return datasObservable;}
  		datasObservable.notifyObservers(new Datas());
  		```
2.	与数据源相关的观察者：
	* `interface DataObserver添加 onNext, onError`
	* 被观察者`Observable<T> next/error  register/unregister观察者`
	* 实现过程
	
		```
		class YourDataTrackerToUpdataMyData extends DataObservable<MyData> implements DataObserver<YourData> {
	
		    @Override
		    public void onNext(DataObservable<YourData> observable, @NonNull YourData yourData) {
		        next(new MyData("MyData"));
		    }
		
		    @Override
		    public void onError(DataObservable<YourData> observable, Throwable throwable) {
		    }
	}
		```

### 3. Javax


## 三 装饰者模式
1. `new A(new B(new C("C")));`一层层封装,类似于汉堡。


## 四 适配器模式
1. 将不同事物联系在一起，如变压器。

```
test() {
	Phone phone = new Phone();
	phone.setAdatper(new PhoneAdapter);
	phone.charge();
}
class Phone {
	private PhoneAdapter adapter;
	public void setAdapter(PhoneAdapter adapter) {
		this.adapter = adapter;
	}
	
	public void charge() {
		adapter.change();
	}
}

class PhoneAdapter {
	public void change() {
		Log.d(TAG, "This is PhoneAdapter changing.");
	}
}
```

## 五 工厂模式
1. 1个abstract class， 
2. N个impl classes, 1个Factory用来实例化abstract的接口。
3. 四个角色：抽象工厂模式，具体工厂模式，抽象产品模式，具体产品模式。

