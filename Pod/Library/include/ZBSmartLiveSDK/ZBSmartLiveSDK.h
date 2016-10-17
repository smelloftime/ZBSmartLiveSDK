//
//  ZBSmartLiveSDK.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//  SDK中心

#import <Foundation/Foundation.h>

@interface ZBSmartLiveSDK : NSObject

/**
 *  实例化方法
 *
 *  @return 整个 sdk 管理的中心
 */
+ (instancetype)shareSDK;

/**
 *  配置智播服务器根地址
 *
 *  @param rootServerAddress 聊天服务器根地址,该地址由服务器提供
 */
- (void)configRootServerAddress:(NSString *)rootServerAddress;

/**
 *  配置商务服务器根地址
 *
 *  @param businessServerAddress 商务服务器地址,该地址由商务服务器提供
 */
- (void)configBusinessServerAddress:(NSString *)businessServerAddress;

/**
 *  注册应用信息
 *
 *  @waring 该方法必须在应用启动后尽快调用
 *  @waring 如果没有获取到配置信息的话,整个应用将无法正常使用,所以建议在没有获取到配置信息时,进入死循环无法进入页面
 *
 * @param versionNumber 版本号
 * @param completion    获取结果的回调如果正常的话 error 就为 nil
 */
- (void)registerWithApiVersion:(NSString *)apiVersion completion:(void (^)(NSError *))completion;

/**
 *  通过智播云返回的 ticket 登录
 *
 *  每次使用 SDK 相关的功能前,都需要正常登录,否则会出现异常的情况
 *  ZBSDK 只提供直播和聊天通道,并不依赖用户业务逻辑,开发者需要为每个 APP 用户指定一个 ticket, ZBSDK 只负责验证 ticket 即可(在服务器端集成)
 *  用户 APP 账户体系和 ZBSDK 没有直接关系
 *  开发者需要根据自己的实际情况配置自身用户系统和 ZBSDK 的关系
 *
 *  @param ticket 智播云服务器返回的 ticket
 *  @param error  登录结果的回调,如果正常的话 error 就为 nil
 */
- (void)loginWithZBTicket:(NSString *)ticket completion:(void(^)(NSError *))error;

@end
