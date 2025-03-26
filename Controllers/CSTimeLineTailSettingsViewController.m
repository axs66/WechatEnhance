#import "CSTimeLineTailSettingsViewController.h"
#import "CSSettingTableViewCell.h"

// 朋友圈后缀相关常量
static NSString * const kWCTimeLineMessageTailText = @"WCTimeLineMessageTailText";       // 朋友圈后缀文本
static NSString * const kWCTimeLineMessageTailEnabled = @"WCTimeLineMessageTailEnabled"; // 朋友圈后缀开关

@interface CSTimeLineTailSettingsViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) CSSettingItem *textInputItem; // 添加属性以便控制显示/隐藏
@end

@implementation CSTimeLineTailSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"朋友圈后缀";
    
    // 设置UI样式
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 设置数据
    [self setupData];
}

- (void)setupData {
    // 获取当前后缀设置
    NSString *tailText = [[NSUserDefaults standardUserDefaults] stringForKey:kWCTimeLineMessageTailText] ?: @"";
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kWCTimeLineMessageTailEnabled];
    
    // 创建相关设置项
    
    // 开关设置项
    CSSettingItem *enableItem = [CSSettingItem switchItemWithTitle:@"启用朋友圈后缀" 
                                                         iconName:@"quote.bubble" 
                                                        iconColor:[UIColor systemBlueColor] 
                                                      switchValue:isEnabled 
                                                valueChangedBlock:^(BOOL isOn) {
        // 保存开关状态
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kWCTimeLineMessageTailEnabled];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 更新UI，显示或隐藏文本输入项
        [self updateUIForSwitchState:isOn];
    }];
    
    // 文本输入设置项
    self.textInputItem = [CSSettingItem inputItemWithTitle:@"后缀文本" 
                                              iconName:@"text.bubble" 
                                             iconColor:[UIColor systemGreenColor] 
                                            inputValue:tailText 
                                      inputPlaceholder:@"请输入朋友圈后缀文本" 
                                     valueChangedBlock:^(NSString *value) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:kWCTimeLineMessageTailText];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    // 主设置区域 - 只包含启用开关
    CSSettingSection *mainSection = [CSSettingSection sectionWithHeader:@"设置" 
                                                               items:@[enableItem]];
    
    // 文本设置区域 - 如果开关打开则显示这个区域
    CSSettingSection *textSection = [CSSettingSection sectionWithHeader:@"后缀内容" 
                                                                 items:@[self.textInputItem]];
    
    // 初始设置 - 根据开关状态决定是否显示文本输入区域
    if (isEnabled) {
        self.sections = @[mainSection, textSection];
    } else {
        self.sections = @[mainSection];
    }
}

// 更新UI，显示或隐藏后缀文本输入区域
- (void)updateUIForSwitchState:(BOOL)isOn {
    // 获取当前的文本设置区域
    CSSettingSection *mainSection = self.sections.firstObject;
    CSSettingSection *textSection = nil;
    
    if (self.sections.count > 1) {
        textSection = self.sections[1];
    } else {
        // 如果当前没有文本区域，创建一个
        textSection = [CSSettingSection sectionWithHeader:@"后缀内容" items:@[self.textInputItem]];
    }
    
    // 根据开关状态决定显示的区域
    if (isOn) {
        self.sections = @[mainSection, textSection];
    } else {
        self.sections = @[mainSection];
    }
    
    // 重新加载表格数据
    [self.tableView reloadData];
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
    if (section == 0) {
        return nil;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取当前项数据
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 处理输入类型项的点击
    if (item.itemType == CSSettingItemTypeInput) {
        [CSUIHelper showInputAlertWithTitle:item.title
                                  message:@"请输入朋友圈后缀文本"
                               initialValue:item.inputValue
                               placeholder:item.inputPlaceholder
                          inViewController:self
                                completion:^(NSString *value) {
            // 更新item的值
            item.inputValue = value;
            
            // 更新detail文本
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

// 设置cell的背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (@available(iOS 13.0, *)) {
        cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

@end 