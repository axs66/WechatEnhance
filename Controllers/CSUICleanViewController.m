#import "CSUICleanViewController.h"
#import "CSSettingTableViewCell.h"

// 定义NSUserDefaults的键（与HideQRCodeHooks.xm中保持一致）
static NSString * const kWCHideQRCodeEnabledKey = @"com.wechat.tweak.hide_qrcode_enabled";
// 添加隐藏聊天时间标签的键
static NSString * const kWCHideChatTimeEnabledKey = @"com.wechat.tweak.hide_chat_time_enabled";
// 添加隐藏撤回消息标签的键
static NSString * const kWCHideRevokeMessageEnabledKey = @"com.wechat.tweak.hide_revoke_message_enabled";
// 添加隐藏拍一拍消息标签的键
static NSString * const kWCHidePatMessageEnabledKey = @"com.wechat.tweak.hide_pat_message_enabled";
// 添加隐藏语音红点和转文字标签的键
static NSString * const kWCHideVoiceHintEnabledKey = @"com.wechat.tweak.hide_voice_hint_enabled";
// 定义通知名称
static NSString * const kWCSettingsChangedNotification = @"com.wechat.tweak.settings_changed";

// 功能说明详细文本
static NSString * const kFeatureDescription = @"此功能将隐藏不必要的界面元素，部分屏蔽可能需要重启才能完全生效。可能会误判，如有误判请关闭。";

@interface CSUICleanViewController ()

// 存储所有设置分区
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;

// 存储UI元素的引用，方便直接操作
@property (nonatomic, strong) CSSettingItem *hideQRCodeItem;
// 添加隐藏聊天时间标签的控制项
@property (nonatomic, strong) CSSettingItem *hideChatTimeItem;
// 添加隐藏撤回消息标签的控制项
@property (nonatomic, strong) CSSettingItem *hideRevokeMessageItem;
// 添加隐藏拍一拍消息标签的控制项
@property (nonatomic, strong) CSSettingItem *hidePatMessageItem;
// 添加隐藏语音红点和转文字标签的控制项
@property (nonatomic, strong) CSSettingItem *hideVoiceHintItem;

@end

@implementation CSUICleanViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"界面净化";
    
    // 设置UI样式
    [self setupTableView];
    
    // 初始化数据
    [self setupData];
    
    // 注册通知，响应设置变化
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(settingsChanged:) 
                                                 name:@"com.wechat.tweak.local_settings_changed" 
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 确保UI刷新
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 私有方法

// 设置表格视图
- (void)setupTableView {
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
}

// 响应设置变化的通知
- (void)settingsChanged:(NSNotification *)notification {
    [self reloadSettings];
}

// 显示功能说明弹窗
- (void)showFeatureDescription {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"功能说明"
                                                                   message:kFeatureDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 公共方法

// 重新加载设置
- (void)reloadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 获取最新设置
    BOOL hideQRCodeEnabled = [defaults objectForKey:kWCHideQRCodeEnabledKey] ? [defaults boolForKey:kWCHideQRCodeEnabledKey] : NO;
    BOOL hideChatTimeEnabled = [defaults objectForKey:kWCHideChatTimeEnabledKey] ? [defaults boolForKey:kWCHideChatTimeEnabledKey] : NO;
    BOOL hideRevokeMessageEnabled = [defaults objectForKey:kWCHideRevokeMessageEnabledKey] ? [defaults boolForKey:kWCHideRevokeMessageEnabledKey] : NO;
    BOOL hidePatMessageEnabled = [defaults objectForKey:kWCHidePatMessageEnabledKey] ? [defaults boolForKey:kWCHidePatMessageEnabledKey] : NO;
    BOOL hideVoiceHintEnabled = [defaults objectForKey:kWCHideVoiceHintEnabledKey] ? [defaults boolForKey:kWCHideVoiceHintEnabledKey] : NO;
    
    // 更新UI
    self.hideQRCodeItem.switchValue = hideQRCodeEnabled;
    self.hideChatTimeItem.switchValue = hideChatTimeEnabled;
    self.hideRevokeMessageItem.switchValue = hideRevokeMessageEnabled;
    self.hidePatMessageItem.switchValue = hidePatMessageEnabled;
    self.hideVoiceHintItem.switchValue = hideVoiceHintEnabled;
    
    // 刷新表格
    [self.tableView reloadData];
}

// 设置UI数据
- (void)setupData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 获取当前设置，将隐藏二维码的默认值改为NO（关闭）
    BOOL hideQRCodeEnabled = [defaults objectForKey:kWCHideQRCodeEnabledKey] ? [defaults boolForKey:kWCHideQRCodeEnabledKey] : NO;
    // 获取隐藏聊天时间的设置，默认为关闭
    BOOL hideChatTimeEnabled = [defaults objectForKey:kWCHideChatTimeEnabledKey] ? [defaults boolForKey:kWCHideChatTimeEnabledKey] : NO;
    // 获取隐藏撤回消息的设置，默认为关闭
    BOOL hideRevokeMessageEnabled = [defaults objectForKey:kWCHideRevokeMessageEnabledKey] ? [defaults boolForKey:kWCHideRevokeMessageEnabledKey] : NO;
    // 获取隐藏拍一拍消息的设置，默认为关闭
    BOOL hidePatMessageEnabled = [defaults objectForKey:kWCHidePatMessageEnabledKey] ? [defaults boolForKey:kWCHidePatMessageEnabledKey] : NO;
    // 获取隐藏语音红点和转文字标签的设置，默认为关闭
    BOOL hideVoiceHintEnabled = [defaults objectForKey:kWCHideVoiceHintEnabledKey] ? [defaults boolForKey:kWCHideVoiceHintEnabledKey] : NO;
    
    // 创建隐藏二维码按钮项
    self.hideQRCodeItem = [CSSettingItem switchItemWithTitle:@"隐藏添加界面二维码" 
                                                   iconName:@"qrcode" 
                                                  iconColor:[UIColor systemGreenColor]
                                                switchValue:hideQRCodeEnabled
                                           valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kWCHideQRCodeEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 先发送本地通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.wechat.tweak.local_settings_changed" object:nil];
        
        // 再发送全局通知
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge CFStringRef)kWCSettingsChangedNotification,
            NULL,
            NULL,
            true
        );
    }];
    
    // 创建隐藏聊天时间按钮项
    self.hideChatTimeItem = [CSSettingItem switchItemWithTitle:@"隐藏聊天界面时间标签" 
                                                     iconName:@"clock" 
                                                    iconColor:[UIColor systemBlueColor]
                                                  switchValue:hideChatTimeEnabled
                                             valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kWCHideChatTimeEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 先发送本地通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.wechat.tweak.local_settings_changed" object:nil];
        
        // 再发送全局通知
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge CFStringRef)kWCSettingsChangedNotification,
            NULL,
            NULL,
            true
        );
    }];
    
    // 创建隐藏撤回消息按钮项
    self.hideRevokeMessageItem = [CSSettingItem switchItemWithTitle:@"隐藏撤回消息提示标签" 
                                                     iconName:@"arrow.uturn.backward" 
                                                    iconColor:[UIColor systemPurpleColor]
                                                  switchValue:hideRevokeMessageEnabled
                                             valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kWCHideRevokeMessageEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 先发送本地通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.wechat.tweak.local_settings_changed" object:nil];
        
        // 再发送全局通知
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge CFStringRef)kWCSettingsChangedNotification,
            NULL,
            NULL,
            true
        );
    }];
    
    // 创建隐藏拍一拍消息按钮项
    self.hidePatMessageItem = [CSSettingItem switchItemWithTitle:@"隐藏拍一拍消息提示标签" 
                                                       iconName:@"hand.tap" 
                                                      iconColor:[UIColor systemOrangeColor]
                                                    switchValue:hidePatMessageEnabled
                                               valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kWCHidePatMessageEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 先发送本地通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.wechat.tweak.local_settings_changed" object:nil];
        
        // 再发送全局通知
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge CFStringRef)kWCSettingsChangedNotification,
            NULL,
            NULL,
            true
        );
    }];
    
    // 创建隐藏语音红点和转文字标签按钮项
    self.hideVoiceHintItem = [CSSettingItem switchItemWithTitle:@"隐藏语音红点和转文字标签" 
                                                       iconName:@"mic" 
                                                      iconColor:[UIColor systemRedColor]
                                                    switchValue:hideVoiceHintEnabled
                                               valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kWCHideVoiceHintEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 先发送本地通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.wechat.tweak.local_settings_changed" object:nil];
        
        // 再发送全局通知
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge CFStringRef)kWCSettingsChangedNotification,
            NULL,
            NULL,
            true
        );
    }];
    
    // 创建说明项，使用带指示器的样式
    CSSettingItem *descriptionItem = [CSSettingItem itemWithTitle:@"功能说明" 
                                                        iconName:@"info.circle" 
                                                       iconColor:[UIColor systemGrayColor]
                                                         detail:@"点击查看"];
    
    // 创建各个分区
    CSSettingSection *qrcodeSection = [CSSettingSection sectionWithHeader:@"二维码设置" 
                                                                 items:@[self.hideQRCodeItem]];
    
    // 创建聊天界面设置分区，添加隐藏语音红点和转文字标签的选项
    CSSettingSection *chatSection = [CSSettingSection sectionWithHeader:@"聊天界面设置" 
                                                                items:@[self.hideChatTimeItem, self.hideRevokeMessageItem, self.hidePatMessageItem, self.hideVoiceHintItem]];
    
    CSSettingSection *descriptionSection = [CSSettingSection sectionWithHeader:@"说明" 
                                                                     items:@[descriptionItem]];
    
    // 设置sections数组，添加新的聊天界面设置分区
    self.sections = @[qrcodeSection, chatSection, descriptionSection];
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
    CSSettingSection *section = self.sections[indexPath.section];
    CSSettingItem *item = section.items[indexPath.row];
    
    // 配置单元格
    [cell configureWithItem:item];
    
    // 如果是功能说明项，添加箭头指示器
    if ([item.title isEqualToString:@"功能说明"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
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
    
    // 如果点击的是功能说明
    if ([item.title isEqualToString:@"功能说明"]) {
        // 显示功能说明弹窗
        [self showFeatureDescription];
        return;
    }
    
    // 处理不同类型的点击事件
    if (item.itemType == CSSettingItemTypeInput) {
        [CSUIHelper showInputAlertWithTitle:item.title
                                  message:nil
                               initialValue:item.inputValue
                               placeholder:item.inputPlaceholder
                          inViewController:self
                                completion:^(NSString *value) {
            // 更新item的值
            item.inputValue = value;
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