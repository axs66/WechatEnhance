/**
 * 用户信息帮助类
 * 提供统一的用户信息访问接口
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 全局常量

// 缓存相关常量
extern NSString * const kUserAvatarURLKey;    // 用户头像URL缓存键
extern NSString * const kChatAvatarURLKey;    // 聊天对象头像URL缓存键

// 插件信息相关常量
#define kPluginVersionString @"1.1.9"  // 插件版本号

#pragma mark - 类定义

/// 用户信息帮助类
@interface CSUserInfoHelper : NSObject

#pragma mark - 用户信息获取

/// 获取用户微信ID
/// @return 用户的微信ID，如果未获取到则返回空字符串
+ (nullable NSString *)getUserWXID;

/// 获取用户昵称
/// @return 用户的昵称，如果未获取到则返回"微信用户"
+ (NSString *)getUserNickname;

/// 获取用户微信号
/// @return 用户的微信号，如果未获取到则返回"未知"
+ (nullable NSString *)getUserAliasName;

/// 获取用户头像URL
/// @return 用户的头像URL
+ (nullable NSString *)getUserAvatarURL;

#pragma mark - 工具方法

/// 获取当前时间的格式化字符串
/// @return 格式化的时间字符串
+ (NSString *)getCurrentTimeString;

@end

NS_ASSUME_NONNULL_END 