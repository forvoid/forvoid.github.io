---
title: Maven学习总结（2）-理解POM和Profile
date: 2017-07-17 10:52:58
tags:
- Maven
---
对于一个项目在maven中而言，最重要的就是他的pom.xml这个配置文件了，这里我总结一下，在学习pom配置文件中的一些内容 ，比较浅显，但是可以大致的学到如何去做一个maven 的配置让我们在实际的开发中带来的便利性也是不言而喻的。
<!--more-->
Maven的核心概念：项目对象模型（Project object model），项目依赖 构建配置 以及构建：所有这些都是要建模和描述的对象。 都是通过pom xml去描述的
pom主要包含了四类描述和配置
* 项目总体信息  包括名称 url 组织 贡献者 许可证
* 构建设置  源码更改测试 添加插件 绑定生命周期 自定义站点生成参数。
* 构建环境 这个主要是在不同环境中的 项目状态 在下面的prifile中我们将详细的去了解
* pom关系 这个项目很少是孤立 的 定义自己和父项目 或者子模块的信息

## 目录
[关于Maven的属性引用和资源过滤](./#maven属性)
[POM的语法理解](./#项目定位的maven和_项目版本)
[项目依赖和项目关系](./#项目依赖)
[profile是用于做什么](./#profile是用于做什么)
[如何激活一个profile](./#如何激活一个profile)

## 超级POM理解
在 maven3 中的 根目录中的（我的是C:\\Program Files\\maven-3.5.0\\lib\\C:\Program Files\maven-3.5.0\maven-model-builder-3.5.0.jar中）中org\apache\maven\model中有pom.xml 就是整个所有maven项目的超级maven 可以设置一些常用的信息 比如 他会插入 官方的编译等环境的信息
```xml
<build>
  <!-- ${project.basedir}就是我们项目的根目录
  下面都是默认的class 编译输出或在测试 文件资源的信息
   默认是不需要更改他们的 但是我们还是可以进行 更改-->
  <directory>${project.basedir}/target</directory>
  <outputDirectory>${project.build.directory}/classes</outputDirectory>
  <finalName>${project.artifactId}-${project.version}</finalName>
  <testOutputDirectory>${project.build.directory}/test-classes</testOutputDirectory>
  <sourceDirectory>${project.basedir}/src/main/java</sourceDirectory>
  <scriptSourceDirectory>${project.basedir}/src/main/scripts</scriptSourceDirectory>
  <testSourceDirectory>${project.basedir}/src/test/java</testSourceDirectory>
  <resources>
    <resource>
      <directory>${project.basedir}/src/main/resources</directory>
    </resource>
  </resources>
  <testResources>
    <testResource>
      <directory>${project.basedir}/src/test/resources</directory>
    </testResource>
  </testResources>
  <pluginManagement>
    <!-- NOTE: These plugins will be removed from future versions of the super POM -->
    <!-- They are kept for the moment as they are very unlikely to conflict with lifecycle mappings (MNG-4453) -->
    <plugins>
      <plugin>
        <artifactId>maven-antrun-plugin</artifactId>
        <version>1.3</version>
      </plugin>
      <plugin>
        <artifactId>maven-assembly-plugin</artifactId>
        <version>2.2-beta-5</version>
      </plugin>
      <plugin>
        <artifactId>maven-dependency-plugin</artifactId>
        <version>2.8</version>
      </plugin>
      <plugin>
        <artifactId>maven-release-plugin</artifactId>
        <version>2.3.2</version>
      </plugin>
    </plugins>
  </pluginManagement>
</build>
```
这些都是会在 项目构建的时候会和 项目中自带的pom.xml去进行整合 生成最后的 pom.xml 信息。
我们可以通过下面的语句命令进行查看
```cmd
mvn help:effective-pom
```
就可以查看到两个整合的信息了。

## 关于Maven的属性引用和资源过滤
### maven属性
maven 的pom中有许多属性引用 主要是便于整个项目的理解 和书写方便主要引用的方式和jsp等网页渲染相同`${引用信息}`

* 第一种自定义引用数据
  ```xml
    <properties>
      <引用信息>值</引用信息>
      <org.springFormwork>3.4.5</org.springFormwork>
    </properties>
  ```
* 内置属性
  就是maven的指定的内置属性 ${basedir}就是项目根目录，${version}项目版本.
* pom属性（project.开头） pom是可以进行属性配置的 对应的pom的每个属性都可以通过上面的方式去引用${project.build.sourceDirectory}项目主源代码地址.
* settings 获取settings.xml中的元素.${settings.localRepository}不过不知道为什么我自己总是没法获取到元素(很尴尬)
* java属性.可以获取java的所用属性 ${java.version}这样的形式
* 环境变量获取，通过env.的方式 获取 环境变量中的属性${env.JAVA_HOME}就可以获取到jdk的跟目录了（environment）

### maven资源过滤
除了maven中需要${}的方式去进行属性的加入 其他的xml jsp properties配置文件也需要一定的${}的方式配置属性 所以为了防止这样的事情 发生 所以会进行屏蔽掉一些文件不需要进行maven处理。

  src/main/java 和src/test/java 会把*.java的文件进行编译 ` 其他类型的文件将被忽略`.
  src/main/resources 和 src/test/resources 目录会进行复制（默认不会过滤 但是有些需要 ${} 赋值就很尴尬）。

   然而有些文件需要和java 放在一起 比如 mybatis和hibernate的表映射文件。
  所以我们需要进行一定的资源过滤处理

  这时候有两种方式：
  * 在<build>元素下的<resources>进行配置
  * 在<build>的<plugins>子元素中配置maven-resources-plugin等处理资源文件的插件.

总的需要三个`<includes>` (要包含那些文件)和 `<excludes>`（要排除那些文件） 。filtering 是指定那些文件需要过滤（就是需要替换${}）、 通过`filtering` 的来确定是否加载 是否 过滤 是否替换。

### build的方式
```xml
  <build>
      .......
        <resources>
          <resource>
              <directory>src/main/resources</directory>
              <!--  不需要过滤的信息(将直接复制)-->
              <excludes>
                  <exclude>**/*.properties</exclude>
                  <exclude>**/*.xml</exclude>
               </excludes>
               <!--  是否开启过滤接口-->
              <filtering>false</filtering>
          </resource>
          <resource>
              <directory>src/main/java</directory>
              <!-- 需要过滤的信息  将按照一定的规则进行过滤 -->
              <includes>
                  <include>**/*.properties</include>
                  <include>**/*.xml</include>
              </includes>
              <filtering>false</filtering>
          </resource>
          <resource>
            <directory>src/main/resources</directory>
            <!--  除了所有的xml文件 其他文件全部复制-->
              <filtering>false</filtering>

              <excludes>
                <exclude>
                  **/*.xml
                </exclude>
              </excludes>

          </resource>
      </resources>
      ......
  </build>
```

### 插件的方式(plugin)
  ```xml
  <plugin>
            <artifactId>maven-resources-plugin</artifactId>
            <version>2.5</version>
            <executions>
                <execution>
                    <id>copy-xmls</id>
                    <phase>process-sources</phase>
                    <goals>
                        <goal>copy-resources</goal>
                    </goals>
                    <configuration>
                        <outputDirectory>${basedir}/target/classes</outputDirectory>
                        <resources>
                            <resource>
                                <directory>${basedir}/src/main/java</directory>
                                <!-- 加入需要进行过滤的文件-->
                                <includes>
                                    <include>**/*.xml</include>
                                </includes>
                            </resource>
                        </resources>
                    </configuration>
                </execution>
            </executions>
        </plugin>
  ```
  第二种方式
  ```xml
  <plugin>
           <groupId>org.codehaus.mojo</groupId>
           <artifactId>build-helper-maven-plugin</artifactId>
           <version>1.8</version>
           <executions>
               <execution>
                   <id>add-resource</id>
                   <phase>generate-resources</phase>
                   <goals>
                       <goal>add-resource</goal>
                   </goals>
                   <configuration>
                       <resources>
                           <resource>
                               <directory>src/main/java</directory>
                               <includes>
                                   <include>**/*.xml</include>
                               </includes>
                           </resource>
                       </resources>
                   </configuration>
               </execution>
           </executions>
       </plugin>
  ```


### 在打包时对项目的资源进行是否过滤的设置
```xml
<plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <version>2.4</version>
                <configuration>
                  <!--  不需要过滤的文件（就是这个文件不要了 呜呜）-->
                    <excludes>
                        <exclude>*.properties</exclude>
                    </excludes>
                    <archive>
                        <manifest>
                            <addClasspath>true</addClasspath>
                            <mainClass>xxxxxx.ConsoleLauncher</mainClass>
                        </manifest>
                    </archive>
                </configuration>
            </plugin>
```
这个小节参考了网上的博客[http://www.cnblogs.com/pixy/p/4798089.html](http://www.cnblogs.com/pixy/p/4798089.html)
## POM的语法理解
### 项目定位的maven和_项目版本
1、maven项目定位坐标 会用到
`groupId` `artifactId` `version` `packaging` `classifier`
群组信息    项目信息      版本信息   打包方式    jdk、系统环境等指定
其中groupId artifactId version 是必须要去填写 packaging可以用amven默认的方式

2、项目版本规范(version)
```
<major version>.<minor version>.<increment version>-<qualifier>
主、次、增订-预选类型(beta公、alpha内、gamma完美公测、Final正式版、release发行版 SNAPSHOT快照版本等)
```
### 多模块项目
```xml
<modules>
  <module>项目名（artifactId）</module>
  <module>项目名（artifactId）</module>
</modules>
```
会去检查每一个子项目的pom.xml

### 项目继承
继承parent的 就是继承一个项目的pom.xml文件 不需要进行单独的重新配置了（每个maven都是继承了超级Pom的内容的）
## 项目依赖和项目关系
### 项目依赖
Maven可以进行内部外部依赖，依赖外部的发行版 依赖内部的自己的其他服务（或者父项目）。
```xml
<dependencies>
  <dependency>
    <groupId>xxxxxx</groupId><!--如果maven的自己类可以不用填写 -->
    <artifactId>xxx</artifactId><!-- 必填-->
    <version>1.2.2</version><!--如果maven 父类已经有过了可以不用填写-->
    <!-- 选填 -->
    <scope>compile</scope>
    <!--  依赖范围
      compile : (default)
      provided: 依赖本地servlet或者jdk提供的jar包，在打包的时候不进行 jar包的复制
      runtime:就是运行和测试时使用 编译时 不需要（生命周期的概念）
      test
      system:和provided类似 显示的指定 jar的路径（<systemPath>）
  -->

```
### 依赖版本界限
（,）不包含量词
[,]包含量词
```xml
<!-- 将选择3.8 --4.0之间的版本 -->
<version>[3.8,4.0]</version>
<!-- 将选择小雨等于4.0的版本-->
<version>[,4.0]</version>
```

### 排除一个jar传递性依赖
```xml
<dependency>
  <groupId></groupId>
  <artifactId></artifactId>
  <version></version>
  <!-- 排除某一个传递依赖  这样就不会在其他地方出现依赖冲突 -->
  <exclusions>
    <exclusion>
      <groupId></groupId>
      <artifactId></artifactId>
    </exclusion>
  </exclusions>
</dependency>
```
### 依赖管理
依赖管理的作用是 <dependencyManagement>为你提供一种统一的依赖版本号， 这样 的化就可以不用在每个子项目中使用版本号 了。
```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      ...
    </dependency>
  </dependencies>
</dependencyManagement>

```


## profile是用于做什么
profile使用于为特殊的环境定义一个特殊的构造，`他让不同环境之间的移植构建成为了可能`。
就是比如 开发环境 测试环境 生产环境 等等

每个profile 都必须要有一个id （这个激活的化的话 -P<id>）参数 其他的都是pom的所有的一级标签都是可以使用的。
```xml
<profiles>
 <profile>
 <build>
 <defaultGoal>...</defaultGoal>
 <finalName>...</finalName>
 <resources>...</resources>
 <testResources>...</testResources>
 <plugins>...</plugins>
 </build>
 <reporting>...</reporting>
 <modules>...</modules>
 <dependencies>...</dependencies>
 <dependencyManagement>...</dependencyManagement>
 <distributionManagement>...</distributionManagement>
 <repositories>...</repositories>
 <pluginRepositories>...</pluginRepositories>
 <properties>...</properties>
 </profile>
 </profiles>
```
## 如何激活一个profile
激活一个profile有很多种方式主要是 参数激活 id激活 jdk激活 os激活 属性缺失激活
* id激活 这个就不用写<activation>
```bash
mvn install -P<id>
```
* jdk激活
```xml
<profiles>
  <profile>
    <id>dev</id>
    <activation>
      <jdk>1.6</jdk>
    </activation>
    。。。。
</profiles>
```
* os激活
```xml
<profiles>
  <profile>
    <id>dev</id>
    <activation>
      <os>
        <name>windows xp</name>
        <family>windows</family>
        <arch>x86</arch>
        <version>  </version>
      </os>
    </activation>
    。。。。
</profiles>
```
* 属性缺失激活
```xml
<profiles>
  <profile>
    <id>dev</id>
    <activation>
      <property>
        <name>!${environment.type}</name>
      </property>
    </activation>
    。。。。
</profiles>
```
* 属性写入激活

```xml
<profiles>
  <profile>
    <id>dev</id>
    <activation>
      <property>
        <name>type</name>
        <value>prod</value>
      </property>
    </activation>
    。。。。
</profiles>
```
写入下面这个样式即可激活profile
```bash
mvn install -Dtype=prod
```
### 如何查看自己已经激活
```bash
mvn help:active-profile
```

## 总结
本次我们学习到了很多的管理pom的管理配置方式，基本不懂就百度 但是还是要有一些基本的概念性的东西需要大致的掌握到。
