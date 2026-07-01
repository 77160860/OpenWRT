#!/bin/bash

#移除luci-app-attendedsysupgrade
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
#sed -i "s/(luciversion[[:space:]]*||[[:space:]]*'')/'$WRT_DATE'/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
	#修改WIFI地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

# 关闭RFC1918
sed -i 's/option rebind_protection 1/option rebind_protection 0/g' package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/8000/0/g' package/network/services/dnsmasq/files/dhcp.conf

# 修改luci首页显示
sed -i '/Target Platform/d' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
sed -i '38,47d' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/20_memory.js
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/25_storage.js
sed -i 's/ECM://g' target/linux/qualcommax/base-files/sbin/cpuusage
sed -i 's/HWE/NPU/g' target/linux/qualcommax/base-files/sbin/cpuusage
# MT7981 PPE
if grep -q "CONFIG_TARGET_.*mt7981=y" .config 2>/dev/null; then
    echo "检测到MT7981平台，开始修改cpuusage脚本..."
    sed -i 's|/sys/kernel/debug/ppe\*/entries|/sys/kernel/debug/ppe0/entries|g' target/linux/mediatek/filogic/base-files/sbin/cpuusage
    sed -i '/name=\$(basename/c\name="PPE"' target/linux/mediatek/filogic/base-files/sbin/cpuusage
    echo "PPE修改完成！"
fi
#去掉luci后缀
sed -i "s#_('Firmware Version'), (L.isObject(boardinfo.release) ? boardinfo.release.description + ' / ' : '') + (luciversion || ''),#_('Firmware Version'), (L.isObject(boardinfo.release) ? boardinfo.release.description : ''),#g" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

#无WIFI配置标志
if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
	echo "WRT_WIFI=wifi-no" >> $GITHUB_ENV
fi

#高通平台调整
DTS_PATH="./target/linux/qualcommax/dts/"
if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_5=y" >> ./.config
	#其他调整
	echo "CONFIG_PACKAGE_kmod-usb-serial-qualcomm=y" >> ./.config
	#无WIFI配置调整Q6大小
	if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
		echo "qualcommax set up nowifi successfully!"
	fi
fi
#ZRAM开启ZSTD和LZ4算法
GENERIC_CONFIG="target/linux/generic/config-6.18"
if [ -f "$GENERIC_CONFIG" ]; then
    echo "正在配置ZSTD及LZ4支持..."
    sed -i '/CONFIG_ZRAM/d' $GENERIC_CONFIG
    sed -i '/CONFIG_ZSMALLOC/d' $GENERIC_CONFIG
    sed -i '/CONFIG_CRYPTO_LZ4/d' $GENERIC_CONFIG
    echo "CONFIG_ZRAM=y" >> $GENERIC_CONFIG
    echo "CONFIG_ZSMALLOC=y" >> $GENERIC_CONFIG
    echo "CONFIG_ZRAM_BACKEND_LZ4=y" >> $GENERIC_CONFIG
    echo "CONFIG_ZRAM_DEF_COMP_LZ4=y" >> $GENERIC_CONFIG
    echo 'CONFIG_ZRAM_DEF_COMP="lz4"' >> $GENERIC_CONFIG
    echo "CONFIG_CRYPTO_LZ4=y" >> $GENERIC_CONFIG
    echo "CONFIG_LZ4_COMPRESS=y" >> $GENERIC_CONFIG
    echo "CONFIG_LZ4_DECOMPRESS=y" >> $GENERIC_CONFIG
    echo "LZ4已应用至 $GENERIC_CONFIG"
else
    echo "跳过:未找到配置文件 $GENERIC_CONFIG"
fi
# 禁用zram自启
mkdir -p files/etc/uci-defaults
echo "/etc/init.d/zram disable" > files/etc/uci-defaults/99-disable-zram
chmod +x files/etc/uci-defaults/99-disable-zram
