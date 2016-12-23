//
//  ZBErrorCode.m
//  Pods
//
//  Created by lip on 16/7/24.
//
//

#import "ZBErrorCode.h"

static NSString *ZBURLErrorDomain = @"ZBURLErrorDomain";
static NSString *ZBNormalErrorDomain = @"ZBNormalErrorDomain";
static NSString *ZBWebSockertErrorDomain = @"ZBWebSockertErrorDomain";

@implementation ZBErrorCode

+ (NSError *)errorCreateWithErrorCode:(ZBErrorCodeStatus)errorCode {
    NSDictionary *errorDic = @{
                               @(1080): @[ZBNormalErrorDomain, @"未能正常初始化"],
                               @(ZBErrorCodeStatusEmptyParameter): @[ZBNormalErrorDomain, @"空的参数"],
                               @(ZBErrorCodeStatusLostWebSocket): @[ZBWebSockertErrorDomain, @"失去了和聊天服务器的链接"],
                               @(ZBErrorCodeStatusSendIMTimeout): @[ZBWebSockertErrorDomain, @"发送消息时响应超时"],
                               @(ZBErrorCodeStatusUnInitialize): @[ZBNormalErrorDomain, @"ZBSDK 未能成功初始化"],
                               @(ZBErrorCodeStatusLostNetWork): @[ZBURLErrorDomain, @"失去网络链接"],
                               @(ZBErrorCodeStatusUndistinguishJson): @[ZBURLErrorDomain, @"无法识别的服务器数据"],
                               @(ZBErrorCodeStatusBreakIn): @[ZBURLErrorDomain, @"未授权的用户发起非法请求"]
                               };
    NSArray *errorArray = errorDic[@(errorCode)];
    NSParameterAssert(errorArray);
    return [[NSError alloc] initWithDomain:errorArray[0] code:errorCode userInfo:@{@"NSLocalizedDescription": errorArray[1]}];
}

+ (NSError *)errorCreateWithCoustomDomain:(NSString *)domain errorCode:(NSInteger)errorCode description:(NSString *)description {
    return [[NSError alloc] initWithDomain:domain code:errorCode userInfo:@{@"NSLocalizedDescription": description}];
}

@end
