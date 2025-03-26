// 禁用微信界面原生标签显示-界面净化

#import <UIKit/UIKit.h>

// 定义NSUserDefaults键名与通知名称（与CSUICleanViewController.m中保持一致）
static NSString * const kWCHideChatTimeEnabledKey = @"com.wechat.tweak.hide_chat_time_enabled";
// 添加隐藏撤回消息标签的键
static NSString * const kWCHideRevokeMessageEnabledKey = @"com.wechat.tweak.hide_revoke_message_enabled";
// 添加隐藏拍一拍消息标签的键
static NSString * const kWCHidePatMessageEnabledKey = @"com.wechat.tweak.hide_pat_message_enabled";
// 添加隐藏语音红点和转文字标签的键
static NSString * const kWCHideVoiceHintEnabledKey = @"com.wechat.tweak.hide_voice_hint_enabled";
static NSString * const kWCSettingsChangedNotification = @"com.wechat.tweak.settings_changed";

// 全局变量，保存当前设置状态
static BOOL gHideChatTimeEnabled = NO;
// 隐藏撤回消息的全局变量
static BOOL gHideRevokeMessageEnabled = NO;
// 隐藏拍一拍消息的全局变量
static BOOL gHidePatMessageEnabled = NO;
// 隐藏语音消息红点和转文字的全局变量
static BOOL gHideVoiceHintEnabled = NO;

// 从NSUserDefaults读取设置状态
static void loadSettings() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    gHideChatTimeEnabled = [defaults boolForKey:kWCHideChatTimeEnabledKey];
    gHideRevokeMessageEnabled = [defaults boolForKey:kWCHideRevokeMessageEnabledKey];
    gHidePatMessageEnabled = [defaults boolForKey:kWCHidePatMessageEnabledKey];
    gHideVoiceHintEnabled = [defaults boolForKey:kWCHideVoiceHintEnabledKey];
}

// 设置更改通知回调
static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadSettings();
}

// 前向声明
@class ChatTimeCellView, ChatTimeViewModel, SystemMessageCellView, SystemMessageViewModel, AppPatMessageCellView, AppPatMessageViewModel;

// Hook ChatTimeCellView类，根据设置决定是否隐藏
%hook ChatTimeCellView

// 初始化时根据设置决定是否隐藏视图
- (id)initWithViewModel:(id)arg1 {
    id view = %orig;
    if (view && gHideChatTimeEnabled) {
        // 根据设置决定是否隐藏视图
        UIView *selfView = (UIView *)view;
        [selfView setHidden:YES];
        
        // 设置高度为0，使其不占用空间
        CGRect frame = [selfView frame];
        frame.size.height = 0;
        [selfView setFrame:frame];
    }
    return view;
}

// 覆盖布局方法，根据设置决定是否执行
- (void)layoutInternal {
    if (gHideChatTimeEnabled) {
        // 设置为隐藏时不执行布局
        return;
    }
    %orig;
}

// 覆盖canBeReused方法
- (BOOL)canBeReused {
    if (gHideChatTimeEnabled) {
        return YES;
    }
    return %orig;
}

// 覆盖shouldLayoutIfNeeded方法
- (BOOL)shouldLayoutIfNeeded {
    if (gHideChatTimeEnabled) {
        return NO;
    }
    return %orig;
}

%end

// Hook ChatTimeViewModel，修改其尺寸计算方法
%hook ChatTimeViewModel

// 覆盖measure方法，根据设置决定返回值
- (CGSize)measure:(CGSize)arg1 {
    if (gHideChatTimeEnabled) {
        // 设置为隐藏时返回零高度
        return CGSizeMake(arg1.width, 0);
    }
    return %orig;
}

%end

// Hook SystemMessageCellView类，根据设置决定是否隐藏撤回消息
%hook SystemMessageCellView

// 初始化时根据设置决定是否隐藏视图
- (id)initWithViewModel:(id)arg1 {
    id view = %orig;
    if (view && gHideRevokeMessageEnabled) {
        // 根据设置决定是否隐藏视图
        UIView *selfView = (UIView *)view;
        [selfView setHidden:YES];
        
        // 设置高度为0，使其不占用空间
        CGRect frame = [selfView frame];
        frame.size.height = 0;
        [selfView setFrame:frame];
    }
    return view;
}

// 覆盖布局方法，根据设置决定是否执行
- (void)layoutInternal {
    if (gHideRevokeMessageEnabled) {
        // 设置为隐藏时不执行布局
        return;
    }
    %orig;
}

// 覆盖canBeReused方法
- (BOOL)canBeReused {
    if (gHideRevokeMessageEnabled) {
        return YES;
    }
    return %orig;
}

// 覆盖shouldLayoutIfNeeded方法
- (BOOL)shouldLayoutIfNeeded {
    if (gHideRevokeMessageEnabled) {
        return NO;
    }
    return %orig;
}

%end

// Hook SystemMessageViewModel，修改其尺寸计算方法
%hook SystemMessageViewModel

// 覆盖measure方法，根据设置决定返回值
- (CGSize)measure:(CGSize)arg1 {
    if (gHideRevokeMessageEnabled) {
        // 设置为隐藏时返回零高度
        return CGSizeMake(arg1.width, 0);
    }
    return %orig;
}

%end

// Hook AppPatMessageCellView类，根据设置决定是否隐藏拍一拍消息
%hook AppPatMessageCellView

// 初始化时根据设置决定是否隐藏视图
- (id)initWithViewModel:(id)arg1 {
    id view = %orig;
    if (view && gHidePatMessageEnabled) {
        // 根据设置决定是否隐藏视图
        UIView *selfView = (UIView *)view;
        [selfView setHidden:YES];
        
        // 设置高度为0，使其不占用空间
        CGRect frame = [selfView frame];
        frame.size.height = 0;
        [selfView setFrame:frame];
    }
    return view;
}

// 覆盖布局方法，根据设置决定是否执行
- (void)layoutInternal {
    if (gHidePatMessageEnabled) {
        // 设置为隐藏时不执行布局
        return;
    }
    %orig;
}

// 覆盖canBeReused方法
- (BOOL)canBeReused {
    if (gHidePatMessageEnabled) {
        return YES;
    }
    return %orig;
}

// 覆盖shouldLayoutIfNeeded方法
- (BOOL)shouldLayoutIfNeeded {
    if (gHidePatMessageEnabled) {
        return NO;
    }
    return %orig;
}

%end

// Hook AppPatMessageViewModel，修改其尺寸计算方法
%hook AppPatMessageViewModel

// 覆盖measure方法，根据设置决定返回值
- (CGSize)measure:(CGSize)arg1 {
    if (gHidePatMessageEnabled) {
        // 设置为隐藏时返回零高度
        return CGSizeMake(arg1.width, 0);
    }
    return %orig;
}

%end

// 修改VoiceMessageCellView的声明，不使用具体属性
@interface VoiceMessageCellView : UIView
@end

// Hook VoiceMessageCellView类，隐藏语音消息的红点和转文字按钮
%hook VoiceMessageCellView

// 使用layoutSubviews方法来隐藏红点和转文字按钮
- (void)layoutSubviews {
    %orig;
    
    if (gHideVoiceHintEnabled) {
        // 使用KVC安全地获取并隐藏红点视图
        UIView *unreadView = [self valueForKey:@"m_unreadImageView"];
        if (unreadView) {
            [unreadView setHidden:YES];
        }
        
        // 使用KVC安全地获取并隐藏转文字按钮
        UIButton *transButton = [self valueForKey:@"m_quickTransTipButton"];
        if (transButton) {
            [transButton setHidden:YES];
        }
    }
}

%end

// 初始化函数
%ctor {
    // 读取初始设置
    loadSettings();
    
    // 注册设置变更通知
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        settingsChanged,
        CFSTR("com.wechat.tweak.settings_changed"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );
} 