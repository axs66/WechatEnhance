#import <UIKit/UIKit.h>

// 用户默认设置的SuiteName
#define kUserDefaultsSuiteName @"com.cyansmoke.wechattweak"

// 私聊场景头像隐藏设置的键
#define kHideOtherAvatarInPrivateChatKey @"hideOtherAvatarInPrivateChat"    // 私聊-隐藏对方头像
#define kHideSelfAvatarInPrivateChatKey @"hideSelfAvatarInPrivateChat"      // 私聊-隐藏自己头像
#define kHideBothAvatarInPrivateChatKey @"hideBothAvatarInPrivateChat"      // 私聊-隐藏双方头像

// 群聊场景头像隐藏设置的键
#define kHideOtherAvatarInGroupChatKey @"hideOtherAvatarInGroupChat"     // 群聊-隐藏对方头像
#define kHideSelfAvatarInGroupChatKey @"hideSelfAvatarInGroupChat"       // 群聊-隐藏自己头像
#define kHideBothAvatarInGroupChatKey @"hideBothAvatarInGroupChat"       // 群聊-隐藏双方头像

// 公众号场景头像隐藏设置的键
#define kHideOtherAvatarInOfficialAccountKey @"hideOtherAvatarInOfficialAccount" // 公众号-隐藏对方头像
#define kHideSelfAvatarInOfficialAccountKey @"hideSelfAvatarInOfficialAccount"   // 公众号-隐藏自己头像
#define kHideBothAvatarInOfficialAccountKey @"hideBothAvatarInOfficialAccount"   // 公众号-隐藏双方头像

// 头像样式相关设置的键
#define kRotateAvatarKey @"rotateAvatar"            // 旋转头像
#define kRotateSpeedKey @"rotateSpeed"              // 旋转速度
#define kRoundAvatarKey @"roundAvatar"              // 圆形头像
#define kAvatarCornerRadiusKey @"avatarCornerRadius"  // 头像圆角大小

NS_ASSUME_NONNULL_BEGIN

/// 头像设置控制器
@interface CSAvatarSettingsViewController : UITableViewController
@end

NS_ASSUME_NONNULL_END 