#
# Copyright (C) 2016 Canonical.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=snap
PKG_VERSION:=1.0
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://github.com/snapcore/snapd
#PKG_MD5SUM:=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

PKG_MAINTAINER:=Matteo Croce <matteo.croce@canonical.com>
PKG_LICENSE:=GPL

include $(INCLUDE_DIR)/package.mk

# add CONFIG_SQUASHFS_TOOLS_XZ_SUPPORT too

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

define Build/Prepare
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/snap/install
	$(INSTALL_DIR) $(1)/bin $(1)/usr/bin $(1)/usr/lib/snapd $(1)/lib $(1)/run $(1)/etc/systemd/system $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/snap ./files/ubuntu-core-launcher $(1)/usr/bin/
	$(INSTALL_BIN) ./files/snapd $(PKG_BUILD_DIR)/snapd-wrapper $(1)/usr/lib/snapd/
	$(INSTALL_BIN) ./files/snapd.init $(1)/etc/init.d/snappy
	$(INSTALL_BIN) ./files/systemctl $(1)/bin/
endef

$(eval $(call BuildPackage,snap))
