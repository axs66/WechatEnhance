#import "CSGameCheatsViewController.h"
#import "CSSettingTableViewCell.h"

// 游戏作弊的设置键
static NSString * const kGameCheatEnabledKey = @"GameCheat_Enabled";

@interface CSGameCheatsViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) CSSettingItem *gameCheatItem;
@end

@implementation CSGameCheatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"游戏辅助";
    
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
    // 从UserDefaults读取设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isGameCheatEnabled = [defaults boolForKey:kGameCheatEnabledKey];
    
    // 创建游戏作弊开关项
    self.gameCheatItem = [CSSettingItem switchItemWithTitle:@"启用游戏辅助"
                                                   iconName:@"gamecontroller.fill"
                                                  iconColor:[UIColor systemGreenColor]
                                                switchValue:isGameCheatEnabled
                                          valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kGameCheatEnabledKey];
        [defaults synchronize];
    }];
    
    // 创建功能说明项
    CSSettingItem *rockPaperScissorsItem = [CSSettingItem itemWithTitle:@"猜拳游戏"
                                                             iconName:@"hand.raised.fill"
                                                            iconColor:[UIColor systemBlueColor]
                                                              detail:@"可自定义出拳"];
    
    CSSettingItem *diceItem = [CSSettingItem itemWithTitle:@"骰子游戏"
                                                 iconName:@"dice.fill"
                                                iconColor:[UIColor systemOrangeColor]
                                                  detail:@"可自定义点数"];
    
    CSSettingItem *infoItem = [CSSettingItem inputItemWithTitle:@"功能说明"
                                                     iconName:@"info.circle"
                                                    iconColor:[UIColor systemBlueColor]
                                                   inputValue:@"点击查看"
                                             inputPlaceholder:@""
                                            valueChangedBlock:nil];
    
    // 创建分区
    CSSettingSection *switchSection = [CSSettingSection sectionWithHeader:@"辅助设置"
                                                                   items:@[self.gameCheatItem]];
    
    CSSettingSection *gamesSection = [CSSettingSection sectionWithHeader:@"支持游戏"
                                                                 items:@[rockPaperScissorsItem, diceItem]];
    
    CSSettingSection *infoSection = [CSSettingSection sectionWithHeader:@"说明"
                                                                items:@[infoItem]];
    
    // 设置分区数组
    self.sections = @[switchSection, gamesSection, infoSection];
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
        return @"开启后，在玩微信游戏时可以选择出拳或骰子点数";
    } else if (section == 1) {
        return @"目前支持猜拳游戏和骰子游戏";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 处理功能说明点击
    if ([item.title isEqualToString:@"功能说明"]) {
        [self showInfoAlert];
    }
}

// 显示功能说明弹窗
- (void)showInfoAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"游戏辅助说明"
                                                                            message:@"游戏辅助功能可以让您在微信的猜拳和骰子游戏中选择想要的结果。\n\n此功能仅供娱乐，请合理使用。"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"了解了"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 设置cell的背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
}

@end 