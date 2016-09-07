//
//  GiftModel.m
//  ZhiBo
//
//  Created by lip on 16/5/25.
//  Copyright © 2016年 lip. All rights reserved.
//

#import "GiftModel.h"
#import "MJExtension/MJExtension.h"

@implementation GiftModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"giftCode": @"gift_code"};
}

@end
