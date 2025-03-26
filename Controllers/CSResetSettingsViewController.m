#import "CSResetSettingsViewController.h"
#import "CSSettingTableViewCell.h"

@interface CSResetSettingsViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) NSMutableArray *plistPaths; // 添加存储plist路径的属性
@property (nonatomic, strong) NSMutableArray *plistNames; // 添加存储plist名称的属性
@end

@implementation CSResetSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化数组
    self.plistPaths = [NSMutableArray array];
    self.plistNames = [NSMutableArray array];
    
    // 设置标题
    self.title = @"重置设置";
    
    // 设置表格样式
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 扫描plist文件
    [self scanPlistFiles];
    
    // 设置数据
    [self setupData];
}

- (void)scanPlistFiles {
    // 1. 获取plist文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths firstObject];
    NSString *preferencesPath = [libraryPath stringByAppendingPathComponent:@"Preferences"];
    
    // 2. 扫描Preferences目录获取所有plist文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:preferencesPath error:&error];
    
    if (error) {
        return;
    } else {
        // 直接获取所有.plist文件，不做额外筛选
        for (NSString *fileName in directoryContents) {
            if ([fileName hasSuffix:@".plist"]) {
                NSString *fullPath = [preferencesPath stringByAppendingPathComponent:fileName];
                [self.plistPaths addObject:fullPath];
                [self.plistNames addObject:fileName];
            }
        }
    }
}

- (void)setupData {
    // 创建重置选项
    CSSettingItem *resetAllItem = [CSSettingItem itemWithTitle:@"重置所有设置" 
                                                      iconName:@"arrow.counterclockwise.circle" 
                                                     iconColor:[UIColor systemRedColor] 
                                                        detail:@"清除所有插件设置"];
    
    // 创建分组
    CSSettingSection *resetSection = [CSSettingSection sectionWithHeader:@"重置选项" 
                                                                   items:@[resetAllItem]];
    
    // 添加到分组数组
    self.sections = @[resetSection];
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
    
    // 获取当前项数据并配置cell
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    [cell configureWithItem:item];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"重置设置会清除所有插件配置，恢复到默认状态。此操作不可撤销，请谨慎操作。";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 准备plist文件列表的文本内容
    NSMutableString *plistListText = [NSMutableString string];
    
    // 如果找到了plist文件，最多显示前20个，防止列表过长
    NSInteger displayCount = MIN(self.plistNames.count, 20);
    
    for (NSInteger i = 0; i < displayCount; i++) {
        [plistListText appendFormat:@"• %@\n", self.plistNames[i]];
    }
    
    // 如果文件数量超过20个，显示省略信息
    if (self.plistNames.count > 20) {
        [plistListText appendFormat:@"\n...以及其他 %ld 个文件", (long)(self.plistNames.count - 20)];
    }
    
    // 如果没有找到文件
    if (self.plistNames.count == 0) {
        [plistListText appendString:@"未找到任何配置文件"];
    }
    
    // 显示配置文件列表对话框
    UIAlertController *fileListAlert = [UIAlertController alertControllerWithTitle:@"将重置以下配置文件"
                                                                         message:plistListText
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"继续重置"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // 展示确认对话框
        [self showConfirmResetAlert];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    [fileListAlert addAction:continueAction];
    [fileListAlert addAction:cancelAction];
    
    [self presentViewController:fileListAlert animated:YES completion:nil];
}

- (void)showConfirmResetAlert {
    // 显示确认对话框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认重置"
                                                                             message:@"确定要重置所有设置吗？所有自定义配置将被清除，恢复到默认状态。此操作不可撤销。"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认重置"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // 执行重置操作
        [self resetAllSettings];
        
        // 显示重启选项
        [self showRestartOptions];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Reset Settings

- (void)resetAllSettings {
    // 3. 删除找到的plist文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *plistPath in self.plistPaths) {
        NSError *error = nil;
        if ([fileManager fileExistsAtPath:plistPath]) {
            [fileManager removeItemAtPath:plistPath error:&error];
        }
    }
    
    // 4. 清空内存中的设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    // 同样清理共享Suite中的设置
    NSString *suiteName = kUserDefaultsSuiteName;
    if (suiteName.length > 0) {
        NSUserDefaults *suiteDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
        [suiteDefaults removePersistentDomainForName:suiteName];
    }
    
    // 5. 保留用户协议同意状态
    [defaults setBool:YES forKey:@"com.wechat.tweak.user.agreement.accepted.v3"];
    [defaults synchronize];
    
    // 6. 发送通知，让相关界面刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.wechat.tweak.settings_changed" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.wechat.tweak.local_settings_changed" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundRunStatusChanged" object:nil userInfo:@{@"enabled": @(NO)}];
}

- (void)showRestartOptions {
    // 提示重启选项
    UIAlertController *restartAlert = [UIAlertController alertControllerWithTitle:@"重置成功"
                                                                         message:@"所有设置已重置。需要立即重启微信才能完全应用更改。"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *restartNowAction = [UIAlertAction actionWithTitle:@"立即重启"
                                                              style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction * _Nonnull action) {
        // 使用exit(0)强制退出应用，用户重新打开即可
        exit(0);
    }];
    
    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"稍后重启"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
    
    // 调整按钮顺序，将稍后重启放在右侧（iOS中按照添加顺序从右到左排列）
    [restartAlert addAction:laterAction];         // 放在右侧
    [restartAlert addAction:restartNowAction];    // 放在左侧
    
    [self presentViewController:restartAlert animated:YES completion:nil];
}

@end 