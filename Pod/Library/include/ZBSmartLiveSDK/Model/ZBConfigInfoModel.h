//
//  ZBConfigInfoModel.h
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/12.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBWebSocketServerModel.h"

@interface ZBConfigInfoModel : NSObject
/** 短信发送验证口令 */
@property (copy, nonatomic) NSString *sendSnsToken;
/** 前段短信发送间隔时间 */
@property (assign, nonatomic) NSInteger snsTimespan;
/** 推流校验口令 */
@property (copy, nonatomic) NSString *validLock;
/** 直播间公告信息 */
@property (strong, nonatomic) NSArray *streamNoticeList;
/** 直播列表请求口令 */
@property (copy, nonatomic) NSString *varPage;
/** 过滤列表 直播清单 */
@property (strong, nonatomic) NSArray *liveFilterList;
/** 过滤列表 回放清单 */
@property (strong, nonatomic) NSArray *replayFilterList;
/** 点赞兑换比例清单 */
@property (strong, nonatomic) NSArray *commendExchangeList;
/** 金币充值兑换比例清单 */
@property (strong, nonatomic) NSArray *goldPayExchangeList;
/** 金币提现兑换比例清单 */
@property (strong, nonatomic) NSArray *goldCashExchangeList;
/** 聊天服务器地址列表 */
@property (strong, nonatomic) NSArray *webSocketServerList;
/** 过滤词替换符号 */
@property (copy, nonatomic) NSString *filterReplaceWord;
/** 敏感词版本号 */
@property (copy, nonatomic) NSString *filterWordVersion;

@end
