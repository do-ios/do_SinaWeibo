//
//  do_SinaWeiBo_SM.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"

#import "do_SinaWeiBo_SM.h"
#import "do_SinaWeiBo_App.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonHelper.h"
#import "WeiboSDK.h"
#import "WeiboUser.h"
#import "doIOHelper.h"
#import "doIPage.h"

typedef NS_ENUM(NSInteger, MessageType)
{
    ImageTextMessage,
    HtmlMessage,
    MusicMessage,
    MediaMessage,
    AudioMessage
};

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
        doInvokeResult *_result = [[doInvokeResult alloc]init:self.UniqueKey];
        NSString *resultStr ;
        if(error == nil)
        {
            WeiboUser *userResult = (WeiboUser *)result;
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
            [resultDict setValue:userResult.userID forKey:@"userID"];
            [resultDict setValue:userResult.userClass forKey:@"userClass"];
            [resultDict setValue:userResult.screenName forKey:@"screenName"];
            [resultDict setValue:userResult.name forKey:@"name"];
            [resultDict setValue:userResult.province forKey:@"province"];
            [resultDict setValue:userResult.location forKey:@"location"];
            [resultDict setValue:userResult.userDescription forKey:@"userDescription"];
            resultStr = [doJsonHelper ExportToText:resultDict :YES];

        }
        else
        {
            [_result SetResultText:error.description];
        }
        [_result SetResultText:resultStr];
        [self.scritEngine Callback:self.callbackName :_result];
    }];
    
    
}
- (void)login:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    NSString *sinaKey = [doJsonHelper GetOneText:_dictParas :@"appId" :@""];
    do_SinaWeiBo_App *sinaApp = [do_SinaWeiBo_App Instance];
    sinaApp.OpenURLScheme = [NSString stringWithFormat:@"wb%@",sinaKey];
    [WeiboSDK registerApp:sinaKey];
    self.scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    self.callbackName = [parms objectAtIndex:2];
    
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    request.userInfo = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [WeiboSDK sendRequest:request];
    });
}

- (void)logout:(NSArray *)parms
{
    [WeiboSDK logOutWithToken:self.accesstoken delegate:self withTag:nil];
    self.accesstoken = nil;
}

- (void)share:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    self.scritEngine = [parms objectAtIndex:1];
    self.callbackName = [parms objectAtIndex:2];
    NSString *sinaKey = [doJsonHelper GetOneText:_dictParas :@"appId" :@""];
    [WeiboSDK registerApp:sinaKey];

    int type = [doJsonHelper GetOneInteger:_dictParas :@"type" :-1];
    NSString *title = [doJsonHelper GetOneText:_dictParas :@"title" :@""];
    
    NSString *image = [doJsonHelper GetOneText:_dictParas :@"image" :@""];
    NSString *url = [doJsonHelper GetOneText:_dictParas :@"url" :@""];
    NSString *summary = [doJsonHelper GetOneText:_dictParas :@"summary" :@""];

    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"all";
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare:type withTitle:title withImage:image withURL:url withSummary:summary] authInfo:authRequest access_token:self.accesstoken];
    request.userInfo = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [WeiboSDK sendRequest:request];
    });
}
- (WBMessageObject *)messageToShare:(int)type withTitle:(NSString *)title withImage:(NSString *)imageUrl withURL:(NSString *)url withSummary:(NSString *)summary
{
    WBMessageObject *messageObject = [WBMessageObject message];
    NSString * imagePath;
    NSData *thumbnailData;
    if (imageUrl != nil && imageUrl.length > 0) {
        imagePath = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :imageUrl];
        if (imagePath != nil) {
            thumbnailData = [NSData dataWithContentsOfFile:imagePath];
        }
    }
    switch (type) {
        case ImageTextMessage:
        {
            WBImageObject *image = [WBImageObject object];
            //设置图片
            NSString * imagePath = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :imageUrl];
            image.imageData = [NSData dataWithContentsOfFile:imagePath];
            messageObject.imageObject = image;
            messageObject.text = summary;
        }
            break;
        case HtmlMessage:
        {
            WBWebpageObject *wbWeb = [WBWebpageObject object];
            wbWeb.objectID = @"identifierHtml";
            wbWeb.description = summary;
            wbWeb.title = title;
            wbWeb.webpageUrl = url;
            wbWeb.thumbnailData = thumbnailData;
            messageObject.mediaObject = wbWeb;
        }
            break;
        case AudioMessage:
        case MusicMessage:
        {
            WBMusicObject *wbMusic = [WBMusicObject object];
            wbMusic.objectID = @"identifierMusic";
            wbMusic.title = title;
            wbMusic.musicUrl = url;
            wbMusic.thumbnailData = thumbnailData;
            wbMusic.description = summary;
            messageObject.mediaObject = wbMusic;
        }
            break;
        case MediaMessage:
        {
            WBVideoObject *wbVideo = [WBVideoObject object];
            wbVideo.objectID = @"identifierMedia";
            wbVideo.title = title;
            wbVideo.videoUrl = url;
            wbVideo.description = summary;
            wbVideo.thumbnailData = thumbnailData;
            messageObject.mediaObject = wbVideo;
        }
            break;
        default:
            break;
    }
    return messageObject;
}


#pragma -mark -
#pragma -mark WeiboSDKDelegate协议方法

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        self.accesstoken = [(WBAuthorizeResponse *)response accessToken] ;
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
    else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
    {
        doInvokeResult *_result;
        if ([(WBSendMessageToWeiboResponse *)response statusCode] == WeiboSDKResponseStatusCodeSuccess) {
            _result = [[doInvokeResult alloc]init:self.UniqueKey];
            [_result SetResultBoolean:YES];
        }
        else
        {
            _result = [[doInvokeResult alloc]init:self.UniqueKey];
            [_result SetResultBoolean:NO];
            
        }
        [self.scritEngine Callback:self.callbackName :_result];
    }
    
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}
@end















