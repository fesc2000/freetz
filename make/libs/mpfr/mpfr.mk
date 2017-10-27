$(call PKG_INIT_LIB, $(MPFR_HOST_VERSION))
$(PKG)_LIB_VERSION:=4.1.6
$(PKG)_SOURCE:=$(MPFR_HOST_SOURCE)
$(PKG)_SOURCE_SHA256:=$(MPFR_HOST_SOURCE_SHA256)
$(PKG)_SITE:=$(MPFR_HOST_SITE)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libmpfr.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpfr.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libmpfr.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += gmp

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-thread-safe
$(PKG)_CONFIGURE_OPTIONS += --with-gmp=$(TARGET_TOOLCHAIN_STAGING_DIR)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

#$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MPFR_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(MPFR_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpfr.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MPFR_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpfr.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/*mpfr*.h

$(pkg)-uninstall:
	$(RM) $(MPFR_TARGET_DIR)/libmpfr*.so*

$(PKG_FINISH)
