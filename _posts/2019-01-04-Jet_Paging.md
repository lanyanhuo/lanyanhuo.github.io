---
layout: post
title: Jet_Paging
category: Android
tags: [Android]
---

## Jetpack Paging

1. 优雅加载RecyclerView
2. 帮助应用观察并显示数据源中的部分数据。
	* 数据请求消耗的网络带宽更少，系统资源更少。
	* 即使在数据更新期间，应用仍会继续快速响应用户输入。


### 1. Paging架构
1. 关键是`PageList`,异步加载应用数据的。
2. 数据：`DataSource`,数据从后端或数据库流入到PageList对象。
3. UI：`PagedList`与`PagedListAdapter`中的数据放入到同一个`RecyclerView`。
4. 使用`LiveData<PagedList>`

### 2. 支持不同的数据架构
1. `Only NetWork`: 使用`Retrofit API`加载数据到`DataSource`对象中。
   * 网络数据分页加载，常用3种不同方案：`PositionalDataSource、PageKeyedDataSource和ItemKeyedDataSource`
2. `Only DB`：使用`Room`
3. `Network和DB`：
  * 在开始观察数据库之后，通过使用来监听数据库何时没有数据 `PagedList.BoundaryCallback`。
  * 然后，从网络中获取更多项目并将其插入数据库。

```
class ConcerViewModel {
	fun search(query: String): ConcertSearchResult {
		val boundaryCallback = ConcertBoundarCallback(query, myService, myCache)
	}
}

class ConcertBoundaryCallback(private val query: String, private val service: MyService, private val cache: MyLocalCache): PagedList.BoundaryCallback<Concert>() {
	// 网络请求初始化数据，替换掉DB中的数据
	override fun onZeroItemLoaded() {
		requestAndReplaceInitialData(query)
	}
	// 网络请求额外数据，添加到DB中
	override fun onItemAtEndLoaded(itemAtEnd: Concert) {
		requestAndAppendData(query, itemAtEnd.key)
	}
}
```

### 3. 处理网络错误
1. 间歇性的网络请求，自动重试

### 4. 更新现有应用

#### 4.1 定制Paging解决方案

#### 4.2 使用List而不是Paging加载数据

#### 4.3 Data cursor与List结合使用CursorAdapter


#### 4.4 使用AsyncListUtil异步加载

### 5. demo
1. [PagingWithNetwork](https://github.com/googlesamples/android-architecture-components/tree/master/PagingWithNetworkSample)了解Paging Library如何与后端API配合使用。
2. [Paginigcodelab](https://codelabs.developers.google.com/codelabs/android-paging/index.html)逐步了解如何将Paging Library添加到应用程序。



## [Paging 解析](https://juejin.im/post/5db06bb6518825646d79070b)

1. 思维导图不错，简洁明了

![img](https://mmbiz.qpic.cn/mmbiz_png/v1LbPPWiaSt4Jwbb1IaZwyibffKERwSuoVx7lPqKliahklic8IyrjAX2ib8ZOvywLUOAqE5Jc0je419mG28TII5XbmA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

2. 具体步骤

   * 1.在RecyclerView的滑动过程中，会触发PagedListAdapter类中的onBindViewHolder()方法。数据与RecycleView Item布局中的UI控件正是在该方法中进行绑定的。
   * 2.当RecyclerView滑动到底部时，在onBindViewHolder()方法中所调用的getItem()方法会通知PagedList，当前需要载入更多数据。
   * 3.接着，PagedList会根据PageList.Config中的配置通知DataSource执行具体的数据获取工作。
   * 4.DataSource从网络/本地数据库取得数据后，交给PagedList，PagedList将持有这些数据。
   * 5.PagedList将数据交给PagedListAdapter中的DiffUtil进行比对和处理。
   * 6.数据在经过处理后，交由RecyclerView进行展示。

   ![](https://raw.githubusercontent.com/rlq/image/master/android/paging.png)

3. BoundaryCallback

   ![](https://raw.githubusercontent.com/rlq/image/master/android/20200916090912.png)

### 1. 3种DataSource

1. `PositionalDataSource:` start=2&count=5，请求第2条数据开始往后的5条数据
2. `PageKeyedDataSource: `page=2&pageSize=5，5条数据为一页，当前返回第二页的5条数据
3. `ItemKeyedDataSource：`since=9527&pageSize=5，返回key=9527之后的5条数据

