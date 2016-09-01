//
//  ZBURLPath.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//  智播云服务器通讯的 API 文档
//  APP 与智播云通讯都默认使用 Post 方法

#import <Foundation/Foundation.h>

@interface ZBURLPath : NSObject

#pragma mark - about application api
/**
 *  整个应用的配置获取接口
 *
 *  @return 该接口路径的字符串
 */
+ (NSString *)pathFromApplicationConfig;
/**
 *  应用配置的版本号获取接口
 *
 *  @return 该接口路径的字符串
 */
+ (NSString *)pathFromApplicationConfigVersion;

#pragma mark - user
/**
 *  获取用户真实性证明凭证接口
 *
 *  @return 该接口的路径字符串
 */
+ (NSString *)pathFromUserAuthenticity;
/**
 *  上传直播推流图片的接口
 *
 *  @return 该接口的路径字符串
 */
+ (NSString *)pathFromUploadImage;
/**
 *  赠送礼物的接口
 *
 *  @return 该接口的路径字符串
 */
+ (NSString *)pathFromSendGift;

@end
