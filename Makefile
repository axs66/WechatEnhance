export DEBUG=0
export FINALPACKAGE=1

# 确保 Theos 目录正确
THEOS := $(CURDIR)/theos  

# 项目名称
TWEAK_NAME = WeChatEnhance

# 根据 SCHEME 变量的值设置 Theos 包的方案和安装路径。
ifeq ($(SCHEME),roothide)
    export THEOS_PACKAGE_SCHEME = roothide
else ifeq ($(SCHEME),rootless)
    export THEOS_PACKAGE_SCHEME = rootless
else ifeq ($(SCHEME),rootful)
    export THEOS_PACKAGE_SCHEME = rootful
endif

# 目标设备最低版本
export ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

# 源文件
WeChatEnhance_FILES = $(wildcard Hooks/*.xm) \
                     $(wildcard Controllers/*.m) 

# 编译标志
WeChatEnhance_CFLAGS = -fobjc-arc \
                       -I$(THEOS_PROJECT_DIR)/Headers \
                       -I$(THEOS_PROJECT_DIR)/Hooks \
                       -Wno-error 

# 框架依赖
WeChatEnhance_FRAMEWORKS = UIKit Foundation LocalAuthentication

# 包含 Theos make 系统
include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/tweak.mk

clean::
	@echo -e "\033[31m==>\033[0m 正在清理......"
	@rm -rf .theos packages

after-package::
	@echo -e "\033[32m==>\033[0m 编译完成！生成deb包：$$(ls -t packages/*.deb | head -1)"
	@echo -e "\033[32m==>\033[0m 请运行 ./install.sh 将插件安装到设备"
