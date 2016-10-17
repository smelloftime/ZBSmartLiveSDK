//
//  ZBApplicationGlobal.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//  应用中心,处理和应用相关的数据(持久化),单例

#import <Foundation/Foundation.h>
#import "ZBConfigInfoModel.h"
#import "ZBUserAuthenticityModel.h"

@interface ZBApplicationCenter : NSObject
/** 应用 ID */
@property (copy, nonatomic) NSString *appID;
/** 应用口令 */
@property (copy, nonatomic) NSString *appToken;
/** 直播云根地址 */
@property (copy, nonatomic, readonly) NSString *rootURL;
/**
 *  @brief 应用基础地址
 *
 *  @see set 方法会更新该数值和持久化
 */
@property (copy, nonatomic) NSString *baseURL;
/**
 *  @brief 配置的版本号
 *
 *  @see set 方法会更新该数值和持久化
 */
@property (copy, nonatomic) NSString *configVersion;
/**
 *  @brief api的版本号，该版本号是接口的版本号，用于获取 baseURL
 *
 *  @see set 方法会更新该数值和持久化
 */
@property (strong, nonatomic) NSString *apiVersion;
/**
 *  @brief 智播云票据 兑换授权信息时使用
 *
 *  @see set 方法会更新该数值和持久化
 */
@property (copy, nonatomic) NSString *ticket;
/** 配置信息 
 *
 *  更新该数据需要调用
 *  @see saveConfigData
 */
@property (strong, nonatomic, readonly) ZBConfigInfoModel *configInfoModel;
/** 用户授权数据
 *
 *  调用该方面可以更新用户授权信息
 *  @see updataAuthenticityData
 */
@property (strong, nonatomic, readonly) ZBUserAuthenticityModel *userAuthenticityModel;
/** 敏感词数据 */
@property (strong, nonatomic,readonly) NSArray *filterArray;
/** 是否安装了分享平台  未完成 */
@property (assign, nonatomic) BOOL isInstallShare;
/** 聊天室的唯一标识 */
@property (strong, nonatomic) NSNumber *chatroomIdentity;

/** 
 *  主播聊天室 cid
 *  登录用户在发起创建直播请求时，服务器才会给登录用户创建聊天室，聊天室创建成功后会返回 cid，此后该聊天室会一直存在，且 cid 不会改变
 */
@property (strong, nonatomic) NSNumber *imCid;

+ (instancetype)defaultCenter;

/**
 *  存储服务器根地址
 *
 *  @param rootServerAddress 服务其提供的根地址
 */
- (void)saveRootServerAddress:(NSString *)rootServerAddress;

/**
 *  配置信息持久化,调用该方法会更新 _configInfoModel
 *
 *  @param configData 服务器返回的 json 格式配置化信息
 */
- (void)saveConfigData:(NSData *)configData;

/**
 *  更新授权信息
 *
 *  @param authenticity 服务器返回的 json 格式的授权信息
 */
- (void)updataAuthenticityData:(NSData *)authenticity;

/**
 *  更新并且持久化敏感词库
 */
- (void)updateFilterWord:(NSArray *)filterArray;

@end
