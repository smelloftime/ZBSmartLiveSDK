//
//  ZBBusinessCloudData.h
//  Pods
//
//  Created by lip on 16/10/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GetFansAndAttentionListType) {
    GetFansAndAttentionListTypeFans,
    GetFansAndAttentionListTypeAttention
};

typedef NS_ENUM(NSInteger, ZBFollowType) {
    ZBFollowTypeFollow = 1, ///< 关注
    ZBFollowTypeCancel, ///< 取消关注
    ZBFollowTypeIsFollow ///< 查询是否关注
};

@interface ZBBusinessCloudData : NSObject

+ (void)zb_GetBusinessCloudDataFansAndAttentionListRequestWithType:(GetFansAndAttentionListType)type uname:(NSString *)uname success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;

+ (void)zb_sendFollowRequestWithAction:(ZBFollowType)followAction usid:(NSString *)usid success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;

+ (void)zb_GetUserInfoWithUsid:(NSArray *)usid success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;

/** 这里实现三个接口
 
 SDK内部实现 授权接口
 
 TS内查找页面 入口进入时 更新用户信息 如果没有网络 或者网络不佳 就不能正常使用 直播 功能
 */
@end
