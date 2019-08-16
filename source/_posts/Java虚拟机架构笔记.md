---
title: Java虚拟机架构笔记
date: 2017-04-30 23:20:44
tags: javaVM
---
# java虚拟机的基本结构
给图java的基本结构：
![Java的基本结构](/images/Java_VM/JavaVM_base.png)
<!-- more-->
> * 1、类加载结构：从文件系统或者网络中加载Class信息，类信息放入方法区的内存空间。
> * 2、方法区：方法区存放类的信息，运行时常量池信息，（包括字符串字面量、数字常量）
> * 3、Java堆：几乎所有的类的实例（对象）都存放在这里，这也是GC发生的主要区域。是线程共享空间。
> * 4、直接内存：NIO允许Java程序使用直接内存，直接内存的大小不受Java堆的限制，受系统内存的大小限制。
> * 5、Java栈：每个Java的线程都会有一个私有Java栈，Java栈中保存着局部变量、方法参数、同时和java方法的调用、返回相关
> * 6、本地方法栈：和Java栈类似，作为本地方法的调用
> * 7、Pc寄存器（程序计数器）：每个线程私有的，pc寄存器会指向当前正在被执行的指令。
> * 9、执行引擎：Java虚拟机核心组件，负责执行虚拟机字节码。

垃圾回收系统（GC）：对方法区、Java堆和直接内存进行回收。

# Java堆
> Java堆是GC的重点区域，Java几乎所有对象都存放在这里。


![java堆分区](/images/Java_VM/new_tenured.png)

根据垃圾回收的机制不同，Java堆可能拥有不同的结构。常见结构为`新生代`和`老年代`

* 新生代存放新生的对象或者年龄不大的对象，其中分为了eden、s0(from)、s1(to)三个区。from和to大小相等可以互换角色。
* 老年代存放比较长久的对象：1、当eden区满后GC，并且from或者to也满时，直接进入老年代；2、在to或者from区的对象，每经过一次新生代GC年龄都加一，年龄到达一定条件，进入老年代。

> Java堆在调用Java指令调用时的内存情况

![堆、方法区、栈的关系](/images/Java_VM/Object_call_VM.png)

# Java栈
> Java栈是线程私有的内存空间。Java栈与线程执行密切相关，每次函数调用的数据都是通过Java线程传递的。

Java栈只支持入栈和出栈，Java栈中保存的内容为`栈帧`，当前帧在栈顶，保存着`局部变量`、`中间运算结果`等.
当return、或者发生异常时栈帧弹出。

一个栈帧中包含`局部变量表`、`操作数`、`帧数据区`几个部分。

![栈的基本结构图](/images/Java_VM/stack_base_structure.png)

*如果栈帧的空间不足和当请求深度大于最大可用深度时，系统会抛出StackOverFlowError错误*
```
public class TestStackDeep {
	private static int count = 0;
	public static void recursion(){
		count++;
		recursion();
	}
	public static void main(String[] args) {
		try {
			recursion();
		} catch (Throwable e) {
			System.out.println("deep of calling = " + count);
			// TODO: handle exception
			e.printStackTrace();
		}
	}
}
当-Xss128K
deep of calling = 1100
java.lang.StackOverflowError
当-Xss256K
deep of calling = 2838
java.lang.StackOverflowError
```
函数嵌套层次由栈的大小决定，越大，就嵌套调用越多

## 局部变量表
> 保存函数的参数、局部变量。局部变量只在表中有效，栈帧销毁后就没有了。

* long double 2个字，int short byte 对象引用 1个字。* 字在32位机中表示4个字节*


如果函数的局部变量和参数较多，会使局部变量表膨胀，->导致函数嵌套次数减少.
```
public class TestStackDeep {
	private static int count = 0;
	public static void recursion(long a, long b, long c){
		long e = 1, f = 2, g = 3, h = 4, i = 5, j = 6, k = 7, q = 8, x = 9, z = 10;
		count++;
		recursion(a,b,c);
	}
	public static void main(String[] args) {
		try {
			recursion(0L,0L,0L);
		} catch (Throwable e) {
			System.out.println("deep of calling = " + count);
			// TODO: handle exception
			e.printStackTrace();
		}
	}
}
当-Xss128K
deep of calling = 305
java.lang.StackOverflowError
当-Xss256K
deep of calling = 760
java.lang.StackOverflowError
```
> 局部变量表也是垃圾回收根节点，被局部变量表中直接引用或者间接引用的都不会被回收。
> 
> `finalize()和gc()`
> 
> (1)问题:finalize()函数是干嘛的?Java不是有Garbage Collection(以下简称gc)来负责回收内存吗?
回答:
`gc 只能清除在堆上分配的内存`(纯java语言的所有对象都在堆上使用new分配内存),而不能清除栈上分配的内存（当使用JNI技术时,可能会在栈上分配内存,例如java调用c程序，而该c程序使用malloc分配内存时）.因此,`如果某些对象被分配了栈上的内存区域,那gc就管不着了,对这样的对象进行内存回收就要靠finalize()`.
> 
>    举个例子来说,当java 调用非java方法时（这种方法可能是c或是c++的）,在非java代码内部也许调用了c的malloc()函数来分配内存，而且除非调用那个了 free() 否则不会释放内存(因为free()是c的函数),这个时候要进行释放内存的工作,gc是不起作用的,因而需要在finalize()内部的一个固有方法调用它(free()).
>    
> finalize的工作原理应该是这样的：`一旦垃圾收集器准备好释放对象占用的存储空间，它首先调用finalize()，而且只有在下一次垃圾收集过程中，才会真正回收对象的内存.所以如果使用finalize()，就可以在垃圾收集期间进行一些重要的清除或清扫工作.`

> (2)问题:finalize()在什么时候被调用?
> 有三种情况
> 
> 1.所有对象被Garbage Collection时自动调用,比如运行System.gc()的时候.
> 
> 2.程序退出时为每个对象调用一次finalize方法。
> 
>  3.显式的调用finalize方法

> 除此以外,正常情况下,当某个对象被系统收集为无用信息的时候,finalize()将被自动调用,但是jvm不保证finalize()一定被调用,也就是说,finalize()的调用是不确定的,这也就是为什么sun不提倡使用finalize()的原因. 简单来讲，finalize()是在对象被GC回收前会调用的方法，而`System.gc()强制GC开始回收工作纠正，不是强制，是建议，具体执行要看GC的意思。简单地说，调用了 System.gc() 之后，java 在内存回收过程中就会调用那些要被回收的对象的 finalize() 方法`.

## 操作数栈
> 保存计算过程中的中间结果，作为计算过程中变量临时的存储空间。

## 帧数据区
> 保存访问常量池的指针，方便程序访问常量池；和保存`异常处理表`.

## 栈上分配
> Java虚拟就提供的一项优化技术，基本思想是：对于那些线程私有的对象，可以将他们打散分配到栈上。可以在函数调用结束后自行销毁，提高系统性能。

栈上分配的技术基础是：进行`逃逸分析`（判断对象的作用域是否有可能逃逸出函数体），没有逃逸体就可以进行栈上分配。在Server模式下才能就行逃逸分析(-XX:+DoEscapeAnalysis启用逃逸分析),`标量替换`(-XX:+EliminateAllocations)允许将对象打散分配到栈上

栈上分配通过逃逸分析和标量替换实现。不适合大对象.
# 方法区
> 方法区是线程共享的内存区域。用于保存系统的类信息（类的字段、方法、常量池）.方法区的大小决定了类可以保存多少类。

* 在1.6，1.7中方法区理解为`永久区(Perm)`用-XX:PermSize和-XX:MaxPermSize指定.
* 1.8时，永久区被彻底移除，取而代之的是`元数据区`大小用-X:MaxMetaspaceSize指定,这个是堆外的`直接内存`如果不指定大小，在默认的情况下会耗尽所有的可用系统内存.