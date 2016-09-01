//
//  ZBMessage.h
//  Pods
//
//  Created by lip on 16/8/24.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZBMessageType) {
    ZBMessageTypeText = 0, ///< 文本消息
    ZBMessageTypeCoustomWillBan = 100,///< 被禁言后就无法成功发送的自定义消息
    ZBMessageTypeCoustomAvailable = 210, ///< 被禁言后也能到达的自定义消息类型
};

/**
 *  @note 当你需要发送一条文本消息时,设置 messageContent 为文本消息内容(可以包含emoji表情),然后设置messageType = 0
 *
 *  @note 当你需要发送一条自定义消息时,建议不设置 messageContent,然后同时设置 extend,和 extendCode
 *
 */

@interface ZBMessage : NSObject
/** 消息发送者唯一标识
 *
 *  @note 该标识由对接智播云服务器的客户服务器生成
 *
 *  @warning 发送消息时,必须有该值,否则会导致接收端异常
 *
 */
@property (copy, nonatomic) NSString *fromUserIdentity;
/** 消息内容.不含消息内容时,可以无该值 */
@property (copy, nonatomic) NSString *messageContent;
/** 消息类型 */
@property (assign, nonatomic) ZBMessageType messageType;
/** 是否实时消息 默认为NO */
@property (assign, nonatomic) BOOL isRealTime;
/** 消息的自定义内容 可以为空
 *
 *  @warning 当自定义内容 extend 未设置时, extendCode 设置无效.
 */
@property (strong, nonatomic) NSDictionary *extend;
/** 消息的自定义内容 代号
 *  
 *  @note 用户识别消息自定义内容的解析方式
 *
 *  @warning 只能识别 0 - 9999
 *
 */
@property (assign, nonatomic) NSUInteger extendCode;

// 需要加上消息到达的对话号

@end
