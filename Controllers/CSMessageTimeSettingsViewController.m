#import "CSMessageTimeSettingsViewController.h"
#import "CSSettingTableViewCell.h"

// UserDefaults Key常量
static NSString * const kMessageTimeEnabledKey = @"com.wechat.enhance.messageTime.enabled";
static NSString * const kMessageTimeFontSizeKey = @"com.wechat.enhance.messageTime.fontSize";
static NSString * const kMessageTimeTextColorKey = @"com.wechat.enhance.messageTime.textColor";
static NSString * const kMessageTimeBackgroundColorKey = @"com.wechat.enhance.messageTime.backgroundColor";
static NSString * const kMessageTimeCornerRadiusKey = @"com.wechat.enhance.messageTime.cornerRadius";
static NSString * const kMessageTimeTextAlphaKey = @"com.wechat.enhance.messageTime.textAlpha";
static NSString * const kMessageTimeBackgroundAlphaKey = @"com.wechat.enhance.messageTime.backgroundAlpha";
// 显示格式控制
static NSString * const kMessageTimeShowYearKey = @"com.wechat.enhance.messageTime.showYear";
static NSString * const kMessageTimeShowMonthKey = @"com.wechat.enhance.messageTime.showMonth";
static NSString * const kMessageTimeShowDayKey = @"com.wechat.enhance.messageTime.showDay";
static NSString * const kMessageTimeShowHourKey = @"com.wechat.enhance.messageTime.showHour";
static NSString * const kMessageTimeShowMinuteKey = @"com.wechat.enhance.messageTime.showMinute";
static NSString * const kMessageTimeShowSecondKey = @"com.wechat.enhance.messageTime.showSecond";
// 位置控制
static NSString * const kMessageTimeShowBelowAvatarKey = @"com.wechat.enhance.messageTime.showBelowAvatar";
// 字体加粗控制
static NSString * const kMessageTimeBoldFontKey = @"com.wechat.enhance.messageTime.boldFont";

// 默认值
static CGFloat const kDefaultFontSize = 7.0f;      // 字体大小
static CGFloat const kDefaultCornerRadius = 8.0f;  // 圆角大小
static CGFloat const kDefaultTextAlpha = 0.8f;    // 文字透明度
static CGFloat const kDefaultBackgroundAlpha = 0.8f; // 背景透明度
static CGFloat const kMaxLabelWidth = 90.0f; // 时间标签最大宽度

@interface CSMessageTimeSettingsViewController () <UIColorPickerViewControllerDelegate>
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) BOOL colorTagTextColor; // 标记当前选择的是文字颜色还是背景颜色
@end

@implementation CSMessageTimeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航标题
    self.title = @"信息时间";
    
    // 设置UI样式
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 加载保存的颜色
    [self loadSavedColors];
    
    // 设置数据
    [self setupData];
}

- (void)loadSavedColors {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 加载文字颜色
    NSData *textColorData = [defaults objectForKey:kMessageTimeTextColorKey];
    if (textColorData) {
        NSError *error = nil;
        self.textColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:textColorData error:&error];
        if (error) {
            // 如果解档失败，使用默认灰色
            self.textColor = [UIColor colorWithWhite:0.5 alpha:kDefaultTextAlpha];
        }
    } else {
        // 默认灰色
        self.textColor = [UIColor colorWithWhite:0.5 alpha:kDefaultTextAlpha];
    }
    
    // 加载背景颜色
    NSData *bgColorData = [defaults objectForKey:kMessageTimeBackgroundColorKey];
    if (bgColorData) {
        NSError *error = nil;
        self.backgroundColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:bgColorData error:&error];
        if (error) {
            // 如果解档失败，使用透明色
            self.backgroundColor = [UIColor clearColor];
        }
    } else {
        // 默认透明色
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setupData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 基本设置组
    CSSettingItem *enableItem = [CSSettingItem switchItemWithTitle:@"显示消息时间" 
                                                         iconName:@"clock.fill" 
                                                        iconColor:[UIColor systemBlueColor] 
                                                      switchValue:[defaults boolForKey:kMessageTimeEnabledKey] 
                                                valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeEnabledKey];
        
        // 当总开关首次打开时，默认打开时分秒
        if (isOn) {
            // 如果之前没有打开过任何时间选项，默认开启时分秒
            if (![defaults boolForKey:kMessageTimeShowHourKey] && 
                ![defaults boolForKey:kMessageTimeShowMinuteKey] && 
                ![defaults boolForKey:kMessageTimeShowSecondKey]) {
                [defaults setBool:YES forKey:kMessageTimeShowHourKey];
                [defaults setBool:YES forKey:kMessageTimeShowMinuteKey];
                [defaults setBool:YES forKey:kMessageTimeShowSecondKey];
            }
        }
        
        [defaults synchronize];
        
        // 根据开关状态刷新整个表格，显示或隐藏样式设置和预览区域
        [self.tableView reloadData];
    }];
    
    // 创建基本设置组
    CSSettingSection *basicSection = [CSSettingSection sectionWithHeader:@"基本设置" 
                                                                 items:@[enableItem]];
    
    // 显示位置区
    CSSettingItem *belowAvatarItem = [CSSettingItem switchItemWithTitle:@"显示在头像下方" 
                                                             iconName:@"person.crop.circle.badge.clock" 
                                                            iconColor:[UIColor systemIndigoColor] 
                                                          switchValue:[defaults boolForKey:kMessageTimeShowBelowAvatarKey] 
                                                    valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeShowBelowAvatarKey];
        [defaults synchronize];
        // 刷新预览区域
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    // 添加加粗字体选项
    CSSettingItem *boldFontItem = [CSSettingItem switchItemWithTitle:@"使用粗体字" 
                                                          iconName:@"bold" 
                                                         iconColor:[UIColor systemOrangeColor] 
                                                       switchValue:[defaults boolForKey:kMessageTimeBoldFontKey] 
                                                 valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeBoldFontKey];
        [defaults synchronize];
        // 刷新预览区域
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    CSSettingSection *positionSection = [CSSettingSection sectionWithHeader:@"显示位置" 
                                                                 items:@[belowAvatarItem, boldFontItem]];
    
    // 创建时间格式设置项 - 默认值设置，如果没有存储过设置
    if (![defaults objectForKey:kMessageTimeShowHourKey]) {
        [defaults setBool:YES forKey:kMessageTimeShowHourKey];
    }
    if (![defaults objectForKey:kMessageTimeShowMinuteKey]) {
        [defaults setBool:YES forKey:kMessageTimeShowMinuteKey];
    }
    if (![defaults objectForKey:kMessageTimeShowSecondKey]) {
        [defaults setBool:YES forKey:kMessageTimeShowSecondKey];
    }
    if (![defaults objectForKey:kMessageTimeShowYearKey]) {
        [defaults setBool:NO forKey:kMessageTimeShowYearKey];
    }
    if (![defaults objectForKey:kMessageTimeShowMonthKey]) {
        [defaults setBool:NO forKey:kMessageTimeShowMonthKey];
    }
    if (![defaults objectForKey:kMessageTimeShowDayKey]) {
        [defaults setBool:NO forKey:kMessageTimeShowDayKey];
    }
    [defaults synchronize];
    
    // 年月日开关项
    CSSettingItem *showYearItem = [CSSettingItem switchItemWithTitle:@"显示年份" 
                                                           iconName:@"calendar" 
                                                          iconColor:[UIColor systemIndigoColor] 
                                                        switchValue:[defaults boolForKey:kMessageTimeShowYearKey] 
                                                  valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeShowYearKey];
        [defaults synchronize];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    CSSettingItem *showMonthItem = [CSSettingItem switchItemWithTitle:@"显示月份" 
                                                            iconName:@"calendar.badge.clock" 
                                                           iconColor:[UIColor systemPurpleColor] 
                                                         switchValue:[defaults boolForKey:kMessageTimeShowMonthKey] 
                                                   valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeShowMonthKey];
        [defaults synchronize];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    CSSettingItem *showDayItem = [CSSettingItem switchItemWithTitle:@"显示日期" 
                                                          iconName:@"calendar.day.timeline.left" 
                                                         iconColor:[UIColor systemRedColor] 
                                                       switchValue:[defaults boolForKey:kMessageTimeShowDayKey] 
                                                 valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeShowDayKey];
        [defaults synchronize];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    // 时分秒开关项
    CSSettingItem *showHourItem = [CSSettingItem switchItemWithTitle:@"显示小时" 
                                                           iconName:@"clock" 
                                                          iconColor:[UIColor systemBlueColor] 
                                                        switchValue:[defaults boolForKey:kMessageTimeShowHourKey] 
                                                  valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeShowHourKey];
        [defaults synchronize];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    CSSettingItem *showMinuteItem = [CSSettingItem switchItemWithTitle:@"显示分钟" 
                                                             iconName:@"timer" 
                                                            iconColor:[UIColor systemGreenColor] 
                                                          switchValue:[defaults boolForKey:kMessageTimeShowMinuteKey] 
                                                    valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeShowMinuteKey];
        [defaults synchronize];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    CSSettingItem *showSecondItem = [CSSettingItem switchItemWithTitle:@"显示秒数" 
                                                             iconName:@"stopwatch" 
                                                            iconColor:[UIColor systemOrangeColor] 
                                                          switchValue:[defaults boolForKey:kMessageTimeShowSecondKey] 
                                                    valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kMessageTimeShowSecondKey];
        [defaults synchronize];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    // 创建时间格式组
    NSArray *formatItems = @[showYearItem, showMonthItem, showDayItem, showHourItem, showMinuteItem, showSecondItem];
    CSSettingSection *formatSection = [CSSettingSection sectionWithHeader:@"时间格式" 
                                                                   items:formatItems];
    
    // 样式设置组
    CGFloat savedFontSize = [defaults floatForKey:kMessageTimeFontSizeKey];
    if (savedFontSize == 0) { // 如果为0，表示未设置过，使用默认值
        savedFontSize = kDefaultFontSize;
    }
    
    CSSettingItem *fontSizeItem = [CSSettingItem itemWithTitle:@"字体大小" 
                                                     iconName:@"textformat.size" 
                                                    iconColor:[UIColor systemOrangeColor] 
                                                      detail:[NSString stringWithFormat:@"%.1f", savedFontSize]];
    
    CSSettingItem *textColorItem = [CSSettingItem itemWithTitle:@"文字颜色" 
                                                      iconName:@"paintbrush.fill" 
                                                     iconColor:[UIColor systemRedColor] 
                                                       detail:@""];
    
    CSSettingItem *backgroundColorItem = [CSSettingItem itemWithTitle:@"背景颜色" 
                                                           iconName:@"square.fill" 
                                                          iconColor:[UIColor systemGreenColor] 
                                                            detail:@""];
    
    CGFloat savedCornerRadius = [defaults floatForKey:kMessageTimeCornerRadiusKey];
    if (savedCornerRadius == 0) { // 如果为0，可能未设置过，使用默认值
        savedCornerRadius = kDefaultCornerRadius;
    }
    
    CSSettingItem *cornerRadiusItem = [CSSettingItem itemWithTitle:@"圆角大小" 
                                                        iconName:@"square.on.circle" 
                                                       iconColor:[UIColor systemPurpleColor] 
                                                         detail:[NSString stringWithFormat:@"%.1f", savedCornerRadius]];
    
    // 文字透明度
    CGFloat savedTextAlpha = [defaults floatForKey:kMessageTimeTextAlphaKey];
    if (savedTextAlpha == 0) { // 如果为0，可能未设置过，使用默认值
        savedTextAlpha = kDefaultTextAlpha;
    }
    
    CSSettingItem *textAlphaItem = [CSSettingItem itemWithTitle:@"文字透明度" 
                                                      iconName:@"slider.horizontal.3" 
                                                     iconColor:[UIColor systemTealColor] 
                                                       detail:[NSString stringWithFormat:@"%.1f", savedTextAlpha]];
    
    // 背景透明度
    CGFloat savedBgAlpha = [defaults floatForKey:kMessageTimeBackgroundAlphaKey];
    if (savedBgAlpha == 0 && ![defaults objectForKey:kMessageTimeBackgroundAlphaKey]) { // 如果为0且未设置过，使用默认值
        savedBgAlpha = kDefaultBackgroundAlpha;
    }
    
    CSSettingItem *bgAlphaItem = [CSSettingItem itemWithTitle:@"背景透明度" 
                                                    iconName:@"slider.horizontal.below.rectangle" 
                                                   iconColor:[UIColor systemIndigoColor] 
                                                     detail:[NSString stringWithFormat:@"%.1f", savedBgAlpha]];
    
    CSSettingSection *styleSection = [CSSettingSection sectionWithHeader:@"样式设置" 
                                                                 items:@[fontSizeItem,
                                                                        textColorItem,
                                                                        backgroundColorItem,
                                                                        cornerRadiusItem,
                                                                        textAlphaItem,
                                                                        bgAlphaItem]];
    
    // 设置预览组 - 不再使用CSSettingItem，直接在tableView中处理
    CSSettingSection *previewSection = [CSSettingSection sectionWithHeader:@"预览" 
                                                                   items:@[]];
    
    // 将位置区域加入到sections数组中
    self.sections = @[basicSection, positionSection, formatSection, styleSection, previewSection];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 如果功能未启用，只显示基本设置组
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:kMessageTimeEnabledKey]) {
        return 1;
    }
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 预览部分返回1行，尽管items数组为空
    if (section == 4) {
        return 1;
    }
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 预览部分使用特殊处理
    if (indexPath.section == 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreviewCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PreviewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // 清除现有子视图
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
        
        // 创建预览视图
        [self setupPreviewInCell:cell];
        
        return cell;
    }
    
    CSSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CSSettingTableViewCell reuseIdentifier]];
    
    // 获取当前项数据并配置cell
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 为颜色项提前处理，覆盖detail值
    if (indexPath.section == 3) {
        if (indexPath.row == 1) { // 文字颜色
            // 直接使用空字符串，颜色显示将通过accessoryView处理
            item.detail = @"";
        } else if (indexPath.row == 2) { // 背景颜色
            item.detail = @"";
        }
    }
    
    [cell configureWithItem:item];
    
    // 为所有可调整选项添加披露指示器
    if (indexPath.section == 3) {
        // 所有样式设置项都应该有披露指示器
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // 为颜色项添加颜色预览指示器
        if (indexPath.row == 1) { // 文字颜色
            [self addColorIndicator:cell forColor:self.textColor alpha:[self getTextAlpha]];
        } else if (indexPath.row == 2) { // 背景颜色
            [self addColorIndicator:cell forColor:self.backgroundColor alpha:[self getBackgroundAlpha]];
        }
    }
    
    return cell;
}

// 为颜色项添加颜色预览指示器
- (void)addColorIndicator:(CSSettingTableViewCell *)cell forColor:(UIColor *)color alpha:(CGFloat)alpha {
    // 创建颜色指示器
    UIView *colorIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    colorIndicator.layer.cornerRadius = 11;
    colorIndicator.layer.borderWidth = 1;
    colorIndicator.layer.borderColor = [UIColor systemGray4Color].CGColor;
    
    // 使用实际颜色及透明度
    if (color && ![color isEqual:[UIColor clearColor]]) {
        colorIndicator.backgroundColor = [color colorWithAlphaComponent:alpha];
    } else if (alpha > 0) {
        colorIndicator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:alpha];
    } else {
        // 如果是透明色，显示一个标记
        colorIndicator.backgroundColor = [UIColor clearColor];
        
        // 添加一个斜线表示透明
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(6, 6)];
        [linePath addLineToPoint:CGPointMake(16, 16)];
        lineLayer.path = linePath.CGPath;
        lineLayer.strokeColor = [UIColor systemGrayColor].CGColor;
        lineLayer.lineWidth = 1.5;
        [colorIndicator.layer addSublayer:lineLayer];
    }
    
    // 设置为accessoryView之前的视图，保持倒三角
    UIView *accessoryContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [accessoryContainer addSubview:colorIndicator];
    colorIndicator.center = CGPointMake(15, 15);
    
    cell.accessoryView = accessoryContainer;
}

// 设置预览
- (void)setupPreviewInCell:(UITableViewCell *)cell {
    // 设置背景颜色
    cell.contentView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    // 创建预览容器 - 减小高度，只保留一条消息
    UIView *previewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width, 100)];
    previewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [cell.contentView addSubview:previewContainer];
    
    // 创建单个消息预览
    [self createChatPreviewInContainer:previewContainer];
}

- (void)createChatPreviewInContainer:(UIView *)container {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 获取保存的样式设置
    CGFloat fontSize = [defaults floatForKey:kMessageTimeFontSizeKey];
    if (fontSize == 0) fontSize = kDefaultFontSize;
    
    CGFloat textAlpha = [self getTextAlpha];
    CGFloat bgAlpha = [self getBackgroundAlpha];
    
    CGFloat cornerRadius = [defaults floatForKey:kMessageTimeCornerRadiusKey];
    if (cornerRadius == 0) cornerRadius = kDefaultCornerRadius;
    
    // 固定参数，不依赖于容器尺寸
    CGFloat avatarSize = 36.0;
    CGFloat horizontalMargin = 16.0;
    
    // ===== 保留接收方消息（左侧绿色） =====
    // 创建接收方头像（左上角固定位置）
    UIImageView *receiverAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(horizontalMargin, 30, avatarSize, avatarSize)];
    if (@available(iOS 13.0, *)) {
        UIImage *image = [UIImage systemImageNamed:@"person.crop.circle.fill"];
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:30 weight:UIImageSymbolWeightRegular];
        receiverAvatar.image = [image imageWithConfiguration:config];
        receiverAvatar.tintColor = [UIColor systemGreenColor];
    } else {
        receiverAvatar.backgroundColor = [UIColor greenColor];
    }
    receiverAvatar.layer.cornerRadius = avatarSize / 2;
    receiverAvatar.clipsToBounds = YES;
    receiverAvatar.contentMode = UIViewContentModeScaleAspectFit;
    [container addSubview:receiverAvatar];
    
    // 创建接收方气泡
    UIView *receiveBubble = [self createBubbleWithText:@"你好，这是一条测试消息" 
                                          isRightAlign:NO
                                         containerView:container
                                               xOffset:horizontalMargin + avatarSize + 8
                                               yOffset:30];
    
    // 添加时间标签 - 强制刷新布局确保位置正确
    [container layoutIfNeeded];
    
    // 根据设置生成预览用的时间文本
    NSString *timeText = [self generatePreviewTimeText];
    
    // 接收方消息（左侧），时间标签显示在右侧
    UILabel *receiveTimeLabel = [self createTimeLabel:timeText
                                             fontSize:fontSize
                                            textAlpha:textAlpha
                                              bgAlpha:bgAlpha
                                        cornerRadius:cornerRadius];
    
    // 固定时间标签位置
    CGFloat receiveRightEdge = CGRectGetMaxX(receiveBubble.frame);
    CGFloat receiveYPos = CGRectGetMaxY(receiveBubble.frame) - receiveTimeLabel.frame.size.height/2;
    receiveTimeLabel.center = CGPointMake(receiveRightEdge + receiveTimeLabel.frame.size.width/2, receiveYPos);
    [container addSubview:receiveTimeLabel];
}

// 根据当前设置生成预览时间文本
- (NSString *)generatePreviewTimeText {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = [NSDate date]; // 使用当前时间作为预览
    
    // 获取显示设置
    BOOL showYear = [defaults boolForKey:kMessageTimeShowYearKey];
    BOOL showMonth = [defaults boolForKey:kMessageTimeShowMonthKey];
    BOOL showDay = [defaults boolForKey:kMessageTimeShowDayKey];
    BOOL showHour = [defaults boolForKey:kMessageTimeShowHourKey];
    BOOL showMinute = [defaults boolForKey:kMessageTimeShowMinuteKey];
    BOOL showSecond = [defaults boolForKey:kMessageTimeShowSecondKey];
    
    // 如果没有任何显示选项开启，默认显示时分
    if (!showYear && !showMonth && !showDay && !showHour && !showMinute && !showSecond) {
        showHour = YES;
        showMinute = YES;
    }
    
    // 日期部分使用短横线分隔，而不是"年月日"文字
    NSMutableString *dateFormat = [NSMutableString string];
    if (showYear) {
        [dateFormat appendString:@"yyyy"];
        if (showMonth || showDay) {
            [dateFormat appendString:@"-"];
        }
    }
    if (showMonth) {
        [dateFormat appendString:@"MM"];
        if (showDay) {
            [dateFormat appendString:@"-"];
        }
    }
    if (showDay) {
        [dateFormat appendString:@"dd"];
    }
    
    // 时间部分保持冒号分隔
    NSMutableString *timeFormat = [NSMutableString string];
    if (showHour) {
        [timeFormat appendString:@"HH"];
    }
    if (showMinute) {
        if (showHour) {
            [timeFormat appendString:@":"];
        }
        [timeFormat appendString:@"mm"];
    }
    if (showSecond) {
        if (showHour || showMinute) {
            [timeFormat appendString:@":"];
        }
        [timeFormat appendString:@"ss"];
    }
    
    // 如果日期和时间格式都为空，设置默认格式
    if (dateFormat.length == 0 && timeFormat.length == 0) {
        timeFormat = [NSMutableString stringWithString:@"HH:mm"];
    }
    
    // 获取日期和时间部分
    NSString *dateStr = @"";
    if (dateFormat.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat];
        dateStr = [dateFormatter stringFromDate:date];
    }
    
    NSString *timeStr = @"";
    if (timeFormat.length > 0) {
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:timeFormat];
        timeStr = [timeFormatter stringFromDate:date];
    }
    
    // 组合日期和时间
    if (dateStr.length > 0 && timeStr.length > 0) {
        return [NSString stringWithFormat:@"%@\n%@", dateStr, timeStr];
    } else if (dateStr.length > 0) {
        return dateStr;
    } else {
        return timeStr;
    }
}

// 创建时间标签
- (UILabel *)createTimeLabel:(NSString *)timeText
                    fontSize:(CGFloat)fontSize
                   textAlpha:(CGFloat)textAlpha
                     bgAlpha:(CGFloat)bgAlpha
               cornerRadius:(CGFloat)cornerRadius {
    
    // 创建时间标签
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = timeText;
    
    // 根据设置决定是否使用粗体字
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL useBoldFont = [defaults boolForKey:kMessageTimeBoldFontKey];
    if (useBoldFont) {
        timeLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        timeLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    
    timeLabel.numberOfLines = 0; // 允许多行
    
    // 设置文字颜色
    if (self.textColor) {
        timeLabel.textColor = [self.textColor colorWithAlphaComponent:textAlpha];
    } else {
        timeLabel.textColor = [UIColor colorWithWhite:0.5 alpha:textAlpha];
    }
    
    // 设置背景颜色
    if (self.backgroundColor && ![self.backgroundColor isEqual:[UIColor clearColor]]) {
        timeLabel.backgroundColor = [self.backgroundColor colorWithAlphaComponent:bgAlpha];
    } else if (bgAlpha > 0) {
        timeLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:bgAlpha];
    } else {
        timeLabel.backgroundColor = [UIColor clearColor];
    }
    
    // 设置圆角
    timeLabel.layer.cornerRadius = cornerRadius;
    timeLabel.clipsToBounds = YES;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    
    // 计算标签大小，限制最大宽度
    CGFloat padding = 10.0; // 左右各5点的内边距
    CGSize constraintSize = CGSizeMake(kMaxLabelWidth - padding, CGFLOAT_MAX);
    CGSize textSize = [timeText boundingRectWithSize:constraintSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: timeLabel.font}
                                          context:nil].size;
                                      
    // 确保有足够的空间包含文本
    CGFloat labelWidth = textSize.width + padding;
    if (labelWidth > kMaxLabelWidth) labelWidth = kMaxLabelWidth;
    if (labelWidth < 30) labelWidth = 30; // 最小宽度
    
    CGFloat labelHeight = textSize.height + 8.0; // 上下各4点的内边距
    
    // 设置frame
    timeLabel.frame = CGRectMake(0, 0, labelWidth, labelHeight);
    
    return timeLabel;
}

// 使用简化的气泡创建方法
- (UIView *)createBubbleWithText:(NSString *)text 
                    isRightAlign:(BOOL)isRightAlign
                   containerView:(UIView *)containerView
                         xOffset:(CGFloat)xOffset
                         yOffset:(CGFloat)yOffset {
    
    // 创建气泡容器
    UIView *bubbleContainer = [[UIView alloc] initWithFrame:CGRectZero];
    [containerView addSubview:bubbleContainer];
    
    // 创建气泡背景
    UIView *bubbleBg = [[UIView alloc] initWithFrame:CGRectZero];
    bubbleBg.backgroundColor = isRightAlign ? [UIColor systemBlueColor] : [UIColor systemGreenColor];
    bubbleBg.layer.cornerRadius = 8.0;
    [bubbleContainer addSubview:bubbleBg];
    
    // 创建文本标签
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:15.0];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.numberOfLines = 0;
    
    // 计算文本大小
    CGFloat maxWidth = containerView.bounds.size.width * 0.6;
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: textLabel.font}
                                         context:nil].size;
    
    textSize.width = ceil(textSize.width);
    textSize.height = ceil(textSize.height);
    
    // 气泡大小
    CGSize bubbleSize = CGSizeMake(textSize.width + 24, textSize.height + 16);
    
    // 根据对齐方式设置位置
    CGRect bubbleFrame;
    if (isRightAlign) {
        // 发送方消息靠右对齐
        bubbleFrame = CGRectMake(xOffset - bubbleSize.width, yOffset, bubbleSize.width, bubbleSize.height);
        bubbleContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    } else {
        // 接收方消息靠左对齐
        bubbleFrame = CGRectMake(xOffset, yOffset, bubbleSize.width, bubbleSize.height);
    }
    
    bubbleContainer.frame = bubbleFrame;
    bubbleBg.frame = bubbleContainer.bounds;
    
    // 添加文本标签
    [bubbleContainer addSubview:textLabel];
    textLabel.frame = CGRectMake(12, 8, textSize.width, textSize.height);
    
    return bubbleContainer;
}

// 获取文字透明度
- (CGFloat)getTextAlpha {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat textAlpha = [defaults floatForKey:kMessageTimeTextAlphaKey];
    if (textAlpha == 0 && ![defaults objectForKey:kMessageTimeTextAlphaKey]) {
        textAlpha = kDefaultTextAlpha;
    }
    return textAlpha;
}

// 获取背景透明度
- (CGFloat)getBackgroundAlpha {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat bgAlpha = [defaults floatForKey:kMessageTimeBackgroundAlphaKey];
    if (bgAlpha == 0 && ![defaults objectForKey:kMessageTimeBackgroundAlphaKey]) {
        bgAlpha = kDefaultBackgroundAlpha;
    }
    return bgAlpha;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"开启后，可以设置消息的发送时间显示";
    } else if (section == 1) {
        return @"设置时间标签的显示位置";
    } else if (section == 2) {
        return @"选择要显示的时间单位";
    } else if (section == 3) {
        return @"调整消息时间标签的外观样式";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 样式设置组的点击处理
    if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0: // 字体大小
                [self showFontSizeInputAlert];
                break;
            case 1: // 文字颜色
                self.colorTagTextColor = YES;
                [self showColorPicker:self.textColor];
                break;
            case 2: // 背景颜色
                self.colorTagTextColor = NO;
                [self showColorPicker:self.backgroundColor];
                break;
            case 3: // 圆角大小
                [self showCornerRadiusInputAlert];
                break;
            case 4: // 文字透明度
                [self showAlphaInputAlertForKey:kMessageTimeTextAlphaKey title:@"文字透明度"];
                break;
            case 5: // 背景透明度
                [self showAlphaInputAlertForKey:kMessageTimeBackgroundAlphaKey title:@"背景透明度"];
                break;
        }
    }
}

#pragma mark - 辅助方法

- (void)showFontSizeInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentFontSize = [defaults floatForKey:kMessageTimeFontSizeKey];
    if (currentFontSize == 0) currentFontSize = kDefaultFontSize;
    
    NSString *currentValue = [NSString stringWithFormat:@"%.1f", currentFontSize];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置字体大小"
                                                                   message:@"请输入字体大小（建议范围：8.0-12.0）"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = currentValue;
        textField.placeholder = @"请输入数字";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputValue = alert.textFields.firstObject.text;
        CGFloat fontSize = [inputValue floatValue];
        
        // 确保字体大小在合理范围内
        if (fontSize < 6.0) fontSize = 6.0;
        if (fontSize > 16.0) fontSize = 16.0;
        
        // 保存设置
        [defaults setFloat:fontSize forKey:kMessageTimeFontSizeKey];
        [defaults synchronize];
        
        // 更新UI
        CSSettingItem *fontSizeItem = self.sections[3].items[0];
        fontSizeItem.detail = [NSString stringWithFormat:@"%.1f", fontSize];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone]; // 更新预览
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCornerRadiusInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentRadius = [defaults floatForKey:kMessageTimeCornerRadiusKey];
    if (currentRadius == 0) currentRadius = kDefaultCornerRadius;
    
    NSString *currentValue = [NSString stringWithFormat:@"%.1f", currentRadius];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置圆角大小"
                                                                   message:@"请输入圆角大小（建议范围：0.0-5.0）"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = currentValue;
        textField.placeholder = @"请输入数字";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputValue = alert.textFields.firstObject.text;
        CGFloat radius = [inputValue floatValue];
        
        // 确保圆角大小在合理范围内
        if (radius < 0.0) radius = 0.0;
        if (radius > 10.0) radius = 10.0;
        
        // 保存设置
        [defaults setFloat:radius forKey:kMessageTimeCornerRadiusKey];
        [defaults synchronize];
        
        // 更新UI
        CSSettingItem *cornerRadiusItem = self.sections[3].items[3];
        cornerRadiusItem.detail = [NSString stringWithFormat:@"%.1f", radius];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone]; // 更新预览
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlphaInputAlertForKey:(NSString *)key title:(NSString *)title {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentAlpha = [defaults floatForKey:key];
    
    // 对于背景透明度，如果未设置过且值为0，使用默认值
    if ([key isEqualToString:kMessageTimeBackgroundAlphaKey] && 
        currentAlpha == 0 && 
        ![defaults objectForKey:key]) {
        currentAlpha = kDefaultBackgroundAlpha;
    } 
    // 对于文字透明度，如果未设置，使用默认值
    else if ([key isEqualToString:kMessageTimeTextAlphaKey] && 
             currentAlpha == 0 && 
             ![defaults objectForKey:key]) {
        currentAlpha = kDefaultTextAlpha;
    }
    
    NSString *currentValue = [NSString stringWithFormat:@"%.1f", currentAlpha];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"设置%@", title]
                                                                   message:@"请输入透明度（范围：0.0-1.0）"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = currentValue;
        textField.placeholder = @"请输入0.0-1.0之间的数字";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputValue = alert.textFields.firstObject.text;
        CGFloat alpha = [inputValue floatValue];
        
        // 确保透明度在合理范围内
        if (alpha < 0.0) alpha = 0.0;
        if (alpha > 1.0) alpha = 1.0;
        
        // 保存设置
        [defaults setFloat:alpha forKey:key];
        [defaults synchronize];
        
        // 确定是更新哪个项
        NSInteger itemIndex = [key isEqualToString:kMessageTimeTextAlphaKey] ? 4 : 5;
        CSSettingItem *alphaItem = self.sections[3].items[itemIndex];
        alphaItem.detail = [NSString stringWithFormat:@"%.1f", alpha];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone]; // 更新预览
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showColorPicker:(UIColor *)initialColor {
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *colorPicker = [[UIColorPickerViewController alloc] init];
        colorPicker.delegate = self;
        colorPicker.selectedColor = initialColor ?: [UIColor blackColor];
        colorPicker.supportsAlpha = YES; // 启用透明度选择
        
        // 设置标题
        colorPicker.title = self.colorTagTextColor ? @"选择文字颜色" : @"选择背景颜色";
        
        [self presentViewController:colorPicker animated:YES completion:nil];
    } else {
        // iOS 14之前，使用自定义的颜色选择方案或提示不支持
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"不支持的iOS版本"
                                                                       message:@"颜色选择器需要iOS 14或更高版本"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    // 获取选择的颜色
    UIColor *selectedColor = viewController.selectedColor;
    
    // 保存颜色设置
    NSError *error = nil;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:selectedColor requiringSecureCoding:NO error:&error];
    if (error) {
        NSLog(@"颜色归档失败: %@", error);
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.colorTagTextColor) {
        // 保存文字颜色
        self.textColor = selectedColor;
        [defaults setObject:colorData forKey:kMessageTimeTextColorKey];
    } else {
        // 保存背景颜色
        self.backgroundColor = selectedColor;
        [defaults setObject:colorData forKey:kMessageTimeBackgroundColorKey];
    }
    
    [defaults synchronize];
    
    // 重新加载颜色指示器显示
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
    // 更新预览
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    // 实时更新颜色选择
    UIColor *selectedColor = viewController.selectedColor;
    
    if (self.colorTagTextColor) {
        self.textColor = selectedColor;
    } else {
        self.backgroundColor = selectedColor;
    }
    
    // 更新预览区域
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 使用secondarySystemGroupedBackgroundColor来获得正确的深色模式下的背景色
    if (@available(iOS 13.0, *)) {
        cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    // 配置选中状态的背景色
    UIView *selectedBackgroundView = [[UIView alloc] init];
    if (@available(iOS 13.0, *)) {
        selectedBackgroundView.backgroundColor = [UIColor tertiarySystemGroupedBackgroundColor];
    } else {
        selectedBackgroundView.backgroundColor = [UIColor systemGray5Color];
    }
    cell.selectedBackgroundView = selectedBackgroundView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 为预览部分提供适当的高度
    if (indexPath.section == 4 && indexPath.row == 0) {
        return 120; // 增加高度，确保有足够空间显示多行时间标签
    }
    return 44;
}

@end 