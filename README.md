# OpenWrt snap feed

## Description

This is the OpenWrt "snap"-feed containing Snap - 

## Usage

This feed is not enabled by default. To use it add to your feeds.conf a line like:
```
src-git snap https://github.com/teknoraver/snap-openwrt
```

To install all its package definitions, run:
```
./scripts/feeds update snap
./scripts/feeds install snapd
make oldconfig
```

Press Y to enable snapd when prompted, and then compile OpenWrt in the usual way
