#import <UIKit/UIKit.h>

@interface CSTouchTrailViewController : UITableViewController

/**
 * 检查并尝试恢复自定义图片路径
 * 当保存的图片路径失效时，尝试从固定位置恢复
 */
- (void)checkAndRestoreCustomImagePath;

@end 