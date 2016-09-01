//
//  ZBURLPath.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBURLPath.h"

@implementation ZBURLPath
+ (NSString *)pathFromApplicationConfig {
    return @"ZBCloud_Get_Config";
}

+ (NSString *)pathFromApplicationConfigVersion {
    return @"ZBCloud_Get_Apiversion";
}

+ (NSString *)pathFromUserAuthenticity {
    return @"ZBCloud_Get_Auth";
}

+ (NSString *)pathFromUploadImage {
    return @"ZBCloud_Upload_Stream";
}

+ (NSString *)pathFromSendGift {
    return @"ZBCloud_Give_Gift";
}

@end
