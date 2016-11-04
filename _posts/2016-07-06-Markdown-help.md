---
layout: post
title: Markdown简明手册
category: Other
tags: [Other, Markdown, github]
---

这是一个简单的Markdown语法说明.
用来写BLOG足够了.

## 标题

```
Code:
# 这是 H1
```

OR

```
Code:
# 这是 H1 #
```

## 数字列表

1. hello1
1. hello2
1. hello3

```
Code:
1. hello1
1. hello2
1. hello3
```

## 普通列表

* hello1
* hello2
* hello3

+ hello1
+ hello2
+ hello3

- hello1
- hello2
- hello3

```
Code:
* hello1
* hello2
* hello3

+ hello1
+ hello2
+ hello3

- hello1
- hello2
- hello3
```

## 嵌套列表

1. 列表1
    - aaa
    - bbb
1. 列表2
    1. ccc
        * ddd
1. 列表3

```
Code:
1. 列表1
    - aaa
    - bbb
1. 列表2
    1. ccc
        * ddd
1. 列表3
```

## 斜体 

*jason1*

```
Code:
*jason1*
```

## 粗体 

**jason2**

```
Code:
**jason2**
```

## 表格

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

```
Code:
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

```

## 引用

> 这是一个引用
>
> > 二级引用

```
Code:
> 这是一个引用  
>
> > 二级引用
```

## 分割线

* * * 这一行中不能用其他字符

***

******

- - - 

---------------

```
Code:
* * * 这一行中不能用其他字符

***

******

- - - 

---------------
```


## 代码块

* HTML

``` html
<a href="www.baidu.com">百度</a>
```

* BASH

``` shell
#!/bin/bash
echo "Hello, world!"
```

* PHP

``` php
<?php
echo "Hello, world!"
?>
```

* Perl

``` perl
#!/usr/bin/perl -w
print "Hello, world!"
```

* Python

``` python
#!/usr/bin/python
print("Hello, world!")
```

## 链接
[KERNEL](https://www.kernel.org/)
[MySQL](http://www.mysql.com/)
[Python中文文档](http://python.usyiyi.cn/)

```
Code:
[KERNEL](https://www.kernel.org/)
[MySQL](http://www.mysql.com/)
[Python中文文档](http://python.usyiyi.cn/)
```

## 自动链接
<http://github.com/>

```
Code:
<http://github.com/>
```

## 图片
![C luo](http://ww3.sinaimg.cn/mw690/60718250jw1f5pj814pcrj20j60b50tx.jpg)

```
Code:
![C luo](http://ww3.sinaimg.cn/mw690/60718250jw1f5pj814pcrj20j60b50tx.jpg)
```

## 转译字符

\*literal asterisks\*

Markdown 支持以下这些符号前面加上反斜杠来帮助插入普通的符号：

```
\   反斜线
`   反引号
*   星号
_   底线
{}  花括号
[]  方括号
()  括弧
#   井字号
+   加号
-   减号
.   英文句点
!   惊叹号
```

## 标签
> 标签