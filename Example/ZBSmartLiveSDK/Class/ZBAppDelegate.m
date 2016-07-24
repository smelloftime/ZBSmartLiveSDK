//
//  ZBAppDelegate.m
//  ZBSmartLiveSDK
//
//  Created by LipYoung on 07/19/2016.
//  Copyright (c) 2016 LipYoung. All rights reserved.
//

#import "ZBAppDelegate.h"
#import "ZBRootTableViewController.h"
#import <ZBSmartLiveSDK/ZBSmartLiveSDK.h>

@implementation ZBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[ZBSmartLiveSDK shareSDK] registerWithAppID:@"zb602251775577514102" appToken:@"ynPtm355S27HwnElEWshpX"];
#warning Note 初始化必须成功 才能正常使用 ZBSmartLiveSDK 相关的所有功能,以免出现其余异常 bug 建议:如果此处显示初始化失败的信息后,重新调用初始化方法
    [[ZBSmartLiveSDK shareSDK] initializeConfigCompletion:^(NSError *error) {
        if (error == nil) {
            NSLog(@"初始化成功");
        } else {
            NSLog(@"初始化失败的错误信息 %@", [error localizedDescription]);
        }
    }];
    
    self.window = [[UIWindow alloc] init];
    ZBRootTableViewController *tableVC = [[ZBRootTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
