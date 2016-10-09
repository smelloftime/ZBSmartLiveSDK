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

+ (void)sendGetConfigRequestSuccess:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail;

+ (void)sendGetConfigVersionSuccess:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail;

+ (void)sendGetAndUpdataUserAuthenticityRequestWithTicket:(NSString *)ticket success:(RequestSuccessCallBack)success fail:(RequestFailCallBack)fail;

+ (void)downloadFilterWordRequestCompletion:(void (^)(NSError *))error;

@end
