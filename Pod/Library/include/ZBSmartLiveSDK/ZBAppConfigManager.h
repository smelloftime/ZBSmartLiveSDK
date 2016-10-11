//
//  ZBAppConfigManager.h
//  ZhiBoLaboratoryaa XBN ,BBRM
//
//  Created by lip on 16/7/12.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//  应用配置管理

#import <Foundation/Foundation.h>

@interface ZBAppConfigManager : NSObject
// 应用初始化
+ (void)initializeApplicationCompletion:(void (^)(NSError *))error;

// 通过票据获取用户授权信息
+ (void)getUserAuthenticityWithZBTicket:(NSString *)ticket completion:(void (^)(NSError *))error;

/**
 *  初始化更新
 *
 *  @note 初始化更新所有相关的授权信息
 *
 *  @param error 初始化的结果
 */
+ (void)initializeCompletion:(void (^)(NSError *))error;

@end
