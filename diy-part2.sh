#!/bin/bash
#
# diy-part2.sh - WR3000K 定制：型号显示名 + 编译者信息
#

# 1. 修改设备型号（LuCI 状态页显示 / tmp/sysinfo/model）
# DTS 实际路径: target/linux/mediatek/dts/mt7981b-tenbay-wr3000k.dts
# 原始字符串: model = "Tenbay WR3000K";  (已核对 openwrt-25.12 分支第 7 行)
sed -i 's/"Tenbay WR3000K"/"SAIDA SD-R3010 (lhhc_02 build)"/g' \
  target/linux/mediatek/dts/mt7981b-tenbay-wr3000k.dts

# 2. 修改版本描述（/etc/openwrt_release 的 DISTRIB_DESCRIPTION）
sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION='SAIDA SD-R3010 - OpenWrt by lhhc_02'/" \
  package/base-files/files/etc/openwrt_release

# 3. 合并双分区：ubi1 并入 ubi，系统分区 48M -> 96M
#    只改内核 DTS 的分区表，U-Boot 完全不动（boot_from=ubi 启动逻辑不受影响）
# 3a. ubi 分区扩大到 96M（0x3000000 -> 0x6000000，覆盖原 ubi1 区域）
sed -i 's/reg = <0x580000 0x3000000>;/reg = <0x580000 0x6000000>;/' \
  target/linux/mediatek/dts/mt7981b-tenbay-wr3000k.dts

# 3b. 删除 ubi1 分区节点（partition@3580000 整块删除，共 4 行）
sed -i '/partition@3580000 {/,/};/d' \
  target/linux/mediatek/dts/mt7981b-tenbay-wr3000k.dts

# 3c. 镜像大小上限同步：49152k(48M) -> 98304k(96M)，全文件唯一出现处，sed 安全
sed -i 's/IMAGE_SIZE := 49152k/IMAGE_SIZE := 98304k/' \
  target/linux/mediatek/image/filogic.mk

# 自检：分区改动没生效就立刻报错中断，避免编出错误固件
grep -q 'reg = <0x580000 0x6000000>;' target/linux/mediatek/dts/mt7981b-tenbay-wr3000k.dts \
  || { echo "ERROR: ubi 分区扩容失败"; exit 1; }
grep -q 'partition@3580000' target/linux/mediatek/dts/mt7981b-tenbay-wr3000k.dts \
  && { echo "ERROR: ubi1 分区删除失败"; exit 1; }
grep -q 'IMAGE_SIZE := 98304k' target/linux/mediatek/image/filogic.mk \
  || { echo "ERROR: IMAGE_SIZE 修改失败"; exit 1; }
echo "OK: 单分区改造完成 (ubi=96M, ubi1 已移除)"

exit 0
