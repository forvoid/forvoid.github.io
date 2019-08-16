---
title: 【Java进阶】--Java内部类学习笔记
date: 2017-5-01 14:50:49
tags:
- Java
---
## 为什么要有Java内部类的机制存在
> 可以将一个类的定义放在另一个类的定义内部的 这个类就叫做`内部类`
> 《java编程思想》

Java内部类的主要机制是用于实现多继承(因为我们都知道Java是单继承、多实现的方式，建立类与类之间的关系的)。
<!--more-->
## 内部类的好处
* 内部类可以有多个实例，每个实例有自己的状态。
* 在单个外围类中，可以让多个内部类以不同的方式实现同一个接口，或者继承同一个类。
* 内部类的创建随意，不依赖于外部。
* 内部类是一个独立的整体，没有`is-a`的承接关系。
* 可以实现更好的封装，private的话，只能内部调用。

内部类可以通过this 和 new的方式与外部类建立联系。
内部类可以直接使用外部类的任何方法和成员变量。

## Java内部类的种类极其介绍
Java的内部类主要有以下几种：
* 成员内部类
* 局部内部类（方法中）
* 匿名内部类
* 静态内部类

### 成员内部类
成员内部类主要是 把内部类当作 外部类的一个成员函数的方式一样去定义，也有权限修饰符，外部可以进行New 外部类 再new内部类的方式进行调用。
需要注意的是:
* 成员内部类中不存在任何static的变量和方法；
* 成员内部类是依附于外围类的，所以只有先创建了外围类才能够创建内部类。

```Java
//如果想要外部类访问的话，在非同包 非继承关系时 必须是用public，不然程序会报错。
public class ExternalClass {
    public String who ;//为public时外部才能访问
    public class InnerClass{//为public时非继承、非同包的才能访问。
        private String name;
        public String getName() {
            return name;
        }
        public void setName(String name) {
            this.name = name;
            who = name;
        }
    }
    public static void main(String[] args) {
        ExternalClass externalClass  = new ExternalClass();
        InnerClass innerClass =  externalClass.new InnerClass();//这个main是在当前类下的可以访问所以的private权限的东西。
        innerClass.setName("forvoid");
        System.out.println(innerClass.getName()+ "  "+ externalClass.who);
    }
}
```

### 局部内部类
局部内部类相当与类方法的局部变量，他有两个类型：
* 一个是定义在方法中
* 一个是定义在方法的某一条件中（作用域）

```Java
//用于在方法内部进行一些复杂的操作，或者进行继承其他的类，调用其方法
public class ExternalClass {
    public String who ;

    public int mothed(int min, int max){
        class InnerClass{
            public  int bigNumber(int min, int max){
                return min > max? max:min;
            }
        }
        return new InnerClass().bigNumber(min,max);

    }
    public static void main(String[] args) {
        ExternalClass externalClass = new ExternalClass();
        System.out.println(externalClass.mothed(4,10));
    }
}
```

作用域执行的方式的局部内部类。
```Java
public class ExternalClass {
    public String who ;

    public int mothed(int min, int max){
        if (min>0) {//只有在满足了作用域的情况下才执行
            class InnerClass {
                public int bigNumber(int min, int max) {
                    return min > max ? max : min;
                }
            }
            return new InnerClass().bigNumber(min, max);
        }
        return 0;
    }
    public static void main(String[] args) {
        ExternalClass externalClass = new ExternalClass();
        System.out.println(externalClass.mothed(4,10));
        System.out.println(externalClass.mothed(-1,10));
    }
}
```
### 匿名内部类（主要用于实现抽象、和接口）

1、 匿名内部类是没有访问修饰符的。
1、使用匿名内部类时，我们必须是继承一个类或者实现一个接口，但是两者不可兼得，同时也只能继承一个类或者实现一个接口。

2、匿名内部类中是不能定义构造函数的。

3、匿名内部类中不能存在任何的静态成员变量和静态方法。

4、匿名内部类为局部内部类，所以局部内部类的所有限制同样对匿名内部类生效。

5、匿名内部类不能是抽象的，它必须要实现继承的类或者实现的接口的所有抽象方法。

6、在内部类方法中已经被使用的变量应该设置为final。对于没有使用到的参数，是不需要设置为final的。
```Java
public abstract class InnerClass1 {
    public static void main(String[] args) {
        Runnable runnable = new Runnable() {//匿名内部类 实现接口和抽象类 或者添加或修改方法。
            @Override
            public void run() {
                System.out.println("innerClass");
            }
        };
        Thread t = new Thread(runnable);
        t.start();
        System.out.println("hello");
    }
}
```
```java
public static void main(String[] args) {
        Thread t = new Thread() {
            public void run() {
                for (int i = 1; i <= 5; i++) {
                    System.out.print(i + " ");
                }
            }
        };
        t.start();
        System.out.println("hello");
    }
```
### 静态内部类
Static可以修饰成员变量、方法、代码块，其他它还可以修饰内部类。
静态内部类与非静态内部类之间存在一个最大的区别，我们知道非静态内部类在编译完成之后会隐含地保存着一个引用，该引用是指向创建它的外围内，但是静态内部类却没有。没有这个引用就意味着：
1、 它的创建是不需要依赖于外围类的。

2、 它不能使用任何外围类的非static成员变量和方法。
```java
public abstract class InnerClass1 {

    public static class InnerClass{//可以在不创建父类的情况下直接运用该类.还可以在承压un方法中使用static 静态方法.
        public  void display(){
            System.out.println("display");
        }
    }
    public static void main(String[] args) {
        InnerClass1.InnerClass innerClass = new InnerClass1.InnerClass();
        innerClass.display();
    }
}
```
## 总结
内部类是java语言为了方便使用者调用，并且减少类数量的一种方式，还有就是为了解决 一个需要多继承的问题（在Swing中比较常见）,而设计的一种代码结构。
感觉需要很深入的理解，但是在日常生活中，我们的这个阶段还用的比较少。
