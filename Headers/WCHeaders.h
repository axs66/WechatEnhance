/**
 * 微信相关头文件声明
 * 包含微信基础框架、UI组件和控制器的声明
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 设备信息类
@interface DeviceInfo : NSObject
+ (BOOL)isiPad;
+ (BOOL)isiPadOrVision;
@end

/// 矩阵设备信息类
@interface MatrixDeviceInfo : NSObject
+ (BOOL)isiPad;
@end

/// 设备工具类
@interface TPDeviceUtil : NSObject
+ (BOOL)isPadModel;
+ (BOOL)isPadInterface;
+ (long long)deviceType;
@end

/// iOS系统信息类
@interface TPIOSSystemInfo : NSObject
+ (BOOL)isPadModel;
+ (BOOL)isPadInterface;
@end

/// 平台工具实现类
@interface MMIPlatformUtilImpl : NSObject
- (BOOL)isPad;
@end

#pragma mark - 基础框架扩展

/// 导航控制器扩展
@interface UIViewController (Navigation)
@property(nonatomic, readonly, strong) UINavigationController *navigationController;
@end

#pragma mark - 表格视图组件

/// 表格分组管理器
@interface WCTableViewSectionManager : NSObject
- (void)addCell:(id)cell;
@end

/// 表格单元格管理器
@interface WCTableViewCellManager : NSObject
/// 创建标准样式的单元格
+ (id)normalCellForSel:(SEL)sel
               target:(id)target
            leftImage:(nullable id)image
               title:(id)title
               badge:(nullable id)badge
          rightValue:(nullable id)value
          rightImage:(nullable id)rightImage
     withRightRedDot:(_Bool)redDot
            selected:(_Bool)selected;
@end

/// 表格视图管理器
@interface WCTableViewManager : NSObject
- (id)getSectionAt:(unsigned int)index;
@end

#pragma mark - 头像相关

/// 长按图片视图
@interface MMUILongPressImageView : UIImageView
@end

/// 微信头像视图
@interface MMHeadImageView : UIView
@property (nonatomic, strong) MMUILongPressImageView *headImageView;
- (instancetype)initWithUsrName:(id)userName headImgUrl:(id)imgUrl bAutoUpdate:(_Bool)autoUpdate bRoundCorner:(_Bool)roundCorner;
@end

#pragma mark - 视图控制器

/// 更多页面控制器
@interface MoreViewController : UIViewController
- (void)addFunctionSection;
@end

#pragma mark - 用户信息相关

/// 登陆账号信息获取（自己）
@interface CContact : NSObject
@property (nonatomic, copy) NSString *m_nsUsrName;    // 用户ID
@property (nonatomic, copy) NSString *m_nsNickName;   // 昵称
@property (nonatomic, copy) NSString *m_nsAliasName;  // 微信号
@property (nonatomic, copy) NSString *m_nsHeadImgUrl; // 头像URL
@end

/// 联系人管理器
@interface CContactMgr : NSObject
- (CContact *)getSelfContact;
- (CContact *)getContactForSearchByName:(NSString *)userName;
@end

/// 微信全局上下文管理器
/// 用于管理和获取当前登录用户的基本信息
/// 这个类在微信启动时就会初始化，可以在任何地方获取当前用户信息
@interface MMContext : NSObject

/// 获取当前登录用户的微信ID
/// @return 当前用户的微信ID，如果未登录则返回nil
+ (id)currentUserName;

@end

#pragma mark - 聊天相关

/// 聊天内容视图控制器
@interface BaseMsgContentViewController : UIViewController
/// 获取当前聊天对象
- (CContact *)GetContact;
@end

/// 聊天消息视图模型
@interface CommonMessageViewModel : NSObject
/// 是否显示头像
- (BOOL)isShowHeadImage;
/// 是否为发送者
- (BOOL)isSender;
@end

#pragma mark - 消息管理相关

/// 消息服务中心
@interface MMServiceCenter : NSObject
+ (instancetype)defaultCenter;
- (id)getService:(Class)serviceClass;
@end

/// 消息内容对象
@interface CMessageWrap : NSObject
@property (nonatomic, copy) NSString *m_nsContent;    // 消息内容
@property (nonatomic, copy) NSString *m_nsToUsr;      // 接收人
@property (nonatomic, copy) NSString *m_nsFromUsr;    // 发送人
@property (nonatomic, assign) unsigned int m_uiStatus; // 消息状态
@property (nonatomic, assign) unsigned int m_uiCreateTime; // 创建时间
@property (nonatomic, assign) unsigned int m_uiMessageType; // 消息类型
@property (nonatomic, assign) unsigned int m_uiGameType;   // 游戏类型：1-猜拳，2-骰子
@property (nonatomic, assign) unsigned int m_uiGameContent; // 游戏内容：猜拳1-剪刀，2-石头，3-布；骰子1-6对应点数
@property (nonatomic, copy) NSString *m_nsEmoticonMD5;   // 表情MD5标识

// 设置游戏相关的方法
- (void)setM_uiGameContent:(unsigned int)gameContent;
- (void)setM_nsEmoticonMD5:(NSString *)md5;

+ (instancetype)createWithRevokeMsgXml:(NSString *)xml;
@end

/// 消息管理器
@interface CMessageMgr : NSObject
- (BOOL)onRevokeMsg:(CMessageWrap *)msgWrap;
- (void)AddLocalMsg:(NSString *)userName MsgWrap:(CMessageWrap *)wrap Time:(unsigned int)time;
- (id)getMessageFromLocalID:(NSString *)fromUser localId:(NSString *)localId;
@end

#pragma mark - 游戏相关

/// 游戏控制器类
@interface GameController : NSObject
/// 根据游戏内容获取对应的MD5标识
+ (NSString *)getMD5ByGameContent:(unsigned int)gameContent;
@end

#pragma mark - 登录界面相关
@interface WCAccountLoginFirstViewController : UIViewController
@property (nonatomic, strong) UIButton *deviceModeButton;
@end

// iPad登录页面控制器
@interface WCAccountBackDeviceFirstViewController : UIViewController
@property (nonatomic, strong) UIButton *deviceModeButton;
@end

NS_ASSUME_NONNULL_END 