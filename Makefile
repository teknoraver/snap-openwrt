#
# Copyright (C) 2016 Canonical.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=snap
PKG_VERSION:=2.0.10
PKG_RELEASE:=1

PKG_SOURCE:=snapd-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://people.canonical.com/~mcroce/
PKG_MD5SUM:=d6d73d9abd64c1729775336d1caca993
PKG_MAINTAINER:=Matteo Croce <matteo.croce@canonical.com>
PKG_LICENSE:=GPL

include $(INCLUDE_DIR)/package.mk

# add CONFIG_SQUASHFS_TOOLS_XZ_SUPPORT and CONFIG_BUSYBOX_CONFIG_FEATURE_MOUNT_LOOP
# and kernel CONFIG_SQUASHFS_XZ too

define Package/snap
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+liblzma +zlib +squashfs-tools-unsquashfs +kmod-loop +ca-certificates
  TITLE:=Snappy Ubuntu Core
  URL:=https://developer.ubuntu.com/en/snappy/
endef

define Package/snap/description
 Snappy is part of Ubuntu Core and enables a fully transactional Ubuntu system.
endef

PKG_SNAPCONFINE_NAME:=snap-confine
PKG_SNAPCONFINE_VERSION:=1.0.30
PKG_SNAPCONFINE_SOURCE:=$(PKG_SNAPCONFINE_VERSION).tar.gz
PKG_SNAPCONFINE_SOURCE_URL:=https://github.com/snapcore/$(PKG_SNAPCONFINE_NAME)/archive/
PKG_MD5SUM:=8aff95eed4ab350f1653d3b14856bb68
PKG_SNAPCONFINE_SUBDIR:=$(PKG_SNAPCONFINE_NAME)

define Download/snap-confine
  FILE:=$(PKG_SNAPCONFINE_SOURCE)
  URL:=$(PKG_SNAPCONFINE_SOURCE_URL)
  VERSION:=$(PKG_SNAPCONFINE_VERSION)
  SUBDIR:=$(PKG_SNAPCONFINE_SUBDIR)
endef
$(eval $(call Download,snap-confine))

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
	$(TAR) -C $(PKG_BUILD_DIR) -xvf $(DL_DIR)/$(PKG_SOURCE)
	mv $(PKG_BUILD_DIR)/snapd-$(PKG_VERSION) $(PKG_BUILD_DIR)/src
	$(TAR) -C $(PKG_BUILD_DIR) -xvf $(DL_DIR)/$(PKG_SNAPCONFINE_SOURCE)
	cd $(PKG_BUILD_DIR)/$(PKG_SNAPCONFINE_NAME)-$(PKG_SNAPCONFINE_VERSION) && \
		aclocal && \
		autoheader && \
		automake --force-missing --add-missing && \
		autoconf
endef

define Build/Configure
	cd $(PKG_BUILD_DIR)/$(PKG_SNAPCONFINE_NAME)-$(PKG_SNAPCONFINE_VERSION) && \
	$(CONFIGURE_VARS) ./configure --disable-confinement $(CONFIGURE_ARGS)
endef

GOARCH:=$(ARCH)

ifeq ($(GOARCH),i386)
  GOARCH:=386
  ifeq ($(CONFIG_CPU_TYPE),pentium4)
    GOSUBARCH:=sse
  else
    GOSUBARCH:=387
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

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) CC=$(TARGET_CC) snapd-wrapper
	$(MAKE) -C $(PKG_BUILD_DIR)/$(PKG_SNAPCONFINE_NAME)-$(PKG_SNAPCONFINE_VERSION)
	GOPATH=$(PKG_BUILD_DIR) GOARCH=$(GOARCH) $(GOSUBARCH) CGO_ENABLED=1 CC=$(TARGET_CC) go build -o $(PKG_BUILD_DIR)/snap github.com/snapcore/snapd/cmd/snap
	GOPATH=$(PKG_BUILD_DIR) GOARCH=$(GOARCH) $(GOSUBARCH) CGO_ENABLED=1 CC=$(TARGET_CC) go build -o $(PKG_BUILD_DIR)/snapd github.com/snapcore/snapd/cmd/snapd
endef

define Package/snap/install
	$(INSTALL_DIR) $(1)/bin $(1)/usr/bin $(1)/usr/lib/snapd $(1)/etc/init.d $(1)/snap $(1)/etc/systemd/system
	$(LN) /var/run $(1)/run
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/snap $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_SNAPCONFINE_NAME)-$(PKG_SNAPCONFINE_VERSION)/src/snap-confine $(1)/usr/bin/ubuntu-core-launcher
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/snapd $(PKG_BUILD_DIR)/snapd-wrapper $(1)/usr/lib/snapd/
	$(INSTALL_BIN) ./files/snapd.init $(1)/etc/init.d/snapd
	$(INSTALL_BIN) ./files/systemctl $(1)/bin/
endef

$(eval $(call BuildPackage,snap))
