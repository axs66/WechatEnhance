#import "CSAccountDetailViewController.h"
#import "CSUserInfoHelper.h"
#import "CSSettingTableViewCell.h"
#import <sys/utsname.h>

#pragma mark - 显示文本常量

// 证书类型文本
static NSString * const kCertTypePersonal = @"个人证书";
static NSString * const kCertTypeEnterprise = @"企业证书";
static NSString * const kCertTypeAppStore = @"App Store";

// 信息缺失文本
static NSString * const kInfoMissing = @"未读取到证书信息";
static NSString * const kDevicesUnlimited = @"不限制";

// 区域标题
static NSString * const kSectionUserInfo = @"用户信息";
static NSString * const kSectionAppInfo = @"应用信息";
static NSString * const kSectionCertInfo = @"签名信息";

// 用户信息标题
static NSString * const kUserName = @"微信名";
static NSString * const kWechatID = @"微信号";
static NSString * const kWXID = @"WXID";

// 应用信息标题
static NSString * const kAppName = @"应用名称";
static NSString * const kBundleID = @"Bundle ID";
static NSString * const kVersionTitle = @"版本号";
static NSString * const kDeviceModel = @"设备标识";

// 证书信息标题
static NSString * const kCertType = @"证书类型";
static NSString * const kTeamName = @"签名团队";
static NSString * const kTeamID = @"团队ID";
static NSString * const kCreationDate = @"注册时间";
static NSString * const kExpirationDate = @"过期时间";
static NSString * const kAllowedDevices = @"允许设备";
static NSString * const kDeviceUDID = @"UDID";

// 其他格式文本
static NSString * const kDateFormat = @"yyyy-MM-dd HH:mm:ss";
static NSString * const kDevicesCountFormat = @"%lu 台设备";
static NSString * const kVersionFormat = @"%@\t(%@)";

// 按钮文本
static NSString * const kPageTitle = @"账号信息";
static NSString * const kAppSuffix = @"aucfa";

@interface CSAccountDetailViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) NSArray<CSSettingItem *> *userItems;
@property (nonatomic, strong) NSArray<CSSettingItem *> *appItems;
@property (nonatomic, strong) NSArray<CSSettingItem *> *certItems;
@end

@implementation CSAccountDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏标题
    self.title = kPageTitle;  // "账号信息"标题
    
    // 配置tableView
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册cell
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 准备数据
    [self setupData];
}

// 判断证书类型
- (NSString *)determineProfileType:(NSDictionary *)profileDict {
    // 获取关键信息
    NSArray *devices = profileDict[@"ProvisionedDevices"];
    BOOL hasAllDevices = [profileDict[@"ProvisionsAllDevices"] boolValue];
    
    // 判断证书类型
    if (devices) {
        // 有设备列表 - 个人证书
        return kCertTypePersonal;
    } else if (hasAllDevices) {
        // 允许所有设备 - 企业证书
        return kCertTypeEnterprise;
    } else {
        // 默认为App Store
        return kCertTypeAppStore;
    }
}

// 读取描述文件信息
- (NSDictionary *)readProvisioningProfile {
    // 获取embedded.mobileprovision文件路径
    NSString *embeddedPath = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"embedded.mobileprovision"];
    
    // 检查文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:embeddedPath]) {
        return nil;
    }
    
    // 读取文件内容
    NSData *profileData = [NSData dataWithContentsOfFile:embeddedPath];
    if (!profileData) {
        return nil;
    }
    
    // 将文件内容转换为字符串
    NSString *profileString = [[NSString alloc] initWithData:profileData encoding:NSASCIIStringEncoding];
    if (!profileString) {
        return nil;
    }
    
    // 查找plist内容
    NSScanner *scanner = [NSScanner scannerWithString:profileString];
    NSString *plistString = nil;
    
    // 跳过开头直到找到<plist
    [scanner scanUpToString:@"<plist" intoString:nil];
    if ([scanner scanUpToString:@"</plist>" intoString:&plistString]) {
        plistString = [plistString stringByAppendingString:@"</plist>"];
        
        // 转换plist字符串为数据
        NSData *plistData = [plistString dataUsingEncoding:NSUTF8StringEncoding];
        
        // 解析plist数据为字典
        NSError *error;
        NSDictionary *plistDict = [NSPropertyListSerialization propertyListWithData:plistData 
                                                                           options:NSPropertyListImmutable 
                                                                            format:nil 
                                                                             error:&error];
        if (plistDict && !error) {
            return plistDict;
        }
    }
    
    return nil;
}

// 获取设备机型标识符 (如: iPhone12,1)
- (NSString *)getDeviceModelIdentifier {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)setupData {
    // 获取用户信息
    NSString *nickname = [CSUserInfoHelper getUserNickname] ?: @"未知";
    NSString *aliasName = [CSUserInfoHelper getUserAliasName] ?: @"未知";
    NSString *wxid = [CSUserInfoHelper getUserWXID] ?: @"未知";
    
    // 获取应用信息
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *appName = [mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: 
                        [mainBundle objectForInfoDictionaryKey:@"CFBundleName"] ?: @"未知";
    NSString *bundleID = mainBundle.bundleIdentifier ?: @"未知";
    NSString *version = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"未知";
    NSString *build = [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"未知";
    
    // 获取设备型号标识符
    NSString *deviceModelIdentifier = [self getDeviceModelIdentifier] ?: @"未知";
    
    // 创建用户信息模型
    self.userItems = @[
        [CSSettingItem itemWithTitle:kUserName iconName:@"person" iconColor:[UIColor systemBlueColor] detail:nickname],
        [CSSettingItem itemWithTitle:kWechatID iconName:@"at" iconColor:[UIColor systemGreenColor] detail:aliasName],
        [CSSettingItem itemWithTitle:kWXID iconName:@"number" iconColor:[UIColor systemOrangeColor] detail:wxid]
    ];
    
    // 读取描述文件信息
    NSDictionary *profileDict = [self readProvisioningProfile];
    
    // 创建应用信息模型
    self.appItems = @[
        [CSSettingItem itemWithTitle:kAppName iconName:@"app" iconColor:[UIColor systemIndigoColor] detail:appName],
        [CSSettingItem itemWithTitle:kBundleID iconName:@"doc.text" iconColor:[UIColor systemTealColor] detail:bundleID],
        [CSSettingItem itemWithTitle:kVersionTitle iconName:@"tag" iconColor:[UIColor systemPurpleColor] detail:[NSString stringWithFormat:kVersionFormat, version, build]],
        [CSSettingItem itemWithTitle:kDeviceModel iconName:@"iphone.radiowaves.left.and.right" iconColor:[UIColor systemBlueColor] detail:deviceModelIdentifier]
    ];
    
    // 如果无法读取配置文件
    if (!profileDict) {
        self.certItems = @[
            [CSSettingItem itemWithTitle:kAllowedDevices iconName:@"iphone" iconColor:[UIColor systemCyanColor] detail:kInfoMissing],
            [CSSettingItem itemWithTitle:kCertType iconName:@"lock.shield" iconColor:[UIColor systemTealColor] detail:kInfoMissing],
            [CSSettingItem itemWithTitle:kTeamName iconName:@"person.2" iconColor:[UIColor systemRedColor] detail:kInfoMissing],
            [CSSettingItem itemWithTitle:kTeamID iconName:@"person.crop.square" iconColor:[UIColor systemPurpleColor] detail:kInfoMissing],
            [CSSettingItem itemWithTitle:kCreationDate iconName:@"calendar.badge.plus" iconColor:[UIColor systemGreenColor] detail:kInfoMissing],
            [CSSettingItem itemWithTitle:kExpirationDate iconName:@"calendar" iconColor:[UIColor systemOrangeColor] detail:kInfoMissing],
            // 添加UDID项，即使没有读取到证书信息
            [CSSettingItem itemWithTitle:kDeviceUDID iconName:@"iphone.circle" iconColor:[UIColor systemRedColor] detail:kInfoMissing]
        ];
    } else {
        // 基本证书信息 - 加强空值检查
        NSString *teamName = kInfoMissing;
        if (profileDict[@"TeamName"] && [profileDict[@"TeamName"] isKindOfClass:[NSString class]]) {
            teamName = profileDict[@"TeamName"];
        }
        
        NSString *teamID = kInfoMissing;
        if (profileDict[@"TeamIdentifier"] && 
            [profileDict[@"TeamIdentifier"] isKindOfClass:[NSArray class]] && 
            [profileDict[@"TeamIdentifier"] count] > 0) {
            id firstItem = profileDict[@"TeamIdentifier"][0];
            if ([firstItem isKindOfClass:[NSString class]]) {
                teamID = (NSString *)firstItem;
            }
        }
        
        NSString *profileType = [self determineProfileType:profileDict];
        
        // 获取时间信息 - 加强空值检查
        NSString *createDateStr = kInfoMissing;
        if (profileDict[@"CreationDate"] && [profileDict[@"CreationDate"] isKindOfClass:[NSDate class]]) {
            NSDate *createDate = profileDict[@"CreationDate"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = kDateFormat;
            createDateStr = [formatter stringFromDate:createDate];
        }
        
        NSString *expirationDateStr = kInfoMissing;
        if (profileDict[@"ExpirationDate"] && [profileDict[@"ExpirationDate"] isKindOfClass:[NSDate class]]) {
            NSDate *expirationDate = profileDict[@"ExpirationDate"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = kDateFormat;
            expirationDateStr = [formatter stringFromDate:expirationDate];
        }
        
        // 设备信息 - 加强空值检查
        NSString *deviceCountStr = kDevicesUnlimited;
        if (profileDict[@"ProvisionedDevices"] && 
            [profileDict[@"ProvisionedDevices"] isKindOfClass:[NSArray class]]) {
            NSArray *devices = profileDict[@"ProvisionedDevices"];
            deviceCountStr = [NSString stringWithFormat:kDevicesCountFormat, (unsigned long)devices.count];
        }
        
        // 创建证书信息模型 - 按照要求调整顺序
        NSMutableArray *certItemsArray = [NSMutableArray arrayWithArray:@[
            [CSSettingItem itemWithTitle:kAllowedDevices iconName:@"iphone" iconColor:[UIColor systemCyanColor] detail:deviceCountStr],
            [CSSettingItem itemWithTitle:kCertType iconName:@"lock.shield" iconColor:[UIColor systemTealColor] detail:profileType],
            [CSSettingItem itemWithTitle:kTeamName iconName:@"person.2" iconColor:[UIColor systemRedColor] detail:teamName],
            [CSSettingItem itemWithTitle:kTeamID iconName:@"person.crop.square" iconColor:[UIColor systemPurpleColor] detail:teamID],
            [CSSettingItem itemWithTitle:kCreationDate iconName:@"calendar.badge.plus" iconColor:[UIColor systemGreenColor] detail:createDateStr],
            [CSSettingItem itemWithTitle:kExpirationDate iconName:@"calendar" iconColor:[UIColor systemOrangeColor] detail:expirationDateStr]
        ]];
        
        // 如果是个人证书，添加UDID到证书信息区域的最后
        if ([profileType isEqualToString:kCertTypePersonal]) {
            NSArray *provisionedDevices = profileDict[@"ProvisionedDevices"];
            if (provisionedDevices && [provisionedDevices isKindOfClass:[NSArray class]] && provisionedDevices.count > 0) {
                NSString *udid = [provisionedDevices firstObject];
                if (udid && [udid isKindOfClass:[NSString class]]) {
                    [certItemsArray addObject:[CSSettingItem itemWithTitle:kDeviceUDID 
                                                                iconName:@"iphone.circle" 
                                                                iconColor:[UIColor systemRedColor] 
                                                                detail:udid]];
                }
            }
        }
        
        // 设置证书信息
        self.certItems = [certItemsArray copy];
    }
    
    // 创建sections
    NSMutableArray *sections = [NSMutableArray array];
    [sections addObject:[CSSettingSection sectionWithHeader:kSectionUserInfo items:self.userItems]];
    [sections addObject:[CSSettingSection sectionWithHeader:kSectionAppInfo items:self.appItems]];
    [sections addObject:[CSSettingSection sectionWithHeader:kSectionCertInfo items:self.certItems]];
    
    self.sections = [sections copy];
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
    
    // 配置cell
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    [cell configureWithItem:item];
    
    // 普通信息项启用靠右显示
    if (item.itemType == CSSettingItemTypeNormal) {
        cell.shouldAlignRight = YES;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 为操作项提供更大的高度
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    if (item.itemType == CSSettingItemTypeAction) {
        return 55.0f;
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置cell背景色
    cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    
    // 获取item
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 为所有项设置统一的样式
    if (item.itemType == CSSettingItemTypeNormal) {
        CSSettingTableViewCell *settingCell = (CSSettingTableViewCell *)cell;
        
        // 所有正常项都使用右对齐方式
        settingCell.shouldAlignRight = YES;
        
        // 处理详情文本的显示样式
        settingCell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        // 特殊处理UDID显示
        if ([item.title isEqualToString:kDeviceUDID] ||
            [item.title isEqualToString:kWXID] ||
            [item.title isEqualToString:kTeamID] ||
            [item.title isEqualToString:kBundleID]) {
            settingCell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            settingCell.detailTextLabel.minimumScaleFactor = 0.7;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取点击的item
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