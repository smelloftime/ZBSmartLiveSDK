//
//  ZBStreamingRequestManager.m
//  Pods
//
//  Created by lip on 16/10/8.
//
//

#import "ZBStreamingRequestManager.h"
#import "ZBURLPath.h"
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
        NSDictionary *imInfoDic = data[@"im"];
        // 校验直播间是否创建成功
        [arguments addEntriesFromDictionary:@{@"stream_id": streamIDMD5}];
        [ZBHttpRequestManager sendHttpRequestWithAPI:[ZBURLPath pathFromCheckStream] arguments:arguments header:nil successCallback:^(id data) {
            NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)data];
            [mutableDic addEntriesFromDictionary:imInfoDic];
            if (success) {
                success(mutableDic);
            }
        } failCallback:^(NSError *error) {
            if (faild) {
                faild([error localizedDescription]);
            }
        }];
    } failCallback:^(NSError *error) {
        if (faild) {
            faild([error localizedDescription]);
        }
    }];
}

// 开始推流
+ (void)sendStartSteamRequestWithTitle:(NSString *)title location:(NSString *)location success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild {
    
}

// 断开推流
+ (void)sendEndSteamRequestWithsuccess:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild {
    
}

// 上传封面图 + 开始推流
+ (void)uploadCoverImgBySDKRequestWithImg:(UIImage *)image title:(NSString *)title  location:(NSString *)location Thumb:(NSString *)thumb success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild {
    
}

@end
