#import "CSFavoriteSettingsViewController.h"
#import "CSSettingTableViewCell.h"
#import "../Headers/WCHeaders.h"
#import <LocalAuthentication/LocalAuthentication.h>

// 收藏验证相关常量
static NSString * const kFavoriteUserDefaultsSuiteName = @"com.cyansmoke.wechattweak";
static NSString * const kBiometricAuthFavKey = @"com.wechat.tweak.biometric.auth.favorite";

@interface CSFavoriteSettingsViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) CSSettingItem *favoriteAuthItem;
@end

@implementation CSFavoriteSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"收藏验证设置";
    
    // 设置UI样式
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 加载数据
    [self setupData];
}

- (void)setupData {
    // 从用户默认值中获取当前设置
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kFavoriteUserDefaultsSuiteName];
    BOOL isAuthEnabled = [defaults boolForKey:kBiometricAuthFavKey];
    
    // 创建开关项
    self.favoriteAuthItem = [CSSettingItem switchItemWithTitle:@"启用收藏验证"
                                                     iconName:@"lock.fill"
                                                    iconColor:[UIColor systemBlueColor]
                                                  switchValue:isAuthEnabled
                                            valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kFavoriteUserDefaultsSuiteName];
        [defaults setBool:isOn forKey:kBiometricAuthFavKey];
        [defaults synchronize];
        
        // 更新界面
        [self.tableView reloadData];
    }];
    
    // 创建说明项
    CSSettingItem *infoItem = [CSSettingItem itemWithTitle:@"功能说明"
                                                 iconName:@"info.circle"
                                                iconColor:[UIColor systemOrangeColor]
                                                   detail:nil];
    
    // 创建设置区域和信息区域
    CSSettingSection *settingSection = [CSSettingSection sectionWithHeader:@"验证设置"
                                                                    items:@[self.favoriteAuthItem]];
    
    CSSettingSection *infoSection = [CSSettingSection sectionWithHeader:@"说明"
                                                                 items:@[infoItem]];
    
    self.sections = @[settingSection, infoSection];
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
    if (section == 0) {
        return @"开启后，查看收藏内容时将需要进行生物认证验证";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 处理功能说明点击
    if ([item.title isEqualToString:@"功能说明"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"收藏验证说明"
                                                                                message:@"开启收藏验证后，每次查看收藏内容时，将要求进行生物认证验证。\n\n这可以保护您的隐私内容不被他人查看。\n\n该功能需要您的设备支持Face ID或Touch ID。"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"了解了"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

// 设置cell的背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
}

@end 