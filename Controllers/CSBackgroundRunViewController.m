#import "CSBackgroundRunViewController.h"
#import "CSSettingTableViewCell.h"

@interface CSBackgroundRunViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) CSSettingItem *backgroundRunItem;
@property (nonatomic, strong) CSSettingItem *intervalItem;
@end

@implementation CSBackgroundRunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"后台运行设置";
    
    // 设置表格样式
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // 注册cell
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 加载数据
    [self setupData];
}

- (void)setupData {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    BOOL isBackgroundRunEnabled = [defaults boolForKey:kBackgroundRunEnabledKey];
    
    // 创建后台运行开关
    self.backgroundRunItem = [CSSettingItem switchItemWithTitle:@"后台运行"
                                                       iconName:@"play.circle"
                                                      iconColor:[UIColor systemGreenColor]
                                                    switchValue:isBackgroundRunEnabled
                                              valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kBackgroundRunEnabledKey];
        [defaults synchronize];
        
        // 发送通知，让BackgroundRun.xm处理状态改变
        NSDictionary *userInfo = @{@"enabled": @(isOn)};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundRunStatusChanged" 
                                                            object:nil 
                                                          userInfo:userInfo];
        
        // 更新UI，根据开关状态决定是否显示触发间隔设置区域
        [self updateSectionsWithBackgroundRunEnabled:isOn];
        [self.tableView reloadData];
    }];
    
    // 读取默认的时间间隔，如果没有设置过则为10秒
    NSInteger interval = [defaults integerForKey:kBackgroundIntervalKey];
    if (interval == 0) {
        interval = 10; // 默认10秒
        [defaults setInteger:interval forKey:kBackgroundIntervalKey];
        [defaults synchronize];
    }
    
    // 创建时间间隔设置项
    self.intervalItem = [CSSettingItem inputItemWithTitle:@"触发间隔"
                                                iconName:@"timer"
                                               iconColor:[UIColor systemOrangeColor]
                                              inputValue:[NSString stringWithFormat:@"%ld秒", (long)interval]
                                          inputPlaceholder:@"10-60秒"
                                         valueChangedBlock:^(NSString *value) {
        // 解析输入的数字
        NSString *numericString = [[value componentsSeparatedByCharactersInSet:
                                  [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] 
                                 componentsJoinedByString:@""];
        
        NSInteger newInterval = [numericString integerValue];
        
        // 验证有效范围：10-60秒
        if (newInterval < 10) {
            newInterval = 10;
        } else if (newInterval > 60) {
            newInterval = 60;
        }
        
        // 保存新设置并发送通知
        [defaults setInteger:newInterval forKey:kBackgroundIntervalKey];
        [defaults synchronize];
        
        NSDictionary *userInfo = @{@"interval": @(newInterval)};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundIntervalChanged" 
                                                           object:nil 
                                                         userInfo:userInfo];
        
        // 更新显示
        self.intervalItem.inputValue = [NSString stringWithFormat:@"%ld秒", (long)newInterval];
        self.intervalItem.detail = self.intervalItem.inputValue;
        [self.tableView reloadData];
    }];
    
    // 根据开关状态决定是否显示触发间隔设置区域
    [self updateSectionsWithBackgroundRunEnabled:isBackgroundRunEnabled];
}

// 根据后台运行开关状态更新UI
- (void)updateSectionsWithBackgroundRunEnabled:(BOOL)enabled {
    // 创建主开关区域
    CSSettingSection *switchSection = [CSSettingSection sectionWithHeader:@"开关设置"
                                                                   items:@[self.backgroundRunItem]];
    
    // 创建触发间隔区域
    CSSettingSection *intervalSection = [CSSettingSection sectionWithHeader:@"触发间隔"
                                                                   items:@[self.intervalItem]];
    
    // 创建功能说明区域
    CSSettingItem *infoItem = [CSSettingItem itemWithTitle:@"功能说明"
                                                 iconName:@"info.circle"
                                               iconColor:[UIColor systemBlueColor]
                                                  detail:nil];
    
    CSSettingSection *infoSection = [CSSettingSection sectionWithHeader:@"说明"
                                                              items:@[infoItem]];
    
    // 根据开关状态决定显示的区域
    if (enabled) {
        // 如果开关打开，显示所有三个区域
        self.sections = @[switchSection, intervalSection, infoSection];
    } else {
        // 如果开关关闭，不显示触发间隔区域
        self.sections = @[switchSection, infoSection];
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else if (section == 1 && self.sections.count > 2) {
        return nil;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 处理输入类型的项目
    if (item.itemType == CSSettingItemTypeInput) {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
        
        if ([item.title isEqualToString:@"触发间隔"]) {
            // 获取当前值
            NSInteger interval = [defaults integerForKey:kBackgroundIntervalKey];
            if (interval == 0) {
                interval = 10; // 默认值
            }
            
            // 显示输入弹窗
            [CSUIHelper showInputAlertWithTitle:@"设置触发间隔"
                                        message:@"请输入后台任务触发间隔（10-60秒）\n建议设置值为10秒-15秒"
                                   initialValue:[NSString stringWithFormat:@"%ld", (long)interval]
                                   placeholder:@"10-60秒"
                               inViewController:self
                                     completion:^(NSString *value) {
                // 解析输入的数字
                NSString *numericString = [[value componentsSeparatedByCharactersInSet:
                                          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] 
                                         componentsJoinedByString:@""];
                
                NSInteger newInterval = [numericString integerValue];
                
                // 验证有效范围：10-60秒
                if (newInterval < 10) {
                    newInterval = 10;
                } else if (newInterval > 60) {
                    newInterval = 60;
                }
                
                // 保存新设置并发送通知
                [defaults setInteger:newInterval forKey:kBackgroundIntervalKey];
                [defaults synchronize];
                
                NSDictionary *userInfo = @{@"interval": @(newInterval)};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundIntervalChanged" 
                                                                   object:nil 
                                                                 userInfo:userInfo];
                
                // 更新UI显示
                self.intervalItem.inputValue = [NSString stringWithFormat:@"%ld秒", (long)newInterval];
                self.intervalItem.detail = self.intervalItem.inputValue;
                [self.tableView reloadData];
            }];
        }
    }
    // 处理功能说明点击
    else if ([item.title isEqualToString:@"功能说明"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"后台运行说明"
                                                                                message:@"开启后台运行后，微信将在后台持续运行，不会被系统自动关闭，会增加电池消耗。\n\n该功能利用后台播放无声音频和通过向系统API申请后台任务，保持应用活跃。"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"了解了"
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end 