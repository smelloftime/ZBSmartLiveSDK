//
//  ZBChat.h
//  Pods
//
//  Created by lip on 16/8/24.
//
//

#import <Foundation/Foundation.h>
#import "ZBMessage.h"

@class ZBChat;

typedef NS_ENUM(NSUInteger, ZBChatState) {
    ZBChatStateReconnection = 1, ///< 重连中
    ZBChatStateSuccess = 2, ///< 重练成功
    ZBChatStateNetworkFail = 3, ///< 网络连接中断
};

@protocol ZBChatDelegate <NSObject>

@optional
/**
 *  接收到的聊天信息
 *
 *  @param chat    聊天核心
 *  @param message 消息
 */
- (void)chat:(ZBChat *)chat didReceiveMessage:(ZBMessage *)message;

/**
 *  聊天核心与服务器的重连情况
 *
 *  @note 聊天核心内部拥有自己的重连逻辑,所以在接收到该状态时可以直接展示给UI界面
 *
 *  @param chat            聊天核心
 *  @param connectionState 链接状态
 */
- (void)chat:(ZBChat *)chat connectionStateDidChange:(ZBChatState)connectionState;

@end

@interface ZBChat : NSObject
/** 聊天信息接收代理 */
@property (weak, nonatomic) id<ZBChatDelegate> delegate;
// 发送文本消息到会话中
- (void)sendMessage:(ZBMessage *)message toConversation:(NSNumber *)conversationIdentity completion:(void(^)(id respondData, NSError *error))completion;
/// 手动重连聊天服务器
- (void)reconnectionSuccess:(void (^)(NSString *))success fail:(void (^)(NSError *))fail;
/// 手动启动重连逻辑
- (void)reconnectLiRivalKit;

@end
