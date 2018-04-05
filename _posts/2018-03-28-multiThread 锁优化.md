---
layout: post
title: MultiThread 锁优化[转]
category: Java
tags: [Java]
---

并发环境下进行编程时，需要使用锁机制来同步多线程间的操作，保证共享资源的互斥访问。加锁会带来性能上的损坏，似乎是众所周知的事情。然而，加锁本身不会带来多少的性能消耗，性能主要是在线程的获取锁的过程。如果只有一个线程竞争锁，此时并不存在多线程竞争的情况，那么JVM会进行优化，那么这时加锁带来的性能消耗基本可以忽略。因此，规范加锁的操作，优化锁的使用方法，避免不必要的线程竞争，不仅可以提高程序性能，也能避免不规范加锁可能造成线程死锁问题，提高程序健壮性。下面阐述几种锁优化的思路。

## 一 尽量不要锁住方法
在普通成员函数上加锁时，线程获得的是该方法所在对象的对象锁。此时整个对象都会被锁住。这也意味着，如果这个对象提供的多个同步方法是针对不同业务的，那么由于整个对象被锁住，一个业务业务在处理时，其他不相关的业务线程也必须wait。下面的例子展示了这种情况：

LockMethod类包含两个同步方法，分别在两种业务处理中被调用：

```
public class LockMethod   {
    public synchronized void busiA() {
        for (int i = 0; i < 10000; i++) {
            System.out.println(Thread.currentThread().getName() + "deal with bussiness A:"+i);
        }
    }
    public synchronized void busiB() {
        for (int i = 0; i < 10000; i++) {
            System.out.println(Thread.currentThread().getName() + "deal with bussiness B:"+i);
        }
    }
}
```

BUSSA是线程类，用来处理A业务，调用的是LockMethod的busiA（）方法：

```
public class BUSSA extends Thread {
    LockMethod lockMethod;
    void deal(LockMethod lockMethod){
        this.lockMethod = lockMethod;
    }
 
    @Override
    public void run() {
        super.run();
        lockMethod.busiA();
    }
}
```

BUSSB是线程类，用来处理B业务，调用的是LockMethod的busiB（）方法：

```
public class BUSSB extends Thread {
    LockMethod lockMethod;
    void deal(LockMethod lockMethod){
        this.lockMethod = lockMethod;
    }
 
    @Override
    public void run() {
        super.run();
        lockMethod.busiB();
    }
}
```

TestLockMethod类，使用线程BUSSA与BUSSB进行业务处理：

```
public class TestLockMethod extends Thread {
 
    public static void main(String[] args) {
        LockMethod lockMethod = new LockMethod();
        BUSSA bussa = new BUSSA();
        BUSSB bussb = new BUSSB();
        bussa.deal(lockMethod);
        bussb.deal(lockMethod);
        bussa.start();
        bussb.start();
 
    }
}
```

运行程序，可以看到在线程bussa 执行的过程中，bussb是不能够进入函数 busiB()的，因为此时lockMethod 的对象锁被线程bussa获取了。

## 二 缩小同步代码块，只锁数据
有时候为了编程方便，有些人会synchnoized很大的一块代码，如果这个代码块中的某些操作与共享资源并不相关，那么应当把它们放到同步块外部，避免长时间的持有锁，造成其他线程一直处于等待状态。尤其是一些循环操作、同步I/O操作。不止是在代码的行数范围上缩小同步块，在执行逻辑上，也应该缩小同步块，例如多加一些条件判断，符合条件的再进行同步，而不是同步之后再进行条件判断，尽量减少不必要的进入同步块的逻辑。

## 三 锁中尽量不要再包含锁
这种情况经常发生，线程在得到了A锁之后，在同步方法块中调用了另外对象的同步方法，获得了第二个锁，这样可能导致一个调用堆栈中有多把锁的请求，多线程情况下可能会出现很复杂、难以分析的异常情况，导致死锁的发生。下面的代码显示了这种情况：

```
synchronized(A){
 
   synchronized(B){
   
      }  
}
或是在同步块中调用了同步方法：
synchronized(A){
 
    B  b = objArrayList.get(0);
    b.method(); //这是一个同步方法
}
解决的办法是跳出来加锁，不要包含加锁：
{
     B b = null;
    
 synchronized(A){
    b = objArrayList.get(0);
  }
  b.method();
}
```

## 四 将锁私有化，在内部管理锁
把锁作为一个私有的对象，外部不能拿到这个对象，更安全一些。对象可能被其他线程直接进行加锁操作，此时线程便持有了该对象的对象锁，例如下面这种情况：

```
class A {
    public void method1() {
    }
}
 
class B {
    public void method1() {
        A a = new A();
        synchronized (a) { //直接进行加锁
　　　　　　a.method1();
 
        }
    }
}
```

这种使用方式下，对象a的对象锁被外部所持有，让这把锁在外部多个地方被使用是比较危险的，对代码的逻辑流程阅读也造成困扰。一种更好的方式是在类的内部自己管理锁，外部需要同步方案时，也是通过接口方式来提供同步操作：

```
class A {
    private Object lock = new Object();
    public void method1() {
        synchronized (lock){
             
        }
    }
}
 
class B {
    public void method1() {
        A a = new A();
        a.method1();
    }
}
```

## 五 进行适当的锁分解
考虑下面这段程序：

```
public class GameServer {
  public Map<String, List<Player>> tables = new HashMap<String, List<Player>>();
 
  public void join(Player player, Table table) {
    if (player.getAccountBalance() > table.getLimit()) {
      synchronized (tables) {
        List<Player> tablePlayers = tables.get(table.getId());
        if (tablePlayers.size() < 9) {
          tablePlayers.add(player);
        }
      }
    }
  }
  public void leave(Player player, Table table) {/*省略*/} 
  public void createTable() {/*省略*/} 
  public void destroyTable(Table table) {/*省略*/}
}
```

在这个例子中，join方法只使用一个同步锁，来获取tables中的List<Player>对象，然后判断玩家数量是不是小于9，如果是，就调增加一个玩家。当有成千上万个List<Player>存在tables中时，对tables锁的竞争将非常激烈。在这里，我们可以考虑进行锁的分解：快速取出数据之后，对List<Player>对象进行加锁，让其他线程可快速竞争获得tables对象锁：

```
public class GameServer {
  public Map<String, List<Player>> tables = new HashMap<String, List<Player>>();
 
  public void join(Player player, Table table) {
    if (player.getAccountBalance() > table.getLimit()) {
      List<Player> tablePlayers = null;
      synchronized (tables) {
          tablePlayers = tables.get(table.getId());
      }
       
      synchronized (tablePlayers) {
        if (tablePlayers.size() < 9) {
          tablePlayers.add(player);
        }
      }
    }
  }
 
 public void leave(Player player, Table table) {/*省略*/} 
 public void createTable() {/*省略*/} 
 public void destroyTable(Table table) {/*省略*/}
}
```

转自

![Java 多线程编程—锁优化](http://www.importnew.com/27935.html)
