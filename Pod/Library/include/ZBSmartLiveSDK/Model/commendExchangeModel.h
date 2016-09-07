//
//  commendExchangeModel.h
//  ZhiBo
//
//  Created by lip on 16/4/21.
//  Copyright © 2016年 lip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommendExchangeModel : NSObject
/** 金币数 */
@property (assign, nonatomic) NSInteger gold;
/** 兑换消耗的点赞数 */
@property (assign, nonatomic) NSInteger zan;

@end
