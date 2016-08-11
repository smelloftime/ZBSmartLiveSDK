//
//  ZBCloudData.h
//  Pods
//
//  Created by lip on 16/7/23.
//
//

#import <Foundation/Foundation.h>

@interface ZBCloudData : NSObject
/**
 *  获取智播云服务器上关于直播相关的数据
 *
 *  @param requestApi 请求的接口名称，接口相关请查阅智播云通讯文档
 *  @param parameter  请求的接口参数
 *  @param success    请求的正确结果
 *  @param fail       请求的错误结果
 */
+ (void)getZBCloudDataWithApi:(NSString *)requestApi parameter:(NSDictionary *)parameter success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;
/**
 *  上传推流直播封面图片至智播云的服务器
 *  
 *  @note  图片会被压缩至 500 kb 以下
 *
 *  @param image     需要上传的图片
 *  @param parameter 图片的规格,可以不传该参数
 *  @param success   请求的正确结果
 *  @param fail      请求的错误结果
 */
+ (void)uploadImage:(UIImage *)image parameter:(NSDictionary *)parameter success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;

@end
