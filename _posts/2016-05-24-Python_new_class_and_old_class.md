---
layout: post
title: Python New Class and Old Class
category: Python
tags: [Python]
---

经典类:

``` shell
$ python
Python 2.7.11+ (default, Apr 17 2016, 14:00:29) 
[GCC 5.3.1 20160413] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> class A():
...     pass
... 
>>> a=A()
>>> a.__class__
<class __main__.A at 0x7f01a515d6d0>
>>> type(a)
<type 'instance'>
```

新式类:

``` shell
$ python3
Python 3.5.1+ (default, Mar 30 2016, 22:46:26) 
[GCC 5.3.1 20160330] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> class A():
...     pass
... 
>>> a=A()
>>> a.__class__
<class '__main__.A'>
>>> type(a)
<class '__main__.A'>
>>> 
```

经典类:
2.x python版本,在定义class的时候,不继承(object)为经典类,即默认位经典类.
经典类的多继承的时候是深度优先
a.__class__ 和 type(a) 返回不一样

新式类:
2.x python版本在定义class的时候,继承(object)为新式类;
3.x python版本默认位新式类.
新式类的多继承是广度优先
a.__class__ 和 type(a) 返回一致. 都是
