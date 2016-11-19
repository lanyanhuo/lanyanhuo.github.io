---
layout: post
title: 架构 
category: Android
tags: [Architeture]
---

翻译[Android开发使用的架构模式的详细指南](https://medium.com/@dmilicic/a-detailed-guide-on-developing-android-apps-using-the-clean-architecture-pattern-d38d71e94029#.f0pg5top3)

自从我开发Android App以来就有这种可以完成得更好的感觉。在我工作期间我见过很多不好的软件设计思路，一些是我自己设计的，Android系统的复杂性和糟糕的软件设计的是一个灾难。但重要的是要从错误中吸取教训，不断完善。寻找更多的方式来开发App后，我遇到了Clean Architecture。运用到Android后，随着类似项目的细化和灵感，我认为这种方法是可行的，值得分享。

本文的目的是提供一个在干净的环境下开发Android App的逐步指南。这整个方案是我如何在最近的项目中为永华成功地创建App。

什么是Clean Architecture

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

对Android而言这意味着什么

总的来说，一个App可以有任何数量的层，但是除非你有企业范围内的逻辑，你必须适用于每一个App，你会经常有3个层：
* 外层： 实现层
* 中层： 接口适配层
* 内层： 业务逻辑层

实现层是所有框架具体发生的地方。Framework具体的代码包括每一行代码都是你需要实现但却没有实现的，包括所有Android之类的像Activity，fragment，发送Intent，另外的framework像网络请求，数据库等。

接口适配器是最重要的层。在这里创建app时需要实际上解决你想解决的问题，这个层不包括任何framework具体代码，**在没有任何模拟器的情况下也可以运行**。你可以有你自己的业务逻辑代码**便于测试，开发和维护**。这是Clean Architecture的主要好处。

在核心层之上的每一层还负责转换为底层模型，在较低的层可以使用它们。内层不能调用属于外层模型的类。然而外层可以使用内层类。这是由于我们的**依赖规则**。它创建了开销，但必须确保代码层的解耦。


> **Why is this model conversion necessary?** For example, your business logic models might not be appropriate for showing them to the user directly. Perhaps you need to show a combination of multiple business logic models at once. Therefore, I suggest you create a ViewModel class that makes it easier for you to display it to the UI. Then, you use a converter class in the outer layer to convert your business models to the appropriate ViewModel.
Another example might be the following: Let’s say you get a `Cursor` object from a `ContentProvider` in an outer database layer. Then the outer layer would convert it to your inner business model first, and then send it to your business logic layer to be processed.

I will add more resources to learn from at the bottom of the article. Now that we know about the basic principles of the Clean Architecture, let’s get our hands dirty with some actual code. I will show you how to build an example functionality using Clean in the next section.

如何开始写Clean App？
我做了一个[模板工程](https://github.com/dmilicic/Android-Clean-Boilerplate)，所有的管道都是为你而写。



















