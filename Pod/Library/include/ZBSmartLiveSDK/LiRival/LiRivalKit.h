//
//  LiRivalKit.h
//  Pods
//
//  Created by lip on 16/8/11.
//
//  LiRival通讯核心,负责和服务器收发聊天消息

#import <Foundation/Foundation.h>

/** 通信核心接收到消息后,会发送通知 */
#define NotificaitonForliRivalKitReceiveMessage @"NotificaitonForliRivalKitReceiveMessage"
/** 通信核心和通信服务器连接状态发生改变时,会发送该通知 */
#define NotificaitonForliRivalKitStatueChange @"NotificaitonForliRivalKitStatueChange"

typedef NS_ENUM(NSInteger, LiRivalKitState) {
    LiRivalKitStateConnection = 0,  ///< 链接服务器
    LiRivalKitStateSuccess = 1,   ///< 链接服务器成功
    LiRivalKitStateFail = 2,  ///< 链接服务器失败
};

typedef NS_ENUM(NSInteger, LRRequestType) {
    LRRequestTypeReachability = 0, ///< 检测服务器和客户端的连接性
    LRRequestTypeReachabilityACK = 1, ///< 服务器响应连接性
    LRRequestTypeData = 2, ///< 消息类型数据包
    LRRequestTypeDataACK = 3, ///< 服务器响应数据包
    LRRequestTypeErrorACK = 4 ///< 服务器响应错误信息
};

@interface LiRivalKit : NSObject
/** 心跳时间间隔设置 默认是240秒 */
@property (assign, nonatomic) NSUInteger timeByHeart;
/** 发送数据超时时间 默认是5秒 (暂不支持修改) */
//@property (assign, nonatomic) NSUInteger timeBySendData;
/** 请求数据类型设置,默认是 LRRequestTypeData */
@property (assign, nonatomic) LRRequestType requestType;
/** 自增长的数据 */
@property (assign, nonatomic) NSUInteger sendMessageIdentity;

/**
 *  获取单例的方法
 *
 *  @warning 请勿使用别的方式生成,会出现各种异常错误
 *
 *  @return 管理 LiRival 的单例
 */
+ (instancetype)coreKit;

/**
 *  通过服务器地址和口令链接服务器
 *
 *  @warning 该方法只能调用一次,不可使用该方法进行重连,会导致异常或者崩溃
 *
 *  @param serverAddress 服务器地址
 *  @param token         服务器指定的口令
 *  @param completion    链接服务器时的结果
 */
- (void)initializeWithAddress:(NSString *)serverAddress token:(NSString *)token success:(void(^)(NSString *successInfo))success fail:(void(^)(NSError *error))fail;

/**
 *  重新链接服务器
 *
 *  @param success 重连成功的回调
 *  @param fail    重连失败的回调
 */
- (void)reconnectionSuccess:(void(^)(NSString *successInfo))success fail:(void(^)(NSError *error))fail;

/**
 *  发送消息
 *
 *  @param messageEvent    消息事件名
 *  @param messageBody     消息体
 *  @param messageIdentity 消息本地唯一标识,验证是否超时,可以为空
 *  @param completion      错误信息,如果错误为空表示正常发送出
 */
- (void)sendMessageWithMessageEvent:(NSString *)messageEvent messageBody:(id)messageBody messageIdentity:(NSNumber *)messageIdentity completion:(void(^)(NSArray *respondData, NSError *error))completion;
@end
