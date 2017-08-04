---
title: Maven学习总结（3）-理解maven套件和settings.xml
date: 2017-07-17 15:21:31
tags:
- Maven
---
maven套件是做自定义打包 根据要求进行maven项目的不同打包的方式（不仅仅局限与jar war ejb ear等）当然这需要进行maven assembly的编写 我们没必要学得那么深入（这个不是很难但是现在用不到） 所以这里我就简单的介绍一下 他命令的支持的一些assembly的功能
<!--more-->
## maven套件的理解和使用
项目的分发 是为不同的人 不同的场景提供不同的项目版本（distribution分发）。

assembly:assembly 目标被设计成直接从命令行调用，它永远不应该被绑定到生命周期阶段。
single mojo被设计成作为构建的某一部分 应该被绑定 到项目的生命周期的某一个阶段。
single 会导致一次构建package阶段被执行两次.

### 预定义套件描述符
* bin 包裹该主构建和项目的许可、readme、和notice文件（最小的二进制分发包）
* `jar-with-dependencies` : 将所有的依赖包加入项目本身（并且可以进行Main-Class Manifest后直接启用了）。
* project target文件被忽略后的剩下的被版本控制信息。
* src 生成源码和pom.xml信息

### assembly 和single的使用总结

使用下面的mvn进行启用maven分发打包
1、使用命令的方式
```bash
mvn -DdescriptorId=project assembly:single
```
2、使用pom.xml的配置方式
```xml
<build>
<plugins>
  <plugin>
    <artifactId>maven-assembly-plugin</artifactId>
    <version>2.2-beta-2</version>
    <!--执行-->
    <executions>
      <execution>
        <id>create-executable-jar</id>
        <phase>package</phase>
        <goals>
          <goal>
            <!--  single 方式-->
            single
          </goal>
        </goals>
        <configuration>
          <descriptorRefs>
            <descriptorRef>
              <!-- 打包方式 -->
              jar-with-dependencies
            </descriptorRef>
          </descriptorRefs>
          <!-- 这段很重要 -->
          <archive>
            <manifest>
              <!--  启用jar指定 main函数-->
              <mainClass>org.sonatype.mavenbook.ch3.App</mainClass>
            </manifest>
          </archive>
        </configuration>
      </execution>

    </executions>
  </plugin>
</plugins>
</build>
```

这里总结一下single和assembly的使用
single可以使用
* project
* src
* jar-with-dependencies

assembly可以使用
* bin
* project
* src
* jar-with-dependencies

## settings的理解和学习
settings 本机电脑中有两个
* ~/.m2/settings.xml 是当前用户的settings信息
* ${MAVEN_HOME}/conf/settings.xml是本机电脑的settings信息。

将按照远的服从近的原则进行 冲突处理

其中有许多的一级元素都可以google到 这里我主要说一下
* localRepository 构建系统本地仓库地址
* interactiveMode 如果maven需要和用户交互获取输入 设置为ture （default）
* usePluginRegistry 需要插件plugin-registry.xml来管理插件版本 默认为false
* offline 构建系统需要在离线模式下进行 false(default) 要离线就需要true
* pluginGroups 当一个依赖没有groupId时将会来匹配（可以有多个pluginGroup）
* 设置激活profile 就可以激活对应的 pom中的或者settings中的profile信息
```xml
<activeProfiles>
  <activeProfile>test</activeProfile>
</activeProfiles>

* 使用镜像（Mirrors） 这个在他的settings.xml中是有进行配置说明的。

```

## site站点信息
启动站点信息
```bash
mvn site:run
```
可以在pom.xml中定义site的样式信息和部署信息

这个就百度去吧

## 总结

大概就把我这几天 学到的maven 信息进行了整理，对整个maven进行了大致的理解 ，后面还将在实践中加深理解和印象。下一步将进行spring的学习。后面也将根据自己更进一步的理解 完善 maven这个知识总结。
