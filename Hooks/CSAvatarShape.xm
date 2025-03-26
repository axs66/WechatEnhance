// 圆形头像，头像旋转相关hook

#import <UIKit/UIKit.h>
#import "../Controllers/CSAvatarSettingsViewController.h"
#import <objc/runtime.h>
// 添加 substrate 头文件导入，用于 MSHookIvar
#import <substrate.h>

// 声明MMHeadImageView类的接口
@interface MMHeadImageView : UIView
@property(readonly, nonatomic) BOOL bRoundedCorner;
@property(nonatomic) unsigned int conerSize;
@property(retain, nonatomic) UIView *headImageView; // 添加headImageView属性
- (void)setHeadImageViewCornerRadius:(double)arg1;
@end

// 声明MMUILongPressImageView类接口
@interface MMUILongPressImageView : UIView
@end

// 声明FakeHeadImageView类接口
@interface FakeHeadImageView : UIView
@property(nonatomic) unsigned int conerSize; // @synthesize conerSize=_conerSize
@property(nonatomic) struct CGSize imageSize; // @synthesize imageSize=_imageSize
@property(nonatomic) unsigned char headCategory; // @synthesize headCategory=_headCategory
@property(nonatomic) unsigned char headUseScene; // @synthesize headUseScene=_headUseScene
@property(readonly, nonatomic) BOOL m_bRoundedCorner; // 添加圆角属性
- (id)initWithRoundCorner:(BOOL)arg1;
@end

// 辅助函数：查找父视图控制器
UIViewController *findParentViewController(UIView *view) {
    UIResponder *responder = [view nextResponder];
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

// 常量定义
static NSString * const kUserDefaultsSuiteNameConst = @"com.cyansmoke.wechattweak";
static NSString * const kRoundAvatarKeyConst = @"roundAvatar";
static NSString * const kAvatarCornerRadiusKeyConst = @"avatarCornerRadius";
static NSString * const kRotateAvatarKeyConst = @"rotateAvatar";
static NSString * const kRotateSpeedKeyConst = @"rotateSpeed";

// 全局变量
static BOOL isRoundAvatarEnabled = NO;
static float customCornerRadius = 1.0f; // 默认值改为1.0 (全圆)
static BOOL isRotateAvatarEnabled = NO;
static float rotateSpeed = 5.0f;

// 添加一个关联对象key，用于存储是否已经添加了旋转动画
static char kHasRotationAnimationKey;

// 在主函数之前执行，读取用户设置
%ctor {
    // 读取用户设置
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteNameConst];
    isRoundAvatarEnabled = [defaults boolForKey:kRoundAvatarKeyConst];
    customCornerRadius = [defaults floatForKey:kAvatarCornerRadiusKeyConst];
    if (customCornerRadius == 0) {
        customCornerRadius = 1.0f; // 默认值改为1.0 (全圆)
    }
    
    // 读取旋转设置
    isRotateAvatarEnabled = [defaults boolForKey:kRotateAvatarKeyConst];
    rotateSpeed = [defaults floatForKey:kRotateSpeedKeyConst];
    if (rotateSpeed == 0) {
        rotateSpeed = 5.0f; // 默认值
    }
    
    // 调试日志
    NSLog(@"[CSAvatarShape] 已加载，圆形头像设置：%@，圆角比例：%.1f，旋转设置：%@，旋转速度：%.1f", 
          isRoundAvatarEnabled ? @"开启" : @"关闭", 
          customCornerRadius,
          isRotateAvatarEnabled ? @"开启" : @"关闭",
          rotateSpeed);
}

// Hook MMHeadImageView的初始化方法
%hook MMHeadImageView

// Hook 初始化方法，设置圆角
- (id)initWithUsrName:(id)arg1 headImgUrl:(id)arg2 bAutoUpdate:(BOOL)arg3 bRoundCorner:(BOOL)arg4 {
    // 直接在初始化时设置是否使用圆角，无需后期更改
    id result = %orig(arg1, arg2, arg3, isRoundAvatarEnabled || arg4);
    return result;
}

// Hook layoutSubviews方法，确保圆角设置在布局后也有效，并添加旋转动画
- (void)layoutSubviews {
    %orig;
    
    // 应用圆角设置 - 使用直接设置为宽度一半的方式
    if (isRoundAvatarEnabled) {
        // 获取视图尺寸
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        
        if (width > 0 && height > 0) {
            // 计算圆角半径
            CGFloat radius;
            
            // 根据圆角比例计算实际圆角大小
            if (customCornerRadius >= 0.99) {
                // 完全圆形，直接使用宽度的一半
                radius = MIN(width, height) / 2.0;
            } else {
                // 部分圆角
                radius = MIN(width, height) / 2.0 * customCornerRadius;
            }
            
            // 应用圆角设置
            self.layer.cornerRadius = radius;
            self.layer.masksToBounds = YES;
            
            // 为内部头像视图也设置圆角
            if (self.headImageView) {
                CGFloat imageWidth = self.headImageView.frame.size.width;
                CGFloat imageHeight = self.headImageView.frame.size.height;
                
                if (imageWidth > 0 && imageHeight > 0) {
                    CGFloat imageRadius;
                    
                    if (customCornerRadius >= 0.99) {
                        // 完全圆形
                        imageRadius = MIN(imageWidth, imageHeight) / 2.0;
                    } else {
                        // 部分圆角
                        imageRadius = MIN(imageWidth, imageHeight) / 2.0 * customCornerRadius;
                    }
                    
                    self.headImageView.layer.cornerRadius = imageRadius;
                    self.headImageView.layer.masksToBounds = YES;
                }
            }
        }
    }
    
    // 应用旋转动画
    // 获取是否已经添加了旋转动画
    NSNumber *hasAnimation = objc_getAssociatedObject(self, &kHasRotationAnimationKey);
    
    // 使用tag值识别"我的"页面头像视图
    BOOL isProfileAvatar = self.tag == 101;
    
    if (isRotateAvatarEnabled && isProfileAvatar) {
        // 只有在没有添加过动画的情况下才添加
        if (!hasAnimation || ![hasAnimation boolValue]) {
            // 创建旋转动画
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = @(M_PI * 2.0);
            rotationAnimation.duration = 12.0 - rotateSpeed; // 速度范围是1-10，所以11-1=10秒到2秒不等
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = HUGE_VALF;
            
            // 重要：设置removedOnCompletion为NO，这样动画不会在完成后被移除
            rotationAnimation.removedOnCompletion = NO;
            
            // 设置fillMode为forwards，这样动画会保持在最后一帧
            rotationAnimation.fillMode = kCAFillModeForwards;
            
            // 添加动画
            [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
            
            // 标记已经添加了动画
            objc_setAssociatedObject(self, &kHasRotationAnimationKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    } else {
        // 如果不需要旋转，移除动画
        if ([self.layer animationForKey:@"rotationAnimation"]) {
            [self.layer removeAnimationForKey:@"rotationAnimation"];
            objc_setAssociatedObject(self, &kHasRotationAnimationKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

// Hook conerSize属性的setter方法 - 保留这个hook以防万一
-(void)setConerSize:(unsigned int)size {
    if (isRoundAvatarEnabled) {
        // 如果启用了圆形头像，使用我们自定义的圆角大小
        %orig((unsigned int)(size * customCornerRadius));
    } else {
        // 否则使用原始值
        %orig(size);
    }
}

%end 

// 添加对 FakeHeadImageView 的 hook
%hook FakeHeadImageView

// Hook 初始化方法，设置圆角
- (id)initWithRoundCorner:(BOOL)arg1 {
    // 直接在初始化时设置是否使用圆角，无需后期更改
    return %orig(isRoundAvatarEnabled || arg1);
}

// Hook layoutSubviews 方法来应用自定义圆角设置
- (void)layoutSubviews {
    %orig;
    
    // 应用圆角设置
    if (isRoundAvatarEnabled) {
        // 获取视图尺寸
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        
        if (width > 0 && height > 0) {
            // 计算圆角半径
            CGFloat radius;
            
            // 根据圆角比例计算实际圆角大小
            if (customCornerRadius >= 0.99) {
                // 完全圆形，直接使用宽度的一半
                radius = MIN(width, height) / 2.0;
            } else {
                // 部分圆角
                radius = MIN(width, height) / 2.0 * customCornerRadius;
            }
            
            // 应用圆角设置
            self.layer.cornerRadius = radius;
            self.layer.masksToBounds = YES;
            
            // 为内部头像视图也设置圆角 (m_headImageView)
            UIImageView *headImageView = MSHookIvar<UIImageView *>(self, "m_headImageView");
            if (headImageView) {
                CGFloat imageWidth = headImageView.frame.size.width;
                CGFloat imageHeight = headImageView.frame.size.height;
                
                if (imageWidth > 0 && imageHeight > 0) {
                    CGFloat imageRadius;
                    
                    if (customCornerRadius >= 0.99) {
                        // 完全圆形
                        imageRadius = MIN(imageWidth, imageHeight) / 2.0;
                    } else {
                        // 部分圆角
                        imageRadius = MIN(imageWidth, imageHeight) / 2.0 * customCornerRadius;
                    }
                    
                    headImageView.layer.cornerRadius = imageRadius;
                    headImageView.layer.masksToBounds = YES;
                }
            }
            
            // 边框视图也设置圆角 (m_borderImageView)
            UIImageView *borderImageView = MSHookIvar<UIImageView *>(self, "m_borderImageView");
            if (borderImageView) {
                CGFloat borderWidth = borderImageView.frame.size.width;
                CGFloat borderHeight = borderImageView.frame.size.height;
                
                if (borderWidth > 0 && borderHeight > 0) {
                    CGFloat borderRadius;
                    
                    if (customCornerRadius >= 0.99) {
                        // 完全圆形
                        borderRadius = MIN(borderWidth, borderHeight) / 2.0;
                    } else {
                        // 部分圆角
                        borderRadius = MIN(borderWidth, borderHeight) / 2.0 * customCornerRadius;
                    }
                    
                    borderImageView.layer.cornerRadius = borderRadius;
                    borderImageView.layer.masksToBounds = YES;
                }
            }
        }
    }
    
    // 应用旋转动画
    NSNumber *hasAnimation = objc_getAssociatedObject(self, &kHasRotationAnimationKey);
    
    // 使用tag值识别"我的"页面头像视图
    BOOL isProfileAvatar = self.tag == 101;
    
    if (isRotateAvatarEnabled && isProfileAvatar) {
        // 只有在没有添加过动画的情况下才添加
        if (!hasAnimation || ![hasAnimation boolValue]) {
            // 创建旋转动画
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = @(M_PI * 2.0);
            rotationAnimation.duration = 12.0 - rotateSpeed; // 速度范围是1-10，所以11-1=10秒到2秒不等
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = HUGE_VALF;
            
            // 重要：设置removedOnCompletion为NO，这样动画不会在完成后被移除
            rotationAnimation.removedOnCompletion = NO;
            
            // 设置fillMode为forwards，这样动画会保持在最后一帧
            rotationAnimation.fillMode = kCAFillModeForwards;
            
            // 添加动画
            [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
            
            // 标记已经添加了动画
            objc_setAssociatedObject(self, &kHasRotationAnimationKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    } else {
        // 如果不需要旋转，移除动画
        if ([self.layer animationForKey:@"rotationAnimation"]) {
            [self.layer removeAnimationForKey:@"rotationAnimation"];
            objc_setAssociatedObject(self, &kHasRotationAnimationKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

// Hook conerSize属性的setter方法
- (void)setConerSize:(unsigned int)size {
    if (isRoundAvatarEnabled) {
        // 如果启用了圆形头像，使用我们自定义的圆角大小
        %orig((unsigned int)(size * customCornerRadius));
    } else {
        // 否则使用原始值
        %orig(size);
    }
}

%end 