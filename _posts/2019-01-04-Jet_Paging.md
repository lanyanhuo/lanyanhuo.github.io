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
1. [PageingWithNetwork](https://github.com/googlesamples/android-architecture-components/tree/master/PagingWithNetworkSample)了解Paging Library如何与后端API配合使用。
2. [Paginigcodelab](https://codelabs.developers.google.com/codelabs/android-paging/index.html)逐步了解如何将Paging Library添加到应用程序。

