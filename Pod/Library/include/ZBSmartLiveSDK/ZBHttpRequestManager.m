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
#import "ZBURLPath.h"

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

+ (void)sendGetBaseURLRequestWithAPIVersion:(NSString *)vesionString successCallback:(void (^)(id))success failCallback:(void (^)(NSError *))fail {
    NSParameterAssert(vesionString);
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] init];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain",@"text/html", @"application/x-www-form-urlencoded", @"text/javascript", nil];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = 10;
    
    httpSessionManager.requestSerializer = requestSerializer;
    httpSessionManager.responseSerializer = responseSerializer;
    
    [ZBTools transformDate:[NSDate date] intoLockedWord:^(NSString *hextime, NSString *lockedToken) {
        NSDictionary *parameter = @{@"api_version":vesionString, @"api":[ZBURLPath pathFromApiConfig], @"hextime":hextime, @"token":lockedToken};
        [httpSessionManager POST:[ZBApplicationCenter defaultCenter].rootURL parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

+ (void)sendBusinessHttpRequestWithAPI:(NSString *)api arguments:(NSDictionary *)arguments header:(NSDictionary *)header successCallback:(void (^)(id))success failCallback:(void (^)(NSError *))fail {
    NSParameterAssert(api);
    NSParameterAssert(arguments);
    NSString *businessRootServerAddress = [ZBApplicationCenter defaultCenter].businessRootServerAddress;
    if (businessRootServerAddress == nil) {
        NSError *error = [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize];
        if (fail) {
            fail(error);
        }
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"api": api}];
    [dic addEntriesFromDictionary:arguments];
    
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:businessRootServerAddress]];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain",@"text/html", @"application/x-www-form-urlencoded", @"text/javascript", nil];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = 10;
    
    httpSessionManager.requestSerializer = requestSerializer;
    httpSessionManager.responseSerializer = responseSerializer;
    
    ZBLog(@"\businessRootServerAddress:%@\nbusinessRootServerAddressArgumentsDictionary:%@\n", businessRootServerAddress, dic);
    
    [httpSessionManager POST:@"apis" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            fail(error);
        }
    }];
}

+ (void)downloadFileWithAPI:(NSString *)api arguments:(NSDictionary *)arguments header:(NSDictionary *)header successCallback:(void (^)(id))success failCallback:(void (^)(NSError *))fail {
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
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[ZBTools httpBodyForParamsDictionary:dic]];
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    ZBLog(@"\nBaseURL:%@\ndownloadTaskArgumentsDictionary:%@\ndocumentsDirectoryURL:%@", baseURL, dic, documentsDirectoryURL);
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (fail) {
                fail(error);
            }
        } else {
            if (success) {
                success(nil);
            }
        }
    }];
    [downloadTask resume];
}

@end
