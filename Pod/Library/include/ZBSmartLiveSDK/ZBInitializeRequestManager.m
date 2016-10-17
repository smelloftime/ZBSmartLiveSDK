//
//  ZBInitializeRequestManager.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/13.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBInitializeRequestManager.h"
#import "ZBURLPath.h"
#import "ZBTools.h"
#import "ZBHttpRequestManager.h"

@implementation ZBInitializeRequestManager
+ (void)sendGetConfigRequestSuccess:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail {
    [ZBTools transformDate:[NSDate date] intoLockedWord:^(NSString *hextime, NSString *lockedToken) {
        NSDictionary *dic = @{@"hextime": hextime, @"token": lockedToken};
        [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromApplicationConfig] arguments:dic header:nil successCallback:success failCallback:fail];
    }];
}

+ (void)sendGetConfigVersionSuccess:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail {
    [ZBTools transformDate:[NSDate date] intoLockedWord:^(NSString *hextime, NSString *lockedToken) {
        NSDictionary *dic = @{@"hextime": hextime, @"token": lockedToken};
        [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromApplicationConfigVersion] arguments:dic header:nil successCallback:success failCallback:fail];
    }];
}

+ (void)sendGetAndUpdataUserAuthenticityRequestWithTicket:(NSString *)ticket success:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail {
    NSParameterAssert(ticket);
    NSDictionary *arguments = @{@"ticket": ticket};
    [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromUserAuthenticity] arguments:arguments header:nil successCallback:success failCallback:fail];
}

+ (void)sendGetBusinessAuthenticityRequestWithTicket:(NSString *)ticket success:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail {
    NSParameterAssert(ticket);
    NSDictionary *arguments = @{@"ticket": ticket};
    [ZBHttpRequestManager sendBusinessHttpRequestWithAPI:[ZBURLPath pathFromBusinessAuth] arguments:arguments header:nil successCallback:success failCallback:fail];
}

+ (void)downloadFilterWordRequestCompletion:(void (^)(NSError *))error {
    [ZBTools transformDate:[NSDate date] intoLockedWord:^(NSString *hextime, NSString *lockedToken) {
        NSString * encodingString = [@"filter_word_list" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *nsdata = [encodingString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
        
        NSDictionary *dic = @{@"hextime": hextime, @"token": lockedToken, @"name": base64Encoded};
        
        NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithDictionary:@{@"api": [ZBURLPath pathFromApplicationConfig]}];
        [arguments addEntriesFromDictionary:dic];
        
        [ZBHttpRequestManager downloadFileWithAPI:[ZBURLPath pathFromApplicationConfig] arguments:arguments header:nil successCallback:^(id data) {
            if (error) {
                error(nil);
            }
        } failCallback:^(NSError *fail) {
            if (error) {
                error(fail);
            }
        }];
    }];
}

@end
