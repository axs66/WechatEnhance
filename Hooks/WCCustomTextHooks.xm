// 名称自定义
#import <UIKit/UIKit.h>

// 添加必要的类声明
@interface TimeoutNumber : UIView
- (void)updateNumber:(unsigned long long)arg1;
- (void)defaultNumber:(unsigned long long)arg1;
@end

@interface ScrollNumber : UIView
- (void)updateNumber:(unsigned long long)arg1;
- (void)defaultNumber:(unsigned long long)arg1;
@end

@interface WCPayWalletEntryHeaderView : UIView
- (void)setupTimeoutNumber;
- (void)updateBalanceEntryView;
- (void)handleUpdateWalletBalance;
- (void)updateBalanceAndRefreshView;
@end

@interface MMUILabel : UILabel
@end

// 定义NSUserDefaults的键
static NSString * const kWCSimpleUIEnabledKey = @"com.wechat.tweak.simple_ui_enabled";
static NSString * const kWCCustomMenuNamesKey = @"com.wechat.tweak.custom_menu_names";
static NSString * const kWCCustomTabNamesKey = @"com.wechat.tweak.custom_tab_names";
// 添加主标题自定义键
static NSString * const kWCMainTitleReplacementKey = @"com.wechat.tweak.main_title_replacement";
// 添加通讯录和发现自定义键
static NSString * const kWCContactsReplacementKey = @"com.wechat.tweak.contacts_replacement";
static NSString * const kWCDiscoverReplacementKey = @"com.wechat.tweak.discover_replacement";
// 添加好友数量自定义键
static NSString * const kWCFriendsCountReplacementKey = @"com.wechat.tweak.friends_count_replacement";
// 添加钱包余额自定义键
static NSString * const kWCWalletBalanceReplacementKey = @"com.wechat.tweak.wallet_balance_replacement";

// 定义替换"微信"标题的常量
static NSString * const kWCOriginalTitle = @"微信";
// 定义"通讯录"和"发现"的常量
static NSString * const kWCOriginalContacts = @"通讯录";
static NSString * const kWCOriginalDiscover = @"发现";

// 缓存设置状态的静态变量
static BOOL gSimpleUIEnabled = YES;
static NSDictionary *gCustomMenuNames = nil;
static NSDictionary *gCustomTabNames = nil;
static NSString *gMainTitleReplacement = nil;
// 通讯录和发现的自定义文本
static NSString *gContactsReplacement = nil;
static NSString *gDiscoverReplacement = nil;
// 好友数量自定义文本
static NSString *gFriendsCountReplacement = nil;
// 钱包余额自定义文本
static NSString *gWalletBalanceReplacement = nil;

// 菜单项原始名称常量 - 只保留新版名称和其他名称
static NSString * const kWCMenuWallet = @"卡包";       // 新版名称
static NSString * const kWCMenuWalletAndOrder = @"订单与卡包"; // 新增卡包的另一种称呼
static NSString * const kWCMenuService = @"服务";      // 新版名称
static NSString * const kWCMenuServiceAndPay = @"支付与服务"; // 服务的另一种称呼
static NSString * const kWCMenuFavorite = @"收藏";
static NSString * const kWCMenuMoments = @"朋友圈";
static NSString * const kWCMenuEmoticon = @"表情";
static NSString * const kWCMenuSetting = @"设置";
static NSString * const kWCMenuPlugin = @"插件";  // 添加插件菜单常量

// 底部标签名称常量
static NSString * const kWCTabChat = @"微信";
static NSString * const kWCTabContacts = @"通讯录";
static NSString * const kWCTabDiscover = @"发现";
static NSString * const kWCTabMe = @"我";

// 从NSUserDefaults读取设置
static void loadSettings() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 如果设置不存在，默认为开启
    gSimpleUIEnabled = [defaults objectForKey:kWCSimpleUIEnabledKey] ? [defaults boolForKey:kWCSimpleUIEnabledKey] : YES;
    
    // 读取自定义菜单名称
    gCustomMenuNames = [defaults objectForKey:kWCCustomMenuNamesKey];
    if (!gCustomMenuNames) {
        // 默认使用空字典，不进行任何替换
        gCustomMenuNames = @{};
    } else {
        // 确保卡包和订单与卡包的名称同步
        NSMutableDictionary *tempDict = [gCustomMenuNames mutableCopy];
        NSString *walletName = [gCustomMenuNames objectForKey:kWCMenuWallet];
        NSString *walletAndOrderName = [gCustomMenuNames objectForKey:kWCMenuWalletAndOrder];
        
        // 如果两者都有值但不一致，优先使用"卡包"的自定义名称
        if (walletName && walletAndOrderName && ![walletName isEqualToString:walletAndOrderName]) {
            [tempDict setObject:walletName forKey:kWCMenuWalletAndOrder];
        } 
        // 如果只有一个有值，则同步另一个
        else if (walletName && !walletAndOrderName) {
            [tempDict setObject:walletName forKey:kWCMenuWalletAndOrder];
        } 
        else if (!walletName && walletAndOrderName) {
            [tempDict setObject:walletAndOrderName forKey:kWCMenuWallet];
        }
        
        // 确保服务和支付与服务的名称同步
        NSString *serviceName = [gCustomMenuNames objectForKey:kWCMenuService];
        NSString *serviceAndPayName = [gCustomMenuNames objectForKey:kWCMenuServiceAndPay];
        
        // 如果两者都有值但不一致，优先使用"服务"的自定义名称
        if (serviceName && serviceAndPayName && ![serviceName isEqualToString:serviceAndPayName]) {
            [tempDict setObject:serviceName forKey:kWCMenuServiceAndPay];
        } 
        // 如果只有一个有值，则同步另一个
        else if (serviceName && !serviceAndPayName) {
            [tempDict setObject:serviceName forKey:kWCMenuServiceAndPay];
        } 
        else if (!serviceName && serviceAndPayName) {
            [tempDict setObject:serviceAndPayName forKey:kWCMenuService];
        }
        
        // 更新同步后的字典
        gCustomMenuNames = [tempDict copy];
    }
    
    // 读取自定义标签名称
    gCustomTabNames = [defaults objectForKey:kWCCustomTabNamesKey];
    if (!gCustomTabNames) {
        gCustomTabNames = @{};
    }
    
    // 读取主标题自定义文本
    gMainTitleReplacement = [defaults objectForKey:kWCMainTitleReplacementKey];
    
    // 读取通讯录和发现自定义文本
    gContactsReplacement = [defaults objectForKey:kWCContactsReplacementKey];
    gDiscoverReplacement = [defaults objectForKey:kWCDiscoverReplacementKey];
    
    // 读取好友数量自定义文本
    gFriendsCountReplacement = [defaults objectForKey:kWCFriendsCountReplacementKey];
    
    // 读取钱包余额自定义文本
    gWalletBalanceReplacement = [defaults objectForKey:kWCWalletBalanceReplacementKey];
}

// 定义WCTableViewCellLeftConfig类，用于配置左边的表格视图单元格
@interface WCTableViewCellLeftConfig : NSObject
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;
@end

%hook WCTableViewCellLeftConfig

// 重写title方法，用于修改标题
- (NSString *)title {
	NSString *r = %orig;
	
	// 如果简化UI功能未启用，则返回原始标题
	if (!gSimpleUIEnabled) {
		return r;
	}
	
	if (r == nil) {
		return nil;
	}
    
    // 查找自定义名称
    NSString *customName = [gCustomMenuNames objectForKey:r];
    if (customName) {
        return customName;
    }
	
	return r;
}

%end

// MMTabbarItem类定义
@interface MMTabbarItem : UITabBarItem
@property (retain, nonatomic) NSString *normalTitle;
@end

// 为MMTabbarItem增加钩子以自定义标签名称
%hook MMTabbarItem

- (id)initWithTitle:(NSString *)title normalImage:(id)normalImage selectedImage:(id)selectedImage {
    // 如果简化UI功能未启用或标题为空，则使用原始标题
    if (!gSimpleUIEnabled || !title) {
        return %orig;
    }
    
    // 查找自定义标签名称
    NSString *customName = [gCustomTabNames objectForKey:title];
    if (customName) {
        return %orig(customName, normalImage, selectedImage);
    }
    
    return %orig;
}

- (void)setNormalTitle:(NSString *)normalTitle {
    // 如果简化UI功能未启用或标题为空，则使用原始标题
    if (!gSimpleUIEnabled || !normalTitle) {
        %orig;
        return;
    }
    
    // 查找自定义标签名称
    NSString *customName = [gCustomTabNames objectForKey:normalTitle];
    if (customName) {
        %orig(customName);
    } else {
        %orig;
    }
}

%end

// MMTabBarItemView类定义
@interface MMTabBarItemView : UIView
@property (retain, nonatomic) UILabel *textLabel;
- (void)setTitle:(NSString *)title;
@end

// 为MMTabBarItemView增加钩子以自定义标签文本
%hook MMTabBarItemView

- (void)setTitle:(NSString *)title {
    // 如果简化UI功能未启用或标题为空，则使用原始标题
    if (!gSimpleUIEnabled || !title) {
        %orig;
        return;
    }
    
    // 查找自定义标签名称
    NSString *customName = [gCustomTabNames objectForKey:title];
    if (customName) {
        %orig(customName);
    } else {
        %orig;
    }
}

%end

// MMTabBarController类定义
@interface MMTabBarController : UITabBarController
- (void)setTabBarItemTitle:(NSString *)title forIndex:(unsigned long long)index;
@end

// 为MMTabBarController增加钩子以自定义标签标题
%hook MMTabBarController

- (void)setTabBarItemTitle:(NSString *)title forIndex:(unsigned long long)index {
    // 如果简化UI功能未启用或标题为空，则使用原始标题
    if (!gSimpleUIEnabled || !title) {
        %orig;
        return;
    }
    
    // 查找自定义标签名称
    NSString *customName = [gCustomTabNames objectForKey:title];
    if (customName) {
        %orig(customName, index);
    } else {
        %orig;
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

// 修改插件菜单名称
%hook MMTableViewInfo 

- (NSString *)getTitle:(long long)arg1 {
    NSString *originalTitle = %orig;
    
    // 检查是否启用了界面简化
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL simpleUIEnabled = [defaults objectForKey:kWCSimpleUIEnabledKey] ? 
                          [defaults boolForKey:kWCSimpleUIEnabledKey] : YES;
    
    if (!simpleUIEnabled) {
        return originalTitle;
    }
    
    // 获取自定义菜单名称
    NSDictionary *customNames = [defaults objectForKey:kWCCustomMenuNamesKey];
    
    // 处理插件菜单
    if ([originalTitle isEqualToString:kWCMenuPlugin]) {
        return customNames[kWCMenuPlugin] ?: originalTitle;
    }
    
    return originalTitle;
}

%end 

// 添加对MMUILabel的钩子，用于替换"微信"标题
%hook MMUILabel

- (void)setText:(NSString *)text {
    // 如果文本为空或者没有开启自定义功能，直接使用原始设置
    if (!text || !gSimpleUIEnabled) {
        %orig;
        return;
    }
    
    // 处理"微信(未连接)"特殊情况
    if ([text containsString:@"微信(未连接)"]) {
        %orig;
        return;
    }
    
    // 检查是否为"微信"或"微信(数字)"格式
    BOOL isWeChatTitle = [text isEqualToString:kWCOriginalTitle];
    if (!isWeChatTitle) {
        // 检查是否匹配"微信(数字)"格式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^微信\\(\\d+\\)$" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
        isWeChatTitle = (match != nil);
    }
    
    // 检查是否为"通讯录"或"通讯录(数字)"格式
    BOOL isContactsTitle = [text isEqualToString:kWCOriginalContacts];
    if (!isContactsTitle) {
        // 检查是否匹配"通讯录(数字)"格式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^通讯录\\(\\d+\\)$" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
        isContactsTitle = (match != nil);
    }
    
    // 检查是否在导航栏中（只对微信标题进行检查）
    BOOL isInNavBar = NO;
    if (isWeChatTitle) {
        // 检查是否在导航栏中
        UIView *superview = self.superview;
        while (superview && ![NSStringFromClass([superview class]) containsString:@"NavigationBar"]) {
            superview = superview.superview;
        }
        isInNavBar = (superview != nil);
        
        // 处理"微信"标题替换 - 保留导航栏检查条件
        if (isInNavBar && gMainTitleReplacement && [gMainTitleReplacement length] > 0) {
            // 完全替换为自定义文本，不保留数字
            %orig(gMainTitleReplacement);
            return;
        }
    }
    
    // 检查是否为"通讯录"或"通讯录(数字)"格式 - 移除导航栏检查条件
    if (isContactsTitle && gContactsReplacement && [gContactsReplacement length] > 0) {
        // 替换为自定义通讯录文本
        %orig(gContactsReplacement);
        return;
    }
    
    // 检查是否完全匹配"发现" - 移除导航栏检查条件
    if ([text isEqualToString:kWCOriginalDiscover] && gDiscoverReplacement && [gDiscoverReplacement length] > 0) {
        // 替换为自定义发现文本
        %orig(gDiscoverReplacement);
        return;
    }
    
    // 处理好友数量显示（如"697个朋友"）
    if (gFriendsCountReplacement && [gFriendsCountReplacement length] > 0) {
        // 使用正则表达式匹配"数字+个朋友"模式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+个朋友$" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
        
        if (match) {
            // 替换为自定义好友数量文本 + "个朋友"
            NSString *customText = [NSString stringWithFormat:@"%@个朋友", gFriendsCountReplacement];
            %orig(customText);
            return;
        }
    }
    
    %orig;
}

// 对attributedText也进行处理，防止通过该方法设置文本
- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (!attributedText || !gSimpleUIEnabled) {
        %orig;
        return;
    }
    
    NSString *originalString = [attributedText string];
    
    // 处理"微信(未连接)"特殊情况
    if ([originalString containsString:@"微信(未连接)"]) {
        %orig;
        return;
    }
    
    // 检查是否为"微信"或"微信(数字)"格式
    BOOL isWeChatTitle = [originalString isEqualToString:kWCOriginalTitle];
    if (!isWeChatTitle) {
        // 检查是否匹配"微信(数字)"格式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^微信\\(\\d+\\)$" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
        isWeChatTitle = (match != nil);
    }
    
    // 检查是否为"通讯录"或"通讯录(数字)"格式
    BOOL isContactsTitle = [originalString isEqualToString:kWCOriginalContacts];
    if (!isContactsTitle) {
        // 检查是否匹配"通讯录(数字)"格式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^通讯录\\(\\d+\\)$" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
        isContactsTitle = (match != nil);
    }
    
    // 检查是否在导航栏中（只对微信标题进行检查）
    BOOL isInNavBar = NO;
    if (isWeChatTitle) {
        // 检查是否在导航栏中
        UIView *superview = self.superview;
        while (superview && ![NSStringFromClass([superview class]) containsString:@"NavigationBar"]) {
            superview = superview.superview;
        }
        isInNavBar = (superview != nil);
        
        // 处理"微信"标题替换 - 保留导航栏检查条件
        if (isInNavBar && gMainTitleReplacement && [gMainTitleReplacement length] > 0) {
            // 创建新的属性字符串，使用完全替换的方式
            NSMutableAttributedString *newAttributedText = [[NSMutableAttributedString alloc] initWithString:gMainTitleReplacement attributes:[attributedText attributesAtIndex:0 effectiveRange:NULL]];
            %orig(newAttributedText);
            return;
        }
    }
    
    // 检查是否为"通讯录"或"通讯录(数字)"格式 - 移除导航栏检查条件
    if (isContactsTitle && gContactsReplacement && [gContactsReplacement length] > 0) {
        // 创建新的属性字符串，使用完全替换的方式
        NSMutableAttributedString *newAttributedText = [[NSMutableAttributedString alloc] initWithString:gContactsReplacement attributes:[attributedText attributesAtIndex:0 effectiveRange:NULL]];
        %orig(newAttributedText);
        return;
    }
    
    // 检查是否完全匹配"发现" - 移除导航栏检查条件
    if ([originalString isEqualToString:kWCOriginalDiscover] && gDiscoverReplacement && [gDiscoverReplacement length] > 0) {
        // 创建新的属性字符串，使用完全替换的方式
        NSMutableAttributedString *newAttributedText = [[NSMutableAttributedString alloc] initWithString:gDiscoverReplacement attributes:[attributedText attributesAtIndex:0 effectiveRange:NULL]];
        %orig(newAttributedText);
        return;
    }
    
    // 处理好友数量显示（如"697个朋友"）
    if (gFriendsCountReplacement && [gFriendsCountReplacement length] > 0) {
        // 使用正则表达式匹配"数字+个朋友"模式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d+个朋友$" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
        
        if (match) {
            // 创建新的属性字符串，使用自定义好友数量
            NSString *customText = [NSString stringWithFormat:@"%@个朋友", gFriendsCountReplacement];
            NSMutableAttributedString *newAttributedText = [[NSMutableAttributedString alloc] initWithString:customText attributes:[attributedText attributesAtIndex:0 effectiveRange:NULL]];
            %orig(newAttributedText);
            return;
        }
    }
    
    // 其他情况保持原样
    %orig;
}

%end

// 添加对MFTitleView的钩子，用于替换标题视图中的文本
%hook MFTitleView

- (void)updateTitleView:(unsigned int)arg1 title:(NSString *)title {
    // 如果标题为空或者没有开启自定义功能，直接使用原始设置
    if (!title || !gSimpleUIEnabled) {
        %orig;
        return;
    }
    
    // 处理"微信(未连接)"特殊情况
    if ([title containsString:@"微信(未连接)"]) {
        %orig;
        return;
    }
    
    // 检查是否为"微信"或"微信(数字)"格式
    BOOL isWeChatTitle = [title isEqualToString:kWCOriginalTitle];
    if (!isWeChatTitle) {
        // 检查是否匹配"微信(数字)"格式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^微信\\(\\d+\\)$" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:title options:0 range:NSMakeRange(0, title.length)];
        isWeChatTitle = (match != nil);
    }
    
    // 检查是否为"通讯录"或"通讯录(数字)"格式
    BOOL isContactsTitle = [title isEqualToString:kWCOriginalContacts];
    if (!isContactsTitle) {
        // 检查是否匹配"通讯录(数字)"格式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^通讯录\\(\\d+\\)$" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:title options:0 range:NSMakeRange(0, title.length)];
        isContactsTitle = (match != nil);
    }
    
    // 处理"微信"标题替换 - 保留导航栏检查（MFTitleView已经在导航栏中）
    if (isWeChatTitle && gMainTitleReplacement && [gMainTitleReplacement length] > 0) {
        // 完全替换为自定义文本，不保留数字
        %orig(arg1, gMainTitleReplacement);
        return;
    }
    
    // 检查是否为"通讯录"或"通讯录(数字)"格式 - 移除导航栏检查条件
    if (isContactsTitle && gContactsReplacement && [gContactsReplacement length] > 0) {
        // 替换为自定义通讯录文本
        %orig(arg1, gContactsReplacement);
        return;
    }
    
    // 检查是否完全匹配"发现" - 移除导航栏检查条件
    if ([title isEqualToString:kWCOriginalDiscover] && gDiscoverReplacement && [gDiscoverReplacement length] > 0) {
        // 替换为自定义发现文本
        %orig(arg1, gDiscoverReplacement);
        return;
    }
    
    // 其他情况保持原样
    %orig;
}

%end

// 添加对WCPayWalletEntryHeaderView的钩子，用于自定义钱包余额
%hook WCPayWalletEntryHeaderView

// 钩入handleUpdateWalletBalance方法，当钱包余额更新时触发
- (void)handleUpdateWalletBalance {
    // 调用原始方法
    %orig;
    
    // 如果自定义功能未启用或自定义余额文本为空，则不做修改
    if (!gSimpleUIEnabled || !gWalletBalanceReplacement || [gWalletBalanceReplacement length] == 0) {
        return;
    }
    
    // 获取TimeoutNumber实例
    TimeoutNumber *timeoutNumber = [self valueForKey:@"_timeoutNumber"];
    if (timeoutNumber) {
        // 将自定义文本转换为数字（如果可能）
        NSScanner *scanner = [NSScanner scannerWithString:gWalletBalanceReplacement];
        unsigned long long balanceValue = 0;
        
        // 尝试从自定义文本中解析数字
        if ([scanner scanUnsignedLongLong:&balanceValue]) {
            // 修复：将balanceValue乘以100，使9999显示为9999.00而不是99.99
            balanceValue = balanceValue * 100;
            // 如果成功解析为数字，则更新TimeoutNumber
            [timeoutNumber updateNumber:balanceValue];
        } else {
            // 如果不是数字，尝试将第一个字符作为ASCII码使用
            // 这是一个变通方法，让TimeoutNumber显示至少一个字符
            if (gWalletBalanceReplacement.length > 0) {
                unichar firstChar = [gWalletBalanceReplacement characterAtIndex:0];
                [timeoutNumber updateNumber:firstChar];
            }
        }
    }
}

// 钩入setupTimeoutNumber方法，初始化TimeoutNumber时触发
- (void)setupTimeoutNumber {
    // 调用原始方法
    %orig;
    
    // 如果自定义功能未启用或自定义余额文本为空，则不做修改
    if (!gSimpleUIEnabled || !gWalletBalanceReplacement || [gWalletBalanceReplacement length] == 0) {
        return;
    }
    
    // 获取TimeoutNumber实例
    TimeoutNumber *timeoutNumber = [self valueForKey:@"_timeoutNumber"];
    if (timeoutNumber) {
        // 将自定义文本转换为数字（如果可能）
        NSScanner *scanner = [NSScanner scannerWithString:gWalletBalanceReplacement];
        unsigned long long balanceValue = 0;
        
        // 尝试从自定义文本中解析数字
        if ([scanner scanUnsignedLongLong:&balanceValue]) {
            // 修复：将balanceValue乘以100，使9999显示为9999.00而不是99.99
            balanceValue = balanceValue * 100;
            // 如果成功解析为数字，则更新TimeoutNumber
            [timeoutNumber updateNumber:balanceValue];
        } else {
            // 如果不是数字，尝试将第一个字符作为ASCII码使用
            if (gWalletBalanceReplacement.length > 0) {
                unichar firstChar = [gWalletBalanceReplacement characterAtIndex:0];
                [timeoutNumber updateNumber:firstChar];
            }
        }
    }
}

// 钩入updateBalanceEntryView方法，当余额入口视图更新时触发
- (void)updateBalanceEntryView {
    // 调用原始方法
    %orig;
    
    // 如果自定义功能未启用或自定义余额文本为空，则不做修改
    if (!gSimpleUIEnabled || !gWalletBalanceReplacement || [gWalletBalanceReplacement length] == 0) {
        return;
    }
    
    // 获取TimeoutNumber实例
    TimeoutNumber *timeoutNumber = [self valueForKey:@"_timeoutNumber"];
    if (timeoutNumber) {
        // 将自定义文本转换为数字（如果可能）
        NSScanner *scanner = [NSScanner scannerWithString:gWalletBalanceReplacement];
        unsigned long long balanceValue = 0;
        
        // 尝试从自定义文本中解析数字
        if ([scanner scanUnsignedLongLong:&balanceValue]) {
            // 修复：将balanceValue乘以100，使9999显示为9999.00而不是99.99
            balanceValue = balanceValue * 100;
            // 如果成功解析为数字，则更新TimeoutNumber
            [timeoutNumber updateNumber:balanceValue];
        } else {
            // 如果不是数字，尝试将第一个字符作为ASCII码使用
            if (gWalletBalanceReplacement.length > 0) {
                unichar firstChar = [gWalletBalanceReplacement characterAtIndex:0];
                [timeoutNumber updateNumber:firstChar];
            }
        }
    }
    
    // 尝试获取并修改balanceMoneyLabel（可能显示货币符号或单位）
    MMUILabel *balanceMoneyLabel = [self valueForKey:@"_balanceMoneyLabel"];
    if (balanceMoneyLabel) {
        // 保留原始文本的格式和符号，但将数字部分替换为自定义文本
        NSString *originalText = balanceMoneyLabel.text;
        if (originalText && [originalText length] > 0) {
            // 使用正则表达式替换数字部分
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+(\\.\\d+)?" options:0 error:nil];
            NSString *newText = [regex stringByReplacingMatchesInString:originalText options:0 range:NSMakeRange(0, originalText.length) withTemplate:gWalletBalanceReplacement];
            balanceMoneyLabel.text = newText;
        }
    }
}

// 钩入updateBalanceAndRefreshView方法，当余额刷新时触发
- (void)updateBalanceAndRefreshView {
    // 调用原始方法
    %orig;
    
    // 如果自定义功能未启用或自定义余额文本为空，则不做修改
    if (!gSimpleUIEnabled || !gWalletBalanceReplacement || [gWalletBalanceReplacement length] == 0) {
        return;
    }
    
    // 执行与updateBalanceEntryView相同的操作
    // 获取TimeoutNumber实例
    TimeoutNumber *timeoutNumber = [self valueForKey:@"_timeoutNumber"];
    if (timeoutNumber) {
        // 将自定义文本转换为数字（如果可能）
        NSScanner *scanner = [NSScanner scannerWithString:gWalletBalanceReplacement];
        unsigned long long balanceValue = 0;
        
        // 尝试从自定义文本中解析数字
        if ([scanner scanUnsignedLongLong:&balanceValue]) {
            // 修复：将balanceValue乘以100，使9999显示为9999.00而不是99.99
            balanceValue = balanceValue * 100;
            // 如果成功解析为数字，则更新TimeoutNumber
            [timeoutNumber updateNumber:balanceValue];
        } else {
            // 如果不是数字，尝试将第一个字符作为ASCII码使用
            if (gWalletBalanceReplacement.length > 0) {
                unichar firstChar = [gWalletBalanceReplacement characterAtIndex:0];
                [timeoutNumber updateNumber:firstChar];
            }
        }
    }
    
    // 尝试获取并修改balanceMoneyLabel（可能显示货币符号或单位）
    MMUILabel *balanceMoneyLabel = [self valueForKey:@"_balanceMoneyLabel"];
    if (balanceMoneyLabel) {
        // 保留原始文本的格式和符号，但将数字部分替换为自定义文本
        NSString *originalText = balanceMoneyLabel.text;
        if (originalText && [originalText length] > 0) {
            // 使用正则表达式替换数字部分
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+(\\.\\d+)?" options:0 error:nil];
            NSString *newText = [regex stringByReplacingMatchesInString:originalText options:0 range:NSMakeRange(0, originalText.length) withTemplate:gWalletBalanceReplacement];
            balanceMoneyLabel.text = newText;
        }
    }
}

%end

// 添加对TimeoutNumber的钩子
%hook TimeoutNumber

// 钩入updateNumber方法，直接拦截数字更新
- (void)updateNumber:(unsigned long long)arg1 {
    // 如果自定义功能未启用或自定义余额文本为空，则使用原始方法
    if (!gSimpleUIEnabled || !gWalletBalanceReplacement || [gWalletBalanceReplacement length] == 0) {
        %orig;
        return;
    }
    
    // 检查这个TimeoutNumber实例是否用于钱包余额
    // 这里我们通过判断父视图是否为WCPayWalletEntryHeaderView来确定
    UIView *parentView = self.superview;
    while (parentView && ![parentView isKindOfClass:%c(WCPayWalletEntryHeaderView)]) {
        parentView = parentView.superview;
    }
    
    // 如果父视图链中没有WCPayWalletEntryHeaderView，则使用原始方法
    if (!parentView) {
        %orig;
        return;
    }
    
    // 将自定义文本转换为数字（如果可能）
    NSScanner *scanner = [NSScanner scannerWithString:gWalletBalanceReplacement];
    unsigned long long balanceValue = 0;
    
    // 尝试从自定义文本中解析数字
    if ([scanner scanUnsignedLongLong:&balanceValue]) {
        // 修复：将balanceValue乘以100，使9999显示为9999.00而不是99.99
        balanceValue = balanceValue * 100;
        // 如果成功解析为数字，则使用自定义数字
        %orig(balanceValue);
    } else {
        // 如果不是数字，尝试将第一个字符作为ASCII码使用
        if (gWalletBalanceReplacement.length > 0) {
            unichar firstChar = [gWalletBalanceReplacement characterAtIndex:0];
            %orig(firstChar);
        } else {
            // 如果自定义文本为空，则使用原始数字
            %orig;
        }
    }
}

// 钩入defaultNumber方法，直接拦截默认数字设置
- (void)defaultNumber:(unsigned long long)arg1 {
    // 如果自定义功能未启用或自定义余额文本为空，则使用原始方法
    if (!gSimpleUIEnabled || !gWalletBalanceReplacement || [gWalletBalanceReplacement length] == 0) {
        %orig;
        return;
    }
    
    // 检查这个TimeoutNumber实例是否用于钱包余额
    // 这里我们通过判断父视图是否为WCPayWalletEntryHeaderView来确定
    UIView *parentView = self.superview;
    while (parentView && ![parentView isKindOfClass:%c(WCPayWalletEntryHeaderView)]) {
        parentView = parentView.superview;
    }
    
    // 如果父视图链中没有WCPayWalletEntryHeaderView，则使用原始方法
    if (!parentView) {
        %orig;
        return;
    }
    
    // 将自定义文本转换为数字（如果可能）
    NSScanner *scanner = [NSScanner scannerWithString:gWalletBalanceReplacement];
    unsigned long long balanceValue = 0;
    
    // 尝试从自定义文本中解析数字
    if ([scanner scanUnsignedLongLong:&balanceValue]) {
        // 修复：将balanceValue乘以100，使9999显示为9999.00而不是99.99
        balanceValue = balanceValue * 100;
        // 如果成功解析为数字，则使用自定义数字
        %orig(balanceValue);
    } else {
        // 如果不是数字，尝试将第一个字符作为ASCII码使用
        if (gWalletBalanceReplacement.length > 0) {
            unichar firstChar = [gWalletBalanceReplacement characterAtIndex:0];
            %orig(firstChar);
        } else {
            // 如果自定义文本为空，则使用原始数字
            %orig;
        }
    }
}

%end 