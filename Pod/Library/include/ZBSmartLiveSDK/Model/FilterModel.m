//
//  FilterModel.m
//  ZhiBo
//
//  Created by lip on 16/3/29.
//  Copyright © 2016年 lip. All rights reserved.
//

#import "FilterModel.h"
#import "MJExtension/MJExtension.h"

@implementation FilterModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"valueArray": @"value"};
}

@end
