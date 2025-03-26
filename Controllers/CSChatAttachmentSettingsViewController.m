#import "CSChatAttachmentSettingsViewController.h"
#import "CSSettingTableViewCell.h"

// 保存设置的键
static NSString * const kChatAttachmentLayoutEnabledKey = @"com.wechat.tweak.chat.attachment.layout.enabled";
static NSString * const kChatAttachmentColumnsKey = @"com.wechat.tweak.chat.attachment.columns";
static NSString * const kChatAttachmentSpacingKey = @"com.wechat.tweak.chat.attachment.spacing";
// 场景控制相关键
static NSString * const kChatAttachmentShowInPrivateKey = @"com.wechat.tweak.chat.attachment.show.in.private";
static NSString * const kChatAttachmentShowInGroupKey = @"com.wechat.tweak.chat.attachment.show.in.group";
static NSString * const kChatAttachmentShowInOfficialKey = @"com.wechat.tweak.chat.attachment.show.in.official";
// 公众号自定义排序相关键
static NSString * const kChatAttachmentOfficialSortEnabledKey = @"com.wechat.tweak.chat.attachment.official.sort.enabled";
static NSString * const kChatAttachmentOfficialSortOrderKey = @"com.wechat.tweak.chat.attachment.official.sort.order";
// 私聊自定义排序相关键
static NSString * const kChatAttachmentPrivateSortEnabledKey = @"com.wechat.tweak.chat.attachment.private.sort.enabled";
static NSString * const kChatAttachmentPrivateSortOrderKey = @"com.wechat.tweak.chat.attachment.private.sort.order";
// 群聊自定义排序相关键
static NSString * const kChatAttachmentGroupSortEnabledKey = @"com.wechat.tweak.chat.attachment.group.sort.enabled";
static NSString * const kChatAttachmentGroupSortOrderKey = @"com.wechat.tweak.chat.attachment.group.sort.order";
// 按钮隐藏相关键
static NSString * const kChatAttachmentOfficialHiddenButtonsKey = @"com.wechat.tweak.chat.attachment.official.hidden.buttons";
static NSString * const kChatAttachmentPrivateHiddenButtonsKey = @"com.wechat.tweak.chat.attachment.private.hidden.buttons";
static NSString * const kChatAttachmentGroupHiddenButtonsKey = @"com.wechat.tweak.chat.attachment.group.hidden.buttons";
// 其他设置键
static NSString * const kChatAttachmentHasShownTutorialKey = @"com.wechat.tweak.chat.attachment.has.shown.tutorial";

// 设置默认值和范围
static const int kDefaultColumns = 5;  // 默认列数
static const int kMinColumns = 3;      // 最小列数
static const int kMaxColumns = 5;      // 最大列数
static const float kDefaultSpacing = 0.0f;  // 默认间距
static const float kMinSpacing = 0.0f;      // 最小间距
static const float kMaxSpacing = 20.0f;     // 最大间距

// 公众号按钮Tag常量
static const int kTagPhoto = 18000;       // 照片
static const int kTagCamera = 18001;      // 拍摄
static const int kTagLocation = 18002;    // 位置
static const int kTagVoiceInput = 18003;  // 语音输入 
static const int kTagFavorite = 18004;    // 收藏
static const int kTagContact = 18005;     // 个人名片

// 私聊按钮Tag常量
static const int kPrivateTagPhoto = 18000;       // 照片
static const int kPrivateTagCamera = 18001;      // 拍摄
static const int kPrivateTagVideoCall = 18002;   // 视频通话
static const int kPrivateTagLocation = 18003;    // 位置
static const int kPrivateTagRedPacket = 18004;   // 红包
static const int kPrivateTagGift = 18005;        // 礼物
static const int kPrivateTagTransfer = 18006;    // 转账
static const int kPrivateTagVoiceInput = 18007;  // 语音输入
static const int kPrivateTagFavorite = 18008;    // 收藏
static const int kPrivateTagContact = 18009;     // 个人名片
static const int kPrivateTagFile = 18010;        // 文件
static const int kPrivateTagCard = 18011;        // 卡券
static const int kPrivateTagMusic = 18012;       // 音乐

// 群聊按钮Tag常量
static const int kGroupTagPhoto = 18000;        // 照片
static const int kGroupTagCamera = 18001;       // 拍摄
static const int kGroupTagVoiceCall = 18002;    // 语音通话
static const int kGroupTagLocation = 18003;     // 位置
static const int kGroupTagRedPacket = 18004;    // 红包
static const int kGroupTagGift = 18005;         // 礼物
static const int kGroupTagTransfer = 18006;     // 转账
static const int kGroupTagVoiceInput = 18007;   // 语音输入
static const int kGroupTagFavorite = 18008;     // 收藏
static const int kGroupTagGroupTool = 18009;    // 群工具
static const int kGroupTagChain = 18010;        // 接龙
static const int kGroupTagLiveStream = 18011;   // 直播
static const int kGroupTagContact = 18012;      // 个人名片
static const int kGroupTagFile = 18013;         // 文件
static const int kGroupTagCard = 18014;         // 卡券
static const int kGroupTagMusic = 18015;        // 音乐

@interface CSChatAttachmentSettingsViewController ()
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, assign) BOOL isEnabled; // 添加开关状态属性
@property (nonatomic, strong) CSSettingSection *layoutSection; // 添加布局部分引用
@property (nonatomic, strong) CSSettingSection *sceneSection; // 添加场景控制部分引用
@property (nonatomic, strong) CSSettingSection *officialSortSection; // 添加公众号排序部分引用
@property (nonatomic, assign) BOOL isOfficialSortEnabled; // 公众号排序开关状态
@property (nonatomic, strong) NSMutableArray<CSSettingItem *> *officialSortItems; // 公众号按钮排序项
@property (nonatomic, strong) NSMutableArray *officialHiddenButtons; // 公众号隐藏的按钮

// 私聊排序相关属性
@property (nonatomic, strong) CSSettingSection *privateSortSection; // 添加私聊排序部分引用 
@property (nonatomic, assign) BOOL isPrivateSortEnabled; // 私聊排序开关状态
@property (nonatomic, strong) NSMutableArray<CSSettingItem *> *privateSortItems; // 私聊按钮排序项
@property (nonatomic, strong) NSMutableArray *privateHiddenButtons; // 私聊隐藏的按钮

// 群聊排序相关属性
@property (nonatomic, strong) CSSettingSection *groupSortSection; // 添加群聊排序部分引用
@property (nonatomic, assign) BOOL isGroupSortEnabled; // 群聊排序开关状态
@property (nonatomic, strong) NSMutableArray<CSSettingItem *> *groupSortItems; // 群聊按钮排序项
@property (nonatomic, strong) NSMutableArray *groupHiddenButtons; // 群聊隐藏的按钮

@property (nonatomic, strong) UIBarButtonItem *editButton; // 编辑按钮
@end

@implementation CSChatAttachmentSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"聊天按钮布局";
    
    // 设置UI样式
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 加载当前启用状态
    self.isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kChatAttachmentLayoutEnabledKey];
    self.isOfficialSortEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kChatAttachmentOfficialSortEnabledKey];
    self.isPrivateSortEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kChatAttachmentPrivateSortEnabledKey];
    self.isGroupSortEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kChatAttachmentGroupSortEnabledKey];
    
    // 初始化隐藏按钮数组
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.officialHiddenButtons = [NSMutableArray arrayWithArray:[defaults arrayForKey:kChatAttachmentOfficialHiddenButtonsKey] ?: @[]];
    self.privateHiddenButtons = [NSMutableArray arrayWithArray:[defaults arrayForKey:kChatAttachmentPrivateHiddenButtonsKey] ?: @[]];
    self.groupHiddenButtons = [NSMutableArray arrayWithArray:[defaults arrayForKey:kChatAttachmentGroupHiddenButtonsKey] ?: @[]];
    
    // 添加编辑按钮
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"排序"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(toggleEditMode)];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    // 更新编辑按钮状态
    [self updateEditButtonState];
    
    // 设置数据
    [self setupData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 检查是否已经显示过说明
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShownTutorial = [defaults boolForKey:kChatAttachmentHasShownTutorialKey];
    
    // 如果是首次显示，自动弹出说明
    if (!hasShownTutorial) {
        // 显示说明并标记为已显示
        [defaults setBool:YES forKey:kChatAttachmentHasShownTutorialKey];
        [defaults synchronize];
        
        // 显示功能说明弹窗
        [self showFeatureExplanation];
    }
}

- (void)toggleEditMode {
    // 切换编辑模式
    BOOL isEditing = !self.tableView.isEditing;
    [self.tableView setEditing:isEditing animated:YES];
    
    // 更新按钮标题
    self.editButton.title = isEditing ? @"完成" : @"排序";
}

- (void)updateEditButtonState {
    // 如果总开关启用，并且公众号排序、私聊排序或群聊排序至少一个启用时才启用编辑按钮
    BOOL shouldEnableEdit = self.isEnabled && (self.isOfficialSortEnabled || self.isPrivateSortEnabled || self.isGroupSortEnabled);
    self.editButton.enabled = shouldEnableEdit;
}

- (void)setupData {
    // 获取当前启用状态和设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.isEnabled = [defaults boolForKey:kChatAttachmentLayoutEnabledKey];
    
    // 获取列数设置，默认为5列
    int columns = [defaults objectForKey:kChatAttachmentColumnsKey] ? 
                 [defaults integerForKey:kChatAttachmentColumnsKey] : kDefaultColumns;
    
    // 获取间距设置，默认为10.0点
    float spacing = [defaults objectForKey:kChatAttachmentSpacingKey] ? 
                   [defaults floatForKey:kChatAttachmentSpacingKey] : kDefaultSpacing;
    
    // 获取场景显示设置，默认全部开启
    BOOL showInPrivate = [defaults objectForKey:kChatAttachmentShowInPrivateKey] ? 
                        [defaults boolForKey:kChatAttachmentShowInPrivateKey] : YES;
    BOOL showInGroup = [defaults objectForKey:kChatAttachmentShowInGroupKey] ? 
                      [defaults boolForKey:kChatAttachmentShowInGroupKey] : YES;
    BOOL showInOfficial = [defaults objectForKey:kChatAttachmentShowInOfficialKey] ? 
                         [defaults boolForKey:kChatAttachmentShowInOfficialKey] : YES;
    
    // 获取公众号排序设置
    self.isOfficialSortEnabled = [defaults boolForKey:kChatAttachmentOfficialSortEnabledKey];
    
    // 获取私聊排序设置
    self.isPrivateSortEnabled = [defaults boolForKey:kChatAttachmentPrivateSortEnabledKey];
    
    // 获取群聊排序设置
    self.isGroupSortEnabled = [defaults boolForKey:kChatAttachmentGroupSortEnabledKey];
    
    // 创建开关项
    __weak typeof(self) weakSelf = self;
    CSSettingItem *enableItem = [CSSettingItem switchItemWithTitle:@"启用聊天附件2x5布局"
                                                         iconName:@"square.grid.3x2"
                                                        iconColor:[UIColor systemTealColor]
                                                       switchValue:self.isEnabled
                                                  valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [defaults setBool:isOn forKey:kChatAttachmentLayoutEnabledKey];
        [defaults synchronize];
        
        // 更新状态变量
        weakSelf.isEnabled = isOn;
        
        // 发送通知，通知CSChatAttachmentLayout.xm的钩子更新状态
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                            object:nil];
        
        // 更新编辑按钮状态
        [weakSelf updateEditButtonState];
        
        // 刷新表格，更新其他选项的可用状态
        [weakSelf.tableView reloadData];
    }];
    
    // 创建列数设置项
    NSString *columnsStr = [NSString stringWithFormat:@"%d", columns];
    __block CSSettingItem *columnsItem = [CSSettingItem inputItemWithTitle:@"每行列数"
                                                         iconName:@"rectangle.grid.3x2"
                                                        iconColor:[UIColor systemBlueColor]
                                                        inputValue:columnsStr
                                                    inputPlaceholder:@"请输入3-5之间的整数"
                                                   valueChangedBlock:^(NSString *value) {
        // 验证并保存输入值
        int newColumns = [value intValue];
        if (newColumns < kMinColumns) newColumns = kMinColumns;
        if (newColumns > kMaxColumns) newColumns = kMaxColumns;
        
        // 更新设置
        [defaults setInteger:newColumns forKey:kChatAttachmentColumnsKey];
        [defaults synchronize];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged"
                                                          object:nil];
        
        // 简化UI显示，只显示值本身
        columnsItem.inputValue = [NSString stringWithFormat:@"%d", newColumns];
        columnsItem.detail = [NSString stringWithFormat:@"%d", newColumns];
    }];
    
    // 创建间距设置项
    NSString *spacingStr = [NSString stringWithFormat:@"%.1f", spacing];
    __block CSSettingItem *spacingItem = [CSSettingItem inputItemWithTitle:@"按钮间距"
                                                         iconName:@"arrow.left.and.right"
                                                        iconColor:[UIColor systemOrangeColor]
                                                        inputValue:spacingStr
                                                    inputPlaceholder:@"请输入0-20之间的数值"
                                                   valueChangedBlock:^(NSString *value) {
        // 验证并保存输入值
        float newSpacing = [value floatValue];
        if (newSpacing < kMinSpacing) newSpacing = kMinSpacing;
        if (newSpacing > kMaxSpacing) newSpacing = kMaxSpacing;
        
        // 更新设置
        [defaults setFloat:newSpacing forKey:kChatAttachmentSpacingKey];
        [defaults synchronize];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged"
                                                          object:nil];
        
        // 简化UI显示，只显示值本身
        spacingItem.inputValue = [NSString stringWithFormat:@"%.1f", newSpacing];
        spacingItem.detail = [NSString stringWithFormat:@"%.1f", newSpacing];
    }];
    
    // 创建场景控制项 - 私聊
    CSSettingItem *privateItem = [CSSettingItem switchItemWithTitle:@"在私聊中显示"
                                                          iconName:@"person"
                                                         iconColor:[UIColor systemBlueColor]
                                                        switchValue:showInPrivate
                                                   valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kChatAttachmentShowInPrivateKey];
        [defaults synchronize];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                          object:nil];
    }];
    
    // 创建场景控制项 - 群聊
    CSSettingItem *groupItem = [CSSettingItem switchItemWithTitle:@"在群聊中显示"
                                                        iconName:@"person.3"
                                                       iconColor:[UIColor systemGreenColor]
                                                      switchValue:showInGroup
                                                 valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kChatAttachmentShowInGroupKey];
        [defaults synchronize];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                          object:nil];
    }];
    
    // 创建场景控制项 - 公众号
    CSSettingItem *officialItem = [CSSettingItem switchItemWithTitle:@"在公众号中显示"
                                                           iconName:@"megaphone"
                                                          iconColor:[UIColor systemOrangeColor]
                                                         switchValue:showInOfficial
                                                    valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kChatAttachmentShowInOfficialKey];
        [defaults synchronize];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                          object:nil];
    }];
    
    // 创建公众号排序开关项
    CSSettingItem *officialSortItem = [CSSettingItem switchItemWithTitle:@"公众号按钮自定义排序"
                                                               iconName:@"arrow.up.arrow.down"
                                                              iconColor:[UIColor systemPurpleColor]
                                                             switchValue:self.isOfficialSortEnabled
                                                        valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [defaults setBool:isOn forKey:kChatAttachmentOfficialSortEnabledKey];
        [defaults synchronize];
        
        // 更新状态变量
        weakSelf.isOfficialSortEnabled = isOn;
        
        // 更新编辑按钮状态
        [weakSelf updateEditButtonState];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                          object:nil];
        
        // 刷新表格，更新排序列表的可见性
        [weakSelf.tableView reloadData];
    }];
    
    // 创建私聊排序开关项
    CSSettingItem *privateSortItem = [CSSettingItem switchItemWithTitle:@"私聊按钮自定义排序"
                                                              iconName:@"arrow.up.arrow.down"
                                                             iconColor:[UIColor systemBlueColor]
                                                            switchValue:self.isPrivateSortEnabled
                                                       valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [defaults setBool:isOn forKey:kChatAttachmentPrivateSortEnabledKey];
        [defaults synchronize];
        
        // 更新状态变量
        weakSelf.isPrivateSortEnabled = isOn;
        
        // 更新编辑按钮状态
        [weakSelf updateEditButtonState];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                          object:nil];
        
        // 刷新表格，更新排序列表的可见性
        [weakSelf.tableView reloadData];
    }];
    
    // 创建群聊排序开关项
    CSSettingItem *groupSortItem = [CSSettingItem switchItemWithTitle:@"群聊按钮自定义排序"
                                                             iconName:@"arrow.up.arrow.down"
                                                            iconColor:[UIColor systemGreenColor]
                                                           switchValue:self.isGroupSortEnabled
                                                      valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        [defaults setBool:isOn forKey:kChatAttachmentGroupSortEnabledKey];
        [defaults synchronize];
        
        // 更新状态变量
        weakSelf.isGroupSortEnabled = isOn;
        
        // 更新编辑按钮状态
        [weakSelf updateEditButtonState];
        
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                          object:nil];
        
        // 刷新表格，更新排序列表的可见性
        [weakSelf.tableView reloadData];
    }];
    
    // 创建公众号按钮排序项
    [self setupOfficialSortItems];
    
    // 创建私聊按钮排序项
    [self setupPrivateSortItems];
    
    // 创建群聊按钮排序项
    [self setupGroupSortItems];
    
    // 创建说明项
    CSSettingItem *descriptionItem = [CSSettingItem itemWithTitle:@"功能说明"
                                                        iconName:@"info.circle"
                                                       iconColor:[UIColor systemBlueColor]
                                                          detail:@"点击查看"];
    
    // 创建分组
    CSSettingSection *mainSection = [CSSettingSection sectionWithHeader:@"基本设置" 
                                                                items:@[enableItem]];
    
    // 保存布局设置分组的引用
    self.layoutSection = [CSSettingSection sectionWithHeader:@"布局设置" 
                                                     items:@[columnsItem, spacingItem]];
    
    // 保存场景控制分组的引用
    self.sceneSection = [CSSettingSection sectionWithHeader:@"场景控制" 
                                                    items:@[privateItem, groupItem, officialItem]];
    
    // 创建排序开关分组
    CSSettingSection *sortSwitchSection = [CSSettingSection sectionWithHeader:@"排序设置" 
                                                                     items:@[officialSortItem, privateSortItem, groupSortItem]];
    
    // 创建排序项列表分组并保存引用
    __weak typeof(self) weakSelf2 = self;
    self.officialSortSection = [CSSettingSection sectionWithHeader:@"公众号排序"
                                                            items:self.officialSortItems
                                                 allowsReordering:YES
                                                orderChangedBlock:^(NSArray<CSSettingItem *> *items) {
        // 保存新的排序
        [weakSelf2 saveOfficialSortOrder:items];
    }];
    
    // 创建私聊排序项列表
    self.privateSortSection = [CSSettingSection sectionWithHeader:@"私聊排序"
                                                          items:self.privateSortItems
                                               allowsReordering:YES
                                              orderChangedBlock:^(NSArray<CSSettingItem *> *items) {
        // 保存新的排序
        [weakSelf2 savePrivateSortOrder:items];
    }];
    
    // 创建群聊排序项列表
    self.groupSortSection = [CSSettingSection sectionWithHeader:@"群聊排序"
                                                        items:self.groupSortItems
                                             allowsReordering:YES
                                            orderChangedBlock:^(NSArray<CSSettingItem *> *items) {
        // 保存新的排序
        [weakSelf2 saveGroupSortOrder:items];
    }];
    
    CSSettingSection *infoSection = [CSSettingSection sectionWithHeader:@"说明" 
                                                                items:@[descriptionItem]];
    
    self.sections = @[mainSection, self.layoutSection, self.sceneSection, sortSwitchSection, 
                     self.officialSortSection, self.privateSortSection, self.groupSortSection, infoSection];
}

- (void)setupOfficialSortItems {
    // 初始化排序项数组
    self.officialSortItems = [NSMutableArray array];
    
    // 获取已保存的排序顺序
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedOrder = [defaults arrayForKey:kChatAttachmentOfficialSortOrderKey];
    
    // 定义按钮信息 - 使用元组 (标识符, 标题, 图标名称, 图标颜色)
    NSArray *buttonInfos = @[
        @[@(kTagPhoto), @"照片", @"photo", [UIColor systemBlueColor]],
        @[@(kTagCamera), @"拍摄", @"camera", [UIColor systemRedColor]],
        @[@(kTagLocation), @"位置", @"location", [UIColor systemYellowColor]],
        @[@(kTagVoiceInput), @"语音输入", @"mic", [UIColor systemPurpleColor]],
        @[@(kTagFavorite), @"收藏", @"star", [UIColor systemOrangeColor]],
        @[@(kTagContact), @"个人名片", @"person.crop.square", [UIColor systemTealColor]]
    ];
    
    // 如果有保存的排序，按照保存的顺序创建项
    if (savedOrder && savedOrder.count == buttonInfos.count) {
        // 遍历保存的排序顺序
        for (NSNumber *identifier in savedOrder) {
            // 查找对应的按钮信息
            for (NSArray *info in buttonInfos) {
                NSNumber *buttonId = info[0];
                if ([buttonId isEqual:identifier]) {
                    // 创建排序项
                    CSSettingItem *item = [CSSettingItem draggableItemWithTitle:info[1]
                                                                    iconName:info[2]
                                                                   iconColor:info[3]
                                                                    identifier:[buttonId integerValue]
                                                                    sortIndex:self.officialSortItems.count];
                    
                    // 检查按钮是否被隐藏，添加标记
                    if ([self.officialHiddenButtons containsObject:buttonId]) {
                        item.detail = @"已隐藏";
                    }
                    
                    [self.officialSortItems addObject:item];
                    break;
                }
            }
        }
    } else {
        // 如果没有保存的排序或者数量不匹配，使用默认顺序
        for (NSArray *info in buttonInfos) {
            CSSettingItem *item = [CSSettingItem draggableItemWithTitle:info[1]
                                                            iconName:info[2]
                                                           iconColor:info[3]
                                                            identifier:[info[0] integerValue]
                                                            sortIndex:self.officialSortItems.count];
            
            // 检查按钮是否被隐藏，添加标记
            if ([self.officialHiddenButtons containsObject:info[0]]) {
                item.detail = @"已隐藏";
            }
            
            [self.officialSortItems addObject:item];
        }
        
        // 保存默认排序
        [self saveOfficialSortOrder:self.officialSortItems];
    }
}

- (void)saveOfficialSortOrder:(NSArray<CSSettingItem *> *)items {
    // 创建标识符数组
    NSMutableArray *identifiers = [NSMutableArray array];
    for (CSSettingItem *item in items) {
        [identifiers addObject:@(item.identifier)];
    }
    
    // 保存到UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:identifiers forKey:kChatAttachmentOfficialSortOrderKey];
    [defaults synchronize];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                      object:nil];
}

// 设置私聊按钮排序项
- (void)setupPrivateSortItems {
    // 初始化排序项数组
    self.privateSortItems = [NSMutableArray array];
    
    // 获取已保存的排序顺序
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedOrder = [defaults arrayForKey:kChatAttachmentPrivateSortOrderKey];
    
    // 定义按钮信息 - 使用元组 (标识符, 标题, 图标名称, 图标颜色)
    NSArray *buttonInfos = @[
        @[@(kPrivateTagPhoto), @"照片", @"photo", [UIColor systemBlueColor]],
        @[@(kPrivateTagCamera), @"拍摄", @"camera", [UIColor systemRedColor]],
        @[@(kPrivateTagVideoCall), @"视频通话", @"video", [UIColor systemGreenColor]],
        @[@(kPrivateTagLocation), @"位置", @"location", [UIColor systemYellowColor]],
        @[@(kPrivateTagRedPacket), @"红包", @"envelope", [UIColor systemRedColor]],
        @[@(kPrivateTagGift), @"礼物", @"gift", [UIColor systemPinkColor]],
        @[@(kPrivateTagTransfer), @"转账", @"dollarsign.circle", [UIColor systemGreenColor]],
        @[@(kPrivateTagVoiceInput), @"语音输入", @"mic", [UIColor systemPurpleColor]],
        @[@(kPrivateTagFavorite), @"收藏", @"star", [UIColor systemOrangeColor]],
        @[@(kPrivateTagContact), @"个人名片", @"person.crop.square", [UIColor systemTealColor]],
        @[@(kPrivateTagFile), @"文件", @"doc", [UIColor systemBlueColor]],
        @[@(kPrivateTagCard), @"卡券", @"creditcard", [UIColor systemIndigoColor]],
        @[@(kPrivateTagMusic), @"音乐", @"music.note", [UIColor systemPurpleColor]]
    ];
    
    // 如果有保存的排序，按照保存的顺序创建项
    if (savedOrder && savedOrder.count == buttonInfos.count) {
        // 遍历保存的排序顺序
        for (NSNumber *identifier in savedOrder) {
            // 查找对应的按钮信息
            for (NSArray *info in buttonInfos) {
                NSNumber *buttonId = info[0];
                if ([buttonId isEqual:identifier]) {
                    // 创建排序项
                    CSSettingItem *item = [CSSettingItem draggableItemWithTitle:info[1]
                                                                      iconName:info[2]
                                                                     iconColor:info[3]
                                                                      identifier:[buttonId integerValue]
                                                                      sortIndex:self.privateSortItems.count];
                    
                    // 检查按钮是否被隐藏，添加标记
                    if ([self.privateHiddenButtons containsObject:buttonId]) {
                        item.detail = @"已隐藏";
                    }
                    
                    [self.privateSortItems addObject:item];
                    break;
                }
            }
        }
    } else {
        // 如果没有保存的排序或者数量不匹配，使用默认顺序
        for (NSArray *info in buttonInfos) {
            CSSettingItem *item = [CSSettingItem draggableItemWithTitle:info[1]
                                                              iconName:info[2]
                                                             iconColor:info[3]
                                                              identifier:[info[0] integerValue]
                                                              sortIndex:self.privateSortItems.count];
            
            // 检查按钮是否被隐藏，添加标记
            if ([self.privateHiddenButtons containsObject:info[0]]) {
                item.detail = @"已隐藏";
            }
            
            [self.privateSortItems addObject:item];
        }
        
        // 保存默认排序
        [self savePrivateSortOrder:self.privateSortItems];
    }
}

// 保存私聊按钮排序
- (void)savePrivateSortOrder:(NSArray<CSSettingItem *> *)items {
    // 创建标识符数组
    NSMutableArray *identifiers = [NSMutableArray array];
    for (CSSettingItem *item in items) {
        [identifiers addObject:@(item.identifier)];
    }
    
    // 保存到UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:identifiers forKey:kChatAttachmentPrivateSortOrderKey];
    [defaults synchronize];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                      object:nil];
}

// 设置群聊按钮排序项
- (void)setupGroupSortItems {
    // 初始化排序项数组
    self.groupSortItems = [NSMutableArray array];
    
    // 获取已保存的排序顺序
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedOrder = [defaults arrayForKey:kChatAttachmentGroupSortOrderKey];
    
    // 定义按钮信息 - 使用元组 (标识符, 标题, 图标名称, 图标颜色)
    NSArray *buttonInfos = @[
        @[@(kGroupTagPhoto), @"照片", @"photo", [UIColor systemBlueColor]],
        @[@(kGroupTagCamera), @"拍摄", @"camera", [UIColor systemRedColor]],
        @[@(kGroupTagVoiceCall), @"语音通话", @"phone", [UIColor systemGreenColor]],
        @[@(kGroupTagLocation), @"位置", @"location", [UIColor systemYellowColor]],
        @[@(kGroupTagRedPacket), @"红包", @"envelope", [UIColor systemRedColor]],
        @[@(kGroupTagGift), @"礼物", @"gift", [UIColor systemPinkColor]],
        @[@(kGroupTagTransfer), @"转账", @"dollarsign.circle", [UIColor systemGreenColor]],
        @[@(kGroupTagVoiceInput), @"语音输入", @"mic", [UIColor systemPurpleColor]],
        @[@(kGroupTagFavorite), @"收藏", @"star", [UIColor systemOrangeColor]],
        @[@(kGroupTagGroupTool), @"群工具", @"gear", [UIColor systemGrayColor]],
        @[@(kGroupTagChain), @"接龙", @"link", [UIColor systemTealColor]],
        @[@(kGroupTagLiveStream), @"直播", @"tv", [UIColor systemRedColor]],
        @[@(kGroupTagContact), @"个人名片", @"person.crop.square", [UIColor systemTealColor]],
        @[@(kGroupTagFile), @"文件", @"doc", [UIColor systemBlueColor]],
        @[@(kGroupTagCard), @"卡券", @"creditcard", [UIColor systemIndigoColor]],
        @[@(kGroupTagMusic), @"音乐", @"music.note", [UIColor systemPurpleColor]]
    ];
    
    // 如果有保存的排序，按照保存的顺序创建项
    if (savedOrder && savedOrder.count == buttonInfos.count) {
        // 遍历保存的排序顺序
        for (NSNumber *identifier in savedOrder) {
            // 查找对应的按钮信息
            for (NSArray *info in buttonInfos) {
                NSNumber *buttonId = info[0];
                if ([buttonId isEqual:identifier]) {
                    // 创建排序项
                    CSSettingItem *item = [CSSettingItem draggableItemWithTitle:info[1]
                                                                      iconName:info[2]
                                                                     iconColor:info[3]
                                                                      identifier:[buttonId integerValue]
                                                                      sortIndex:self.groupSortItems.count];
                    
                    // 检查按钮是否被隐藏，添加标记
                    if ([self.groupHiddenButtons containsObject:buttonId]) {
                        item.detail = @"已隐藏";
                    }
                    
                    [self.groupSortItems addObject:item];
                    break;
                }
            }
        }
    } else {
        // 如果没有保存的排序或者数量不匹配，使用默认顺序
        for (NSArray *info in buttonInfos) {
            CSSettingItem *item = [CSSettingItem draggableItemWithTitle:info[1]
                                                              iconName:info[2]
                                                             iconColor:info[3]
                                                              identifier:[info[0] integerValue]
                                                              sortIndex:self.groupSortItems.count];
            
            // 检查按钮是否被隐藏，添加标记
            if ([self.groupHiddenButtons containsObject:info[0]]) {
                item.detail = @"已隐藏";
            }
            
            [self.groupSortItems addObject:item];
        }
        
        // 保存默认排序
        [self saveGroupSortOrder:self.groupSortItems];
    }
}

// 保存群聊按钮排序
- (void)saveGroupSortOrder:(NSArray<CSSettingItem *> *)items {
    // 创建标识符数组
    NSMutableArray *identifiers = [NSMutableArray array];
    for (CSSettingItem *item in items) {
        [identifiers addObject:@(item.identifier)];
    }
    
    // 保存到UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:identifiers forKey:kChatAttachmentGroupSortOrderKey];
    [defaults synchronize];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                      object:nil];
}

#pragma mark - 动态section管理

// 返回当前应该显示的section数组
- (NSArray<CSSettingSection *> *)visibleSections {
    NSMutableArray *visibleSections = [NSMutableArray array];
    
    // 主设置section (总开关) - 始终显示
    [visibleSections addObject:self.sections[0]];
    
    // 如果总开关开启，显示布局设置section和场景控制section
    if (self.isEnabled) {
        [visibleSections addObject:self.layoutSection]; // 布局设置
        [visibleSections addObject:self.sceneSection]; // 场景控制
        
        // 排序开关section - 总开关开启时显示
        [visibleSections addObject:self.sections[3]];
        
        // 如果对应排序开关开启，显示排序列表section
        if (self.isOfficialSortEnabled) {
            [visibleSections addObject:self.officialSortSection];
        }
        
        if (self.isPrivateSortEnabled) {
            [visibleSections addObject:self.privateSortSection];
        }
        
        if (self.isGroupSortEnabled) {
            [visibleSections addObject:self.groupSortSection];
        }
    }
    
    // 说明section - 始终显示
    [visibleSections addObject:self.sections.lastObject];
    
    return visibleSections;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self visibleSections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CSSettingSection *settingSection = [self visibleSections][section];
    return settingSection.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CSSettingTableViewCell reuseIdentifier]];
    
    // 获取当前项数据并配置cell
    CSSettingItem *item = [self visibleSections][indexPath.section].items[indexPath.row];
    [cell configureWithItem:item];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self visibleSections][section].header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取选中的分区
    CSSettingSection *section = [self visibleSections][indexPath.section];
    // 获取选中的项
    CSSettingItem *item = section.items[indexPath.row];
    
    // 处理输入类型项的点击
    if (item.itemType == CSSettingItemTypeInput) {
        // 显示输入弹窗
        [CSUIHelper showInputAlertWithTitle:item.title
                                  message:nil
                              initialValue:item.inputValue
                              placeholder:item.inputPlaceholder
                         inViewController:self
                               completion:^(NSString *value) {
            // 保存原始值用于比较
            NSString *originalValue = item.inputValue;
            
            // 调用回调函数进行数据存储
            if (item.inputValueChanged) {
                item.inputValueChanged(value);
            }
            
            // 简化UI显示，只显示值本身
            if ([item.title isEqualToString:@"每行列数"]) {
                // 验证并调整值
                int newValue = [value intValue];
                if (newValue < kMinColumns) newValue = kMinColumns;
                if (newValue > kMaxColumns) newValue = kMaxColumns;
                
                // 简化UI显示，只显示值本身
                item.detail = [NSString stringWithFormat:@"%d", newValue];
                item.inputValue = [NSString stringWithFormat:@"%d", newValue];
            } 
            else if ([item.title isEqualToString:@"按钮间距"]) {
                // 验证并调整值
                float newValue = [value floatValue];
                if (newValue < kMinSpacing) newValue = kMinSpacing;
                if (newValue > kMaxSpacing) newValue = kMaxSpacing;
                
                // 简化UI显示，只显示值本身
                item.detail = [NSString stringWithFormat:@"%.1f", newValue];
                item.inputValue = [NSString stringWithFormat:@"%.1f", newValue];
            }
            
            // 如果值被修改，发送通知更新界面
            if (![originalValue isEqualToString:item.inputValue]) {
                // 发送通知，通知CSChatAttachmentLayout.xm的钩子更新状态
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged"
                                                                  object:nil];
            }
            
            // 手动刷新单元格
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        return;
    }
    
    // 如果是操作项，执行操作
    if ([item canPerformAction]) {
        [item performAction];
    }
    
    // 如果是功能说明，显示说明
    if ([item.title isEqualToString:@"功能说明"]) {
        [self showFeatureExplanation];
    }
}

// 处理左滑删除操作
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 只有在编辑模式下排序表格中的项才允许左滑删除
    if (!tableView.isEditing) {
        return nil;
    }
    
    // 获取当前分区
    CSSettingSection *section = self.sections[indexPath.section];
    
    // 判断是不是排序分区
    BOOL isOfficialSection = (section == self.officialSortSection);
    BOOL isPrivateSection = (section == self.privateSortSection);
    BOOL isGroupSection = (section == self.groupSortSection);
    
    // 只有排序分区允许左滑操作
    if (!(isOfficialSection || isPrivateSection || isGroupSection)) {
        return nil;
    }
    
    // 获取当前项
    CSSettingItem *item = section.items[indexPath.row];
    
    // 判断按钮是否已经隐藏
    BOOL isHidden = [self isButtonHidden:item.identifier inSection:section];
    
    // 创建操作
    NSString *actionTitle = isHidden ? @"取消隐藏" : @"隐藏";
    UIColor *actionColor = isHidden ? [UIColor systemGreenColor] : [UIColor systemRedColor];
    
    // 创建左滑操作
    __weak typeof(self) weakSelf = self;
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal 
                                                                    title:actionTitle
                                                                  handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // 根据按钮类型和当前状态切换隐藏/显示状态
        if (isOfficialSection) {
            [weakSelf toggleHideButton:item.identifier inSection:weakSelf.officialSortSection];
        } else if (isPrivateSection) {
            [weakSelf toggleHideButton:item.identifier inSection:weakSelf.privateSortSection];
        } else if (isGroupSection) {
            [weakSelf toggleHideButton:item.identifier inSection:weakSelf.groupSortSection];
        }
        
        // 完成回调
        completionHandler(YES);
    }];
    
    action.backgroundColor = actionColor;
    
    // 创建配置
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    config.performsFirstActionWithFullSwipe = NO; // 禁用全滑动执行
    
    return config;
}

// 判断按钮是否已隐藏
- (BOOL)isButtonHidden:(NSInteger)buttonId inSection:(CSSettingSection *)section {
    if (section == self.officialSortSection) {
        return [self.officialHiddenButtons containsObject:@(buttonId)];
    } else if (section == self.privateSortSection) {
        return [self.privateHiddenButtons containsObject:@(buttonId)];
    } else if (section == self.groupSortSection) {
        return [self.groupHiddenButtons containsObject:@(buttonId)];
    }
    return NO;
}

// 切换按钮隐藏/显示状态
- (void)toggleHideButton:(NSInteger)buttonId inSection:(CSSettingSection *)section {
    NSMutableArray *hiddenButtons = nil;
    NSString *userDefaultsKey = nil;
    NSMutableArray *sortItems = nil;
    
    // 确定操作的数组和键
    if (section == self.officialSortSection) {
        hiddenButtons = self.officialHiddenButtons;
        userDefaultsKey = kChatAttachmentOfficialHiddenButtonsKey;
        sortItems = self.officialSortItems;
    } else if (section == self.privateSortSection) {
        hiddenButtons = self.privateHiddenButtons;
        userDefaultsKey = kChatAttachmentPrivateHiddenButtonsKey;
        sortItems = self.privateSortItems;
    } else if (section == self.groupSortSection) {
        hiddenButtons = self.groupHiddenButtons;
        userDefaultsKey = kChatAttachmentGroupHiddenButtonsKey;
        sortItems = self.groupSortItems;
    } else {
        return; // 不是有效的分区
    }
    
    // 查找按钮的位置
    NSInteger buttonIndex = -1;
    for (NSInteger i = 0; i < sortItems.count; i++) {
        CSSettingItem *item = sortItems[i];
        if (item.identifier == buttonId) {
            buttonIndex = i;
            break;
        }
    }
    
    if (buttonIndex == -1) {
        return; // 未找到按钮
    }
    
    // 获取当前项目
    CSSettingItem *item = sortItems[buttonIndex];
    
    // 检查是否已隐藏
    BOOL isHidden = [hiddenButtons containsObject:@(buttonId)];
    
    // 切换隐藏状态
    if (isHidden) {
        // 取消隐藏
        [hiddenButtons removeObject:@(buttonId)];
        // 更新UI
        item.detail = nil;
    } else {
        // 隐藏按钮
        [hiddenButtons addObject:@(buttonId)];
        // 更新UI - 直接设置为"已隐藏"
        item.detail = @"已隐藏";
    }
    
    // 保存设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:hiddenButtons forKey:userDefaultsKey];
    [defaults synchronize];
    
    // 发送通知，通知CSChatAttachmentLayout.xm的钩子更新状态
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CSChatAttachmentLayoutSettingsChanged" 
                                                      object:nil];
    
    // 刷新表格
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate 拖动排序相关方法

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // 只允许排序分组中的行进行编辑
    CSSettingSection *section = [self visibleSections][indexPath.section];
    return section.allowsReordering;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // 只允许排序分组中的行进行移动
    CSSettingSection *section = [self visibleSections][indexPath.section];
    return section.allowsReordering;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // 确保只在同一分组内移动
    if (sourceIndexPath.section != destinationIndexPath.section) {
        return;
    }
    
    // 获取分组
    CSSettingSection *section = [self visibleSections][sourceIndexPath.section];
    if (!section.allowsReordering) {
        return;
    }
    
    // 更新数据源
    NSMutableArray *items = [NSMutableArray arrayWithArray:section.items];
    CSSettingItem *movedItem = items[sourceIndexPath.row];
    [items removeObjectAtIndex:sourceIndexPath.row];
    [items insertObject:movedItem atIndex:destinationIndexPath.row];
    
    // 更新分组的items
    section.items = items;
    
    // 如果是公众号排序分组，更新排序项引用
    if (section == self.officialSortSection) {
        self.officialSortItems = items;
    }
    // 如果是私聊排序分组，更新排序项引用
    else if (section == self.privateSortSection) {
        self.privateSortItems = items;
    }
    // 如果是群聊排序分组，更新排序项引用
    else if (section == self.groupSortSection) {
        self.groupSortItems = items;
    }
    
    // 更新所有项的排序索引
    for (NSInteger i = 0; i < items.count; i++) {
        CSSettingItem *item = items[i];
        item.sortIndex = i;
    }
    
    // 调用排序变更回调
    if (section.orderChangedBlock) {
        section.orderChangedBlock(items);
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    // 确保只在同一分组内移动
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

// 显示功能说明弹窗
- (void)showFeatureExplanation {
    // 功能说明内容
    NSString *message = @"1. 该功能可将聊天界面底部的附件按钮布局改为居中对齐\n\n"
                        @"2. 支持设置每行3-5列，默认为5列，5列为最佳排序\n\n"
                        @"3. 支持调整按钮间距0-20点，默认为0点\n\n"
                        @"4. 可设置在私聊/群聊/公众号中单独开启或关闭\n\n"
                        @"5. 在公众号、私聊和群聊中可自定义按钮顺序，点击顶部右侧\"排序\"按钮后拖动调整";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"功能说明-看第5条"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加确定按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"我知道了" 
                                              style:UIAlertActionStyleDefault 
                                            handler:nil]];
    
    // 显示弹窗
    [self presentViewController:alert animated:YES completion:nil];
}

@end 