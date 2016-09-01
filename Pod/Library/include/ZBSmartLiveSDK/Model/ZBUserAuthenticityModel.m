//
//  ZBUserAuthenticityModel.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/14.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBUserAuthenticityModel.h"
#import "MJExtension.h"

@implementation ZBUserAuthenticityModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"instantMessagingIdentity"     : @"im.im_uid",
             @"instantMessagingPassword"   : @"im.im_pwd",
             @"businessUserIdentity"         : @"usid",
             @"authenticAccessKey"   : @"ak"
             };
}

@end
