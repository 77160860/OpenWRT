include $(TOPDIR)/rules.mk

PKG_NAME:=yq
PKG_VERSION:=4.52.5
PKG_RELEASE:=1

PKG_SOURCE:=yq_linux_arm64
PKG_SOURCE_URL:=https://github.com/mikefarah/yq/releases/download/v4.52.5/
PKG_HASH:=skip

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Custom Build

include $(INCLUDE_DIR)/package.mk

define Package/yq
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Portable command-line YAML processor
  URL:=https://github.com/mikefarah/yq
  DEPENDS:=@aarch64
endef

define Package/yq/description
  yq pre-compiled binary for ARM64.
  Downloaded from mikefarah/yq releases.
endef

define Build/Prepare
    mkdir -p $(PKG_BUILD_DIR)
    cp $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/yq
    chmod +x $(PKG_BUILD_DIR)/yq
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/yq/install
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/yq $(1)/usr/bin/yq
endef

$(eval $(call BuildPackage,yq))
