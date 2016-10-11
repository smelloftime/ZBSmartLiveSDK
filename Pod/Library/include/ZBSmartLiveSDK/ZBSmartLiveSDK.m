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
- (void)registerWithAppID:(NSString *)appID appToken:(NSString *)appToken completion:(void (^)(NSError *))completion {
    ZBApplicationCenter *center = [ZBApplicationCenter defaultCenter];
    if ([appID isEqualToString:center.appID] && [appToken isEqualToString:center.appToken]) {
        [ZBAppConfigManager initializeApplicationCompletion:completion];
    } else { // 直接获取全部的配置信息等
        [ZBApplicationCenter defaultCenter].appID = appID;
        [ZBApplicationCenter defaultCenter].appToken = appToken;
        [ZBAppConfigManager initializeCompletion:completion];
    }
}

- (void)loginWithZBTicket:(NSString *)ticket completion:(void (^)(NSError *))error {
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
