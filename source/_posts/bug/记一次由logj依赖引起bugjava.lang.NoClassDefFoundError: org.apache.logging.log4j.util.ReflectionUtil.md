---
title: java.lang.NoClassDefFoundError：org/apache/logging/log4j/util/ReflectionUtil 
tags:
- bug
categories:
- bug
---

![首图](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/bug/lindanov.12.png)

今天在项目启动的时候报错，java.lang.NoClassDefFoundError: org/apache/logging/log4j/util/ReflectionUtil 导致整个服务无法启动 
<!-- more -->
具体的错误日志如下：`我们采用的resin作为java ee容器`

```log
[18-11-13 20:55:01.758] {resin-21} WebApp[production/webapp/default/ROOT,STARTING] Set web app root system property: 'webapp.root' = [/home/work/bin/netroam-api/webapp/]
[18-11-13 20:55:01.768] {resin-21} WebvApp[production/webapp/default/ROOT] fail
[18-11-13 20:55:01.769] {resin-21} java.lang.NoClassDefFoundError: org/apache/logging/log4j/util/ReflectionUtil
                        at org.apache.logging.log4j.jcl.LogAdapter.getContext(LogAdapter.java:39)
                        at org.apache.logging.log4j.spi.AbstractLoggerAdapter.getLogger(AbstractLoggerAdapter.java:46)
                        at org.apache.logging.log4j.jcl.LogFactoryImpl.getInstance(LogFactoryImpl.java:40)
                        at org.apache.logging.log4j.jcl.LogFactoryImpl.getInstance(LogFactoryImpl.java:55)
                        at org.apache.commons.logging.LogFactory.getLog(LogFactory.java:685)
                        at org.springframework.util.PropertyPlaceholderHelper.<clinit>(PropertyPlaceholderHelper.java:40)
                        at org.springframework.web.util.ServletContextPropertyUtils.<clinit>(ServletContextPropertyUtils.java:38)
                        at org.springframework.web.util.Log4jWebConfigurer.initLogging(Log4jWebConfigurer.java:128)
                        at org.springframework.web.util.Log4jConfigListener.contextInitialized(Log4jConfigListener.java:49)
                        at com.caucho.server.webapp.WebApp.fireContextInitializedEvent(WebApp.java:3777)
                        at com.caucho.server.webapp.WebApp.startImpl(WebApp.java:3687)
                        at com.caucho.server.webapp.WebApp.access$400(WebApp.java:207)
                        at com.caucho.server.webapp.WebApp$StartupTask.run(WebApp.java:5234)
                        at com.caucho.env.thread2.ResinThread2.runTasks(ResinThread2.java:173)
                        at com.caucho.env.thread2.ResinThread2.run(ResinThread2.java:118)
                       Caused by: java.lang.ClassNotFoundException: org.apache.logging.log4j.util.ReflectionUtil (in EnvironmentClassLoader[web-app:production/webapp/default/ROOT])
                        at com.caucho.loader.DynamicClassLoader.loadClass(DynamicClassLoader.java:1532)
                        at com.caucho.loader.DynamicClassLoader.loadClass(DynamicClassLoader.java:1502)
                        ... 15 more
                       
[18-11-13 20:55:01.770] {main} java.lang.IllegalStateException
                        at com.caucho.server.webapp.WebApp$StartupTask.run(WebApp.java:5243)
                        at com.caucho.env.thread2.ResinThread2.runTasks(ResinThread2.java:173)
                        at com.caucho.env.thread2.ResinThread2.run(ResinThread2.java:118)
                       
[18-11-13 20:55:01.770] {main} Host[production/host/default] active
[18-11-13 20:55:01.771] {main} ServletService[id=netroam-api,cluster=netroam-api] active
[18-11-13 20:55:01.771] {main} 
[18-11-13 20:55:01.771] {main} http listening to *:8094
[18-11-13 20:55:01.771] {main} 
[18-11-13 20:55:01.772] {main} Resin[id=netroam-api] started in 7025ms
```

根据bug的提示`java.lang.NoClassDefFoundError` 我们知道是没有找到对应的类信息。我的pom配置如下

```xml
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-api</artifactId>
    <version>2.9.1</version>
</dependency>
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-core</artifactId>
    <version>2.9.1</version>
</dependency>
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-slf4j-impl</artifactId>
    <version>2.9.1</version>
</dependency>
```

# 解决方式一：log4j使用2.5的版本

根据报错，我查看了`log4j-core`和`log4j-api` 的jar包类

log4j-api-2.5 存在 `ReflectionUtil`的类 在 log4j-api-2.9.1中不存在`ReflectionUtil`类 ,所有解决bug的方式就是将 所有的logj的引用改为2.5的版本就可以解决了


```xml
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-api</artifactId>
    <version>2.5</version>
</dependency>
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-core</artifactId>
    <version>2.5</version>
</dependency>
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-slf4j-impl</artifactId>
    <version>2.5</version>
</dependency>
```

![log4j-api-2.5](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/bug/log4j-api2.5util.jpeg)
![log4j-api-2.9](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/bug/log4j-api2.9util.jpeg)

# 解决方式二：引入jcl-over-slf4j.jar

**当我们不想对log4j版本进行降级的时候我们需要采用本方式来处理**

这个jcl-over-slf4j的jar包主要的作用是：把jcl实现的日志输出重定向到 SLF4J。
jcl是什么呢：

> Apache Commons Logging （之前叫 Jakarta Commons Logging，JCL）粉墨登场，JCL 只提供 log 接口，具体的实现则在运行时动态寻找。这样一来组件开发者只需要针对 JCL 接口开发，而调用组件的应用程序则可以在运行时搭配自己喜好的日志实践工具。
当程序规模越来越庞大时，

> JCL的动态绑定并不是总能成功，具体原因大家可以 Google 一下，这里就不再赘述了。解决方法之一就是在程序部署时静态绑定指定的日志工具，这就是 SLF4J 产生的原因。

> 现在还有一个问题，假如你正在开发应用程序所调用的组件当中已经使用了 JCL 的，还有一些组建可能直接调用了 java.util.logging，这时你需要一个桥接器（名字为 XXX-over-slf4j.jar）把他们的日志输出重定向到 SLF4J，所谓的桥接器就是一个假的日志实现工具，比如当你把 jcl-over-slf4j.jar 放到 CLASS_PATH 时，即使某个组件原本是通过 JCL 输出日志的，现在却会被 jcl-over-slf4j “骗到”SLF4J 里，然后 SLF4J 又会根据绑定器把日志交给具体的日志实现工具。过程如下
Component 
| 
| log to Apache Commons Logging 
V 
jcl-over-slf4j.jar — (redirect) —> SLF4j —> slf4j-log4j12-version.jar —> log4j.jar —> 输出日志
看到上面的流程图可能会发现一个有趣的问题，**假如在 CLASS_PATH 里同时放置 log4j-over-slf4j.jar 和 slf4j-log4j12-version.jar 会发生什么情况呢？没错，日志会被踢来踢去，最终进入死循环。**

所有我们可以让程序执行避开去加载ReflectionUtil.class类来解决在pom.xml中引用jar包即可
```xml
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>jcl-over-slf4j</artifactId>
    <version>1.7.9</version>
</dependency>
```
就可以解决问题了。

# 问题产生

这个问题是无意间产生的，用release版本也出现了一样的问题，怀疑是之前在pom中的某一个依赖里面带有 jcl-over-slf4。但是现在`mvn dependency:tree`没有发现这个问题


google后无果，查找对应的正式环境和测试环境中的不同，发现。正式环境中的jar包中多了一个jcl-over-slf4.jar

![正式环境](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/bug/release-slf4j.jpeg)
![测试环境](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/bug/develop-slf4j.jpeg)

所以尝试引用jar包后解决问题！

# 总结

一般启动报错 会导致服务无法启动，导致的问题由很多。这里主要是`maven依赖相关的问题`。引用依赖中由`SNAPSHOT`版本，在依赖了SNAPSHOT变更，并不需要去改变版本号导致即使之前成功了，但是删除了对应的依赖也会报错。所有在正式的版本中启用SNAPSHOT版本的依赖。

在遇到代码启动问题找不到对应的类文件时，需要通过idea 工具 。或者直接grep 类名 在lib包下。查询是否正的没有。因为网上很多提示是，有些jar版本号下存在 有的不存在的。

# 参考链接🔗

[jcl-over-slf4j slf4j-log4j12等log工具作用](https://blog.csdn.net/s332755645/article/details/73992860)