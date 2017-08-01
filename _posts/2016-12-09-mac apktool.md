---
layout: post
title: MAC apktool 
category: Android
tags: [apktool]
---

#### 1. apktool步骤
1. 下载[apktool](https://bitbucket.org/iBotPeaches/apktool/downloads)，重命名为`apktool.jar`
2. 创建`apktool`脚本，参照[这里](https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/osx/apktool)
3. 创建`apktool`文件夹，将`apktool.jar`和`apktool`放进去
4. 在终端配置，步骤如下：

	```
	//可使用：右击Finder －> 前往文件夹 －>输入/usr/sbin －>前往
	~ user:cd /usr/local/bin 
	//如果不存在，可以执行 sudo mkdir bin
	~ bin: cd Desktop/apktool/
	//将apktool.jar 和apktool copy 到bin下
	~ apktool: sudo cp apktool.jar apktool /usr/local/bin 
	~ sudo apktool
	```
5.  `~ apktool: ./apktool d test.apk`, 进入apktool文件夹下，进行反编译 
6. 此时`xml`文件都已经反编译成功

#### 2. 查看java源码
1. 下载[dex2jar](http://mac.softpedia.com/get/Developer-Tools/dex2jar.shtml),解压
2. 把`dex2jar`文件放到`apktool`文件夹下
3. 把`apk`文件解压,可以直接解压或者修改后缀`.zip`再解压,找到`classes.dex`文件，把它放进`dex2jar`文件夹下
4. `cd Destop/apktool/dex2jar`,进入`dex2jar`文件夹下
5. 执行`sh dex2jar.sh classes.dex`,会生成一个`classes_dexjar.jar`文件
  
6. 下载[jd-gui](),解压
7. 打开`jd-gui`，将生成的`classes_dex2jar.jar`在窗口下查看

#### 3. 编译，签名，打包
1. 编译 `java -jar /usr/local/bin/apktool.jar b apk`
2. 重新打包 `apktool b Destop/apktool/test`
3. 自动签名 `jarsigner -verbose -keystore new.keystore -signedjar newTest.apk test.apk new.keystore`; 签名 `new.keystore`, 签名后的apkName `newTest.apk`,签名前的apkName `test.apk`

#### 遇到的问题
1. `sudo: apktool: command not found`

	```
	$ apktool
	zsh: permission denied: apktool
	$ sudo apktool
	Password:
	sudo: apktool: command not found 
	```
官方有提示：`Note - Wrapper scripts are not needed, but helpful so you don’t have to type java -jar apktool.jar over and over.`
**`./apktool d test.apk`**

2. d2j-dex2jar.sh: line 36: ./d2j_invoke.sh: Permission denied

	```
	sh d2j-dex2jar.sh classes.dex
	./d2j-dex2jar.sh: line 36: ./d2j_invoke.sh: Permission denied
	```
需要增加权限 `sudo chmod +x d2j_invoke.sh`

#### apktool命令
1. 反编译APK命令`apktool d [-f] <file.apk> <dir>`
2. 编译修改好的文件 `apktool b <dir>`
3. install -framework