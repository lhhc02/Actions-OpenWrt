#!/bin/bash
#
# diy-part2.sh - WR3000K 定制：型号显示名 + 编译者信息
#

# 1. 修改设备型号（LuCI 状态页显示 / tmp/sysinfo/model）
# DTS 实际路径: target/linux/mediatek/dts/mt7981b-tenbay-wr3000k.dts
# 原始字符串: model = "Tenbay WR3000K";
sed -i 's/"Tenbay WR3000K"/"SAIDA SD-R3010 (lhhc_02 build)"/g' \
  target/linux/mediatek/dts/mt7981b-tenbay-wr3000k.dts

# 2. 修改版本描述（/etc/openwrt_release 的 DISTRIB_DESCRIPTION）
sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION='SAIDA SD-R3010 - OpenWrt by lhhc_02'/" \
  package/base-files/files/etc/openwrt_release

exit 0
