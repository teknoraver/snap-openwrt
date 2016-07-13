#
# Copyright (C) 2016 Canonical.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=snap
PKG_VERSION:=2.0.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/snapcore/snapd/archive/
PKG_MD5SUM:=ab3546018390c9ffa73e5fd7a3f09ebe
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

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) CC=$(TARGET_CC) snapd-wrapper
	$(MAKE) -C $(PKG_BUILD_DIR)/$(PKG_SNAPCONFINE_NAME)-$(PKG_SNAPCONFINE_VERSION)
endef

define Package/snap/install
	$(INSTALL_DIR) $(1)/bin $(1)/usr/bin $(1)/usr/lib/snapd $(1)/etc/init.d $(1)/snap $(1)/etc/systemd/system
	$(LN) /var/run $(1)/run
	$(INSTALL_BIN) ./files/$(CONFIG_ARCH)/snap $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_SNAPCONFINE_NAME)-$(PKG_SNAPCONFINE_VERSION)/src/snap-confine $(1)/usr/bin/ubuntu-core-launcher
	$(INSTALL_BIN) ./files/$(CONFIG_ARCH)/snapd $(PKG_BUILD_DIR)/snapd-wrapper $(1)/usr/lib/snapd/
	$(INSTALL_BIN) ./files/snapd.init $(1)/etc/init.d/snapd
	$(INSTALL_BIN) ./files/systemctl $(1)/bin/
endef

$(eval $(call BuildPackage,snap))
