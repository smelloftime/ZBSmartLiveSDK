//
//  ZBSmartLiveSDK.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBSmartLiveSDK : NSObject

/**
 *  实例化方法
 *
 *  @return 整个 sdk 管理的中心
 */
+ (instancetype)shareSDK;

/**
 *  注册应用信息
 *
 *  @waring 该方法必须在应用启动后尽快调用
 *  @param appID    智播云后台分配的 appID
 *  @param appToken 智播云后台分配的 appToken
 */
- (void)registerWithAppID:(NSString *)appID appToken:(NSString *)appToken;

/**
 *  获取服务器的配置信息
 *
 *  @waring 如果没有获取到配置信息的话,整个应用将无法正常使用,所以建议在没有获取到配置信息时,进入死循环无法进入页面
 *  @param error 获取结果的回调如果正常的话 error 就为 nil,
 */
- (void)initializeConfigCompletion:(void(^)(NSError *))error;

/**
 *  通过智播云返回的 ticket 登录
 *
 *  每次使用 SDK 相关的功能前,都需要正常登录,否则会出现异常的情况
 *
 *  @param ticket 智播云服务器返回的 ticket
 *  @param error  登录结果的回调,如果正常的话 error 就为 nil
 */
- (void)loginWithZBTicket:(NSString *)ticket completion:(void(^)(NSError *))error;

@end
