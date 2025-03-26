#import "CSSettingTableViewCell.h"
#import <objc/runtime.h>

@interface CSSettingItem ()
@property (nonatomic, assign, readwrite) CSSettingItemType itemType; // 项目类型（内部可写）
@end

@implementation CSSettingItem

- (instancetype)initWithType:(CSSettingItemType)type {
    if (self = [super init]) {
        _itemType = type;
        // 根据类型设置默认值
        switch (type) {
            case CSSettingItemTypeSwitch:
                _switchValue = NO;
                break;
            case CSSettingItemTypeInput:
                _inputValue = @"";
                _inputPlaceholder = @"";
                break;
            case CSSettingItemTypeDraggable:
                _identifier = 0;
                _sortIndex = 0;
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)setDetail:(NSString *)detail {
    // 如果是开关类型，强制detail为nil
    if (self.itemType == CSSettingItemTypeSwitch) {
        _detail = nil;
    } else {
        _detail = [detail copy];
    }
}

// 实现CSConfigurableItem协议方法
- (void)performAction {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)copyItemDetail {
    if (self.detail.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.detail;
    }
}

- (BOOL)canPerformAction {
    return (self.detail.length > 0 || 
            self.itemType == CSSettingItemTypeAction || 
            self.actionBlock != nil);
}

+ (instancetype)itemWithTitle:(NSString *)title
                    iconName:(NSString *)iconName
                  iconColor:(UIColor *)iconColor
                     detail:(nullable NSString *)detail {
    CSSettingItem *item = [[CSSettingItem alloc] init];
    item.title = title;
    item.iconName = iconName;
    item.iconColor = iconColor;
    item.detail = detail;
    item.itemType = CSSettingItemTypeNormal;
    return item;
}

+ (instancetype)actionItemWithTitle:(NSString *)title
                          iconName:(NSString *)iconName
                         iconColor:(UIColor *)iconColor {
    CSSettingItem *item = [[CSSettingItem alloc] init];
    item.title = title;
    item.iconName = iconName;
    item.iconColor = iconColor;
    item.itemType = CSSettingItemTypeAction;
    return item;
}

+ (instancetype)switchItemWithTitle:(NSString *)title
                          iconName:(NSString *)iconName
                         iconColor:(UIColor *)iconColor
                        switchValue:(BOOL)switchValue
                   valueChangedBlock:(nullable void(^)(BOOL isOn))valueChanged {
    CSSettingItem *item = [[CSSettingItem alloc] init];
    item.title = title;
    item.iconName = iconName;
    item.iconColor = iconColor;
    item.itemType = CSSettingItemTypeSwitch;
    item.switchValue = switchValue;
    item.switchValueChanged = valueChanged;
    item.detail = nil; // 确保开关项没有详情文本
    return item;
}

+ (instancetype)inputItemWithTitle:(NSString *)title
                         iconName:(NSString *)iconName
                        iconColor:(UIColor *)iconColor
                        inputValue:(nullable NSString *)inputValue
                    inputPlaceholder:(nullable NSString *)placeholder
                   valueChangedBlock:(nullable void(^)(NSString *value))valueChanged {
    CSSettingItem *item = [[CSSettingItem alloc] init];
    item.title = title;
    item.iconName = iconName;
    item.iconColor = iconColor;
    item.itemType = CSSettingItemTypeInput;
    item.inputValue = inputValue;
    item.inputPlaceholder = placeholder;
    item.inputValueChanged = valueChanged;
    item.detail = inputValue; // 在detail中显示当前值
    return item;
}

+ (instancetype)draggableItemWithTitle:(NSString *)title
                             iconName:(NSString *)iconName
                            iconColor:(UIColor *)iconColor
                             identifier:(NSInteger)identifier
                             sortIndex:(NSInteger)sortIndex {
    CSSettingItem *item = [[CSSettingItem alloc] init];
    item.title = title;
    item.iconName = iconName;
    item.iconColor = iconColor;
    item.itemType = CSSettingItemTypeDraggable;
    item.identifier = identifier;
    item.sortIndex = sortIndex;
    return item;
}

@end

@implementation CSSettingSection

+ (instancetype)sectionWithHeader:(NSString *)header items:(NSArray<CSSettingItem *> *)items {
    CSSettingSection *section = [[CSSettingSection alloc] init];
    section.header = header;
    section.items = items;
    section.allowsReordering = NO;
    return section;
}

+ (instancetype)sectionWithHeader:(NSString *)header 
                            items:(NSArray<CSSettingItem *> *)items 
                 allowsReordering:(BOOL)allowsReordering
                orderChangedBlock:(nullable void (^)(NSArray<CSSettingItem *> *))orderChangedBlock {
    CSSettingSection *section = [[CSSettingSection alloc] init];
    section.header = header;
    section.items = items;
    section.allowsReordering = allowsReordering;
    section.orderChangedBlock = orderChangedBlock;
    return section;
}

@end

@interface CSSettingTableViewCell ()
@property (nonatomic, strong) CSSettingItem *currentItem;
@property (nonatomic, strong) UIImageView *dragHandleImageView; // 拖动手柄
@end

@implementation CSSettingTableViewCell

+ (NSString *)reuseIdentifier {
    return @"CSSettingTableViewCell";
}

+ (void)registerToTableView:(UITableView *)tableView {
    [tableView registerClass:self forCellReuseIdentifier:[self reuseIdentifier]];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 配置选中状态的背景色
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [UIColor tertiarySystemGroupedBackgroundColor];
    self.selectedBackgroundView = selectedBackgroundView;
    
    // 背景色
    self.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    
    // 设置图标容器，使用自动布局
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 在初始化时应用图标的自动布局约束
    [NSLayoutConstraint activateConstraints:@[
        [self.imageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.imageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15.0f],
        [self.imageView.widthAnchor constraintEqualToConstant:29.0f],
        [self.imageView.heightAnchor constraintEqualToConstant:29.0f]
    ]];
    
    // 初始化拖动手柄
    self.dragHandleImageView = [[UIImageView alloc] init];
    self.dragHandleImageView.contentMode = UIViewContentModeCenter;
    self.dragHandleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    // 使用系统图标作为拖动手柄
    UIImage *dragHandleImage = [UIImage systemImageNamed:@"line.3.horizontal"];
    self.dragHandleImageView.image = dragHandleImage;
    self.dragHandleImageView.tintColor = [UIColor systemGrayColor];
    self.dragHandleImageView.hidden = YES; // 默认隐藏
    [self.contentView addSubview:self.dragHandleImageView];
    
    // 设置拖动手柄的约束
    [NSLayoutConstraint activateConstraints:@[
        [self.dragHandleImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.dragHandleImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15.0f],
        [self.dragHandleImageView.widthAnchor constraintEqualToConstant:30.0f],
        [self.dragHandleImageView.heightAnchor constraintEqualToConstant:30.0f]
    ]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    // 重置所有状态
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    self.imageView.image = nil;
    self.imageView.tintColor = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    self.currentItem = nil;
    self.dragHandleImageView.hidden = YES;
    
    // 移除所有子视图（除了系统自带的和拖动手柄）
    for (UIView *view in self.contentView.subviews) {
        if (![view isKindOfClass:[UILabel class]] && 
            ![view isKindOfClass:[UIImageView class]] && 
            view != self.dragHandleImageView) {
            [view removeFromSuperview];
        }
    }
}

- (void)configureWithItem:(CSSettingItem *)item {
    if (!item) return;
    
    self.currentItem = item;
    self.textLabel.text = item.title;
    
    // 设置图标
    if (item.iconName.length > 0) {
        self.imageView.image = [UIImage systemImageNamed:item.iconName];
        self.imageView.tintColor = item.iconColor ?: [UIColor labelColor];
    } else {
        self.imageView.image = nil;
    }
    
    // 根据不同类型配置Cell
    switch (item.itemType) {
        case CSSettingItemTypeSwitch:
            [self configureSwitchItem:item];
            break;
        case CSSettingItemTypeInput:
            [self configureInputItem:item];
            break;
        case CSSettingItemTypeDisclosure:
            [self configureDisclosureItem:item];
            break;
        case CSSettingItemTypeAction:
            [self configureActionItem:item];
            break;
        case CSSettingItemTypeDraggable:
            [self configureDraggableItem:item];
            break;
        case CSSettingItemTypeNormal:
            [self configureNormalItem:item];
            break;
    }
}

- (void)configureSwitchItem:(CSSettingItem *)item {
    // 创建开关并设置初始状态
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.on = item.switchValue;
    [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    // 不使用accessoryView，而是直接添加到contentView
    [self.contentView addSubview:switchView];
    switchView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 使用自动布局确保switch在右侧
    [NSLayoutConstraint activateConstraints:@[
        [switchView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [switchView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15.0f]
    ]];
    
    // 清除详情文本
    self.detailTextLabel.text = nil;
    self.accessoryView = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.dragHandleImageView.hidden = YES;
}

- (void)configureInputItem:(CSSettingItem *)item {
    // 使用item.detail显示值（如果为nil则使用inputValue）
    self.detailTextLabel.text = item.detail ?: item.inputValue;
    
    // 设置标准样式
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.dragHandleImageView.hidden = YES;
}

- (void)configureDisclosureItem:(CSSettingItem *)item {
    self.detailTextLabel.text = item.detail;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.dragHandleImageView.hidden = YES;
}

- (void)configureActionItem:(CSSettingItem *)item {
    // 移除蓝色加粗的文字样式，使用普通文字样式
    self.textLabel.textAlignment = NSTextAlignmentLeft; // 改为左对齐
    self.textLabel.textColor = [UIColor labelColor]; // 使用默认文字颜色
    self.textLabel.font = [UIFont systemFontOfSize:17]; // 使用常规文字粗细
    self.detailTextLabel.text = item.detail; // 显示详情文本
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // 添加指示箭头
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.dragHandleImageView.hidden = YES;
}

- (void)configureNormalItem:(CSSettingItem *)item {
    self.detailTextLabel.text = item.detail;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.dragHandleImageView.hidden = YES;
}

- (void)configureDraggableItem:(CSSettingItem *)item {
    // 显示拖动手柄
    self.dragHandleImageView.hidden = NO;
    
    // 设置详情文本
    self.detailTextLabel.text = item.detail;
    
    // 统一使用iOS标准浅灰色
    self.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    
    // 右侧显示拖动手柄
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    // 设置拖动标识
    self.shouldIndentWhileEditing = NO;
    self.showsReorderControl = YES;
}

- (void)switchValueChanged:(UISwitch *)sender {
    if (self.currentItem.switchValueChanged) {
        self.currentItem.switchValue = sender.on;
        self.currentItem.switchValueChanged(sender.on);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置一个固定的左边距，确保所有单元格标题对齐
    CGFloat fixedLabelX = 54.0f;  // 固定的标题标签X坐标
    CGFloat spacing = 10.0f;      // 标题和详情之间的间距
    CGFloat rightMargin = 15.0f;  // 右边距
    
    // 确保在首次布局时强制刷新布局
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 触发一次额外的布局刷新
        [self setNeedsLayout];
    });
    
    // 设置标题文本位置 - 使用固定左边距
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = fixedLabelX;
    self.textLabel.frame = textLabelFrame;
    
    // 图标仍然使用自动布局，位置不变
    
    // 详情文本处理
    if (self.detailTextLabel.text.length > 0) {
        CGRect detailFrame = self.detailTextLabel.frame;
        
        if (self.shouldAlignRight) {
            // 靠右显示详情文本
            detailFrame.origin.x = self.contentView.bounds.size.width - rightMargin - detailFrame.size.width;
        } else {
            // 计算详情文本的位置
            // 先计算标题文本的宽度
            CGFloat titleWidth = [self.textLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, textLabelFrame.size.height)].width;
            
            // 固定详情文本的起始位置，确保对齐
            CGFloat fixedDetailX = fixedLabelX + 80.0f; // 或者其他合适的值
            
            if (fixedDetailX > fixedLabelX + titleWidth + spacing) {
                detailFrame.origin.x = fixedDetailX;
            } else {
                // 如果标题太长，则使用标题结束位置 + 间距
                detailFrame.origin.x = fixedLabelX + titleWidth + spacing;
            }
        }
        
        self.detailTextLabel.frame = detailFrame;
    }
    
    // 在编辑模式下调整拖动手柄的位置
    if (self.currentItem && self.currentItem.itemType == CSSettingItemTypeDraggable) {
        if (self.editing) {
            self.dragHandleImageView.hidden = YES; // 编辑模式下隐藏自定义拖动手柄
        } else {
            self.dragHandleImageView.hidden = NO; // 非编辑模式下显示自定义拖动手柄
        }
    }
}

// 实现CSConfigurableCell协议方法
- (void)updateAppearance {
    // 强制刷新布局
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)handleSelection {
    if (self.currentItem) {
        switch (self.currentItem.itemType) {
            case CSSettingItemTypeAction:
                [self.currentItem performAction];
                break;
            case CSSettingItemTypeNormal:
            case CSSettingItemTypeDisclosure:
                if (self.currentItem.canPerformAction && self.currentItem.detail.length > 0) {
                    [self.currentItem copyItemDetail];
                    // 复制成功后显示提示信息
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil 
                                                                                  message:@"已复制到剪贴板" 
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                    // 寻找当前的视图控制器
                    UIViewController *viewController = nil;
                    UIResponder *responder = self;
                    while ((responder = [responder nextResponder])) {
                        if ([responder isKindOfClass:[UIViewController class]]) {
                            viewController = (UIViewController *)responder;
                            break;
                        }
                    }
                    
                    if (viewController) {
                        [viewController presentViewController:alert animated:YES completion:^{
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            });
                        }];
                    }
                }
                break;
            default:
                break;
        }
    }
}

// 添加新的tapped方法
- (void)tapped {
    [self handleSelection];
}

@end

@implementation CSUIHelper

+ (void)showInputAlertWithTitle:(NSString *)title
                        message:(nullable NSString *)message
                       initialValue:(nullable NSString *)initialValue
                       placeholder:(nullable NSString *)placeholder
                      inViewController:(UIViewController *)viewController
                      completion:(void(^)(NSString *value))completion {
    // 创建弹窗
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    // 添加确认按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 获取输入文本
        UITextField *textField = alert.textFields.firstObject;
        NSString *text = textField.text;
        
        // 执行回调
        if (completion) {
            completion(text ?: @"");
        }
    }]];
    
    // 添加文本输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeholder ?: @"请输入";
        textField.text = initialValue ?: @"";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        // 统一使用默认键盘，不再区分数字输入和文本输入
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    // 显示弹窗
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)showCopySuccessToast:(UIViewController *)viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil 
                                                                  message:@"已复制到剪贴板" 
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [viewController presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

@end 