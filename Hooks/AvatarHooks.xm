// 处理隐藏头像相关的hook
#import "../Controllers/CSAvatarSettingsViewController.h"
#import "../Headers/WCHeaders.h"
#import <objc/runtime.h>

// 存储当前聊天场景状态
static BOOL currentChatIsPrivate = NO;
static BOOL currentChatIsGroup = NO;
static BOOL currentChatIsOfficial = NO;
static NSString *currentChatID = nil;

// 辅助函数：查找父视图控制器
UIViewController *findParentViewControllerForChat(UIView *view) {
    UIResponder *responder = [view nextResponder];
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

// Hook BaseMsgContentViewController来识别聊天类型
%hook BaseMsgContentViewController

- (void)viewDidLoad {
    %orig;
    
    // 重置聊天类型状态
    currentChatIsPrivate = NO;
    currentChatIsGroup = NO;
    currentChatIsOfficial = NO;
    currentChatID = nil;
    
    // 获取聊天联系人
    CContact *contact = [self GetContact];
    if (!contact) {
        return;
    }
    
    // 获取聊天ID - 使用m_nsUsrName属性
    NSString *chatID = [contact valueForKey:@"m_nsUsrName"];
    if (!chatID) {
        return;
    }
    
    // 保存当前聊天ID
    currentChatID = chatID;
    
    // 判断聊天类型
    if ([chatID hasPrefix:@"gh_"]) {
        // 公众号聊天
        currentChatIsOfficial = YES;
    } else if ([chatID hasSuffix:@"@chatroom"]) {
        // 群聊
        currentChatIsGroup = YES;
    } else {
        // 假设其他都是私聊（普通联系人可能没有特定前缀）
        currentChatIsPrivate = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    // 更新聊天联系人信息（防止中途切换联系人）
    CContact *contact = [self GetContact];
    if (!contact) {
        return;
    }
    
    // 获取聊天ID
    NSString *chatID = [contact valueForKey:@"m_nsUsrName"];
    if (!chatID) {
        return;
    }
    
    // 保存/更新当前聊天ID
    currentChatID = chatID;
    
    // 重置并更新聊天类型
    currentChatIsPrivate = NO;
    currentChatIsGroup = NO;
    currentChatIsOfficial = NO;
    
    if ([chatID hasPrefix:@"gh_"]) {
        // 公众号聊天
        currentChatIsOfficial = YES;
    } else if ([chatID hasSuffix:@"@chatroom"]) {
        // 群聊
        currentChatIsGroup = YES;
    } else {
        // 假设其他都是私聊
        currentChatIsPrivate = YES;
    }
}

%end

// 辅助函数：判断是否应该隐藏自己的头像
BOOL shouldHideSelfAvatar(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    
    // 根据当前场景判断是否应该隐藏自己的头像
    if (currentChatIsPrivate) {
        // 私聊场景：检查"隐藏自己头像"或"隐藏双方头像"设置
        return [defaults boolForKey:kHideSelfAvatarInPrivateChatKey] || 
               [defaults boolForKey:kHideBothAvatarInPrivateChatKey];
    } 
    else if (currentChatIsGroup) {
        // 群聊场景：检查"隐藏自己头像"或"隐藏双方头像"设置
        return [defaults boolForKey:kHideSelfAvatarInGroupChatKey] || 
               [defaults boolForKey:kHideBothAvatarInGroupChatKey];
    }
    else if (currentChatIsOfficial) {
        // 公众号场景：检查"隐藏自己头像"或"隐藏双方头像"设置
        return [defaults boolForKey:kHideSelfAvatarInOfficialAccountKey] || 
               [defaults boolForKey:kHideBothAvatarInOfficialAccountKey];
    }
    
    // 不在已知场景中，默认不隐藏
    return NO;
}

// 辅助函数：判断是否应该隐藏他人的头像
BOOL shouldHideOtherAvatar(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    
    // 根据当前场景判断是否应该隐藏他人的头像
    if (currentChatIsPrivate) {
        // 私聊场景：检查"隐藏对方头像"或"隐藏双方头像"设置
        return [defaults boolForKey:kHideOtherAvatarInPrivateChatKey] || 
               [defaults boolForKey:kHideBothAvatarInPrivateChatKey];
    } 
    else if (currentChatIsGroup) {
        // 群聊场景：检查"隐藏对方头像"或"隐藏双方头像"设置
        return [defaults boolForKey:kHideOtherAvatarInGroupChatKey] || 
               [defaults boolForKey:kHideBothAvatarInGroupChatKey];
    }
    else if (currentChatIsOfficial) {
        // 公众号场景：检查"隐藏对方头像"或"隐藏双方头像"设置
        return [defaults boolForKey:kHideOtherAvatarInOfficialAccountKey] || 
               [defaults boolForKey:kHideBothAvatarInOfficialAccountKey];
    }
    
    // 不在已知场景中，默认不隐藏
    return NO;
}

%hook CommonMessageViewModel

- (BOOL)isShowHeadImage {
    // 获取当前消息是否为自己发送的
    BOOL isSelfMessage = [self isSender];
    
    // 根据消息发送者选择对应的隐藏逻辑
    BOOL shouldHide;
    if (isSelfMessage) {
        shouldHide = shouldHideSelfAvatar();
    } else {
        shouldHide = shouldHideOtherAvatar();
    }
    
    BOOL shouldShow = !shouldHide;
    
    return shouldShow;
}

%end 