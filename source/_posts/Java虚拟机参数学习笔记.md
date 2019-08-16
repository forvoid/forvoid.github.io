---
title: Java虚拟机参数学习笔记
date: 2017-05-01 11:21:06
tags: 
	- javaVM
---
学习一些J常用的Java虚拟机参数，对系统进行跟踪和配置，对系统故障诊断、性能优化。
<!-- more -->
# 跟踪调试参数
## 读懂虚拟机日志
* 1、`-XX:+PrintGC`:使用这个参数启动Java虚拟机后，只要遇到GC就会打印
```
[GC  33280K->672K(125952K), 0.0010082 secs]
[GC  33952K->648K(125952K), 0.0007962 secs]
[GC  33928K->608K(125952K), 0.0006208 secs]
gc标志 gc前使用 gc后使用  总量   gc所用时间.
```
每次GC占用一行，`堆空间使用量`为33MB，GC后，`堆空间使用量`变为600K。`当前可用总和为`125MB.最后显示本次GC所用的总时间.

* 2、`-XX:PrintGCDetails` :输出更详细的信息，在退出前会打印堆的详细信息

```
[GC [PSYoungGen: 1016K->488K(1024K)] 1112K->612K(1536K), 0.0005786 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[Full GC [PSYoungGen: 1000K->71K(1024K)] [ParOldGen: 508K->460K(512K)] 1508K->532K(1536K), [Metaspace: 2597K->2597K(1056768K)], 0.0057408 secs] [Times: user=0.02 sys=0.00, real=0.01 secs] 
Heap
 PSYoungGen      total 1024K, used 218K [0x00000000ffe80000, 0x0000000100000000, 0x0000000100000000)
  eden space 512K, 38% used [0x00000000ffe80000,0x00000000ffeb0bf0,0x00000000fff00000)
  from space 512K, 4% used [0x00000000fff00000,0x00000000fff05cc0,0x00000000fff80000)
  to   space 512K, 0% used [0x00000000fff80000,0x00000000fff80000,0x0000000100000000)
 ParOldGen       total 512K, used 509K [0x00000000ffe00000, 0x00000000ffe80000, 0x00000000ffe80000)
  object space 512K, 99% used [0x00000000ffe00000,0x00000000ffe7f448,0x00000000ffe80000)
 Metaspace       used 2604K, capacity 4486K, committed 4864K, reserved 1056768K
  class space    used 288K, capacity 386K, committed 512K, reserved 1048576K
```
第一行是·`新生代GC`开始是新生代的效果，接着是整个堆的回收情况

第二行是`Full GC` 他回收新生代、老年代和永久区（元数据区）,第一个是新生代回收情况，第二个是老年代回收情况，第三个为整个堆空间回收情况，第四个是元数据区回收情况.第五个是整体的使用时间，第六个是时间分配情况

第三行是退出前打印堆的情况，使用的地址和比例等信息。

* 3、`-XX:+PrintHeapAtGC`:就是每次GC后显示显示GC回收前和GC回收后的堆信息。

```
{Heap before GC invocations=1 (full 0):
 PSYoungGen      total 1024K, used 505K [0x00000000ffe80000, 0x0000000100000000, 0x0000000100000000)
  eden space 512K, 98% used [0x00000000ffe80000,0x00000000ffefe7d8,0x00000000fff00000)
  from space 512K, 0% used [0x00000000fff80000,0x00000000fff80000,0x0000000100000000)
  to   space 512K, 0% used [0x00000000fff00000,0x00000000fff00000,0x00000000fff80000)
 ParOldGen       total 512K, used 0K [0x00000000ffe00000, 0x00000000ffe80000, 0x00000000ffe80000)
  object space 512K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000ffe80000)
 Metaspace       used 1857K, capacity 4480K, committed 4480K, reserved 1056768K
  class space    used 210K, capacity 384K, committed 384K, reserved 1048576K
Heap after GC invocations=1 (full 0):
 PSYoungGen      total 1024K, used 504K [0x00000000ffe80000, 0x0000000100000000, 0x0000000100000000)
  eden space 512K, 0% used [0x00000000ffe80000,0x00000000ffe80000,0x00000000fff00000)
  from space 512K, 98% used [0x00000000fff00000,0x00000000fff7e010,0x00000000fff80000)
  to   space 512K, 0% used [0x00000000fff80000,0x00000000fff80000,0x0000000100000000)
 ParOldGen       total 512K, used 0K [0x00000000ffe00000, 0x00000000ffe80000, 0x00000000ffe80000)
  object space 512K, 0% used [0x00000000ffe00000,0x00000000ffe00000,0x00000000ffe80000)
 Metaspace       used 1857K, capacity 4480K, committed 4480K, reserved 1056768K
  class space    used 210K, capacity 384K, committed 384K, reserved 1048576K
}
```
* `-XX:+PrintReferenceGC`:跟踪软引用、弱引用、虚引用。
* `-Xloggc:d:/gc.log`：指定一个文件夹记录GC日志。

## 类加载、卸载的跟踪
* `-XX:+TraceClassUnloading` 和 `-XX:+TraceClassLoading`输出类的加载和卸载过程。
```
[Loaded java.lang.Void from C:\Program Files\Java\jre1.8.0_121\lib\rt.jar]
[Loaded com.OnstackTest$User from file:/D:/workCode/workspace/JVMTest/bin/]
```
* ` -XX:+PrintVMOptions`：显示虚拟机接受到命令行显示参数
```
VM option '+PrintVMOptions'
VM option '+PrintGC'
```
* `-XX:+PrintCommandLineFlags`:显示虚拟机的显示和隐式参数
```
-XX:InitialHeapSize=1048576 -XX:MaxHeapSize=1048576 -XX:+PrintCommandLineFlags -XX:+PrintGC -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:-UseLargePagesIndividualAllocation -XX:+UseParallelGC 
```
* `-XX:+PrintFlagsFinal`:打印所有的系统参数值
```
[Global flags]
    uintx AdaptiveSizeDecrementScaleFactor          = 4                                   {product}
    uintx AdaptiveSizeMajorGCDecayTimeScale         = 10                                  {product}
    uintx AdaptiveSizePausePolicy                   = 0                                   {product}
    略。。。
```

# 堆配置参数
主要介绍与堆有关的参数配置，对程序性能有着重要影响。
## 最大堆和初始堆的设置

* -Xms[128K]:初始化堆的大小，Java虚拟机会尽可能的维护在初始堆空间范围内运行，如果初始堆空间耗尽，虚拟机将会对堆空间进行扩展。
* -Xmx[32M]：堆的最大空间，就是堆空间的上限。

> -XX:InitialHeapSize=5242880 -XX:MaxHeapSize=20971520 -XX:+PrintCommandLineFlags -XX:+PrintGCDetails 
  -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:-UseLargePagesIndividualAllocation -XX:+UseSerialGC 
  
当申请的空间大于了初始空间，使用空间将翻倍直至与最大空间相同。使用的空间等于 total - free

```
maxMemory= 20316160 bytes 最大20M
free mem = 5277784bytes   空闲5M
total mem = 6094848bytes  总共有6M

maxMemory= 20316160 bytes
free mem = 4532784bytes
total mem = 10358784bytes
```
## 新生代配置
* -Xmn[125K]：用于设置`新生代`的大小。设置一个较大的新生代会减小老年代的大小，（一般新生代设置为整个堆空间的1/3或者1/4）。
* -XX:SurvivorRatio=eden/from = eden/to:用于设置新生代中`eden`区和`from`区的比例关系.
```
-Xms20M -Xmx20M -Xmn1M -XX:SurvivorRatio=2 -XX:+PrintGCDetails  -XX:+UseSerialGC
```
```
Heap
 def new generation   total 768K（eden+to）, used 515K [0x00000000fec00000, 0x00000000fed00000, 0x00000000fed00000)
  eden space 512K,  50% used [0x00000000fec00000, 0x00000000fec40c40, 0x00000000fec80000)
  from space 256K, 100% used [0x00000000fecc0000, 0x00000000fed00000, 0x00000000fed00000)
  to   space 256K,   0% used [0x00000000fec80000, 0x00000000fec80000, 0x00000000fecc0000)
 tenured generation   total 19456K, used 10415K [0x00000000fed00000, 0x0000000100000000, 0x0000000100000000)
   the space 19456K,  53% used [0x00000000fed00000, 0x00000000ff72bee8, 0x00000000ff72c000, 0x0000000100000000)
 Metaspace       used 2599K, capacity 4486K, committed 4864K, reserved 1056768K
  class space    used 288K, capacity 386K, committed 512K, reserved 1048576K
```
> 尽可能的将对象预留在新生代，减少老年代GC的次数

* -XX:NewRatio=老年代/新生代:设置老年代与新生代的比例.(Xms=Xmx并且设置了Xmn的情况下，该参数不需要进行设置,当设置了新生代Xmn的大小后不需要设置)。
```
-Xms20M -Xmx20M  -XX:NewRatio=2 -XX:+PrintGCDetails -XX:+UseSerialGC
```
![堆参数分配示意图](/images/Java_VM/new_old_perm.png)
## 堆溢出
* `-XX:+HeapDumpOnOutOfMemoryError`和`-XX:HeapDumpPath`排查堆溢出.

```
-Xms20M -Xmx20M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=d:/d.hprof  -XX:+UseSerialGC
```

# 非堆内存参数配置
## 方法区分配
在jdk1.6 1.7版本中使用，默认最大为64M
* `-XX:PermSize`:永久区初始大小
* `-XX:MaxPermSize`:永久区最大空间大小

在jdk1.8中，使用metaspace，不指定的话就是整个系统内存大学
* `-XX:MaxMetaspaceSize`：指定永久区的最大可用

## 栈分配
* `-Xss`：指定线程的栈的大小。
## 直接内存大小（DirectMemory）
直接内存跳过Java堆，让Java程序直接访问系统原生堆空间，提高内存的访问速度(一般情况下）。
* `-XX:MaxDirectMemorySize`：Java的最大可用直接内存。当直接内存到达最大值时，将进行GC，不能放出足够的内存时，将抛出OOM错误。

> 直接内存（DirectMemory）适合请求次数少，使用频繁的场合，如果频繁申请不适合直接内存。


# 虚拟机工作模式
虚拟机的工作模式有两种Client 和 Server 

* `-client` 指定使用client模式，系统可分配最大堆256MB
* `-server` 指定使用server模式，比client启动慢，指令执行优化更高，64位只有该模式。系统可分配最大堆1GB

