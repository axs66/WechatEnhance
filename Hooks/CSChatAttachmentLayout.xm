#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 保存设置的键
static NSString * const kChatAttachmentLayoutEnabledKey = @"com.wechat.tweak.chat.attachment.layout.enabled";
static NSString * const kChatAttachmentColumnsKey = @"com.wechat.tweak.chat.attachment.columns";
static NSString * const kChatAttachmentSpacingKey = @"com.wechat.tweak.chat.attachment.spacing";
// 场景控制相关键
static NSString * const kChatAttachmentShowInPrivateKey = @"com.wechat.tweak.chat.attachment.show.in.private";
static NSString * const kChatAttachmentShowInGroupKey = @"com.wechat.tweak.chat.attachment.show.in.group";
static NSString * const kChatAttachmentShowInOfficialKey = @"com.wechat.tweak.chat.attachment.show.in.official";
// 公众号自定义排序相关键
static NSString * const kChatAttachmentOfficialSortEnabledKey = @"com.wechat.tweak.chat.attachment.official.sort.enabled";
static NSString * const kChatAttachmentOfficialSortOrderKey = @"com.wechat.tweak.chat.attachment.official.sort.order";
// 私聊自定义排序相关键
static NSString * const kChatAttachmentPrivateSortEnabledKey = @"com.wechat.tweak.chat.attachment.private.sort.enabled";
static NSString * const kChatAttachmentPrivateSortOrderKey = @"com.wechat.tweak.chat.attachment.private.sort.order";
// 群聊自定义排序相关键
static NSString * const kChatAttachmentGroupSortEnabledKey = @"com.wechat.tweak.chat.attachment.group.sort.enabled";
static NSString * const kChatAttachmentGroupSortOrderKey = @"com.wechat.tweak.chat.attachment.group.sort.order";
// 按钮隐藏相关键
static NSString * const kChatAttachmentOfficialHiddenButtonsKey = @"com.wechat.tweak.chat.attachment.official.hidden.buttons";
static NSString * const kChatAttachmentPrivateHiddenButtonsKey = @"com.wechat.tweak.chat.attachment.private.hidden.buttons";
static NSString * const kChatAttachmentGroupHiddenButtonsKey = @"com.wechat.tweak.chat.attachment.group.hidden.buttons";

// 设置默认值
static const int kDefaultColumns = 5;
static const float kDefaultSpacing = 0.0f;
static const float kBaseSpacing = 8.0f; // 微信默认基础间距

// 公众号按钮Tag常量
static const int kTagPhoto = 18000;       // 照片
static const int kTagCamera = 18001;      // 拍摄
static const int kTagLocation = 18002;    // 位置
static const int kTagVoiceInput = 18003;  // 语音输入 
static const int kTagFavorite = 18004;    // 收藏
static const int kTagContact = 18005;     // 个人名片

// 私聊按钮Tag常量
static const int kPrivateTagPhoto = 18000;       // 照片
static const int kPrivateTagCamera = 18001;      // 拍摄
static const int kPrivateTagVideoCall = 18002;   // 视频通话
static const int kPrivateTagLocation = 18003;    // 位置
static const int kPrivateTagRedPacket = 18004;   // 红包
static const int kPrivateTagGift = 18005;        // 礼物
static const int kPrivateTagTransfer = 18006;    // 转账
static const int kPrivateTagVoiceInput = 18007;  // 语音输入
static const int kPrivateTagFavorite = 18008;    // 收藏
static const int kPrivateTagContact = 18009;     // 个人名片
static const int kPrivateTagFile = 18010;        // 文件
static const int kPrivateTagCard = 18011;        // 卡券
static const int kPrivateTagMusic = 18012;       // 音乐

// 群聊按钮Tag常量 
static const int kGroupTagPhoto = 18000;        // 照片
static const int kGroupTagCamera = 18001;       // 拍摄
static const int kGroupTagVoiceCall = 18002;    // 语音通话
static const int kGroupTagLocation = 18003;     // 位置
static const int kGroupTagRedPacket = 18004;    // 红包
static const int kGroupTagGift = 18005;         // 礼物
static const int kGroupTagTransfer = 18006;     // 转账
static const int kGroupTagVoiceInput = 18007;   // 语音输入
static const int kGroupTagFavorite = 18008;     // 收藏
static const int kGroupTagGroupTool = 18009;    // 群工具
static const int kGroupTagChain = 18010;        // 接龙
static const int kGroupTagLiveStream = 18011;   // 直播
static const int kGroupTagContact = 18012;      // 个人名片
static const int kGroupTagFile = 18013;         // 文件
static const int kGroupTagCard = 18014;         // 卡券
static const int kGroupTagMusic = 18015;        // 音乐

// 导入微信相关头文件的声明
@interface SelectAttachmentView : UIView
- (void)layoutSubviews;
- (double)itemOffset;
- (struct CGRect)calculateEmoticonViewFrameAtIndex:(unsigned int)arg1 forViewWidth:(double)arg2;
@end

@interface AttachmentButton : UIButton
@end

@interface CBaseContact : NSObject
@property(retain, nonatomic) NSString *m_nsUsrName;
@end

@interface MMUIViewController : UIViewController
@end

@interface CBaseMessageViewController : MMUIViewController
- (id)getMainTableDataSource;
- (CBaseContact *)GetContact;
@end

@interface BaseMsgContentViewController : CBaseMessageViewController
@end

// 存储SelectAttachmentView的宽度，初始值使用设备屏幕宽度
static CGFloat viewWidth = 0;

// 存储当前聊天场景状态
static BOOL currentChatIsPrivate = NO;
static BOOL currentChatIsGroup = NO;
static BOOL currentChatIsOfficial = NO;
static NSString *currentChatID = nil;

// 检查功能是否整体启用
static BOOL isLayoutEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kChatAttachmentLayoutEnabledKey];
}

// 获取列数设置
static int getColumnsCount() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int columns = [defaults objectForKey:kChatAttachmentColumnsKey] ? 
                 [defaults integerForKey:kChatAttachmentColumnsKey] : kDefaultColumns;
    return columns;
}

// 获取间距设置
static float getSpacing() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float spacing = [defaults objectForKey:kChatAttachmentSpacingKey] ? 
                   [defaults floatForKey:kChatAttachmentSpacingKey] : kDefaultSpacing;
    
    // 使用基础间距加上自定义间距
    float totalSpacing = kBaseSpacing + spacing;
    return totalSpacing;
}

// 检查公众号排序功能是否启用
static BOOL isOfficialSortEnabled() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kChatAttachmentOfficialSortEnabledKey];
}

// 获取公众号自定义排序顺序
static NSArray *getOfficialSortOrder() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *sortOrder = [defaults arrayForKey:kChatAttachmentOfficialSortOrderKey];
    
    // 如果没有保存过排序或者数组为空，返回默认排序
    if (!sortOrder || sortOrder.count == 0) {
        sortOrder = @[
            @(kTagPhoto),      // 照片
            @(kTagCamera),     // 拍摄
            @(kTagLocation),   // 位置
            @(kTagVoiceInput), // 语音输入
            @(kTagFavorite),   // 收藏
            @(kTagContact)     // 个人名片
        ];
        // 保存默认排序
        [defaults setObject:sortOrder forKey:kChatAttachmentOfficialSortOrderKey];
        [defaults synchronize];
    }
    
    return sortOrder;
}

// 根据按钮索引获取公众号对应的Tag
static int getOfficialButtonTagAtIndex(unsigned int index) {
    // 公众号按钮的默认tag顺序
    static int defaultOfficialTags[] = {
        kTagPhoto,      // 照片 - 18000
        kTagCamera,     // 拍摄 - 18001
        kTagLocation,   // 位置 - 18002
        kTagVoiceInput, // 语音输入 - 18003
        kTagFavorite,   // 收藏 - 18004
        kTagContact     // 个人名片 - 18005
    };
    
    // 如果索引超出范围，返回原始索引对应的Tag
    if (index >= 6) {
        return defaultOfficialTags[index % 6];
    }
    
    return defaultOfficialTags[index];
}

// 检查私聊排序功能是否启用
static BOOL isPrivateSortEnabled() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kChatAttachmentPrivateSortEnabledKey];
}

// 检查群聊排序功能是否启用
static BOOL isGroupSortEnabled() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kChatAttachmentGroupSortEnabledKey];
}

// 根据按钮索引获取私聊对应的Tag
static int getPrivateButtonTagAtIndex(unsigned int index) {
    // 私聊按钮的默认tag顺序
    static int defaultPrivateTags[] = {
        kPrivateTagPhoto,       // 照片 - 18000
        kPrivateTagCamera,      // 拍摄 - 18001
        kPrivateTagVideoCall,   // 视频通话 - 18002
        kPrivateTagLocation,    // 位置 - 18003
        kPrivateTagRedPacket,   // 红包 - 18004
        kPrivateTagGift,        // 礼物 - 18005
        kPrivateTagTransfer,    // 转账 - 18006
        kPrivateTagVoiceInput,  // 语音输入 - 18007
        kPrivateTagFavorite,    // 收藏 - 18008
        kPrivateTagContact,     // 个人名片 - 18009
        kPrivateTagFile,        // 文件 - 18010
        kPrivateTagCard,        // 卡券 - 18011
        kPrivateTagMusic        // 音乐 - 18012
    };
    
    // 如果索引超出范围，返回原始索引对应的Tag
    if (index >= 13) {
        return defaultPrivateTags[index % 13];
    }
    
    return defaultPrivateTags[index];
}

// 获取私聊自定义排序顺序
static NSArray *getPrivateSortOrder() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *sortOrder = [defaults arrayForKey:kChatAttachmentPrivateSortOrderKey];
    
    // 如果没有保存过排序或者数组为空，返回默认排序
    if (!sortOrder || sortOrder.count == 0) {
        sortOrder = @[
            @(kPrivateTagPhoto),       // 照片
            @(kPrivateTagCamera),      // 拍摄
            @(kPrivateTagVideoCall),   // 视频通话
            @(kPrivateTagLocation),    // 位置
            @(kPrivateTagRedPacket),   // 红包
            @(kPrivateTagGift),        // 礼物
            @(kPrivateTagTransfer),    // 转账
            @(kPrivateTagVoiceInput),  // 语音输入
            @(kPrivateTagFavorite),    // 收藏
            @(kPrivateTagContact),     // 个人名片
            @(kPrivateTagFile),        // 文件
            @(kPrivateTagCard),        // 卡券
            @(kPrivateTagMusic)        // 音乐
        ];
        // 保存默认排序
        [defaults setObject:sortOrder forKey:kChatAttachmentPrivateSortOrderKey];
        [defaults synchronize];
    }
    
    return sortOrder;
}

// 根据自定义排序顺序映射私聊按钮索引
static unsigned int mapPrivateButtonIndexByCustomSort(unsigned int originalIndex) {
    // 获取自定义排序顺序
    NSArray *sortOrder = getPrivateSortOrder();
    
    // 获取原始按钮的Tag
    int originalTag = getPrivateButtonTagAtIndex(originalIndex);
    
    // 在自定义排序中查找该Tag的位置
    NSUInteger newPosition = [sortOrder indexOfObject:@(originalTag)];
    
    // 如果找不到，返回原始索引
    if (newPosition == NSNotFound) {
        return originalIndex;
    }
    
    return (unsigned int)newPosition;
}

// 根据自定义排序顺序映射按钮索引
static unsigned int mapButtonIndexByCustomSort(unsigned int originalIndex) {
    // 获取自定义排序顺序
    NSArray *sortOrder = getOfficialSortOrder();
    
    // 获取原始按钮的Tag
    int originalTag = getOfficialButtonTagAtIndex(originalIndex);
    
    // 在自定义排序中查找该Tag的位置
    NSUInteger newPosition = [sortOrder indexOfObject:@(originalTag)];
    
    // 如果找不到，返回原始索引
    if (newPosition == NSNotFound) {
        return originalIndex;
    }
    
    return (unsigned int)newPosition;
}

// 获取群聊自定义排序顺序
static NSArray *getGroupSortOrder() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *sortOrder = [defaults arrayForKey:kChatAttachmentGroupSortOrderKey];
    
    // 如果没有保存过排序或者数组为空，返回默认排序
    if (!sortOrder || sortOrder.count == 0) {
        sortOrder = @[
            @(kGroupTagPhoto),        // 照片
            @(kGroupTagCamera),       // 拍摄
            @(kGroupTagVoiceCall),    // 语音通话
            @(kGroupTagLocation),     // 位置
            @(kGroupTagRedPacket),    // 红包
            @(kGroupTagGift),         // 礼物
            @(kGroupTagTransfer),     // 转账
            @(kGroupTagVoiceInput),   // 语音输入
            @(kGroupTagFavorite),     // 收藏
            @(kGroupTagGroupTool),    // 群工具
            @(kGroupTagChain),        // 接龙
            @(kGroupTagLiveStream),   // 直播
            @(kGroupTagContact),      // 个人名片
            @(kGroupTagFile),         // 文件
            @(kGroupTagCard),         // 卡券
            @(kGroupTagMusic)         // 音乐
        ];
        // 保存默认排序
        [defaults setObject:sortOrder forKey:kChatAttachmentGroupSortOrderKey];
        [defaults synchronize];
    }
    
    return sortOrder;
}

// 根据按钮索引获取群聊对应的Tag
static int getGroupButtonTagAtIndex(unsigned int index) {
    // 群聊按钮的默认tag顺序
    static int defaultGroupTags[] = {
        kGroupTagPhoto,        // 照片 - 18000
        kGroupTagCamera,       // 拍摄 - 18001
        kGroupTagVoiceCall,    // 语音通话 - 18002
        kGroupTagLocation,     // 位置 - 18003
        kGroupTagRedPacket,    // 红包 - 18004
        kGroupTagGift,         // 礼物 - 18005
        kGroupTagTransfer,     // 转账 - 18006
        kGroupTagVoiceInput,   // 语音输入 - 18007
        kGroupTagFavorite,     // 收藏 - 18008
        kGroupTagGroupTool,    // 群工具 - 18009
        kGroupTagChain,        // 接龙 - 18010
        kGroupTagLiveStream,   // 直播 - 18011
        kGroupTagContact,      // 个人名片 - 18012
        kGroupTagFile,         // 文件 - 18013
        kGroupTagCard,         // 卡券 - 18014
        kGroupTagMusic         // 音乐 - 18015
    };
    
    // 如果索引超出范围，返回原始索引对应的Tag
    if (index >= 16) {
        return defaultGroupTags[index % 16];
    }
    
    return defaultGroupTags[index];
}

// 根据自定义排序顺序映射群聊按钮索引
static unsigned int mapGroupButtonIndexByCustomSort(unsigned int originalIndex) {
    // 获取自定义排序顺序
    NSArray *sortOrder = getGroupSortOrder();
    
    // 获取原始按钮的Tag
    int originalTag = getGroupButtonTagAtIndex(originalIndex);
    
    // 在自定义排序中查找该Tag的位置
    NSUInteger newPosition = [sortOrder indexOfObject:@(originalTag)];
    
    // 如果找不到，返回原始索引
    if (newPosition == NSNotFound) {
        return originalIndex;
    }
    
    return (unsigned int)newPosition;
}

// 获取公众号隐藏按钮列表
static NSArray *getOfficialHiddenButtons() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *hiddenButtons = [defaults arrayForKey:kChatAttachmentOfficialHiddenButtonsKey];
    
    // 如果没有保存过隐藏按钮或者数组为空，返回空数组
    if (!hiddenButtons) {
        return @[];
    }
    
    return hiddenButtons;
}

// 获取私聊隐藏按钮列表
static NSArray *getPrivateHiddenButtons() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *hiddenButtons = [defaults arrayForKey:kChatAttachmentPrivateHiddenButtonsKey];
    
    // 如果没有保存过隐藏按钮或者数组为空，返回空数组
    if (!hiddenButtons) {
        return @[];
    }
    
    return hiddenButtons;
}

// 获取群聊隐藏按钮列表
static NSArray *getGroupHiddenButtons() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *hiddenButtons = [defaults arrayForKey:kChatAttachmentGroupHiddenButtonsKey];
    
    // 如果没有保存过隐藏按钮或者数组为空，返回空数组
    if (!hiddenButtons) {
        return @[];
    }
    
    return hiddenButtons;
}

// 判断公众号按钮是否被隐藏
static BOOL isOfficialButtonHidden(int buttonTag) {
    NSArray *hiddenButtons = getOfficialHiddenButtons();
    return [hiddenButtons containsObject:@(buttonTag)];
}

// 判断私聊按钮是否被隐藏
static BOOL isPrivateButtonHidden(int buttonTag) {
    NSArray *hiddenButtons = getPrivateHiddenButtons();
    return [hiddenButtons containsObject:@(buttonTag)];
}

// 判断群聊按钮是否被隐藏
static BOOL isGroupButtonHidden(int buttonTag) {
    NSArray *hiddenButtons = getGroupHiddenButtons();
    return [hiddenButtons containsObject:@(buttonTag)];
}

// 判断当前聊天环境是否应该启用布局功能
static BOOL shouldEnableLayout() {
    // 如果总开关关闭，直接返回false
    if (!isLayoutEnabled()) {
        return NO;
    }
    
    // 记录场景设置状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showInPrivate = [defaults boolForKey:kChatAttachmentShowInPrivateKey];
    BOOL showInGroup = [defaults boolForKey:kChatAttachmentShowInGroupKey];
    BOOL showInOfficial = [defaults boolForKey:kChatAttachmentShowInOfficialKey];
    
    // 根据已存储的聊天类型判断是否应该启用
    BOOL shouldEnable = NO;
    
    if (currentChatIsOfficial) {
        // 公众号聊天
        shouldEnable = showInOfficial;
    } else if (currentChatIsGroup) {
        // 群聊
        shouldEnable = showInGroup;
    } else if (currentChatIsPrivate) {
        // 私聊
        shouldEnable = showInPrivate;
    } else {
        // 其他未知类型，启用布局功能但保持默认排序
        shouldEnable = showInPrivate; // 使用私聊设置作为默认行为
    }
    
    return shouldEnable;
}

// 钩住BaseMsgContentViewController来识别聊天类型
%hook BaseMsgContentViewController

- (void)viewDidLoad {
    %orig;
    
    // 重置聊天类型状态
    currentChatIsPrivate = NO;
    currentChatIsGroup = NO;
    currentChatIsOfficial = NO;
    currentChatID = nil;
    
    // 获取聊天联系人
    CBaseContact *contact = [self GetContact];
    if (!contact) {
        return;
    }
    
    // 获取聊天ID
    NSString *chatID = contact.m_nsUsrName;
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
    } else if ([chatID hasPrefix:@"wxid_"] || ![chatID containsString:@"@"]) {
        // 私聊 - 处理wxid_前缀和普通用户名（不包含@符号的）
        currentChatIsPrivate = YES;
    } else {
        // 其他类型的聊天（如企业号、小程序等）
        // 启用布局功能但不参与排序
        currentChatIsPrivate = YES; // 视为私聊，但使用默认排序，不会影响实际排序
        currentChatIsGroup = NO;
        currentChatIsOfficial = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    // 更新聊天联系人信息（防止中途切换联系人）
    CBaseContact *contact = [self GetContact];
    if (!contact) {
        return;
    }
    
    // 获取聊天ID
    NSString *chatID = contact.m_nsUsrName;
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
    } else if ([chatID hasPrefix:@"wxid_"] || ![chatID containsString:@"@"]) {
        // 私聊 - 处理wxid_前缀和普通用户名（不包含@符号的）
        currentChatIsPrivate = YES;
    } else {
        // 其他类型的聊天（如企业号、小程序等）
        // 启用布局功能但不参与排序
        currentChatIsPrivate = YES; // 视为私聊，但使用默认排序，不会影响实际排序
        currentChatIsGroup = NO;
        currentChatIsOfficial = NO;
    }
}

%end

%hook SelectAttachmentView

// 钩住layoutSubviews来观察整体布局和保存实际宽度
- (void)layoutSubviews {
    %orig;
    
    // 保存实际宽度
    viewWidth = self.bounds.size.width;
}

// 完全重写计算方法，使用我们存储的视图实际宽度
- (struct CGRect)calculateEmoticonViewFrameAtIndex:(unsigned int)arg1 forViewWidth:(double)arg2 {
    // 检查当前聊天环境是否应该启用布局功能
    if (!shouldEnableLayout()) {
        return %orig(arg1, arg2);
    }
    
    // 首先记录原始索引
    unsigned int originalIndex = arg1;
    unsigned int mappedIndex = originalIndex;
    
    // 检查按钮是否被隐藏
    BOOL isHidden = NO;
    int buttonTag = 0;
    
    // 如果是公众号聊天并且启用了自定义排序
    if (currentChatIsOfficial && isOfficialSortEnabled()) {
        // 获取原始Tag
        buttonTag = getOfficialButtonTagAtIndex(originalIndex);
        // 检查是否被隐藏
        isHidden = isOfficialButtonHidden(buttonTag);
        // 对按钮索引进行映射
        mappedIndex = mapButtonIndexByCustomSort(originalIndex);
    }
    // 如果是私聊并且启用了自定义排序
    else if (currentChatIsPrivate && isPrivateSortEnabled()) {
        // 获取原始Tag
        buttonTag = getPrivateButtonTagAtIndex(originalIndex);
        // 检查是否被隐藏
        isHidden = isPrivateButtonHidden(buttonTag);
        // 对按钮索引进行映射
        mappedIndex = mapPrivateButtonIndexByCustomSort(originalIndex);
    }
    // 如果是群聊并且启用了自定义排序
    else if (currentChatIsGroup && isGroupSortEnabled()) {
        // 获取原始Tag
        buttonTag = getGroupButtonTagAtIndex(originalIndex);
        // 检查是否被隐藏
        isHidden = isGroupButtonHidden(buttonTag);
        // 对按钮索引进行映射
        mappedIndex = mapGroupButtonIndexByCustomSort(originalIndex);
    }
    // 未知类型聊天不参与排序，直接使用原始索引
    
    // 调用原始方法，但不使用其返回值
    %orig;
    
    // 使用我们存储的真实视图宽度而不是arg2
    double screenWidth = viewWidth;
    
    // 如果按钮被隐藏，将其移到屏幕外非常远的位置
    if (isHidden) {
        // 创建一个在屏幕外非常远的frame（使用一个非常大的值，确保用户无法滑动到）
        return CGRectMake(screenWidth * 100, 0, 0, 0);
    }
    
    // 使用自定义的列数
    int columnsPerRow = getColumnsCount();
    int buttonsPerPage = columnsPerRow * 2;
    
    // 获取当前聊天类型中隐藏的按钮数组
    NSArray *hiddenButtons = @[];
    if (currentChatIsOfficial && isOfficialSortEnabled()) {
        hiddenButtons = getOfficialHiddenButtons();
    } else if (currentChatIsPrivate && isPrivateSortEnabled()) {
        hiddenButtons = getPrivateHiddenButtons();
    } else if (currentChatIsGroup && isGroupSortEnabled()) {
        hiddenButtons = getGroupHiddenButtons();
    }
    
    // 计算当前显示位置的偏移量 - 根据前面被隐藏的按钮数量
    int visibleButtonIndex = 0;
    NSArray *sortOrder = @[];
    
    if (currentChatIsOfficial && isOfficialSortEnabled()) {
        sortOrder = getOfficialSortOrder();
    } else if (currentChatIsPrivate && isPrivateSortEnabled()) {
        sortOrder = getPrivateSortOrder();
    } else if (currentChatIsGroup && isGroupSortEnabled()) {
        sortOrder = getGroupSortOrder();
    }
    
    // 计算在排序序列中该按钮前有多少个被隐藏的按钮
    for (int i = 0; i < mappedIndex && i < sortOrder.count; i++) {
        NSNumber *currentTag = sortOrder[i];
        if ([hiddenButtons containsObject:currentTag]) {
            // 前面有按钮被隐藏，需要减少实际显示的索引
            visibleButtonIndex--;
        }
        visibleButtonIndex++;
    }
    
    // 使用调整后的可见索引计算位置
    // 计算按钮应该在哪一页
    unsigned long long page = visibleButtonIndex / buttonsPerPage;
    
    // 计算在当前页中的索引（从0开始）
    unsigned long long indexInPage = visibleButtonIndex % buttonsPerPage;
    
    // 计算在当前页中的行和列
    unsigned long long row = indexInPage / columnsPerRow;
    unsigned long long col = indexInPage % columnsPerRow;
    
    // 获取按钮间距
    float spacing = getSpacing();
    
    // 计算按钮的宽度和高度
    double itemHeight = 96.0; // 保持原始高度
    
    // 计算每个按钮的宽度
    double buttonWidth = 65.0; // 微信默认按钮宽度
    
    // 计算整行按钮加间距的总宽度
    double totalRowWidth = (buttonWidth * columnsPerRow) + (spacing * (columnsPerRow - 1));
    
    // 计算起始X坐标以居中整行
    double startX = (screenWidth - totalRowWidth) / 2.0;
    
    // 计算当前按钮的X、Y坐标
    double x = startX + (col * (buttonWidth + spacing));
    double y = (row * itemHeight); // 每行的高度为itemHeight
    
    // 创建页面偏移的frame
    CGRect newFrame = CGRectMake(x + (page * screenWidth), y, buttonWidth, itemHeight);
    
    return newFrame;
}

%end

// 添加Notification监听，当设置改变时更新状态
%ctor {
    // 默认值初始化 - 如果键不存在，设置默认值
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 检查场景控制设置是否存在，如不存在则设置默认值(全部开启)
    if (![defaults objectForKey:kChatAttachmentShowInPrivateKey]) {
        [defaults setBool:YES forKey:kChatAttachmentShowInPrivateKey];
    }
    
    if (![defaults objectForKey:kChatAttachmentShowInGroupKey]) {
        [defaults setBool:YES forKey:kChatAttachmentShowInGroupKey];
    }
    
    if (![defaults objectForKey:kChatAttachmentShowInOfficialKey]) {
        [defaults setBool:YES forKey:kChatAttachmentShowInOfficialKey];
    }
    
    // 初始化公众号排序设置
    if (![defaults objectForKey:kChatAttachmentOfficialSortEnabledKey]) {
        [defaults setBool:YES forKey:kChatAttachmentOfficialSortEnabledKey];
    }
    
    // 初始化私聊排序设置
    if (![defaults objectForKey:kChatAttachmentPrivateSortEnabledKey]) {
        [defaults setBool:YES forKey:kChatAttachmentPrivateSortEnabledKey];
    }
    
    // 初始化群聊排序设置
    if (![defaults objectForKey:kChatAttachmentGroupSortEnabledKey]) {
        [defaults setBool:YES forKey:kChatAttachmentGroupSortEnabledKey];
    }
    
    // 同步设置
    [defaults synchronize];
    
    // 注册通知监听
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                     object:nil 
                                                      queue:[NSOperationQueue mainQueue] 
                                                 usingBlock:^(NSNotification *notification) {
        // 设置已更新
    }];
}