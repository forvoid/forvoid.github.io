---
title: Java引用类型及分析
date: 2017-04-23 23:35:21
tags: 
 	- Java
---
# Java引用类型及分析
> 今天学习了java的引用类型和他的具体是在jvm垃圾回收中是如何使用的。强引用就是一般的引用，其他的引用都在java.lang.ref 包中


<!-- more -->
## Java 引用类型分类
* 强引用
* 软引用
* 弱引用
* 虚引用

## 强引用
就是我们一般用java写引用的类型比如说
>  Object o = new Object();

这个就是强引用类型的一个例子.大概分析一下。先声明一个Object的变量o分配在Java stack，然后变量o指向引用由Java heap分配的一个Object对象

强引用的具备以下特点
* 可直接访问目标对象
* 指向的对象在任何时候都不会被系统回收，（及时抛出OOM）
* 强引用可能导致内存溢出


## 软引用
**当堆空间不足时，就会被回收**。GC未必会回收软引用的对象。但是当内存资料紧张时软引用对象会被回收。所以软引用不会导致内存溢出（OOM）import java.lang.ref.SoftReference;

事例



```
package com;

import java.lang.ref.ReferenceQueue;
import java.lang.ref.SoftReference;
/**
 * -Xmx10m -XX:+UseSerialGC*/
public class SoftRefQ {
	public static class User{
		public User(int id, String name) {
			this.id = id;
			this.name = name;
		}
		private int id;
		private String name;
		public int getId() {
			return id;
		}
		public void setId(int id) {
			this.id = id;
		}
		public String getName() {
			return name;
		}
		public void setName(String name) {
			this.name = name;
		}
		@Override
		public String toString() {
			return "User [id=" + id + ", name=" + name + "]";
		}
	}
	static ReferenceQueue<User> softQueue = null;
	public static class CheckRefQueue extends Thread {//当软引用被回收是将进入这个引用队列
			public void run() {
				while(true) {
					if (softQueue != null) {
						UserSoftReference obj = null;
						try{
							obj = (UserSoftReference) softQueue.remove(); 
						}catch (InterruptedException e) {
							e.printStackTrace();
						}
						if (obj != null) {
							System.out.println("user id " + obj.uid + " is delete");
						}
					}
				}
			}
	}
	public static class UserSoftReference extends SoftReference<User> {
		int uid;
		public UserSoftReference(User referent, ReferenceQueue<? super User> q){
			super(referent,q);
			uid = referent.id;
		}
	}
	public static void main(String[] args) throws InterruptedException{
		Thread thread = new CheckRefQueue();
		thread.setDaemon(true);
		thread.start();
		User user = new User(1, "geym");
		softQueue = new ReferenceQueue<>();
		UserSoftReference userSoftReference = new UserSoftReference(user, softQueue);
		user = null;
		System.out.println(userSoftReference.get());
		System.gc();
		//内存足够不会回收
		System.out.println("After GC");
		System.out.println(userSoftReference.get());
		
		System.out.println("try to create byte array and GC");
		byte[] b= new byte[1024*925*7];
		System.gc();
		System.out.println(userSoftReference.get());
		Thread.sleep(1000);
	}
}
```
结果
```
User [id=1, name=geym]
After GC
User [id=1, name=geym]
try to create byte array and GC
user id 1 is delete//当堆空间不满足时，就自动回收掉软引用
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
	at com.SoftRefQ.main(SoftRefQ.java:71)
```

## 弱引用-发现既回收
**在GC系统中，只要发现弱引用，都会对对象进行回收**,一旦对象被垃圾回收器回收，就会加入到一个注册的引用队列中。使用
import java.lang.ref.WeakReference;

实例

```
package com;

import java.lang.ref.WeakReference;

public class WeakRef {
	public static class User{
		public User(int id, String name) {
			this.id = id;
			this.name = name;
		}
		private int id;
		private String name;
		public int getId() {
			return id;
		}
		public void setId(int id) {
			this.id = id;
		}
		public String getName() {
			return name;
		}
		public void setName(String name) {
			this.name = name;
		}
		@Override
		public String toString() {
			return "User [id=" + id + ", name=" + name + "]";
		}
	}
	public static void main(String[] args) {
		User user = new User(1, "geym");
		WeakReference<User> userWeakRef = new WeakReference<User>(user);
		user = null;
		System.out.println(userWeakRef.get());
		System.gc();
		//不管内存是否满足都将回收他的内存
		System.out.println("After GC");
		System.out.println(userWeakRef.get());
	}

}
```
结果

```
User [id=1, name=geym]
After GC
null
```

## 虚引用-对象回收跟踪
**作用在于跟踪垃圾回收的过程**,一个持有虚引用的对象，和没有引用几乎是一样的，随时都有可能被垃圾回收。试图通过get（）获得强引用，总会失败。并且虚引用必须和引用队列一起使用.

由于虚引用可以跟踪对象的回收时间，可以将一些资源释放操作放置在虚引用执行和记录中。

事例
```
package com;

import java.lang.ref.PhantomReference;
import java.lang.ref.ReferenceQueue;
import java.lang.ref.SoftReference;

import com.SoftRefQ.CheckRefQueue;
import com.SoftRefQ.User;
import com.SoftRefQ.UserSoftReference;

public class TraceCanReliveObj {
	public static TraceCanReliveObj obj;
	static ReferenceQueue<TraceCanReliveObj> phantomQueue = null;
	public static class CheckRefQueue extends Thread {
			public void run() {
				while(true) {
					if (phantomQueue != null) {
						PhantomReference<TraceCanReliveObj> obj = null;
						try{
							obj = (PhantomReference<TraceCanReliveObj> ) phantomQueue.remove(); 
						}catch (InterruptedException e) {
							e.printStackTrace();
						}
						if (obj != null) {
							System.out.println("TraceCanReliveObj " + " is delete");
						}
					}
				}
			}
	}
	public void finalize() throws Throwable{
		super.finalize();
		System.out.println("CanReliveObj finalize called");
	}
	@Override
	public String toString() {
		return "I am CanReliveObj";
	}
	public static void main(String[] args) throws InterruptedException{
		Thread thread = new CheckRefQueue();
		thread.setDaemon(true);
		thread.start();
		
		phantomQueue =new ReferenceQueue<TraceCanReliveObj>();
		obj = new TraceCanReliveObj();
		PhantomReference<TraceCanReliveObj> userSoftReference = new PhantomReference<TraceCanReliveObj>(obj, phantomQueue);
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
结果
```
CanReliveObj finalize called
Obj is null
第二次gc
TraceCanReliveObj  is delete
Obj is null
```
## 总结
java的引用方式有很多种，一般使用的是：强引用，这也是java虚拟机不可触及性的一个重要依据；软引用是可以用作缓存使用的。当堆空间满时将对其进行回收；弱引用是只要遇到GC就被回收；虚引用无法获取get只能在其引用对象被gc后进入引用队列（用于跟踪对象的回收和非内存资源的释放）。