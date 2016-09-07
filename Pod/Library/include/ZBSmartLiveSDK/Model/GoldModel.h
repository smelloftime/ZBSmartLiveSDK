//
//  GoldModel.h
//  ZhiBo
//
//  Created by lip on 16/6/13.
//  Copyright © 2016年 lip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoldModel : NSObject
/** 人民币数 (单位元) */
@property (assign, nonatomic) int money;
/** 金币数 */
@property (assign, nonatomic) int gold;
/** 产品Id */
@property (strong, nonatomic) NSString * product_id;

@end
