uci set network.netkeeper=interface
uci set network.netkeeper.ifname=eth0.2
uci set network.netkeeper.macaddr=aabbccddeeff
uci set network.netkeeper.proto=pppoe
uci set network.netkeeper.pppd_options='plugin chongqing_sxplugin.so'
uci set network.netkeeper.username=1640663@cqupt
uci set network.netkeeper.password=888168
uci set network.netkeeper.metric='0'
uci commit network                                 
uci set firewall.@zone[1].network='wan netkeeper' 
uci commit firewall
/etc/init.d/firewall restart
/etc/init.d/network reload
/etc/init.d/network restart
config interface 'netkeeper'
        option ifname 'eth0.2'
        option macaddr 'aabbccddeeff'
        option proto 'pppoe'
        option pppd_options 'plugin chongqing_sxplugin.so'
        option username '1640663@cqupt'
        option password '888168'
        option metric '0'

