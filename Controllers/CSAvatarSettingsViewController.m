#import "CSAvatarSettingsViewController.h"
#import "CSSettingTableViewCell.h"

@interface CSAvatarSettingsViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) CSSettingItem *rotateSpeedItem; // 旋转速度设置项
@property (nonatomic, assign) BOOL isRotateEnabled; // 追踪旋转开关状态
@property (nonatomic, assign) BOOL isRoundAvatarEnabled; // 追踪圆形头像开关状态
@property (nonatomic, strong) CSSettingItem *cornerRadiusItem; // 圆角大小输入项
@end

@implementation CSAvatarSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"头像设置";
    
    // 设置表格样式
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // 注册cell
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 初始化状态
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    self.isRotateEnabled = [defaults boolForKey:kRotateAvatarKey];
    self.isRoundAvatarEnabled = [defaults boolForKey:kRoundAvatarKey];
    
    // 加载数据
    [self setupData];
}

- (void)setupData {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    // 1. 创建私聊头像设置分区
    NSMutableArray *privateChatItems = [NSMutableArray array];
    
    [privateChatItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏对方头像"
                                                         iconName:@"person.crop.circle.badge.minus.fill"
                                                        iconColor:[UIColor systemRedColor]
                                                      switchValue:[defaults boolForKey:kHideOtherAvatarInPrivateChatKey]
                                                 valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideOtherAvatarInPrivateChatKey];
        // 确保"隐藏双方头像"和"隐藏对方头像"的状态一致
        if (isOn) {
            // 如果"隐藏自己头像"也是打开的，就打开"隐藏双方头像"
            if ([defaults boolForKey:kHideSelfAvatarInPrivateChatKey]) {
                [defaults setBool:YES forKey:kHideBothAvatarInPrivateChatKey];
            } else {
                [defaults setBool:NO forKey:kHideBothAvatarInPrivateChatKey];
            }
        } else {
            // 如果关闭"隐藏对方头像"，也要关闭"隐藏双方头像"
            [defaults setBool:NO forKey:kHideBothAvatarInPrivateChatKey];
        }
        [defaults synchronize];
        [self updateSectionWithItems:privateChatItems atIndex:0];
    }]];
    
    [privateChatItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏自己头像"
                                                         iconName:@"person.crop.circle.badge.minus"
                                                        iconColor:[UIColor systemOrangeColor]
                                                      switchValue:[defaults boolForKey:kHideSelfAvatarInPrivateChatKey]
                                                 valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideSelfAvatarInPrivateChatKey];
        // 确保"隐藏双方头像"和"隐藏自己头像"的状态一致
        if (isOn) {
            // 如果"隐藏对方头像"也是打开的，就打开"隐藏双方头像"
            if ([defaults boolForKey:kHideOtherAvatarInPrivateChatKey]) {
                [defaults setBool:YES forKey:kHideBothAvatarInPrivateChatKey];
            } else {
                [defaults setBool:NO forKey:kHideBothAvatarInPrivateChatKey];
            }
        } else {
            // 如果关闭"隐藏自己头像"，也要关闭"隐藏双方头像"
            [defaults setBool:NO forKey:kHideBothAvatarInPrivateChatKey];
        }
        [defaults synchronize];
        [self updateSectionWithItems:privateChatItems atIndex:0];
    }]];
    
    [privateChatItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏双方头像"
                                                         iconName:@"person.2.slash"
                                                        iconColor:[UIColor systemPurpleColor]
                                                      switchValue:[defaults boolForKey:kHideBothAvatarInPrivateChatKey]
                                                 valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideBothAvatarInPrivateChatKey];
        // 同步更新单独的开关状态
        [defaults setBool:isOn forKey:kHideOtherAvatarInPrivateChatKey];
        [defaults setBool:isOn forKey:kHideSelfAvatarInPrivateChatKey];
        [defaults synchronize];
        [self updateSectionWithItems:privateChatItems atIndex:0];
    }]];
    
    CSSettingSection *privateChatSection = [CSSettingSection sectionWithHeader:@"私聊头像设置" items:privateChatItems];
    [sectionsArray addObject:privateChatSection];
    
    // 2. 创建群聊头像设置分区
    NSMutableArray *groupChatItems = [NSMutableArray array];
    
    [groupChatItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏对方头像"
                                                       iconName:@"person.3.fill"
                                                      iconColor:[UIColor systemGreenColor]
                                                    switchValue:[defaults boolForKey:kHideOtherAvatarInGroupChatKey]
                                               valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideOtherAvatarInGroupChatKey];
        // 确保"隐藏双方头像"和"隐藏对方头像"的状态一致
        if (isOn) {
            // 如果"隐藏自己头像"也是打开的，就打开"隐藏双方头像"
            if ([defaults boolForKey:kHideSelfAvatarInGroupChatKey]) {
                [defaults setBool:YES forKey:kHideBothAvatarInGroupChatKey];
            } else {
                [defaults setBool:NO forKey:kHideBothAvatarInGroupChatKey];
            }
        } else {
            // 如果关闭"隐藏对方头像"，也要关闭"隐藏双方头像"
            [defaults setBool:NO forKey:kHideBothAvatarInGroupChatKey];
        }
        [defaults synchronize];
        [self updateSectionWithItems:groupChatItems atIndex:1];
    }]];
    
    [groupChatItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏自己头像"
                                                       iconName:@"person.crop.circle.badge.minus"
                                                      iconColor:[UIColor systemOrangeColor]
                                                    switchValue:[defaults boolForKey:kHideSelfAvatarInGroupChatKey]
                                               valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideSelfAvatarInGroupChatKey];
        // 确保"隐藏双方头像"和"隐藏自己头像"的状态一致
        if (isOn) {
            // 如果"隐藏对方头像"也是打开的，就打开"隐藏双方头像"
            if ([defaults boolForKey:kHideOtherAvatarInGroupChatKey]) {
                [defaults setBool:YES forKey:kHideBothAvatarInGroupChatKey];
            } else {
                [defaults setBool:NO forKey:kHideBothAvatarInGroupChatKey];
            }
        } else {
            // 如果关闭"隐藏自己头像"，也要关闭"隐藏双方头像"
            [defaults setBool:NO forKey:kHideBothAvatarInGroupChatKey];
        }
        [defaults synchronize];
        [self updateSectionWithItems:groupChatItems atIndex:1];
    }]];
    
    [groupChatItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏双方头像"
                                                       iconName:@"person.2.slash"
                                                      iconColor:[UIColor systemPurpleColor]
                                                    switchValue:[defaults boolForKey:kHideBothAvatarInGroupChatKey]
                                               valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideBothAvatarInGroupChatKey];
        // 同步更新单独的开关状态
        [defaults setBool:isOn forKey:kHideOtherAvatarInGroupChatKey];
        [defaults setBool:isOn forKey:kHideSelfAvatarInGroupChatKey];
        [defaults synchronize];
        [self updateSectionWithItems:groupChatItems atIndex:1];
    }]];
    
    CSSettingSection *groupChatSection = [CSSettingSection sectionWithHeader:@"群聊头像设置" items:groupChatItems];
    [sectionsArray addObject:groupChatSection];
    
    // 3. 创建公众号头像设置分区
    NSMutableArray *officialAccountItems = [NSMutableArray array];
    
    [officialAccountItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏对方头像"
                                                           iconName:@"megaphone.fill"
                                                          iconColor:[UIColor systemOrangeColor]
                                                        switchValue:[defaults boolForKey:kHideOtherAvatarInOfficialAccountKey]
                                                   valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideOtherAvatarInOfficialAccountKey];
        // 确保"隐藏双方头像"和"隐藏对方头像"的状态一致
        if (isOn) {
            // 如果"隐藏自己头像"也是打开的，就打开"隐藏双方头像"
            if ([defaults boolForKey:kHideSelfAvatarInOfficialAccountKey]) {
                [defaults setBool:YES forKey:kHideBothAvatarInOfficialAccountKey];
            } else {
                [defaults setBool:NO forKey:kHideBothAvatarInOfficialAccountKey];
            }
        } else {
            // 如果关闭"隐藏对方头像"，也要关闭"隐藏双方头像"
            [defaults setBool:NO forKey:kHideBothAvatarInOfficialAccountKey];
        }
        [defaults synchronize];
        [self updateSectionWithItems:officialAccountItems atIndex:2];
    }]];
    
    [officialAccountItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏自己头像"
                                                           iconName:@"person.crop.circle.badge.minus"
                                                          iconColor:[UIColor systemOrangeColor]
                                                        switchValue:[defaults boolForKey:kHideSelfAvatarInOfficialAccountKey]
                                                   valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideSelfAvatarInOfficialAccountKey];
        // 确保"隐藏双方头像"和"隐藏自己头像"的状态一致
        if (isOn) {
            // 如果"隐藏对方头像"也是打开的，就打开"隐藏双方头像"
            if ([defaults boolForKey:kHideOtherAvatarInOfficialAccountKey]) {
                [defaults setBool:YES forKey:kHideBothAvatarInOfficialAccountKey];
            } else {
                [defaults setBool:NO forKey:kHideBothAvatarInOfficialAccountKey];
            }
        } else {
            // 如果关闭"隐藏自己头像"，也要关闭"隐藏双方头像"
            [defaults setBool:NO forKey:kHideBothAvatarInOfficialAccountKey];
        }
        [defaults synchronize];
        [self updateSectionWithItems:officialAccountItems atIndex:2];
    }]];
    
    [officialAccountItems addObject:[CSSettingItem switchItemWithTitle:@"隐藏双方头像"
                                                           iconName:@"person.2.slash"
                                                          iconColor:[UIColor systemPurpleColor]
                                                        switchValue:[defaults boolForKey:kHideBothAvatarInOfficialAccountKey]
                                                   valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kHideBothAvatarInOfficialAccountKey];
        // 同步更新单独的开关状态
        [defaults setBool:isOn forKey:kHideOtherAvatarInOfficialAccountKey];
        [defaults setBool:isOn forKey:kHideSelfAvatarInOfficialAccountKey];
        [defaults synchronize];
        [self updateSectionWithItems:officialAccountItems atIndex:2];
    }]];
    
    CSSettingSection *officialAccountSection = [CSSettingSection sectionWithHeader:@"公众号头像设置" items:officialAccountItems];
    [sectionsArray addObject:officialAccountSection];
    
    // 4. 创建头像形状设置分区
    __weak typeof(self) weakSelf = self;
    
    CSSettingItem *roundAvatarItem = [CSSettingItem switchItemWithTitle:@"圆形头像"
                                                               iconName:@"circle"
                                                              iconColor:[UIColor systemBlueColor]
                                                            switchValue:self.isRoundAvatarEnabled
                                                       valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kRoundAvatarKey];
        [defaults synchronize];
        
        // 更新圆形头像状态
        weakSelf.isRoundAvatarEnabled = isOn;
        
        // 更新圆角设置项的显示状态
        [weakSelf updateCornerRadiusSection];
        
        // 显示提示对话框，提供立即重启和稍后重启选项
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                 message:@"头像形状设置已保存，需要重启微信才能生效。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        // 稍后重启选项
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启" 
                                                             style:UIAlertActionStyleDefault 
                                                           handler:nil];
        [alertController addAction:laterAction];
        
        // 立即重启选项
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启" 
                                                              style:UIAlertActionStyleDestructive 
                                                            handler:^(UIAlertAction * _Nonnull action) {
            // 使用exit(0)立即重启
            exit(0);
        }];
        [alertController addAction:restartAction];
        
        // 显示对话框
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    
    CSSettingSection *avatarShapeSection = [CSSettingSection sectionWithHeader:@"头像形状设置" 
                                                                       items:@[roundAvatarItem]];
    [sectionsArray addObject:avatarShapeSection];
    
    // 5. 创建圆角大小分区（仅在圆形头像开启时显示）
    // 获取当前圆角大小值，默认为1.0（完全圆形）
    float currentCornerRadius = [defaults floatForKey:kAvatarCornerRadiusKey];
    if (currentCornerRadius == 0) currentCornerRadius = 1.0f;
    
    // 创建圆角大小设置项
    self.cornerRadiusItem = [CSSettingItem inputItemWithTitle:@"圆角程度"
                                                    iconName:@"slider.horizontal.3"
                                                   iconColor:[UIColor systemTealColor]
                                                  inputValue:[NSString stringWithFormat:@"%.1f", currentCornerRadius]
                                            inputPlaceholder:@"0.1-1.0之间的数值"
                                           valueChangedBlock:^(NSString *value) {
        float cornerRadius = [value floatValue];
        if (cornerRadius < 0.1) cornerRadius = 0.1;
        if (cornerRadius > 1.0) cornerRadius = 1.0;
        [defaults setFloat:cornerRadius forKey:kAvatarCornerRadiusKey];
        [defaults synchronize];
        
        // 显示提示对话框，提供立即重启和稍后重启选项
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                 message:@"圆角程度设置已保存，需要重启微信才能生效。数值越大头像越圆，1.0为完全圆形。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        // 稍后重启选项
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启" 
                                                           style:UIAlertActionStyleDefault 
                                                         handler:nil];
        [alertController addAction:laterAction];
        
        // 立即重启选项
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启" 
                                                             style:UIAlertActionStyleDestructive 
                                                           handler:^(UIAlertAction * _Nonnull action) {
            // 使用exit(0)立即重启
            exit(0);
        }];
        [alertController addAction:restartAction];
        
        // 显示对话框
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    
    if (self.isRoundAvatarEnabled) {
        CSSettingSection *cornerRadiusSection = [CSSettingSection sectionWithHeader:@"圆角大小设置" 
                                                                           items:@[self.cornerRadiusItem]];
        [sectionsArray addObject:cornerRadiusSection];
    }
    
    // 6. 创建头像旋转分区
    CSSettingItem *rotateAvatarItem = [CSSettingItem switchItemWithTitle:@"头像旋转"
                                                              iconName:@"arrow.clockwise.circle"
                                                             iconColor:[UIColor systemPurpleColor]
                                                           switchValue:self.isRotateEnabled
                                                      valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kRotateAvatarKey];
        [defaults synchronize];
        
        // 更新旋转状态
        weakSelf.isRotateEnabled = isOn;
        
        // 更新旋转速度分区的显示状态
        [weakSelf updateRotateSpeedSection];
        
        // 显示提示对话框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                message:@"头像旋转设置已保存，需要重启刷新缓存才能生效。"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
        
        // 稍后重启选项
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启" 
                                                             style:UIAlertActionStyleDefault 
                                                           handler:nil];
        [alertController addAction:laterAction];
        
        // 立即重启选项
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启" 
                                                              style:UIAlertActionStyleDestructive 
                                                            handler:^(UIAlertAction * _Nonnull action) {
            // 使用exit(0)立即重启
            exit(0);
        }];
        [alertController addAction:restartAction];
        
        // 显示对话框
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    
    CSSettingSection *rotateAvatarSection = [CSSettingSection sectionWithHeader:@"旋转功能" 
                                                                    items:@[rotateAvatarItem]];
    [sectionsArray addObject:rotateAvatarSection];
    
    // 7. 创建旋转速度设置项
    float currentSpeed = [defaults floatForKey:kRotateSpeedKey];
    if (currentSpeed == 0) currentSpeed = 5;
    
    self.rotateSpeedItem = [CSSettingItem inputItemWithTitle:@"旋转速度"
                                                  iconName:@"speedometer"
                                                 iconColor:[UIColor systemOrangeColor]
                                                inputValue:[NSString stringWithFormat:@"%.1f", currentSpeed]
                                          inputPlaceholder:@"1-10之间的数值"
                                         valueChangedBlock:^(NSString *value) {
        float speed = [value floatValue];
        if (speed < 1) speed = 1;
        if (speed > 10) speed = 10;
        [defaults setFloat:speed forKey:kRotateSpeedKey];
        [defaults synchronize];
        
        // 显示提示对话框，提供立即重启和稍后重启选项
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                message:@"旋转速度设置已保存，需要重启微信才能生效。"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
        
        // 稍后重启选项
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启" 
                                                           style:UIAlertActionStyleDefault 
                                                         handler:nil];
        [alertController addAction:laterAction];
        
        // 立即重启选项
        UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"立即重启" 
                                                             style:UIAlertActionStyleDestructive 
                                                           handler:^(UIAlertAction * _Nonnull action) {
            // 使用exit(0)立即重启
            exit(0);
        }];
        [alertController addAction:restartAction];
        
        // 显示对话框
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    
    // 添加旋转速度分区（仅在旋转功能开启时显示）
    if (self.isRotateEnabled) {
        CSSettingSection *rotateSpeedSection = [CSSettingSection sectionWithHeader:@"旋转速度设置" 
                                                                        items:@[self.rotateSpeedItem]];
        [sectionsArray addObject:rotateSpeedSection];
    }
    
    // 设置分区数组
    self.sections = sectionsArray;
}

// 更新某个分区的开关状态，以保持一致性
- (void)updateSectionWithItems:(NSMutableArray *)items atIndex:(NSInteger)sectionIndex {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSString *prefix = nil;
    
    // 根据分区索引确定前缀
    if (sectionIndex == 0) { // 私聊
        prefix = @"InPrivateChat";
    } else if (sectionIndex == 1) { // 群聊
        prefix = @"InGroupChat";
    } else if (sectionIndex == 2) { // 公众号
        prefix = @"InOfficialAccount";
    }
    
    // 如果找不到前缀，直接返回
    if (!prefix) return;
    
    // 获取当前开关状态
    BOOL otherState = [defaults boolForKey:[@"hideOtherAvatar" stringByAppendingString:prefix]];
    BOOL selfState = [defaults boolForKey:[@"hideSelfAvatar" stringByAppendingString:prefix]];
    BOOL bothState = [defaults boolForKey:[@"hideBothAvatar" stringByAppendingString:prefix]];
    
    // 更新开关项
    for (CSSettingItem *item in items) {
        if ([item.title isEqualToString:@"隐藏对方头像"]) {
            item.switchValue = otherState;
        } else if ([item.title isEqualToString:@"隐藏自己头像"]) {
            item.switchValue = selfState;
        } else if ([item.title isEqualToString:@"隐藏双方头像"]) {
            item.switchValue = bothState;
        }
    }
    
    // 更新表格视图
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
}

// 更新圆角大小分区
- (void)updateCornerRadiusSection {
    NSMutableArray *newSections = [NSMutableArray arrayWithArray:self.sections];
    
    // 查找圆角大小分区的索引
    NSInteger cornerRadiusSectionIndex = -1;
    for (NSInteger i = 0; i < newSections.count; i++) {
        CSSettingSection *section = newSections[i];
        if ([section.header isEqualToString:@"圆角大小设置"]) {
            cornerRadiusSectionIndex = i;
            break;
        }
    }
    
    // 如果圆形头像功能开启，但没有圆角大小分区，则添加
    if (self.isRoundAvatarEnabled && cornerRadiusSectionIndex == -1) {
        CSSettingSection *cornerRadiusSection = [CSSettingSection sectionWithHeader:@"圆角大小设置" 
                                                                             items:@[self.cornerRadiusItem]];
        // 查找头像形状分区的索引
        NSInteger avatarShapeSectionIndex = -1;
        for (NSInteger i = 0; i < newSections.count; i++) {
            CSSettingSection *section = newSections[i];
            if ([section.header isEqualToString:@"头像形状设置"]) {
                avatarShapeSectionIndex = i;
                break;
            }
        }
        
        if (avatarShapeSectionIndex != -1) {
            [newSections insertObject:cornerRadiusSection atIndex:avatarShapeSectionIndex + 1];
            self.sections = newSections;
            
            // 无动画更新表格
            [self.tableView reloadData];
        }
    }
    // 如果圆形头像功能关闭，但有圆角大小分区，则移除
    else if (!self.isRoundAvatarEnabled && cornerRadiusSectionIndex != -1) {
        [newSections removeObjectAtIndex:cornerRadiusSectionIndex];
        self.sections = newSections;
        
        // 无动画更新表格
        [self.tableView reloadData];
    }
}

// 更新旋转速度分区
- (void)updateRotateSpeedSection {
    NSMutableArray *newSections = [NSMutableArray arrayWithArray:self.sections];
    
    // 查找旋转速度分区的索引
    NSInteger rotateSpeedSectionIndex = -1;
    for (NSInteger i = 0; i < newSections.count; i++) {
        CSSettingSection *section = newSections[i];
        if ([section.header isEqualToString:@"旋转速度设置"]) {
            rotateSpeedSectionIndex = i;
            break;
        }
    }
    
    // 如果旋转功能开启，但没有旋转速度分区，则添加
    if (self.isRotateEnabled && rotateSpeedSectionIndex == -1) {
        CSSettingSection *rotateSpeedSection = [CSSettingSection sectionWithHeader:@"旋转速度设置" 
                                                                         items:@[self.rotateSpeedItem]];
        // 插入到旋转功能分区之后
        NSInteger rotateSectionIndex = -1;
        for (NSInteger i = 0; i < newSections.count; i++) {
            CSSettingSection *section = newSections[i];
            if ([section.header isEqualToString:@"旋转功能"]) {
                rotateSectionIndex = i;
                break;
            }
        }
        
        if (rotateSectionIndex != -1) {
            [newSections insertObject:rotateSpeedSection atIndex:rotateSectionIndex + 1];
            self.sections = newSections;
            
            // 无动画更新表格
            [self.tableView reloadData];
        }
    }
    // 如果旋转功能关闭，但有旋转速度分区，则移除
    else if (!self.isRotateEnabled && rotateSpeedSectionIndex != -1) {
        [newSections removeObjectAtIndex:rotateSpeedSectionIndex];
        self.sections = newSections;
        
        // 无动画更新表格
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CSSettingTableViewCell reuseIdentifier]];
    
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    [cell configureWithItem:item];
    
    // 重要：设置所有单元格的详情文本跟随标题显示，而不是靠右对齐
    cell.shouldAlignRight = NO;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    if (item.itemType == CSSettingItemTypeInput) {
        [CSUIHelper showInputAlertWithTitle:item.title
                                  message:nil
                             initialValue:item.inputValue
                             placeholder:item.inputPlaceholder
                        inViewController:self
                             completion:^(NSString *value) {
            item.inputValue = value;
            if (item.inputValueChanged) {
                item.inputValueChanged(value);
            }
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

@end 