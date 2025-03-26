#import "CSTouchTrailViewController.h"
#import "CSSettingTableViewCell.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 触摸轨迹设置的键
static NSString * const kTouchTrailKey = @"com.wechat.tweak.touch.trail.enabled";
static NSString * const kTouchTrailColorRedKey = @"com.wechat.tweak.touch.trail.color.red";
static NSString * const kTouchTrailColorGreenKey = @"com.wechat.tweak.touch.trail.color.green";
static NSString * const kTouchTrailColorBlueKey = @"com.wechat.tweak.touch.trail.color.blue";
static NSString * const kTouchTrailColorAlphaKey = @"com.wechat.tweak.touch.trail.color.alpha";
static NSString * const kTouchTrailSizeKey = @"com.wechat.tweak.touch.trail.size";
static NSString * const kTouchTrailOnlyWhenRecordingKey = @"com.wechat.tweak.touch.trail.only.when.recording";
// 新增一个键，用于存储实际显示状态
static NSString * const kTouchTrailDisplayStateKey = @"com.wechat.tweak.touch.trail.display.state";
// 触摸点边框相关设置
static NSString * const kTouchTrailBorderEnabledKey = @"com.wechat.tweak.touch.trail.border.enabled";
static NSString * const kTouchTrailBorderColorRedKey = @"com.wechat.tweak.touch.trail.border.color.red";
static NSString * const kTouchTrailBorderColorGreenKey = @"com.wechat.tweak.touch.trail.border.color.green";
static NSString * const kTouchTrailBorderColorBlueKey = @"com.wechat.tweak.touch.trail.border.color.blue";
static NSString * const kTouchTrailBorderColorAlphaKey = @"com.wechat.tweak.touch.trail.border.color.alpha";
static NSString * const kTouchTrailBorderWidthKey = @"com.wechat.tweak.touch.trail.border.width";
// 拖尾效果设置
static NSString * const kTouchTrailTailEnabledKey = @"com.wechat.tweak.touch.trail.tail.enabled";
// 拖尾密度和持续时间设置键
static NSString * const kTouchTrailTailDensityKey = @"com.wechat.tweak.touch.trail.tail.density";
static NSString * const kTouchTrailTailDurationKey = @"com.wechat.tweak.touch.trail.tail.duration";
// 自定义图片轨迹设置键
static NSString * const kTouchTrailCustomImageEnabledKey = @"com.wechat.tweak.touch.trail.custom.image.enabled";
static NSString * const kTouchTrailCustomImagePathKey = @"com.wechat.tweak.touch.trail.custom.image.path";
// 自定义圆角程度设置键
static NSString * const kTouchTrailCustomImageCornerRadiusKey = @"com.wechat.tweak.touch.trail.custom.image.corner.radius";

@interface ColorPreviewView : UIView
@property (nonatomic, strong) UIColor *previewColor;
@end

@implementation ColorPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.height / 2;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.previewColor = [UIColor redColor];
    }
    return self;
}

- (void)setPreviewColor:(UIColor *)previewColor {
    _previewColor = previewColor;
    self.backgroundColor = previewColor;
    [self setNeedsDisplay];
}

@end

@interface CSTouchTrailViewController () <UIColorPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) ColorPreviewView *colorPreviewView;
@property (nonatomic, strong) ColorPreviewView *borderColorPreviewView;
@property (nonatomic, strong) CSSettingItem *colorItem;
@property (nonatomic, strong) CSSettingItem *sizeItem;
@property (nonatomic, strong) CSSettingItem *touchTrailItem;
@property (nonatomic, strong) CSSettingItem *onlyWhenRecordingItem;
// 边框相关设置项
@property (nonatomic, strong) CSSettingItem *borderEnabledItem;
@property (nonatomic, strong) CSSettingItem *borderColorItem;
@property (nonatomic, strong) CSSettingItem *borderWidthItem;
// 拖尾效果设置项
@property (nonatomic, strong) CSSettingItem *tailEnabledItem;
@property (nonatomic, strong) CSSettingItem *tailDensityItem;
@property (nonatomic, strong) CSSettingItem *tailDurationItem;
// 自定义图片设置项
@property (nonatomic, strong) CSSettingItem *customImageEnabledItem;
@property (nonatomic, strong) CSSettingItem *customImageSelectItem;
@property (nonatomic, strong) CSSettingItem *customImageCornerRadiusItem;
@property (nonatomic, strong) UIImageView *customImagePreviewView;
@property (nonatomic, assign) BOOL isSelectingBorderColor; // 标记是否正在选择边框颜色
@end

@implementation CSTouchTrailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"触摸轨迹";
    
    // 注册设置单元格
    [CSSettingTableViewCell registerToTableView:self.tableView];
    
    // 创建颜色预览视图
    self.colorPreviewView = [[ColorPreviewView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    self.borderColorPreviewView = [[ColorPreviewView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    
    // 创建自定义图片预览视图
    self.customImagePreviewView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.customImagePreviewView.contentMode = UIViewContentModeScaleAspectFit;
    self.customImagePreviewView.layer.borderWidth = 1.0;
    self.customImagePreviewView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.customImagePreviewView.layer.cornerRadius = 5.0;
    self.customImagePreviewView.clipsToBounds = YES;
    
    // 注册屏幕录制状态变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(screenCaptureDidChange)
                                               name:UIScreenCapturedDidChangeNotification
                                             object:nil];
    
    // 检查并尝试恢复自定义图片路径
    [self checkAndRestoreCustomImagePath];
    
    // 加载数据
    [self setupData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 处理屏幕录制状态变化
- (void)screenCaptureDidChange {
    BOOL isRecording = UIScreen.mainScreen.isCaptured;
    NSLog(@"屏幕录制状态变化: %@", isRecording ? @"开始录制" : @"停止录制");
    
    // 如果设置了仅在录屏时显示，则需要更新触摸轨迹的显示状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL onlyWhenRecording = [defaults boolForKey:kTouchTrailOnlyWhenRecordingKey];
    BOOL trailEnabled = [defaults boolForKey:kTouchTrailKey];
    
    if (onlyWhenRecording) {
        // 更新实际显示状态而非设置状态
        BOOL shouldDisplay = isRecording && trailEnabled;
        [defaults setBool:shouldDisplay forKey:kTouchTrailDisplayStateKey];
        [defaults synchronize];
    } else if (trailEnabled) {
        // 如果不是仅在录屏时显示，且触摸轨迹开启，则始终显示
        [defaults setBool:YES forKey:kTouchTrailDisplayStateKey];
        [defaults synchronize];
    }
}

- (UIColor *)getCurrentTrailColor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat red = [defaults floatForKey:kTouchTrailColorRedKey];
    CGFloat green = [defaults floatForKey:kTouchTrailColorGreenKey];
    CGFloat blue = [defaults floatForKey:kTouchTrailColorBlueKey];
    CGFloat alpha = [defaults floatForKey:kTouchTrailColorAlphaKey];
    
    // 如果未设置颜色或值无效，设置默认值（红色）
    if (red == 0 && green == 0 && blue == 0 && alpha == 0) {
        [defaults setFloat:1.0 forKey:kTouchTrailColorRedKey];
        [defaults setFloat:0.0 forKey:kTouchTrailColorGreenKey];
        [defaults setFloat:0.0 forKey:kTouchTrailColorBlueKey];
        [defaults setFloat:1.0 forKey:kTouchTrailColorAlphaKey];
        [defaults synchronize];
        return [UIColor redColor];
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)saveTrailColor:(UIColor *)color {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    [defaults setFloat:red forKey:kTouchTrailColorRedKey];
    [defaults setFloat:green forKey:kTouchTrailColorGreenKey];
    [defaults setFloat:blue forKey:kTouchTrailColorBlueKey];
    [defaults setFloat:alpha forKey:kTouchTrailColorAlphaKey];
    [defaults synchronize];
}

// 获取边框颜色
- (UIColor *)getBorderColor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat red = [defaults floatForKey:kTouchTrailBorderColorRedKey];
    CGFloat green = [defaults floatForKey:kTouchTrailBorderColorGreenKey];
    CGFloat blue = [defaults floatForKey:kTouchTrailBorderColorBlueKey];
    CGFloat alpha = [defaults floatForKey:kTouchTrailBorderColorAlphaKey];
    
    // 如果未设置颜色或值无效，设置默认值（白色）
    if (red == 0 && green == 0 && blue == 0 && alpha == 0) {
        [defaults setFloat:1.0 forKey:kTouchTrailBorderColorRedKey];
        [defaults setFloat:1.0 forKey:kTouchTrailBorderColorGreenKey];
        [defaults setFloat:1.0 forKey:kTouchTrailBorderColorBlueKey];
        [defaults setFloat:1.0 forKey:kTouchTrailBorderColorAlphaKey];
        [defaults synchronize];
        return [UIColor whiteColor];
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

// 保存边框颜色
- (void)saveBorderColor:(UIColor *)color {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    [defaults setFloat:red forKey:kTouchTrailBorderColorRedKey];
    [defaults setFloat:green forKey:kTouchTrailBorderColorGreenKey];
    [defaults setFloat:blue forKey:kTouchTrailBorderColorBlueKey];
    [defaults setFloat:alpha forKey:kTouchTrailBorderColorAlphaKey];
    [defaults synchronize];
}

- (void)setupData {
    // 从UserDefaults读取设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isTrailEnabled = [defaults boolForKey:kTouchTrailKey];
    BOOL onlyWhenRecording = [defaults boolForKey:kTouchTrailOnlyWhenRecordingKey];
    
    // 初始化实际显示状态
    if (onlyWhenRecording) {
        BOOL isRecording = UIScreen.mainScreen.isCaptured;
        [defaults setBool:(isRecording && isTrailEnabled) forKey:kTouchTrailDisplayStateKey];
    } else {
        [defaults setBool:isTrailEnabled forKey:kTouchTrailDisplayStateKey];
    }
    [defaults synchronize];
    
    // 创建开关项
    self.touchTrailItem = [CSSettingItem switchItemWithTitle:@"启用触摸轨迹"
                                                    iconName:@"hand.tap.fill"
                                                   iconColor:[UIColor systemBlueColor]
                                                 switchValue:isTrailEnabled
                                           valueChangedBlock:^(BOOL isOn) {
        // 保存设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kTouchTrailKey];
        
        // 根据"仅在录屏时显示"设置来决定实际显示状态
        BOOL onlyWhenRecording = [defaults boolForKey:kTouchTrailOnlyWhenRecordingKey];
        if (onlyWhenRecording) {
            BOOL isRecording = UIScreen.mainScreen.isCaptured;
            [defaults setBool:(isOn && isRecording) forKey:kTouchTrailDisplayStateKey];
        } else {
            [defaults setBool:isOn forKey:kTouchTrailDisplayStateKey];
        }
        
        [defaults synchronize];
        
        // 更新界面 - 根据开关状态决定是否显示高级设置
        [self updateSectionsWithTrailEnabled:isOn];
        [self.tableView reloadData];
    }];
    
    // 创建仅在录屏时显示的开关项（移动到高级设置区域）
    self.onlyWhenRecordingItem = [CSSettingItem switchItemWithTitle:@"仅在录屏时显示"
                                                          iconName:@"record.circle"
                                                         iconColor:[UIColor systemRedColor]
                                                       switchValue:onlyWhenRecording
                                                 valueChangedBlock:^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kTouchTrailOnlyWhenRecordingKey];
        
        // 如果开启了仅在录屏时显示，则检查当前是否在录屏来决定实际显示状态
        BOOL trailEnabled = [defaults boolForKey:kTouchTrailKey];
        if (isOn) {
            BOOL isRecording = UIScreen.mainScreen.isCaptured;
            [defaults setBool:(trailEnabled && isRecording) forKey:kTouchTrailDisplayStateKey];
        } else {
            // 如果关闭了仅在录屏时显示，则实际显示状态跟随触摸轨迹开关
            [defaults setBool:trailEnabled forKey:kTouchTrailDisplayStateKey];
        }
        
        [defaults synchronize];
        
        // 更新表格
        [self.tableView reloadData];
    }];
    
    // 创建颜色选择项
    UIColor *trailColor = [self getCurrentTrailColor];
    self.colorPreviewView.previewColor = trailColor;
    
    // 使用inputItemWithTitle替代disclosureItemWithTitle
    self.colorItem = [CSSettingItem inputItemWithTitle:@"轨迹颜色"
                                             iconName:@"paintpalette.fill"
                                            iconColor:[UIColor systemRedColor]
                                           inputValue:@"点击选择"
                                     inputPlaceholder:@""
                                    valueChangedBlock:nil];
    
    // 创建大小设置项
    CGFloat trailSize = [defaults floatForKey:kTouchTrailSizeKey];
    if (trailSize <= 0) {
        trailSize = 35.0; // 修改默认值为35.0
        [defaults setFloat:trailSize forKey:kTouchTrailSizeKey];
        [defaults synchronize];
    }
    
    NSString *sizeText = [NSString stringWithFormat:@"%.1f", trailSize];
    // 使用inputItemWithTitle替代disclosureItemWithTitle
    self.sizeItem = [CSSettingItem inputItemWithTitle:@"轨迹大小"
                                            iconName:@"circle.dashed"
                                           iconColor:[UIColor systemOrangeColor]
                                          inputValue:sizeText
                                    inputPlaceholder:@""
                                   valueChangedBlock:nil];
    
    // 读取边框设置
    BOOL isBorderEnabled = [defaults boolForKey:kTouchTrailBorderEnabledKey];
    CGFloat borderWidth = [defaults floatForKey:kTouchTrailBorderWidthKey];
    if (borderWidth <= 0) {
        borderWidth = 1.0; // 默认边框宽度为1.0
        [defaults setFloat:borderWidth forKey:kTouchTrailBorderWidthKey];
        [defaults synchronize];
    }
    
    // 创建边框开关项
    self.borderEnabledItem = [CSSettingItem switchItemWithTitle:@"显示边框"
                                                       iconName:@"square.dashed"
                                                      iconColor:[UIColor systemIndigoColor]
                                                    switchValue:isBorderEnabled
                                              valueChangedBlock:^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kTouchTrailBorderEnabledKey];
        [defaults synchronize];
        [self updateSectionsWithTrailEnabled:YES];
        [self.tableView reloadData];
    }];
    
    // 创建边框颜色选择项
    UIColor *borderColor = [self getBorderColor];
    self.borderColorPreviewView.previewColor = borderColor;
    
    // 使用inputItemWithTitle替代disclosureItemWithTitle
    self.borderColorItem = [CSSettingItem inputItemWithTitle:@"边框颜色"
                                                   iconName:@"pencil.circle"
                                                  iconColor:[UIColor systemPurpleColor]
                                                 inputValue:@"点击选择"
                                           inputPlaceholder:@""
                                          valueChangedBlock:nil];
    
    // 创建边框宽度设置项
    NSString *borderWidthText = [NSString stringWithFormat:@"%.1f", borderWidth];
    // 使用inputItemWithTitle替代disclosureItemWithTitle
    self.borderWidthItem = [CSSettingItem inputItemWithTitle:@"边框宽度"
                                                   iconName:@"decrease.indent"
                                                  iconColor:[UIColor systemTealColor]
                                                 inputValue:borderWidthText
                                           inputPlaceholder:@""
                                          valueChangedBlock:nil];
    
    // 读取拖尾效果设置
    BOOL isTailEnabled = [defaults boolForKey:kTouchTrailTailEnabledKey];
    
    // 读取拖尾密度设置
    CGFloat tailDensity = [defaults floatForKey:kTouchTrailTailDensityKey];
    if (tailDensity <= 0) {
        tailDensity = 100.0; // 修改默认值为100.0
        [defaults setFloat:tailDensity forKey:kTouchTrailTailDensityKey];
        [defaults synchronize];
    }
    
    // 读取拖尾持续时间设置
    CGFloat tailDuration = [defaults floatForKey:kTouchTrailTailDurationKey];
    if (tailDuration <= 0) {
        tailDuration = 0.8; // 默认0.8秒消失
        [defaults setFloat:tailDuration forKey:kTouchTrailTailDurationKey];
        [defaults synchronize];
    }
    
    // 创建拖尾效果开关项
    self.tailEnabledItem = [CSSettingItem switchItemWithTitle:@"拖尾效果" 
                                                     iconName:@"waveform.path"
                                                    iconColor:[UIColor systemTealColor]
                                                  switchValue:isTailEnabled
                                            valueChangedBlock:^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kTouchTrailTailEnabledKey];
        [defaults synchronize];
        [self updateTailSettings];
        [self.tableView reloadData];
    }];
    
    // 创建拖尾密度设置项
    NSString *densityText = [NSString stringWithFormat:@"%.0f", tailDensity];
    // 使用inputItemWithTitle替代disclosureItemWithTitle
    self.tailDensityItem = [CSSettingItem inputItemWithTitle:@"拖尾密度"
                                                   iconName:@"chart.bar.fill"
                                                  iconColor:[UIColor systemBlueColor]
                                                 inputValue:densityText
                                           inputPlaceholder:@""
                                          valueChangedBlock:nil];
    
    // 创建拖尾持续时间设置项
    NSString *durationText = [NSString stringWithFormat:@"%.1f秒", tailDuration];
    // 使用inputItemWithTitle替代disclosureItemWithTitle
    self.tailDurationItem = [CSSettingItem inputItemWithTitle:@"拖尾持续时间"
                                                    iconName:@"timer"
                                                   iconColor:[UIColor systemPurpleColor]
                                                  inputValue:durationText
                                            inputPlaceholder:@""
                                           valueChangedBlock:nil];
    
    // 读取自定义图片设置
    BOOL isCustomImageEnabled = [defaults boolForKey:kTouchTrailCustomImageEnabledKey];
    NSString *imagePath = [defaults objectForKey:kTouchTrailCustomImagePathKey];
    
    // 读取自定义圆角程度设置
    CGFloat cornerRadius = [defaults floatForKey:kTouchTrailCustomImageCornerRadiusKey];
    // 如果未设置，默认为0.5（中等圆角）
    if (cornerRadius == 0 && ![defaults objectForKey:kTouchTrailCustomImageCornerRadiusKey]) {
        cornerRadius = 0.5;
        [defaults setFloat:cornerRadius forKey:kTouchTrailCustomImageCornerRadiusKey];
        [defaults synchronize];
    }
    
    // 创建自定义图片开关项
    self.customImageEnabledItem = [CSSettingItem switchItemWithTitle:@"使用自定义图片" 
                                                          iconName:@"photo.fill"
                                                         iconColor:[UIColor systemGreenColor]
                                                       switchValue:isCustomImageEnabled
                                                 valueChangedBlock:^(BOOL isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isOn forKey:kTouchTrailCustomImageEnabledKey];
        [defaults synchronize];
        [self updateSectionsWithTrailEnabled:YES];
        [self.tableView reloadData];
    }];
    
    // 创建选择图片项
    NSString *imageStatus = imagePath ? @"已选择" : @"点击选择";
    self.customImageSelectItem = [CSSettingItem inputItemWithTitle:@"选择图片"
                                                          iconName:@"photo.on.rectangle"
                                                         iconColor:[UIColor systemBlueColor]
                                                        inputValue:imageStatus
                                                  inputPlaceholder:@""
                                                 valueChangedBlock:nil];
    
    // 创建圆角设置项
    NSString *cornerRadiusText = [NSString stringWithFormat:@"%.1f", cornerRadius];
    self.customImageCornerRadiusItem = [CSSettingItem inputItemWithTitle:@"圆角程度"
                                                             iconName:@"square.on.circle"
                                                            iconColor:[UIColor systemOrangeColor]
                                                           inputValue:cornerRadiusText
                                                     inputPlaceholder:@""
                                                    valueChangedBlock:nil];
    
    // 更新自定义图片预览
    if (imagePath) {
        UIImage *customImage = [UIImage imageWithContentsOfFile:imagePath];
        if (customImage) {
            self.customImagePreviewView.image = customImage;
        }
    }
    
    // 根据开关状态更新界面
    [self updateSectionsWithTrailEnabled:isTrailEnabled];
}

// 根据触摸轨迹开关状态更新UI
- (void)updateSectionsWithTrailEnabled:(BOOL)enabled {
    NSMutableArray *sections = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 1. 基础设置区域 - 包含总开关和显示模式
    NSMutableArray *basicItems = [NSMutableArray arrayWithObject:self.touchTrailItem];
    [basicItems addObject:self.onlyWhenRecordingItem];
    CSSettingSection *basicSection = [CSSettingSection sectionWithHeader:@"基础设置"
                                                                  items:basicItems];
    [sections addObject:basicSection];
    
    // 只有在开启触摸轨迹功能时显示以下设置
    if (enabled) {
        // 2. 外观设置区域 - 包含颜色、大小和自定义图片选项
        NSMutableArray *appearanceItems = [NSMutableArray array];
        
        // 添加自定义图片设置项
        [appearanceItems addObject:self.customImageEnabledItem];
        
        // 根据是否启用自定义图片决定显示哪些设置
        BOOL isCustomImageEnabled = [defaults boolForKey:kTouchTrailCustomImageEnabledKey];
        if (isCustomImageEnabled) {
            [appearanceItems addObject:self.customImageSelectItem];
            [appearanceItems addObject:self.customImageCornerRadiusItem];
        } else {
            [appearanceItems addObject:self.colorItem];
        }
        
        // 轨迹大小设置始终显示
        [appearanceItems addObject:self.sizeItem];
        
        CSSettingSection *appearanceSection = [CSSettingSection sectionWithHeader:@"外观设置"
                                                                          items:appearanceItems];
        [sections addObject:appearanceSection];
        
        // 3. 边框设置区域
        BOOL isBorderEnabled = [defaults boolForKey:kTouchTrailBorderEnabledKey];
        NSMutableArray *borderItems = [NSMutableArray arrayWithObject:self.borderEnabledItem];
        if (isBorderEnabled) {
            [borderItems addObject:self.borderColorItem];
            [borderItems addObject:self.borderWidthItem];
        }
        CSSettingSection *borderSection = [CSSettingSection sectionWithHeader:@"边框设置"
                                                                      items:borderItems];
        [sections addObject:borderSection];
        
        // 4. 拖尾效果区域 - 单独分区
        BOOL isTailEnabled = [defaults boolForKey:kTouchTrailTailEnabledKey];
        NSMutableArray *tailItems = [NSMutableArray arrayWithObject:self.tailEnabledItem];
        if (isTailEnabled) {
            [tailItems addObject:self.tailDensityItem];
            [tailItems addObject:self.tailDurationItem];
        }
        CSSettingSection *tailSection = [CSSettingSection sectionWithHeader:@"拖尾效果"
                                                                    items:tailItems];
        [sections addObject:tailSection];
    }
    
    // 5. 说明区域 - 始终显示
    // 使用inputItemWithTitle替代disclosureItemWithTitle
    CSSettingItem *infoItem = [CSSettingItem inputItemWithTitle:@"功能说明"
                                                      iconName:@"info.circle"
                                                     iconColor:[UIColor systemBlueColor]
                                                    inputValue:@"点击查看"
                                              inputPlaceholder:@""
                                             valueChangedBlock:nil];
    
    CSSettingSection *infoSection = [CSSettingSection sectionWithHeader:@"说明"
                                                                items:@[infoItem]];
    [sections addObject:infoSection];
    
    // 更新区域
    self.sections = sections;
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
    
    // 为颜色选项添加颜色预览
    if ([item.title isEqualToString:@"轨迹颜色"]) {
        cell.accessoryView = self.colorPreviewView;
    } else if ([item.title isEqualToString:@"边框颜色"]) {
        cell.accessoryView = self.borderColorPreviewView;
    } else if ([item.title isEqualToString:@"选择图片"]) {
        cell.accessoryView = self.customImagePreviewView;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSInteger sectionCount = self.sections.count;
    
    // 基础设置区域
    if (section == 0) {
        return @"开启或关闭触摸轨迹功能，设置是否仅在录屏时显示";
    } 
    // 外观设置区域
    else if (section == 1 && sectionCount > 2) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL isCustomImageEnabled = [defaults boolForKey:kTouchTrailCustomImageEnabledKey];
        if (isCustomImageEnabled) {
            return @"可以从相册选择自定义图片作为触摸轨迹，并调整图片显示大小";
        } else {
            return @"调整触摸点的颜色和大小";
        }
    } 
    // 边框设置区域
    else if (section == 2 && sectionCount > 3) {
        return @"为触摸点添加边框，使其在相似背景色上更加醒目";
    } 
    // 拖尾效果区域
    else if (section == 3 && sectionCount > 4) {
        return @"启用拖尾效果可显示完整触摸路径，通过密度和持续时间控制拖尾的显示效果";
    } 
    // 说明区域（始终是最后一个区域）
    else if (section == sectionCount - 1) {
        return @"触摸轨迹功能可以在触摸屏幕时显示轨迹效果，方便录制教程视频或进行演示";
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CSSettingItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    // 处理轨迹颜色点击
    if ([item.title isEqualToString:@"轨迹颜色"]) {
        self.isSelectingBorderColor = NO;
        [self showColorPicker];
    }
    // 处理边框颜色点击
    else if ([item.title isEqualToString:@"边框颜色"]) {
        self.isSelectingBorderColor = YES;
        [self showBorderColorPicker];
    }
    // 处理轨迹大小点击
    else if ([item.title isEqualToString:@"轨迹大小"]) {
        [self showSizeInputAlert];
    }
    // 处理边框宽度点击
    else if ([item.title isEqualToString:@"边框宽度"]) {
        [self showBorderWidthInputAlert];
    }
    // 处理拖尾密度点击
    else if ([item.title isEqualToString:@"拖尾密度"]) {
        [self showTailDensityInputAlert];
    }
    // 处理拖尾持续时间点击
    else if ([item.title isEqualToString:@"拖尾持续时间"]) {
        [self showTailDurationInputAlert];
    }
    // 处理功能说明点击
    else if ([item.title isEqualToString:@"功能说明"]) {
        [self showInfoAlert];
    }
    // 处理选择图片点击
    else if ([item.title isEqualToString:@"选择图片"]) {
        [self showImagePicker];
    }
    // 处理圆角程度点击
    else if ([item.title isEqualToString:@"圆角程度"]) {
        [self showCornerRadiusInputAlert];
    }
}

// 显示功能说明弹窗
- (void)showInfoAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"触摸轨迹说明"
                                                                            message:@"触摸轨迹功能可以在您触摸屏幕时显示轨迹效果，方便演示操作流程或录制教程视频。\n\n您可以调整轨迹的颜色和大小，以满足不同的使用场景。\n\n注意：启用此功能可能会略微增加系统资源占用。"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"了解了"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示颜色选择器
- (void)showColorPicker {
    UIColorPickerViewController *colorPicker = [[UIColorPickerViewController alloc] init];
    colorPicker.delegate = self;
    colorPicker.selectedColor = [self getCurrentTrailColor];
    colorPicker.title = @"选择轨迹颜色";
    colorPicker.supportsAlpha = YES;
    [self presentViewController:colorPicker animated:YES completion:nil];
}

// 显示边框颜色选择器
- (void)showBorderColorPicker {
    UIColorPickerViewController *colorPicker = [[UIColorPickerViewController alloc] init];
    colorPicker.delegate = self;
    colorPicker.selectedColor = [self getBorderColor];
    colorPicker.title = @"选择边框颜色";
    colorPicker.supportsAlpha = YES;
    [self presentViewController:colorPicker animated:YES completion:nil];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController {
    // 用户完成颜色选择
    UIColor *selectedColor = viewController.selectedColor;
    
    if (self.isSelectingBorderColor) {
        [self saveBorderColor:selectedColor];
        self.borderColorPreviewView.previewColor = selectedColor;
    } else {
        [self saveTrailColor:selectedColor];
        self.colorPreviewView.previewColor = selectedColor;
    }
    
    [self.tableView reloadData];
}

- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController {
    // 实时更新颜色预览
    UIColor *selectedColor = viewController.selectedColor;
    
    if (self.isSelectingBorderColor) {
        self.borderColorPreviewView.previewColor = selectedColor;
    } else {
        self.colorPreviewView.previewColor = selectedColor;
    }
}

// 显示大小输入弹窗
- (void)showSizeInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentSize = [defaults floatForKey:kTouchTrailSizeKey];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置轨迹大小"
                                                                           message:@"请输入轨迹大小(10-50)"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入大小";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = [NSString stringWithFormat:@"%.1f", currentSize];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        CGFloat size = [textField.text floatValue];
        
        // 限制范围
        if (size < 10.0) size = 10.0;
        if (size > 50.0) size = 50.0;
        
        // 保存设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:size forKey:kTouchTrailSizeKey];
        [defaults synchronize];
        
        // 更新UI - 同时更新inputValue和detail
        NSString *sizeText = [NSString stringWithFormat:@"%.1f", size];
        self.sizeItem.inputValue = sizeText;
        self.sizeItem.detail = sizeText;
        [self.tableView reloadData];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示边框宽度输入弹窗
- (void)showBorderWidthInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentWidth = [defaults floatForKey:kTouchTrailBorderWidthKey];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置边框宽度"
                                                                           message:@"请输入边框宽度(0.5-5.0)"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入宽度";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = [NSString stringWithFormat:@"%.1f", currentWidth];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        CGFloat width = [textField.text floatValue];
        
        // 限制范围
        if (width < 0.5) width = 0.5;
        if (width > 5.0) width = 5.0;
        
        // 保存设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:width forKey:kTouchTrailBorderWidthKey];
        [defaults synchronize];
        
        // 更新UI - 同时更新inputValue和detail
        NSString *widthText = [NSString stringWithFormat:@"%.1f", width];
        self.borderWidthItem.inputValue = widthText;
        self.borderWidthItem.detail = widthText;
        [self.tableView reloadData];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示拖尾密度输入弹窗
- (void)showTailDensityInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentDensity = [defaults floatForKey:kTouchTrailTailDensityKey];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置拖尾密度"
                                                                           message:@"请输入拖尾密度(1-100)\n数值越大拖尾越密集"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入密度";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.text = [NSString stringWithFormat:@"%.0f", currentDensity];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        CGFloat density = [textField.text floatValue];
        
        // 限制范围
        if (density < 1.0) density = 1.0;
        if (density > 100.0) density = 100.0;
        
        // 保存设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:density forKey:kTouchTrailTailDensityKey];
        [defaults synchronize];
        
        // 更新UI - 同时更新inputValue和detail
        NSString *densityText = [NSString stringWithFormat:@"%.0f", density];
        self.tailDensityItem.inputValue = densityText;
        self.tailDensityItem.detail = densityText;
        [self.tableView reloadData];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示拖尾持续时间输入弹窗
- (void)showTailDurationInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentDuration = [defaults floatForKey:kTouchTrailTailDurationKey];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置拖尾持续时间"
                                                                           message:@"请输入拖尾持续时间(0.3-3.0秒)"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入持续时间";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = [NSString stringWithFormat:@"%.1f", currentDuration];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        CGFloat duration = [textField.text floatValue];
        
        // 限制范围
        if (duration < 0.3) duration = 0.3;
        if (duration > 3.0) duration = 3.0;
        
        // 保存设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:duration forKey:kTouchTrailTailDurationKey];
        [defaults synchronize];
        
        // 更新UI - 同时更新inputValue和detail
        NSString *durationText = [NSString stringWithFormat:@"%.1f秒", duration];
        self.tailDurationItem.inputValue = durationText;
        self.tailDurationItem.detail = durationText;
        [self.tableView reloadData];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示图片选择器
- (void)showImagePicker {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES; // 允许编辑，方便用户裁剪图片
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // 获取编辑后的图片
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    if (!selectedImage) {
        selectedImage = info[UIImagePickerControllerOriginalImage];
    }
    
    if (selectedImage) {
        // 更新图片预览
        self.customImagePreviewView.image = selectedImage;
        
        // 保存图片到应用沙盒
        NSString *imagePath = [self saveImageToDocuments:selectedImage];
        if (imagePath) {
            // 保存图片路径到 UserDefaults
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:imagePath forKey:kTouchTrailCustomImagePathKey];
            [defaults synchronize];
            
            // 更新UI
            self.customImageSelectItem.inputValue = @"已选择";
            self.customImageSelectItem.detail = @"已选择";
            [self.tableView reloadData];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 保存图片到应用沙盒
- (NSString *)saveImageToDocuments:(UIImage *)image {
    // 获取Preferences目录下的WechatEnhance文件夹路径
    NSString *prefsPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    prefsPath = [prefsPath stringByAppendingPathComponent:@"Preferences"];
    NSString *enhanceFolderPath = [prefsPath stringByAppendingPathComponent:@"WechatEnhance"];
    
    // 检查目录是否存在，如果不存在则创建
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:enhanceFolderPath]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:enhanceFolderPath 
               withIntermediateDirectories:YES 
                                attributes:nil 
                                     error:&error];
        if (error) {
            NSLog(@"创建WechatEnhance目录失败: %@", error.localizedDescription);
            return nil;
        }
    }
    
    // 使用固定的文件名
    NSString *fileName = @"touch_trail.png";
    NSString *filePath = [enhanceFolderPath stringByAppendingPathComponent:fileName];
    
    // 如果旧文件存在，先删除
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"删除旧图片失败: %@", error.localizedDescription);
        }
    }
    
    // 将图片转换为PNG数据并保存
    NSData *imageData = UIImagePNGRepresentation(image);
    BOOL success = [imageData writeToFile:filePath atomically:YES];
    
    // 添加防止备份标志，避免被iCloud备份
    if (success) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        NSError *error = nil;
        [fileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (error) {
            NSLog(@"设置文件不备份标志失败: %@", error.localizedDescription);
        }
    }
    
    return success ? filePath : nil;
}

// 更新拖尾设置的显示/隐藏状态
- (void)updateTailSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isTrailEnabled = [defaults boolForKey:kTouchTrailKey];
    
    if (!isTrailEnabled) {
        return; // 如果触摸轨迹功能已关闭，则不更新拖尾设置
    }
    
    // 重新构建所有区域，确保拖尾区域正确显示
    [self updateSectionsWithTrailEnabled:YES];
    [self.tableView reloadData];
}

// 显示圆角程度输入弹窗
- (void)showCornerRadiusInputAlert {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat currentRadius = [defaults floatForKey:kTouchTrailCustomImageCornerRadiusKey];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置圆角程度"
                                                                           message:@"请输入圆角程度(0-1)\n0表示方形，1表示圆形，中间值表示不同程度的圆角"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入圆角程度";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = [NSString stringWithFormat:@"%.1f", currentRadius];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        CGFloat radius = [textField.text floatValue];
        
        // 限制范围
        if (radius < 0.0) radius = 0.0;
        if (radius > 1.0) radius = 1.0;
        
        // 保存设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:radius forKey:kTouchTrailCustomImageCornerRadiusKey];
        [defaults synchronize];
        
        // 更新UI - 同时更新inputValue和detail
        NSString *radiusText = [NSString stringWithFormat:@"%.1f", radius];
        self.customImageCornerRadiusItem.inputValue = radiusText;
        self.customImageCornerRadiusItem.detail = radiusText;
        [self.tableView reloadData];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 新增方法：检查并尝试恢复自定义图片路径
- (void)checkAndRestoreCustomImagePath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedPath = [defaults objectForKey:kTouchTrailCustomImagePathKey];
    BOOL isCustomImageEnabled = [defaults boolForKey:kTouchTrailCustomImageEnabledKey];
    
    // 如果启用了自定义图片但路径无效或文件不存在
    if (isCustomImageEnabled && (!savedPath || ![[NSFileManager defaultManager] fileExistsAtPath:savedPath])) {
        // 尝试查找固定位置的图片
        NSString *prefsPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
        prefsPath = [prefsPath stringByAppendingPathComponent:@"Preferences"];
        NSString *enhanceFolderPath = [prefsPath stringByAppendingPathComponent:@"WechatEnhance"];
        NSString *fixedImagePath = [enhanceFolderPath stringByAppendingPathComponent:@"touch_trail.png"];
        
        // 如果固定位置的图片存在，更新路径
        if ([[NSFileManager defaultManager] fileExistsAtPath:fixedImagePath]) {
            [defaults setObject:fixedImagePath forKey:kTouchTrailCustomImagePathKey];
            [defaults synchronize];
        }
    }
}

@end 