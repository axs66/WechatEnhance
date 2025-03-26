#import <UIKit/UIKit.h>
#import "CSSettingTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

// 入口显示模式枚举
typedef NS_ENUM(NSInteger, CSEntryDisplayMode) {
    CSEntryDisplayModeMore = 0,     // 设置页面（原始位置）
    CSEntryDisplayModePlugin = 1,   // 插件入口（MinimizeViewController）
    CSEntryDisplayModeBoth = 2      // 两处都显示
};

// 入口设置控制器 - 用于配置自定义入口的显示位置
@interface CSEntrySettingsViewController : UITableViewController

@end

NS_ASSUME_NONNULL_END 