#import "CSEntrySettingsViewController.h"
#import <stdlib.h>

// 用户默认设置键
static NSString * const kEntryDisplayModeKey = @"com.wechat.tweak.entry.display.mode";
static NSString * const kEntryCustomTitleKey = @"com.wechat.tweak.entry.custom.title";
static NSString * const kEntrySettingsChangedNotification = @"com.wechat.tweak.entry.settings.changed";

// 新增单独的开关键
static NSString * const kEntryShowInMoreKey = @"com.wechat.tweak.entry.show.in.more";
static NSString * const kEntryShowInPluginKey = @"com.wechat.tweak.entry.show.in.plugin";

@interface CSEntrySettingsViewController ()

// 设置项和分区
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) CSSettingItem *customTitleItem;

// 新增开关设置项
@property (nonatomic, strong) CSSettingItem *showInMoreItem;
@property (nonatomic, strong) CSSettingItem *showInPluginItem;

// 标题
@property (nonatomic, copy) NSString *customTitle;

@end

@implementation CSEntrySettingsViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"入口设置";
    
    // 配置表格视图
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 加载当前设置
    [self loadCurrentSettings];
    
    // 设置界面数据
    [self setupData];
}

#pragma mark - 私有方法

// 加载当前设置
- (void)loadCurrentSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 设置模式（默认为设置页面）
    CSEntryDisplayMode displayMode = [defaults integerForKey:kEntryDisplayModeKey];
    
    // 根据之前的显示模式设置单独的开关状态
    BOOL showInMore = NO;
    BOOL showInPlugin = NO;
    
    switch (displayMode) {
        case CSEntryDisplayModeMore:
            showInMore = YES;
            showInPlugin = NO;
            break;
        case CSEntryDisplayModePlugin:
            showInMore = NO;
            showInPlugin = YES;
            break;
        case CSEntryDisplayModeBoth:
            showInMore = YES;
            showInPlugin = YES;
            break;
        default:
            showInMore = YES;
            showInPlugin = NO;
            break;
    }
    
    // 如果是首次使用，保存默认设置
    if (![defaults objectForKey:kEntryShowInMoreKey]) {
        [defaults setBool:showInMore forKey:kEntryShowInMoreKey];
    }
    
    if (![defaults objectForKey:kEntryShowInPluginKey]) {
        [defaults setBool:showInPlugin forKey:kEntryShowInPluginKey];
    }
    
    // 自定义标题
    self.customTitle = [defaults stringForKey:kEntryCustomTitleKey];
    if (!self.customTitle) {
        self.customTitle = @"Wechat";
    }
}

// 保存设置并发送通知
- (void)saveSettingsAndNotify {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 获取开关状态
    BOOL showInMore = [defaults boolForKey:kEntryShowInMoreKey];
    BOOL showInPlugin = [defaults boolForKey:kEntryShowInPluginKey];
    
    // 根据开关状态计算显示模式
    CSEntryDisplayMode displayMode;
    if (showInMore && showInPlugin) {
        displayMode = CSEntryDisplayModeBoth;
    } else if (showInMore) {
        displayMode = CSEntryDisplayModeMore;
    } else if (showInPlugin) {
        displayMode = CSEntryDisplayModePlugin;
    } else {
        // 如果都没开启，默认显示在设置页面
        displayMode = CSEntryDisplayModeMore;
        [defaults setBool:YES forKey:kEntryShowInMoreKey];
    }
    
    // 保存显示模式
    [defaults setInteger:displayMode forKey:kEntryDisplayModeKey];
    
    // 保存自定义标题
    if (self.customTitle.length > 0) {
        [defaults setObject:self.customTitle forKey:kEntryCustomTitleKey];
    }
    
    [defaults synchronize];
    
    // 发送通知 - 通知CustomEntryHooks更新设置
    [[NSNotificationCenter defaultCenter] postNotificationName:kEntrySettingsChangedNotification object:nil];
}

// 显示重启提示弹窗
- (void)showRestartConfirmAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" 
                                                                  message:@"修改设置需要重启微信才能生效，是否立即重启？" 
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    // 取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"稍后重启" 
                                              style:UIAlertActionStyleCancel 
                                            handler:nil]];
    
    // 确定按钮（点击后退出应用）
    [alert addAction:[UIAlertAction actionWithTitle:@"立即重启" 
                                              style:UIAlertActionStyleDestructive 
                                            handler:^(UIAlertAction * _Nonnull action) {
        // 退出应用
        exit(0);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 设置界面数据
- (void)setupData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL showInMore = [defaults boolForKey:kEntryShowInMoreKey];
    BOOL showInPlugin = [defaults boolForKey:kEntryShowInPluginKey];
    
    // 创建显示在我页面开关项
    self.showInMoreItem = [CSSettingItem switchItemWithTitle:@"显示在我页面" 
                                                  iconName:@"person.fill" 
                                                 iconColor:[UIColor systemBlueColor]
                                               switchValue:showInMore
                                         valueChangedBlock:^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kEntryShowInMoreKey];
        [self saveSettingsAndNotify];
        
        // 显示重启提示弹窗
        [self showRestartConfirmAlert];
    }];
    
    // 创建显示在插件入口的开关项
    self.showInPluginItem = [CSSettingItem switchItemWithTitle:@"显示在插件入口" 
                                                     iconName:@"apps.iphone" 
                                                    iconColor:[UIColor systemGreenColor]
                                                  switchValue:showInPlugin
                                            valueChangedBlock:^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kEntryShowInPluginKey];
        [self saveSettingsAndNotify];
        
        // 显示重启提示弹窗
        [self showRestartConfirmAlert];
    }];
    
    // 创建自定义标题设置项
    self.customTitleItem = [CSSettingItem inputItemWithTitle:@"自定义标题" 
                                                  iconName:@"textformat.alt" 
                                                 iconColor:[UIColor systemOrangeColor]
                                                 inputValue:self.customTitle
                                             inputPlaceholder:@"默认：Wechat"
                                            valueChangedBlock:^(NSString *value) {
        // 更新自定义标题并保存设置
        self.customTitle = value;
        [self saveSettingsAndNotify];
        
        // 显示重启提示弹窗
        [self showRestartConfirmAlert];
    }];
    
    // 创建说明文本设置项
    CSSettingItem *aboutItem = [CSSettingItem itemWithTitle:@"说明" 
                                                 iconName:@"info.circle" 
                                                iconColor:[UIColor systemGrayColor]
                                                  detail:@"调整后需要重启微信"];
    
    // 创建分区
    CSSettingSection *displaySection = [CSSettingSection sectionWithHeader:@"显示设置" 
                                                                  items:@[self.showInMoreItem,
                                                                          self.showInPluginItem,
                                                                          self.customTitleItem]];
    
    CSSettingSection *aboutSection = [CSSettingSection sectionWithHeader:@"注意事项" 
                                                                 items:@[aboutItem]];
    
    // 设置分区数组
    self.sections = @[displaySection, aboutSection];
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    // 为第一个分区添加说明
    if (section == 0) {
        return @"选择插件入口在微信中的显示位置，两个选项都可以开启，修改后需要重启微信才能生效";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取点击的item
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 处理自定义标题
    if (item == self.customTitleItem) {
        [CSUIHelper showInputAlertWithTitle:@"自定义入口标题"
                                  message:@"设置自定义插件入口标题名称"
                               initialValue:self.customTitle
                               placeholder:@"请输入标题（默认：Wechat）"
                          inViewController:self
                                completion:^(NSString *value) {
            // 更新item的值
            item.inputValue = value;
            item.detail = value;
            
            // 更新自定义标题
            self.customTitle = value;
            
            // 保存设置并通知
            [self saveSettingsAndNotify];
            
            // 显示重启提示弹窗
            [self showRestartConfirmAlert];
        }];
    }
}

@end 