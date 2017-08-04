---
title: dubbo-admin打包和运行启动总结
date: 2017-07-13 14:10:49
tags:
- dubbo
---
这几天，来到了公司实习，公司要求是使用zookeeper+dubbo的服务端 和客户端来进行分布式SOA架构。老大要求我们先学习着。然而dubbo在阿里14年就没有维护了（唉！），而且很多的依赖在阿里的镜像都没有，这就很尴尬了。所以导致maven打包一直报错，刚刚好经过不屑的努力和大佬们的提点，终于调通了，先写点总结，以后再深入（现在只知道皮毛）
<!--more-->
## 先决条件
* jdk环境
* maven环境（可以保证在命令行中输入命令）
* tomocat或者jetty 等Java EE 容器
* 下载解压好zookeeper
* 下载dubbo源代码，或者版本发布代码[https://github.com/alibaba/dubbo/releases](https://github.com/alibaba/dubbo/releases)

## 进入安装
首先进入命令行（我是以windows演示，linux也是差不多的，改替换的替换一下就好了
）
### 1、使用命令行（cmd）进入dubbo-admin源码跟目录
这个就是要找到dubbo-admin的源码位置。
### 2、对dubbo-admin的一些数据进行更换。
因为dubbo-admin有很多东西都out了，直接使用原有下载的配置会报错。所以我们要先修改一下pom.xml的一些数据。
下面修改的内容来自我google的大神提示@stirp[https://github.com/alibaba/dubbo/issues/50](https://github.com/alibaba/dubbo/issues/50).
* 打开pom.xml
* 找到webx依赖替换为3.1.6
 ```
     <dependency>
        <groupId>com.alibaba.citrus</groupId>
        <artifactId>citrus-webx-all</artifactId>
        <version>3.1.6</version>
    </dependency>
    ```
* 添加Velocity依赖
	```
     <dependency>
        <groupId>org.apache.velocity</groupId>
        <artifactId>velocity</artifactId>
        <version>1.7</version>
    </dependency>
    ```
* 对依赖项dubbo添加exclusion，避免引入旧spring
	```
     <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>dubbo</artifactId>
        <version>${project.parent.version}</version>
        <exclusions>
            <exclusion>
                <groupId>org.springframework</groupId>
                <artifactId>spring</artifactId>
            </exclusion>
        </exclusions>
    </dependency>
    ```

* webx已有spring 3以上的依赖，因此注释掉dubbo-admin里面的spring依赖
	```
    <!--<dependency>-->
        <!--<groupId>org.springframework</groupId>-->
        <!--<artifactId>spring</artifactId>-->
    <!--</dependency>-->
    ```
   
现在，就把dubbo-admin的pom.xml的依赖配置好了。

### 3、为了添加阿里仓库和主要仓库没有的jar，添加镜像资源。
在整个dubbo-admin的项目构建中有许多的jar是不能在主要仓库和阿里的镜像中找到的所以需要配置一下，一些镜像，来找到这些jar.
这里我参考了 一路追随 的blog[http://www.cnblogs.com/pengkw/p/3674730.html](http://www.cnblogs.com/pengkw/p/3674730.html)

* 首先需要下载一波opensesame的pom支持[https://github.com/alibaba/opensesame](https://github.com/alibaba/opensesame)
* 然后进入opensensame项目跟目录进行输入命令
	```
    mvn clean install -Dmaven.test.skip
```
完成要依赖的jar的本地化
* 配置maven 的setting.xml的数据,添加多个镜像源
	```
    <mirror>
<id>kafeitu</id>
<mirrorOf>central</mirrorOf>
<name>Human Readable Name for this Mirror.</name>
<url>http://maven.kafeitu.me/nexus/content/repositories/public</url>
</mirror>
<mirror>
<id>ibiblio.org</id>
<name>ibiblio Mirror of http://repo1.maven.org/maven2/</name>
<url>http://mirrors.ibiblio.org/pub/mirrors/maven2</url>
<mirrorOf>*</mirrorOf>
</mirror>
<mirror>
<id>lvu.cn</id>
<name>lvu.cn</name>
<url>http://lvu.cn/nexus/content/groups/public</url>
<mirrorOf>*</mirrorOf>
</mirror>
    ```
* 修改几个jar的版本.将`com.alibaba:fastjson`的版本修改为`1.1.39`

### 4、进入打包环节
在dubbo-admin的根目录下输入命令
```
mvn clean install -Dmaven.test.skip
```
等待若干时间（这个要等一段时间应为maven要下很多的依赖包）
如果不抱错的化就会在根目录下生成一个target的文件目录，进入把生成的\*.war文件放入 tomcat的对应的项目文件夹中。
启动tomcat或者jetty等，即可启动.

> 如果配置完成了一定要去掉镜像，不让无法进行创建新项目的操作。


## 登录
当进入dubbo-admin页面后，需要输入登录的帐号和密码（额，我还没认真的去学习）这里就直接输入root就可以登录了。

## 如果出现问题怎么办
因为dubbo年久失修，所以出现问题很正常。
主要的途径就行去看github上面的isssue的回复吧。都是chinase people 应该可以找到满意的解决方案，

## 总结
总的来说 ，这就是一个框架，很多人都在用，但是自己搭建还是遇到了一些麻烦。没有认真的去思考是什么问题，也没有google和百度（有可能才到公司以为什么都可以问大神too yong）。这些问题都挺基础的，自己多google就出来了。还有就是对maven不了解也导致了，一些概念不是很清楚，这几天再学maven希望可以尽快的成长》fight!!




