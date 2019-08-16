---
title: JMM理解-双重检查锁定与延迟初始化的问题
date: 2017-07-31 19:08:28
tags:
- Java并发
---
这个是我读《Java并发编程的艺术》一书中的Java 内存模型一章中阐述的，这里我做一下笔记，主要是这个点，之前一直的感知是错误的，做一个笔记为了以后能自己去理解更多的知识，少点自以为是。
在java程序中有时候会进行延迟加载初始化，比如我之前记录的单例模式的懒汉模式就是 延迟初始化的，但是重要的点是`开始就进行初始化比延迟初始化的性能上是更高的`。我们为什么要延迟初始化呢？ 因为：有些高开销的 或者初始化很慢的 使用频率低但是内存占用大的（没必要一开始就运行）这些，有可能就需要延迟初始化。
<!--more-->
## 双重检查锁的由来
 
全文以单例模式为代码事例。
```java
//在不安全的环境下进行单例初始化对象 
public class UnsafeLazyInitialization{
    public static Instance instance;

    public static Instance getInstance() {
        if(instance == null) {
            instance = new Instance();
        }
        return instance;
    }
}
```
这个是线程不安全的，因为当a线程进行 new的操作的时候 b线程检测instance == null 也可以进入new 的操作。所以以前我写代码就是跟下面的方式一样。
```java
  public class SafeLazyInitialization{
        private static Instance instance;

        public synchronized static Instance getInstance() {
            if (instance == null) {
                instance = new Instance();
            }
            return instance;
        }
    }
```
这个代码可以`保证没有任何线程安全的问题`。因为进入getInstance方法必须进行获取同步锁，在同一时间点内只能有一个线程进入方法操作。但是内存消耗过大，在线程间切换的开销 和 在单线程下的性能开销是没有意义的。所以很多时候我们写代码就有可能会使用到双重检查锁定
```java
public class DoubleCheckedLocking{
        private static Instance instance;

        public  static Instance getInstance() {             //1进入方法
            if (instance == null) {                         //2判断是否存在instance
                synchronized (DoubleCheckedLocking.class) { //3获取类锁
                    if (instance == null) {                 //4判断是否存在instance
                        instance = new Instance();          //5初始化对象然后赋值
                    }
                }
            }
            return instance;
        }
    }
```
这里在以前我是认为是没有任何错误的。但是`在进行初始化的过程中是存在重排序的可能性的`
初始化过程
```java
memory = allocate()//分配对象的内存空间（1）
ctorInstance(momory)//初始化对象（2）
instance = memory;//设置instance指向刚刚分配的内存地址（3）
```
这里的（2） 和（3） 是有可能进行从排序的，在单线程中，只要保证在访问之前 把初始访问对象的时候 分配好对象就行了。但是在多线程中，如果b在访问的时候`刚好设置类分配的内存对象 但是没有进行初始化对象`，那么就gg了。这里给过去的引用只是一个没有分配好空间的引用。那么调用方法肯定就会报错。
这里就有两种解决方式，就在下面写好了
## 基于volatile的解决方式
volatile关键字能保证禁止指令重排序，也就是说上面的（2）和（3）的顺序在volatile中是不能进行重排序的。保证了他们是可以在多线程安全的进行延迟加载
```java
public class SafeDoubleCheckedLocking{
        private static volatile Instance instance;

        public  static Instance getInstance() {
            if (instance == null) {
                synchronized (DoubleCheckedLocking.class) {
                    if (instance == null) {
                        instance = new Instance();
                    }
                }
            }
            return instance;
        }
    }
```
主要解决的问题就是让2 和3 执行位置不能进行交换，而volatile就能保证内存可见性 和禁止指令重排序的功能。
## 基于类初始化的解决方式
这里用到了一个我之前没有了解过得概念，就是`类初始化锁`（LC）.初始化一个类的静态变量，将对该类进行初始化，下面记录一下类被初始化的5种条件
* 一个类的类型被实例化创建时
* 类中声明的一个静态方法被调用时
* 类中一个静态变量被赋值时；
* 类中的一个静态变量被使用时，并且这个变量不是一个常量字段
* 类的一个顶级类，并且一个断言语句嵌套在类的内部被执行。

反正这个通过类初始化锁，可以保证只有一个类进行初始化，并且在他的初始化的时候不具备可见性（2）和（3）调换位置，并没有什么影响。
```java
public class DoubleCheckedLocking{
        private static class InstanceHandler{
            public static Instance instance = new Instance();
        }
        public  static Instance getInstance() {
            return InstanceHandler.instance;
        }
    }
```

这里就可以通过类初始化锁获得唯一的instance对象了，并且是static静态的数据。所以在不改变引用的情况下，都是使用第一次new出来的对象。

## 总结
这个概念还是很难理解，尤其是通过类初始化来解决单例的初始化，可以多google进行深入的理解。这个只是我进行记录的，感觉java的很多东西都是博大精深，要理解很久才能董一点皮毛（主要还是英语比较差）。以后一定要多多的理解一下java的很多东西，并且把英语搞好。
