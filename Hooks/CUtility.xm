#import <Foundation/Foundation.h>

static NSInteger gWeChatVersion = 0; // 0 表示未选择版本
static NSString * const kWeChatCustomVersionKey = @"com.wechat.tweak.version.custom"; // 自定义版本的键

%hook CUtility

+ (NSInteger)GetVersion {
    if (gWeChatVersion == 0) {
        // 未选择版本时完全使用原始实现
        return %orig;
    } else if (gWeChatVersion < 0) {
        // 负数值表示使用自定义版本号
        NSString *customVersionStr = [[NSUserDefaults standardUserDefaults] stringForKey:kWeChatCustomVersionKey];
        if (customVersionStr.length > 0) {
            NSInteger customVersion = [customVersionStr integerValue];
            if (customVersion > 0) {
                return customVersion;
            }
        }
        // 如果无法获取有效的自定义版本，则回退到原始实现
        return %orig;
    }
    // 正数值表示使用预设版本
    return gWeChatVersion;
}

%end

// 监听版本变更通知
%ctor {
    // 从 NSUserDefaults 读取保存的版本
    NSInteger savedVersion = [[NSUserDefaults standardUserDefaults] integerForKey:@"com.wechat.tweak.version.selected"];
    
    if (savedVersion != 0) {
        gWeChatVersion = savedVersion;
    }
    
    // 添加通知观察者
    [[NSNotificationCenter defaultCenter] addObserverForName:@"WeChat.Version.Changed"
                                                    object:nil
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification *notification) {
        NSNumber *version = notification.userInfo[@"version"];
        if (version) {
            // 处理正常传入的版本号 (正数)
            NSInteger versionValue = [version integerValue];
            
            // 检查是否为自定义版本 (在设置中保存为负数)
            if (versionValue > 0) {
                // 如果传入的是正值，但在设置中保存为负值表示自定义版本
                gWeChatVersion = -versionValue;
            } else {
                // 否则直接使用传入的值（预设版本或0表示关闭）
                gWeChatVersion = versionValue;
            }
        }
    }];
} 