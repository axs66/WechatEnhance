#import "CSNavigationTitleSettingsViewController.h"
#import "CSSettingTableViewCell.h"
#import <objc/runtime.h>

// 常量定义
NSString * const kNavigationShowAvatarKey = @"com.wechat.tweak.navigation.show.avatar";
NSString * const kNavigationAvatarModeKey = @"com.wechat.tweak.navigation.avatar.mode";
NSString * const kNavigationAvatarSizeKey = @"com.wechat.tweak.navigation.avatar.size";
NSString * const kNavigationAvatarRadiusKey = @"com.wechat.tweak.navigation.avatar.radius";

// 新增显示模式开关常量
NSString * const kNavigationShowSelfAvatarKey = @"com.wechat.tweak.navigation.show.self";
NSString * const kNavigationShowOtherAvatarKey = @"com.wechat.tweak.navigation.show.other";
// 添加显示对方网名的常量
NSString * const kNavigationShowOtherNicknameKey = @"com.wechat.tweak.navigation.show.other.nickname";
// 添加显示备注名而不是网名的常量
NSString * const kNavigationShowRemarkNameKey = @"com.wechat.tweak.navigation.show.remark.name";
// 添加网名位置和大小的常量
NSString * const kNavigationNicknamePositionKey = @"com.wechat.tweak.navigation.nickname.position";
NSString * const kNavigationNicknameSizeKey = @"com.wechat.tweak.navigation.nickname.size";

// 新增点击头像弹出信息开关常量
NSString * const kNavigationShowPopoverWhenTapAvatarKey = @"com.wechat.tweak.navigation.show.popover.when.tap.avatar";

// 新增场景设置常量
NSString * const kNavigationShowInPrivateKey = @"com.wechat.tweak.navigation.show.in.private";
NSString * const kNavigationShowInGroupKey = @"com.wechat.tweak.navigation.show.in.group";
NSString * const kNavigationShowInOfficialKey = @"com.wechat.tweak.navigation.show.in.official";

// 分隔符设置常量
NSString * const kNavigationSeparatorTextKey = @"com.wechat.tweak.navigation.separator.text";
NSString * const kNavigationSeparatorSizeKey = @"com.wechat.tweak.navigation.separator.size";
NSString * const kNavigationAvatarSpacingKey = @"com.wechat.tweak.navigation.avatar.spacing";
NSString * const kNavigationVerticalOffsetKey = @"com.wechat.tweak.navigation.vertical.offset";
// 分隔符图片路径常量
NSString * const kNavigationSeparatorImageKey = @"com.wechat.tweak.navigation.separator.image";

// 默认值常量
CGFloat const kDefaultAvatarSize = 35.0f;      // 默认头像大小
CGFloat const kDefaultAvatarRadius = 0.2f;    // 默认圆角比例(40%)
CGFloat const kDefaultSeparatorSize = 22.0f;   // 默认分隔符大小(像素)
CGFloat const kDefaultAvatarSpacing = 4.0f;    // 默认头像间距(像素)
CGFloat const kDefaultVerticalOffset = 0.0f;   // 默认垂直偏移(像素)
CGFloat const kMinAvatarSize = 5.0f;          // 最小头像大小
CGFloat const kMaxAvatarSize = 45.0f;          // 最大头像大小
CGFloat const kDefaultNicknameSize = 16.0f;    // 默认网名字体大小
CGFloat const kMinNicknameSize = 5.0f;        // 最小网名字体大小（从10改为5）
CGFloat const kMaxNicknameSize = 24.0f;        // 最大网名字体大小

@interface CSNavigationTitleSettingsViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, assign) BOOL showAvatar;
@property (nonatomic, assign) BOOL showSelfAvatar;
@property (nonatomic, assign) BOOL showOtherAvatar;
// 添加显示对方网名的属性
@property (nonatomic, assign) BOOL showOtherNickname;
// 添加显示备注名而不是网名的属性
@property (nonatomic, assign) BOOL showRemarkName;
@property (nonatomic, assign) CGFloat avatarSize;
@property (nonatomic, assign) CGFloat avatarRadius;
@property (nonatomic, assign) CGFloat separatorSize; // 添加分隔符大小属性
@property (nonatomic, assign) CGFloat avatarSpacing; // 添加头像间距属性
@property (nonatomic, assign) CGFloat verticalOffset; // 添加垂直偏移属性
@property (nonatomic, strong) UIImage *separatorImage; // 添加分隔符图片属性
@property (nonatomic, strong) UIButton *previewButton; // 预览按钮
// 新增网名位置和大小属性
@property (nonatomic, assign) CSNavigationNicknamePosition nicknamePosition;
@property (nonatomic, assign) CGFloat nicknameSize;
// 添加是否在点击头像时显示信息弹窗的属性
@property (nonatomic, assign) BOOL showPopoverWhenTapAvatar;
@end

@implementation CSNavigationTitleSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    self.title = @"顶栏头像设置";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    // 设置表格样式
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // 注册单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 加载设置
    [self loadSettings];
    
    // 设置数据
    [self setupData];
}

// 视图将要出现时强制刷新一次布局
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 清空表格的重用队列
    [self.tableView reloadData];
    
    // 强制重新调用setupData
    [self setupData];
    
    // 再次强制刷新表格
    [self.tableView reloadData];
}

// 添加viewDidLayoutSubviews方法确保布局完成后刷新表格
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 首次布局完成时强制刷新表格内容，确保图标和标签位置正确
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.tableView reloadData];
    });
}

#pragma mark - 设置加载与保存

- (void)loadSettings {
    // 从UserDefaults加载设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 基本设置
    self.showAvatar = [defaults objectForKey:kNavigationShowAvatarKey] ? 
                      [defaults boolForKey:kNavigationShowAvatarKey] : NO; // 默认关闭
    
    // 加载点击头像显示信息的设置
    self.showPopoverWhenTapAvatar = [defaults objectForKey:kNavigationShowPopoverWhenTapAvatarKey] ? 
                                   [defaults boolForKey:kNavigationShowPopoverWhenTapAvatarKey] : NO; // 默认关闭
    
    // 加载显示模式，默认都关闭
    self.showSelfAvatar = [defaults objectForKey:kNavigationShowSelfAvatarKey] ? 
                         [defaults boolForKey:kNavigationShowSelfAvatarKey] : NO; // 默认关闭
    self.showOtherAvatar = [defaults objectForKey:kNavigationShowOtherAvatarKey] ? 
                          [defaults boolForKey:kNavigationShowOtherAvatarKey] : NO; // 默认关闭
    // 加载显示对方网名的设置
    self.showOtherNickname = [defaults objectForKey:kNavigationShowOtherNicknameKey] ? 
                           [defaults boolForKey:kNavigationShowOtherNicknameKey] : NO; // 默认关闭
    
    // 加载显示备注名的设置
    self.showRemarkName = [defaults objectForKey:kNavigationShowRemarkNameKey] ? 
                         [defaults boolForKey:kNavigationShowRemarkNameKey] : NO; // 默认关闭
    
    // 加载网名位置设置
    NSInteger positionValue = [defaults objectForKey:kNavigationNicknamePositionKey] ? 
                             [defaults integerForKey:kNavigationNicknamePositionKey] : CSNavigationNicknamePositionRight; // 默认右侧
    self.nicknamePosition = (CSNavigationNicknamePosition)positionValue;
    
    // 加载网名大小设置
    self.nicknameSize = [defaults objectForKey:kNavigationNicknameSizeKey] ? 
                       [defaults floatForKey:kNavigationNicknameSizeKey] : kDefaultNicknameSize; // 默认16pt
    
    // 大小设置
    self.avatarSize = [defaults objectForKey:kNavigationAvatarSizeKey] ? 
                     [defaults floatForKey:kNavigationAvatarSizeKey] : kDefaultAvatarSize;
    
    // 圆角设置
    self.avatarRadius = [defaults objectForKey:kNavigationAvatarRadiusKey] ? 
                       [defaults floatForKey:kNavigationAvatarRadiusKey] : kDefaultAvatarRadius;
    
    // 分隔符大小设置
    self.separatorSize = [defaults objectForKey:kNavigationSeparatorSizeKey] ? 
                        [defaults floatForKey:kNavigationSeparatorSizeKey] : kDefaultSeparatorSize;
    
    // 头像间距设置
    self.avatarSpacing = [defaults objectForKey:kNavigationAvatarSpacingKey] ? 
                        [defaults floatForKey:kNavigationAvatarSpacingKey] : kDefaultAvatarSpacing;
                        
    // 垂直偏移设置
    self.verticalOffset = [defaults objectForKey:kNavigationVerticalOffsetKey] ? 
                         [defaults floatForKey:kNavigationVerticalOffsetKey] : kDefaultVerticalOffset;
    
    // 加载分隔符图片
    NSString *imagePath = [defaults objectForKey:kNavigationSeparatorImageKey];
    if (imagePath) {
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        if (imageData) {
            self.separatorImage = [UIImage imageWithData:imageData];
        }
    }
    
    // 向后兼容：如果有旧的显示模式设置，则转换为新的开关设置
    if ([defaults objectForKey:kNavigationAvatarModeKey]) {
        NSInteger oldModeValue = [defaults integerForKey:kNavigationAvatarModeKey];
        CSNavigationAvatarMode oldMode = (CSNavigationAvatarMode)oldModeValue; // 将数值转换为枚举
        
        switch (oldMode) {
            case CSNavigationAvatarModeNone:
                // 不显示头像，但我们默认还是显示自己的
                self.showSelfAvatar = YES;
                self.showOtherAvatar = NO;
                self.showOtherNickname = NO;
                break;
            case CSNavigationAvatarModeOther:
                self.showSelfAvatar = NO;
                self.showOtherAvatar = YES;
                self.showOtherNickname = NO;
                break;
            case CSNavigationAvatarModeSelf:
                self.showSelfAvatar = YES;
                self.showOtherAvatar = NO;
                self.showOtherNickname = NO;
                break;
            case CSNavigationAvatarModeBoth:
                self.showSelfAvatar = YES;
                self.showOtherAvatar = YES;
                self.showOtherNickname = NO;
                break;
        }
        
        // 保存新设置，删除旧设置
        [defaults setBool:self.showSelfAvatar forKey:kNavigationShowSelfAvatarKey];
        [defaults setBool:self.showOtherAvatar forKey:kNavigationShowOtherAvatarKey];
        [defaults setBool:self.showOtherNickname forKey:kNavigationShowOtherNicknameKey];
        [defaults removeObjectForKey:kNavigationAvatarModeKey];
        [defaults synchronize];
    }
    
    // 加载场景设置，默认都关闭
    BOOL showInPrivate = [defaults objectForKey:kNavigationShowInPrivateKey] ? 
                        [defaults boolForKey:kNavigationShowInPrivateKey] : NO; // 默认关闭
    BOOL showInGroup = [defaults objectForKey:kNavigationShowInGroupKey] ? 
                      [defaults boolForKey:kNavigationShowInGroupKey] : NO; // 默认关闭
    BOOL showInOfficial = [defaults objectForKey:kNavigationShowInOfficialKey] ? 
                         [defaults boolForKey:kNavigationShowInOfficialKey] : NO; // 默认关闭
    
    // 重要：如果全部关闭了，至少要开启一个场景（私聊）保持功能可用
    if (!showInPrivate && !showInGroup && !showInOfficial && self.showAvatar) {
        // 移除自动启用私聊场景的逻辑，完全由用户自行控制
        // 即使所有场景都关闭，也尊重用户选择
    }
}

- (void)saveSettings {
    // 保存设置到UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.showAvatar forKey:kNavigationShowAvatarKey];
    [defaults setBool:self.showSelfAvatar forKey:kNavigationShowSelfAvatarKey];
    [defaults setBool:self.showOtherAvatar forKey:kNavigationShowOtherAvatarKey];
    [defaults setBool:self.showOtherNickname forKey:kNavigationShowOtherNicknameKey];
    [defaults setBool:self.showRemarkName forKey:kNavigationShowRemarkNameKey];
    [defaults setBool:self.showPopoverWhenTapAvatar forKey:kNavigationShowPopoverWhenTapAvatarKey];
    [defaults setFloat:self.avatarSize forKey:kNavigationAvatarSizeKey];
    [defaults setFloat:self.avatarRadius forKey:kNavigationAvatarRadiusKey];
    [defaults setFloat:self.separatorSize forKey:kNavigationSeparatorSizeKey];
    [defaults setFloat:self.avatarSpacing forKey:kNavigationAvatarSpacingKey];
    [defaults setFloat:self.verticalOffset forKey:kNavigationVerticalOffsetKey];
    
    // 保存网名位置和大小设置
    [defaults setInteger:self.nicknamePosition forKey:kNavigationNicknamePositionKey];
    [defaults setFloat:self.nicknameSize forKey:kNavigationNicknameSizeKey];
    
    // 重要：确保设置立即同步，这样其他地方读取设置时能获取到最新值
    [defaults synchronize];
    
    // 可选：发送通知，让正在显示的头像视图立即更新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CSNavigationTitleSettingsChanged" object:nil];
}

#pragma mark - 数据设置

- (void)setupData {
    // 基本设置组
    __weak typeof(self) weakSelf = self;
    
    // 1. 显示头像开关
    CSSettingItem *showAvatarItem = [CSSettingItem switchItemWithTitle:@"显示头像" 
                                                             iconName:@"person.crop.circle" 
                                                            iconColor:[UIColor systemBlueColor] 
                                                           switchValue:self.showAvatar 
                                                      valueChangedBlock:^(BOOL isOn) {
        weakSelf.showAvatar = isOn;
        
        // 删除自动开启所有场景的逻辑，让用户自行控制各场景设置
        [weakSelf saveSettings];
        
        // 如果关闭了头像显示，则刷新整个表格（隐藏头像模式选择）
        if (!isOn) {
            [weakSelf setupData];
            [weakSelf.tableView reloadData];
        } else if (weakSelf.sections.count == 1) {
            // 如果开启了头像显示，并且当前只有一个分组，则刷新整个表格（显示详细设置）
            [weakSelf setupData];
            [weakSelf.tableView reloadData];
        }
    }];
    
    // 2. 点击头像显示信息开关
    CSSettingItem *showPopoverWhenTapAvatarItem = [CSSettingItem switchItemWithTitle:@"点击头像显示信息" 
                                                                         iconName:@"person.crop.circle.badge.questionmark" 
                                                                        iconColor:[UIColor systemTealColor] 
                                                                       switchValue:self.showPopoverWhenTapAvatar 
                                                                  valueChangedBlock:^(BOOL isOn) {
        weakSelf.showPopoverWhenTapAvatar = isOn;
        [weakSelf saveSettings];
    }];
    
    // 创建第一个分组
    CSSettingSection *basicSection = [CSSettingSection sectionWithHeader:@"基本设置" 
                                                                 items:@[showAvatarItem, showPopoverWhenTapAvatarItem]];
    
    // 如果没有启用头像显示，则只显示基本设置组
    if (!self.showAvatar) {
        self.sections = @[basicSection];
        return;
    }
    
    // 4. 创建场景设置组
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CSSettingItem *showInPrivateItem = [CSSettingItem switchItemWithTitle:@"在私聊中显示" 
                                                                iconName:@"person.circle" 
                                                               iconColor:[UIColor systemIndigoColor] 
                                                              switchValue:[defaults boolForKey:kNavigationShowInPrivateKey] 
                                                         valueChangedBlock:^(BOOL isOn) {
        // 删除检查其他场景的逻辑，直接设置值
        [defaults setBool:isOn forKey:kNavigationShowInPrivateKey];
        [defaults synchronize];
    }];
    
    CSSettingItem *showInGroupItem = [CSSettingItem switchItemWithTitle:@"在群聊中显示" 
                                                              iconName:@"person.2.circle" 
                                                             iconColor:[UIColor systemGreenColor] 
                                                            switchValue:[defaults boolForKey:kNavigationShowInGroupKey] 
                                                       valueChangedBlock:^(BOOL isOn) {
        // 删除检查其他场景的逻辑，直接设置值
        [defaults setBool:isOn forKey:kNavigationShowInGroupKey];
        [defaults synchronize];
    }];
    
    CSSettingItem *showInOfficialItem = [CSSettingItem switchItemWithTitle:@"在公众号中显示" 
                                                                 iconName:@"newspaper.circle" 
                                                                iconColor:[UIColor systemOrangeColor] 
                                                               switchValue:[defaults boolForKey:kNavigationShowInOfficialKey] 
                                                          valueChangedBlock:^(BOOL isOn) {
        // 删除检查其他场景的逻辑，直接设置值
        [defaults setBool:isOn forKey:kNavigationShowInOfficialKey];
        [defaults synchronize];
    }];
    
    CSSettingSection *sceneSection = [CSSettingSection sectionWithHeader:@"场景设置" 
                                                                 items:@[showInPrivateItem, showInGroupItem, showInOfficialItem]];
    
    // 2. 创建显示开关项
    CSSettingItem *showOtherItem = [CSSettingItem switchItemWithTitle:@"只显示对方头像" 
                                                            iconName:@"person.crop.circle" 
                                                           iconColor:[UIColor systemOrangeColor] 
                                                          switchValue:(self.showOtherAvatar && !self.showSelfAvatar && !self.showOtherNickname) 
                                                     valueChangedBlock:^(BOOL isOn) {
        if (isOn) {
            // 启用"只显示对方"模式
            weakSelf.showOtherAvatar = YES;
            weakSelf.showSelfAvatar = NO;
            weakSelf.showOtherNickname = NO;
        } else {
            // 允许用户关闭此模式
            weakSelf.showOtherAvatar = NO;
        }
        [weakSelf saveSettings];
        
        // 重新设置数据并刷新表格以更新所有开关状态
        [weakSelf setupData];
        [weakSelf.tableView reloadData];
    }];
    
    CSSettingItem *showSelfItem = [CSSettingItem switchItemWithTitle:@"只显示自己头像" 
                                                           iconName:@"person.crop.circle.fill" 
                                                          iconColor:[UIColor systemPurpleColor] 
                                                         switchValue:(self.showSelfAvatar && !self.showOtherAvatar && !self.showOtherNickname) 
                                                    valueChangedBlock:^(BOOL isOn) {
        if (isOn) {
            // 启用"只显示自己"模式
            weakSelf.showSelfAvatar = YES;
            weakSelf.showOtherAvatar = NO;
            weakSelf.showOtherNickname = NO;
        } else {
            // 允许用户关闭此模式
            weakSelf.showSelfAvatar = NO;
        }
        [weakSelf saveSettings];
        
        // 重新设置数据并刷新表格以更新所有开关状态
        [weakSelf setupData];
        [weakSelf.tableView reloadData];
    }];
    
    // 添加显示对方头像带网名的开关
    CSSettingItem *showOtherWithNicknameItem = [CSSettingItem switchItemWithTitle:@"显示对方头像和网名" 
                                                                       iconName:@"person.text.rectangle" 
                                                                      iconColor:[UIColor systemBlueColor] 
                                                                     switchValue:(self.showOtherAvatar && !self.showSelfAvatar && self.showOtherNickname) 
                                                                valueChangedBlock:^(BOOL isOn) {
        if (isOn) {
            // 启用"显示对方头像和网名"模式
            weakSelf.showOtherAvatar = YES;
            weakSelf.showSelfAvatar = NO;
            weakSelf.showOtherNickname = YES;
        } else {
            // 允许用户关闭此模式
            weakSelf.showOtherNickname = NO;
            weakSelf.showOtherAvatar = NO;
        }
        [weakSelf saveSettings];
        
        // 重新设置数据并刷新表格以更新所有开关状态
        [weakSelf setupData];
        [weakSelf.tableView reloadData];
    }];
    
    // 添加同时显示两个头像的开关
    CSSettingItem *showBothItem = [CSSettingItem switchItemWithTitle:@"同时显示两个头像" 
                                                           iconName:@"person.2.circle.fill" 
                                                          iconColor:[UIColor systemTealColor] 
                                                         switchValue:(self.showSelfAvatar && self.showOtherAvatar && !self.showOtherNickname) 
                                                    valueChangedBlock:^(BOOL isOn) {
        if (isOn) {
            // 启用"显示两个头像"模式
            weakSelf.showSelfAvatar = YES;
            weakSelf.showOtherAvatar = YES;
            weakSelf.showOtherNickname = NO;
        } else {
            // 允许用户关闭此模式而不自动切换到其他模式
            weakSelf.showSelfAvatar = NO;
            weakSelf.showOtherAvatar = NO;
        }
        [weakSelf saveSettings];
        
        // 重新设置数据并刷新表格以更新所有开关状态
        [weakSelf setupData];
        [weakSelf.tableView reloadData];
    }];
    
    // 创建显示模式分组
    CSSettingSection *displaySection = [CSSettingSection sectionWithHeader:@"显示模式设置" 
                                                               items:@[showBothItem, showOtherItem, showSelfItem, showOtherWithNicknameItem]];
    
    // 创建外观设置项
    NSString *sizeText = [NSString stringWithFormat:@"%.0f", self.avatarSize];
    CSSettingItem *sizeItem = [CSSettingItem inputItemWithTitle:@"头像大小" 
                                                       iconName:@"ruler" 
                                                      iconColor:[UIColor systemBlueColor] 
                                                      inputValue:sizeText 
                                                  inputPlaceholder:@"输入大小 (25-45)" 
                                                 valueChangedBlock:^(NSString *value) {
        // 转换为数值并验证范围
        CGFloat size = [value floatValue];
        if (size < kMinAvatarSize) {
            size = kMinAvatarSize;
        } else if (size > kMaxAvatarSize) {
            size = kMaxAvatarSize;
        }
        
        // 更新并保存设置
        weakSelf.avatarSize = size;
        [weakSelf saveSettings];
        
        // 更新显示文本，使用调整后的值
        NSString *displayValue = [NSString stringWithFormat:@"%.0f", size];
        
        // 手动更新正确的item和cell
        for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
            CSSettingSection *section = weakSelf.sections[sectionIndex];
            for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                CSSettingItem *item = section.items[rowIndex];
                if ([item.title isEqualToString:@"头像大小"] && item.itemType == CSSettingItemTypeInput) {
                    // 找到了正确的item
                    item.inputValue = displayValue;
                    item.detail = displayValue; // 更新detail显示
                    
                    // 更新对应的cell
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                    CSSettingTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        cell.detailTextLabel.text = displayValue;
                    }
                    break;
                }
            }
        }
        
        // 强制更新所有cell，确保没有错误显示
        [weakSelf.tableView reloadData];
    }];
    
    // 直接使用百分比值显示圆角
    NSString *radiusText = [NSString stringWithFormat:@"%.0f%%", self.avatarRadius * 200]; // 乘以200转换为0-100%
    
    CSSettingItem *radiusItem = [CSSettingItem inputItemWithTitle:@"圆角程度" 
                                                        iconName:@"rectangle.roundedtop" 
                                                       iconColor:[UIColor systemTealColor] 
                                                       inputValue:radiusText 
                                                   inputPlaceholder:@"输入百分比 (0-100)" 
                                                  valueChangedBlock:^(NSString *value) {
        // 处理输入值
        NSString *processedValue = value;
        
        // 移除可能的百分号
        processedValue = [processedValue stringByReplacingOccurrencesOfString:@"%" withString:@""];
        
        // 直接处理数值
        CGFloat percentage = [processedValue floatValue];
        if (percentage < 0) {
            percentage = 0;
        } else if (percentage > 100) {
            percentage = 100;
        }
        
        // 直接将百分比值映射到0-0.5之间
        // 0% -> 0 (无圆角)
        // 50% -> 0.25 (中等圆角)
        // 100% -> 0.5 (完美圆形)
        weakSelf.avatarRadius = percentage / 200.0; // 除以200得到0-0.5范围
        
        // 更新并保存设置
        [weakSelf saveSettings];
        
        // 强制更新文本显示为百分比，使用调整后的值
        NSString *displayValue = [NSString stringWithFormat:@"%.0f%%", percentage];
        
        // 手动更新正确的item和cell
        for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
            CSSettingSection *section = weakSelf.sections[sectionIndex];
            for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                CSSettingItem *item = section.items[rowIndex];
                if ([item.title isEqualToString:@"圆角程度"] && item.itemType == CSSettingItemTypeInput) {
                    // 找到了正确的item
                    item.inputValue = displayValue;
                    item.detail = displayValue; // 更新detail显示
                    
                    // 更新对应的cell
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                    CSSettingTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        cell.detailTextLabel.text = displayValue;
                    }
                    break;
                }
            }
        }
        
        // 强制更新所有cell，确保没有错误显示
        [weakSelf.tableView reloadData];
    }];
    
    // 创建外观设置组
    NSMutableArray *appearanceItems = [NSMutableArray arrayWithArray:@[sizeItem, radiusItem]];
    
    // 如果启用了网名显示，添加网名位置和大小设置
    NSMutableArray *nicknameItems = [NSMutableArray array];
    
    if (self.showOtherNickname) {
        // 网名位置选择器
        CSSettingItem *nicknamePositionItem = [CSSettingItem actionItemWithTitle:@"网名位置" 
                                                                       iconName:@"arrow.up.and.down.and.arrow.left.and.right" 
                                                                      iconColor:[UIColor systemIndigoColor]];
        
        // 设置当前位置的文本描述
        NSString *positionText;
        switch (self.nicknamePosition) {
            case CSNavigationNicknamePositionLeft:
                positionText = @"左侧";
                break;
            case CSNavigationNicknamePositionRight:
                positionText = @"右侧";
                break;
            case CSNavigationNicknamePositionTop:
            case CSNavigationNicknamePositionBottom:
                positionText = @"默认位置";
                break;
        }
        nicknamePositionItem.detail = positionText;
        
        // 网名大小设置
        NSString *sizeTxt = [NSString stringWithFormat:@"%.0f", self.nicknameSize];
        CSSettingItem *nicknameSizeItem = [CSSettingItem inputItemWithTitle:@"网名大小" 
                                                                  iconName:@"textformat.size" 
                                                                 iconColor:[UIColor systemBlueColor] 
                                                                 inputValue:sizeTxt 
                                                           inputPlaceholder:@"输入大小 (5-24)" 
                                                          valueChangedBlock:^(NSString *value) {
            // 转换为数值并验证范围
            CGFloat size = [value floatValue];
            if (size < kMinNicknameSize) {
                size = kMinNicknameSize;
            } else if (size > kMaxNicknameSize) {
                size = kMaxNicknameSize;
            }
            
            // 更新并保存设置
            weakSelf.nicknameSize = size;
            [weakSelf saveSettings];
            
            // 更新显示文本，使用调整后的值
            NSString *displayValue = [NSString stringWithFormat:@"%.0f", size];
            
            // 手动更新UI
            for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
                CSSettingSection *section = weakSelf.sections[sectionIndex];
                for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                    CSSettingItem *item = section.items[rowIndex];
                    if ([item.title isEqualToString:@"网名大小"] && item.itemType == CSSettingItemTypeInput) {
                        // 找到了正确的item
                        item.inputValue = displayValue;
                        item.detail = displayValue; // 更新detail显示
                        
                        // 更新对应的cell
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                        CSSettingTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
                        if (cell) {
                            cell.detailTextLabel.text = displayValue;
                        }
                        break;
                    }
                }
            }
            
            // 刷新表格
            [weakSelf.tableView reloadData];
        }];
        
        // 添加显示备注名而不是网名的开关
        CSSettingItem *showRemarkNameItem = [CSSettingItem switchItemWithTitle:@"显示备注名而非网名"
                                                                     iconName:@"tag.fill"
                                                                    iconColor:[UIColor systemOrangeColor]
                                                                   switchValue:self.showRemarkName
                                                              valueChangedBlock:^(BOOL isOn) {
            weakSelf.showRemarkName = isOn;
            [weakSelf saveSettings];
        }];
        
        [nicknameItems addObjectsFromArray:@[nicknamePositionItem, nicknameSizeItem, showRemarkNameItem]];
        
        // 创建网名设置分组
        CSSettingSection *nicknameSection = [CSSettingSection sectionWithHeader:@"网名设置" 
                                                                      items:nicknameItems];
        
        // 在同时显示两个头像模式下添加分隔符相关设置项
        if (self.showSelfAvatar && self.showOtherAvatar) {
            // 获取当前分隔符文本或图片状态
            NSString *currentSeparator = [[NSUserDefaults standardUserDefaults] objectForKey:kNavigationSeparatorTextKey] ? 
                                       [[NSUserDefaults standardUserDefaults] stringForKey:kNavigationSeparatorTextKey] : @"💗";
            
            // 创建综合分隔符设置项 - 我们不再将详情文本设为空值
            NSString *detailText = self.separatorImage ? @"图片" : currentSeparator; // 显示文本描述或实际分隔符
            CSSettingItem *separatorItem = [CSSettingItem actionItemWithTitle:@"设置分隔符" 
                                                                 iconName:@"text.insert" 
                                                                iconColor:[UIColor systemPinkColor]];
            separatorItem.detail = detailText; // 设置详情文本，不再留空
            
            // 分隔符大小设置项
            NSString *separatorSizeText = [NSString stringWithFormat:@"%.0f", self.separatorSize];
            CSSettingItem *separatorSizeItem = [CSSettingItem inputItemWithTitle:@"分隔符大小" 
                                                                     iconName:@"textformat.size" 
                                                                    iconColor:[UIColor systemPurpleColor] 
                                                                    inputValue:separatorSizeText 
                                                                inputPlaceholder:@"输入大小 5-35)" 
                                                               valueChangedBlock:^(NSString *value) {
                // 转换为数值并验证范围
                CGFloat size = [value floatValue];
                if (size < 5.0) {
                    size = 5.0;
                } else if (size > 35.0) {
                    size = 35.0;
                }
                
                // 更新并保存设置
                weakSelf.separatorSize = size;
                [weakSelf saveSettings];
                
                // 更新显示文本，使用调整后的值
                NSString *displayValue = [NSString stringWithFormat:@"%.0f", size];
                
                // 手动更新正确的item和cell
                for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
                    CSSettingSection *section = weakSelf.sections[sectionIndex];
                    for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                        CSSettingItem *item = section.items[rowIndex];
                        if ([item.title isEqualToString:@"分隔符大小"] && item.itemType == CSSettingItemTypeInput) {
                            // 找到了正确的item
                            item.inputValue = displayValue;
                            item.detail = displayValue; // 更新detail显示
                            break;
                        }
                    }
                }
                
                // 刷新整个表格，让系统处理UI更新
                [weakSelf.tableView reloadData];
            }];
            
            // 头像间距设置项
            NSString *spacingText = [NSString stringWithFormat:@"%.0f", self.avatarSpacing];
            CSSettingItem *spacingItem = [CSSettingItem inputItemWithTitle:@"头像间距" 
                                                                 iconName:@"arrow.left.and.right" 
                                                                iconColor:[UIColor systemGreenColor] 
                                                                inputValue:spacingText 
                                                            inputPlaceholder:@"输入间距 (0-20)" 
                                                           valueChangedBlock:^(NSString *value) {
                // 转换为数值并验证范围
                CGFloat spacing = [value floatValue];
                if (spacing < 0.0) {
                    spacing = 0.0;
                } else if (spacing > 20.0) {
                    spacing = 20.0;
                }
                
                // 更新并保存设置
                weakSelf.avatarSpacing = spacing;
                [weakSelf saveSettings];
                
                // 更新显示文本，使用调整后的值
                NSString *displayValue = [NSString stringWithFormat:@"%.0f", spacing];
                
                // 手动更新正确的item和cell
                for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
                    CSSettingSection *section = weakSelf.sections[sectionIndex];
                    for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                        CSSettingItem *item = section.items[rowIndex];
                        if ([item.title isEqualToString:@"头像间距"] && item.itemType == CSSettingItemTypeInput) {
                            // 找到了正确的item
                            item.inputValue = displayValue;
                            item.detail = displayValue; // 更新detail显示
                            break;
                        }
                    }
                }
                
                // 刷新整个表格，让系统处理UI更新
                [weakSelf.tableView reloadData];
            }];
            
            // 添加所有分隔符相关的设置项
            [appearanceItems addObjectsFromArray:@[separatorItem, separatorSizeItem, spacingItem]];
        }
        
        // 垂直偏移设置项
        NSString *offsetText = [NSString stringWithFormat:@"%.0f", self.verticalOffset];
        CSSettingItem *offsetItem = [CSSettingItem inputItemWithTitle:@"垂直位置" 
                                                           iconName:@"arrow.up.and.down" 
                                                          iconColor:[UIColor systemBlueColor] 
                                                          inputValue:offsetText 
                                                      inputPlaceholder:@"正值向上 负值向下 (-20~20)" 
                                                     valueChangedBlock:^(NSString *value) {
            // 转换为数值并验证范围
            CGFloat offset = [value floatValue];
            if (offset < -20.0) {
                offset = -20.0;
            } else if (offset > 20.0) {
                offset = 20.0;
            }
            
            // 更新并保存设置
            weakSelf.verticalOffset = offset;
            [weakSelf saveSettings];
            
            // 更新显示文本，使用调整后的值
            NSString *displayValue = [NSString stringWithFormat:@"%.0f", offset];
            
            // 手动更新正确的item和cell
            for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
                CSSettingSection *section = weakSelf.sections[sectionIndex];
                for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                    CSSettingItem *item = section.items[rowIndex];
                    if ([item.title isEqualToString:@"垂直位置"] && item.itemType == CSSettingItemTypeInput) {
                        // 找到了正确的item
                        item.inputValue = displayValue;
                        item.detail = displayValue; // 更新detail显示
                        break;
                    }
                }
            }
            
            // 刷新整个表格，让系统处理UI更新
            [weakSelf.tableView reloadData];
        }];
        
        [appearanceItems addObject:offsetItem];
        
        CSSettingSection *appearanceSection = [CSSettingSection sectionWithHeader:@"外观设置" 
                                                                      items:appearanceItems];
        
        // 设置数据 - 包含网名设置分区
        self.sections = @[basicSection, sceneSection, displaySection, nicknameSection, appearanceSection];
    } else {
        // 在同时显示两个头像模式下添加分隔符相关设置项
        if (self.showSelfAvatar && self.showOtherAvatar) {
            // 获取当前分隔符文本或图片状态
            NSString *currentSeparator = [[NSUserDefaults standardUserDefaults] objectForKey:kNavigationSeparatorTextKey] ? 
                                       [[NSUserDefaults standardUserDefaults] stringForKey:kNavigationSeparatorTextKey] : @"💗";
            
            // 创建综合分隔符设置项 - 我们不再将详情文本设为空值
            NSString *detailText = self.separatorImage ? @"图片" : currentSeparator; // 显示文本描述或实际分隔符
            CSSettingItem *separatorItem = [CSSettingItem actionItemWithTitle:@"设置分隔符" 
                                                                 iconName:@"text.insert" 
                                                                iconColor:[UIColor systemPinkColor]];
            separatorItem.detail = detailText; // 设置详情文本，不再留空
            
            // 分隔符大小设置项
            NSString *separatorSizeText = [NSString stringWithFormat:@"%.0f", self.separatorSize];
            CSSettingItem *separatorSizeItem = [CSSettingItem inputItemWithTitle:@"分隔符大小" 
                                                                     iconName:@"textformat.size" 
                                                                    iconColor:[UIColor systemPurpleColor] 
                                                                    inputValue:separatorSizeText 
                                                                inputPlaceholder:@"输入大小 (12-35)" 
                                                               valueChangedBlock:^(NSString *value) {
                // 转换为数值并验证范围
                CGFloat size = [value floatValue];
                if (size < 12.0) {
                    size = 12.0;
                } else if (size > 35.0) {
                    size = 35.0;
                }
                
                // 更新并保存设置
                weakSelf.separatorSize = size;
                [weakSelf saveSettings];
                
                // 更新显示文本，使用调整后的值
                NSString *displayValue = [NSString stringWithFormat:@"%.0f", size];
                
                // 手动更新正确的item和cell
                for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
                    CSSettingSection *section = weakSelf.sections[sectionIndex];
                    for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                        CSSettingItem *item = section.items[rowIndex];
                        if ([item.title isEqualToString:@"分隔符大小"] && item.itemType == CSSettingItemTypeInput) {
                            // 找到了正确的item
                            item.inputValue = displayValue;
                            item.detail = displayValue; // 更新detail显示
                            break;
                        }
                    }
                }
                
                // 刷新整个表格，让系统处理UI更新
                [weakSelf.tableView reloadData];
            }];
            
            // 头像间距设置项
            NSString *spacingText = [NSString stringWithFormat:@"%.0f", self.avatarSpacing];
            CSSettingItem *spacingItem = [CSSettingItem inputItemWithTitle:@"头像间距" 
                                                                 iconName:@"arrow.left.and.right" 
                                                                iconColor:[UIColor systemGreenColor] 
                                                                inputValue:spacingText 
                                                            inputPlaceholder:@"输入间距 (0-20)" 
                                                           valueChangedBlock:^(NSString *value) {
                // 转换为数值并验证范围
                CGFloat spacing = [value floatValue];
                if (spacing < 0.0) {
                    spacing = 0.0;
                } else if (spacing > 20.0) {
                    spacing = 20.0;
                }
                
                // 更新并保存设置
                weakSelf.avatarSpacing = spacing;
                [weakSelf saveSettings];
                
                // 更新显示文本，使用调整后的值
                NSString *displayValue = [NSString stringWithFormat:@"%.0f", spacing];
                
                // 手动更新正确的item和cell
                for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
                    CSSettingSection *section = weakSelf.sections[sectionIndex];
                    for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                        CSSettingItem *item = section.items[rowIndex];
                        if ([item.title isEqualToString:@"头像间距"] && item.itemType == CSSettingItemTypeInput) {
                            // 找到了正确的item
                            item.inputValue = displayValue;
                            item.detail = displayValue; // 更新detail显示
                            break;
                        }
                    }
                }
                
                // 刷新整个表格，让系统处理UI更新
                [weakSelf.tableView reloadData];
            }];
            
            // 添加所有分隔符相关的设置项
            [appearanceItems addObjectsFromArray:@[separatorItem, separatorSizeItem, spacingItem]];
        }
        
        // 垂直偏移设置项
        NSString *offsetText = [NSString stringWithFormat:@"%.0f", self.verticalOffset];
        CSSettingItem *offsetItem = [CSSettingItem inputItemWithTitle:@"垂直位置" 
                                                           iconName:@"arrow.up.and.down" 
                                                          iconColor:[UIColor systemBlueColor] 
                                                          inputValue:offsetText 
                                                      inputPlaceholder:@"正值向上 负值向下 (-20~20)" 
                                                     valueChangedBlock:^(NSString *value) {
            // 转换为数值并验证范围
            CGFloat offset = [value floatValue];
            if (offset < -20.0) {
                offset = -20.0;
            } else if (offset > 20.0) {
                offset = 20.0;
            }
            
            // 更新并保存设置
            weakSelf.verticalOffset = offset;
            [weakSelf saveSettings];
            
            // 更新显示文本，使用调整后的值
            NSString *displayValue = [NSString stringWithFormat:@"%.0f", offset];
            
            // 手动更新正确的item和cell
            for (NSInteger sectionIndex = 0; sectionIndex < weakSelf.sections.count; sectionIndex++) {
                CSSettingSection *section = weakSelf.sections[sectionIndex];
                for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                    CSSettingItem *item = section.items[rowIndex];
                    if ([item.title isEqualToString:@"垂直位置"] && item.itemType == CSSettingItemTypeInput) {
                        // 找到了正确的item
                        item.inputValue = displayValue;
                        item.detail = displayValue; // 更新detail显示
                        break;
                    }
                }
            }
            
            // 刷新整个表格，让系统处理UI更新
            [weakSelf.tableView reloadData];
        }];
        
        [appearanceItems addObject:offsetItem];
        
        CSSettingSection *appearanceSection = [CSSettingSection sectionWithHeader:@"外观设置" 
                                                                      items:appearanceItems];
        
        // 设置数据 - 包含网名设置分区
        self.sections = @[basicSection, sceneSection, displaySection, appearanceSection];
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
    
    // 获取当前项数据
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 特殊处理分隔符设置项
    if ([item.title isEqualToString:@"设置分隔符"] && self.separatorImage) {
        // 创建一个小型预览图像视图
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.separatorImage];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.cornerRadius = 4.0;
        imageView.layer.masksToBounds = YES;
        
        // 设置固定尺寸
        CGRect frame = CGRectMake(0, 0, 30, 30);
        imageView.frame = frame;
        
        // 设置为accessoryView
        cell.accessoryView = imageView;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // 隐藏详情文本，因为我们用图片代替
        item.detail = nil;
    } else if ([item.title isEqualToString:@"设置分隔符"] && !self.separatorImage) {
        // 使用箭头指示器，并显示当前分隔符文本
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString *currentSeparator = [[NSUserDefaults standardUserDefaults] objectForKey:kNavigationSeparatorTextKey] ?: @"💗";
        item.detail = currentSeparator;
    }
    
    // 配置单元格
    [cell configureWithItem:item];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0 && self.sections.count > 1) {
        return nil;
    } else if (section == 1 && self.sections.count > 2) {
        return nil;
    } else if (section == 2 && self.sections.count > 3) {
        return nil;
    } else if (section == 3) {
        return nil;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 处理输入类型项的点击
    if (item.itemType == CSSettingItemTypeInput) {
        // 为输入类型项显示输入弹窗
        [CSUIHelper showInputAlertWithTitle:item.title
                                  message:nil
                               initialValue:item.inputValue
                               placeholder:item.inputPlaceholder
                          inViewController:self
                                completion:^(NSString *value) {
            // 更新item的值
            item.inputValue = value;
            
            // 执行回调
            if (item.inputValueChanged) {
                item.inputValueChanged(value);
            }
            
            // 刷新表格 - 让系统处理UI更新
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    } 
    // 处理操作类型项的点击
    else if (item.itemType == CSSettingItemTypeAction) {
        if ([item.title isEqualToString:@"设置分隔符"]) {
            // 弹出分隔符设置选项
            [self showSeparatorOptions];
        } else if ([item.title isEqualToString:@"网名位置"]) {
            // 弹出网名位置选择器
            [self showNicknamePositionOptions];
        }
    }
}

#pragma mark - 分隔符设置选项

// 显示分隔符设置选项
- (void)showSeparatorOptions {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"设置分隔符"
                                                                    message:@"请选择分隔符类型"
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 添加文本输入选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"输入文本" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 获取当前文本值
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *currentText = [defaults objectForKey:kNavigationSeparatorTextKey] ?: @"💗";
        
        // 显示文本输入弹窗
        [CSUIHelper showInputAlertWithTitle:@"输入分隔符文本"
                                  message:@"最多1个字符"
                               initialValue:currentText
                               placeholder:@"输入表情或符号"
                          inViewController:self
                                completion:^(NSString *value) {
            // 处理输入值
            NSString *finalValue = value;
            
            // 如果为空，设置为默认值
            if (finalValue.length == 0) {
                finalValue = @"💗";
            } 
            // 如果超过1个字符，只保留第一个完整字符（包括复合emoji）
            else if (finalValue.length > 1) {
                NSRange firstCharRange = [finalValue rangeOfComposedCharacterSequenceAtIndex:0];
                finalValue = [finalValue substringWithRange:firstCharRange];
            }
            
            // 清除图片分隔符
            if (self.separatorImage) {
                self.separatorImage = nil;
                NSString *imagePath = [defaults objectForKey:kNavigationSeparatorImageKey];
                if (imagePath) {
                    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                    [defaults removeObjectForKey:kNavigationSeparatorImageKey];
                }
            }
            
            // 保存文本分隔符
            [defaults setObject:finalValue forKey:kNavigationSeparatorTextKey];
            [defaults synchronize];
            
            // 发送通知更新UI
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CSNavigationTitleSettingsChanged" object:nil];
            
            // 更新设置界面
            [self setupData];
            [self.tableView reloadData];
        }];
    }]];
    
    // 添加图片选择选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"选择图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openImagePicker];
    }]];
    
    // 如果已有图片，添加删除选项
    if (self.separatorImage) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"删除图片" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteSeparatorImage];
        }]];
    }
    
    // 添加取消选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    // 在iPad上，需要设置弹出位置
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        actionSheet.popoverPresentationController.sourceView = self.tableView;
        actionSheet.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - 图片选择器和预览

// 打开图片选择器
- (void)openImagePicker {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                       message:@"无法访问相册"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES; // 允许编辑，以便将图片裁剪为方形
    
    [self presentViewController:picker animated:YES completion:nil];
}

// 显示图片预览和删除选项
- (void)showImagePreviewOptions {
    if (!self.separatorImage) return;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"分隔符图片"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 添加预览选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"预览" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showImagePreview];
    }]];
    
    // 添加删除选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"删除图片" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteSeparatorImage];
    }]];
    
    // 添加取消选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    // 在iPad上，需要设置弹出位置
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        actionSheet.popoverPresentationController.sourceView = self.tableView;
        actionSheet.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

// 显示图片预览
- (void)showImagePreview {
    if (!self.separatorImage) return;
    
    // 创建一个弹出窗口显示图片
    UIViewController *previewVC = [[UIViewController alloc] init];
    previewVC.view.backgroundColor = [UIColor blackColor];
    
    // 创建图片视图
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.separatorImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [previewVC.view addSubview:imageView];
    
    // 添加约束
    [NSLayoutConstraint activateConstraints:@[
        [imageView.centerXAnchor constraintEqualToAnchor:previewVC.view.centerXAnchor],
        [imageView.centerYAnchor constraintEqualToAnchor:previewVC.view.centerYAnchor],
        [imageView.widthAnchor constraintLessThanOrEqualToAnchor:previewVC.view.widthAnchor multiplier:0.9],
        [imageView.heightAnchor constraintLessThanOrEqualToAnchor:previewVC.view.heightAnchor multiplier:0.9]
    ]];
    
    // 添加关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:previewVC action:@selector(dismissViewControllerAnimated:completion:) forControlEvents:UIControlEventTouchUpInside];
    [previewVC.view addSubview:closeButton];
    
    // 添加关闭按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [closeButton.topAnchor constraintEqualToAnchor:previewVC.view.safeAreaLayoutGuide.topAnchor constant:20],
        [closeButton.trailingAnchor constraintEqualToAnchor:previewVC.view.safeAreaLayoutGuide.trailingAnchor constant:-20]
    ]];
    
    // 模态显示预览控制器
    [self presentViewController:previewVC animated:YES completion:nil];
}

// 删除分隔符图片
- (void)deleteSeparatorImage {
    // 清除图片数据
    self.separatorImage = nil;
    
    // 清空分隔符图片
    NSString *prefsPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    prefsPath = [prefsPath stringByAppendingPathComponent:@"Preferences"];
    NSString *enhanceFolderPath = [prefsPath stringByAppendingPathComponent:@"WechatEnhance"];
    NSString *filePath = [enhanceFolderPath stringByAppendingPathComponent:@"separator_image.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    // 从UserDefaults中删除图片路径
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kNavigationSeparatorImageKey];
    [defaults synchronize];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CSNavigationTitleSettingsChanged" object:nil];
    
    // 刷新表格视图，更新UI
    [self setupData];
    [self.tableView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    
    if (selectedImage) {
        // 调整图片大小
        CGSize maxSize = CGSizeMake(100, 100); // 设置合理的最大尺寸
        UIImage *resizedImage = [self resizeImage:selectedImage toSize:maxSize];
        
        // 保存图片并更新UI
        [self saveSeparatorImage:resizedImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 图片处理工具方法

// 调整图片大小
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)maxSize {
    CGSize originalSize = image.size;
    CGFloat ratio = MIN(maxSize.width / originalSize.width, maxSize.height / originalSize.height);
    
    // 如果图片已经小于最大尺寸，直接返回
    if (ratio >= 1.0) {
        return image;
    }
    
    CGSize newSize = CGSizeMake(originalSize.width * ratio, originalSize.height * ratio);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

// 保存分隔符图片
- (void)saveSeparatorImage:(UIImage *)image {
    if (!image) return;
    
    // 保存图片到文件
    NSData *pngData = UIImagePNGRepresentation(image);
    if (!pngData) return;
    
    // 创建Preferences目录下专用于WechatEnhance的固定文件夹
    NSString *prefsPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    prefsPath = [prefsPath stringByAppendingPathComponent:@"Preferences"];
    
    NSString *enhanceFolderName = @"WechatEnhance";
    NSString *enhanceFolderPath = [prefsPath stringByAppendingPathComponent:enhanceFolderName];
    
    // 确保文件夹存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:enhanceFolderPath isDirectory:&isDirectory];
    
    // 如果文件夹不存在或不是文件夹，则创建它
    if (!exists || !isDirectory) {
        // 如果存在但不是文件夹，先删除
        if (exists) {
            [fileManager removeItemAtPath:enhanceFolderPath error:nil];
        }
        // 创建文件夹
        [fileManager createDirectoryAtPath:enhanceFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 使用固定文件名
    NSString *fileName = @"separator_image.png";
    NSString *filePath = [enhanceFolderPath stringByAppendingPathComponent:fileName];
    
    // 写入文件
    if ([pngData writeToFile:filePath atomically:YES]) {
        // 保存新路径到用户设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:filePath forKey:kNavigationSeparatorImageKey];
        [defaults synchronize];
        
        // 更新内存中的图片
        self.separatorImage = image;
        
        // 发送通知更新UI
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSNavigationTitleSettingsChanged" object:nil];
        
        // 刷新当前表格视图
        [self setupData];
        [self.tableView reloadData];
    }
}

// 设置cell的背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 使用secondarySystemGroupedBackgroundColor来获得正确的深色模式下的背景色
    if (@available(iOS 13.0, *)) {
        cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - 网名位置选择器

// 显示网名位置选择器
- (void)showNicknamePositionOptions {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"选择网名位置"
                                                                        message:@"选择网名相对于头像的位置"
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 添加右侧选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"右侧" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateNicknamePosition:CSNavigationNicknamePositionRight];
    }]];
    
    // 添加左侧选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"左侧" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateNicknamePosition:CSNavigationNicknamePositionLeft];
    }]];
    
    // 添加取消选项
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    // 在iPad上，需要设置弹出位置
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        actionSheet.popoverPresentationController.sourceView = self.tableView;
        // 找到网名位置选项的索引路径
        NSIndexPath *indexPath = nil;
        for (NSInteger sectionIndex = 0; sectionIndex < self.sections.count; sectionIndex++) {
            CSSettingSection *section = self.sections[sectionIndex];
            for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
                CSSettingItem *item = section.items[rowIndex];
                if ([item.title isEqualToString:@"网名位置"] && item.itemType == CSSettingItemTypeAction) {
                    indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                    break;
                }
            }
            if (indexPath) break;
        }
        
        if (indexPath) {
            actionSheet.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:indexPath];
        } else {
            actionSheet.popoverPresentationController.sourceRect = self.tableView.bounds;
        }
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

// 更新网名位置
- (void)updateNicknamePosition:(CSNavigationNicknamePosition)position {
    // 更新位置
    self.nicknamePosition = position;
    
    // 保存设置
    [self saveSettings];
    
    // 更新界面显示
    NSString *positionText;
    switch (position) {
        case CSNavigationNicknamePositionLeft:
            positionText = @"左侧";
            break;
        case CSNavigationNicknamePositionRight:
            positionText = @"右侧";
            break;
        case CSNavigationNicknamePositionTop:
        case CSNavigationNicknamePositionBottom:
            positionText = @"默认位置";
            break;
    }
    
    // 更新UI
    for (NSInteger sectionIndex = 0; sectionIndex < self.sections.count; sectionIndex++) {
        CSSettingSection *section = self.sections[sectionIndex];
        for (NSInteger rowIndex = 0; rowIndex < section.items.count; rowIndex++) {
            CSSettingItem *item = section.items[rowIndex];
            if ([item.title isEqualToString:@"网名位置"] && item.itemType == CSSettingItemTypeAction) {
                // 找到了正确的item
                item.detail = positionText;
                
                // 更新对应的cell
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}

@end 