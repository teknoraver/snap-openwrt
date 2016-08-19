#
# Copyright (C) 2016 Canonical.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=snapd
PKG_VERSION:=2.0.10
PKG_RELEASE:=1

PKG_SOURCE:=snapd-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://people.canonical.com/~teknoraver/
PKG_MD5SUM:=d6d73d9abd64c1729775336d1caca993
PKG_MAINTAINER:=Matteo Croce <matteo.croce@canonical.com>
PKG_LICENSE:=GPL

include $(INCLUDE_DIR)/package.mk

# configure options to enable:
# CONFIG_SQUASHFS_TOOLS_XZ_SUPPORT
# CONFIG_BUSYBOX_CONFIG_FEATURE_MOUNT_LOOP
# CONFIG_TARGET_INIT_PATH="/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
# kernel options:
# CONFIG_SQUASHFS_XZ

define Package/snapd
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+snap-confine +squashfs-tools-unsquashfs +kmod-loop +kmod-fs-squashfs +ca-certificates +libudev
  TITLE:=Snappy Ubuntu Core Daemon
  URL:=https://developer.ubuntu.com/en/snappy/
endef

define Package/snapd/description
 Snappy is part of Ubuntu Core and enables a fully transactional Ubuntu system.
endef

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
	$(TAR) -C $(PKG_BUILD_DIR) -xvf $(DL_DIR)/$(PKG_SOURCE)
	mv $(PKG_BUILD_DIR)/snapd-$(PKG_VERSION) $(PKG_BUILD_DIR)/src
endef

define Build/Configure
endef

GOARCH:=$(ARCH)

ifeq ($(GOARCH),i386)
  GOARCH:=386
  ifeq ($(CONFIG_CPU_TYPE),"pentium4")
    GOSUBARCH:=GO386=sse2
  else
    GOSUBARCH:=GO386=387
  endif
endif
ifeq ($(GOARCH),x86_64)
  GOARCH:=amd64
endif
ifeq ($(GOARCH),aarch64)
  GOARCH:=arm64
endif
ifeq ($(GOARCH),arm)
  ifeq ($(CONFIG_arm_v5),y)
    GOSUBARCH:=GOARM=5
  endif
  ifeq ($(CONFIG_arm_v6),y)
    GOSUBARCH:=GOARM=6
  endif
  ifeq ($(CONFIG_arm_v7),y)
    GOSUBARCH:=GOARM=7
  endif
endif

GOENV:=GOPATH=$(PKG_BUILD_DIR) GOARCH=$(GOARCH) $(GOSUBARCH) CGO_ENABLED=1 CC=$(TARGET_CC)
CMD:=github.com/snapcore/snapd/cmd
GOFLAGS:=--ldflags='-s -w'

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) CC=$(TARGET_CC) snapd-wrapper
	$(GOENV) go build -o $(PKG_BUILD_DIR)/snap $(GOFLAGS) $(CMD)/snap
	$(GOENV) go build -o $(PKG_BUILD_DIR)/snapd $(GOFLAGS) $(CMD)/snapd
endef

define Package/snapd/install
	$(INSTALL_DIR) $(1)/bin $(1)/usr/bin $(1)/usr/lib/snapd $(1)/etc/init.d $(1)/snap $(1)/etc/systemd/system $(1)/home $(1)/media
	$(LN) /var/run $(1)/run
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/snap $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/snapd $(PKG_BUILD_DIR)/snapd-wrapper $(1)/usr/lib/snapd/
	$(INSTALL_BIN) ./files/snapd.init $(1)/etc/init.d/snapd
	$(INSTALL_BIN) ./files/systemctl $(1)/bin/
endef

$(eval $(call BuildPackage,snapd))
