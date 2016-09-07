//
//  ZBMessageModel.h
//  Pods
//
//  Created by lip on 16/8/24.
//
//  完整的消息字段属性,用于本地化

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZBMessageModelType) {
    ZBMessageModelTypeText = 0, ///<  文本消息
    ZBMessageModelTypeCoustomWillBan = 100, ///< 被禁言后就无法成功发送的自定义消息
    ZBMessageModelTypeCoustomAvailable = 210, ///< 被禁言后也能到达的自定义消息类型
};

@interface ZBMessageModel : NSObject
/** 发送到的对话的唯一标识 */
@property (strong, nonatomic) NSNumber *conversationIdentity;
/** 发送到指定用户组 */
@property (strong, nonatomic) NSArray *targetArray;
/** 发送消息者的用户唯一标识
 *
 *  @note 该唯一标识来自于聊天服务器,发送消息时可以无该值
 **/
@property (strong, nonatomic) NSNumber *senderIdentity;
/** 实时消息标识 0表示为假,1表示为真 */
@property (strong, nonatomic) NSNumber *realTime;
/** 消息类型 0-255 */
@property (strong, nonatomic) NSNumber *type;
/** 消息内容 */
@property (copy, nonatomic) NSString *messageContent;
/** 扩展内容 */
@property (copy, nonatomic) NSDictionary *extend;
/** 消息云端唯一标识 可转换为时间戳 可用于检测去除重复 */
@property (strong, nonatomic) NSNumber *identityCloud;
/** 消息云端接收时间戳 通过messageIdentityCloud转换而来 单位秒 */
@property (strong, nonatomic) NSNumber *timeStamp;
/** 消息顺序序号,用于检测是否丢消息 */
@property (strong, nonatomic) NSNumber *sequence;
/** 消息阅读标识 0表示未读,1表示已读 */
@property (strong, nonatomic) NSNumber *isRead;
/** 消息删除标识 0表示未删除,1表示已删除 */
@property (strong, nonatomic) NSNumber *isDelete;
@end

/**
 {
 "mid":165755294771576964, // 消息的ID，`(mid >> 23) + 1451577600000` 为毫秒时间戳
 "uid":1,                  // 发送消息的用户id，无符号整型
 "cid":1,                  // 消息所在的对话ID， 无符号长整型
 "type":0,                 // 消息的类型，无符号整型；范围0-255
 "txt":"text content",     // 消息的文本内容，字符串
 "ext":{"key":"value"},    // 消息的扩展数据
 "seq":1,                  // 消息的序号，实时消息无此项
 "rt": true,               // 是否实时消息，有此项且值为true则为实时消息
 }
 */
