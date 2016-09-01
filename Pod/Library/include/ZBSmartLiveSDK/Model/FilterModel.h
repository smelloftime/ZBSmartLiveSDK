//
//  FilterModel.h
//  ZhiBo
//
//  Created by lip on 16/3/29.
//  Copyright © 2016年 lip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterModel : NSObject
/** 类型 */
@property (copy, nonatomic) NSString *desc;
/** 关键字 也是回传字段 */
@property (copy, nonatomic) NSString *key;
/** 类型 目前只有 between radio local 三种类型 */
@property (copy, nonatomic) NSString *type;
/** 显示风格(类型) */
@property (copy, nonatomic) NSString *name;
/** 值 */
@property (strong, nonatomic) NSArray *valueArray;

@end