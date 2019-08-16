---
title: tomcat初始化后无法进入页面后台的问题
date: 2016-09-19 18:08:52
tags:
  - tomcat
  - bug
categories:
  - tomcat
---
## 问题描述
今天为了搭建一个gitbucket服务端，我又下载了tomcat8.tar.gz数据包进行安装，在解压玩成之后，我需要用界面登录tomcat服务器放入gitbucket.war但是需要我配置tomcat中的`tomcat-users.xml`信息给定一定的账户和密码才能进入后台。我安照网上的要求配置后和我以前的一些经历一样。无论怎么重新启动都无法进入`host/manager`这个页面。
<!-- more -->
# 更新
* 2017.5.25 把第二个方法更新了一下，下面那个第二个方法不是绝对的正确


# 问题解决方式
## 第一、我需要结局给`tomcat-users.xml`给定帐号密码的值
```
<role rolename="manager-gui"/>

<user username="tomcat" password="tomcat" roles="manager-gui"/>
```
角色只需要manager-gui这个角色就可以了，在网页信息中也有显示。
## 第二远程登录tomcat管理页面
这个是是因为管理页面是在webapps项目包下面的manager项目中的。我们需要在manager项目中去配置运行远程的访问。
* 1 找到webapps/manager项目
* 2 进入项目中的MATE-INF
* 3 打开context.xml 
* 4 注释掉判断访问ip的那一段代码

```
<Context antiResourceLocking="false" privileged="true" >
<!--注释掉下面的这一段代码-->
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
</Context>

```
## ~~第二个问题是我需要让我进入那个登录验证的页面。~~(错误的）
这就是我在查看`http://www.cnblogs.com/dawugui5460/articles/4164124.html`这位大神的博客中看到的。说进入不了页面的原因是因为tomcat的安装包中没有提供manager.xml这个文件。有些版本的tomcat无法启动管理界面。
解决方法：
* 查看是否存在`conf/Catalina/localhost/manager.xml`这个文件夹，
* 如果没有的话就创建并且填入值
  ```
  <?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" />
  ```
  保存重启后再看看，可不可以了。
## 感悟
非常感谢那位大神的博客。我试了很多次，也baidu、google了很久，这方面的信息确实有点少。希望以后自己也能够善于的去发现这些问题。并且可以自己解决掉。我写出来的目地是确实知道的人比较少。后面有需要的人，有幸的话可以看到这篇博文的话，希望他们也可以解决自己的问题。
