//
//  ZBBusinessCloudData.h
//  Pods
//
//  Created by lip on 16/10/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZBFollowActionType) {
    ZBFollowActionTypeFans = 0, ///< 粉丝
    ZBFollowActionTypeFollow ///< 关注
};

typedef NS_ENUM(NSInteger, ZBFollowType) {
    ZBFollowTypeFollow = 1, ///< 关注
    ZBFollowTypeCancel, ///< 取消关注
    ZBFollowTypeIsFollow ///< 查询是否关注
};

@interface ZBBusinessCloudData : NSObject

/**
 *  获取商务服务器上的关注清单信息
 *
 *  @param type           查询类型
 *  @param uname          搜索关键字,可以为空,如果为空表示不搜索,显示所有用户信息
 *  @param businessUserID 商务服务器提供的用户唯一标识.从服务器`usid`映射
 *  @param pageNumber     查询分页页码,由服务器提供
 *  @param success        查询成功后的回调数据
 *  @param fail           查询错误信息
 */
+ (void)zb_GetBusinessCloudDataFansFollowListRequestWithType:(ZBFollowActionType)type uname:(NSString *)uname businessUserID:(NSString *)businessUserID pageNumber:(NSUInteger)pageNumber success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;

/**
 *  对商务服务器指定用户发起关注操作
 *
 *  @param followAction   关注操作
 *  @param businessUserID 商务服务器提供的用户唯一表示,从服务器`usid`映射
 *  @param success        查询成功后的回调数据
 *  @param fail           查询错误的信息
 */
+ (void)zb_sendFollowRequestWithAction:(ZBFollowType)followAction businessUserID:(NSString *)businessUserID success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;

/**
 *  获取商务服务器对应的商务服务器唯一标识用户的用户信息
 *
 *  @param businessUserIDArray  多个商务服务器提供的用户唯一标识用逗号分隔的组成的字符串,从服务器`usid`映射
 *  @param success              查询成功后的回调数据
 *  @param fail                 查询错误的信息
 */
+ (void)zb_GetUserInfoWithBusinessUserIDArray:(NSString *)businessUserIDArray success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;

@end
