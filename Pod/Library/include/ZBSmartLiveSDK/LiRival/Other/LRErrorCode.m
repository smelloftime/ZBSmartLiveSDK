//
//  ZBErrorCode.m
//  Pods
//
//  Created by lip on 16/7/24.
//
//

#import "LRErrorCode.h"

static NSString *LRURLErrorDomain = @"ZBURLErrorDomain";
static NSString *LRNormalErrorDomain = @"LRNormalErrorDomain";
static NSString *LiRivalErrorDomain = @"LiRivalErrorDomain";

@implementation LRErrorCode

+ (NSError *)errorCreateWithErrorCode:(LRErrorCodeStatus)errorCode {
    NSDictionary *errorDic = @{
                               @(1090): @[LRNormalErrorDomain, @"空的参数"],
                               @(3010): @[LiRivalErrorDomain, @"失去了和聊天服务器的链接"],
                               @(3020): @[LiRivalErrorDomain, @"发送消息时响应超时"],
                               @(10000): @[LRURLErrorDomain, @"失去网络链接"],
                               @(10401): @[LRURLErrorDomain, @"无法识别的服务器数据"],
                               @(10500): @[LRURLErrorDomain, @"未授权的用户发起非法请求"]
                               };
    NSArray *errorArray = errorDic[@(errorCode)];
    NSParameterAssert(errorArray);
    return [[NSError alloc] initWithDomain:errorArray[0] code:errorCode userInfo:@{@"NSLocalizedDescription": errorArray[1]}];
}

+ (NSError *)errorCreateWithCoustomDomain:(NSString *)domain errorCode:(NSInteger)errorCode description:(NSString *)description {
    return [[NSError alloc] initWithDomain:domain code:errorCode userInfo:@{@"NSLocalizedDescription": description}];
}

@end
