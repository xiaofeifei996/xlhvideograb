#
# XLHVideoGrab — 悬浮抓取网页视频链接
#
# Rootless (Dopamine /var/jb):
#   make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
# RootHide (Dopamine 隐根 / roothide bootstrap):
#   make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
#

ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
TARGET := iphone:clang:16.5:15.0
else
TARGET := iphone:clang:16.5:15.0
endif
ARCHS := arm64 arm64e
INSTALL_TARGET_PROCESSES := MobileSafari

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := XLHVideoGrab

XLHVideoGrab_FILES := Tweak.xm \
                      VGCommon.m \
                      VGManager.m \
                      VGOverlay.m \
                      VGDownloader.m \
                      VGScript.m \
                      VGNative.xm

XLHVideoGrab_CFLAGS := -fobjc-arc -O2 -Wall -Wno-unused-parameter -Wno-unused-function
XLHVideoGrab_FRAMEWORKS := Foundation UIKit WebKit CoreGraphics AVFoundation

# Logos 生成的钩子需要 libsubstrate 符号（MSHookMessageEx 等）。
# rootless 工具链提供 /var/jb 版 tbd；roothide 工具链提供 @loader_path/.jbroot 版 tbd。
XLHVideoGrab_LIBRARIES := substrate

# RootHide 额外需要 libroothide（jbroot() / rootfs() 的实现）。
ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
XLHVideoGrab_LIBRARIES += roothide
XLHVideoGrab_CFLAGS += -DDISABLE_ROOTLESS_COMPAT_WARNING=1
endif

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari SpringBoard 2>/dev/null || true"
