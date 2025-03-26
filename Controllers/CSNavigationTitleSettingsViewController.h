#import <UIKit/UIKit.h>

// 用户默认设置的SuiteName
#define kNavigationUserDefaultsSuiteName @"com.wechat.tweak.navigation.settings"

// 头像显示模式
typedef NS_ENUM(NSInteger, CSNavigationAvatarMode) {
    CSNavigationAvatarModeNone,   // 不显示头像
    CSNavigationAvatarModeOther,  // 只显示对方头像
    CSNavigationAvatarModeSelf,   // 只显示自己头像
    CSNavigationAvatarModeBoth    // 显示两个头像
};

// 常量声明
extern NSString * const kNavigationShowAvatarKey;      // 是否显示头像
extern NSString * const kNavigationAvatarModeKey;      // 头像显示模式
extern NSString * const kNavigationAvatarSizeKey;      // 头像大小
extern NSString * const kNavigationAvatarRadiusKey;    // 头像圆角比例
extern NSString * const kNavigationSeparatorSizeKey;   // 分隔符大小
extern NSString * const kNavigationAvatarSpacingKey;   // 头像间距
extern NSString * const kNavigationVerticalOffsetKey;  // 垂直位置偏移

// 显示模式开关常量
extern NSString * const kNavigationShowSelfAvatarKey;  // 是否显示自己头像
extern NSString * const kNavigationShowOtherAvatarKey; // 是否显示对方头像
extern NSString * const kNavigationShowOtherNicknameKey; // 是否显示对方网名
extern NSString * const kNavigationShowRemarkNameKey; // 是否显示备注名而不是网名

// 场景设置常量
extern NSString * const kNavigationShowPopoverWhenTapAvatarKey; // 是否在点击头像时显示信息
extern NSString * const kNavigationShowInPrivateKey;   // 是否在私聊中显示
extern NSString * const kNavigationShowInGroupKey;     // 是否在群聊中显示
extern NSString * const kNavigationShowInOfficialKey;  // 是否在公众号中显示

// 自定义分隔符文本常量
extern NSString * const kNavigationSeparatorTextKey;   // 头像间的分隔符文本

// 分隔符设置常量
extern NSString * const kNavigationSeparatorImageKey;   // 分隔符图片路径

// 默认值常量
extern CGFloat const kDefaultAvatarSize;       // 默认头像大小
extern CGFloat const kDefaultAvatarRadius;     // 默认头像圆角比例
extern CGFloat const kDefaultSeparatorSize;    // 默认分隔符大小
extern CGFloat const kDefaultAvatarSpacing;    // 默认头像间距
extern CGFloat const kDefaultVerticalOffset;   // 默认垂直偏移
extern CGFloat const kMinAvatarSize;           // 最小头像大小
extern CGFloat const kMaxAvatarSize;           // 最大头像大小
extern CGFloat const kDefaultNicknameSize;    // 默认网名字体大小
extern CGFloat const kMinNicknameSize;        // 最小网名字体大小
extern CGFloat const kMaxNicknameSize;        // 最大网名字体大小

// 新增显示模式开关常量
extern NSString * const kNavigationNicknamePositionKey;  // 网名位置
extern NSString * const kNavigationNicknameSizeKey;      // 网名字体大小

// 网名位置枚举
typedef NS_ENUM(NSInteger, CSNavigationNicknamePosition) {
    CSNavigationNicknamePositionRight = 0,  // 右侧（默认）
    CSNavigationNicknamePositionLeft,       // 左侧
    CSNavigationNicknamePositionTop,        // 上方
    CSNavigationNicknamePositionBottom,     // 下方
};

NS_ASSUME_NONNULL_BEGIN

@interface CSNavigationTitleSettingsViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

NS_ASSUME_NONNULL_END 