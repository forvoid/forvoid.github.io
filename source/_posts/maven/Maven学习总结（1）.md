---
title: Maven学习总结（1）
date: 2017-07-17 09:18:43
tags:
- Maven
---
通过三四天的学习和总结《Maven权威指南》,这里我大概总结一下maven中我的学习内容。maven是我们日常程序开发中所经常需要接触的一个管理工具，他主要是用在了整个项目的搭建、测试、运行和打包 发布等等的整个项目生命周期的环节。这个（1）我打算就写一下 `maven是什么``能干什么``怎么用`.和他的生命周期相关的一些内容
<!--more-->
## Maven 是什么
 笼统的说 ： maven是一个构建工具，构建整个我们开发程序的项目的全过程（除了不写代码、配置路由外）。
 maven也是一个项目管理工具， 管理整个项目的Jar包依赖 管理项目的权限（什么系统使用什么样的配置等） 他动态的接管了整个项目的运行和调试环境（通过参数配置）。
 > 官方的定义是：Maven是一个项目管理工具，它包含了一个项目对象模型（pom）、一组标准集合、一个项目生命周期（project lifcycle）、一个依赖管理系统 和用来运行定义在生命周期阶段（phase）中的插件（plugin）目标（goal）的逻辑。

 就是说maven包括了四个内容 然后根据这些内容 对整个项目进行构建（约定优于配置）。
 也可以用一个形象的栗子来考虑（我的理解有可能有失偏颇），就像是建设一个高楼大厦 maven就像是整个高楼同一的`设计工具` 实现工具 和网络模拟工具 ，而剩下的只是我们程序要去下如何 设计整个的流程（编写代码） 实现高楼一层一层的向上迭代这样一个过程 了。他让 软件工程化成为了一种可能，而不是之前的，什么都是自己在定义 自己在编写 自己在发布等等。我们剩下的就只需要去实现业务代码就好了。这与使用的什么编程工具是无关的。
## Maven 能做什么
正如上面定义所说的 maven是可以进行许许多多的操作的，
 `maven arachetype:generate -DgroupId=com.forvoid.xx -DartifactId=XXX `（这个就是根据类型创建项目）、
 创建完成了开始编码 、
 然后可以在maven命令中使用生命周期的元素 进行编译 `mvn compile`、`mvn test`、`mvn install`等等
 然后可以对网站进行指定样式的打包`mvn package` 、`mvn -DdescriptorId=project assembly:single`根据要求打对应的包 、
 发布项目内容静态网站 `mvn site` 和 发布整个项目 `mvn deploy`
 还有我们使用它最重要的原因 管理jar包 让整个开发流程各个程序员统一 jar不会出现什么问题

## Maven 生命周期详解

maven的生命周期 是一个需要重要理解的问题，整个生命周期大致上就是一个项目的从开始到上线的生命过程，我们可以从mvn的理解的整个生命周期有哪些
### 生命周期有那些(Maven3)
* validate 验证项目
* initialize 初始化
* generate-sources 生成源文件（）
* process-sources 编译前阶段  复制并处理资源文件。
* compile 编译（就是javac的这个阶段）
* process-classes
* generate-test-sources
* process-test-sources
* test-compile 测试代码编译
* process-test-classes
* test
* prepare-package
* package
* pre-integration-test
* integration-test 集成测试
* post-integration-test
* verify 验证
* install 项目安装
* deploy 项目发布
* pre-clean 准备清理
* clean 清理
* post-clean 清理后
* pre-site 准备生成站点
* site 生成站点
* post-site 生成站点后
* site-deploy 站点发布

从上面的生命周期我们可以大致的看出整个Maven的工作范围 从最开始的验证整个项目的pom正确性--》整个项目的详细情况分析网站 ,这就相当与整个建筑从那地到安装内置 到最后交房使用 统计房子的使用情况 的整个流程。

每个流程都必须 先执行前面的所以流程后才会继续执行下面的流程 （test例外 `mvn site -Dmaven.test.skip=true`跳过 执行test的所有操作）

## 写在后面
本节只是对整个maven有个初始的理解和印象 需要重点的理解的是maven的生命周期 对整个maven的工作要有一定的理解。
