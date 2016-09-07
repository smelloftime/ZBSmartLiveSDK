//
//  ZBErrorCode.h
//  Pods
//
//  Created by lip on 16/7/24.
//
//

#import <Foundation/Foundation.h>

typedef enum LRErrorCodeStatus : NSInteger {
    // 1000 - 1999 常规错误
    LRErrorCodeStatusEmptyParameter = 1090,    ///< 空的参数
    // 2000 - 2999 聊天相关错误
    // 3000 - 3999 三方框架相关错误
    LRErrorCodeStatusLostWebSocket = 3010,  ///< 失去了和服务器的链接
    LRErrorCodeStatusSendIMTimeout = 3020,    ///< 发送消息响应超时
    // 4000 - 4999 应用相关错误
    /// 10000 - 19999 服务器相关错误
    LRErrorCodeStatusLostNetWork = 10000,   ///<  失去网络链接
    LRErrorCodeStatusUndistinguishJson = 10401,  ///< 无法识别的数据
    LRErrorCodeStatusBreakIn = 10500,   ///< 非法请求
} LRErrorCodeStatus;

@interface LRErrorCode : NSObject

+ (NSError *)errorCreateWithErrorCode:(LRErrorCodeStatus)errorCode;

+ (NSError *)errorCreateWithCoustomDomain:(NSString *)domain errorCode:(NSInteger)errorCode description:(NSString *)description;

@end
