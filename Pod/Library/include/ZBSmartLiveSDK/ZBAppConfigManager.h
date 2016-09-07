//
//  ZBAppConfigManager.h
//  ZhiBoLaboratoryaa XBN ,BBRM
//
//  Created by lip on 16/7/12.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBAppConfigManager : NSObject
+ (void)initializeApplicationCompletion:(void (^)(NSError *))error;

+ (void)getUserAuthenticityWithZBTicket:(NSString *)ticket completion:(void (^)(NSError *))error;

+ (void)initializeCompletion:(void (^)(NSError *))error;

@end
