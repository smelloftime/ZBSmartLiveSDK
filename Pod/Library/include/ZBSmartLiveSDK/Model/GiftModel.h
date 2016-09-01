//
//  GiftModel.h
//  ZhiBo
//
//  Created by lip on 16/5/25.
//  Copyright © 2016年 lip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftModel : NSObject
/** 礼物代号 */
@property (copy, nonatomic) NSString *giftCode;
/** 礼物金币数 */
@property (assign, nonatomic) NSInteger gold;
/** 礼物名称 */
@property (copy, nonatomic) NSString *name;

@end
