---
title: Java虚拟机垃圾回收概念和算法
date: 2017-05-08 10:13:56
tags:
	- javaVM	
---
# 认识垃圾回事
垃圾回收（Garbage Collection）是指在内存中不会被使用的对象进行内存的回收，以提高内存的利用率。如果不回收将有可能会导致内存的溢出，Java的垃圾回收是由Java虚拟机提供的程序员不需要进行垃圾回收处理。
<!--more-->
# 常用的垃圾回收算法
## 引用数据算法
原理：当一个对象有任何其他对象或者自己引用它时，它的引用计数器就加一，当引用失效时，引用计数器就减一。如果对象的引用计数器为0，则对象就不可能再被使用了。

问题：
* 无法处理循环引用的情况（对象相互引用）。
* 每次都伴随着加法和减法操作，对系统性能会有一定的影响。

## 标记清除法（Mark-Sweep）
本方法是现代垃圾回收的思想基础。分为两个阶段`标记阶段`和`清除阶段`.

在标记阶段，首先通过根节点，标记所以从`根节点`开始的`可达对象`，未被标记的就是垃圾对象。

在清理阶段，清除所以未被标记的对象。将产生空间碎片。
## 复制算法（Copying）
核心思想： 将原有的空间分为两块，每次只是用其中的一块，在垃圾回收时，将正在使用的内存中的存活对象复制到未使用的内存块中，之后清理正在使用的内存块中所以的对象。交换两个内存的角色。

确保了没有空间碎片，但是将系统内存折半。

在Java新生代串行垃圾回收器中。使用了垃圾回收算法。from和to空间视为用于复制的两个大小相等，

在存活对象少，垃圾对象多时，算法最高效

## 标记压缩算法（Mark-Compact）
标记压缩算法是一个老年代的回收算法，在标记清除算法的基础上做了优化。也是两个阶段`标记阶段`和`清理阶段`

在标记阶段：从根节点开始对所以的可达对象做一次标记。

在清理阶段：对所以的存活对象压缩到内存的一端。之后清理边界外所以的内存空间。

避免了内存空间碎片，又不需要两个相同的内存空间。性价比较高。等同于垃圾回收进行了一次`标记清理算法`后再进行了一次`内存碎片整理`
## 分代算法（Generational Collecting）
根据垃圾回收对象的特性，使用合适的算法回收。分代算法：将内存区间根据对象的特性分成几块，根据每块内存空间的内存区间特点，使用不同的回收算法，提高垃圾回收的效率。

Java虚拟机所以新建的对象都放入`新生代`的内存区域，（对象特点朝生夕灭），大约90%的新建对象都会很快的被回收，因此新生代比较适合`复杂算法`.当新生代经过几次回收后依然活着，对象就会进入`老年代`。在老年代中，几乎所有的对象都是经过了几次垃圾回收后依然存活的对象，可以认为是一段时期内常驻内存的，对老年代进行`标记压缩算法`或者`标记清除算法`可以提高垃圾回收效率。

通常： 新生代频率高，耗时少。老年代频率低，耗时多。
## 分区算法（Region）
分代是将对象按照生命周期的长短划分成两个部分，分区算法是将整个堆空间划分成连续的不同的 小区间，每个小区间都`独立使用`，`独立回收`。

在相同情况下，堆空间越大，一次GC的时间就越长，从而产生的停顿也越长，根据目标的停顿时间，每次合理的进行回收若干个小区间，而不是整个堆空间，从而减少一次GC所产生的停顿。提高效率。

# 判断对象的可触及性（复活对象）
可触及性包括以下三个状态：
* 可触及的：从根节点开始，可以到达这个对象。
* 可复活的：对象的所以引用都被释放，但是对象有可能在finalize()函数中复活。
* 不可触及的：对象的finalize()函数被调用，并且没有被复活，不可触及对象不可能复活，因为finalize()函数只会被调用一次

以上三种情况只有`不可触及`时才肯被回收。
实例
```
package com;

public class CanReliveObj {
	public static CanReliveObj obj;
	
	protected void finalize() throws Throwable {//只会被调用一次(可复活的
		super.finalize();
		System.out.println("Can ReliveObj finalize called");
		obj = this;
	}
	@Override
	public String toString() {
		// TODO Auto-generated method stub
		return "I am CanReliveObj";
	}
	public static void main(String[] args) throws InterruptedException{
		obj = new CanReliveObj();
		obj = null;
		System.gc();
		Thread.sleep(1000);
		if (obj == null) {
			System.out.println("Obj is null");
			
		}else {
			System.out.println("Obj useful");
		}
		System.out.println("第二次gc");
		obj = null;
		System.gc();
		Thread.sleep(1000);
		if (obj == null) {
			System.out.println("Obj is null");
			
		}else {
			System.out.println("Obj useful");
		}
	}
}
```
运行结果:
```
Can ReliveObj finalize called
Obj useful
第二次gc
Obj is null
```
## 关于对象的引用
对象引用包括了四种方式他们都有对GC不同的反映，[点击查看Java对象的引用方式](../../../../2017/04/23/Java引用类型及分析/)
# 垃圾回收时的停顿现象
垃圾回收器的任务是：识别和回收垃圾对象进行内存清理。为了让垃圾回收器可以正常高效的工作，大部分情况下会要求系统进入一个停顿的时间。目的是：终止所以应用线程的执行。（Stop-The-World）STW。
实例
```
package com;
import java.util.HashMap;
import javax.swing.text.Position.Bias;

/**
 * 观察停顿现象
 * @author forvoid
 *-Xmx1g -Xms1g -Xmn1024k -XX:+UseSerialGC -Xloggc:d:\gc.log -XX:+PrintGCDetails
 */
public class StopWorldTest {
	public static class MyThread extends Thread {
		
	
		HashMap map = new HashMap<>();
		public void run() {
		
			try{
			while(true) {
				if (map.size()*512/1024/1024>=900) {
					map.clear();
					System.out.println("clean map");
				}
				byte[] b1;
				for(int i = 0; i< 100;i++){
					b1 = new byte[512];
					map.put(System.nanoTime(), b1);
					
				}
				Thread.sleep(1);
			}
			}catch (Exception e) {
				// TODO: handle exception
			}
		}
	}
	public static class PrintThread extends Thread{
		public static final long starttime = System.currentTimeMillis();
		public void run(){
			while(true){
				long t = System.currentTimeMillis() - starttime;
				System.out.println(t/1000+"."+t%1000);
				try {
					Thread.sleep(100);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}
	public static void main(String[] args){
		MyThread thread = new MyThread();
		PrintThread printThread = new PrintThread();
		thread.start();
		printThread.start();
	}
	
}
```
```
23.742
23.842
```
log
```
23.743: [GC (Allocation Failure) 23.743: [DefNew: 959K->64K(960K), 0.0088708 secs] 582614K->582413K(1048512K), 0.0089818 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
23.770: [GC (Allocation Failure) 23.770: [DefNew: 960K->64K(960K), 0.0067947 secs] 583309K->583100K(1048512K), 0.0068949 secs] [Times: user=0.01 sys=0.00, real=0.01 secs] 
23.807: [GC (Allocation Failure) 23.808: [DefNew: 960K->64K(960K), 0.0077419 secs] 583996K->583767K(1048512K), 0.0078460 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
23.834: [GC (Allocation Failure) 23.834: [DefNew: 960K->63K(960K), 0.0092173 secs] 584663K->584508K(1048512K), 0.0093496 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
```
