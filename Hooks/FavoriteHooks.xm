// HOOK 收藏验证
#import "../Headers/WCHeaders.h"
#import <LocalAuthentication/LocalAuthentication.h>

// 生物认证相关常量（直接在文件中定义，避免引入额外文件）
static NSString * const kFavoriteUserDefaultsSuiteName = @"com.cyansmoke.wechattweak";
static NSString * const kBiometricAuthFavKey = @"com.wechat.tweak.biometric.auth.favorite";
static NSString * const kBiometricAuthFavReason = @"请验证您的身份以查看收藏内容";

%hook MoreViewController

- (void)showFavoriteView {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kFavoriteUserDefaultsSuiteName];
    if (![defaults boolForKey:kBiometricAuthFavKey]) {
        %orig;
        return;
    }
    
    // 需要验证
    LAContext *context = [[LAContext alloc] init];
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:kBiometricAuthFavReason
                    reply:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                %orig;
            }
        });
    }];
}

%end 