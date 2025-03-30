TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ExitLagBypassFinal
ExitLagBypassFinal_FILES = Tweak.xm
ExitLagBypassFinal_FRAMEWORKS = StoreKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
