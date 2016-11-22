---
layout: post
title: 架构 
category: Android
tags: [Architeture]
---

翻译[Android开发使用的架构模式的详细指南](https://medium.com/@dmilicic/a-detailed-guide-on-developing-android-apps-using-the-clean-architecture-pattern-d38d71e94029#.f0pg5top3)

自从我开发Android App以来就有这种可以完成得更好的感觉。在我工作期间我见过很多不好的软件设计思路，一些是我自己设计的，Android系统的复杂性和糟糕的软件设计的是一个灾难。但重要的是要从错误中吸取教训，不断完善。寻找更多的方式来开发App后，我遇到了Clean Architecture。运用到Android后，随着类似项目的细化和灵感，我认为这种方法是可行的，值得分享。

本文的目的是提供一个在干净的环境下开发Android App的逐步指南。这整个方案是我如何在最近的项目中为永华成功地创建App。

## 什么是Clean Architecture

我没有太多的细节有篇文章解释的比我能做的更好。但接下来的段落提供一个你需要了解的Clean的图。
对于一般Clean，代码是层层分离的，**依赖规则**：内层不知道外层的任何事情，这意味着应该是点向内的依赖关系。
这是前面的可视化：
![]()
* framework的独立性。架构并不依赖已经存在的某些库的有负载的特性。这允许你作为工具去使用框架，而不是把你的系统强塞到限制和约束中。
* 可测试性。业务规则可以脱离UI、数据库、web服务器和其他外部元素去进行测试。
* UI的独立性。UI可以在不修改系统其他地方的情况下很容易地被改变。比如：一个Web UI可以使用console UI替换，而不改变任何业务规则。
* 数据库的依赖。可以使用Mongo、BitTable、CouchDB或者其他来替换Oracle或者SQL Server。你的业务规则不会被数据库束缚。
* 任何代理的独立性。事实上，你的业务规则根本不知道外面的世界。

我希望在以下的例子中你能够理解这些点是如何实现的。对于Clean的详细介绍，我推荐[这篇文章(译文)](http://www.cnblogs.com/tiantianbyconan/p/5276587.html)----[原文](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html)和[这个视频](https://vimeo.com/43612849)

### 对Android而言这意味着什么

总的来说，一个App可以有任何数量的层，但是除非你有企业范围内的逻辑，你必须适用于每一个App，你会经常有3个层：
* 外层： 实现层
* 中层： 接口适配层
* 内层： 业务逻辑层

实现层是所有框架具体发生的地方。Framework具体的代码包括每一行代码都是你需要实现但却没有实现的，包括所有Android之类的像Activity，fragment，发送Intent，另外的framework像网络请求，数据库等。

接口适配器是最重要的层。在这里创建app时需要实际上解决你想解决的问题，这个层不包括任何framework具体代码，**在没有任何模拟器的情况下也可以运行**。你可以有你自己的业务逻辑代码**便于测试，开发和维护**。这是Clean Architecture的主要好处。

在核心层之上的每一层还负责转换为底层模型，在较低的层可以使用它们。内层不能调用属于外层模型的类。然而外层可以使用内层类。这是由于我们的**依赖规则**。它创建了开销，但必须确保代码层的解耦。

> **为什么模型的转换是这么必要呢？** 比如，我们的业务逻辑模型可能不会直接很合适的展示给用户。也许你需要展示多个业务逻辑模型的组合。因此我建议你创建一个View模型可以让它更加容易为你显示UI。这样你在内层就需要一个转换类去转换业务逻辑到合适的view模型。

> 另一个例子可能是这样的：在外层数据库中你从**ContentProvider**得到一个*Cursor*对象。首先外层将会把它转换到内层的业务逻辑模型，然后发送给你的业务逻辑层去处理。

我将在文章底部添加更多的学习资料。现在我们了解了`Clean Architecture`的基本原则，让我们开始着手写一个实际的代码把。我将会在下一段落给你展示如何创建一个使用Clean的功能的例子。

## 如何开始写Clean App？
我做了一个[模板工程](https://github.com/dmilicic/Android-Clean-Boilerplate)，所有的管道都是为你而写。它是**Clean started pack**,从一开始就直接用最常见的工具设计去创建的。你可以免费下载，修改，用它去创建你自己的apps。

你可以在这里找到开始的工程：[Android Clean Boilerplate](https://github.com/dmilicic/Android-Clean-Boilerplate).

## 开始编写一个新的用例
这一段介绍为创建一个使用Clean的新的用例在前一节中提供的样板而需要的所有代码。一个用例仅仅是这个app的一些功能的结合。也可能是(用户的点击事件)或者可能不是被用户启动的。

首先我们来介绍这种方法的结构和术语。如何创建app，但不是一成不变的，如果你想要你可以有不同地组织。

### 结构
Android app普通的结构是这样的：
* 外层： UI，Storage， NetWork等等.
* 中层： Presenters, Converters.
* 内层： Interactors, Models, Repositie]ries, Exectutor.

### Outer layer
正如之前所说，这是framework细节所去的地方。

* UI --你放所有Activity， Fragment， Adapter和其他与用户相关的Android代码的地方。
* Storage --数据库指定的代码
Storage — Database specific code that implements the interface our Interactors use for accessing data and storing data. This includes, for example, ContentProviders or ORM-s such as DBFlow.
Network — Things like Retrofit go here.
Middle layer
Glue code layer which connects the implementation details with your business logic.
Presenters — Presenters handle events from the UI (e.g. user click) and usually serve as callbacks from inner layers (Interactors).
Converters — Converter objects are responsible for converting inner models to outer models and vice versa.
Inner layer
The core layer contains the most high-level code. All classes here are POJOs. Classes and objects in this layer have no knowledge that they are run in an Android app and can easily be ported to any machine running JVM.
Interactors — These are the classes which actually contain your business logic code. These are run in the background and communicate events to the upper layer using callbacks. They are also called UseCases in some projects (probably a better name). It is normal to have a lot of small Interactor classes in your projects that solve specific problems. This conforms to the Single Responsibility Principle and in my opinion is easier on the brain.
Models — These are your business models that you manipulate in your business logic.
Repositories — This package only contains interfaces that the database or some other outer layer implements. These interfaces are used by Interactors to access and store data. This is also called a repository pattern.
Executor — This package contains code for making Interactors run in the background by using a worker thread executor. This package is generally not something you need to change.

### 一个简单的例子
在这个例子中，我们的用例将会：**“当app启动时迎接用户是一个存储在数据库中的信息。”**这个例子将展示怎样编写以下三个所需要的包才能是测试用例工作：
* presentation
* storage
* domain

前两个属于外层，最后一个是属于内层/核心层。

**Presentation**负责一切有关在屏幕上显示的东西--包括整个MVP(意味着包括UI和Presenter尽管它们属于不同的层)。
好--少说多做。

#### 编写一个新的交互（内层/核心层） 
事实上你可以在架构的任何一层开始，但我建议首先你应该开始于核心业务逻。你可以编写，测试，确保可以在没有创建Activity的情况下工作。

所以让我们首先创建一个交互。这个交互是用例的主逻辑所在。**所有的交互都运行在后台线程，所以不应该有任何对UI性能的影响。**让我们用一个好的名称`WelcomingInteractor`开始创建一个新的交互吧。

```
public interface WelcomingInteractor extends Interactor {
	interface Callback {
		void onMessafeTetrieved(String message);
		void inRetrievalFailed(String error);
	}
}
```

`Callback`负责在主线程中与UI交互，我们把它放在Interactor的interface所以我们必须把它命名为WelcomingInteractorCallback --为了与别的Callback区分。现在我们来实现得到信息的逻辑。我们有一个**MessageRepository**可提供给我们欢迎信息。

```
public interface MessageResository {
	String getWelcomeMessage();
}
```
现在我们实现业务逻辑的Interactor接口。**这个实现是继承自关心后台线程运行的AbstractInteractor。**

```
public class WelcomingInteractorImpl extends AbstractInteractor implements WelcomingInteractor {
 
    ...
    
    private void notifyError() {
        mMainThread.post(new Runnable() {
            @Override
            public void run() {
                mCallback.onRetrievalFailed("Nothing to welcome you with :(");
            }
        });
    }

    private void postMessage(final String msg) {
        mMainThread.post(new Runnable() {
            @Override
            public void run() {
                mCallback.onMessageRetrieved(msg);
            }
        });
    }

    @Override
    public void run() {
        // retrieve the message
        final String message = mMessageRepository.getWelcomeMessage();
        // check if we have failed to retrieve our message
        if (message == null || message.length() == 0) {

            // notify the failure on the main thread
            notifyError();

            return;
        }
        // we have retrieved our message, notify the UI on the main thread
        postMessage(message);
    }
```
这仅仅是试着接收和发送消息，还有把错误在UI上显示。我注意到使用Callback的UI实际上变成了Presenter。**这是业务逻辑的关键，我们需要做的都要依赖framework。**

看下Interactor依赖的包：

```
import com.kodelabs.boilerplate.domain.executor.Executor;
import com.kodelabs.boilerplate.domain.executor.MainThread;
import com.kodelabs.boilerplate.domain.interactors.WelcomingInteractor;
import com.kodelabs.boilerplate.domain.interactors.base.AbstractInteractor;
import com.kodelabs.boilerplate.domain.repository.MessageRepository;
```
正如你所看到的，没有提到任何Android代码。这是这种方法主要优点。你可以看到拥有独立的框架。你不需要关心UI或者数据库的细节，我们只是调用了接口方法，有人在外层实现。因此我们独立的UI和数据库。












