---
title: MySQL数据库安装与配置
date: 2017-05-10 10:02:33
tags:
	- MySQL
---
很久之前就一直在搞MySQL数据库，每次都是在网上google或者baidu一大堆文章然后按照对应的方式输入，傻瓜式的学习。然后有需要又重复一边，唉，受不了现在自己总结一下时时更新一波。为自己做点知识笔记。
### 更新说明
2017/5/10:加入了Mysql7在win10、centos7下的安装配置说明（win10是免安装的压缩包，centos是rpm）
<!--more-->

## 各操作系统的通用配置
## windows环境下进行MySQL数据库的安装
讲解主要分为以下几个步骤：
* 如何下载免安装包
* 如何安装
* 如何配置数据库的密码

### 下载免安装版
下载地址`https://dev.mysql.com/downloads/mysql/`一般都是这个，然后可以用迅雷要快一点。下载完成后
![下载界面](/images/MySQL/upload_win_zip.png)
### 怎样安装
我们按照步骤一步一步进行
* 1、先进行压缩包解压，放入对应的位置
* 2、然后打开cmd（以管理员的权限）、进入MySQL的bin文件夹下面
* 3、输入
```
mysqld install
```
返回结果说`Service successfully installed`说明服务器已经被创建。（如果要取消mysql服务可以输入`mysqld remove MySQL`）
* 4、接下来我们用`mysqld  --initialize --console`先初始化data目录。要不然mysql5.7的文件夹下面不会出现
    data文件夹.

    注意：mysqld  --initialize 如果不加 --console 会在data目录下生成xxx.err的文件
    
** 特别注意：**初始化完成后生成一个临时登录密码
```
[Note] A temporary password is generated for root@localhost: a7(GfdodYNeQ//这个就是临时密码
```

* 5、接着就是在输入net start mysql启动服务。或者不嫌麻烦的话，就手动启动。打开服务，启动mysql服务。到这里基本就完成了，mysql的安装啦。（mysql 会自动的在path中加入环境不用担心，cmd mysql查找不到的情况）
### 如何配置数据库密码
用第二部分的临时密码登录MySQL shell 
```
mysql -uroo -p [数据库临时密码]
```
然后登陆后输入即可修改密码
```
alter user root@'localhost' identified by '[新密码]';
```
### 忘记密码处理

```
存在问题解决：（忘记密码处理）

1、 好了，坑来了。以前我们安装mysql，root用户是不需要密码的，从mysql5.7开始不行了。坑了我一小
    会，我就记得我没设置密码啊，莫名其妙我竟然开始慌了。ERROR 1045 (28000): Access denied for
    user'root'@'localhost'(using password: NO)，好心塞啊。

2、别慌，跟着我先关闭mysql服务。

3、在提示命令管理工具输入如下命令，进入安全模式：mysqld --defaults-file="E:\mysql5.7\my.ini" --
    console --skip-grant-tables，这里的路径需要根据你安装的实际路径修改。好的，这个窗口我们让它就这
    么运行，然后重新打开一个命令提示窗口，记得一定是管理员权限。

4、接着我们重新以管理员身份打开一个dos窗口，继续输入用户名和密码登陆，

    mysql –u root –p  回车

哇塞成功了。别急，这只是第一步。接下来我们还是要修改root的默认密码。

5、 接着，我们来选择当前使用的数据库：输入use mysql；

    然后尝试修改密码，艾玛，字段不对。

    5.1、进入mysql数据库：

    mysql> use mysql;

    Database changed

    5.2、给root用户设置新密码

        mysql> update user set authentication_string=password('新密码') where user='root';

        Query OK,1 rows affected(0.01 sec)Rows matched:1 Changed:1Warnings: 0

    5.3、刷新数据库 （一定要记得刷新）：mysql>flush privileges; 

            QueryOK, 0 rows affected (0.00 sec)

    5.4、退出：mysql：mysql> quit

下次输入mysql -uroot -p 就可以用新密码登录了。
```
[引用链接:mysql-5.7.11-winx64 免安装版配置及密码问题处理](https://my.oschina.net/pmos/blog/620860)
## CentOS7安装MySQL数据库(RPM安装方式)
### Step 1 设置引用
进入网站
```
https://dev.mysql.com/downloads/repo/yum/
```
查看最新版本
然后在shell中输入
```
wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm # 这个可以换成你在网站中看到的最新版本.
```
然后用md5校验一下完整性正确性
```
md5sum mysql57-community-release-el7-9.noarch.rpm
```
输入依赖
```
sudo rpm -ivh mysql57-community-release-el7-9.noarch.rpm
```
然后rpm请求安装
```
sudo yum install mysql-server
```
### Step 2 启动数据库并载入
输入内容启动数据库
```
sudo systemctl start mysqld
```
启动后可以查看数据库的状态
```
sudo systemctl status mysqld
```
> If MySQL has successfully started, the output should contain Active: active (running) and the final line should look something like
> 
> Note: MySQL is automatically enabled to start at boot when it is installed. You can change that default behavior with sudo systemctl disable mysqld
然后查找数据库的临时密码
```
sudo grep 'temporary password' /var/log/mysqld.log
```
查找结果中
```
2016-12-01T00:22:31.416107Z 1 [Note] A temporary password is generated for root@localhost: mqRfBU_3Xk>r //这个就是数据库的临时密码
```
### 配置数据库
主要是输入新的密码和一下信息的确认
```
sudo mysql_secure_installation
```
跟着步骤走就行了

### 学习引用的博客
* [https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7)
* [https://www.linode.com/docs/databases/mysql/how-to-install-mysql-on-centos-7](https://www.linode.com/docs/databases/mysql/how-to-install-mysql-on-centos-7)