//
//  ZBCloudData.m
//  Pods
//
//  Created by lip on 16/7/23.
//
//

#import "ZBCloudData.h"
#import "ZBHttpRequestManager.h"
#import "ZBErrorCode.h"
#import "ZBApplicationCenter.h"
#import "ZBPrefix.h"
#import "ZBURLPath.h"
#import "ZBTools.h"
#import "MJExtension.h"

@implementation ZBCloudData

+ (void)getZBCloudDataWithApi:(NSString *)requestApi parameter:(NSDictionary *)parameter success:(void (^)(id))success fail:(void (^)(NSError *))fail {
    NSString *key = [ZBApplicationCenter defaultCenter].userAuthenticityModel.authenticAccessKey;
    if (key == nil) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    if ([requestApi length] <= 0 || requestApi == nil || parameter == nil) {
        if (fail) {
            NSError *error = [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter];
            fail(error);
        }
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"ak": key}];
    [dic addEntriesFromDictionary:parameter];
    [ZBHttpRequestManager sendHttpRequestWithAPI:requestApi arguments:dic header:nil successCallback:success failCallback:fail];
}

+ (void)uploadImage:(UIImage *)image parameter:(NSDictionary *)parameter success:(void (^)(id))success fail:(void (^)(NSError *))fail {
    NSString *key = [ZBApplicationCenter defaultCenter].userAuthenticityModel.authenticAccessKey;
    if (key == nil) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    if (image == nil) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
        }
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"ak": key}];
    if (parameter != nil) {
        [dic addEntriesFromDictionary:parameter];
    }
    
    [ZBHttpRequestManager uploadImageRequestWithAPI:[ZBURLPath pathFromUploadImage] arguments:dic imageName:@"file" imageData:[ZBTools imageData:image] header:nil sucessCallback:success failCallback:fail];
}

+ (void)sendGift:(NSString *)giftCode toUser:(NSString *)usid andGiftCount:(NSUInteger)count success:(void (^)(id))success fail:(void (^)(NSError *))fail {
    NSString *key = [ZBApplicationCenter defaultCenter].userAuthenticityModel.authenticAccessKey;
    if (key == nil) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    if (giftCode == nil || [giftCode length] <= 0 || usid == nil || [usid length] <= 0 || count == 0) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
        }
        return;
    }
    NSDictionary *dic = @{@"ak": key, @"usid": usid, @"gift_code": giftCode, @"count": @(count)};
    [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromSendGift] arguments:dic header:nil successCallback:success failCallback:fail];
}

+ (void)getGiftConfigInfoSuccess:(void (^)(id))success fail:(void (^)(NSError *))fail {
    [ZBTools transformDate:[NSDate date] intoLockedWord:^(NSString *hextime, NSString *lockedToken) {
        NSString * encodingString = [@"gift_list" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *nsdata = [encodingString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
        
        NSDictionary *dic = @{@"hextime": hextime, @"token": lockedToken, @"name": base64Encoded};
        [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromApplicationConfig] arguments:dic header:nil successCallback:success failCallback:fail];
    }];
}

+ (NSArray *)getFilterStringArray {
    return [ZBApplicationCenter defaultCenter].filterArray;
}

+ (NSString *)getFilterReplaceString {
    return [ZBApplicationCenter defaultCenter].configInfoModel.filterReplaceWord;
}

+ (NSArray *)getLiveFilterListConfig {
    return [ZBApplicationCenter defaultCenter].configInfoModel.liveFilterList;
}

+ (NSString *)getStreamNotice {
    NSArray *tempArray = [ZBApplicationCenter defaultCenter].configInfoModel.streamNoticeList;
    if (tempArray.count == 0) {
        return nil;
    } else {
        return tempArray[0][@"text"];
    }
}

+ (NSNumber *)getImCid {
    return [ZBApplicationCenter defaultCenter].imCid;
}

@end
