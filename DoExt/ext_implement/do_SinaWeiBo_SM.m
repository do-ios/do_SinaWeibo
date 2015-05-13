//
//  do_SinaWeiBo_SM.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define httpMethodType @"GET"
#define baseUrl @"https://api.weibo.com/2/users/show.json"

#import "do_SinaWeiBo_SM.h"
#import "do_SinaWeiBo_App.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonHelper.h"
#import "WeiboSDK.h"
#import "WeiboUser.h"

@interface do_SinaWeiBo_SM() <WBHttpRequestDelegate,WeiboSDKDelegate>
@property(nonatomic,strong) id<doIScriptEngine> scritEngine;
@property(nonatomic,copy) NSString *callbackName;
@property(nonatomic,copy) NSString *accesstoken;
@property(nonatomic,copy) NSString *refresh_token;
@property(nonatomic,copy) NSString *expires_in;
@property(nonatomic,copy) NSString *uid;
@end

@implementation do_SinaWeiBo_SM
#pragma mark -
#pragma mark - 同步异步方法的实现
/*
 1.参数节点
 doJsonNode *_dictParas = [parms objectAtIndex:0];
 a.在节点中，获取对应的参数
 NSString *title = [_dictParas GetOneText:@"title" :@"" ];
 说明：第一个参数为对象名，第二为默认值
 
 2.脚本运行时的引擎
 id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
 3.同步回调对象(有回调需要添加如下代码)
 doInvokeResult *_invokeResult = [parms objectAtIndex:2];
 回调信息
 如：（回调一个字符串信息）
 [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
 3.获取回调函数名(异步方法都有回调)
 NSString *_callbackName = [parms objectAtIndex:2];
 在合适的地方进行下面的代码，完成回调
 新建一个回调对象
 doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
 填入对应的信息
 如：（回调一个字符串）
 [_invokeResult SetResultText: @"异步方法完成"];
 [_scritEngine Callback:_callbackName :_invokeResult];
 */
//同步
//异步
- (void)getUserInfo:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    self.scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    self.callbackName = [parms objectAtIndex:2];
    NSString *uid = [doJsonHelper GetOneText:_dictParas :@"uid" :@""];
    NSString *accesstoken = [doJsonHelper GetOneText:_dictParas :@"accessToken" :@""];
    [WBHttpRequest requestForUserProfile:uid withAccessToken:accesstoken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        WeiboUser *userResult = (WeiboUser *)result;
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setValue:userResult.userID forKey:@"userID"];
        [resultDict setValue:userResult.userClass forKey:@"userClass"];
        [resultDict setValue:userResult.screenName forKey:@"screenName"];
        [resultDict setValue:userResult.name forKey:@"name"];
        [resultDict setValue:userResult.province forKey:@"province"];
        [resultDict setValue:userResult.location forKey:@"location"];
        [resultDict setValue:userResult.userDescription forKey:@"userDescription"];
        NSString *resultStr = [doJsonHelper ExportToText:resultDict :YES];
        doInvokeResult *_result = [[doInvokeResult alloc]init:self.UniqueKey];
        [_result SetResultText:resultStr];
        [self.scritEngine Callback:self.callbackName :_result];
    }];

    
}
- (void)login:(NSArray *)parms
{
    self.scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    self.callbackName = [parms objectAtIndex:2];
    
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"doRootViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    dispatch_async(dispatch_get_main_queue(), ^{
        [WeiboSDK sendRequest:request];
    });
}

- (void)logout:(NSArray *)parms
{
    [WeiboSDK logOutWithToken:self.accesstoken delegate:self withTag:nil];
}

- (void)didReceiveResponse:(NSString *)responseResult
{
    doInvokeResult *_result = [[doInvokeResult alloc]init:self.UniqueKey];
    [_result SetResultText:responseResult];
    [self.scritEngine Callback:self.callbackName :_result];

}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
        [responseDict setValue:[(WBAuthorizeResponse *)response userID] forKey:@"uid"];
        [responseDict setValue:[(WBAuthorizeResponse *)response accessToken] forKey:@"access_token"];
        [responseDict setValue:[(WBAuthorizeResponse *)response refreshToken] forKey:@"refresh_token"];
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormat stringFromDate:[(WBAuthorizeResponse *)response expirationDate]];
        [responseDict setValue:dateString forKey:@"expires_in"];
        NSString *result_str = [doJsonHelper ExportToText:responseDict :YES];
        doInvokeResult *_result = [[doInvokeResult alloc]init:self.UniqueKey];
        [_result SetResultText:result_str];
        [self.scritEngine Callback:self.callbackName :_result];

    }

}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}
@end















