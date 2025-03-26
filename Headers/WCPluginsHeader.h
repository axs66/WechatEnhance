// WCPluginsHeader.h
// 定义其他插件提供的类和方法声明

#import <Foundation/Foundation.h>

@interface WCPluginsMgr : NSObject
+ (instancetype)sharedInstance;
- (void)registerControllerWithTitle:(NSString *)title 
                            version:(NSString *)version 
                         controller:(NSString *)controller;
@end 