#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 设置项类型
typedef NS_ENUM(NSInteger, CSSettingItemType) {
    CSSettingItemTypeNormal,  // 普通信息项
    CSSettingItemTypeAction,  // 操作项（如复制）
    CSSettingItemTypeSwitch,  // 开关项
    CSSettingItemTypeInput,   // 输入项（弹窗输入）
    CSSettingItemTypeDisclosure,  // 带有指示器的条目
    CSSettingItemTypeDraggable  // 可拖动排序项
};

// 定义通用控制协议
@protocol CSConfigurableItem <NSObject>
@required
@property (nonatomic, copy) NSString *title;  // 项目标题
@property (nonatomic, copy, nullable) NSString *detail;  // 详情文本

@optional
- (void)performAction;  // 执行项目操作
- (void)copyItemDetail;  // 复制详情内容
- (BOOL)canPerformAction;  // 是否可以执行操作
@end

// 定义通用单元格配置协议
@protocol CSConfigurableCell <NSObject>
@required
- (void)configureWithItem:(id<CSConfigurableItem>)item;  // 配置单元格
- (void)updateAppearance;  // 更新单元格外观

@optional
- (void)prepareForReuse;  // 准备复用
- (void)handleSelection;  // 处理选择事件
@end

/// 设置项数据模型
@interface CSSettingItem : NSObject <CSConfigurableItem>

@property (nonatomic, copy) NSString *title;           // 标题
@property (nonatomic, copy, nullable) NSString *iconName;        // 图标名称
@property (nonatomic, strong, nullable) UIColor *iconColor;      // 图标颜色
@property (nonatomic, copy, nullable) NSString *detail; // 详情文本
@property (nonatomic, assign, readonly) CSSettingItemType itemType; // 项目类型（只读）
@property (nonatomic, assign) BOOL switchValue;        // 开关值(仅用于开关类型)
@property (nonatomic, copy, nullable) void (^switchValueChanged)(BOOL isOn); // 开关变更回调
@property (nonatomic, copy, nullable) NSString *inputValue; // 输入值(仅用于输入类型)
@property (nonatomic, copy, nullable) NSString *inputPlaceholder; // 输入提示(仅用于输入类型)
@property (nonatomic, copy, nullable) void (^inputValueChanged)(NSString *value); // 输入值变更回调
@property (nonatomic, copy, nullable) void (^actionBlock)(void); // 操作回调(用于Action类型)

// 拖动排序相关属性
@property (nonatomic, assign) NSInteger identifier;    // 项目标识符(用于拖动排序类型)
@property (nonatomic, assign) NSInteger sortIndex;     // 排序索引(用于拖动排序类型)

// 实现CSConfigurableItem协议方法
- (void)performAction;
- (void)copyItemDetail;
- (BOOL)canPerformAction;

+ (instancetype)itemWithTitle:(NSString *)title
                    iconName:(nullable NSString *)iconName
                   iconColor:(nullable UIColor *)iconColor
                      detail:(nullable NSString *)detail;

// 创建操作项
+ (instancetype)actionItemWithTitle:(NSString *)title
                          iconName:(nullable NSString *)iconName
                         iconColor:(nullable UIColor *)iconColor;

// 创建开关项
+ (instancetype)switchItemWithTitle:(NSString *)title
                          iconName:(nullable NSString *)iconName
                         iconColor:(nullable UIColor *)iconColor
                        switchValue:(BOOL)switchValue
                   valueChangedBlock:(nullable void(^)(BOOL isOn))valueChanged;

// 创建输入项
+ (instancetype)inputItemWithTitle:(NSString *)title
                          iconName:(nullable NSString *)iconName
                         iconColor:(nullable UIColor *)iconColor
                         inputValue:(nullable NSString *)inputValue
                     inputPlaceholder:(nullable NSString *)placeholder
                    valueChangedBlock:(nullable void(^)(NSString *value))valueChanged;

// 创建可拖动排序项
+ (instancetype)draggableItemWithTitle:(NSString *)title
                             iconName:(nullable NSString *)iconName
                            iconColor:(nullable UIColor *)iconColor
                             identifier:(NSInteger)identifier
                             sortIndex:(NSInteger)sortIndex;

@end

/// 设置分组数据模型
@interface CSSettingSection : NSObject

@property (nonatomic, copy) NSString *header;                 // 分组标题
@property (nonatomic, copy) NSArray<CSSettingItem *> *items;  // 分组内容
@property (nonatomic, assign) BOOL allowsReordering;         // 是否允许重新排序
@property (nonatomic, copy, nullable) void (^orderChangedBlock)(NSArray<CSSettingItem *> *items); // 排序变更回调

+ (instancetype)sectionWithHeader:(NSString *)header items:(NSArray<CSSettingItem *> *)items;
+ (instancetype)sectionWithHeader:(NSString *)header 
                            items:(NSArray<CSSettingItem *> *)items 
                 allowsReordering:(BOOL)allowsReordering
                orderChangedBlock:(nullable void(^)(NSArray<CSSettingItem *> *items))orderChangedBlock;

@end

/// 设置页表格单元格
@interface CSSettingTableViewCell : UITableViewCell <CSConfigurableCell>

@property (nonatomic, strong, nullable) UISwitch *settingSwitch;
@property (nonatomic, assign) BOOL shouldAlignRight;      // 是否启用详情文本靠右显示

/// 注册单元格到表格视图
+ (void)registerToTableView:(UITableView *)tableView;

/// 获取单元格重用标识符
+ (NSString *)reuseIdentifier;

/// 使用设置项配置单元格
- (void)configureWithItem:(CSSettingItem *)item;

/// 更新单元格外观（实现CSConfigurableCell协议）
- (void)updateAppearance;

/// 处理单元格选择（实现CSConfigurableCell协议）
- (void)handleSelection;

@end

/// 辅助函数
@interface CSUIHelper : NSObject

/// 显示输入弹窗
+ (void)showInputAlertWithTitle:(NSString *)title
                        message:(nullable NSString *)message
                       initialValue:(nullable NSString *)initialValue
                       placeholder:(nullable NSString *)placeholder
                      inViewController:(UIViewController *)viewController
                      completion:(void(^)(NSString *value))completion;

/// 显示复制成功提示
+ (void)showCopySuccessToast:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END 