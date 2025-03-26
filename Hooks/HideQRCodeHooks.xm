// HOOK 隐藏二维码按钮
#import <UIKit/UIKit.h>

// 定义NSUserDefaults的键
static NSString * const kWCHideQRCodeEnabledKey = @"com.wechat.tweak.hide_qrcode_enabled";
// 定义通知名称
static NSString * const kWCSettingsChangedNotification = @"com.wechat.tweak.settings_changed";

// 缓存设置状态的静态变量
static BOOL gHideQRCodeEnabled = NO;

// 从NSUserDefaults读取设置
static void loadSettings() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 如果设置不存在，默认为关闭
    gHideQRCodeEnabled = [defaults objectForKey:kWCHideQRCodeEnabledKey] ? [defaults boolForKey:kWCHideQRCodeEnabledKey] : NO;
}

%hook UIButton

// 重写setAccessibilityLabel方法，用于设置按钮的无障碍标签
- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
    %orig;

    // 如果隐藏二维码功能未启用，则不隐藏按钮
    if (!gHideQRCodeEnabled) {
        return;
    }

    if ([accessibilityLabel isEqualToString:@"我的⼆维码"]) {
        self.hidden = YES;
    }
}

%end

// 构造函数，在加载时执行
%ctor {
    // 加载设置
    loadSettings();
    
    // 添加通知观察者，当设置变化时重新加载
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    (CFNotificationCallback)loadSettings,
                                    CFSTR("com.wechat.tweak.settings_changed"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
} 