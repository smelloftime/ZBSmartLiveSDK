//
//  ZBChatroom.h
//  Pods
//
//  Created by lip on 16/8/24.
//
//

#import <Foundation/Foundation.h>

@interface ZBChatroom : NSObject
/**
*  加入聊天室
*
*  @param chatroomID 聊天室的唯一标识
*  @param password   聊天的密码,可以为空
*  @param completion 响应结果,error 为空时,respondData 才会有数据,如果error有值则 respondData 为空
*/
- (void)joinChatroom:(NSNumber *)chatroomID password:(NSString *)password completion:(void(^)(id respondData, NSError *error))completion;

/**
 *  禁言聊天室用户
 *
 *  @note 只有主播才能顺利使用该接口
 *
 *  @param userIdentity 被禁言用户的唯一标识
 *  @param disableTime  禁言时长,单位秒,如果设置为 0 表示永久禁言
 *  @param completion   响应结果,error 为空时,respondData 才会有数据,如果error有值则 respondData 为空
 */
- (void)disableChatroomUserIdentity:(NSString *)userIdentity sendMessageWithTime:(NSUInteger)disableTime completion:(void(^)(id respondData, NSError *error))completion;

/**
 *  解除聊天室用户禁言
 *
 *  @note 只有主播才能顺利使用该接口
 *
 *  @param userIdentity 解禁用户的唯一标识
 *  @param completion   响应结果,error 为空时,respondData 才会有数据,如果error有值则 respondData 为空
 */
- (void)enableChatroomUserIdentity:(NSString *)userIdentity sendMessageCompletion:(void(^)(id respondData, NSError *error))completion;

/**
 *  获取聊天室人数
 *
 *  @param chatroomID 聊天室的唯一标识
 *  @param completion 响应结果,error 为空时,respondData 才会有数据,如果error有值则 respondData 为空
 */
- (void)getChatroom:(NSNumber *)chatroomID viewerCountCompletion:(void(^)(id respondData, NSError *error))completion;

/**
 *  离开聊天室
 *
 *  @param chatroomID 聊天室的唯一标识
 *  @param password   聊天室的密码,可以为空
 *  @param completion 响应结果,error 为空时, respondData 才会有数据,如果error有值则 respondData 为空
 */
- (void)leaveChatroom:(NSNumber *)chatroomID password:(NSString *)password completion:(void(^)(id respondData, NSError *error))completion;

@end
