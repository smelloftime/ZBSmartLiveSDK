//
//  ZBStreamingRequestManager.h
//  Pods
//
//  Created by lip on 16/10/8.
//
//

#import <Foundation/Foundation.h>

typedef void(^ZBStreamingRequestSuccessBlock)(id responsObject);
typedef void(^ZBStreamingRequestFaildBlock)(NSString *err);

@interface ZBStreamingRequestManager : NSObject
/**
*  创建直播间 + 校验直播间
*
*  @param success 成功校验直播间后,将直播间信息通过字典中`stream`对应的值返回json格式的字符串,聊天室信息通过`cid`对应的`int`类型的值返回,用户信息通过`im_uid`对应的`int`类型的值返回
*  @param faild   错误请求的请求信息
*/
+ (void)sendCreatSteamRequestWithsuccess:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild;

// 开始推流
+ (void)sendStartSteamRequestWithTitle:(NSString *)title location:(NSString *)location success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild;

// 断开推流
+ (void)sendEndSteamRequestWithsuccess:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild;

// 上传封面图 + 开始推流
+ (void)uploadCoverImgBySDKRequestWithImg:(UIImage *)image title:(NSString *)title  location:(NSString *)location Thumb:(NSString *)thumb success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild;

@end
