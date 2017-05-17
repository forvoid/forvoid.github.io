---
title: 事务管理简介（数据库和spring）
date: 2017-05-16 10:06:32
tags:
	- 事务
---
> 文章摘自《从零开始写Java框架》的事务管理简介部分，感觉还不错，做个笔记

<!--more-->
## 什么是事务（Transaction）
事务：就是做一个任务，要么全部做完，要么都不做，不会存在做一半留一半的情况。

事务的4个性质（ACID）
* 原子性（Atomicity） 事务是不可分割的整体
* 一致性（Consistency） 执行数据库操作后，数据必须不会被破坏
* 隔离性（Isolation）保证多线程操作下，对数据保存没有干扰（或者干扰小）
* 持久性（Durability）数据永久的存储在数据库中

四个性质的关系：原子性是基础；隔离性是手段；持久性的目的；一致性是老大（其他都为数据传输的一致性负责）。
### 事务隔离级别

* Read_uncommited;未提交可读：允许脏读，也就是可能读取到其他会话中未提交事务修改的数据（数据库一般都不会用，而且任何操作都不会加锁，这里就不讨论了。）
* Read_commited;已提交可读：只能读取到已经提交的数据。Oracle等多数数据库默认都是该级别 (不重复读)。（数据的读取都是不加锁的，但是数据的写入、修改和删除是需要加锁的）
* Repeatable_read;可重复读：可重复读。在同一个事务内的查询都是事务开始时刻一致的，InnoDB默认级别，mysql默认。在SQL标准中，该隔离级别消除了不可重复读，但是还存在幻读。可重读这个概念是一事务的多个实例在并发读取数据时，会看到同样的数据行。不可重读：事务B修改id=1的数据提交之后，事务A同样的查询，后一次和前一次的结果不一样。
* SeriaLizable;可串行化：完全串行化的读，每次读都需要获得表级共享锁，读写相互都会阻塞。读加共享锁，写加排他锁，读写互斥，使用的悲观锁的理论，实现简单，数据更加安全，但是并发能力非常差。


## 事务面临的问题

隔离性在高并发的情况下会产生以下几种情况
* Dirty Read(脏读) 两个事务相互影响）。例：`事务A提读取了事务B未提交的数据`
* Unrepeatable Read（不可重读）：在一个事务进行过程中，可以读到其他事务提交的操作。就是在逻辑上会有问题。（这个线程一脸懵逼，我就查询了几次。怎么我的钱就少了）。例：`事务A读取了事务B已经提交的更改的数据`
* Phantom Read（幻读）：更新提交后。马上会显示在其他线程的查询中。例：`事务A读取了事务B已提交的新增的数据`(这个主要是有写锁的成分在)。


事务隔离级别|脏读|不可重读|幻读
--|--|--|--
未提交可读|允许|允许|允许
提交后可读||允许|允许
可重读|||允许
可序列化|||

mysql的解决方式采用事务隔离级别。

## 隔离级别和锁持续时间
在基于锁的并发控制中，隔离级别决定了锁的持有时间。"C"-表示锁会持续到事务提交。 "S" –表示锁持续到当前语句执行完毕。如果锁在语句执行完毕就释放则另外一个事务就可以在这个事务提交前修改锁定的数据，从而造成混乱。（引用【维基百科】[地址](https://zh.wikipedia.org/wiki/%E4%BA%8B%E5%8B%99%E9%9A%94%E9%9B%A2)）

隔离级别|写操作|读操作|范围操作（。。。where。。。）
--|--|--|--
未提交可读|S|S|S
已提交可读|C|S|S
可重读|C|C|S
可序列化|C|C|C

## Spring的事务机制

> 摘自ibm技术博客。https://www.ibm.com/developerworks/cn/education/opensource/os-cn-spring-trans/
### spring事务隔离级别(5个级别）

* TransactionDefinition.ISOLATION_DEFAULT：这是默认值，表示使用底层数据库的默认隔离级别。（就是用数据库的默认级别。）但是程序本身是没有事务机制存在的。
* TransactionDefinition.ISOLATION_READ_UNCOMMITTED：该隔离级别表示一个事务可以读取另一个事务修改但还没有提交的数据。该级别不能防止脏读和不可重复读，因此很少使用该隔离级别。
* TransactionDefinition.ISOLATION_READ_COMMITTED：该隔离级别表示一个事务只能读取另一个事务已经提交的数据。该级别可以防止脏读，这也是大多数情况下的推荐值。
* TransactionDefinition.ISOLATION_REPEATABLE_READ：该隔离级别表示一个事务在整个过程中可以多次重复执行某个查询，并且每次返回的记录都相同。`即使在多次查询之间有新增的数据满足该查询，这些新增的记录也会被忽略`。该级别可以防止脏读和不可重复读。
* TransactionDefinition.ISOLATION_SERIALIZABLE：所有的事务依次逐个执行，这样事务之间就完全不可能产生干扰，也就是说，该级别可以防止脏读、不可重复读以及幻读。但是这将严重影响程序的性能。通常情况下也不会用到该级别。


### 事务传播行为
事务的传播行为是指，如果在开始当前事务之前，一个事务上下文已经存在，此时有若干选项可以指定一个事务性方法的执行行为.

* TransactionDefinition.PROPAGATION_REQUIRED：如果当前存在事务，则加入该事务；如果当前没有事务，则创建一个新的事务。
* TransactionDefinition.PROPAGATION_REQUIRES_NEW：创建一个新的事务，如果当前存在事务，则把当前事务挂起。
* TransactionDefinition.PROPAGATION_SUPPORTS：如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
* TransactionDefinition.PROPAGATION_NOT_SUPPORTED：以非事务方式运行，如果当前存在事务，则把当前事务挂起。
* TransactionDefinition.PROPAGATION_NEVER：以非事务方式运行，如果当前存在事务，则抛出异常。
* TransactionDefinition.PROPAGATION_MANDATORY：如果当前存在事务，则加入该事务；如果当前没有事务，则抛出异常。
* TransactionDefinition.PROPAGATION_NESTED：如果当前存在事务，则创建一个事务作为当前事务的嵌套事务来运行；如果当前没有事务，则该取值等价于TransactionDefinition.PROPAGATION_REQUIRED。

以 PROPAGATION_NESTED 启动的事务内嵌于外部事务中（如果存在外部事务的话），此时，内嵌事务并不是一个独立的事务，它依赖于外部事务的存在，只有通过外部的事务提交，才能引起内部事务的提交，嵌套的子事务不能单独提交。如果熟悉 JDBC 中的保存点（SavePoint）的概念，那嵌套事务就很容易理解了，其实嵌套的子事务就是保存点的一个应用，一个事务中可以包括多个保存点，每一个嵌套子事务。另外，外部事务的回滚也会导致嵌套子事务的回滚。

```
<tx:annotation-driven transaction-manager="transactionManager"/>
```

