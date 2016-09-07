//
//  ZBAppConfigManager.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/12.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBAppConfigManager.h"
#import "ZBApplicationCenter.h"
#import "ZBHttpRequestManager.h"
#import "ZBInitializeRequestManager.h"


@implementation ZBAppConfigManager
#pragma mark - init Application
+ (void)initializeApplicationCompletion:(void (^)(NSError *))error {
    if ([ZBApplicationCenter defaultCenter].baseURL == nil) {
        [self initializeCompletion:error];
    } else {
        [self contrastServerConfigVersionCompletion:error];
    }
}

+ (void)contrastServerConfigVersionCompletion:(void (^)(NSError *))error {
    NSString *apiVersion = [ZBApplicationCenter defaultCenter].configVersion;
    if (apiVersion == nil) {
        [self initializeCompletion:error];
        return;
    } else {
        ZBConfigInfoModel *model = [ZBApplicationCenter defaultCenter].configInfoModel;
        if (model) {
            error(nil);
        } else {
            [self initializeCompletion:error];
            return;
        }
        [self saveConfigFile];
    }
}

#pragma mark - config
+ (void)saveConfigFile {
    [ZBInitializeRequestManager sendGetConfigVersionSuccess:^(NSString *configVersion) {
        NSString *newConfigVersion = configVersion;
        NSString *oldConfigVersion = [ZBApplicationCenter defaultCenter].configVersion;
        if ([newConfigVersion isEqualToString:oldConfigVersion] == NO || oldConfigVersion == nil) {
            [ZBInitializeRequestManager sendGetConfigRequestSuccess:^(id data) {
                [[ZBApplicationCenter defaultCenter] saveConfigData:data];
            } fail:^(NSError *err) {
                NSLog(@"%@", err);
            }];
        }
        [ZBApplicationCenter defaultCenter].configVersion = newConfigVersion;
    } fail:^(NSError *err) {
        NSLog(@"%@", [err localizedDescription]);
    }];
}

#pragma mark - user authenticity
+ (void)getUserAuthenticityWithZBTicket:(NSString *)ticket completion:(void (^)(NSError *))error {
    ZBApplicationCenter *center = [ZBApplicationCenter defaultCenter];
    if ([center.ticket isEqualToString:ticket] == NO || center.userAuthenticityModel == nil) {
        [ZBInitializeRequestManager sendGetAndUpdataUserAuthenticityRequestWithTicket:ticket success:^(id data) {
            center.ticket = ticket;
            [center updataAuthenticityData:data];
            error(nil);
        } fail:^(NSError *fail) {
            error(fail);
        }];
    } else if ([center.ticket isEqualToString:ticket] == YES) {
        error(nil);
    }
}

#pragma mark - initialize'stream
+ (void)initializeCompletion:(void (^)(NSError *))error {
    [ZBHttpRequestManager sendGetBaseURLRequestWithAPPID:[ZBApplicationCenter defaultCenter].appID appToken:[ZBApplicationCenter defaultCenter].appToken successCallback:^(NSString *baseURL) {
        [ZBApplicationCenter defaultCenter].baseURL = baseURL;
        
        [ZBInitializeRequestManager sendGetConfigRequestSuccess:^(id data) {
            [[ZBApplicationCenter defaultCenter] saveConfigData:data];
            [ZBApplicationCenter defaultCenter].configVersion = data[@"api_config_version"];
            error(nil);
        } fail:^(NSError *fail) {
            error(fail);
        }];
    } failCallback:^(NSError *fail) {
        error(fail);
    }];
}

@end
