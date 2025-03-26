// CustomEntryHooks.xm
// 微信自定义入口 Hook
// 该文件负责在微信注册自定义插件入口

#import "../Headers/WCHeaders.h"      // 微信相关的所有类和框架
#import "../Headers/CSUserInfoHelper.h" // 用户信息助手和全局常量
#import "../Headers/WCPluginsHeader.h"  // 其他插件提供的接口声明
#import "../Controllers/CSCustomViewController.h" // 自定义设置页面
#import "../Controllers/CSEntrySettingsViewController.h" // 入口设置控制器

// 入口设置相关的键
static NSString * const kEntryDisplayModeKey = @"com.wechat.tweak.entry.display.mode";
static NSString * const kEntryCustomTitleKey = @"com.wechat.tweak.entry.custom.title";
static NSString * const kEntrySettingsChangedNotification = @"com.wechat.tweak.entry.settings.changed";

// 定义入口标题变量，可根据设置动态更改
static NSString *gCustomEntryTitle = nil;

// 获取入口图标
static inline UIImage * __nullable getCustomEntryIcon(void) {
    // 使用系统图标并设置蓝色
    UIImage *icon = [UIImage systemImageNamed:@"signature.th"];
    return [icon imageWithTintColor:[UIColor systemBlueColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
}

// 获取显示模式设置
static CSEntryDisplayMode getEntryDisplayMode() {
    return (CSEntryDisplayMode)[[NSUserDefaults standardUserDefaults] integerForKey:kEntryDisplayModeKey];
}

// 获取自定义标题
static NSString *getCustomEntryTitle() {
    if (!gCustomEntryTitle) {
        NSString *savedTitle = [[NSUserDefaults standardUserDefaults] objectForKey:kEntryCustomTitleKey];
        gCustomEntryTitle = savedTitle ?: @"Wechat";
    }
    return gCustomEntryTitle;
}

// 加载设置
static void loadEntrySettings() {
    // 加载自定义标题
    gCustomEntryTitle = getCustomEntryTitle();
    NSLog(@"[WeChatTweak] 入口设置已加载: 显示模式=%ld, 标题=%@", (long)getEntryDisplayMode(), gCustomEntryTitle);
}

// 监听设置变更的回调
static void entrySettingsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // 重新加载设置
    loadEntrySettings();
}

%hook MoreViewController

// 在"设置"页面添加功能入口
- (void)addFunctionSection {
    // 调用原始方法
    %orig;
    
    // 获取显示模式
    CSEntryDisplayMode displayMode = getEntryDisplayMode();
    
    // 如果设置为只在插件入口显示，则不添加到设置页面
    if (displayMode == CSEntryDisplayModePlugin) {
        NSLog(@"[WeChatTweak] 根据设置跳过在设置页面添加入口");
        return;
    }
    
    // 获取自定义标题
    NSString *entryTitle = getCustomEntryTitle();
    
    // 获取tableViewMgr
    WCTableViewManager *tableViewMgr = MSHookIvar<id>(self, "m_tableViewMgr");
    if (!tableViewMgr) { 
        return; 
    }
    
    // 获取第三个section（通常是功能区域）
    WCTableViewSectionManager *section = [tableViewMgr getSectionAt:2];
    if (!section) { 
        return; 
    }
    
    // 创建自定义入口cell
    WCTableViewCellManager *customEntryCell = [%c(WCTableViewCellManager) normalCellForSel:@selector(onCustomEntryClick)
                                                                              target:self
                                                                           leftImage:getCustomEntryIcon()
                                                                              title:entryTitle
                                                                              badge:nil
                                                                         rightValue:nil
                                                                        rightImage:nil
                                                                   withRightRedDot:NO
                                                                          selected:NO];
    
    // 添加cell到section
    [section addCell:customEntryCell];
    NSLog(@"[WeChatTweak] 已在设置页面添加入口: %@", entryTitle);
}

// 处理入口点击事件
%new
- (void)onCustomEntryClick {
    // 创建并配置自定义控制器
    CSCustomViewController *customVC = [[CSCustomViewController alloc] init];
    customVC.title = getCustomEntryTitle();
    
    // 创建导航控制器（用于模态展示）
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:customVC];
    
    // 设置模态展示样式（iOS 13+）
    if (@available(iOS 13.0, *)) {
        navVC.modalPresentationStyle = UIModalPresentationFormSheet; // 使用表单样式
    } else {
        navVC.modalPresentationStyle = UIModalPresentationPageSheet; // 向上滑动样式
    }
    
    // 模态展示控制器
    [self presentViewController:navVC animated:YES completion:nil];
}

%end

%hook MinimizeViewController

static int isRegister = 0;

-(void)viewDidLoad{
    %orig;
    
    // 获取显示模式
    CSEntryDisplayMode displayMode = getEntryDisplayMode();
    
    // 如果设置为只在设置页面显示，则不添加到插件入口
    if (displayMode == CSEntryDisplayModeMore) {
        NSLog(@"[WeChatTweak] 根据设置跳过在插件入口添加入口");
        return;
    }
    
    if (NSClassFromString(@"WCPluginsMgr") && isRegister == 0) {
        isRegister = 1;
        
        // 获取自定义标题
        NSString *title = getCustomEntryTitle();
        NSString *version = kPluginVersionString;
        NSString *controller = @"CSCustomViewController";
        
        NSLog(@"[WeChatTweak] 尝试注册自定义入口: %@, 控制器: %@", title, controller);
        
        @try {
            Class wcPluginsMgr = objc_getClass("WCPluginsMgr");
            if (wcPluginsMgr) {
                id instance = [wcPluginsMgr performSelector:@selector(sharedInstance)];
                if (instance) {
                    SEL registerSel = @selector(registerControllerWithTitle:version:controller:);
                    if ([instance respondsToSelector:registerSel]) {
                        [instance registerControllerWithTitle:title version:version controller:controller];
                        NSLog(@"[WeChatTweak] 成功注册自定义入口: %@", title);
                    } else {
                        NSLog(@"[WeChatTweak] 注册失败: registerControllerWithTitle方法不存在");
                    }
                } else {
                    NSLog(@"[WeChatTweak] 注册失败: 无法获取WCPluginsMgr实例");
                }
            } else {
                NSLog(@"[WeChatTweak] 注册失败: WCPluginsMgr类不存在");
            }
        } @catch (NSException *exception) {
            NSLog(@"[WeChatTweak] 注册入口失败: %@", exception);
        }
    }
}
%end

// 注册设置变更通知和初始化
%ctor {
    // 加载设置
    loadEntrySettings();
    
    // 注册通知观察者，当设置变化时重新加载
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                   NULL,
                                   entrySettingsChangedCallback,
                                   CFSTR("com.wechat.tweak.entry.settings.changed"),
                                   NULL,
                                   CFNotificationSuspensionBehaviorDeliverImmediately);
} 