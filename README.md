# OpenWrt snap feed

## Description

This is the OpenWrt "snap"-feed containing Snap - 

## Usage

This feed is not enabled by default. To use it add to your feeds.conf.default a line like:
```src-git snap https://github.com/teknoraver/snap-openwrt```
To install all its package definitions, run:
```
./scripts/feeds update snap
./scripts/feeds install snapd
make menuconfig
```
Select the snap package from the "Utilities" menu, and enable this options needed by snapd:
```
Utilities -> Enable XZ support
Base system -> busybox -> Linux System Utilities -> Support loopback mounts
Add ":/snap/bin" to Image configuration -> Init configuration options -> PATH for regular boot
```
run ```make kernel_menuconfig``` and select
```
File systems -> Miscellaneous filesystems -> SquashFS 4.0 - Squashed file system support
with
Include support for XZ compressed file systems
```
apply the persistent /var patch with:
```
curl https://people.canonical.com/~teknoraver/openwrt_persistent_var.patch |patch -p1
```
Then compile OpenWrt in the usual way, and enjoy your snappy world!
