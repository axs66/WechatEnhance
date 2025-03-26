#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 * 微信热更新禁用钩子
 * 通过hook WCUpdateMgr相关方法，阻止微信热更新的下载、解压与执行
 */

// 常量字符串KEY定义
static NSString * const kDisableLoadMainUpdateBundleKey = @"com.wechat.tweak.disable.loadMainUpdateBundle";
static NSString * const kDisableForceUpdateKey = @"com.wechat.tweak.disable.forceUpdate";
static NSString * const kDisableUnzipBundleUpdatesKey = @"com.wechat.tweak.disable.unzipBundleUpdates";
static NSString * const kDisableUnzipDownloadUpdatesKey = @"com.wechat.tweak.disable.unzipDownloadUpdates";
static NSString * const kDisableLoadAndExecuteKey = @"com.wechat.tweak.disable.loadAndExecute";
static NSString * const kDisableRegisterUpdateKey = @"com.wechat.tweak.disable.registerUpdate";
static NSString * const kDisableTryRegisterUpdateKey = @"com.wechat.tweak.disable.tryRegisterUpdate";
static NSString * const kDisableOnPResUpdateFinishKey = @"com.wechat.tweak.disable.onPResUpdateFinish";
static NSString * const kDisableTryRenameTmpUpdateDataDirKey = @"com.wechat.tweak.disable.tryRenameTmpUpdateDataDir";
static NSString * const kDisableLoadResourceKey = @"com.wechat.tweak.disable.loadResource";
static NSString * const kDisableLoadPluginInBundleKey = @"com.wechat.tweak.disable.loadPluginInBundle";
static NSString * const kDisableLoadBundleKey = @"com.wechat.tweak.disable.loadBundle";
static NSString * const kDisableShouldTraceKey = @"com.wechat.tweak.disable.shouldTrace";
static NSString * const kDisableImmediateRenameUpdateKey = @"com.wechat.tweak.disable.immediateRenameUpdate";
static NSString * const kAllUpdateFunctionsDisabledKey = @"com.wechat.tweak.disable.allUpdateFunctions";

%hook WCUpdateMgr

// 阻止加载主更新包
- (BOOL)loadMainUpdateBundle {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableLoadMainUpdateBundleKey]) {
        return NO;
    }
    return %orig;
}

// 阻止强制更新
- (void)forceUpdate:(unsigned int)arg1 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableForceUpdateKey]) {
        return;
    }
    %orig;
}

// 阻止解压更新包
- (BOOL)unzipBundleUpdates {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableUnzipBundleUpdatesKey]) {
        return NO;
    }
    return %orig;
}

// 阻止解压下载的更新
- (BOOL)unzipDownloadUpdates:(id)arg1 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableUnzipDownloadUpdatesKey]) {
        return NO;
    }
    return %orig;
}

// 阻止解压下载的更新（重载方法）
- (BOOL)unzipDownloadUpdates:(id)arg1 to:(id)arg2 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableUnzipDownloadUpdatesKey]) {
        return NO;
    }
    return %orig;
}

// 阻止加载并执行更新
- (void)loadAndExecute {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableLoadAndExecuteKey]) {
        return;
    }
    %orig;
}

// 阻止注册更新
- (void)registerUpdate:(unsigned long long)arg1 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableRegisterUpdateKey]) {
        return;
    }
    %orig;
}

// 阻止尝试注册更新
- (void)tryRegisterUpdate {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableTryRegisterUpdateKey]) {
        return;
    }
    %orig;
}

// 阻止更新资源完成后的回调处理
- (void)onPResUpdateFinish:(unsigned long long)arg1 updateType:(unsigned long long)arg2 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableOnPResUpdateFinishKey]) {
        return;
    }
    %orig;
}

// 禁用尝试重命名临时更新数据目录
- (void)tryRenameTmpUpdateDataDir {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableTryRenameTmpUpdateDataDirKey]) {
        return;
    }
    %orig;
}

// 禁用资源加载
- (BOOL)loadResource {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableLoadResourceKey]) {
        return NO;
    }
    return %orig;
}

// 禁用加载插件
- (BOOL)loadPluginInBundle:(id)arg1 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableLoadPluginInBundleKey]) {
        return NO;
    }
    return %orig;
}

// 禁用加载插件（重载方法）
- (BOOL)loadPluginInBundle:(id)arg1 withIDKey:(const struct BundleLoadIDKey *)arg2 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableLoadPluginInBundleKey]) {
        return NO;
    }
    return %orig;
}

// 禁用加载bundle
- (BOOL)loadBundle:(id)arg1 withIDKey:(const struct BundleLoadIDKey *)arg2 {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableLoadBundleKey]) {
        return NO;
    }
    return %orig;
}

// 类方法 - 阻止追踪
+ (BOOL)shouldTrace {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableShouldTraceKey]) {
        return NO;
    }
    return %orig;
}

// 类方法 - 阻止立即重命名更新
+ (void)immediateRenameUpdate {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableImmediateRenameUpdateKey]) {
        return;
    }
    %orig;
}

%end 