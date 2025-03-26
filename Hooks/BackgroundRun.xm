// 后台运行hook
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "../Headers/CSUserInfoHelper.h"
#import "../Controllers/CSBackgroundRunViewController.h"

// 全局变量
static UIBackgroundTaskIdentifier bgTaskIdentifier;
static NSTimer *bgTaskTimer;
static AVAudioPlayer *silentAudioPlayer;
static BOOL isInBackground = NO;  // 添加应用状态跟踪
static NSInteger timerFireCount = 0;  // 记录定时器触发次数
static NSTimeInterval timerInterval = 10.0; // 默认10秒触发一次

// 检查后台运行功能是否启用
static BOOL isBackgroundRunEnabled() {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    return [defaults boolForKey:kBackgroundRunEnabledKey];
}

// 获取后台任务触发间隔
static NSTimeInterval getBackgroundInterval() {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSInteger interval = [defaults integerForKey:kBackgroundIntervalKey];
    
    // 验证范围，确保间隔在10-60秒内
    if (interval < 10) {
        interval = 10;
    } else if (interval > 60) {
        interval = 60;
    }
    
    return (NSTimeInterval)interval;
}

// 播放无声音频
static void playBlankAudio() {
    // 检查功能是否启用
    if (!isBackgroundRunEnabled()) {
        return;
    }
    
    // 如果已经有播放器在运行，不要创建新的
    if (silentAudioPlayer && silentAudioPlayer.isPlaying) {
        return;
    }
    
    NSError *setCategoryErr = nil;
    NSError *activationErr = nil;
    
    // 设置音频会话
    [[AVAudioSession sharedInstance]
     setCategory:AVAudioSessionCategoryPlayback
     withOptions:AVAudioSessionCategoryOptionMixWithOthers
     error:&setCategoryErr];
    
    // 激活音频会话
    [[AVAudioSession sharedInstance]
     setActive:YES
     error:&activationErr];
    
    // 使用微信应用中自带的blank.caf文件
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *silentSoundURL = [mainBundle URLForResource:@"blank" withExtension:@"caf"];
    
    if (silentSoundURL) {
        NSError *audioError = nil;
        silentAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:silentSoundURL error:&audioError];
        
        if (!audioError) {
            silentAudioPlayer.numberOfLoops = -1; // 无限循环
            [silentAudioPlayer play];
        }
    }
}

// 请求更多后台运行时间
static void requestMoreBackgroundTime() {
    // 检查功能是否启用
    if (!isBackgroundRunEnabled()) {
        return;
    }
    
    NSTimeInterval remainingTime = [UIApplication sharedApplication].backgroundTimeRemaining;
    
    if (remainingTime < 30) {
        // 播放无声音频以保持后台运行
        playBlankAudio();
        
        // 结束当前后台任务并开始新任务
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskIdentifier];
        bgTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTaskIdentifier];
            bgTaskIdentifier = UIBackgroundTaskInvalid;
        }];
    }
}

// 创建一个类用于回调定时器
@interface NSTimerCallbackClass : NSObject
+ (void)requestMoreBackgroundTimeCallback:(NSTimer *)timer;
@end

@implementation NSTimerCallbackClass
+ (void)requestMoreBackgroundTimeCallback:(NSTimer *)timer {
    // 增加触发计数
    timerFireCount++;
    requestMoreBackgroundTime();
}
@end

// 处理应用进入后台
static void handleEnterBackground() {
    // 检查功能是否启用
    if (!isBackgroundRunEnabled()) {
        return;
    }
    
    // 防止重复触发
    if (isInBackground) {
        return;
    }
    
    isInBackground = YES;
    timerFireCount = 0;  // 重置触发计数
    
    // 确保使用最新的间隔设置
    timerInterval = getBackgroundInterval();
    
    // 开始后台任务
    UIApplication *app = [UIApplication sharedApplication];
    bgTaskIdentifier = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTaskIdentifier];
        bgTaskIdentifier = UIBackgroundTaskInvalid;
    }];
    
    if (bgTaskIdentifier != UIBackgroundTaskInvalid) {
        // 确保旧定时器已停止
        if (bgTaskTimer) {
            [bgTaskTimer invalidate];
            bgTaskTimer = nil;
        }
        
        bgTaskTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval 
                                                    target:[NSTimerCallbackClass class]
                                                    selector:@selector(requestMoreBackgroundTimeCallback:) 
                                                    userInfo:nil 
                                                    repeats:YES];
        
        // 添加定时器到主运行循环
        [[NSRunLoop mainRunLoop] addTimer:bgTaskTimer forMode:NSRunLoopCommonModes];
        [bgTaskTimer fire];
        
        // 初始播放无声音频
        playBlankAudio();
    }
}

// 处理应用进入前台
static void handleEnterForeground() {
    // 防止重复触发
    if (!isInBackground) {
        return;
    }
    
    isInBackground = NO;
    
    // 停止定时器
    if (bgTaskTimer) {
        [bgTaskTimer invalidate];
        bgTaskTimer = nil;
    }
    
    // 停止音频播放
    if (silentAudioPlayer) {
        [silentAudioPlayer stop];
        silentAudioPlayer = nil;
    }
    
    // 结束后台任务
    if (bgTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskIdentifier];
        bgTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    // 初始化
    bgTaskIdentifier = UIBackgroundTaskInvalid;
}
%end

// Hook应用代理方法 - 尝试多种可能的生命周期方法
%hook AppDelegate
- (void)applicationDidEnterBackground:(UIApplication *)application {
    %orig;
    handleEnterBackground();
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    // 加载后台任务间隔设置
    timerInterval = getBackgroundInterval();
    
    // 监听后台运行设置变化通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BackgroundRunStatusChanged" 
                                                    object:nil 
                                                     queue:[NSOperationQueue mainQueue] 
                                                usingBlock:^(NSNotification *notification) {
        BOOL enabled = [notification.userInfo[@"enabled"] boolValue];
        
        // 根据新状态处理
        if (enabled && isInBackground) {
            // 如果启用了后台运行，且当前在后台，则开始后台保活
            handleEnterBackground();
        } else if (!enabled && isInBackground) {
            // 如果禁用了后台运行，且当前在后台，则停止后台保活
            if (silentAudioPlayer) {
                [silentAudioPlayer stop];
                silentAudioPlayer = nil;
            }
            
            if (bgTaskTimer) {
                [bgTaskTimer invalidate];
                bgTaskTimer = nil;
            }
        }
    }];
    
    // 监听后台任务间隔变更通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BackgroundIntervalChanged" 
                                                    object:nil 
                                                     queue:[NSOperationQueue mainQueue] 
                                                usingBlock:^(NSNotification *notification) {
        NSInteger newInterval = [notification.userInfo[@"interval"] integerValue];
        timerInterval = (NSTimeInterval)newInterval;
        
        // 如果当前在后台状态，且定时器正在运行，则更新定时器间隔
        if (isInBackground && bgTaskTimer) {
            [bgTaskTimer invalidate];
            bgTaskTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval 
                                                        target:[NSTimerCallbackClass class]
                                                        selector:@selector(requestMoreBackgroundTimeCallback:) 
                                                        userInfo:nil 
                                                        repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:bgTaskTimer forMode:NSRunLoopCommonModes];
            [bgTaskTimer fire];
        }
    }];
    
    return result;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    %orig;
    handleEnterForeground();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    %orig;
}
%end

// 添加UIApplicationDelegate的分类，以捕获可能的应用状态变化
%hook UIApplication

// 前台切换到后台
- (void)_applicationWillResignActive {
    %orig;
}

- (void)_applicationDidEnterBackground {
    %orig;
    // 延迟执行，确保系统已完成状态切换
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        handleEnterBackground();
    });
}

// 后台切换到前台
- (void)_applicationWillEnterForeground {
    %orig;
    // 延迟执行，确保系统已完成状态切换
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        handleEnterForeground();
    });
}

- (void)_applicationDidBecomeActive {
    %orig;
    // 另一种尝试，确保至少一个方法能触发前台处理
    if (isInBackground) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            handleEnterForeground();
        });
    }
}

%end

// 添加通知观察者，而不是Hook通知中心
%ctor {
    @autoreleasepool {
        // 初始化变量
        bgTaskIdentifier = UIBackgroundTaskInvalid;
        isInBackground = NO;
        timerFireCount = 0;
        
        // 注册通知观察者
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        // 观察应用退到后台的通知
        [center addObserverForName:UIApplicationDidEnterBackgroundNotification 
                            object:nil 
                             queue:[NSOperationQueue mainQueue] 
                        usingBlock:^(NSNotification *notification) {
            // 应用进入后台
        }];
        
        // 观察应用回到前台的通知
        [center addObserverForName:UIApplicationWillEnterForegroundNotification 
                            object:nil 
                             queue:[NSOperationQueue mainQueue] 
                        usingBlock:^(NSNotification *notification) {
            // 通过通知直接触发前台处理
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                handleEnterForeground();
            });
        }];
        
        // 增加活跃状态通知监听
        [center addObserverForName:UIApplicationDidBecomeActiveNotification
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *notification) {
            // 最后的保障，确保一定会执行前台处理
            if (isInBackground) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    handleEnterForeground();
                });
            }
        }];
    }
} 