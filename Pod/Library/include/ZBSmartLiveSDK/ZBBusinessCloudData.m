//
//  ZBBusinessCloudData.m
//  Pods
//
//  Created by lip on 16/10/17.
//
//

#import "ZBBusinessCloudData.h"
#import "ZBErrorCode.h"
#import "ZBURLPath.h"
#import "ZBApplicationCenter.h"
#import "ZBHttpRequestManager.h"

@implementation ZBBusinessCloudData

+ (void)zb_GetBusinessCloudDataFansFollowListRequestWithType:(ZBFollowActionType)type uname:(NSString *)uname businessUserID:(NSString *)businessUserID pageNumber:(NSUInteger)pageNumber success:(void (^)(id))success fail:(void (^)(NSError *))fail {
    if (businessUserID == nil || [businessUserID  length] <= 0 || pageNumber == 0) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
        }
        return;
    }
    NSDictionary *businessAuthInfo = [ZBApplicationCenter defaultCenter].businessAuthInfo;
    if (businessAuthInfo == nil) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    NSArray *typeArr = @[@"fans", @"follow"];
    if (uname == nil || [uname length] <= 0) {
        uname = nil;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"type":typeArr[type], @"usid":businessUserID, @"p":@(pageNumber)}];
    [parameters addEntriesFromDictionary:businessAuthInfo];
    if (uname) {
        [parameters setObject:uname forKey:@"uname"];
    }
    [ZBHttpRequestManager sendBusinessHttpRequestWithAPI:[ZBURLPath pathFromBusinessFollowList] arguments:parameters header:nil successCallback:success failCallback:fail];
}

+ (void)zb_sendFollowRequestWithAction:(ZBFollowType)followAction businessUserID:(NSString *)businessUserID success:(void (^)(id))success fail:(void (^)(NSError *))fail{
    if (businessUserID == nil || [businessUserID  length] <= 0) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
        }
        return;
    }
    NSDictionary *businessAuthInfo = [ZBApplicationCenter defaultCenter].businessAuthInfo;
    if (businessAuthInfo == nil) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"usid":businessUserID, @"action":@(followAction)}];
    [parameters addEntriesFromDictionary:businessAuthInfo];
    [ZBHttpRequestManager sendBusinessHttpRequestWithAPI:[ZBURLPath pathFromBusinessFollowAction] arguments:parameters header:nil successCallback:success failCallback:fail];
}

+ (void)zb_GetUserInfoWithBusinessUserIDArray:(NSString *)businessUserIDArray success:(void (^)(id))success fail:(void (^)(NSError *))fail {
    if (businessUserIDArray == nil || [businessUserIDArray  length] <= 0) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
        }
        return;
    }
    NSDictionary *businessAuthInfo = [ZBApplicationCenter defaultCenter].businessAuthInfo;
    if (businessAuthInfo == nil) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"usid":businessUserIDArray}];
    [parameters addEntriesFromDictionary:businessAuthInfo];
    [ZBHttpRequestManager sendBusinessHttpRequestWithAPI:[ZBURLPath pathFromBusinessUserInfo] arguments:parameters header:nil successCallback:success failCallback:fail];
}

@end
