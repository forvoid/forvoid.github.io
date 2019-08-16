---
title: 跟hashmap源码Put和Get在1.7的使用
date: 2017-07-31 18:21:55
tags:
- Java
---
一直对hashmap的get和put方法有理解，但是一直没有静下心来去理解他们的具体实现，今天在同事的代领下认真的去理解了1.7源码的实现。后面也会再理解1.7之后，再深入的去理解1.8的源码吧，这里写了1.7源码的理解
## 主要难点
这个hashMap的主要难道就是在于理解如何理解Hash函数的运算这块。
还有一个难点是在于在达到增加的阀值时进行数据的扩容。
<!--more-->
## put方法的理解
put方法是向hashmap中提交数据，主要提交的就是K 和V 
* 1、进入put方法提交key 和 value
* 2、方法第一步进行`数组`判断，判断hashmap中是否有数组，如果没有数组就调用inflateTable进行数组的
* 3、如果key为空的话就调用putForNullKey方法，在方法中获取到`entry（table[0]）链表`。如果链表中的一个entry节点并且key==null的时候就进行值的`覆盖操作`把老的值返回给用户，否则就进行addentry的新增操作（这个接后面的步骤6）
* 4、如果key不为空的话，就计算key的hash值，然后通过hash值和数组的长度计算 `数组的角标`.
* 5、通过角标获取到entry链表，然后对链表进行循环获得entry类 `判断entry的hash是否等于 传入key的hash值` 如果相等就 `把值进行覆盖操作`,把老的数据值返回。否则就进行addentry新增操作
* 6、addentry获得 hash key value 和 数组下标 。先进行判断 size 是否 超过了threshold这个阀值（默认是0.75）并且判断是否在数组角标中有entry链表（不为空）。如果不满足的话，将进行扩容（resize方法扩容2倍），并且重新计算 hash 和数组角标，然后调用createEntry方法
* 7、在createEntry方法中有hash key value 和数组下标。通过数组下标获取 entry链表 然后兴建一个entry对象 把 hash key value 和entry这个链表放入新的entry对象中，在赋值给 数组小标的那个值中。并且size++
* 8、最后返回的是null。

通过这个流程，我们可以看出有三个步骤会进行返回 当key为null并且原来有null为key 的时候  和 当key在原来的entry链表上有值的时候会进行返回老的数值， 否则就会返回null

## get方法的理解

理解put的方法后get方法就容易理解了。
* 1、传入key 然后方法会进行判断。当key为 null时，就调用方法getForNullKey 
* 2、通过数组下表为0去获取entry 然后遍历entry看key==null的entry对象是否有值，如果有值的话就会进行值的返回，如果没有就返回null
* 3、key不为空就调用 getEntry（key）方法 ，获取key的hash值 然后通过hash值和数组长度 得到对于entry链表的下角标，然后遍历entry链表 获取entry.key == key的entry 并且e.hash == hahs的entry 然后返回entry给 put 方法中的entry遍历 ，然后entry不为空的化就返回entry.getValue（） 否则就返回null；

## 总结
这个是很浅显的一些认识，但是也可以大致的理解hashmap是怎样进行put 和get操作的。