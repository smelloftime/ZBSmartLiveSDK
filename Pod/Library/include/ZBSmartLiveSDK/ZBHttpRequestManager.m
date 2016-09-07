//
//  ZBHttpRequestManager.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBHttpRequestManager.h"
#import "ZBTools.h"
#import "ZBApplicationCenter.h"
#import "ZBErrorCode.h"
#import "AFNetworking.h"
#import "ZBPrefix.h"

#define Get_Root_Api @"http://test.zhibocloud.cn/api/getconfig/getApi"

typedef enum {
    HttpRequestStatusNormal     = 0,        ///< 正常状态
    HttpRequestStatusError      = 500,      ///< 非法请求
    HttpRequestStatusRecreate   = 70401     ///< 重复创建交易口令
} HttpRequestStatus;

const NSString *kStatusMsgKey = @"message";

@implementation ZBHttpRequestManager

void(^processResponseData)(id,void(^)(id),void(^)(NSError *)) = ^(id data,void(^success)(id),void(^fail)(NSError *)) {
    if (![data isKindOfClass:[NSDictionary class]]) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithCoustomDomain:@"ZBURLErrorDomain" errorCode:505 description:@"服务器返回的数据格式有误"]);
        }
        return;
    }
    if (success) {
        int index = [data[@"code"] intValue];
        switch (index) {
            case HttpRequestStatusNormal:
                if (data[@"data"] == nil) {
                    success(data[@"message"]);
                } else {
                    success(data[@"data"]);
                }
                break;
            case HttpRequestStatusError:
                if (fail) {
                    fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusBreakIn]);
                }
                break;
            default:
                if (fail) {
                    fail([ZBErrorCode errorCreateWithCoustomDomain:@"ZBURLErrorDomain" errorCode:[data[@"code"] integerValue] description:data[kStatusMsgKey]]);
                }
                break;
        }
    }
};

void(^processImageResponseData)(id,void(^)(id),void(^)(NSError *)) = ^(id data,void(^success)(id),void(^fail)(NSError *)) {
    if (![data isKindOfClass:[NSDictionary class]]) {
        if (fail) {
            fail([ZBErrorCode errorCreateWithCoustomDomain:@"ZBURLErrorDomain" errorCode:505 description:@"服务器返回的数据格式有误"]);
        }
        return;
    }
    if (success) {
        switch ([data[@"code"] intValue]) {
            case HttpRequestStatusNormal:
                if (data[@"data"]) {
                    if (success) {
                        success(data[@"data"][0][@"urls"]);
                    }
                }
                break;
            case HttpRequestStatusError:
                if (fail) {
                    fail([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusBreakIn]);
                }
                break;
            default:
                if (fail) {
                    fail([ZBErrorCode errorCreateWithCoustomDomain:@"ZBURLErrorDomain" errorCode:[data[@"code"] integerValue] description:data[kStatusMsgKey]]);
                }
                break;
        }
    }
};

+ (AFHTTPSessionManager *)httpSessionManagerInitializeWithTimeoutInterval:(NSTimeInterval)timeoutInterval {
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] init];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain",@"text/html", @"application/x-www-form-urlencoded", @"text/javascript", nil];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = timeoutInterval;
    
    httpSessionManager.requestSerializer = requestSerializer;
    httpSessionManager.responseSerializer = responseSerializer;
    
    return httpSessionManager;
}

+ (void)sendGetBaseURLRequestWithAPPID:(NSString *)appID appToken:(NSString *)appToken successCallback:(void (^)(id data))success failCallback:(void (^)(NSError *error))fail {
    NSParameterAssert(appID);
    NSParameterAssert(appToken);
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] init];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain",@"text/html", @"application/x-www-form-urlencoded", @"text/javascript", nil];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = 10;
    
    httpSessionManager.requestSerializer = requestSerializer;
    httpSessionManager.responseSerializer = responseSerializer;
    
    [ZBTools transformDate:[NSDate date] token:appToken intoLockedWord:^(NSString *hextime, NSString *lockedToken) {
        [httpSessionManager.requestSerializer setValue:appID forHTTPHeaderField:@"Auth-Appid"];
        [httpSessionManager.requestSerializer setValue:lockedToken forHTTPHeaderField:@"Auth-Token"];
        [httpSessionManager.requestSerializer setValue:hextime forHTTPHeaderField:@"Auth-Basetime"];
        [httpSessionManager POST:Get_Root_Api parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            processResponseData(responseObject, success, fail);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (fail) {
                fail(error);
            }
        }];
    }];
}

+ (void)sendHttpRequestWithAPI:(NSString *)api arguments:(NSDictionary *)arguments header:(NSDictionary *)header successCallback:(void (^)(id))success failCallback:(void (^)(NSError *))fail {
    NSParameterAssert(api);
    NSParameterAssert(arguments);
    NSString *baseURL = [ZBApplicationCenter defaultCenter].baseURL;
    if (baseURL == nil) {
        NSError *error = [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize];
        if (fail) {
            fail(error);
        }
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"api": api}];
    [dic addEntriesFromDictionary:arguments];
    
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain",@"text/html", @"application/x-www-form-urlencoded", @"text/javascript", nil];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = 10;
    
    httpSessionManager.requestSerializer = requestSerializer;
    httpSessionManager.responseSerializer = responseSerializer;
    
    ZBLog(@"\nBaseURL:%@\nargumentsDictionary:%@\n", baseURL, dic);
    
    [httpSessionManager POST:@"api" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        processResponseData(responseObject, success, fail);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (fail) {
            fail(error);
        } else {
            ZBLog(@"%@", [error localizedDescription]);
        }
    }];
}

+ (void)uploadImageRequestWithAPI:(NSString *)api arguments:(NSDictionary *)arguments imageName:(NSString *)imageName imageData:(NSData *)imageData header:(NSDictionary *)header sucessCallback:(void (^)(id))success failCallback:(void (^)(NSError *))fail {
    NSParameterAssert(api);
    NSParameterAssert(arguments);
    NSString *baseURL = [ZBApplicationCenter defaultCenter].baseURL;
    if (baseURL == nil) {
        NSError *error = [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize];
        if (fail) {
            fail(error);
        }
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"api": api}];
    [dic addEntriesFromDictionary:arguments];
    
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    httpSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = 20;
    httpSessionManager.requestSerializer = requestSerializer;
    
    ZBLog(@"\nBaseURL:%@\nargumentsDictionary:%@\nlength:%d\n", baseURL, dic, (int)imageData.length);
    
    [httpSessionManager POST:@"api" parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:imageName fileName:[NSString stringWithFormat:@"%@.jpg",imageName] mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        processImageResponseData(responseObject,success,fail);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(fail){
            ZBLog(@"%@", [error localizedDescription]);
        }
    }];
}


@end
