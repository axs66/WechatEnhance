#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../Headers/WCHeaders.h"

// 检查游戏辅助功能是否启用
static BOOL isGameCheatEnabled() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"GameCheat_Enabled"];
}

%hook CMessageMgr
- (void)AddEmoticonMsg:(NSString *)msg MsgWrap:(CMessageWrap *)msgWrap {
    // 只有当游戏辅助功能启用时才执行作弊逻辑
    if (isGameCheatEnabled() && [msgWrap m_uiMessageType] == 47 && ([msgWrap m_uiGameType] == 2|| [msgWrap m_uiGameType] == 1)) {
        NSString *title = [msgWrap m_uiGameType] == 1 ? @"请选择石头/剪刀/布" : @"请选择点数";
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请选择"
                                                                       message:title
                                                                preferredStyle:UIAlertControllerStyleActionSheet];

        NSArray *arr = @[@"剪刀",@"石头",@"布",@"1",@"2",@"3",@"4",@"5",@"6"];
        for (int i = [msgWrap m_uiGameType] == 1 ? 0 : 3; i<([msgWrap m_uiGameType] == 1 ? 3 : 9); i++) {
            UIAlertAction* action1 = [UIAlertAction actionWithTitle:arr[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [msgWrap setM_nsEmoticonMD5:[objc_getClass("GameController") getMD5ByGameContent:i+1]];
                [msgWrap setM_uiGameContent:i+1];
                %orig(msg, msgWrap);
            }];
            [alert addAction:action1];
        }
        UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        [alert addAction:action2];
        
        // 在iPad上需要设置弹出位置
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            UIWindowScene *windowScene = nil;
            for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                    windowScene = (UIWindowScene *)scene;
                    break;
                }
            }
            
            UIWindow *window = windowScene.windows.firstObject;
            alert.popoverPresentationController.sourceView = window;
            alert.popoverPresentationController.sourceRect = CGRectMake(window.frame.size.width / 2, window.frame.size.height / 2, 0, 0);
            alert.popoverPresentationController.permittedArrowDirections = 0;
        }
        
        // 使用当前最前端的视图控制器展示弹窗
        UIViewController *topController = nil;
        UIWindowScene *windowScene = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                windowScene = (UIWindowScene *)scene;
                break;
            }
        }
        
        if (windowScene) {
            UIWindow *window = windowScene.windows.firstObject;
            topController = window.rootViewController;
            while (topController.presentedViewController) {
                topController = topController.presentedViewController;
            }
            [topController presentViewController:alert animated:true completion:nil];
        }

        return;
    }

    %orig(msg, msgWrap);
}
%end 