#import "CSInputTextSettingsViewController.h"
#import <UIKit/UIKit.h>

// UserDefaults Key常量
static NSString * const kInputTextEnabledKey = @"com.wechat.enhance.inputText.enabled";
static NSString * const kInputTextContentKey = @"com.wechat.enhance.inputText.content";
static NSString * const kInputTextColorKey = @"com.wechat.enhance.inputText.color";
static NSString * const kInputTextAlphaKey = @"com.wechat.enhance.inputText.alpha";
static NSString * const kInputTextFontSizeKey = @"com.wechat.enhance.inputText.fontSize";
static NSString * const kInputTextBoldKey = @"com.wechat.enhance.inputText.bold";
static NSString * const kInputTextRoundedCornersKey = @"com.wechat.enhance.inputText.roundedCorners";
// 添加圆角大小设置键
static NSString * const kInputTextCornerRadiusKey = @"com.wechat.enhance.inputText.cornerRadius";
// 添加边框相关设置键
static NSString * const kInputTextBorderEnabledKey = @"com.wechat.enhance.inputText.border.enabled";
static NSString * const kInputTextBorderWidthKey = @"com.wechat.enhance.inputText.border.width";
static NSString * const kInputTextBorderColorKey = @"com.wechat.enhance.inputText.border.color";

// 默认值
static NSString * const kDefaultInputText = @"我爱你呀";
static CGFloat const kDefaultFontSize = 15.0f;
static CGFloat const kDefaultTextAlpha = 0.5f;
// 输入框圆角大小默认值
static CGFloat const kDefaultCornerRadius = 18.0f;
// 输入框边框默认值
static CGFloat const kDefaultBorderWidth = 1.0f;

@implementation CSInputTextSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航标题
    self.title = @"文本占位";
    
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
    NSError *error = nil;
    
    // 加载文字颜色
    NSData *textColorData = [defaults objectForKey:kInputTextColorKey];
    if (textColorData) {
        self.textColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:textColorData error:&error];
        if (error || !self.textColor) {
            // 处理错误并使用默认值
            NSLog(@"解档文字颜色时出错: %@", error);
            self.textColor = [UIColor colorWithWhite:0.5 alpha:kDefaultTextAlpha];
            error = nil;
        }
    } else {
        // 默认灰色
        self.textColor = [UIColor colorWithWhite:0.5 alpha:kDefaultTextAlpha];
    }
    
    // 加载边框颜色
    NSData *borderColorData = [defaults objectForKey:kInputTextBorderColorKey];
    if (borderColorData) {
        self.borderColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:borderColorData error:&error];
        if (error || !self.borderColor) {
            // 处理错误并使用默认值
            NSLog(@"解档边框颜色时出错: %@", error);
            self.borderColor = [UIColor systemGrayColor];
        }
    } else {
        // 默认边框颜色为系统灰色
        self.borderColor = [UIColor systemGrayColor];
    }
}

- (void)setupData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 基本设置组
    __weak typeof(self) weakSelf = self; // 使用弱引用避免循环引用
    
    // 显示占位文本开关
    CSSettingItem *enableItem = [CSSettingItem switchItemWithTitle:@"显示占位文本" 
                                                         iconName:@"text.bubble" 
                                                        iconColor:[UIColor systemBlueColor] 
                                                      switchValue:[defaults boolForKey:kInputTextEnabledKey]
                                                valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kInputTextEnabledKey];
        [defaults synchronize];
        
        // 重新构建菜单并刷新整个表格
        [weakSelf setupData];
        [weakSelf.tableView reloadData];
    }];
    
    // 输入框圆角开关
    CSSettingItem *roundedCornersItem = [CSSettingItem switchItemWithTitle:@"输入框圆角" 
                                                          iconName:@"rectangle.roundedtop" 
                                                         iconColor:[UIColor systemPurpleColor] 
                                                       switchValue:[defaults boolForKey:kInputTextRoundedCornersKey]
                                                 valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kInputTextRoundedCornersKey];
        [defaults synchronize];
        
        // 重新构建菜单并刷新整个表格
        [weakSelf setupData];
        [weakSelf.tableView reloadData];
    }];
    
    // 输入框边框开关
    CSSettingItem *borderEnabledItem = [CSSettingItem switchItemWithTitle:@"输入框边框" 
                                                          iconName:@"rectangle" 
                                                         iconColor:[UIColor systemOrangeColor] 
                                                       switchValue:[defaults boolForKey:kInputTextBorderEnabledKey]
                                                 valueChangedBlock:^(BOOL isOn) {
        [defaults setBool:isOn forKey:kInputTextBorderEnabledKey];
        [defaults synchronize];
        
        // 重新构建菜单并刷新整个表格
        [weakSelf setupData];
        [weakSelf.tableView reloadData];
    }];
    
    // 基本设置组始终显示
    CSSettingSection *basicSection = [CSSettingSection sectionWithHeader:@"基本设置" 
                                                                 items:@[enableItem, roundedCornersItem, borderEnabledItem]];
    
    // 判断是否启用了功能
    BOOL isInputTextEnabled = [defaults boolForKey:kInputTextEnabledKey];
    BOOL isRoundedCornersEnabled = [defaults boolForKey:kInputTextRoundedCornersKey];
    BOOL isBorderEnabled = [defaults boolForKey:kInputTextBorderEnabledKey];
    
    // 准备可能的section数组
    NSMutableArray *sectionsArray = [NSMutableArray arrayWithObject:basicSection];
    
    // 如果启用了圆角，添加圆角设置组
    if (isRoundedCornersEnabled) {
        // 获取保存的圆角大小或默认值
        CGFloat savedCornerRadius = [defaults floatForKey:kInputTextCornerRadiusKey];
        if (savedCornerRadius <= 0) {
            savedCornerRadius = kDefaultCornerRadius;
        }
        
        // 添加圆角大小调整选项
        CSSettingItem *cornerRadiusItem = [CSSettingItem itemWithTitle:@"圆角大小" 
                                                         iconName:@"slider.horizontal.below.rectangle" 
                                                        iconColor:[UIColor systemIndigoColor] 
                                                          detail:[NSString stringWithFormat:@"%.1f", savedCornerRadius]];
        
        // 创建圆角设置组
        CSSettingSection *cornerSection = [CSSettingSection sectionWithHeader:@"圆角设置" 
                                                                items:@[cornerRadiusItem]];
        
        [sectionsArray addObject:cornerSection];
    }
    
    // 如果启用了边框，添加边框设置组
    if (isBorderEnabled) {
        // 获取保存的边框宽度或默认值
        CGFloat savedBorderWidth = [defaults floatForKey:kInputTextBorderWidthKey];
        if (savedBorderWidth <= 0) {
            savedBorderWidth = kDefaultBorderWidth;
        }
        
        // 添加边框宽度调整选项
        CSSettingItem *borderWidthItem = [CSSettingItem itemWithTitle:@"边框宽度" 
                                                         iconName:@"increase.indent" 
                                                        iconColor:[UIColor systemIndigoColor] 
                                                          detail:[NSString stringWithFormat:@"%.1f", savedBorderWidth]];
        
        // 添加边框颜色选项
        CSSettingItem *borderColorItem = [CSSettingItem itemWithTitle:@"边框颜色" 
                                                        iconName:@"paintbrush.pointed" 
                                                       iconColor:[UIColor systemRedColor] 
                                                         detail:@""];
        
        // 创建边框设置组
        CSSettingSection *borderSection = [CSSettingSection sectionWithHeader:@"边框设置" 
                                                                items:@[borderWidthItem, borderColorItem]];
        
        [sectionsArray addObject:borderSection];
    }
    
    // 如果启用了占位文本功能，添加相关设置组
    if (isInputTextEnabled) {
        // 创建内容设置组
        NSString *savedText = [defaults objectForKey:kInputTextContentKey];
        if (!savedText) {
            savedText = kDefaultInputText;
        }
        
        CSSettingItem *textContentItem = [CSSettingItem itemWithTitle:@"占位文本" 
                                                          iconName:@"text.quote" 
                                                         iconColor:[UIColor systemGreenColor] 
                                                           detail:savedText];
        
        CSSettingSection *contentSection = [CSSettingSection sectionWithHeader:@"内容设置" 
                                                                     items:@[textContentItem]];
        
        [sectionsArray addObject:contentSection];
        
        // 添加样式设置组
        CSSettingItem *boldFontItem = [CSSettingItem switchItemWithTitle:@"使用粗体字" 
                                                            iconName:@"bold" 
                                                           iconColor:[UIColor systemOrangeColor] 
                                                         switchValue:[defaults boolForKey:kInputTextBoldKey]
                                                   valueChangedBlock:^(BOOL isOn) {
            [defaults setBool:isOn forKey:kInputTextBoldKey];
            [defaults synchronize];
        }];
        
        CSSettingSection *styleSection = [CSSettingSection sectionWithHeader:@"样式设置" 
                                                                   items:@[boldFontItem]];
        
        [sectionsArray addObject:styleSection];
        
        // 添加高级样式设置组
        CGFloat savedFontSize = [defaults floatForKey:kInputTextFontSizeKey];
        if (savedFontSize <= 0) {
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
        
        CGFloat savedTextAlpha = [defaults floatForKey:kInputTextAlphaKey];
        if (savedTextAlpha == 0 && ![defaults objectForKey:kInputTextAlphaKey]) { 
            savedTextAlpha = kDefaultTextAlpha;
        }
        
        CSSettingItem *textAlphaItem = [CSSettingItem itemWithTitle:@"文字透明度" 
                                                        iconName:@"slider.horizontal.3" 
                                                       iconColor:[UIColor systemTealColor] 
                                                         detail:[NSString stringWithFormat:@"%.1f", savedTextAlpha]];
        
        CSSettingSection *advancedStyleSection = [CSSettingSection sectionWithHeader:@"高级样式" 
                                                                   items:@[fontSizeItem,
                                                                          textColorItem,
                                                                          textAlphaItem]];
        
        [sectionsArray addObject:advancedStyleSection];
    }
    
    // 设置最终的sections数组
    self.sections = sectionsArray;
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
    
    // 获取当前部分的头部标题
    NSString *sectionHeader = self.sections[indexPath.section].header;
    
    // 为颜色项提前处理，覆盖detail值
    if ([sectionHeader isEqualToString:@"高级样式"] && indexPath.row == 1) { // 文字颜色
        item.detail = @"";
    } else if ([sectionHeader isEqualToString:@"边框设置"] && indexPath.row == 1) { // 边框颜色
        item.detail = @"";
    }
    
    [cell configureWithItem:item];
    
    // 为所有可调整选项添加披露指示器
    if ([sectionHeader isEqualToString:@"圆角设置"] || 
        [sectionHeader isEqualToString:@"边框设置"] ||
        [sectionHeader isEqualToString:@"内容设置"] || 
        [sectionHeader isEqualToString:@"高级样式"]) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // 为颜色项添加颜色预览指示器
        if ([sectionHeader isEqualToString:@"高级样式"] && indexPath.row == 1) { // 文字颜色
            [self addColorIndicator:cell forColor:self.textColor alpha:[self getTextAlpha]];
        } else if ([sectionHeader isEqualToString:@"边框设置"] && indexPath.row == 1) { // 边框颜色
            [self addColorIndicator:cell forColor:self.borderColor alpha:1.0]; // 边框一般不透明
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
    if (color) {
        colorIndicator.backgroundColor = [color colorWithAlphaComponent:alpha];
    } else {
        colorIndicator.backgroundColor = [UIColor colorWithWhite:0.5 alpha:alpha];
    }
    
    // 设置为accessoryView之前的视图，保持倒三角
    UIView *accessoryContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [accessoryContainer addSubview:colorIndicator];
    colorIndicator.center = CGPointMake(15, 15);
    
    cell.accessoryView = accessoryContainer;
}

// 获取文字透明度
- (CGFloat)getTextAlpha {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat textAlpha = [defaults floatForKey:kInputTextAlphaKey];
    if (textAlpha == 0 && ![defaults objectForKey:kInputTextAlphaKey]) {
        textAlpha = kDefaultTextAlpha;
    }
    return textAlpha;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"开启显示占位文本可在聊天输入框中显示自定义文本，开启输入框圆角可使输入框两侧呈现圆润效果，开启边框可为输入框添加自定义边框";
    }
    
    // 获取当前部分的头部标题
    NSString *sectionHeader = self.sections[section].header;
    
    if ([sectionHeader isEqualToString:@"圆角设置"]) {
        return @"调整输入框圆角的大小，数值越大圆角越明显";
    } else if ([sectionHeader isEqualToString:@"边框设置"]) {
        return @"自定义输入框边框的宽度和颜色";
    } else if ([sectionHeader isEqualToString:@"内容设置"]) {
        return @"设置要显示在输入框中的占位文本";
    } else if ([sectionHeader isEqualToString:@"样式设置"]) {
        return @"调整文本的显示样式";
    } else if ([sectionHeader isEqualToString:@"高级样式"]) {
        return @"进一步自定义文本的外观";
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取当前部分的头部标题
    NSString *sectionHeader = self.sections[indexPath.section].header;
    
    // 根据部分标题判断
    if ([sectionHeader isEqualToString:@"圆角设置"] && indexPath.row == 0) {
        [self showCornerRadiusInputAlert];
    } else if ([sectionHeader isEqualToString:@"边框设置"]) {
        if (indexPath.row == 0) { // 边框宽度
            [self showBorderWidthInputAlert];
        } else if (indexPath.row == 1) { // 边框颜色
            self.colorTagTextColor = NO; // 不是文字颜色标记
            [self showColorPicker:self.borderColor];
        }
    } else if ([sectionHeader isEqualToString:@"内容设置"] && indexPath.row == 0) {
        [self showInputTextAlert];
    } else if ([sectionHeader isEqualToString:@"高级样式"]) {
        switch (indexPath.row) {
            case 0: // 字体大小
                [self showFontSizeInputAlert];
                break;
            case 1: // 文字颜色
                self.colorTagTextColor = YES; // 是文字颜色标记
                [self showColorPicker:self.textColor];
                break;
            case 2: // 文字透明度
                [self showAlphaInputAlert];
                break;
        }
    }
}

#pragma mark - 辅助方法

- (void)showInputTextAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentText = [defaults objectForKey:kInputTextContentKey];
    if (!currentText) {
        currentText = kDefaultInputText;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置占位文本"
                                                                   message:@"请输入要在输入框中显示的文本"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = currentText;
        textField.placeholder = @"请输入文本";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputValue = alert.textFields.firstObject.text;
        if (inputValue.length > 0) {
            // 保存设置
            [defaults setObject:inputValue forKey:kInputTextContentKey];
            [defaults synchronize];
            
            // 更新UI
            // 找到内容设置组的索引
            for (NSInteger i = 0; i < self.sections.count; i++) {
                CSSettingSection *section = self.sections[i];
                if ([section.header isEqualToString:@"内容设置"]) {
                    CSSettingItem *textContentItem = section.items[0];
                    textContentItem.detail = inputValue;
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showFontSizeInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentFontSize = [defaults floatForKey:kInputTextFontSizeKey];
    if (currentFontSize <= 0) currentFontSize = kDefaultFontSize;
    
    NSString *currentValue = [NSString stringWithFormat:@"%.1f", currentFontSize];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置字体大小"
                                                                   message:@"请输入字体大小（建议范围：12.0-18.0）"
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
        if (fontSize < 10.0) fontSize = 10.0;
        if (fontSize > 20.0) fontSize = 20.0;
        
        // 保存设置
        [defaults setFloat:fontSize forKey:kInputTextFontSizeKey];
        [defaults synchronize];
        
        // 更新UI
        // 找到高级样式组的索引
        for (NSInteger i = 0; i < self.sections.count; i++) {
            CSSettingSection *section = self.sections[i];
            if ([section.header isEqualToString:@"高级样式"]) {
                CSSettingItem *fontSizeItem = section.items[0];
                fontSizeItem.detail = [NSString stringWithFormat:@"%.1f", fontSize];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlphaInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentAlpha = [defaults floatForKey:kInputTextAlphaKey];
    if (currentAlpha == 0 && ![defaults objectForKey:kInputTextAlphaKey]) {
        currentAlpha = kDefaultTextAlpha;
    }
    
    NSString *currentValue = [NSString stringWithFormat:@"%.1f", currentAlpha];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置文字透明度"
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
        [defaults setFloat:alpha forKey:kInputTextAlphaKey];
        [defaults synchronize];
        
        // 更新UI
        // 找到高级样式组的索引
        for (NSInteger i = 0; i < self.sections.count; i++) {
            CSSettingSection *section = self.sections[i];
            if ([section.header isEqualToString:@"高级样式"]) {
                CSSettingItem *alphaItem = section.items[2];
                alphaItem.detail = [NSString stringWithFormat:@"%.1f", alpha];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
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
        colorPicker.title = @"选择文字颜色";
        
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
    NSError *error = nil;
    
    // 保存颜色设置
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:selectedColor requiringSecureCoding:NO error:&error];
    if (error || !colorData) {
        NSLog(@"归档颜色数据时出错: %@", error);
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.colorTagTextColor) {
        // 保存文字颜色
        self.textColor = selectedColor;
        [defaults setObject:colorData forKey:kInputTextColorKey];
    } else {
        // 保存边框颜色
        self.borderColor = selectedColor;
        [defaults setObject:colorData forKey:kInputTextBorderColorKey];
    }
    
    [defaults synchronize];
    
    // 重新加载颜色指示器显示 - 根据section标题来刷新
    for (NSInteger i = 0; i < self.sections.count; i++) {
        if ([self.sections[i].header isEqualToString:@"高级样式"] && self.colorTagTextColor) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
            break;
        } else if ([self.sections[i].header isEqualToString:@"边框设置"] && !self.colorTagTextColor) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    // 实时更新颜色选择
    UIColor *selectedColor = viewController.selectedColor;
    
    if (self.colorTagTextColor) {
        self.textColor = selectedColor;
    } else {
        self.borderColor = selectedColor;
    }
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

// 添加圆角大小设置对话框
- (void)showCornerRadiusInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentRadius = [defaults floatForKey:kInputTextCornerRadiusKey];
    if (currentRadius <= 0) currentRadius = kDefaultCornerRadius;
    
    NSString *currentValue = [NSString stringWithFormat:@"%.1f", currentRadius];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置圆角大小"
                                                                   message:@"请输入圆角大小（建议范围：5.0-25.0）"
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
        if (radius < 1.0) radius = 1.0;
        if (radius > 30.0) radius = 30.0;
        
        // 保存设置
        [defaults setFloat:radius forKey:kInputTextCornerRadiusKey];
        [defaults synchronize];
        
        // 更新UI
        // 找到圆角设置组的索引
        for (NSInteger i = 0; i < self.sections.count; i++) {
            CSSettingSection *section = self.sections[i];
            if ([section.header isEqualToString:@"圆角设置"]) {
                CSSettingItem *cornerRadiusItem = section.items[0];
                cornerRadiusItem.detail = [NSString stringWithFormat:@"%.1f", radius];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 添加边框宽度设置对话框
- (void)showBorderWidthInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentWidth = [defaults floatForKey:kInputTextBorderWidthKey];
    if (currentWidth <= 0) currentWidth = kDefaultBorderWidth;
    
    NSString *currentValue = [NSString stringWithFormat:@"%.1f", currentWidth];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置边框宽度"
                                                                   message:@"请输入边框宽度（建议范围：0.5-3.0）"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = currentValue;
        textField.placeholder = @"请输入数字";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *inputValue = alert.textFields.firstObject.text;
        CGFloat width = [inputValue floatValue];
        
        // 确保边框宽度在合理范围内
        if (width < 0.5) width = 0.5;
        if (width > 5.0) width = 5.0;
        
        // 保存设置
        [defaults setFloat:width forKey:kInputTextBorderWidthKey];
        [defaults synchronize];
        
        // 更新UI
        // 找到边框设置组的索引
        for (NSInteger i = 0; i < self.sections.count; i++) {
            CSSettingSection *section = self.sections[i];
            if ([section.header isEqualToString:@"边框设置"]) {
                CSSettingItem *borderWidthItem = section.items[0];
                borderWidthItem.detail = [NSString stringWithFormat:@"%.1f", width];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end 