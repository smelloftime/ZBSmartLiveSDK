//
//  ZBErrorCode.h
//  Pods
//
//  Created by lip on 16/7/24.
//
//

#import <Foundation/Foundation.h>

typedef enum ZBErrorCodeStatus : NSInteger {
    // 1000 - 1999 常规错误
    ZBErrorCodeStatusEmptyParameter = 1090,    ///< 空的参数
    // 2000 - 2999 聊天相关错误
    // 3000 - 3999 三方框架相关错误
    ZBErrorCodeStatusLostWebSocket = 3010,  ///< 失去了和服务器的链接
    ZBErrorCodeStatusSendIMTimeout = 3020,    ///< 发送消息响应超时
    // 4000 - 4999 应用相关错误
    ZBErrorCodeStatusUnInitialize = 4080,   ///< ZBSDK 未能成功初始化
    /// 10000 - 19999 服务器相关错误
    ZBErrorCodeStatusLostNetWork = 10000,   ///<  失去网络链接
    ZBErrorCodeStatusUndistinguishJson = 10401,  ///< 无法识别的数据
    ZBErrorCodeStatusBreakIn = 10500,   ///< 非法请求
} ZBErrorCodeStatus;

@interface ZBErrorCode : NSObject

+ (NSError *)errorCreateWithErrorCode:(ZBErrorCodeStatus)errorCode;

+ (NSError *)errorCreateWithCoustomDomain:(NSString *)domain errorCode:(NSInteger)errorCode description:(NSString *)description;

@end
