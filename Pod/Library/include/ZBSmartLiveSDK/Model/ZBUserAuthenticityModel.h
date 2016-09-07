//
//  ZBUserAuthenticityModel.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/14.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBUserAuthenticityModel : NSObject
/** 聊天服务器 ID */
@property (assign, nonatomic) NSInteger instantMessagingIdentity;
/** 聊天服务器密码 */
@property (copy, nonatomic) NSString *instantMessagingPassword;
/** 商务服务器用户 ID */
@property (copy, nonatomic) NSString *businessUserIdentity;
/** 合法性钥匙串 */
@property (copy, nonatomic) NSString *authenticAccessKey;

@end
