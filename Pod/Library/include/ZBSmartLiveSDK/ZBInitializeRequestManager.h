//
//  ZBInitializeRequestManager.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/13.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//  初始化相关的网络请求管理

#import <Foundation/Foundation.h>

typedef void(^RequestSuccessCallBack)(id data);
typedef void(^RequestFailCallBack)(NSError *fail);

@interface ZBInitializeRequestManager : NSObject
/// 发送获取智播云配置请求
+ (void)sendGetConfigRequestSuccess:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail;

/// 发起获取最新智播云配置版本号请求
+ (void)sendGetConfigVersionSuccess:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail;

/// 发起获取和更新智播云授权信息请求
+ (void)sendGetAndUpdataUserAuthenticityRequestWithTicket:(NSString *)ticket success:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail;

/// 发起获取商务服务器授权信息请求
+ (void)sendGetBusinessAuthenticityRequestWithTicket:(NSString *)ticket success:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail;

/// 下载过滤敏感词词典请求
+ (void)downloadFilterWordRequestCompletion:(void (^)(NSError *))error;

@end
