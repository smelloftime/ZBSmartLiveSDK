//
//  ZBSmartLiveSDK.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBSmartLiveSDK.h"
#import "ZBAppConfigManager.h"
#import "ZBApplicationCenter.h"
#import "LiRivalKit.h"
#import "ZBErrorCode.h"

@interface ZBSmartLiveSDK ()
/** 聊天核心 */
@property (weak, nonatomic) LiRivalKit *liRivalKit;

@end

@implementation ZBSmartLiveSDK
#pragma mark - class means
+ (instancetype)shareSDK {
    static dispatch_once_t once;
    static ZBSmartLiveSDK *sdk;
    dispatch_once(&once, ^{
        sdk = [[self alloc] init];
        sdk.liRivalKit = [LiRivalKit coreKit];
    });
    return sdk;
}

#pragma mark └ instance means
- (void)configRootServerAddress:(NSString *)rootServerAddress {
    NSParameterAssert(rootServerAddress);
    [[ZBApplicationCenter defaultCenter] saveRootServerAddress:rootServerAddress];
}

- (void)configBusinessServerAddress:(NSString *)businessServerAddress {
    NSParameterAssert(businessServerAddress);
    [[ZBApplicationCenter defaultCenter] saveBusinessRootServerAddress:businessServerAddress];
}

- (void)registerWithApiVersion:(NSString *)apiVersion completion:(void (^)(NSError *))completion {
    /** 更新的逻辑说明
     如果修改了API 版本号,或者无API 版本号就直接更新所有的配置相关信息
     如果未修改API 版本号,就调用应用初始化接口,判断是否还需要局部更新
     */
    NSString *rootURL = [ZBApplicationCenter defaultCenter].rootURL;
    if (rootURL == nil || [rootURL length] <= 0) {
        if (completion) {
            completion([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    if (apiVersion == nil || [apiVersion length] <= 0) {
         if (completion) {
             completion([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
         }
         return;
     }
    if ([apiVersion isEqualToString:[ZBApplicationCenter defaultCenter].apiVersion] == NO) {
        [ZBApplicationCenter defaultCenter].apiVersion = apiVersion;
        [ZBAppConfigManager initializeCompletion:completion];
    } else {
        [ZBAppConfigManager initializeApplicationCompletion:completion];
    }
}

- (void)loginWithZBTicket:(NSString *)ticket completion:(void (^)(NSError *))error {
    /** 通过 Ticket 登陆的逻辑
     1. 通过票据兑换智播云用户授权信息,并且持久化,如果票据一致,就直接使用持久化的用户授权信息
     2. 通过票据兑换商务服务器用户授权信息,并且持久化,如果票据一直,就直接使用持久化的商务服务器授权信息
     3. 获取用户授权信息后,登陆聊天服务器
     4. 所有异常信息都会抛出,如果不能抛出正常,就不能视为正常登陆SDK
     */
    [ZBAppConfigManager getUserAuthenticityWithZBTicket:ticket completion:^(NSError *fail) {
        if (fail == nil) {
            [self loginLiRivalkitCompletion:^(NSError *fail) {
                error(fail);
            }];
        } else {
            error(fail);
        }
    }];
}

#pragma mark - LiRivalKit
- (void)loginLiRivalkitCompletion:(void(^)(NSError *fail))completion {
    ZBApplicationCenter *center = [ZBApplicationCenter defaultCenter];
    ZBWebSocketServerModel *serverModel = [ZBApplicationCenter defaultCenter].configInfoModel.webSocketServerList[0];
    NSParameterAssert(center.userAuthenticityModel.instantMessagingPassword);
    NSParameterAssert(serverModel.extranet);
    NSParameterAssert(center.userAuthenticityModel.instantMessagingPassword);
    [self.liRivalKit initializeWithAddress:serverModel.extranet token:center.userAuthenticityModel.instantMessagingPassword success:^(NSString *successInfo) {
        completion(nil);
    } fail:^(NSError *error) {
        completion(error);
    }];
}

@end
