#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

uci set luci.main.lang=zh_cn
uci commit luci
uci set system.@system[0].timezone=CST-8
uci set system.@system[0].zonename=Asia/Shanghai
uci set system.@system[0].hostname=H69K-OWRT
uci commit system
uci set fstab.@global[0].anon_mount=1
uci commit fstab


rm -f /usr/lib/lua/luci/view/admin_status/index/mwan.htm
rm -f /usr/lib/lua/luci/view/admin_status/index/upnp.htm
rm -f /usr/lib/lua/luci/view/admin_status/index/ddns.htm
rm -f /usr/lib/lua/luci/view/admin_status/index/minidlna.htm

sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/aria2.lua
sed -i 's/services/nas/g' /usr/lib/lua/luci/view/aria2/overview_status.htm
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/hd_idle.lua
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/samba.lua
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/samba4.lua
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/minidlna.lua
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/transmission.lua
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/mjpg-streamer.lua
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/p910nd.lua
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/usb_printer.lua
sed -i 's/\"services\"/\"nas\"/g' /usr/lib/lua/luci/controller/xunlei.lua
sed -i 's/services/nas/g'  /usr/lib/lua/luci/view/minidlna_status.htm

ln -sf /sbin/ip /usr/bin/ip

sed -i 's#downloads.openwrt.org#mirrors.cloud.tencent.com/lede#g' /etc/opkg/distfeeds.conf
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' /etc/shadow
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' /etc/shadow

sed -i "s/# //g" /etc/opkg/distfeeds.conf
sed -i '/openwrt_luci/ { s/snapshots/releases\/18.06.9/g; }'  /etc/opkg/distfeeds.conf

sed -i '/REDIRECT --to-ports 53/d' /etc/firewall.user
echo 'iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user
echo 'iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user

echo '[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user
echo '[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user

#echo 'iptables -A OUTPUT -m string --string "api.installer.xiaomi.cn" --algo bm --to 65535 -j DROP' >> /etc/firewall.user

sed -i '/option disabled/d' /etc/config/wireless
sed -i '/set wireless.radio${devidx}.disabled/d' /lib/wifi/mac80211.sh

sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release
echo "DISTRIB_REVISION='R23.7.7'" >> /etc/openwrt_release
sed -i '/DISTRIB_DESCRIPTION/d' /etc/openwrt_release
echo "DISTRIB_DESCRIPTION='OpenWrt '" >> /etc/openwrt_release

sed -i '/log-facility/d' /etc/dnsmasq.conf
echo "log-facility=/dev/null" >> /etc/dnsmasq.conf

rm -rf /tmp/luci-modulecache/
rm -f /tmp/luci-indexcache





uci set dhcp.lan.ra_default=1
uci commit dhcp




chmod 777 /bin/is-opkg
chmod 777 /usr/sbin/netspeed
uci set oled.@oled[0].netsource=wwan0
uci commit oled



echo 'ip6tables -t nat -A POSTROUTING -o usb0 -j MASQUERADE' >> /etc/firewall.user
echo 'ip6tables -t nat -A POSTROUTING -o wwan0 -j MASQUERADE' >> /etc/firewall.user
echo 'ip6tables -t nat -A POSTROUTING -o wwan0_1 -j MASQUERADE' >> /etc/firewall.user

uci set firewall.@zone[1].network="wan wan6 wlan wwan wwan6"
uci commit firewall

uci set network.wwan=interface
uci set network.wwan.proto='modemmanager'
uci set network.wwan.device='/sys/devices/platform/fd000000.usb/xhci-hcd.0.auto/usb6/6-1'
uci set network.wwan.apn='ctnet'
uci set network.wwan.auth='both'
uci set network.wwan.pdptype='IPV4V6'
uci set network.wwan.metric=40
uci commit network



uci set cpemodem.@ndis[0].enabled=0
uci commit cpemodem


rm -rf /etc/config/wireless
touch /etc/config/wireless
uci set wireless.radio0=wifi-device
uci set wireless.radio0.type='mac80211'
uci set wireless.radio0.path='3c0000000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0'
uci set wireless.radio0.channel='1'
uci set wireless.radio0.band='2g'
uci set wireless.radio0.country='US'
uci set wireless.radio0.legacy_rates='1'
uci set wireless.radio0.mu_beamformer='0'
uci set wireless.radio0.htmode='HE40'
uci set wireless.radio0.txpower='17'
uci set wireless.default_radio0=wifi-iface
uci set wireless.default_radio0.device='radio0'
uci set wireless.default_radio0.network='lan'
uci set wireless.default_radio0.mode='ap'
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio0.ssid='H69K'
uci set wireless.default_radio0.key='1234567890'
uci set wireless.default_radio0.disassoc_low_ack='0'
uci commit wireless

uci set wireless.radio1=wifi-device
uci set wireless.radio1.type='mac80211'
uci set wireless.radio1.path='3c0000000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0+1'
uci set wireless.radio1.channel='44'
uci set wireless.radio1.band='5g'
uci set wireless.radio1.country='US'
uci set wireless.radio1.legacy_rates='1'
uci set wireless.radio1.mu_beamformer='0'
uci set wireless.radio1.htmode='HE160'
uci set wireless.radio1.txpower='29'
uci set wireless.default_radio1=wifi-iface
uci set wireless.default_radio1.device='radio1'
uci set wireless.default_radio1.network='lan'
uci set wireless.default_radio1.mode='ap'
uci set wireless.default_radio1.encryption='psk2'
uci set wireless.default_radio1.ssid='H69K-5G'
uci set wireless.default_radio1.key='1234567890'
uci set wireless.default_radio1.disassoc_low_ack='0'
uci commit wireless


uci set luci.main.mediaurlbase='/luci-static/argonne'
uci commit luci
/etc/init.d/uhttpd restart
