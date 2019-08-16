---
title: 搭建maven3.4.x及如何上传下载jar包的理解和总结
date: 2017-08-04 14:11:20
tags:
- Maven
---
在这两天的学习中，我的导师要求我自己新建一个私服然后，把自己的jar上传上去，然后再另一个电脑上进行调用。这个其实网上都有很多的blog文章说了很多，但是对于nexus oss3.4.x的文章很少，还有一些文章具有误导性（额，百度就查不出想要的结果了，所以我针对这两天学并且实践到的写一点）。这里主要就说一下如何使用oss 3.4.x搭建（这是现在的最新版一般网上的都是2.x）.当然我上个月看maven的时候也去学过几天私服，但是没有搞太明白（英语太垃圾）.
<!--more-->
## 如何搭建nexus oss 3.4.x
这个我是基于win10下的搭建和安装（和linux下的差不多），linux下更简单。

### 首先是去下载
这里贴了一个sonatype的下载地址（我们选择免费版）
[https://www.sonatype.com/download-oss-sonatype](https://www.sonatype.com/download-oss-sonatype)
### 下载完成后就是安装了
首先是解压下载的压缩包

然后进入安装的目录下，测试启动
```cmd
nexus.exe /run 
```
当我们看到started nexus repository manager 3.x 的时候就完全启动，表示项目可以运行

下面就是安装服务到service中
```cmd
nexus.exe /install <这个是你确定的服务的名称，如果不填的话就是nexus了>
```
当我们安装完了 以后就可以以服务的方式进行启动和关闭。
```cmd
net start nexus(这个就是你的服务名称)
```
或者关闭服务
```cmd
net start nexus
```
也可以通过下面的方式进行启动和关闭
```cmd
nexus.exe /start <服务的名称>
nexus.exe /stop  <服务的名称>
```

当然也可以卸载服务
```cmd
nexus.exe /uninstall <服务的名称>
```
好了写到这里应该可以应付nexus的启动安装等问题了。
## 常规使用
当我们安装好后，就去进行常规的使用了。这个使用的话，基本在网上的blog都有涉及。但是如果还是不是很清楚的话最好去下载一下官方的文档进行查看和说明这里给一个地址[官方文档](https://books.sonatype.com/nexus-book/reference3/bundle-development.html#bundle-development-introduction)
登录的话初始帐号密码分别是`admin` `admin123`。当然为了能让仓库有上传的权限的化，最好还是在`maven-release` `maven-snapshots`中进行赋给当前用户上传的权利。
## 如何在本机的setting.xml中进行配置
如果要使用私服的化需要配置<mirrors>中配置镜像


```xml
 <mirror>
      <id>mirror的id</id>
      <name>mirror的描述</name>
      <!-- 这个是public组的位置这个需要去网页上copy一波 -->
      <url>http://100.73.12.8:8081/nexus/content/groups/public/</url>
      <!-- 下面这个是筛选仓库的，私服有许多的仓库，这里的化可以具体百度一波就行了 -->
      <mirrorOf>*</mirrorOf>
 </mirror> 
```

--- 
这里还要配置<servers>中配置



```xml
  <server>
    <id>服务id</id>
    <username>forvoid 用户名</username>
    <password>password 用户密码</password>
  </server>
```


当然还需要在pom.xml项目中指定你需要进行上传的是snapshot还是release版本。


```xml
<!-- 公司Maven私服Nexus地址用于下载 -->
     <repositories>
         <repository>
             <id>releases</id>
             <name>Internal Releases</name>
             <url>http://{ip:port}/nexus/content/repositories/releases</url>
         </repository>
         <repository>
             <id>Snapshots</id>
             <name>Internal Snapshots</name>
             <url>http://{ip:port}/nexus/content/repositories/snapshots</url>
         </repository>
     </repositories>
     <!-- 公司Maven私服Nexus地址用于发布 -->
     <distributionManagement>
         <repository>
             <id>releases</id>
             <name>可选参数</name>
             <url>http://{ip:port}/nexus/content/repositories/releases</url>
         </repository>
         <snapshotRepository>
             <id>snapshots</id>
             <name>可选参数</name>
             <url>http://{ip:port}/nexus/content/repositories/snapshots</url>
         </snapshotRepository>
     </distributionManagement>
```
这里直接粘贴了别人的见解[blog地址](http://www.jianshu.com/p/e4a3ab0298df)

当上传时需要去配置他的帐号和密码。
这里需要保证的是发布的id 必须和server的id相同，这样好找到密码和账户进行上传。
## 如何在项目中上传jar包

当我们在项目中配置好了上面的pom.xml中需要配置的文件后。现在就只需要进行。
```cmd
mvn deploy
```
当然这里也可以不只是发布到项目仓库，不同的插件有不同的效果。
也可以设置跳过检测之类的
## 如何在项目中引用jar包的依赖

在项目中引用jar包的话就没那么复杂了。
但是还是有很多需要注意的
```xml
  <profile>
      <id>私服服务</id>
      <repositories>
        <repository>
          <id>这个是一个随便写的id</id>
          <!-- 这里如果public不行的化最好写私服，其实两个都可以。 -->
          <url>http://100.73.12.8:8081/nexus/content/groups/public/</url>
          <!-- 如果不写下面这些的话无法获取到snapshot的包 -->
          <!-- 所以如果想获取到snapshot的包的话就要在setting或者pom.xml中写本代码 -->
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
      </repositories>
      <!-- 下面这个是插件的使用，也就是插件也有可能有本地的，一般应该用不到 -->
       <pluginRepositories>
                <pluginRepository>
                    <id>repo-iss</id>
                    <url>http://10.24.16.99:5555/nexus/content/groups/public/</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                    </snapshots>
                </pluginRepository>
            </pluginRepositories>
    </profile>   
```

通过上面的配置就可以得到snapshots和release的jar包了
。
然后直接在pom.xml中引用就行了。
所以总结一下：使用私服需要配置两步
* 在setting.xml中配置mirror，并且需要保证调用到的一定是他（可以注释其他的mirror）
* 在setting.xml或者pom.xml中配置profile中配置<repository>配置一个和mirror中类似的，把release和snapshot打开，这样就可以下载（release和snapshots的内容了）

## 总结
通过这些配置，我了解了setting 文件中servers和mirror的作用，并且加深了对profile的理解，还有就是如何管理私服，发布jar。
总的来说，还是多看多学多做是有好处的。

### 下面是我遇到的一个坑
> 这里我遇到了一个坑，就是一个<mirrors>中最好只配置一个<mirror>，应为这个是一个镜像的概念（而不是分库）。一般maven中只会使用其中的一个镜像(网上有的说是按照id的a-z的顺序选择，但是我实践是按照在setting文件中的出现先后顺序选择一个的)。所有如果你的私服中特有的jar，然后你配置的私服镜像没有被maven启用的话，那么怎么配置都是没用的（这个镜像只有第一个挂了才会继续选择其他的镜像，不然第一个没有就是没有了）。