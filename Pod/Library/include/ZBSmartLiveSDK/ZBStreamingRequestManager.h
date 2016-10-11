//
//  ZBStreamingRequestManager.h
//  Pods
//
//  Created by lip on 16/10/8.
//
//  推流相关的网络请求管理

#import <Foundation/Foundation.h>

typedef void(^ZBStreamingRequestSuccessBlock)(id responsObject);
typedef void(^ZBStreamingRequestFaildBlock)(NSError *err);

@interface ZBStreamingRequestManager : NSObject
/**
*  创建直播间 + 校验直播间
*
*  @param success 成功校验直播间后,将直播间信息通过字典中`stream`对应的值返回json格式的字符串,聊天室信息通过`cid`对应的`int`类型的值返回,用户信息通过`im_uid`对应的`int`类型的值返回
*  @param faild   错误请求的请求信息
*/
+ (void)sendCreatSteamRequestWithsuccess:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild;

/**
 上传推流直播标题和地址至智播云服务器

 @param title    直播间标题
 @param location 直播间地址
 @param success  请求正确的结果
 @param faild    请求错误的结果
 */
+ (void)sendStartSteamRequestWithTitle:(NSString *)title location:(NSString *)location success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild;

/**
 *  上传推流直播封面图片至智播云的服务器
 *
 *  @note  图片会被压缩至 500 kb 以下
 
 @param image    需要上传的图片
 @param thumb    自定义生成的缩略图大小
 @param success  请求的正确结果
 @param faild    请求的错误结果
 */
+ (void)uploadCoverImgBySDKRequestWithImg:(UIImage *)image Thumb:(NSString *)thumb success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild;

// 断开推流
+ (void)sendEndSteamRequestWithStreamId:(NSString *)streamID success:(ZBStreamingRequestSuccessBlock)success faild:(ZBStreamingRequestFaildBlock)faild;

@end
