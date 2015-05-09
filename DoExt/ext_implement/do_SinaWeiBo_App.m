//
//  do_SinaWeiBo_App.m
//  DoExt_SM
//
//  Created by 刘吟 on 15/4/9.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_SinaWeiBo_App.h"
#import "WeiboSDK.h"
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"


@implementation do_SinaWeiBo_App
@synthesize ThridPartyID;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSString *sinaKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"do_SinaWeiBo.plist" :@"EASEMOB_APPKEY"];
//    [WeiboSDK enableDebugMode:YES];
//    [WeiboSDK registerApp:@"1226508063"];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}
@end
