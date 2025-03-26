#import <UIKit/UIKit.h>

// 用户默认设置的SuiteName
#define kUserDefaultsSuiteName @"com.cyansmoke.wechattweak"

// 后台运行相关设置的键
#define kBackgroundRunEnabledKey @"BackgroundRunEnabled"
#define kBackgroundIntervalKey @"BackgroundInterval"  // 后台任务时间间隔（秒）

@interface CSBackgroundRunViewController : UITableViewController

@end 