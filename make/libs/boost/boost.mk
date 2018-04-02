$(call PKG_INIT_LIB, 1.66.0)
$(PKG)_SOURCE:=boost_1_66_0.tar.bz2
$(PKG)_SITE:=http://downloads.sourceforge.net/project/boost/boost/1.66.0

BOOST_FLAGS += --without-icu

BOOST_OPT += toolset=gcc \
             threading=multi \
             variant=release \
             link=shared \
             runtime-link=shared
BOOST_OPT += boost.locale.posix=off

BOOST_FLAGS += --without-libraries=atomic,container,coroutine,fiber,log,stacktrace,type_erasure,python,context,chrono,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,math,mpi,program_options,random,regex,serialization,signals,system,test,thread,timer,wave

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

TARGET_CC_VERSION = $(shell $(TARGET_CC) -dumpversion)

$(BOOST_DIR)/b2: $($(PKG)_DIR)/.configured
	cd $(BOOST_DIR); ./bootstrap.sh $(BOOST_FLAGS)
	echo "using gcc : $(TARGET_CC_VERSION) : $(TARGET_CXX) : <cxxflags>\"$(TARGET_CXXFLAGS)\" <linkflags>\"$(TARGET_LDFLAGS)\" ;" > $(BOOST_DIR)/user-config.jam
	echo "" >> $(BOOST_DIR)/user-config.jam


$(BOOST_DIR)/project-config.jam: $(BOOST_DIR)/b2
	cd $(BOOST_DIR) && ./b2 -j4 -d+1 \
	--user-config=user-config.jam \
	$(BOOST_OPT) \
	--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
	--layout=system install

$(pkg): $(BOOST_DIR)/project-config.jam

$(pkg)-precompiled:

$(pkg)-clean:
	-$(SUBMAKE) -C $(BOOST_DIR) clean
	$(RM) -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/include/boost

$(pkg)-uninstall:
	$(RM) $(BOOST_TARGET_DIR)/libgsm.so*

$(PKG_FINISH)
