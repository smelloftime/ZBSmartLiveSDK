//
//  ZBConfigInfoModel.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/12.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBConfigInfoModel.h"
#import "MJExtension/MJExtension.h"

@implementation ZBConfigInfoModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"sendSnsToken": @"send_sns_token", @"snsTimespan": @"sns_timespan", @"tokenKey": @"token_key", @"validLock": @"valid_lock", @"varPage" : @"var_page",@"liveFilterList":@"filter_list.live", @"replayFilterList": @"filter_list.video", @"commendExchangeList": @"exchange_type_list.zan_list", @"giftList": @"gift_list", @"goldPayExchangeList": @"exchange_type_list.pay_list", @"goldCashExchangeList" :@"exchange_type_list.cash_list", @"webSocketServerList" :@"webim"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"liveFilterList" : @"FilterModel", @"replayFilterList": @"FilterModel", @"commendExchangeList": @"CommendExchangeModel", @"giftList":@"GiftModel", @"goldPayExchangeList" : @"GoldModel", @"goldCashExchangeList": @"GoldModel", @"webSocketServerList": @"ZBWebSocketServerModel"};
}

@end
