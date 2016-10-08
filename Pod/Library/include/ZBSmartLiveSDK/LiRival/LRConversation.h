//
//  LRConversation.h
//  Pods
//
//  Created by lip on 16/8/20.
//
//  暂未使用

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LRConversationType) {
    LRConversationTypeDialog = 1, ///< 1对1会话
    LRConversationTypeGroupChat, ///< 多人会话
    LRConversationTypeChatroom, ///< 聊天室
    LRConversationTypeRealTimeChatroom, ///< 实时聊天室
};

@interface LRConversation : NSObject
/** 会话唯一标识 */
@property (copy, nonatomic) NSString *identity;
/** 会话类型 */
@property (assign, nonatomic) LRConversationType conversationType;
// 创建一个单聊 会话
// 创建一个群组 会话
// 创建一个聊天室 会话
// 创建一个实时消息聊天室会话

+ (instancetype)conversationWithIdentity:(NSString *)identity type:(LRConversationType)type;


@end
