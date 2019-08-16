---
title: tomcat入门学习笔记（启动安装）
date: 2016-05-25 21:31:41
tags:
- tomcat
---
tomcat是我学习java ee开发以来的一个动态web服务器，从最开始使用他的时候是在大一的课程上面，后来又是在水电气项目上面运用到了tomcat服务器。一直都没时间去好好的学习它，这次我买了《tomcat权威指南第二版（6.0）》好好的去学习一下tomcat，之前很多项目在部署的时候出现很多问题。都不知道怎么去解决。这次好好的学习应该有很大的收获。
<!--more-->
## tomcat简介
tomcat是sun公司的一个java servlet container（容器）.是由James Duncan Davidson编写的。后面交给了apache基金会去维护。是GlassFish Java EE的一种新的参考实现。 是用java语言编写的web服务器。
## tomcat的安装
这里我大概只说一下用二进制包的方式安装。基本上就是把tomcat的二进制包下载好。不需要安装，在（使用1-1024端口的情况下使用root用户（如果是linux））运行包bin下的启动脚本就可以启动tomcat了。
### tomcat的前提条件
必须已经配置好了Java的运行环境（JRE）。

## tomcat的启动、停止、重启。

### 了解bin中的脚本
脚本|用途
--|--
Catalina|Tomcat的主要脚本，执行java命令以调用tomcat的启动与停止类
cpappend|用于windows系统内部，将项目路径追加到tomcat的classpath环境变量中（现在没了1.8 1.9）
digest|生成tomcat密码的摘要值，用于产生加密过后的密码
service|该脚本以windows服务方式安装和卸载tomcat（废弃了没了）
setcalsspath|设定tomcat的classpath和其他环境变量的脚本。
shutdown|运行 catalina stop 停止tomcat
startup|运行 catalina start 开始tomcat
tool-wrapper|用于digest脚本系统内部，用于封装可用与设置环境变量的脚本，并调用classpath中设置的完全符合限定的主要方法
version|运行catalina的版本，输出版本信息

```
//这个是用digest脚本生成的密码的方式 md5 md2 sha 
D:\apache-tomcat-9.0.0.M17\bin>digest.bat -a md5 tao
tao:4eb26038908bb3fc90b36c419593db3391abd242ce0218ee84b14619c1ed62b9$1$9234c361964a73e22923748e301b7e10
//输入version后的输出
Using CATALINA_BASE:   "D:\apache-tomcat-9.0.0.M17"
Using CATALINA_HOME:   "D:\apache-tomcat-9.0.0.M17"
Using CATALINA_TMPDIR: "D:\apache-tomcat-9.0.0.M17\temp"
Using JRE_HOME:        "C:\Program Files\Java\jdk1.8.0_121"
Using CLASSPATH:       "D:\apache-tomcat-9.0.0.M17\bin\bootstrap.jar;D:\apache-tomcat-9.0.0.M17\bin\tomcat-juli.jar"
Server version: Apache Tomcat/9.0.0.M17
Server built:   Jan 10 2017 20:59:20 UTC
Server number:  9.0.0.0
OS Name:        Windows 10
OS Version:     10.0
Architecture:   amd64
JVM Version:    1.8.0_121-b13
JVM Vendor:     Oracle Corporation
```
### 了解catalina脚本的使用
```
commands:
  debug             Start Catalina in a debugger
  debug -security   Debug Catalina with a security manager
  jpda start        Start Catalina under JPDA debugger
  run               Start Catalina in the current window
  run -security     Start in the current window with security manager
  start             Start Catalina in a separate window
  start -security   Start in a separate window with security manager
  stop              Stop Catalina
  configtest        Run a basic syntax check on server.xml
  version           What version of tomcat are you running?
```
参数|用途
--|--
-config [server.xml]|指定server.xml配置文件
-help | 帮助
-nonaming|停用tomcat中停用JNDI 
-security|启用catalina.policy文件
debug|调用模式启动tomcat
jpda start |以jpda调试器启动tomcat
run|`启动tomcat 但不会重定向标准输出与错误`
start|`启动tomcat 但会重定向标准输出与错误到tomcat的日志文件中 logs/catalina.out`
stop|停止tomcat
version |输出tomcat版本信息
### 常规的启动
bin/startup.sh
### 常规关闭
bin/shutdown.sh
## 为什么tomcat没有重启的脚本
主要原因是：确认tomcat是否正常关闭是比较困难。
下面列出tomcat的关闭是不可靠的理由：
* Java Servlet Speclification并没有强制规定java Servlet需要多长时间完成其工作，（tomcat有时间限制），但是会拖慢tomcat关闭
* tomcat在关闭前 servlet container必须在servlet服务结束前等待每个servlet完成所有还在进行的请求。
* Java虚拟机以多线程的方式进行处理，所以无法判断java的时间时长，还会有`线程阻塞`和`滞留阻塞`。java项目自己无法判断tomcat是否停止 （必须使用第三方语言来判断）
* tomcat所有线程都停止时，servlet还会衍生出阻止vm退出的线程。（尽可能不用System.exit(0)）。
* 在安全管理器的允许下，有可能tomcat创建出来的线程有可能优先级比tomcat本身要高（这就很尴尬了...）
* `如果tomcat完全内存溢出`（Permgen memory）,那么他在关闭端口或web端口上就无法接受新的连接。（可以设定必须没有它大）。


## 如何对tomcat进行重启

下面进行tomcat重启操作（linux）
* 1、bin/shutdown.sh
* 2、等待几秒后，jps查看是否还有Bootstrap 进程
* 3、kill -term 进程id 告诉jvm结束该进程
* 3、 kill -kill 进程id 告诉系统介绍该进程
* 4、确定tomcat不再处于运行状态 bin/startup.sh

## tomcat的环境变量
大概写一下，不懂的以后百度吧。
CATALINA_BASE(整个基本目录） 
CATALINA_HOME(静态部分基本目录)
CATALINA_OPTS(传给java的命令)
CATALINA_TMPDIR(设定tomcat临时文件夹)
CATALINA_PID（保存进程id号）
JAVA_HOME
JAVA_JRE
JPDA_TRANSPORT(dt_socket)
JPDA_ADDRESS
JSSE_HOME
