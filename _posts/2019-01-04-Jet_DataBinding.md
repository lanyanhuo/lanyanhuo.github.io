---
layout: post
title: Jet_DataBinding
category: Android
tags: [Android]
---

## [Jetpack DataBinding](https://developer.android.com/topic/libraries/data-binding/expressions)


### 1. 前期工作

#### 1.1 建立环境
```
android {
    ...
    dataBinding {
        enabled = true
    }
}
```
#### 1.3 AS支持DataBinding

#### 1.4 DataBinding编译器
1. 在`gradle.properties`中添加`android.databinding.enableV2=true`
2. 通过gradle命令启用编译器 `gradle -Pandroid.databinding.enableV2=true`


### 2. 布局和绑定表达式
#### 2.1 layout —— activity_main.layout
```
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">
   <data>
       <variable name="user" type="com.xxx.User"/>
		<import type="android.util.SparseArray"/>
		<variable name="sparse" type="SparseArray<String>"/>
		
   </data>
   <LinearLayout
       android:orientation="vertical"
       android:layout_width="match_parent"
       android:layout_height="match_parent">
       <TextView android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="@{user.firstName}"/>
       <TextView android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="@{sparse[index]}"/>
   </LinearLayout>
</layout>
```

#### 2.2 数据对象
`data class User(val firstName: String, val lastName: String)`

#### 2.3 绑定数据
1. 编译后生成`ActivityMainBinding `
2. 在`MainActivity`中绑定

	```
	val binding: ActivityMainBinding = DataBindingUtil.setContentView(
            this, R.layout.activity_main)
    binding.user = User("Test", "User")
	```
3. 在`Fragment/View/Adapter`等绑定

	```
	val listItemBinding = ListItemBinding.inflate(layoutInflater, viewGroup, false)
   或者
	val listItemBinding = DataBindingUtil.inflate(layoutInflater, R.layout.list_item, viewGroup, false)
	```
#### 2.4 表达式
```
Mathematical + - / * %  <——>  android:text="@{String.valueOf(index + 1)}"
String concatenation +  <——> android:transitionName='@{"image_" + id}'
Logical && ||
Binary & | ^  
Unary + - ! ~ 
Shift >> >>> << 
Comparison == > < >= <=	 
instanceof 
Grouping ()
Literals - character, String, numeric, null	——> android:text="@{user.displayName ?? user.lastName}"
Cast
Method calls
Field access	
Array access [] 
Ternary operator ?:	——> android:visibility="@{age < 13 ? View.GONE : View.VISIBLE}"
res <——> android:padding="@{large? @dimen/largePadding : @dimen/smallPadding}"
```

#### 2.5 方法调用
1. User类中定义点击事件处理方法 `fun onClickUser(view: View) { ... }`
2. 调用 `android:onClick="@{User::onClickUser}"`
3. CallBack类中定义事件回调 `fun onSaveClick(view: View, user: User){}`
4. 调用

	```
	<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">
    <data>
        <variable name="user" type="com.xxx.User" />
        <variable name="callback" type="com.xxx.CallBack" />
    </data>
    <LinearLayout android:layout_width="match_parent" android:layout_height="match_parent">
        <Button android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:onClick="@{(theView) -> callback.onSaveClick(theView, user)}" />
    </LinearLayout>
</layout>
	```

### 3. 使用可观察Observable的数据对象

#### 3.1 可观察字段
1. 类中定义可观察的字段
	
	```
	class User {
	    val firstName = ObservableField<String>()
	    val lastName = ObservableField<String>()
	    val age = ObservableInt()
	}
	```
2. 使用这些字段 `user.firstName = "Google"  val age = user.age`

#### 3.2 可观察集合
1. 定义可观察集合

	```
	ObservableArrayMap<String, Any>().apply {
	    put("firstName", "Google")
	    put("lastName", "Inc.")
	    put("age", 17)
	}
	```
2. 调用

	```
<data>
    <import type="android.databinding.ObservableMap"/>
    <variable name="user" type="ObservableMap<String, Object>"/>
</data>
…
<TextView
    android:text="@{String.valueOf(1 + (Integer)user.age)}"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
	```

#### 3.3 可观察对象
1. 定义一个可观察对象，实现`BaseObservable`,负责通知属性changed。

	```
	class User : BaseObservable() {

    @get:Bindable
    var firstName: String = ""
        set(value) {
            field = value
            notifyPropertyChanged(BR.firstName)
        }
} 
	```
2. 通过调用 `notifyPropertyChanged() `，通知改变。
3. 也可以使用`PropertyChangeRegistry `实现Observable，以便注册和通知监听。


### 4. 生成的绑定类
1. 所有绑定类都继承于`ViewDataBinding`
2. 将layout文件名`activity_main`相应生成的类`ActivityMainBinding`.
3. 包含layout的属性

#### 4.1 创建绑定对象
1. `val binding: ActivityMainBinding = ActivityMainBinding.inflate(layoutInflater)`
2. `val listItemBinding = DataBindingUtil.inflate(layoutInflater, R.layout.list_item, viewGroup, false)`

#### 4.2 带ID的View
1. 直接调用layout定义的属性名，比`findViewById()`更快

#### 4.3 变量
1. 定义变量直接访问 `<variable name="user" type="com.xxx.User"/>`

#### 4.4 其他
1. `ViewStubs` 可以监听 `OnInflateListener`
2. 立即绑定：` executePendingBindings()`
3. 高级绑定：比如在item的onBindViewHolder

	```
	override fun onBindViewHolder(holder: BindingHolder, position: Int) {
		item: T = mItems.get(position)
		holder.binding.setVariable(BR.item, item);
		holder.binding.executePendingBindings();
	}
	```
4. 后台线程，不允许是collection的类型，避免并发问题。
5. 自定义绑定类：`<data class="CustomItem"/>`


### 5. 绑定Adapter

#### 5.1 设置属性的值
1. 自动method选择：比如 `android:text="@{user.name}"`,setText或getText都会去寻找这个user.getName()。
2. 指定自定义的method：

	```
	@BindingMethods(value = [
    BindingMethod(
        type = android.widget.ImageView::class,
        attribute = "android:tint",
        method = "setImageTintList")])
	```
3. 提供自定义逻辑

	```
	@BindingAdapter("android:paddingLeft")
fun setPaddingLeft(view: View, padding: Int) {
    view.setPadding(padding,
        view.getPaddingTop(),
        view.getPaddingRight(),
        view.getPaddingBottom())
}
	```

#### 5.2 对象转化
1. 自动对象转换
2. 自定义转化：`@BindingConversion
fun convertColorToDrawable(color: Int) = ColorDrawable(color)`, 使用` <View  android:background="@{isError ? @color/red : @color/white}" `

### 6. 将layout绑定到框架组件中

#### 6.1 使用LiveData通知UI相关数据改变
1. 设置`binding.setLifecycleOwner(this)`
2. 使用ViewModel组件，LiveData对象作为数据绑定源 通知UI

	```
	class ScheduleViewModel : ViewModel() {
	    val userName: LiveData
	
	    init {
	        val result = Repository.userName
	        userName = Transformations.map(result) { result -> result.value }
	    }
	}
	```
        
#### 6.2 使用ViewModel管理与UI相关的数据
1. 定义1个ViewModel

	```
	UserModel userModel = ViewModelProviders.of(getActivity()).get(UserModel.class)
	val binding: UserBinding = DataBindingUtil.setContentView(this, R.layout.user)
	binding.viewmodel = userModel
	```

2. 使用ViewModel

	```
	<CheckBox
	    android:id="@+id/rememberMeCheckBox"
	    android:checked="@{viewmodel.rememberMe}"
	    android:onCheckedChanged="@{() -> viewmodel.rememberMeChanged()}" />
	```

#### 6.3 使用Observable ViewModel更好地控制绑定Adapter
1. 使用ViewModel实现该组件的Observable来通知UI，类似于LiveData。但这种情况不关注组件的生命周期。
2. 使用add/removeOnPropertyChangedCallback()订阅/取消通知。
3. 在notifyPropertyChanged()在属性更改时运行自定义的逻辑。

```
open class ObservableViewModel : ViewModel(), Observable {
	private val callbacks: PropertyChangeRegistry = PropertyChangeRegistry()
	
	override fun addOnPropertyChangedCallback(callback: Observable.OnPropertyChangedCallback) {
		callbacks.add(callback)
	}
	
	override fun removeOnPropertyChangedCallback(callback : Observable.OnPropertyChangedCallback) {
		callbacks.remove(callback)
	}
	
	// Notifies observers that all properties of this instance have changed.
	fun notifyChange() {
		callbacks.notifyCallbacks(this, 0, null)
	}
}
```

### 7. 双向数据绑定
1. 单项绑定

	```
	<CheckBox
    android:id="@+id/rememberMeCheckBox"
    android:checked="@{viewmodel.rememberMe}"
    android:onCheckedChanged="@{viewmodel.rememberMeChanged}"
/>
	```
2. 双向绑定,使用`@={}`

	```
	<CheckBox
    android:id="@+id/rememberMeCheckBox"
    android:checked="@={viewmodel.rememberMe}"
/>
	```
3. 实现`BaseObservable`,并使用`@Bindable`注释,通过get/setData去映射到 viewModel的属性值。

#### 7.1 使用自定义属性双向绑定
1. 自定义属性使用双向绑定需添加`@InverseBindingAdapter`和 `InverseBindingMethod`注释。
2. 也可以添加一个监听器`InverseBindingListener`

```
@BindgingAdapter("time")
@JvmStatic fun setTime(view: MyView, newValue: Time) {
	if (view.time != newValue) {
		view.time = newValue
	}
}

@InverseBindingAdapter("time")
@JvmStatic fun getTime(view: MyView): Time {
	return view.getTime()
}

// 设置时间变化的监听器
@BindingAdapter("app: timeAttrChanged")
@JvmStatic fun setListeners(view: MyView, attrChange: InverseBindingListener) {
	// set a listener for click, focus, touch, etc.
}
```

#### 7.2 转化器
1. 1个变量绑定到一个需要在显示前格式化，转换或更改的View对象上，则需要一个转换器。
2. 1个EditText显示日期，`<EditText android:text="@={Converter.dateToString(viewmodel.birthDate)}/>"`

#### 7.3 定义循环的双向绑定
1. 当用户更改属性时，将@InverseBindingAdapter调用使用注释的方法 ，并将值分配给backing属性。反过来，这将调用使用注释的方法 @BindingAdapter，这将触发对使用注释的方法的另一个调用@InverseBindingAdapter，依此类推。

#### 7.4 双向属性
![](https://raw.githubusercontent.com/rlq/image/1623b9227a03e1f0994d517e191e4f596be70417/audition/jet/databinding.png)

#### 7.5 附加资源(TwoWaySample)[https://github.com/googlesamples/android-databinding/tree/master/TwoWaySample]






























