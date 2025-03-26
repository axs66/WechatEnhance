// WCUploadTaskHook.xm
// 朋友圈后缀功能

#import "../Headers/WCHeaders.h"

// 声明必要的类
@interface WCAppInfo : NSObject
- (void)setAppID:(NSString *)appID;
- (void)setAppName:(NSString *)appName;
@end

@interface WCUploadTask : NSObject
- (WCAppInfo *)appInfo;
@end

// 朋友圈后缀相关常量
static NSString * const kWCTimeLineMessageTailText = @"WCTimeLineMessageTailText";       // 朋友圈后缀文本
static NSString * const kWCTimeLineMessageTailEnabled = @"WCTimeLineMessageTailEnabled"; // 朋友圈后缀开关

// 让我们修改微信上传时候所用的appInfo，实现自定义朋友圈后缀
%hook WCUploadTask

- (WCAppInfo *)appInfo {
    NSString *tailText = [NSUserDefaults.standardUserDefaults stringForKey:kWCTimeLineMessageTailText];
    BOOL isTailEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kWCTimeLineMessageTailEnabled]; // 读取开关状态
    
    if (!isTailEnabled || !tailText || tailText.length < 1) {
        return %orig; // 如果开关关闭或没有设置文本，返回原始 appInfo
    }
    
    WCAppInfo *appInfo = [[%c(WCAppInfo) alloc] init];
    // 生成8位随机数字
    NSMutableString *randomString = [NSMutableString stringWithCapacity:8];
    for (int i = 0; i < 8; i++) {
        [randomString appendFormat:@"%d", arc4random_uniform(10)];
    }
    
    // 所需18位, 我们随机末尾8位字符
    [appInfo setAppID:[NSString stringWithFormat:@"wxa5e0de08%@", randomString]];
    [appInfo setAppName:tailText]; // 使用用户设置的文本
    return appInfo;
}

%end 