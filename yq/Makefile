include $(TOPDIR)/rules.mk

PKG_NAME:=yq
PKG_VERSION:=4.52.5
PKG_RELEASE:=1

PKG_SOURCE:=yq_linux_arm64
PKG_SOURCE_URL:=https://github.com/mikefarah/yq/releases/download/v$(PKG_VERSION)/
PKG_HASH:=90fa510c50ee8ca75544dbfffed10c88ed59b36834df35916520cddc623d9aaa

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/yq
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Portable command-line YAML processor
  URL:=https://mikefarah.gitbook.io/yq/
  DEPENDS:=@aarch64
  PKG_ARCH:=aarch64
endef

define Package/yq/description
  The aim of the project is to be the jq or sed of yaml files.
endef

define Build/Prepare
    $(call Build/Prepare/Default)
    mkdir -p $(PKG_BUILD_DIR)
    $(CP) $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/yq
    chmod +x $(PKG_BUILD_DIR)/yq
endef

define Package/yq/install
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/yq $(1)/usr/bin/yq
endef

$(eval $(call BuildPackage,yq))
