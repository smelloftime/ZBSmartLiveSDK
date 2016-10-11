//
//  ZBStreamingRequestManager.m
//  Pods
//
//  Created by lip on 16/10/8.
//
//

#import "ZBStreamingRequestManager.h"
#import "ZBURLPath.h"
#import "ZBErrorCode.h"
#import "ZBTools.h"
#import "ZBApplicationCenter.h"
#import "ZBHttpRequestManager.h"

@implementation ZBStreamingRequestManager
+ (void)sendCreatSteamRequestWithsuccess:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild {
    NSString *key = [ZBApplicationCenter defaultCenter].userAuthenticityModel.authenticAccessKey;
    NSParameterAssert(key);
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithDictionary:@{@"ak": key}];
    // 创建直播间
    [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromCreatStream] arguments:arguments header:nil successCallback:^(id data) {
        NSString *streamID = data[@"id"];
        NSString *streamIDMD5 = [ZBTools md5:streamID];
        if ([ZBApplicationCenter defaultCenter].imCid == nil) {
            [ZBApplicationCenter defaultCenter].imCid = data[@"im"][@"cid"];
        }
        // 校验直播间是否创建成功
        [arguments addEntriesFromDictionary:@{@"stream_id": streamIDMD5}];
        [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromCheckStream] arguments:arguments header:nil successCallback:^(id data) {
            NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)data];
            [mutableDic setObject:streamID forKey:@"stream_id"];
            if (success) {
                success(mutableDic);
            }
        } failCallback:^(NSError *error) {
            if (faild) {
                faild(error);
            }
        }];
    } failCallback:^(NSError *error) {
        if (faild) {
            faild(error);
        }
    }];
}

// 上传推流直播标题和地址至智播云服务器
+ (void)sendStartSteamRequestWithTitle:(NSString *)title location:(NSString *)location success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild {
    
    NSString *key = [ZBApplicationCenter defaultCenter].userAuthenticityModel.authenticAccessKey;
    if (key == nil) {
        if (faild) {
            faild([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"ak": key}];
    if (title) {
        [dic setObject:title forKey:@"title"];
    }
    if (location) {
        [dic setObject:location forKey:@"location"];
    }

    [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromStartStream] arguments:dic header:nil successCallback:^(id data) {
        if (success) {
            success(data);
        }
    } failCallback:^(NSError *error) {
        if (faild) {
            faild(error);
        }
    }];
}

// 上传推流直播封面图片至智播云的服务器
+ (void)uploadCoverImgBySDKRequestWithImg:(UIImage *)image Thumb:(NSString *)thumb success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild {
    NSString *key = [ZBApplicationCenter defaultCenter].userAuthenticityModel.authenticAccessKey;
    if (key == nil) {
        if (faild) {
            faild([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    if (image == nil) {
        if (faild) {
            faild([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
        }
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"ak": key}];
    if (thumb) {
        [dic setObject:thumb forKey:@"thumb"];
    }
    [ZBHttpRequestManager uploadImageRequestWithAPI:[ZBURLPath pathFromUploadImage] arguments:dic imageName:@"file" imageData:[ZBTools imageData:image] header:nil sucessCallback:^(id data) {
        if (success) {
            success(data);
        }
    } failCallback:^(NSError *error) {
        if (faild) {
            faild(error);
        }
    }];
}

// 断开推流
+ (void)sendEndSteamRequestWithStreamId:(NSString *)streamID success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild {
    NSString *key = [ZBApplicationCenter defaultCenter].userAuthenticityModel.authenticAccessKey;
    if (key == nil) {
        if (faild) {
            faild([ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        }
        return;
    }
    if (streamID == nil) {
        if (faild) {
            NSError *error = [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter];
            faild(error);
        }
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"ak": key,@"stream_id":[ZBTools md5:streamID]}];
    [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromEndStream] arguments:dic header:nil successCallback:^(id data) {
        if (success) {
            success(data);
        }
    } failCallback:^(NSError *error) {
        if (faild) {
            faild(error);
        }
    }];
    
}

@end