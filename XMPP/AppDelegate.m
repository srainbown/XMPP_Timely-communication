//
//  AppDelegate.m
//  XMPP
//
//  Created by mac on 20/12/2018.
//  Copyright © 2018 Woodsoo. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "ZCXLoginViewController.h"
#import "HomePageViewController.h"
#import "ZCXXMPPManager.h"

@interface AppDelegate ()

@property (nonatomic, strong) ZCXXMPPManager *manager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    HomePageViewController *homeVc = [[HomePageViewController alloc]init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults valueForKey:NSUserDefaultsUserNameAndPassword];
    if (dict.count > 0) {
        NSString *userName = dict[@"userName"];
        NSString *password = dict[@"password"];
        if ([userName length] > 0 && [password length] > 0) {
            UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:homeVc];
            self.window.rootViewController = navi;
            self.manager = [ZCXXMPPManager sharedInstance];
            [self.manager loginWithUserName:userName withPassword:password];
            WS(weakSelf);
            self.manager.loginResultBlock = ^(NSString * str) {
                if([str isEqualToString:@"登录成功"]){
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"登录失败，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        ZCXLoginViewController *logVc = [[ZCXLoginViewController alloc]init];
                        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:logVc];
                        weakSelf.window.rootViewController = navi;
                    }];
                    [alert addAction:cancle];
                    
                    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    alertWindow.rootViewController = [[UIViewController alloc] init];
                    alertWindow.windowLevel = UIWindowLevelAlert + 1;
                    [alertWindow makeKeyAndVisible];
                    [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                }
            };
        }
    }else{
        ZCXLoginViewController *logVc = [[ZCXLoginViewController alloc]init];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:logVc];
        self.window.rootViewController = navi;
    }
    
    [self.window makeKeyAndVisible];

    [self setIQKeyboardManager];
    
    return YES;
}



-(void)setIQKeyboardManager{
    
    IQKeyboardManager *iQKeyboardManager = [IQKeyboardManager sharedManager];
    iQKeyboardManager.enable = YES;//控制整个功能是否启用
    iQKeyboardManager.shouldResignOnTouchOutside = YES;//控制点击背景是否收起键盘
    iQKeyboardManager.shouldToolbarUsesTextFieldTintColor = NO;//控制键盘上的工具条文字颜色是否用户自定义
    iQKeyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews;//有多个输入框时，可以通过点击Toolbar来实现移动到不同的输入框
    iQKeyboardManager.enableAutoToolbar = NO;//控制是否显示键盘上的工具条
    iQKeyboardManager.shouldShowToolbarPlaceholder = NO;//是否显示占位文字
    iQKeyboardManager.placeholderFont = [UIFont systemFontOfSize:17];
    iQKeyboardManager.placeholderColor = [UIColor orangeColor];
    iQKeyboardManager.keyboardDistanceFromTextField = 5.0f; //输入框距离键盘的距离
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
