---
title: mybatis与spring集成总结
date: 2017-07-30 10:44:37
tags:
- mybatis
---
这里总结一下mybatis的与spring的集成方式，主要是从mybatis的官方文档中学习到的。[http://www.mybatis.org/spring/zh/](http://www.mybatis.org/spring/zh/)这里可以具体的去学习
<!--more-->
> 做难事，必有所得                     --金一南教授
## 主要的要点

要点主要在 
`datasource`的配置 
`SqlSessionFactory`的获取
`SqlSession`的获取或者说用其他方式注入Sqlsession
`SqlSession`注入到mapper接口
`mapper`接口注入到项目的service中
这几个是主要需要解决和理解的点

## 支持的jar

主要是spring的context beans（这个集成在了context中） myabtis mysql 还有spring-jdbc这几个jar

## 让mybatis支持事务

```xml
<tx:jta-transaction-manager />
<!-- 注 意 , 如 果 你 想 使 用 CMT , 而 不 想 使 用 Spring 的 事 务 管 理 , 你 就 必 须 配 置 SqlSessionFactoryBean 来使用基本的 MyBatis 的 ManagedTransactionFactory 而不是其 它任意的 Spring 事务管理器: -->

<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
  <property name="dataSource" ref="dataSource" />
  <property name="transactionFactory">
    <bean class="org.apache.ibatis.transaction.managed.ManagedTransactionFactory" />
  </property>  
</bean>
```

## 事例代码
这里我在代码中做了注释，可以通过注释去理解这个的整合方式等。
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:context="http://www.springframework.org/schema/context"

       xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans-4.1.xsd
                           http://www.springframework.org/schema/context
                           http://www.springframework.org/shcema/context/spring-context-4.1.xsd
                           http://www.springframework.org/schema/tx
                           http://www.springframework.org/schema/spring-tx-4.1.xsd">

    <bean id="propertyConfiguration" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
        <property name="locations">
            <list>
                <value>classpath:jdbc.properties</value>
            </list>
        </property>
    </bean>

    <bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource"
          init-method="init" destroy-method="close">
        <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
        <property name="url" value="${jdbc.url}"/>
        <property name="username" value="${jdbc.username}"/>
        <property name="password" value="${jdbc.password}"/>

        <property name="maxActive" value="${jdbc.maxActive}"/>
    </bean>

    <!--mybatis整合-->
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
        <!--如果不加这一句的话，那么Mapper.java和Mapper.xml必须放在同一个目录下面-->
        <property name="mapperLocations" value="classpath*:org/**/*Mapper.xml"/>
    </bean>

    <!--&lt;!&ndash;通过bean的方式加载和使用 注入映射器mybatis&ndash;&gt;-->
    <!--<bean id="personMapper" class="org.mybatis.spring.mapper.MapperFactoryBean">-->
        <!--<property name="sqlSessionFactory" ref="sqlSessionFactory"/>-->
        <!--<property name="mapperInterface" value="org.learn.springTransaction.dao.PersonMapper"/>-->
    <!--</bean>-->

    <!--注册所以的映射器-->
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <!--这个是指定java包的地址 有多个包的情况进行分号的隔离(官方文档说逗号也可以我尝试不行)-->
        <property name="basePackage" value="org.learn.springTransaction.dao" />
        <!--这个是为了当使用多个datasource时，无法进行自动装配，将可以指定名称装配的方式来进行-->
        <property name="sqlSessionFactoryBeanName" value="sqlSessionFactory" />
    </bean>
    <!--这个是将sqlSession作为一个bean来通过application来获取一般不用-->
    <!--<bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate">-->
        <!--<constructor-arg index="0" ref="sqlSessionFactory" />-->
    <!--下面这个语言是用于进行批量插入的-->
    <!--<constructor-arg index="1" value="BATCH" />-->
    <!--</bean>-->
    <!--通过bean的方式来获取sqlsession-->
    <!--<bean id="userDao" class="org.mybatis.spring.sample.dao.UserDaoImpl">-->
        <!--<property name="sqlSession" ref="sqlSession" />-->
    <!--</bean>-->

    <!--mybatis启用spring的事务管理-->
    <!--配置数据源的标准方式-->
    <!--<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">-->
        <!--<property name="dataSource" ref="dataSource" />-->
    <!--</bean>-->

    <!--正使用一个 JEE 容器而且想让 Spring 参与到容器管理事务(Container managed transactions,CMT,译者注)中
    ,那么 Spring 应该使用 JtaTransactionManager 或它的容 器指定的子类来配置。
    做这件事情的最方便的方式是用 Spring 的事务命名空间-->
    <tx:jta-transaction-manager />
</beans>
```
## 总结
基本上就是一些概念性的东西，当认真的去理解了mybatis 和spring后 理解他们的整合还是很简单的，所以学东西就是这样如何把一个知识点拉通了才是我们真正的提高的点。