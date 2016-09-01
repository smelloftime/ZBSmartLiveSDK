//
//  ZBChat.m
//  Pods
//
//  Created by lip on 16/8/24.
//
//

#import "ZBChat.h"
#import "LiRivalKit.h"
#import "ZBConversationEvent.h"
#import "LRException.h"
#import "ZBMessageModel.h"
#import "ZBPrefix.h"
#import "ZBErrorCode.h"
#import "ZBApplicationCenter.h"

#import "MJExtension/MJExtension.h"
#import "AFNetworking/AFNetworkReachabilityManager.h"

#define kReconnectAtFirstDistance 1
#define kReconnectFinallyDistance 2.5
#define kRepetitionMessageCount 100

@interface ZBChat () <
    LiRivalKitDelegate
>
/** 聊天核心 */
@property (strong, nonatomic) LiRivalKit *liRivalKit;
/** 重连的状态 */
@property (assign, nonatomic) BOOL isConnection;
/** 重连计时器 */
@property (strong, nonatomic) NSTimer *reconnectTimer;
/** 重连计数器 */
@property (assign, nonatomic) NSUInteger reconnectTimes;
/** 最近50条消息唯一标识组成的数组 */
@property (strong, nonatomic) NSMutableArray *messageIdentityArray;
/** 聊天室收到消息的最新序列号 */
@property (strong, nonatomic) NSNumber *chatroomNowMessageSequence;

@end

@implementation ZBChat
#pragma mark - property
- (NSMutableArray *)messageIdentityArray {
    if (_messageIdentityArray == nil) {
        _messageIdentityArray = [NSMutableArray array];
    }
    return _messageIdentityArray;
}

#pragma mark - initialize
+ (void)initialize {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (instancetype)init {
    if (self = [super init]) {
        self.liRivalKit = [LiRivalKit coreKit];
        self.liRivalKit.delegate = self;
        self.isConnection = NO;
    }
    return self;
}

#pragma mark - reconnect
/// 开始重连
- (void)reconnectLiRivalKit {
    if (self.isConnection == NO) { // 如果在重连中 就不要继续开始重连了
        self.isConnection = YES;
        self.reconnectTimer = [NSTimer timerWithTimeInterval:kReconnectAtFirstDistance target:self selector:@selector(celerityReconnect) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.reconnectTimer forMode:NSRunLoopCommonModes];
    }
}

/// 快速重连
- (void)celerityReconnect {
    self.reconnectTimes = self.reconnectTimes + 1;
    if (self.reconnectTimes == 5) { // 计算,如果调用了5次这个方法,就切换到另一种重连方式中
        [self longReconnect];
        return;
    }
    [self reconnectioning];
}

/**
 *  长久的慢速重连
 *
 *  @note 当进入长久的慢速重连后,会将聊天室序列号置空,避免重连成功后,抓取大量丢失的聊天信息
 *
 */
- (void)longReconnect {
    if ([self.delegate respondsToSelector:@selector(chat:connectionStateDidChange:)]) {
        [self.delegate chat:self connectionStateDidChange:ZBChatStateReconnection];
    }
    self.chatroomNowMessageSequence = nil;
    [self.reconnectTimer invalidate];
    self.reconnectTimer = nil;
    self.reconnectTimer = [NSTimer timerWithTimeInterval:kReconnectFinallyDistance target:self selector:@selector(reconnectioning) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.reconnectTimer forMode:NSRunLoopCommonModes];
}

/// 让核心重连
- (void)reconnectioning {
    [self.liRivalKit reconnectionSuccess:nil fail:nil];
}

/// 结束重连
- (void)stopReconnectLiRivalKit {
    self.isConnection = NO;
    if (self.reconnectTimer) {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
    }
    if ([self.delegate respondsToSelector:@selector(chat:connectionStateDidChange:)]) {
        [self.delegate chat:self connectionStateDidChange:ZBChatStateSuccess];
    }
}

- (void)reconnectionSuccess:(void (^)(NSString *))success fail:(void (^)(NSError *))fail {
    [self.liRivalKit reconnectionSuccess:success fail:fail];
}

#pragma mark - send message
- (void)sendMessage:(ZBMessage *)message toConversation:(NSNumber *)conversationIdentity completion:(void (^)(id, NSError *))completion {
    // 转换 消息为 标准样式 然后 发给服务器
    if (message == nil || conversationIdentity == nil) {
        completion(nil, [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
    }
    ZBMessageModel *messageModel = [self conversionMessage:message conversation:conversationIdentity completion:completion];
    if (messageModel == nil) {
        return;
    }
    NSDictionary *messageBody = [NSDictionary dictionaryWithDictionary:[messageModel mj_keyValues]];
    [self.liRivalKit sendMessageWithMessageEvent:ZBConversationEventMessage messageBody:messageBody messageIdentity:@(self.liRivalKit.sendMessageIdentity) completion:^(NSArray *respondData, NSError *error) {
        if (completion) {
            if (error) {
                completion(nil, error);
            } else {
                if ([respondData[0] isEqualToString:ZBConversationEventMessage]) {
                    completion(respondData[1], nil);
                } else {
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidArgument];
                    [exception raise];
                }
            }
        }
    }];
}

#pragma mark - complete complement message
- (void)getMissingMessageWithLastSeq:(NSNumber *)lastSeq nowSeq:(NSNumber *)nowSeq {
    // 当获取到缺失部分的数据后,去重
    NSNumber *chatroomIdentity = [ZBApplicationCenter defaultCenter].chatroomIdentity;
    NSDictionary *messageBody = @{@"cid": chatroomIdentity, @"gt": lastSeq, @"lt": nowSeq};
    [self.liRivalKit sendMessageWithMessageEvent:ZBConversationEventGetMessage messageBody:messageBody messageIdentity:@(self.liRivalKit.sendMessageIdentity) completion:^(NSArray *respondData, NSError *error) {
            if (error) {
                ZBLog(@"%@", [error debugDescription]);
            } else {
                if ([respondData[0] isEqualToString:ZBConversationEventGetMessage]) {
                    for (NSDictionary *messageDic in respondData[1]) {
                        ZBMessageModel *messageModel = [ZBMessageModel mj_objectWithKeyValues:messageDic];
                        for (NSNumber *identity in self.messageIdentityArray) { // 最近100条的消息去重
                            if (identity == messageModel.identityCloud) {
                                return;
                            }
                        }
                        
                        if (self.messageIdentityArray.count > kRepetitionMessageCount) {
                            [self.messageIdentityArray removeObjectAtIndex:0];
                        }
                        [self.messageIdentityArray addObject:messageModel.identityCloud];
                        
                        [self raiseMessageToDelegate:messageModel];
                    }
                } else {
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidArgument];
                    [exception raise];
                }
            }
    }];
    
}

#pragma mark └ delegate
- (void)liRivalKit:(LiRivalKit *)liRivalKit connectionStateDidChange:(LiRivalKitState)connectionState {
    AFNetworkReachabilityStatus networkStatys = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (connectionState == LiRivalKitStateFail && ((networkStatys == AFNetworkReachabilityStatusReachableViaWWAN) || (networkStatys == AFNetworkReachabilityStatusReachableViaWiFi))) {
        [self reconnectLiRivalKit];
    }
    if (connectionState == LiRivalKitStateSuccess) {
        [self stopReconnectLiRivalKit];
    }
    if (connectionState == LiRivalKitStateFail && (networkStatys == AFNetworkReachabilityStatusNotReachable)) {
        if ([self.delegate respondsToSelector:@selector(chat:connectionStateDidChange:)]) {
            [self.delegate chat:self connectionStateDidChange:ZBChatStateNetworkFail];
        }
    }
}

- (void)liRivalKit:(LiRivalKit *)liRivalKit didReceiveMessageEvent:(NSString *)messageEvent messageBody:(id)messageBody {
    if ([messageEvent isEqualToString:ZBConversationEventMessage]) {
        ZBMessageModel *messageModel = [ZBMessageModel mj_objectWithKeyValues:messageBody];
        for (NSNumber *identity in self.messageIdentityArray) { // 最近100条的消息去重
            if (identity == messageModel.identityCloud) {
                return;
            }
        }
        
        if (self.messageIdentityArray.count > kRepetitionMessageCount) {
            [self.messageIdentityArray removeObjectAtIndex:0];
        }
        [self.messageIdentityArray addObject:messageModel.identityCloud];
        
        [self raiseMessageToDelegate:messageModel];
        
        NSNumber *chatroomIdentity = [ZBApplicationCenter defaultCenter].chatroomIdentity;
        /** 消息必答的逻辑
         记录收到消息的序列号,当下次收到消息后,更新序列号.
         如果序列号增加了一位就表示消息未丢失,如果序列号增加大于1,就去服务器获取缺少的消息
         */
        if ([messageModel.realTime  isEqualToNumber:@(1)]) { // 消息的类型是 RT 就不走必答逻辑
            // 判断如果是聊天室 就更新 聊天室最新消息的序列号
            if ([messageModel.conversationIdentity isEqualToNumber:chatroomIdentity]) {
                if (self.chatroomNowMessageSequence != nil) {
                    // 如果大于 且 是有序增长 就啥也不干了
                    int sequenceResult = [messageModel.sequence intValue] - [self.chatroomNowMessageSequence intValue];
                    if (sequenceResult > 1) { // 向服务器发送 缺失的部分 数据请求
                        [self getMissingMessageWithLastSeq:self.chatroomNowMessageSequence nowSeq:messageModel.sequence];
                    } // 如果是小于或者等于 1 就啥也不干 因为已经丢出去 和去除重复了
                }
                self.chatroomNowMessageSequence = messageModel.sequence;
            } else {
                LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
                [exception raise]; // TODO: 如果不是聊天室,就查询数据库,存储数据库等操作.暂无
            }
        }
    }
#if DEBUG
    else {
        LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
        [exception raise];
    }
#else
#endif
}

- (ZBMessageModel *)conversionMessage:(ZBMessage *)message conversation:(NSNumber *)conversationIdentity     completion:(void (^)(id, NSError *))completion {
    ZBMessageModel *model = [[ZBMessageModel alloc] init];
    model.conversationIdentity = conversationIdentity;
    model.type = @(message.messageType);
    model.messageContent = message.messageContent;
    model.realTime = @(message.isRealTime);
    if (message.fromUserIdentity == nil) {
        completion(nil, [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
        return nil;
    }
    if (message.extend) {
        model.extend = @{@"ZBUSID": message.fromUserIdentity, @"custom": message.extend, @"customID": @(message.extendCode)};
    } else {
        model.extend = @{@"ZBUSID": message.fromUserIdentity};
    }
    return model;
}

- (void)raiseMessageToDelegate:(ZBMessageModel *)messageModel {
    if ([self.delegate respondsToSelector:@selector(chat:didReceiveMessage:)]) {
        ZBMessage *message = [[ZBMessage alloc] init];
        message.fromUserIdentity = messageModel.extend[@"ZBUSID"];
        message.messageContent = messageModel.messageContent;
        message.messageType = [messageModel.type intValue];
        message.extend = messageModel.extend[@"custom"];
        message.extendCode = [messageModel.extend[@"customID"] unsignedIntegerValue];
        [self.delegate chat:self didReceiveMessage:message];
    }
}

@end
