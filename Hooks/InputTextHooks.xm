// 聊天输入框占位文本Hook
// 在输入框显示自定义的灰色文本

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

// UserDefaults Key常量
static NSString * const kInputTextEnabledKey = @"com.wechat.enhance.inputText.enabled";
static NSString * const kInputTextContentKey = @"com.wechat.enhance.inputText.content";
static NSString * const kInputTextColorKey = @"com.wechat.enhance.inputText.color";
static NSString * const kInputTextAlphaKey = @"com.wechat.enhance.inputText.alpha";
static NSString * const kInputTextFontSizeKey = @"com.wechat.enhance.inputText.fontSize";
static NSString * const kInputTextBoldKey = @"com.wechat.enhance.inputText.bold";
// 添加输入框圆角设置键
static NSString * const kInputTextRoundedCornersKey = @"com.wechat.enhance.inputText.roundedCorners";
// 添加圆角大小设置键
static NSString * const kInputTextCornerRadiusKey = @"com.wechat.enhance.inputText.cornerRadius";
// 添加边框相关设置键
static NSString * const kInputTextBorderEnabledKey = @"com.wechat.enhance.inputText.border.enabled";
static NSString * const kInputTextBorderWidthKey = @"com.wechat.enhance.inputText.border.width";
static NSString * const kInputTextBorderColorKey = @"com.wechat.enhance.inputText.border.color";

// 默认值
static NSString * const kDefaultInputText = @"我爱你呀";
static CGFloat const kDefaultFontSize = 15.0f;
static CGFloat const kDefaultTextAlpha = 0.5f;
// 输入框圆角大小
static CGFloat const kDefaultCornerRadius = 18.0f;
// 输入框边框默认值
static CGFloat const kDefaultBorderWidth = 1.0f;

// 存储当前是否在聊天界面
static BOOL isInChatView = NO;

// 聊天界面声明
@interface BaseMsgContentViewController : UIViewController
- (id)GetContact;
@end

// 类声明
@interface MMGrowTextView : UIView
@property(nonatomic) __weak NSString *placeHolder;
@property(nonatomic) __weak NSAttributedString *attributePlaceholder;
- (void)setPlaceHolderColor:(UIColor *)color;
- (void)setPlaceHolderMultiLine:(BOOL)multiLine;
@end

@interface MMInputToolView : UIView
@property(retain, nonatomic) MMGrowTextView *textView;
@end

// 检查功能是否启用
static BOOL isInputTextEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kInputTextEnabledKey];
}

// 检查输入框圆角是否启用
static BOOL isInputTextRoundedCornersEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kInputTextRoundedCornersKey];
}

// 检查输入框边框是否启用
static BOOL isInputTextBorderEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kInputTextBorderEnabledKey];
}

// 检查是否应该应用输入框样式(必须在聊天界面且功能启用)
static BOOL shouldApplyInputTextStyle() {
    return isInChatView && isInputTextEnabled();
}

// 检查是否应该应用圆角样式(必须在聊天界面且功能启用)
static BOOL shouldApplyRoundedCorners() {
    return isInChatView && isInputTextRoundedCornersEnabled();
}

// 检查是否应该应用边框样式(必须在聊天界面且功能启用)
static BOOL shouldApplyBorder() {
    return isInChatView && isInputTextBorderEnabled();
}

// 获取圆角大小设置
static CGFloat getCornerRadius() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat cornerRadius = [defaults floatForKey:kInputTextCornerRadiusKey];
    // 如果没有设置过或者值为0，返回默认值
    if (cornerRadius <= 0) {
        cornerRadius = kDefaultCornerRadius;
    }
    return cornerRadius;
}

// 获取边框宽度设置
static CGFloat getBorderWidth() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat borderWidth = [defaults floatForKey:kInputTextBorderWidthKey];
    // 如果没有设置过或者值为0，返回默认值
    if (borderWidth <= 0) {
        borderWidth = kDefaultBorderWidth;
    }
    return borderWidth;
}

// 获取边框颜色设置
static UIColor *getBorderColorFromDefaults() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 获取保存的颜色
    NSData *colorData = [defaults objectForKey:kInputTextBorderColorKey];
    if (colorData) {
        NSError *error = nil;
        UIColor *savedColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
        if (savedColor && !error) {
            return savedColor;
        }
        if (error) {
            NSLog(@"解档边框颜色时出错: %@", error);
        }
    }
    // 返回默认颜色
    return [UIColor systemGrayColor];
}

// 获取保存的设置内容
static NSString *getInputTextContent() {
    NSString *savedText = [[NSUserDefaults standardUserDefaults] objectForKey:kInputTextContentKey];
    return savedText.length > 0 ? savedText : kDefaultInputText;
}

// 获取文字颜色设置
static UIColor *getTextColorFromDefaults() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 获取保存的颜色
    NSData *colorData = [defaults objectForKey:kInputTextColorKey];
    if (colorData) {
        NSError *error = nil;
        UIColor *savedColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[UIColor class] fromData:colorData error:&error];
        if (savedColor && !error) {
            // 应用保存的文字透明度
            CGFloat alpha = [defaults floatForKey:kInputTextAlphaKey];
            if (alpha == 0 && ![defaults objectForKey:kInputTextAlphaKey]) {
                alpha = kDefaultTextAlpha;
            }
            return [savedColor colorWithAlphaComponent:alpha];
        }
        if (error) {
            NSLog(@"解档文字颜色时出错: %@", error);
        }
    }
    // 返回默认颜色
    CGFloat alpha = [defaults floatForKey:kInputTextAlphaKey];
    if (alpha == 0 && ![defaults objectForKey:kInputTextAlphaKey]) {
        alpha = kDefaultTextAlpha;
    }
    return [UIColor colorWithWhite:0.5 alpha:alpha];
}

// 应用圆角和边框设置
static void applyRoundedCornersIfNeeded(MMGrowTextView *textView) {
    BOOL shouldApplyCorners = shouldApplyRoundedCorners();
    BOOL shouldApplyBorderStyle = shouldApplyBorder();
    
    if (!shouldApplyCorners && !shouldApplyBorderStyle) {
        // 如果圆角和边框功能都未启用或不在聊天界面，将圆角和边框重置为0
        textView.layer.cornerRadius = 0;
        textView.layer.borderWidth = 0;
        textView.clipsToBounds = NO;
        return;
    }
    
    // 获取用户设置
    CGFloat cornerRadius = shouldApplyCorners ? getCornerRadius() : 0;
    CGFloat borderWidth = shouldApplyBorderStyle ? getBorderWidth() : 0;
    UIColor *borderColor = shouldApplyBorderStyle ? getBorderColorFromDefaults() : [UIColor clearColor];
    
    // 只在最外层容器应用圆角和边框
    textView.layer.cornerRadius = cornerRadius;
    textView.layer.borderWidth = borderWidth;
    textView.layer.borderColor = borderColor.CGColor;
    textView.clipsToBounds = (cornerRadius > 0);
}

// 应用占位文本设置的辅助函数
static void applyPlaceHolderSettings(MMGrowTextView *textView) {
    if (!shouldApplyInputTextStyle()) {
        // 即使不应用占位文本，也尝试应用圆角和边框设置
        if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            applyRoundedCornersIfNeeded(textView);
        }
        return;
    }
    
    // 获取自定义设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *customText = getInputTextContent();
    CGFloat fontSize = [defaults floatForKey:kInputTextFontSizeKey];
    if (fontSize <= 0) fontSize = kDefaultFontSize;
    BOOL isBold = [defaults boolForKey:kInputTextBoldKey];
    
    // 设置颜色
    UIColor *textColor = getTextColorFromDefaults();
    [textView setPlaceHolderColor:textColor];
    
    // 支持多行
    [textView setPlaceHolderMultiLine:YES];
    
    // 创建字体
    UIFont *font = isBold ? 
        [UIFont boldSystemFontOfSize:fontSize] : 
        [UIFont systemFontOfSize:fontSize];
    
    // 设置富文本样式的占位文本
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: textColor,
        NSParagraphStyleAttributeName: paragraphStyle
    };
    
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] 
                                               initWithString:customText 
                                               attributes:attributes];
    
    textView.attributePlaceholder = attributedPlaceholder;
    
    // 同时设置普通占位文本，以防富文本设置无效
    textView.placeHolder = customText;
    
    // 应用圆角和边框设置
    applyRoundedCornersIfNeeded(textView);
}

// Hook BaseMsgContentViewController来识别聊天界面
%hook BaseMsgContentViewController

- (void)viewDidLoad {
    %orig;
    isInChatView = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    isInChatView = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    isInChatView = NO;
}

%end

// Hook MMGrowTextView类，这是微信的输入框类
%hook MMGrowTextView

- (id)init {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithExtConfig:(id)arg1 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithOriginHeight:(double)arg1 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithOriginHeight:(double)arg1 extConfig:(id)arg2 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithDonotNeedTextViewContentTopBottomInset:(_Bool)arg1 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithDonotNeedTextViewContentTopBottomInset:(_Bool)arg1 matchInnerViewHeightWithFrame:(_Bool)arg2 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

- (id)initWithOriginHeight:(double)arg1 WithDonotNeedTextViewContentTopBottomInset:(_Bool)arg2 extConfig:(id)arg3 matchInnerViewHeightWithFrame:(_Bool)arg4 {
    id view = %orig;
    if (view) {
        applyPlaceHolderSettings(self);
    }
    return view;
}

// 添加布局后的处理，确保圆角设置正确应用
- (void)layoutSubviews {
    %orig;
    // 应用圆角设置，即使placeholder功能未启用
    if (shouldApplyRoundedCorners()) {
        applyRoundedCornersIfNeeded(self);
    }
}

%end

// Hook MMInputToolView，确保在视图更新时总是设置占位文本和圆角
%hook MMInputToolView

- (void)layoutSubviews {
    %orig;
    
    if (self.textView) {
        // 应用占位文本设置（如果启用）
        if (shouldApplyInputTextStyle()) {
            applyPlaceHolderSettings(self.textView);
        } else if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            // 如果只启用了圆角或边框设置，只应用这些设置
            applyRoundedCornersIfNeeded(self.textView);
        }
    }
}

- (void)updateToolViewHeight:(_Bool)arg1 {
    %orig;
    
    if (self.textView) {
        // 应用占位文本设置（如果启用）
        if (shouldApplyInputTextStyle()) {
            applyPlaceHolderSettings(self.textView);
        } else if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            // 如果只启用了圆角或边框设置，只应用这些设置
            applyRoundedCornersIfNeeded(self.textView);
        }
    }
}

- (void)onWillAppear {
    %orig;
    
    if (self.textView) {
        // 应用占位文本设置（如果启用）
        if (shouldApplyInputTextStyle()) {
            applyPlaceHolderSettings(self.textView);
        } else if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            // 如果只启用了圆角或边框设置，只应用这些设置
            applyRoundedCornersIfNeeded(self.textView);
        }
    }
}

- (void)onViewDidInit {
    %orig;
    
    if (self.textView) {
        // 应用占位文本设置（如果启用）
        if (shouldApplyInputTextStyle()) {
            applyPlaceHolderSettings(self.textView);
        } else if (shouldApplyRoundedCorners() || shouldApplyBorder()) {
            // 如果只启用了圆角或边框设置，只应用这些设置
            applyRoundedCornersIfNeeded(self.textView);
        }
    }
}

%end
