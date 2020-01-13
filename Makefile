export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = PassbookUIService

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Amandus
Amandus_FILES = $(wildcard *.xm)
Amandus_CFLAGS = -fobjc-arc -IInclude
Amandus_LDFLAGS = -FFrameworks
Amandus_FRAMEWORKS = UIKit Cephei
Amandus_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += amandus
include $(THEOS_MAKE_PATH)/aggregate.mk
