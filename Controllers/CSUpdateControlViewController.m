#import "CSUpdateControlViewController.h"
#import "CSSettingTableViewCell.h"

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

@interface CSUpdateControlViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *disableSettings;
@end

@implementation CSUpdateControlViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"热更新控制";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    // 设置表格样式
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 加载设置
    [self loadDisableSettings];
    
    // 检查总开关状态
    [self updateAllFunctionsState];
    
    // 设置数据
    [self setupSections];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 刷新数据
    [self loadDisableSettings];
    [self updateAllFunctionsState];
    [self setupSections];
    
    // 刷新表格
    [self.tableView reloadData];
}

#pragma mark - Setup Methods

- (void)loadDisableSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.disableSettings = [NSMutableDictionary dictionary];
    
    // 加载所有设置项
    [self.disableSettings setObject:@([defaults boolForKey:kDisableLoadMainUpdateBundleKey]) forKey:kDisableLoadMainUpdateBundleKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableForceUpdateKey]) forKey:kDisableForceUpdateKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableUnzipBundleUpdatesKey]) forKey:kDisableUnzipBundleUpdatesKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableUnzipDownloadUpdatesKey]) forKey:kDisableUnzipDownloadUpdatesKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableLoadAndExecuteKey]) forKey:kDisableLoadAndExecuteKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableRegisterUpdateKey]) forKey:kDisableRegisterUpdateKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableTryRegisterUpdateKey]) forKey:kDisableTryRegisterUpdateKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableOnPResUpdateFinishKey]) forKey:kDisableOnPResUpdateFinishKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableTryRenameTmpUpdateDataDirKey]) forKey:kDisableTryRenameTmpUpdateDataDirKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableLoadResourceKey]) forKey:kDisableLoadResourceKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableLoadPluginInBundleKey]) forKey:kDisableLoadPluginInBundleKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableLoadBundleKey]) forKey:kDisableLoadBundleKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableShouldTraceKey]) forKey:kDisableShouldTraceKey];
    [self.disableSettings setObject:@([defaults boolForKey:kDisableImmediateRenameUpdateKey]) forKey:kDisableImmediateRenameUpdateKey];
    [self.disableSettings setObject:@([defaults boolForKey:kAllUpdateFunctionsDisabledKey]) forKey:kAllUpdateFunctionsDisabledKey];
}

- (void)saveDisableSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (NSString *key in self.disableSettings) {
        [defaults setBool:[self.disableSettings[key] boolValue] forKey:key];
    }
    
    [defaults synchronize];
}

- (void)setupSections {
    // 创建主开关部分
    CSSettingItem *allFunctionsItem = [CSSettingItem switchItemWithTitle:@"禁用所有热更新功能"
                                                             iconName:@"xmark.shield.fill"
                                                            iconColor:[UIColor systemRedColor]
                                                           switchValue:[self.disableSettings[kAllUpdateFunctionsDisabledKey] boolValue]
                                                      valueChangedBlock:^(BOOL isOn) {
        // 更新主开关状态
        [self.disableSettings setObject:@(isOn) forKey:kAllUpdateFunctionsDisabledKey];
        
        // 设置所有子开关状态
        [self setAllFunctionsDisabled:isOn];
        
        // 保存设置并重建数据
        [self saveDisableSettings];
        
        // 显示重启提示
        [self showRestartAlert];
    }];
    
    CSSettingSection *mainSection = [CSSettingSection sectionWithHeader:@"全局设置" items:@[allFunctionsItem]];
    
    // 创建基本功能部分
    CSSettingItem *loadMainUpdateBundleItem = [CSSettingItem switchItemWithTitle:@"阻止加载主更新包"
                                                                     iconName:@"arrow.down.doc.fill"
                                                                    iconColor:[UIColor systemBlueColor]
                                                                   switchValue:[self.disableSettings[kDisableLoadMainUpdateBundleKey] boolValue]
                                                              valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableLoadMainUpdateBundleKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *forceUpdateItem = [CSSettingItem switchItemWithTitle:@"阻止强制更新"
                                                              iconName:@"arrow.clockwise.circle.fill"
                                                             iconColor:[UIColor systemGreenColor]
                                                            switchValue:[self.disableSettings[kDisableForceUpdateKey] boolValue]
                                                       valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableForceUpdateKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *unzipBundleUpdatesItem = [CSSettingItem switchItemWithTitle:@"阻止解压更新包"
                                                                    iconName:@"archivebox.fill"
                                                                   iconColor:[UIColor systemOrangeColor]
                                                                  switchValue:[self.disableSettings[kDisableUnzipBundleUpdatesKey] boolValue]
                                                             valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableUnzipBundleUpdatesKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *unzipDownloadUpdatesItem = [CSSettingItem switchItemWithTitle:@"阻止解压下载的更新"
                                                                      iconName:@"doc.zipper"
                                                                     iconColor:[UIColor systemPurpleColor]
                                                                    switchValue:[self.disableSettings[kDisableUnzipDownloadUpdatesKey] boolValue]
                                                               valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableUnzipDownloadUpdatesKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingSection *basicSection = [CSSettingSection sectionWithHeader:@"基本功能" 
                                                                items:@[loadMainUpdateBundleItem,
                                                                      forceUpdateItem,
                                                                      unzipBundleUpdatesItem,
                                                                      unzipDownloadUpdatesItem]];
    
    // 创建执行部分
    CSSettingItem *loadAndExecuteItem = [CSSettingItem switchItemWithTitle:@"阻止加载并执行更新"
                                                                iconName:@"play.fill"
                                                               iconColor:[UIColor systemTealColor]
                                                              switchValue:[self.disableSettings[kDisableLoadAndExecuteKey] boolValue]
                                                         valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableLoadAndExecuteKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *registerUpdateItem = [CSSettingItem switchItemWithTitle:@"阻止注册更新"
                                                                iconName:@"square.and.pencil"
                                                               iconColor:[UIColor systemYellowColor]
                                                              switchValue:[self.disableSettings[kDisableRegisterUpdateKey] boolValue]
                                                         valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableRegisterUpdateKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *tryRegisterUpdateItem = [CSSettingItem switchItemWithTitle:@"阻止尝试注册更新"
                                                                   iconName:@"square.and.pencil.circle.fill"
                                                                  iconColor:[UIColor systemPinkColor]
                                                                 switchValue:[self.disableSettings[kDisableTryRegisterUpdateKey] boolValue]
                                                            valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableTryRegisterUpdateKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *onPResUpdateFinishItem = [CSSettingItem switchItemWithTitle:@"阻止更新资源完成回调"
                                                                    iconName:@"checkmark.circle.fill"
                                                                   iconColor:[UIColor systemIndigoColor]
                                                                  switchValue:[self.disableSettings[kDisableOnPResUpdateFinishKey] boolValue]
                                                             valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableOnPResUpdateFinishKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingSection *executeSection = [CSSettingSection sectionWithHeader:@"执行控制" 
                                                                 items:@[loadAndExecuteItem,
                                                                        registerUpdateItem,
                                                                        tryRegisterUpdateItem,
                                                                        onPResUpdateFinishItem]];
    
    // 创建高级功能部分
    CSSettingItem *tryRenameTmpUpdateDataDirItem = [CSSettingItem switchItemWithTitle:@"阻止重命名临时更新目录"
                                                                          iconName:@"folder.fill"
                                                                         iconColor:[UIColor systemBrownColor]
                                                                        switchValue:[self.disableSettings[kDisableTryRenameTmpUpdateDataDirKey] boolValue]
                                                                   valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableTryRenameTmpUpdateDataDirKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *loadResourceItem = [CSSettingItem switchItemWithTitle:@"阻止加载资源"
                                                               iconName:@"photo.fill"
                                                              iconColor:[UIColor systemRedColor]
                                                             switchValue:[self.disableSettings[kDisableLoadResourceKey] boolValue]
                                                        valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableLoadResourceKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *loadPluginInBundleItem = [CSSettingItem switchItemWithTitle:@"阻止加载插件"
                                                                    iconName:@"puzzlepiece.fill"
                                                                   iconColor:[UIColor systemGrayColor]
                                                                  switchValue:[self.disableSettings[kDisableLoadPluginInBundleKey] boolValue]
                                                             valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableLoadPluginInBundleKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *loadBundleItem = [CSSettingItem switchItemWithTitle:@"阻止加载bundle"
                                                             iconName:@"cube.fill"
                                                            iconColor:[UIColor darkGrayColor]
                                                           switchValue:[self.disableSettings[kDisableLoadBundleKey] boolValue]
                                                      valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableLoadBundleKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *shouldTraceItem = [CSSettingItem switchItemWithTitle:@"阻止追踪"
                                                              iconName:@"binoculars.fill"
                                                             iconColor:[UIColor systemGreenColor]
                                                            switchValue:[self.disableSettings[kDisableShouldTraceKey] boolValue]
                                                       valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableShouldTraceKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingItem *immediateRenameUpdateItem = [CSSettingItem switchItemWithTitle:@"阻止立即重命名更新"
                                                                       iconName:@"tag.fill"
                                                                      iconColor:[UIColor systemOrangeColor]
                                                                     switchValue:[self.disableSettings[kDisableImmediateRenameUpdateKey] boolValue]
                                                                valueChangedBlock:^(BOOL isOn) {
        [self.disableSettings setObject:@(isOn) forKey:kDisableImmediateRenameUpdateKey];
        [self saveDisableSettings];
        [self updateAllFunctionsState];
        [self showRestartAlert];
    }];
    
    CSSettingSection *advancedSection = [CSSettingSection sectionWithHeader:@"高级控制" 
                                                                   items:@[tryRenameTmpUpdateDataDirItem,
                                                                          loadResourceItem,
                                                                          loadPluginInBundleItem,
                                                                          loadBundleItem,
                                                                          shouldTraceItem,
                                                                          immediateRenameUpdateItem]];
    
    self.sections = @[mainSection, basicSection, executeSection, advancedSection];
}

#pragma mark - Helper Methods

- (void)setAllFunctionsDisabled:(BOOL)disabled {
    // 1. 更新所有设置项的值
    [self.disableSettings setObject:@(disabled) forKey:kDisableLoadMainUpdateBundleKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableForceUpdateKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableUnzipBundleUpdatesKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableUnzipDownloadUpdatesKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableLoadAndExecuteKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableRegisterUpdateKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableTryRegisterUpdateKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableOnPResUpdateFinishKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableTryRenameTmpUpdateDataDirKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableLoadResourceKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableLoadPluginInBundleKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableLoadBundleKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableShouldTraceKey];
    [self.disableSettings setObject:@(disabled) forKey:kDisableImmediateRenameUpdateKey];
    
    // 2. 遍历更新所有CSSettingItem对象的状态
    for (NSInteger section = 1; section < self.sections.count; section++) {
        CSSettingSection *settingSection = self.sections[section];
        NSArray<CSSettingItem *> *items = settingSection.items;
        
        for (CSSettingItem *item in items) {
            if (item.itemType == CSSettingItemTypeSwitch) {
                item.switchValue = disabled;
            }
        }
    }
    
    // 3. 如果所有section都已加载，更新UI
    if (self.isViewLoaded && self.sections.count > 1) {
        // 刷新整个表格
        [self.tableView reloadData];
    }
}

- (void)updateAllFunctionsState {
    // 检查是否所有功能都已禁用
    BOOL allDisabled = [self.disableSettings[kDisableLoadMainUpdateBundleKey] boolValue] &&
                       [self.disableSettings[kDisableForceUpdateKey] boolValue] &&
                       [self.disableSettings[kDisableUnzipBundleUpdatesKey] boolValue] &&
                       [self.disableSettings[kDisableUnzipDownloadUpdatesKey] boolValue] &&
                       [self.disableSettings[kDisableLoadAndExecuteKey] boolValue] &&
                       [self.disableSettings[kDisableRegisterUpdateKey] boolValue] &&
                       [self.disableSettings[kDisableTryRegisterUpdateKey] boolValue] &&
                       [self.disableSettings[kDisableOnPResUpdateFinishKey] boolValue] &&
                       [self.disableSettings[kDisableTryRenameTmpUpdateDataDirKey] boolValue] &&
                       [self.disableSettings[kDisableLoadResourceKey] boolValue] &&
                       [self.disableSettings[kDisableLoadPluginInBundleKey] boolValue] &&
                       [self.disableSettings[kDisableLoadBundleKey] boolValue] &&
                       [self.disableSettings[kDisableShouldTraceKey] boolValue] &&
                       [self.disableSettings[kDisableImmediateRenameUpdateKey] boolValue];
    
    // 更新总开关状态
    [self.disableSettings setObject:@(allDisabled) forKey:kAllUpdateFunctionsDisabledKey];
    
    // 更新主开关的CSSettingItem对象状态
    if (self.sections.count > 0) {
        CSSettingSection *mainSection = self.sections[0];
        if (mainSection.items.count > 0) {
            CSSettingItem *allFunctionsItem = mainSection.items[0];
            allFunctionsItem.switchValue = allDisabled;
        }
    }
    
    // 刷新主开关所在的section
    if (self.isViewLoaded) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
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
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 使用secondarySystemGroupedBackgroundColor来获得正确的深色模式下的背景色
    if (@available(iOS 13.0, *)) {
        cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (void)showRestartAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重启提示"
                                                                 message:@"修改设置后需要重启微信才能生效。是否立即重启？"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加立即重启选项
    UIAlertAction *restartNowAction = [UIAlertAction actionWithTitle:@"立即重启"
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction * _Nonnull action) {
        // 使用exit(0)终止应用程序，强制重启
        exit(0);
    }];
    
    // 添加稍后重启选项
    UIAlertAction *restartLaterAction = [UIAlertAction actionWithTitle:@"稍后重启"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
    
    [alert addAction:restartNowAction];
    [alert addAction:restartLaterAction];
    
    // 在iPad上处理兼容性 - 提示框不会自动消失
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 0, 0);
        alert.popoverPresentationController.permittedArrowDirections = 0;
    }
    
    // 避免重复显示弹窗
    if (!self.presentedViewController) {
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// 添加setupData方法，确保总开关状态与子开关同步
- (void)setupData {
    // 保存所有设置
    [self saveDisableSettings];
    
    // 重新检查总开关状态
    [self updateAllFunctionsState];
    
    // 重新构建sections数据，确保所有开关状态一致
    [self setupSections];
    
    // 刷新整个表格
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

@end 