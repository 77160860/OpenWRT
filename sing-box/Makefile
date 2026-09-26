# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2022-2023 ImmortalWrt.org
# Pre-compiled version from custom source

include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.15.0
PKG_RELEASE:=8
PKG_NO_CHECKSUM:=1

ifneq ($(findstring aarch64,$(ARCH)),)
  PKG_SOURCE:=sing-box-arm64
else ifneq ($(findstring x86_64,$(ARCH)),)
  PKG_SOURCE:=sing-box-amd64
else
  PKG_SOURCE:=sing-box-unsupported
endif

PKG_SOURCE_URL:=https://github.com/77160860/proxy/releases/download/singbox/
PKG_HASH:=skip

PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Custom Build

include $(INCLUDE_DIR)/package.mk

define Package/sing-box
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=sing-box (Pre-compiled Binary)
  URL:=https://github.com/77160860/proxy
  DEPENDS:=+ca-bundle +kmod-tun +kmod-inet-diag +kmod-netlink-diag
endef

define Package/sing-box/description
  Sing-box pre-compiled binary for ARM64 and AMD64.
  Downloaded from custom repository.
endef

define Package/sing-box/conffiles
/etc/config/sing-box
/etc/sing-box/
endef

define Build/Prepare
	@if [ "$(PKG_SOURCE)" = "sing-box-unsupported" ]; then \
		echo "=================================================" >&2; \
		echo "【错误】当前架构 ($(ARCH)) 不支持，无法编译sing-box！" >&2; \
		echo "=================================================" >&2; \
		exit 1; \
	fi
	mkdir -p $(PKG_BUILD_DIR)
	cp $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/sing-box
	chmod +x $(PKG_BUILD_DIR)/sing-box
endef

# 编译过程：跳过
define Build/Compile
endef

# 配置过程：跳过
define Build/Configure
endef

define Package/sing-box/install
	$(INSTALL_DIR) $(1)/usr/bin
	# 安装sing-box
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sing-box $(1)/usr/bin/sing-box

	# 安装配置文件
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/sing-box.conf $(1)/etc/config/sing-box
	
	# 安装启动脚本
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sing-box.init $(1)/etc/init.d/sing-box
	
	# 创建配置目录
	$(INSTALL_DIR) $(1)/etc/sing-box
endef

$(eval $(call BuildPackage,sing-box))
