---
title: 配置校园内网netkeeper路由器使用
date: 2017-05-15 11:11:18
tags:
	- netkeeper
---
# 前景介绍
我的是在重庆邮电大学（CQUPT）进行配置的，我们学校的网是电信的netkeeper。每个人都用一个帐号在自己的电脑上进行帐号登录后上网。十分的不方便，尤其是用电脑开的wifi，有些不稳定。所以我在网上找到了诸多大神的配置方法进行配置，并且记录下来便于以后自己好查看。

# 更新说明
5-15：配置好了第一版（基于斐讯k2 + openwrt），~~完成断网重连，自动拨号功能~~。未完成稳定性问题没有解决，。
<!--more-->
# 配置方式
## 安装OpenWRT
OpenWRT是一个linux内核的路由器系统。我们到openwrt官网即可下载[openwrt官网](https://openwrt.org/)

在路由器安装Openwrt前应该先刷一个breed基础系统防止失败GG。各个版本的网上都有，这里我放一个老高的斐讯刷机博客，里面可以从斐讯k2知道降级等都可以看到[老高的斐讯k2博客](https://blog.phpgao.com/phicomm_k2.html)
。根据教材里面的一步一步来基本就可以解决到breed

然后在openwrt下下载对应的路由器版本的bin。路由器断电，让网线连接电脑，按住restart键插入电源，大概十秒后。在浏览器输入`192.168.1。1`就会进入breed界面

![网上招的breed web界面)](/images/netkeeper/breed_web.png)

就是选中固件更新.然后重启后192.168.1.1就进入了对应的系统登录界面了。
一般帐号密码都是`root`。

## netkeeper拨号器配置
### 安装netkeeper的环境
这里放一个netkeeper-openwrt重邮大神写的github地址[https://github.com/miao1007/Openwrt-NetKeeper](https://github.com/miao1007/Openwrt-NetKeeper)。
里面有详细的说明如何安装netkeeper环境。

以下为摘录内容具体的看大神的[github文档](https://github.com/miao1007/Openwrt-NetKeeper/blob/master/README-CN.md)
```
1. 下载最新版插件

sxplugin.so
confnetwork.sh
下载后，修改confnetwork.sh中的 pppd_options username password

2. 上传（这里有个坑在下面马上要说）

使用scp(windows下可以使用 WinScp) 上传

yourprovince_sxplugin.so -> /usr/lib/pppd/2.4.7/
confnetwork.sh -> /tmp/
3. 配置路由器

登陆路由器，执行脚本

chmod a+x /tmp/confnetwork.sh
sh /tmp/confnetwork.sh 
最后在浏览器中同步一下路由器时间并重连一下闪讯(netkeeper)
```
这里介绍一下这里面的坑。主要是在从其他电脑scp传入openwrt时，他会在后面都加入^M标识，然后当执行脚本的时候就会报错。报错信息如下
```
/tmp$ sh /tmp/confnetwork.sh
uci: Invalid argument
uci: Invalid argument
uci: Parse error
uci: Invalid argument
uci: Parse error
Usage: uci [] []
......
```
解决的办法我这边写两个
* 一就是对传入的脚本进行更改去掉每一行后面的`^M`再试试.
* 二就是把脚本的命令行直接打入shell。

### 一些问题汇总
* 1、由于时间不正确引起的拨号失败.这里的解决方式就是同步时间
```
在界面上填入ntp服务器地址。然后刷新时间（注意要选择utf-8的时间区）香港或者上海时间都行。这里放重邮的ntp服务器
202.202.43.120
202.202.43.131
202.202.43.231
202.202.43.198
```
这里引用了一个重邮学长的博客他里面也是介绍如何进行配置可以参考一下[http://blog.csdn.net/Azure95/article/details/50805849](http://blog.csdn.net/Azure95/article/details/50805849)
* 2、配置成功后还是连接不上。这个我选择restart路由器。（不知道为什么需要重启，但是重启之后确实好了~~~~(>_<)~~~~）
* 3、配置断点重连。这里主要是做网络是否中断，如果中断了重新network restart网络。直接贴代码

```
#!/bin/sh
#sleep 100
DATE=`date +%Y-%m-%d-%H:%M:%S`
tries=0
echo --- my_watchdog start ---
while [[ $tries -lt 5 ]]
do
        if /bin/ping -c 1 8.8.8.8 >/dev/null #判断当前网络连接是否正常，如果正常的话就退出，如果不正常循环五次休息1os后
        then
                echo --- exit ---
#               echo $DATE OK >>my_watchdog.log
                exit 0
        fi
        tries=$((tries+1))
        sleep 10
#       echo $DATE tries: $tries >>my_watchdog.log
done

echo $DATE network restart >>my_watchdog.log
/etc/init.d/network restart

#echo $DATE reboot >>my_watchdog.log
#reboot
```
这个是我在一个博客中看到的[博客地址（哈哈太长了就不给出链接url了）。点击就行](https://jamesqi.com/%E5%8D%9A%E5%AE%A2/OpenWRT%E8%B7%AF%E7%94%B1%E5%99%A8%E4%B8%AD%E7%9B%91%E6%8E%A7%E7%BD%91%E7%BB%9C%E6%9C%8D%E5%8A%A1%E5%B9%B6%E9%87%8D%E5%90%AF%E7%9A%84%E8%84%9A%E6%9C%AC)其实自己也可以写。这就是shell编程。然后还有一步就是加入crontab命令，让他每5分钟执行一次。
```
$ root@Openwrt:~# crontab -e
然后输入
*/5 * * * * sh /etc/crontabs/my_wifi_cron.sh #五分钟启动一次
0 */1 * * * rm -rf /overlay/upper/root/my_watchdog.log #1h启动一次
0 */1 * * * rm -rf /root/my_watchdog.log #1h启动一次
0 */12 * * * rm -rf /root/error.log #12h启动一次
```
这样就差不多了。
# 下面放上一些我觉得我需要的资源
* 我的备份配置包就是/etc目录下的文件(我去掉了我的帐号信息)[下载地址](../../../../files/netkeeper_package/backup-OpenWrt-2017-05-15.tar.gz)

# 致谢
这个还是折腾了我很久的。从一开始的害怕，不懂，不敢去尝试。到后面才发现大坑都已经被大神们填了。我只需要沿着他们的脚步走一边，感觉自己还是有点怕事。以后需要改改.
这里主要感谢
* 苗1007          提供netkeeper算法和编译好的so文件。和开源维护
* 老高   提供了斐讯的刷机等教程和开发包（让我们远离了后台监管）
* 祁劲松 提供了定时更新的shell脚本（让我知道shell的强大），以前都没好好的用shell
* qingfengtsing 根据苗1007学长的思路跑了一边，还是很有参考价值的
* openwrt项目组  真的openwrt是个好东西，可以完成好多不需要在电脑上完成的工作（我在想以后家里面就自己搭建物联网家庭。还得用到他。）
* 和所以我知道的不知道的给我帮助的各位大佬，虽然我的致谢没有实际作用。但是我还是很感谢你们的付出。

