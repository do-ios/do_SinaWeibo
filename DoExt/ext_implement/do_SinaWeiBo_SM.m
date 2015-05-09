//
//  do_SinaWeiBo_SM.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#define kRedirectURI    @"http://www.baidu.com"
#define httpMethodType @"GET"
#define baseUrl @"https://api.weibo.com/2/users/show.json"

#import "do_SinaWeiBo_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonNode.h"
#import "WeiboSDK.h"




@interface do_SinaWeiBo_SM() <WeiboSDKDelegate,WBHttpRequestDelegate>
@property(nonatomic,strong) id<doIScriptEngine> scritEngine;
@property(nonatomic,copy) NSString *callbackName;
@property(nonatomic,copy) NSString *accesstoken;
@property(nonatomic,strong) WBAuthorizeRequest *request;
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
    doJsonNode *_dictParas = [parms objectAtIndex:0];
    self.scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    self.callbackName = [parms objectAtIndex:2];
    NSString *uid = [_dictParas GetOneText:@"uid" :@""];
    self.accesstoken = [_dictParas GetOneText:@"accessToken" :@""];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:uid forKey:@"uid"];
    [paramDict setValue:self.accesstoken forKey:@"accessToken"];
    [WBHttpRequest requestWithAccessToken:self.accesstoken url:baseUrl httpMethod:httpMethodType params:paramDict delegate:self withTag:nil];
    
}
- (void)login:(NSArray *)parms
{
//    doJsonNode *_dictParas = [parms objectAtIndex:0];
    self.scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    self.callbackName = [parms objectAtIndex:2];
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    self.request = request;
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:self.request];
}

- (void)logout:(NSArray *)parms
{
//    doJsonNode *_dictParas = [parms objectAtIndex:0];
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
//    //自己的代码实现
//    
//    NSString *_callbackName = [parms objectAtIndex:2];
//    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    [WeiboSDK logOutWithToken:self.accesstoken delegate:self withTag:nil];
}

#pragma -mark -
#pragma -mark WeiboSDKDelegate

-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        NSString *result_str = [NSString stringWithFormat:@"{uid:%@,access_token:%@,refresh_token:%@,expires_in:%@}",[(WBAuthorizeResponse *)response userID],[(WBAuthorizeResponse *)response accessToken],[(WBAuthorizeResponse *)response refreshToken],[(WBAuthorizeResponse *)response expirationDate]];
        doInvokeResult *_result = [[doInvokeResult alloc]init];
        [_result SetResultText:result_str];
        [self.scritEngine Callback:self.callbackName :_result];
    }
}

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

#pragma -mark -
#pragma -mark WBHttpRequestDelegate

-(void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    doInvokeResult *_result = [[doInvokeResult alloc]init];
    NSLog(@"网络返回用户信息结果：%@",result);
    [_result SetResultText:result];
    [self.scritEngine Callback:self.callbackName :_result];
}

@end















