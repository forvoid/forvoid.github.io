---
title: centos7zookeeper集群安装与坑的解决
tags:
- zookeeper
categories:
- 分布式服务
---



在大数据工具中很多都使用到了zookeeper做为公共配置服务，为分布式应用提供了高效高可用的分布式协调服务，在很多大型的分布式系统中都使用到了zookeeper作为协调的工具。为了更好的理解zookeeper也为了，可以接下来自己搭建kafka、dobble、hadoop等服务，我需要先搭建zookeeper。这里记录一下我自己搭建zookeeper的步骤、方法和遇到的一些坑，总结一下。怕自己下次忘记。
<!-- more -->

# 安装zookeeper

## 安装前准备

1、这里我采用了三台云服务器作为安装zookeeper集群的服务器。他们分别的hostname为 `fv_al_pt01` `fv_al_pt02` `fv_al_pt03` 我在 /etc/hosts中设置了 我的不同主机的ip 对应的主机名，使用主机名的目的是不用记录每一个机器的ip 如下图：

![hosts.png](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/zookeeper/hosts_alias.png)

2、每台云服务器都需要进行jdk的安装。这里我安装的时jdk8，并配置好了环境变量

3、从网上下载对应的zookeeper安装包，并分发到三台云服务器中。我通过scp 将安装包放入了/home/work/目录下

## 将安装包放入到对应的位置并解压

```shell
# 对 zookeeper 放入到对应的位置并解压
cd /home/work
mkdir -p /usr/local/zookeeper
mv /home/work/zookeeper-3.4.12.tar.gz /usr/local/zookeeper/
cd /usr/local/zookeeper
tar -zxvf zookeeper-3.4.12.tar.gz
mv zookeeper-3.4.12 zookeeper-3.4
rm -rf zookeeper-3.4.12.tar.gz
```

将zookeeper的安装包放入到/usr/local/zookeeper中，并进行解压，修改名称，然后删除安装包


## 配置环境变量
在zookeeper服务器启动的时候是有环境变量的要求的，所有我们需要将zookeeper的bin包的地址配置到环境变量中。

```shell
# 配置环境变量并生效
echo -e "# append zk_env\nexport PATH=$PATH:/usr/local/zookeeper/zookeeper-3.4/bin" > /home/work/env/zk_env
chmod 700 /home/work/env/zk_env
echo -e "# append zk_env \nsource /home/work/env/zk_env
```

这里将zookeeper的环境变量设置语句放在了 /home/work/env/中，然后再在/etc/profile中调用 我们设置的环境变量。

## 配置zookeeper启动所需要的配置信息

zk启动是会去读取zookeeper程序目录下的conf/zoo.cfg文件的，并且没法将文件放置在其他的地方。这里给出一些集群相关的配置信息

```shell
# zoo.cfg的配置
mkdir -p /home/work/bin/zookeeper/conf/
touch /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# 维持心跳的时间间隔\ntickTime=2000" >> home/work/bin/zookeeper/conf/zoo.conf
echo -e "# 接受客户端（leader 连接的 follower 服务器）初始化时最长忍受多少个心跳时间间接数\ninitLimit=10" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# leader 与 follower 之间发送消息，请求和应答的时间长度，最长不能超过多少个 心跳时间间隔\nsyncLimit=5" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# 数据保存的目录\ndataDir=/home/work/bin/zookeeper/data" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# 日志保存目录\ndataLogDir=/home/work/bin/zookeeper/logs" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# 接受客户端请求的服务器端口\nclientPort=2181" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# the maximum number of client connections.\n# increase this if you need to handle more clients\n#maxClientCnxns=60" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# 自动清除快照的时间间隔 小时为单位 默认 0 禁止自动清除功能\nautopurge.purgeInterval=24" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# 启用自动清除功能开启时，保存快照个数 默认 3\nautopurge.snapRetainCount=100" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# server.A=B:C:D\n# A 表示zk服务器的序号\n# B 这个服务器的 ip 地址\n# C 收集群成员的信息交换， 这个服务器与 集群 leader 的服务器交换信息接口" >> /home/work/bin/zookeeper/conf/zoo.conf
echo -e "# D 在 leader 挂掉 后专门用来进行选举leader 所用的接口\nserver.1=fv_al_pt01:2888:3888\nserver.2=0.0.0.0:2888:3888\nserver.3=fv_al_pt03:2888:3888" >> /home/work/bin/zookeeper/conf/zoo.conf
```

上面得到的效果如下图：

![zoo.cfg](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/zookeeper/zoo.cfg.png)

这样我就将设置信息放入到了`home/work/bin/zookeeper/conf/zoo.conf`文件中，但是我的zk是在/usr/local/zookeeper/zookeeper-3.4中的，所以我需要做一个软连接

```shell
ln -s /home/work/bin/zookeeper/conf/zoo.conf /usr/local/zookeeper/zookeeper-3.4/conf/zoo.cfg

```

为了使配置中的信息能够生效，需要我们自己创建在zoo.cfg中的dataDir的路径和dataLogDir的路径
```shell
mkdir - p /home/work/bin/zookeeper/data/
mkdir -p /home/work/bin/zookeeper/logs
```
否则程序会报错

##  配置本机myid

根据上面zoo.cfg中的`server.A`的配置。来配置自己的myid，如果不配置myid也会报错

myid配置在zoo.cfg中指定的dataDir中,如下，但是 下面的这个 1 是当前服务器对应的`A`

```shell
echo "1" > /home/work/bin/zookeeper/data/myid
```

# 启动zookeeper服务

在每一个机器上同时执行

```shell
# zkServer.sh start
```

然后在启动的路径下会有一个`zookeeper.out`文件夹。可以查看到当前启动的zk中的日志记录

查看当前zk的状态信息
```shell
# zkServer.sh status
```

如果返回

```bash
ZooKeeper JMX enabled by default 
Using config: /usr/local/zookeeper/zookeeper-3.4/bin/../conf/zoo.cfg 
Mode: follower 或者 leader 表示当前zk的角色
```

表示启动成功

如果有错误的话就需要去查看对应的zookeeper.out文件了。

# 遇到的bug与解决方式

- 1、没设置myid
目前我的版本是3.4.12如果忘记设置了myid的话会导致启动报错

 ```
 # zookeeper.out的报错信息
 Caused by: java.lang.IllegalArgumentException:  /home/work/bin/zookeeper/data/myid file is missing 
 at  org.apache.zookeeper.server.quorum.QuorumPeerConfig.pars eProperties(QuorumPeerConfig.java:408) 
 at  org.apache.zookeeper.server.quorum.QuorumPeerConfig.pars e(QuorumPeerConfig.java:152) 
 ... 2 more
 ```
 解决方式就是在指定的目录下设置一个对应的myid

- 2、无法绑定监听服务
如果将当前的server.A=B:C:D中的B设置为公网ip的话就会爆下面的错误

 ```
 2018-11-08 17:13:38,982 [myid:3] - ERROR  [fv_al_pt01/119.23.221. 27:3888:QuorumCnxManager$Listener@760] - Exception  while listening
 java.net.BindException: Cannot assign requested address  (Bind failed)
 	at java.net.PlainSocketImpl.socketBind(Native  Method)
 	at java.net.AbstractPlainSocketImpl.bind (AbstractPlainSocketImpl.java:387)
 	at java.net.ServerSocket.bind(ServerSocket.java:375)
 	at java.net.ServerSocket.bind(ServerSocket.java:329)
 	at  org.apache.zookeeper.server.quorum.QuorumCnxManager$ Listener.run(QuorumCnxManager.java:739)
 ```
 
 或者报错
 
 ```
 
 WARN [QuorumPeer[myid=1] /0.0.0.0:2181:QuorumCnxManager@584] - Cannot open  channel to 3 at election address /119.23.221.27:3888
 ```
 无法绑定监听端口

 解决方式是将当前的server的B改为0.0.0.0 (这个是个坑)
 
 当然也有可能是因为 防火墙 或者 阿里云的安全组不让 我们的云服务的 2888 和 3888端口被外部访问，这里需要检查一些下防火墙和阿里云的安全组。

# zookeeper配置优化


## 问题一：zookeeper.out日志没有固定位置

我们上面介绍了，我们在那个目录下启动zk，就在那个目录下会出现zookeeper.out的zk启动日志，这样的话，启动日志没有一个统一的位置。我希望将它放在一个国定的位置便于查询。

命令如下

```shell
# 设置路径
ZK_HOME=/usr/local/zookeeper/zookeeper-3.4
# 修改 zkEnv.sh 文件 中的地址
sed -i 's/ZOO_LOG_DIR=\".\"/ZOO_LOG_DIR=\"\/home\/work\/bin\/zookeeper\/logs\"/g' $ZK_HOME/bin/zkEnv.sh
# 修改答应日志的类型
sed -i 's/ZOO_LOG4J_PROP=\"INFO,CONSOLE\"/ZOO_LOG4J_PROP=\"INFO,ROLLINGFILE\"/g' $ZK_HOME/bin/zkEnv.sh

# 修改 log4j 文件输出形式
sed -i 's/zookeeper.root.logger=INFO, CONSOLE/zookeeper.root.logger=INFO, ROLLINGFILE/g' $ZK_HOME/conf/log4j.properties

# 将日志修改为 每日打包压缩
sed -i 's/log4j.appender.ROLLINGFILE=org.apache.log4j.RollingFileAppender/log4j.appender.ROLLINGFILE=org.apache.log4j.DailyRollingFileAppender/g' $ZK_HOME/conf/log4j.properties

# DailyRollingFileAppender 不需要 log4j.appender.ROLLINGFILE.MaxFileSize
sed -i 's/log4j.appender.ROLLINGFILE.MaxFileSize=10MB/# log4j.appender.ROLLINGFILE.MaxFileSize=10MB/g' $ZK_HOME/conf/log4j.properties

```

本来的zkEnv如图：
![zkEnv_old.png](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/zookeeper/zkEnv_sh_old.png)

新的zkEnv如图；
![zkEnv_new.png](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/zookeeper/zkEnv_sh_new.png)
当然采用ROLLINGFILE的日志方式也是打印在一个文件下面，如果要分天打印也是可以实现的，这里就是log4j的配置文件，可以随便修改

## 问题二：去除无用的zookeeper.out文件
然后我们重启服务器发现还是会在/home/work/bin/zookeeper/logs目录下生成一个zookeeper.out的文件。但是文件内容一直是空的。所有也可以对zookeeper.out进行删除

将下面代码放到zkServer.sh中

```shell
"$JAVA" "-Dzookeeper.log.dir=${ZOO_LOG_DIR}" "-Dzookeeper.root.logger=${ZOO_LOG4J_PROP}" -cp "$CLASSPATH" $JVMFLAGS $ZOOMAIN "$ZOOCFG" &
```

并删除

```shell

# _ZOO_DAEMON_OUT="$ZOO_LOG_DIR/zookeeper.out"

# nohup "$JAVA" "-Dzookeeper.log.dir=${ZOO_LOG_DIR}" "-Dzookeeper.root.logger=${ZOO_LOG4J_PROP}" \

 # -cp "$CLASSPATH" $JVMFLAGS $ZOOMAIN "$ZOOCFG" > "$_ZOO_DAEMON_OUT" 2>&1 < /dev/null &
 ```

 这样的话重启zk后就不会看到对应的zookeeper.out目录了。

 配置后如下图：
 
 ![zkServer_sh.png](https://raw.githubusercontent.com/forvoid/imageHosting/master/blog/zookeeper/zkServer_sh.png)

 # 总结

 # 参考链接🔗

 [掘金-Zookeeper 安装与部署](https://juejin.im/post/5abc984c51882555635e66ef)

 [Zookeeper集群搭建](https://www.linuxprobe.com/zookeeper-cluster-deploy.html)

 [掘金-zookeeper集群搭建❤️](https://juejin.im/post/5ba879ce6fb9a05d16588802#heading-10)

 [ZooKeeper搭建系列集](https://blog.csdn.net/shatelang/article/details/7596007)

 [ZooKeeper 配置参数说明](https://www.cnblogs.com/sunddenly/articles/4071730.html)










