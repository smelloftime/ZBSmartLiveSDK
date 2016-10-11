//
//  ZBHttpRequestManager.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//  负责网络请求管理

#import <Foundation/Foundation.h>

@interface ZBHttpRequestManager : NSObject

+ (void)sendGetBaseURLRequestWithAPIVersion:(NSString *)vesionString successCallback:(void(^)(id data))success failCallback:(void(^)(NSError *error))fail;

+ (void)sendHttpRequestWithAPI:(NSString *)api arguments:(NSDictionary *)arguments header:(NSDictionary *)header successCallback:(void(^)(id))success failCallback:(void(^)(NSError *error))fail;

+ (void)uploadImageRequestWithAPI:(NSString *)api arguments:(NSDictionary *)arguments imageName:(NSString *)imageName imageData:(NSData *)imageData  header:(NSDictionary *)header sucessCallback:(void(^)(id))success failCallback:(void(^)(NSError *error))fail;

+ (void)downloadFileWithAPI:(NSString *)api arguments:(NSDictionary *)arguments header:(NSDictionary *)header successCallback:(void(^)(id))success failCallback:(void(^)(NSError *error))fail;

@end
