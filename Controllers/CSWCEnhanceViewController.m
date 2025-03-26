#import "CSWCEnhanceViewController.h"
#import "CSSettingTableViewCell.h"

// 定义NSUserDefaults的键（与WCEnhance.xm中保持一致）
static NSString * const kWCSimpleUIEnabledKey = @"com.wechat.tweak.simple_ui_enabled";
static NSString * const kWCCustomMenuNamesKey = @"com.wechat.tweak.custom_menu_names";
static NSString * const kWCCustomTabNamesKey = @"com.wechat.tweak.custom_tab_names";
static NSString * const kWCMainTitleReplacementKey = @"com.wechat.tweak.main_title_replacement";
// 添加通讯录和发现自定义键
static NSString * const kWCContactsReplacementKey = @"com.wechat.tweak.contacts_replacement";
static NSString * const kWCDiscoverReplacementKey = @"com.wechat.tweak.discover_replacement";
// 添加好友数量自定义键
static NSString * const kWCFriendsCountReplacementKey = @"com.wechat.tweak.friends_count_replacement";
// 添加钱包余额自定义键
static NSString * const kWCWalletBalanceReplacementKey = @"com.wechat.tweak.wallet_balance_replacement";
// 定义通知名称
static NSString * const kWCSettingsChangedNotification = @"com.wechat.tweak.settings_changed";

// 菜单项原始名称常量 - 只保留新版名称和其他名称
static NSString * const kWCMenuWallet = @"卡包";
static NSString * const kWCMenuWalletAndOrder = @"订单与卡包"; // 新增卡包的另一种称呼
static NSString * const kWCMenuService = @"服务";
static NSString * const kWCMenuServiceAndPay = @"支付与服务"; // 新增服务的另一种称呼
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

@interface CSWCEnhanceViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) NSMutableDictionary *customMenuNames;
@property (nonatomic, strong) NSMutableDictionary *customTabNames;
@property (nonatomic, strong) CSSettingSection *functionSection; // 功能设置部分
@property (nonatomic, strong) CSSettingSection *topTitleSection; // 顶部标签自定义部分（包括微信、通讯录、发现）
@property (nonatomic, strong) CSSettingSection *menuNameSection; // 菜单名称自定义部分
@property (nonatomic, strong) CSSettingSection *tabNameSection; // 底部标签名称自定义部分
@property (nonatomic, strong) CSSettingSection *specialSection; // 特殊自定义部分
@property (nonatomic, strong) CSSettingSection *descriptionSection; // 说明部分
@property (nonatomic, assign) BOOL simpleUIEnabled; // 界面名称简化开关状态
@property (nonatomic, strong) NSString *mainTitleReplacement; // 主标题替换文本
@property (nonatomic, strong) NSString *contactsReplacement; // 通讯录替换文本
@property (nonatomic, strong) NSString *discoverReplacement; // 发现替换文本
@property (nonatomic, strong) NSString *friendsCountReplacement; // 好友数量替换文本
@property (nonatomic, strong) NSString *walletBalanceReplacement; // 钱包余额替换文本
@end

@implementation CSWCEnhanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"界面简化";
    
    // 设置UI样式
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 初始化自定义菜单名称
    [self loadCustomMenuNames];
    
    // 初始化自定义底部标签名称
    [self loadCustomTabNames];
    
    // 初始化主标题替换文本
    [self loadMainTitleReplacement];
    
    // 初始化通讯录和发现替换文本
    [self loadContactsReplacement];
    [self loadDiscoverReplacement];
    
    // 初始化好友数量替换文本
    [self loadFriendsCountReplacement];
    
    // 初始化钱包余额替换文本
    [self loadWalletBalanceReplacement];
    
    // 设置数据
    [self setupData];
}

- (void)loadCustomMenuNames {
    // 从NSUserDefaults读取自定义菜单名称
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *savedNames = [defaults objectForKey:kWCCustomMenuNamesKey];
    
    if (savedNames) {
        self.customMenuNames = [savedNames mutableCopy];
    } else {
        // 使用空字典，不进行任何默认替换
        self.customMenuNames = [NSMutableDictionary dictionary];
    }
}

- (void)loadCustomTabNames {
    // 从NSUserDefaults读取自定义底部标签名称
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *savedNames = [defaults objectForKey:kWCCustomTabNamesKey];
    
    if (savedNames) {
        self.customTabNames = [savedNames mutableCopy];
    } else {
        // 使用空字典，不进行任何默认替换
        self.customTabNames = [NSMutableDictionary dictionary];
    }
}

- (void)loadMainTitleReplacement {
    // 从NSUserDefaults读取主标题替换文本
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedTitle = [defaults objectForKey:kWCMainTitleReplacementKey];
    
    if (savedTitle) {
        self.mainTitleReplacement = savedTitle;
    } else {
        // 默认值设为空
        self.mainTitleReplacement = @"";
    }
}

- (void)loadContactsReplacement {
    // 从NSUserDefaults读取通讯录替换文本
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedTitle = [defaults objectForKey:kWCContactsReplacementKey];
    
    if (savedTitle) {
        self.contactsReplacement = savedTitle;
    } else {
        // 默认值设为空
        self.contactsReplacement = @"";
    }
}

- (void)loadDiscoverReplacement {
    // 从NSUserDefaults读取发现替换文本
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedTitle = [defaults objectForKey:kWCDiscoverReplacementKey];
    
    if (savedTitle) {
        self.discoverReplacement = savedTitle;
    } else {
        // 默认值设为空
        self.discoverReplacement = @"";
    }
}

- (void)loadFriendsCountReplacement {
    // 从NSUserDefaults读取好友数量替换文本
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedCount = [defaults objectForKey:kWCFriendsCountReplacementKey];
    
    if (savedCount) {
        self.friendsCountReplacement = savedCount;
    } else {
        // 默认值设为空
        self.friendsCountReplacement = @"";
    }
}

- (void)loadWalletBalanceReplacement {
    // 从NSUserDefaults读取钱包余额替换文本
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedBalance = [defaults objectForKey:kWCWalletBalanceReplacementKey];
    
    if (savedBalance) {
        self.walletBalanceReplacement = savedBalance;
    } else {
        // 默认值设为空
        self.walletBalanceReplacement = @"";
    }
}

- (void)saveCustomMenuNames {
    // 保存自定义菜单名称到NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDictionary dictionaryWithDictionary:self.customMenuNames] forKey:kWCCustomMenuNamesKey];
    [defaults synchronize];
    
    // 发送通知，通知WCEnhance.xm重新加载设置
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kWCSettingsChangedNotification,
        NULL,
        NULL,
        true
    );
}

- (void)saveCustomTabNames {
    // 保存自定义底部标签名称到NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDictionary dictionaryWithDictionary:self.customTabNames] forKey:kWCCustomTabNamesKey];
    [defaults synchronize];
    
    // 发送通知，通知WCEnhance.xm重新加载设置
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kWCSettingsChangedNotification,
        NULL,
        NULL,
        true
    );
}

- (void)saveMainTitleReplacement {
    // 保存主标题替换文本到NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.mainTitleReplacement forKey:kWCMainTitleReplacementKey];
    [defaults synchronize];
    
    // 发送通知，通知WCEnhance.xm重新加载设置
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kWCSettingsChangedNotification,
        NULL,
        NULL,
        true
    );
}

- (void)saveContactsReplacement {
    // 保存通讯录替换文本到NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.contactsReplacement forKey:kWCContactsReplacementKey];
    [defaults synchronize];
    
    // 发送通知，通知WCEnhance.xm重新加载设置
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kWCSettingsChangedNotification,
        NULL,
        NULL,
        true
    );
}

- (void)saveDiscoverReplacement {
    // 保存发现替换文本到NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.discoverReplacement forKey:kWCDiscoverReplacementKey];
    [defaults synchronize];
    
    // 发送通知，通知WCEnhance.xm重新加载设置
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kWCSettingsChangedNotification,
        NULL,
        NULL,
        true
    );
}

- (void)saveFriendsCountReplacement {
    // 保存好友数量替换文本到NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.friendsCountReplacement forKey:kWCFriendsCountReplacementKey];
    [defaults synchronize];
    
    // 发送通知，通知WCEnhance.xm重新加载设置
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kWCSettingsChangedNotification,
        NULL,
        NULL,
        true
    );
}

- (void)saveWalletBalanceReplacement {
    // 保存钱包余额替换文本到NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.walletBalanceReplacement forKey:kWCWalletBalanceReplacementKey];
    [defaults synchronize];
    
    // 发送通知，通知WCEnhance.xm重新加载设置
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kWCSettingsChangedNotification,
        NULL,
        NULL,
        true
    );
}

- (void)setupData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 获取当前设置，如果不存在则默认为开启
    self.simpleUIEnabled = [defaults objectForKey:kWCSimpleUIEnabledKey] ? [defaults boolForKey:kWCSimpleUIEnabledKey] : NO;
    
    // 创建界面简化项（使用开关项工厂方法）
    CSSettingItem *simpleUIItem = [CSSettingItem switchItemWithTitle:@"界面名称简化" 
                                                          iconName:@"text.alignleft" 
                                                         iconColor:[UIColor systemBlueColor]
                                                       switchValue:self.simpleUIEnabled
                                                  valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kWCSimpleUIEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 更新状态变量
        self.simpleUIEnabled = isOn;
        
        // 更新sections数组，根据开关状态显示或隐藏菜单自定义部分
        [self updateSections];
        
        // 刷新表格视图
        [self.tableView reloadData];
        
        // 发送通知，通知WCEnhance.xm重新加载设置
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge CFStringRef)kWCSettingsChangedNotification,
            NULL,
            NULL,
            true
        );
    }];
    
    // 创建顶部标签自定义项
    NSMutableArray *topTitleItems = [NSMutableArray array];
    
    // 创建微信标题自定义项
    CSSettingItem *mainTitleItem = [CSSettingItem inputItemWithTitle:@"微信标题" 
                                                           iconName:@"message" 
                                                          iconColor:[UIColor systemGreenColor]
                                                         inputValue:self.mainTitleReplacement
                                                     inputPlaceholder:@"替换「微信」的文本"
                                                    valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.mainTitleReplacement = value;
        } else {
            // 如果清空，直接将替换文本置空
            self.mainTitleReplacement = @"";
        }
        [self saveMainTitleReplacement];
        
        // 弹出重启确认对话框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置已保存"
                                                                                 message:@"需要重启微信才能生效，是否立即重启？"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启"
                                                                   style:UIAlertActionStyleDestructive
                                                                 handler:^(UIAlertAction * _Nonnull action) {
            // 退出应用，强制重启
            exit(0);
        }];
        
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
        
        [alertController addAction:restartAction];
        [alertController addAction:laterAction];
        
        // 显示对话框
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    [topTitleItems addObject:mainTitleItem];
    
    // 创建通讯录自定义项
    CSSettingItem *contactsItem = [CSSettingItem inputItemWithTitle:@"通讯录标题" 
                                                           iconName:@"person.2" 
                                                          iconColor:[UIColor systemBlueColor]
                                                         inputValue:self.contactsReplacement
                                                     inputPlaceholder:@"替换「通讯录」的文本"
                                                    valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.contactsReplacement = value;
        } else {
            // 如果清空，直接将替换文本置空
            self.contactsReplacement = @"";
        }
        [self saveContactsReplacement];
        
        // 弹出重启确认对话框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置已保存"
                                                                                 message:@"需要重启微信才能生效，是否立即重启？"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
            // 退出应用，强制重启
            exit(0);
        }];
        
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
        
        [alertController addAction:restartAction];
        [alertController addAction:laterAction];
        
        // 显示对话框
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    [topTitleItems addObject:contactsItem];
    
    // 创建发现自定义项
    CSSettingItem *discoverItem = [CSSettingItem inputItemWithTitle:@"发现标题" 
                                                           iconName:@"safari" 
                                                          iconColor:[UIColor systemOrangeColor]
                                                         inputValue:self.discoverReplacement
                                                     inputPlaceholder:@"替换「发现」的文本"
                                                    valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.discoverReplacement = value;
        } else {
            // 如果清空，直接将替换文本置空
            self.discoverReplacement = @"";
        }
        [self saveDiscoverReplacement];
        
        // 弹出重启确认对话框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置已保存"
                                                                                 message:@"需要重启微信才能生效，是否立即重启？"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
            // 退出应用，强制重启
            exit(0);
        }];
        
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
        
        [alertController addAction:restartAction];
        [alertController addAction:laterAction];
        
        // 显示对话框
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    [topTitleItems addObject:discoverItem];
    
    // 创建特殊自定义项数组
    NSMutableArray *specialItems = [NSMutableArray array];
    
    // 创建好友数量自定义项并添加到特殊自定义项数组
    CSSettingItem *friendsCountItem = [CSSettingItem inputItemWithTitle:@"通讯录底部好友" 
                                                           iconName:@"person.3" 
                                                          iconColor:[UIColor systemIndigoColor]
                                                         inputValue:self.friendsCountReplacement
                                                     inputPlaceholder:@"替换通讯录底部好友数量"
                                                    valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.friendsCountReplacement = value;
        } else {
            // 如果清空，直接将替换文本置空
            self.friendsCountReplacement = @"";
        }
        [self saveFriendsCountReplacement];
        
        // 弹出重启确认对话框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置已保存"
                                                                                 message:@"需要重启微信才能生效，是否立即重启？"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
            // 退出应用，强制重启
            exit(0);
        }];
        
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
        
        [alertController addAction:restartAction];
        [alertController addAction:laterAction];
        
        // 显示对话框
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    [specialItems addObject:friendsCountItem];
    
    // 创建钱包余额自定义项并添加到特殊自定义项数组
    CSSettingItem *walletBalanceItem = [CSSettingItem inputItemWithTitle:@"服务页钱包余额" 
                                                          iconName:@"creditcard.fill" 
                                                         iconColor:[UIColor systemGreenColor]
                                                        inputValue:self.walletBalanceReplacement
                                                    inputPlaceholder:@"替换钱包页面显示余额"
                                                   valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.walletBalanceReplacement = value;
        } else {
            // 如果清空，直接将替换文本置空
            self.walletBalanceReplacement = @"";
        }
        [self saveWalletBalanceReplacement];
        
        // 弹出重启确认对话框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置已保存"
                                                                                 message:@"需要重启微信才能生效，是否立即重启？"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
            // 退出应用，强制重启
            exit(0);
        }];
        
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
        
        [alertController addAction:restartAction];
        [alertController addAction:laterAction];
        
        // 显示对话框
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    [specialItems addObject:walletBalanceItem];
    
    // 创建自定义菜单名称项
    NSMutableArray *menuNameItems = [NSMutableArray array];
    
    // 创建服务名称自定义项
    CSSettingItem *serviceItem = [CSSettingItem inputItemWithTitle:@"服务/支付与服务"
                                                        iconName:@"server.rack" 
                                                       iconColor:[UIColor systemGreenColor]
                                                      inputValue:[self.customMenuNames objectForKey:kWCMenuService]
                                                  inputPlaceholder:@"自定义名称"
                                                 valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            // 同时设置"服务"和"支付与服务"的自定义名称
            self.customMenuNames[kWCMenuService] = value;
            self.customMenuNames[kWCMenuServiceAndPay] = value; // 同步更新两种称呼
        } else {
            // 如果清空，同时移除两种称呼的自定义名称
            [self.customMenuNames removeObjectForKey:kWCMenuService];
            [self.customMenuNames removeObjectForKey:kWCMenuServiceAndPay];
        }
        [self saveCustomMenuNames];
    }];
    [menuNameItems addObject:serviceItem];
    
    // 创建收藏名称自定义项
    CSSettingItem *favoriteItem = [CSSettingItem inputItemWithTitle:@"收藏" 
                                                         iconName:@"star.fill" 
                                                        iconColor:[UIColor systemYellowColor]
                                                       inputValue:[self.customMenuNames objectForKey:kWCMenuFavorite]
                                                   inputPlaceholder:@"自定义名称"
                                                  valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customMenuNames[kWCMenuFavorite] = value;
        } else {
            [self.customMenuNames removeObjectForKey:kWCMenuFavorite];
        }
        [self saveCustomMenuNames];
    }];
    [menuNameItems addObject:favoriteItem];
    
    // 创建朋友圈名称自定义项
    CSSettingItem *momentsItem = [CSSettingItem inputItemWithTitle:@"朋友圈" 
                                                        iconName:@"photo.on.rectangle" 
                                                       iconColor:[UIColor systemBlueColor]
                                                      inputValue:[self.customMenuNames objectForKey:kWCMenuMoments]
                                                  inputPlaceholder:@"自定义名称"
                                                 valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customMenuNames[kWCMenuMoments] = value;
        } else {
            [self.customMenuNames removeObjectForKey:kWCMenuMoments];
        }
        [self saveCustomMenuNames];
    }];
    [menuNameItems addObject:momentsItem];
    
    // 创建卡包名称自定义项
    CSSettingItem *walletItem = [CSSettingItem inputItemWithTitle:@"卡包/订单与卡包"
                                                       iconName:@"creditcard.fill" 
                                                      iconColor:[UIColor systemOrangeColor]
                                                     inputValue:[self.customMenuNames objectForKey:kWCMenuWallet]
                                                 inputPlaceholder:@"自定义名称"
                                                valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            // 同时设置"卡包"和"订单与卡包"的自定义名称
            self.customMenuNames[kWCMenuWallet] = value;
            self.customMenuNames[kWCMenuWalletAndOrder] = value; // 同步更新两种称呼
        } else {
            // 如果清空，同时移除两种称呼的自定义名称
            [self.customMenuNames removeObjectForKey:kWCMenuWallet];
            [self.customMenuNames removeObjectForKey:kWCMenuWalletAndOrder];
        }
        [self saveCustomMenuNames];
    }];
    [menuNameItems addObject:walletItem];

    // 创建表情名称自定义项
    CSSettingItem *emoticonItem = [CSSettingItem inputItemWithTitle:@"表情" 
                                                         iconName:@"face.smiling" 
                                                        iconColor:[UIColor systemYellowColor]
                                                       inputValue:[self.customMenuNames objectForKey:kWCMenuEmoticon]
                                                   inputPlaceholder:@"自定义名称"
                                                  valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customMenuNames[kWCMenuEmoticon] = value;
        } else {
            [self.customMenuNames removeObjectForKey:kWCMenuEmoticon];
        }
        [self saveCustomMenuNames];
    }];
    [menuNameItems addObject:emoticonItem];
    
    // 创建设置名称自定义项
    CSSettingItem *settingItem = [CSSettingItem inputItemWithTitle:@"设置" 
                                                        iconName:@"gear" 
                                                       iconColor:[UIColor systemGrayColor]
                                                      inputValue:[self.customMenuNames objectForKey:kWCMenuSetting]
                                                  inputPlaceholder:@"自定义名称"
                                                 valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customMenuNames[kWCMenuSetting] = value;
        } else {
            [self.customMenuNames removeObjectForKey:kWCMenuSetting];
        }
        [self saveCustomMenuNames];
    }];
    [menuNameItems addObject:settingItem];
    
    // 创建插件菜单项
    CSSettingItem *pluginItem = [CSSettingItem inputItemWithTitle:@"插件" 
                                                        iconName:@"puzzlepiece.fill" 
                                                       iconColor:[UIColor systemPurpleColor]
                                                      inputValue:[self.customMenuNames objectForKey:kWCMenuPlugin]
                                                  inputPlaceholder:@"自定义名称"
                                                 valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customMenuNames[kWCMenuPlugin] = value;
        } else {
            [self.customMenuNames removeObjectForKey:kWCMenuPlugin];
        }
        [self saveCustomMenuNames];
    }];
    [menuNameItems addObject:pluginItem];
    
    // 创建底部标签自定义项
    NSMutableArray *tabNameItems = [NSMutableArray array];
    
    // 创建微信标签自定义项
    CSSettingItem *chatTabItem = [CSSettingItem inputItemWithTitle:kWCTabChat
                                                        iconName:@"message" 
                                                       iconColor:[UIColor systemGreenColor]
                                                      inputValue:[self.customTabNames objectForKey:kWCTabChat]
                                                  inputPlaceholder:@"自定义标签名称"
                                                 valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customTabNames[kWCTabChat] = value;
        } else {
            [self.customTabNames removeObjectForKey:kWCTabChat];
        }
        [self saveCustomTabNames];
    }];
    [tabNameItems addObject:chatTabItem];
    
    // 创建通讯录标签自定义项
    CSSettingItem *contactsTabItem = [CSSettingItem inputItemWithTitle:kWCTabContacts
                                                            iconName:@"person.2" 
                                                           iconColor:[UIColor systemBlueColor]
                                                          inputValue:[self.customTabNames objectForKey:kWCTabContacts]
                                                      inputPlaceholder:@"自定义标签名称"
                                                     valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customTabNames[kWCTabContacts] = value;
        } else {
            [self.customTabNames removeObjectForKey:kWCTabContacts];
        }
        [self saveCustomTabNames];
    }];
    [tabNameItems addObject:contactsTabItem];
    
    // 创建发现标签自定义项
    CSSettingItem *discoverTabItem = [CSSettingItem inputItemWithTitle:kWCTabDiscover
                                                             iconName:@"safari" 
                                                            iconColor:[UIColor systemRedColor]
                                                           inputValue:[self.customTabNames objectForKey:kWCTabDiscover]
                                                       inputPlaceholder:@"自定义标签名称"
                                                      valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customTabNames[kWCTabDiscover] = value;
        } else {
            [self.customTabNames removeObjectForKey:kWCTabDiscover];
        }
        [self saveCustomTabNames];
    }];
    [tabNameItems addObject:discoverTabItem];
    
    // 创建我标签自定义项
    CSSettingItem *meTabItem = [CSSettingItem inputItemWithTitle:kWCTabMe
                                                      iconName:@"person" 
                                                     iconColor:[UIColor systemBlueColor]
                                                    inputValue:[self.customTabNames objectForKey:kWCTabMe]
                                                inputPlaceholder:@"自定义标签名称"
                                               valueChangedBlock:^(NSString *value) {
        if (value.length > 0) {
            self.customTabNames[kWCTabMe] = value;
        } else {
            [self.customTabNames removeObjectForKey:kWCTabMe];
        }
        [self saveCustomTabNames];
    }];
    [tabNameItems addObject:meTabItem];
    
    // 创建说明项（使用普通项）
    CSSettingItem *descriptionItem = [CSSettingItem itemWithTitle:@"功能说明" 
                                                       iconName:@"info.circle" 
                                                      iconColor:[UIColor systemGrayColor]
                                                        detail:@"重启微信后功能完全生效"];
    
    // 创建功能设置部分
    self.functionSection = [CSSettingSection sectionWithHeader:@"功能设置" 
                                                     items:@[simpleUIItem]];
    
    // 创建顶部标签自定义部分
    self.topTitleSection = [CSSettingSection sectionWithHeader:@"顶部标签自定义" 
                                                      items:topTitleItems];
    
    // 创建特殊自定义部分
    self.specialSection = [CSSettingSection sectionWithHeader:@"特殊自定义" 
                                                    items:specialItems];
    
    // 创建菜单名称自定义部分
    self.menuNameSection = [CSSettingSection sectionWithHeader:@"我的页面菜单名称自定义" 
                                                   items:menuNameItems];
    
    // 创建底部标签名称自定义部分
    self.tabNameSection = [CSSettingSection sectionWithHeader:@"底部标签自定义" 
                                                  items:tabNameItems];
    
    // 创建说明部分
    self.descriptionSection = [CSSettingSection sectionWithHeader:@"说明" 
                                                        items:@[descriptionItem]];
    
    // 更新sections数组
    [self updateSections];
}

// 根据界面名称简化开关状态更新sections数组
- (void)updateSections {
    if (self.simpleUIEnabled) {
        // 开关开启，显示所有自定义部分，包括新的特殊自定义部分
        self.sections = @[self.functionSection, self.topTitleSection, self.specialSection, self.menuNameSection, self.tabNameSection, self.descriptionSection];
    } else {
        // 开关关闭，只显示功能设置和说明部分
        self.sections = @[self.functionSection, self.descriptionSection];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CSSettingTableViewCell reuseIdentifier]];
    
    // 获取当前项数据并配置cell
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    [cell configureWithItem:item];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取点击的item
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 处理输入类型项的点击
    if (item.itemType == CSSettingItemTypeInput) {
        [CSUIHelper showInputAlertWithTitle:item.title
                                  message:nil
                               initialValue:item.inputValue
                               placeholder:item.inputPlaceholder
                          inViewController:self
                                completion:^(NSString *value) {
            // 更新item的值
            item.inputValue = value;
            // 同时更新detail属性以刷新显示
            item.detail = value;
            
            // 刷新表格
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            // 执行回调
            if (item.inputValueChanged) {
                item.inputValueChanged(value);
            }
        }];
    }
}

@end 