// 消息时间显示Hook
// 显示每条消息的发送时间

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// UserDefaults Key常量
static NSString * const kMessageTimeEnabledKey = @"com.wechat.enhance.messageTime.enabled";
static NSString * const kMessageTimeFontSizeKey = @"com.wechat.enhance.messageTime.fontSize";
static NSString * const kMessageTimeTextColorKey = @"com.wechat.enhance.messageTime.textColor";
static NSString * const kMessageTimeBackgroundColorKey = @"com.wechat.enhance.messageTime.backgroundColor";
static NSString * const kMessageTimeCornerRadiusKey = @"com.wechat.enhance.messageTime.cornerRadius";
static NSString * const kMessageTimeTextAlphaKey = @"com.wechat.enhance.messageTime.textAlpha";
static NSString * const kMessageTimeBackgroundAlphaKey = @"com.wechat.enhance.messageTime.backgroundAlpha";
// 显示格式控制
static NSString * const kMessageTimeShowYearKey = @"com.wechat.enhance.messageTime.showYear";
static NSString * const kMessageTimeShowMonthKey = @"com.wechat.enhance.messageTime.showMonth";
static NSString * const kMessageTimeShowDayKey = @"com.wechat.enhance.messageTime.showDay";
static NSString * const kMessageTimeShowHourKey = @"com.wechat.enhance.messageTime.showHour";
static NSString * const kMessageTimeShowMinuteKey = @"com.wechat.enhance.messageTime.showMinute";
static NSString * const kMessageTimeShowSecondKey = @"com.wechat.enhance.messageTime.showSecond";
// 位置控制
static NSString * const kMessageTimeShowBelowAvatarKey = @"com.wechat.enhance.messageTime.showBelowAvatar";
// 字体加粗控制
static NSString * const kMessageTimeBoldFontKey = @"com.wechat.enhance.messageTime.boldFont";

// 默认值
static CGFloat const kDefaultFontSize = 9.0f;
static CGFloat const kDefaultCornerRadius = 2.0f;
static CGFloat const kDefaultTextAlpha = 0.8f;
static CGFloat const kDefaultBackgroundAlpha = 0.0f;
static CGFloat const kMaxLabelWidth = 90.0f; // 时间标签最大宽度

// 类声明
@interface CMessageWrap : NSObject
@property(nonatomic) unsigned int m_uiCreateTime; // 消息创建时间
@property(nonatomic) unsigned int m_uiMessageType; // 消息类型
@property(readonly, nonatomic) BOOL IsImgMsg;      // 是否是图片消息
@property(readonly, nonatomic) BOOL IsVideoMsg;    // 是否是视频消息
@property(readonly, nonatomic) BOOL IsVoiceMsg;    // 是否是语音消息
@property(readonly, nonatomic) BOOL IsTextMsg;     // 是否是文本消息
@property(readonly, nonatomic) NSString *m_nsContent; // 消息内容
@property(readonly, nonatomic) unsigned int m_uiMesLocalID; // 消息本地ID，用于唯一标识消息
@end

@interface CommonMessageViewModel : NSObject
@property(readonly, nonatomic) BOOL isSender; // 是否是发送者
@property(retain, nonatomic) CMessageWrap *messageWrap; // 消息包装对象
@property(nonatomic) unsigned int createTime; // 消息创建时间
@end

@interface TextMessageSubViewModel : CommonMessageViewModel
@property(readonly, nonatomic) CommonMessageViewModel *parentModel; // 对于长文本消息，父模型
@property(readonly, nonatomic) NSArray *subViewModels; // 子视图模型列表
@end

@interface CommonMessageCellView : UIView
@property(readonly, nonatomic) CommonMessageViewModel *viewModel; // 消息视图模型
@property(nonatomic, readonly) UIView *m_contentView; // 内容视图
- (UIView *)getBgImageView; // 获取背景图片视图
- (void)updateNodeStatus; // 更新节点状态
@end

@interface VoiceMessageCellView : CommonMessageCellView
@property(nonatomic, readonly) UILabel *m_secLabel; // 语音消息秒数标签
@end

@interface BaseMsgContentViewController : UIViewController
@property(nonatomic, readonly) UITableView *tableView; // 消息表格视图
@end

@interface ChatTableViewCell : UITableViewCell
- (CommonMessageCellView *)cellView; // 获取消息Cell视图
@end

// 存储消息时间的关联对象key
static char kMessageTimeKey;
// 存储消息时间视图的关联对象key
static char kTimeViewKey;

// 辅助函数
static void setMessageTime(id self, NSString *time) {
    objc_setAssociatedObject(self, &kMessageTimeKey, time, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static NSString *getMessageTime(id self) {
    return objc_getAssociatedObject(self, &kMessageTimeKey);
}

static void setTimeView(id self, UIView *view) {
    objc_setAssociatedObject(self, &kTimeViewKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static UIView *getTimeView(id self) {
    return objc_getAssociatedObject(self, &kTimeViewKey);
}

// 获取颜色设置
static UIColor *getTextColorFromDefaults() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 获取保存的颜色
    NSData *colorData = [defaults objectForKey:kMessageTimeTextColorKey];
    if (colorData) {
        NSError *error = nil;
        UIColor *savedColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
        if (savedColor && !error) {
            // 应用保存的文字透明度
            CGFloat alpha = [defaults floatForKey:kMessageTimeTextAlphaKey];
            if (alpha == 0 && ![defaults objectForKey:kMessageTimeTextAlphaKey]) {
                alpha = kDefaultTextAlpha;
            }
            return [savedColor colorWithAlphaComponent:alpha];
        }
        if (error) {
            NSLog(@"解档消息时间文字颜色时出错: %@", error);
        }
    }
    // 返回默认颜色
    CGFloat alpha = [defaults floatForKey:kMessageTimeTextAlphaKey];
    if (alpha == 0 && ![defaults objectForKey:kMessageTimeTextAlphaKey]) {
        alpha = kDefaultTextAlpha;
    }
    return [UIColor colorWithWhite:0.5 alpha:alpha];
}

static UIColor *getBackgroundColorFromDefaults() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 获取保存的颜色
    NSData *colorData = [defaults objectForKey:kMessageTimeBackgroundColorKey];
    if (colorData) {
        NSError *error = nil;
        UIColor *savedColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
        if (savedColor && !error && ![savedColor isEqual:[UIColor clearColor]]) {
            // 应用保存的背景透明度
            CGFloat alpha = [defaults floatForKey:kMessageTimeBackgroundAlphaKey];
            if (alpha == 0 && ![defaults objectForKey:kMessageTimeBackgroundAlphaKey]) {
                alpha = kDefaultBackgroundAlpha;
            }
            return [savedColor colorWithAlphaComponent:alpha];
        }
        if (error) {
            NSLog(@"解档消息时间背景颜色时出错: %@", error);
        }
    }
    
    // 检查是否有设置背景透明度但没有设置颜色
    CGFloat alpha = [defaults floatForKey:kMessageTimeBackgroundAlphaKey];
    if (alpha > 0) {
        return [UIColor colorWithWhite:0.9 alpha:alpha];
    }
    
    // 默认为透明
    return [UIColor clearColor];
}

// 格式化时间的工具方法
static NSString* getTimeStringFromTimestamp(unsigned int timestamp) {
    // 处理时间戳
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 获取显示设置
    BOOL showYear = [defaults boolForKey:kMessageTimeShowYearKey];
    BOOL showMonth = [defaults boolForKey:kMessageTimeShowMonthKey];
    BOOL showDay = [defaults boolForKey:kMessageTimeShowDayKey];
    BOOL showHour = [defaults boolForKey:kMessageTimeShowHourKey];
    BOOL showMinute = [defaults boolForKey:kMessageTimeShowMinuteKey];
    BOOL showSecond = [defaults boolForKey:kMessageTimeShowSecondKey];
    
    // 如果没有任何显示选项开启，默认显示时分
    if (!showYear && !showMonth && !showDay && !showHour && !showMinute && !showSecond) {
        showHour = YES;
        showMinute = YES;
    }
    
    NSMutableArray *components = [NSMutableArray array];
    
    // 构建日期部分 - 使用短横线分隔
    NSMutableString *dateComponent = [NSMutableString string];
    
    // 添加年份
    if (showYear) {
        NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
        [yearFormatter setDateFormat:@"yyyy"];
        [dateComponent appendString:[yearFormatter stringFromDate:date]];
    }
    
    // 添加月份
    if (showMonth) {
        // 如果已经有年份，添加分隔符
        if (showYear && dateComponent.length > 0) {
            [dateComponent appendString:@"-"];
        }
        
        NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
        [monthFormatter setDateFormat:@"MM"];
        [dateComponent appendString:[monthFormatter stringFromDate:date]];
        
        // 如果还要显示日，添加分隔符
        if (showDay) {
            [dateComponent appendString:@"-"];
        }
    }
    
    // 添加日
    if (showDay) {
        // 如果没有月份但有年份，需要添加分隔符
        if (!showMonth && showYear && dateComponent.length > 0) {
            [dateComponent appendString:@"-"];
        }
        
        NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
        [dayFormatter setDateFormat:@"dd"];
        [dateComponent appendString:[dayFormatter stringFromDate:date]];
    }
    
    // 构建时间部分 - 使用冒号分隔
    NSMutableString *timeComponent = [NSMutableString string];
    
    // 添加时
    if (showHour) {
        NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
        [hourFormatter setDateFormat:@"HH"];
        [timeComponent appendString:[hourFormatter stringFromDate:date]];
    }
    
    // 添加分
    if (showMinute) {
        if (showHour && timeComponent.length > 0) {
            [timeComponent appendString:@":"];
        }
        
        NSDateFormatter *minuteFormatter = [[NSDateFormatter alloc] init];
        [minuteFormatter setDateFormat:@"mm"];
        [timeComponent appendString:[minuteFormatter stringFromDate:date]];
    }
    
    // 添加秒
    if (showSecond) {
        if ((showHour || showMinute) && timeComponent.length > 0) {
            [timeComponent appendString:@":"];
        }
        
        NSDateFormatter *secondFormatter = [[NSDateFormatter alloc] init];
        [secondFormatter setDateFormat:@"ss"];
        [timeComponent appendString:[secondFormatter stringFromDate:date]];
    }
    
    // 添加到组件列表，让日期在上，时间在下
    if (dateComponent.length > 0) {
        [components addObject:dateComponent];
    }
    
    if (timeComponent.length > 0) {
        [components addObject:timeComponent];
    }
    
    // 如果没有任何组件，显示默认时间
    if (components.count == 0) {
        NSDateFormatter *defaultFormatter = [[NSDateFormatter alloc] init];
        [defaultFormatter setDateFormat:@"HH:mm"];
        [components addObject:[defaultFormatter stringFromDate:date]];
    }
    
    // 使用换行符连接所有组件
    return [components componentsJoinedByString:@"\n"];
}

// 检查是否启用了时间显示功能
static BOOL isMessageTimeEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kMessageTimeEnabledKey];
}

// Hook CommonMessageCellView类，这是消息气泡的基类
%hook CommonMessageCellView

- (id)initWithViewModel:(id)arg1 {
    id view = %orig;
    if (view) {
        // 从UserDefaults获取字体大小设置
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        CGFloat fontSize = [defaults floatForKey:kMessageTimeFontSizeKey];
        if (fontSize == 0) fontSize = kDefaultFontSize;
        
        // 创建时间标签，但不立即添加到视图
        UILabel *timeLabel = [[UILabel alloc] init];
        
        // 根据设置决定是否使用粗体字
        BOOL useBoldFont = [defaults boolForKey:kMessageTimeBoldFontKey];
        if (useBoldFont) {
            timeLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        } else {
            timeLabel.font = [UIFont systemFontOfSize:fontSize];
        }
        
        timeLabel.textColor = getTextColorFromDefaults();
        timeLabel.backgroundColor = getBackgroundColorFromDefaults();
        
        // 设置圆角
        CGFloat cornerRadius = [defaults floatForKey:kMessageTimeCornerRadiusKey];
        if (cornerRadius == 0) cornerRadius = kDefaultCornerRadius;
        timeLabel.layer.cornerRadius = cornerRadius;
        
        // 支持换行和文字自动调整大小
        timeLabel.numberOfLines = 0; // 允许多行
        timeLabel.adjustsFontSizeToFitWidth = NO; // 不缩小字体，保持清晰度
        timeLabel.clipsToBounds = YES;
        timeLabel.textAlignment = NSTextAlignmentCenter; // 居中对齐
        
        // 计算标签的初始大小 - 真实大小将在updateNodeStatus中更新
        CGSize labelSize = CGSizeMake(40, 30); // 一个初始值，实际会在设置文本时调整
        timeLabel.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
        
        // 关联时间标签到视图
        setTimeView(self, timeLabel);
    }
    return view;
}

- (void)updateNodeStatus {
    %orig;
    
    // 如果功能未启用，直接返回
    if (!isMessageTimeEnabled()) {
        UIView *timeView = getTimeView(self);
        if (timeView) {
            timeView.hidden = YES;
        }
        return;
    }
    
    // 获取视图模型
    id viewModel = [self valueForKey:@"viewModel"];
    if (![viewModel respondsToSelector:@selector(isSender)]) {
        return;
    }
    
    // 获取时间文本
    NSString *messageTime = getMessageTime(viewModel);
    if (messageTime.length > 0) {
        // 如果标记为不显示，则隐藏
        if ([messageTime isEqualToString:@"-1"]) {
            getTimeView(self).hidden = YES;
            return;
        }
        
        // 获取时间标签并更新设置
        UILabel *timeLabel = (UILabel *)getTimeView(self);
        if (!timeLabel) return;
        
        // 更新时间标签的样式，以防设置有变化
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // 更新字体大小和加粗
        CGFloat fontSize = [defaults floatForKey:kMessageTimeFontSizeKey];
        if (fontSize == 0) fontSize = kDefaultFontSize;
        
        // 根据设置决定是否使用粗体字
        BOOL useBoldFont = [defaults boolForKey:kMessageTimeBoldFontKey];
        if (useBoldFont) {
            timeLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        } else {
            timeLabel.font = [UIFont systemFontOfSize:fontSize];
        }
        
        // 更新颜色
        timeLabel.textColor = getTextColorFromDefaults();
        timeLabel.backgroundColor = getBackgroundColorFromDefaults();
        
        // 更新圆角
        CGFloat cornerRadius = [defaults floatForKey:kMessageTimeCornerRadiusKey];
        if (cornerRadius == 0) cornerRadius = kDefaultCornerRadius;
        timeLabel.layer.cornerRadius = cornerRadius;
        
        timeLabel.hidden = NO;
        timeLabel.text = messageTime;
        
        // 计算标签大小，限制最大宽度
        CGFloat padding = 10.0; // 左右各5点的内边距
        CGSize constraintSize = CGSizeMake(kMaxLabelWidth - padding, CGFLOAT_MAX);
        CGSize textSize = [messageTime boundingRectWithSize:constraintSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: timeLabel.font}
                                               context:nil].size;
                                               
        // 确保有足够的空间包含文本
        CGFloat labelWidth = textSize.width + padding;
        if (labelWidth > kMaxLabelWidth) labelWidth = kMaxLabelWidth;
        if (labelWidth < 30) labelWidth = 30; // 最小宽度
        
        CGFloat labelHeight = textSize.height + 8.0; // 上下各4点的内边距
        timeLabel.frame = CGRectMake(0, 0, labelWidth, labelHeight);
        
        // 设置时间标签位置
        CGFloat centerX = 0, centerY = 0;
        BOOL isSender = [viewModel isSender];
        
        // 检查是否应该显示在头像下方
        BOOL showBelowAvatar = [[NSUserDefaults standardUserDefaults] boolForKey:kMessageTimeShowBelowAvatarKey];
        
        // 获取内容视图，在两个分支中都可能用到
        UIView *contentView = [self valueForKey:@"m_contentView"];
        // 获取气泡背景视图，可能会用到
        UIView *bgView = nil;
        
        if (showBelowAvatar) {
            // 尝试找到头像视图
            UIView *headImageView = nil;
            
            // 遍历子视图寻找MMHeadImageView
            for (UIView *subview in self.subviews) {
                if ([NSStringFromClass([subview class]) isEqualToString:@"MMHeadImageView"]) {
                    headImageView = subview;
                    break;
                }
            }
            
            if (headImageView) {
                // 设置位置在头像下方居中
                centerX = CGRectGetMidX(headImageView.frame);
                // 计算中心点Y坐标，使标签顶部紧贴头像底部
                CGFloat topY = CGRectGetMaxY(headImageView.frame);
                centerY = topY + (timeLabel.bounds.size.height / 2) - 7.0; // 向上移动4像素
            } else {
                // 如果找不到头像，使用默认位置
                if (contentView) {
                    if (isSender) {
                        centerX = CGRectGetMinX(contentView.frame) - 1 - timeLabel.bounds.size.width / 2;
                    } else {
                        centerX = CGRectGetMaxX(contentView.frame) + 1 + timeLabel.bounds.size.width / 2;
                    }
                    centerY = CGRectGetMaxY(contentView.frame) - timeLabel.bounds.size.height / 2; // 向上移动4像素
                }
            }
        } else {
            // 使用原来的位置逻辑
            // 统一处理所有消息类型，包括语音消息
            
            if (contentView) {
                if (isSender) {
                    centerX = CGRectGetMinX(contentView.frame) - 1 - timeLabel.bounds.size.width / 2;
                } else {
                    centerX = CGRectGetMaxX(contentView.frame) + 1 + timeLabel.bounds.size.width / 2;
                }
                centerY = CGRectGetMaxY(contentView.frame) - timeLabel.bounds.size.height / 2;
            } else {
                // 如果无法获取内容视图，则使用气泡背景视图
                bgView = [self getBgImageView];
                if (bgView) {
                    if (isSender) {
                        centerX = CGRectGetMinX(bgView.frame) - 1 - timeLabel.bounds.size.width / 2;
                    } else {
                        centerX = CGRectGetMaxX(bgView.frame) + 1 + timeLabel.bounds.size.width / 2;
                    }
                    centerY = CGRectGetMaxY(bgView.frame) - timeLabel.bounds.size.height / 2;
                }
            }
        }
        
        // 设置中心位置
        timeLabel.center = CGPointMake(centerX, centerY);
        
        // 添加到视图上
        if (![timeLabel isDescendantOfView:self]) {
            [self addSubview:timeLabel];
        }
        
        [self bringSubviewToFront:timeLabel];
    } else {
        // 没有时间信息，隐藏标签
        getTimeView(self).hidden = YES;
    }
}

- (void)prepareForReuse {
    %orig;
}

%end

// Hook BaseMsgContentViewController类，用于设置消息时间
%hook BaseMsgContentViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = %orig;
    
    // 如果功能未启用，直接返回原始结果
    if (!isMessageTimeEnabled()) {
        return cell;
    }
    
    // 仅处理聊天消息单元格
    if ([cell isKindOfClass:NSClassFromString(@"ChatTableViewCell")]) {
        // 使用dispatch_async避免阻塞UI
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ChatTableViewCell *chatCell = (ChatTableViewCell *)cell;
            CommonMessageCellView *cellView = [chatCell cellView];
            if (!cellView) return;
            
            id viewModel = [cellView valueForKey:@"viewModel"];
            if (!viewModel) return;
            
            // 从视图模型直接获取消息对象
            if ([viewModel respondsToSelector:@selector(messageWrap)]) {
                CMessageWrap *messageWrap = [viewModel messageWrap];
                if (messageWrap && [messageWrap respondsToSelector:@selector(m_uiCreateTime)]) {
                    // 使用消息对象本身的创建时间，而不是视图模型的时间
                    unsigned int createTime = messageWrap.m_uiCreateTime;
                    
                    // 如果是长文本消息的子视图模型，处理特殊情况
                    if ([viewModel isKindOfClass:NSClassFromString(@"TextMessageSubViewModel")] && 
                        getMessageTime(viewModel) == nil) {
                        
                        TextMessageSubViewModel *textSubModel = (TextMessageSubViewModel *)viewModel;
                        id parentModel = [textSubModel valueForKey:@"parentModel"];
                        
                        // 获取是否显示在头像下方的设置
                        BOOL showBelowAvatar = [[NSUserDefaults standardUserDefaults] boolForKey:kMessageTimeShowBelowAvatarKey];
                        NSArray *subViewModels = [parentModel valueForKey:@"subViewModels"];
                        
                        if (subViewModels.count > 0) {
                            // 根据设置决定在哪个子视图上显示时间
                            if (showBelowAvatar) {
                                // 如果设置为显示在头像下方，则在第一个子视图上显示
                                if ([subViewModels indexOfObject:textSubModel] == 0) {
                                    NSString *timeStr = getTimeStringFromTimestamp(createTime);
                                    setMessageTime(viewModel, timeStr);
                                } else {
                                    setMessageTime(viewModel, @"-1");
                                }
                            } else {
                                // 如果未设置显示在头像下方，则保持原来的行为，在最后一个子视图上显示
                                if ([subViewModels indexOfObject:textSubModel] == subViewModels.count - 1) {
                                    NSString *timeStr = getTimeStringFromTimestamp(createTime);
                                    setMessageTime(viewModel, timeStr);
                                } else {
                                    setMessageTime(viewModel, @"-1");
                                }
                            }
                        }
                    } 
                    // 处理其他类型的消息
                    else if (getMessageTime(viewModel) == nil) {
                        NSString *timeStr = getTimeStringFromTimestamp(createTime);
                        setMessageTime(viewModel, timeStr);
                    }
                    
                    // 在主线程更新视图
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([cellView respondsToSelector:@selector(updateNodeStatus)]) {
                            [cellView updateNodeStatus];
                        }
                    });
                }
            }
            // 如果没有messageWrap但有createTime属性
            else if ([viewModel respondsToSelector:@selector(createTime)] && 
                    getMessageTime(viewModel) == nil) {
                
                unsigned int createTime = [viewModel createTime];
                NSString *timeStr = getTimeStringFromTimestamp(createTime);
                setMessageTime(viewModel, timeStr);
                
                // 在主线程更新视图
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([cellView respondsToSelector:@selector(updateNodeStatus)]) {
                        [cellView updateNodeStatus];
                    }
                });
            }
        });
    }
    
    return cell;
}

%end 