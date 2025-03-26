#import "CSVersionSettingsViewController.h"
#import "CSSettingTableViewCell.h"

// 版本设置的键
static NSString * const kWeChatVersionKey = @"com.wechat.tweak.version.selected";
static NSString * const kWeChatCustomVersionKey = @"com.wechat.tweak.version.custom"; // 自定义版本的键

@interface CSVersionSettingsViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, assign) BOOL isCustomVersionEnabled; // 是否启用自定义版本
@property (nonatomic, strong) NSString *customVersionString; // 自定义版本值
@property (nonatomic, assign) BOOL isCustomSectionExpanded; // 自定义版本区域是否展开
@end

@implementation CSVersionSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"版本控制";
    
    // 注册cell
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 设置UI样式
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // 获取当前选中的版本（不设置默认值）
    NSInteger currentVersion = [[NSUserDefaults standardUserDefaults] integerForKey:kWeChatVersionKey];
    
    // 获取自定义版本设置
    self.isCustomVersionEnabled = (currentVersion == 0) ? NO : (currentVersion < 0);
    self.customVersionString = [[NSUserDefaults standardUserDefaults] stringForKey:kWeChatCustomVersionKey] ?: @"";
    
    // 当有自定义版本时默认展开
    self.isCustomSectionExpanded = self.isCustomVersionEnabled;
    
    // 创建版本选项
    NSArray *versionItems = @[
        [self createVersionItemWithTitle:@"微信 8.0.31"
                              iconName:@"checkmark.circle.fill"
                             iconColor:[UIColor systemBlueColor]
                            versionCode:402661175
                         currentVersion:currentVersion],
        
        [self createVersionItemWithTitle:@"微信 8.0.33"
                              iconName:@"checkmark.circle.fill"
                             iconColor:[UIColor systemGreenColor]
                            versionCode:402661664
                         currentVersion:currentVersion],
        
        [self createVersionItemWithTitle:@"微信 8.0.49"
                              iconName:@"checkmark.circle.fill"
                             iconColor:[UIColor systemOrangeColor]
                            versionCode:402665783
                         currentVersion:currentVersion],
        
        [self createVersionItemWithTitle:@"微信 8.0.56"
                              iconName:@"checkmark.circle.fill"
                             iconColor:[UIColor systemRedColor]
                            versionCode:402667568
                         currentVersion:currentVersion],
        
        [self createVersionItemWithTitle:@"微信 8.0.57"
                              iconName:@"checkmark.circle.fill"
                             iconColor:[UIColor systemTealColor]
                            versionCode:402667810
                         currentVersion:currentVersion]
    ];
    
    // 创建自定义版本开关项
    CSSettingItem *customVersionToggle = [CSSettingItem switchItemWithTitle:@"使用自定义版本号"
                                                             iconName:@"gear.circle.fill"
                                                            iconColor:[UIColor systemPurpleColor]
                                                           switchValue:self.isCustomVersionEnabled
                                                      valueChangedBlock:^(BOOL isOn) {
        // 更新展开状态
        self.isCustomSectionExpanded = isOn;
        
        if (isOn) {
            // 如果已有自定义版本号，直接启用它
            if (self.customVersionString.length > 0) {
                [self enableCustomVersion:self.customVersionString];
            } else {
                // 否则提示用户输入
                [self showCustomVersionInputAlert];
            }
        } else {
            // 关闭自定义版本
            [self disableCustomVersion];
        }
    }];
    
    // 创建自定义版本输入项（只有当开关打开时才显示）
    CSSettingItem *customVersionInput = [CSSettingItem actionItemWithTitle:@"自定义版本号值"
                                                             iconName:@"number"
                                                            iconColor:[UIColor systemIndigoColor]];
    
    // 设置详情文本显示当前值
    if (self.customVersionString.length > 0) {
        customVersionInput.detail = self.customVersionString;
    } else {
        customVersionInput.detail = @"点击设置";
    }
    
    // 创建自定义版本区域项目数组
    NSMutableArray *customItems = [NSMutableArray arrayWithObject:customVersionToggle];
    
    // 创建说明项
    CSSettingItem *infoItem = [CSSettingItem itemWithTitle:@"功能说明"
                                                 iconName:@"info.circle"
                                                iconColor:[UIColor systemBlueColor]
                                                   detail:nil];
    
    // 设置sections
    self.sections = @[
        [CSSettingSection sectionWithHeader:@"选择微信版本" items:versionItems],
        [CSSettingSection sectionWithHeader:@"自定义版本" items:customItems],
        [CSSettingSection sectionWithHeader:@"说明" items:@[infoItem]]
    ];
    
    // 根据展开状态更新
    [self updateCustomVersionSectionItems];
}

// 更新自定义版本区域的项目
- (void)updateCustomVersionSectionItems {
    CSSettingSection *customSection = self.sections[1];
    NSMutableArray *items = [NSMutableArray arrayWithArray:customSection.items];
    
    // 检查是否需要添加输入项
    if (self.isCustomSectionExpanded) {
        // 如果已展开但不足两项，添加输入项
        if (items.count < 2) {
            // 创建输入项
            CSSettingItem *inputItem = [CSSettingItem actionItemWithTitle:@"版本号值" 
                                                           iconName:@"number" 
                                                          iconColor:[UIColor systemIndigoColor]];
            
            // 设置详情文本
            if (self.customVersionString.length > 0) {
                inputItem.detail = self.customVersionString;
            } else {
                inputItem.detail = @"点击设置";
            }
            
            [items addObject:inputItem];
        } else {
            // 已有输入项，更新其详情文本
            CSSettingItem *inputItem = items[1];
            if (self.customVersionString.length > 0) {
                inputItem.detail = self.customVersionString;
            } else {
                inputItem.detail = @"点击设置";
            }
        }
    } else {
        // 如果未展开但有超过一项，移除多余项
        if (items.count > 1) {
            [items removeObjectsInRange:NSMakeRange(1, items.count - 1)];
        }
    }
    
    // 更新区域的项目
    NSMutableArray *updatedSections = [NSMutableArray arrayWithArray:self.sections];
    updatedSections[1] = [CSSettingSection sectionWithHeader:customSection.header items:items];
    self.sections = updatedSections;
    
    // 更新表格
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CSSettingItem *)createVersionItemWithTitle:(NSString *)title
                                    iconName:(NSString *)iconName
                                   iconColor:(UIColor *)iconColor
                                  versionCode:(NSInteger)versionCode
                               currentVersion:(NSInteger)currentVersion {
    __weak typeof(self) weakSelf = self;
    return [CSSettingItem switchItemWithTitle:title
                                    iconName:iconName
                                   iconColor:iconColor
                                  switchValue:(currentVersion == versionCode)
                             valueChangedBlock:^(BOOL isOn) {
        // 无论开启还是关闭，都更新版本设置
        NSInteger newVersion = isOn ? versionCode : 0;  // 关闭时设为0
        
        // 保存设置
        [[NSUserDefaults standardUserDefaults] setInteger:newVersion forKey:kWeChatVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChat.Version.Changed" 
                                                          object:nil 
                                                        userInfo:@{@"version": @(newVersion)}];
        
        // 更新其他开关状态
        [weakSelf deselectAllVersionsExcept:newVersion];
        
        // 刷新UI
        [weakSelf.tableView reloadData];
        
        // 显示重启提示
        if (isOn) {
            [weakSelf showRestartAlert];
        }
    }];
}

// 显示自定义版本输入弹窗
- (void)showCustomVersionInputAlert {
    [CSUIHelper showInputAlertWithTitle:@"输入自定义版本号"
                               message:@"请输入版本号数字（如40XXXXX75）"
                          initialValue:self.customVersionString
                          placeholder:@"例如：40XXXXX75"
                     inViewController:self
                           completion:^(NSString *value) {
        if (value.length > 0) {
            // 确保输入是数字
            NSScanner *scanner = [NSScanner scannerWithString:value];
            long long version;
            if ([scanner scanLongLong:&version] && scanner.isAtEnd) {
                // 有效的数字输入
                [self enableCustomVersion:value];
            } else {
                // 无效的数字输入，显示错误
                [self showErrorAlert:@"请输入有效的数字"];
                
                // 如果没有之前的版本号，则关闭开关
                if (self.customVersionString.length == 0) {
                    self.isCustomVersionEnabled = NO;
                    self.isCustomSectionExpanded = NO;
                    [self updateCustomVersionSectionItems];
                }
            }
        } else {
            // 输入为空，关闭开关
            self.isCustomVersionEnabled = NO;
            self.isCustomSectionExpanded = NO;
            [self updateCustomVersionSectionItems];
        }
    }];
}

// 启用自定义版本
- (void)enableCustomVersion:(NSString *)versionText {
    // 有效的数字输入
    self.customVersionString = versionText;
    self.isCustomVersionEnabled = YES;
    
    // 将自定义版本字符串转换为数字
    long long version = [versionText longLongValue];
    
    // 使用负值存储表示这是自定义值
    long long customVersionValue = -version;
    
    // 保存设置
    [[NSUserDefaults standardUserDefaults] setInteger:customVersionValue forKey:kWeChatVersionKey];
    [[NSUserDefaults standardUserDefaults] setObject:versionText forKey:kWeChatCustomVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChat.Version.Changed" 
                                                      object:nil 
                                                    userInfo:@{@"version": @(version)}];
    
    // 更新其他开关状态
    [self deselectAllVersionsExcept:customVersionValue];
    
    // 更新自定义版本区域
    [self updateCustomVersionSectionItems];
    
    // 刷新UI
    [self.tableView reloadData];
    
    // 显示重启提示
    [self showRestartAlert];
}

// 关闭自定义版本
- (void)disableCustomVersion {
    self.isCustomVersionEnabled = NO;
    
    // 重置版本设置
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kWeChatVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChat.Version.Changed" 
                                                      object:nil 
                                                    userInfo:@{@"version": @(0)}];
    
    // 更新其他开关状态
    [self deselectAllVersionsExcept:0];
    
    // 更新自定义版本区域
    [self updateCustomVersionSectionItems];
    
    // 刷新UI
    [self.tableView reloadData];
}

// 显示错误提示
- (void)showErrorAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"输入错误"
                        message:message
                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction
        actionWithTitle:@"确定"
                 style:UIAlertActionStyleDefault
               handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 关闭其他开关
- (void)deselectAllVersionsExcept:(NSInteger)selectedVersion {
    // 更新版本区域的开关状态
    CSSettingSection *versionSection = self.sections[0];
    for (CSSettingItem *item in versionSection.items) {
        if (item.itemType == CSSettingItemTypeSwitch) {
            NSInteger version = [self versionCodeFromTitle:item.title];
            item.switchValue = (version == selectedVersion);
        }
    }
    
    // 更新自定义版本开关状态
    CSSettingSection *customSection = self.sections[1];
    CSSettingItem *toggleItem = customSection.items.firstObject;
    if (toggleItem.itemType == CSSettingItemTypeSwitch) {
        toggleItem.switchValue = (selectedVersion < 0);
    }
    
    // 更新状态属性
    self.isCustomVersionEnabled = (selectedVersion < 0);
    self.isCustomSectionExpanded = self.isCustomVersionEnabled;
    
    // 更新自定义版本区域
    [self updateCustomVersionSectionItems];
}

// 修改重启提示方法
- (void)showRestartAlert {
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"版本设置已更改"
                         message:@"需要重启微信使设置生效"
                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction 
        actionWithTitle:@"稍后重启"
                  style:UIAlertActionStyleCancel
                handler:nil]];
    
    [alert addAction:[UIAlertAction 
        actionWithTitle:@"立即重启"
                  style:UIAlertActionStyleDestructive
                handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 从标题中提取版本代码
- (NSInteger)versionCodeFromTitle:(NSString *)title {
    if ([title containsString:@"8.0.31"]) return 402661175;
    if ([title containsString:@"8.0.33"]) return 402661664;
    if ([title containsString:@"8.0.49"]) return 402665783;
    if ([title containsString:@"8.0.56"]) return 402667568;
    if ([title containsString:@"8.0.57"]) return 402667810;
    return 0;
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
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return self.isCustomVersionEnabled 
            ? [NSString stringWithFormat:@"当前使用自定义版本号: %@", self.customVersionString] 
            : @"开启后可输入自定义版本号";
    }
    
    if (section == 0) {
        return @"选择版本后需要重启微信才能生效";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 处理自定义版本输入项点击
    if (indexPath.section == 1 && indexPath.row > 0) {
        [self showCustomVersionInputAlert];
        return;
    }
    
    // 处理功能说明点击
    if (indexPath.section == 2 && indexPath.row == 0) {
        UIAlertController *alertController = [UIAlertController 
            alertControllerWithTitle:@"版本控制说明"
                            message:@"1. 此功能用于控制微信显示的版本号\n\n"
                                   "2. 选择版本后需要重启微信才能生效\n\n"
                                   "3. 如果不选择任何版本，将使用微信原始版本号\n\n"
                                   "4. 您也可以开启自定义版本号功能输入任意版本\n\n"
                                   "5. 自定义版本号与预设版本互斥，不能同时启用"
                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction 
            actionWithTitle:@"了解了"
                    style:UIAlertActionStyleDefault
                  handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
