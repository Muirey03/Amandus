include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Amandus

Amandus_FILES = AMDRootListController.m
Amandus_INSTALL_PATH = /Library/PreferenceBundles
Amandus_CFLAGS = -fobjc-arc -I../Include
Amandus_LDFLAGS = -F../Frameworks
Amandus_FRAMEWORKS = UIKit Preferences CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Amandus.plist$(ECHO_END)
