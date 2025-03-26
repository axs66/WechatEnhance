#import <UIKit/UIKit.h>
#import "CSSettingTableViewCell.h"

@interface CSInputTextSettingsViewController : UITableViewController <UIColorPickerViewControllerDelegate>

@property (nonatomic, strong) NSArray<CSSettingSection *> *sections;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL colorTagTextColor;

@end 