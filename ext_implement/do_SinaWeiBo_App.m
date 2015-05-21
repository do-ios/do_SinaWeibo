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
#import "doScriptEngineHelper.h"
static do_SinaWeiBo_App * instance;
@interface do_SinaWeiBo_App()

@end
@implementation do_SinaWeiBo_App
@synthesize OpenURLScheme;

+ (instancetype)Instance
{
    if (instance == nil) {
        instance = [[do_SinaWeiBo_App alloc]init];
    }
    return instance;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url fromThridParty:(NSString *)_id
{
    return [WeiboSDK handleOpenURL:url delegate:(id<WeiboSDKDelegate>)[doScriptEngineHelper ParseSingletonModule:nil :@"do_SinaWeiBo" ]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation fromThridParty:(NSString *)_id
{   
    return [WeiboSDK handleOpenURL:url delegate:(id<WeiboSDKDelegate>)[doScriptEngineHelper ParseSingletonModule:nil :@"do_SinaWeiBo" ]];
}
@end
