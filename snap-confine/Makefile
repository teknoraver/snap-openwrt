#
# Copyright (C) 2016 Canonical.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=snap-confine
PKG_VERSION:=1.0.39
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/snapcore/snap-confine/archive/
PKG_MD5SUM:=9809499c0a9f2059c09c28feb38500e4

PKG_MAINTAINER:=Matteo Croce <matteo.croce@canonical.com>
PKG_LICENSE:=GPL

include $(INCLUDE_DIR)/package.mk

# configure options to enable:
# CONFIG_SQUASHFS_TOOLS_XZ_SUPPORT
# CONFIG_BUSYBOX_CONFIG_FEATURE_MOUNT_LOOP
# CONFIG_BUSYBOX_CONFIG_FEATURE_BASH_IS_ASH
# CONFIG_TARGET_INIT_PATH="/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
# kernel options:
# CONFIG_SQUASHFS_XZ

define Package/snap-confine
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+KERNEL_SECCOMP:libseccomp +libudev
  TITLE:=Snappy Ubuntu Core Confinement tool
  URL:=https://developer.ubuntu.com/en/snappy/
endef

define Package/snap-confine/description
 Snappy is part of Ubuntu Core and enables a fully transactional Ubuntu system.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	cd $(PKG_BUILD_DIR) && \
		aclocal && \
		autoheader && \
		automake --force-missing --add-missing && \
		autoconf
endef

ifeq ($(CONFIG_KERNEL_SECCOMP),)
  CONFIGURE_ARGS += --disable-seccomp
endif

define Build/Configure
	cd $(PKG_BUILD_DIR) && \
		$(CONFIGURE_VARS) ./configure --disable-apparmor $(CONFIGURE_ARGS)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) SUBDIRS=src
endef

define Package/snap-confine/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/snap-confine $(1)/usr/bin/ubuntu-core-launcher
endef

$(eval $(call BuildPackage,snap-confine))
