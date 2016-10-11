//
//  LiRivalKit.m
//  Pods
//
//  Created by lip on 16/8/11.
//
//

#import "LiRivalKit.h"
#import "LRToolbox.h"
#import "LRErrorCode.h"
#import "LRException.h"
#import "LRWebSocket.h"
#import "MPMessagePack.h"
#import "LRReachability.h"
#import "LRTimerArrayLifecycleManager.h"

const static NSTimeInterval kTimeByDefaultHeart = 200;
const static NSTimeInterval kTimeBySendPingRespond = 1; ///< 发送 PING 响应超时时长
const static NSTimeInterval ktimeByLoginRespond = 5; ///< 登录聊天服务器的响应超时时长
const static NSUInteger kSendMessageIdentity = 10000;

typedef void(^WebSocketErrorBlock)(NSError *error);
typedef void(^webSocketSuccessBlock)(NSString *success);

typedef void(^WebSocketRespondDataBlock)(NSArray *respondData,NSError *error);

@interface LiRivalKit () <
SRWebSocketDelegate,
LRTimerArrayLifecycleProtocol
>

/** socket */
@property (strong, nonatomic) LRWebSocket *webSocket;
/** 登录的协议 */
@property (strong, nonatomic) NSString *loginAgreement;
/** 登陆&&重连 聊天服务器时的错误回调 */
@property (strong, nonatomic) WebSocketErrorBlock connectionServerErrorBlock;
/** 登陆&&重连 聊天服务器时的正确回调 */
@property (strong, nonatomic) webSocketSuccessBlock connectionServerSuccessBlock;
/** 登录&&重连 服务器计时器 */
@property (strong, nonatomic) NSTimer *connectionServerTimer;
/** 心跳计时器 */
@property (strong,nonatomic) NSTimer *keepHeartbeatTimer;
/** ping 响应计时器 */
@property (strong, nonatomic) NSTimer *sendPingRespondTimer;
/** 发送消息响应计时管理 */
@property (strong, nonatomic) LRTimerArrayLifecycleManager *timerArrayManager;
/** 发送消息的 Block 字典 */
@property (strong, nonatomic) NSMutableDictionary *sendMessageBlockDic;
/** 聊天服务器的到达性 */
@property (assign, nonatomic) BOOL isReachabilityWebSocketServer;

@end

@implementation LiRivalKit
@synthesize timeByHeart = _timeByHeart;
#pragma mark - means
+ (instancetype)coreKit {
    static dispatch_once_t once;
    static LiRivalKit *coreKit;
    dispatch_once(&once, ^{
        coreKit = [[self alloc] init];
        coreKit.timerArrayManager = [[LRTimerArrayLifecycleManager alloc] init];
        coreKit.sendMessageBlockDic = [NSMutableDictionary dictionary];
        coreKit.requestType = LRRequestTypeData;
        coreKit.sendMessageIdentity = kSendMessageIdentity;
    });
    return coreKit;
}

#pragma mark - property
- (NSUInteger)sendMessageIdentity {
    return _sendMessageIdentity = _sendMessageIdentity + 1;
}

- (NSUInteger)timeByHeart {
    if (_timeByHeart == 0) {
        return kTimeByDefaultHeart;
    }
    return _timeByHeart;
}

- (void)setTimeByHeart:(NSUInteger)timeByHeart {
    _timeByHeart = timeByHeart;
    // 重新生成计时器
    if (_keepHeartbeatTimer) {
        [_keepHeartbeatTimer invalidate];
        _keepHeartbeatTimer = nil;
        [self fireTimer:self.keepHeartbeatTimer];
    }
}

#pragma mark - socket rocket lifecycle
#pragma mark └ init
- (void)initializeWithAddress:(NSString *)serverAddress token:(NSString *)token success:(void (^)(NSString *))success fail:(void (^)(NSError *))fail {
    if (serverAddress == nil || [serverAddress length] <= 0 || token == nil || [token length] <= 0) {
        if (fail) {
            fail([LRErrorCode errorCreateWithErrorCode:LRErrorCodeStatusEmptyParameter]);
        }
        return;
    }
    self.loginAgreement = [[NSString alloc] initWithFormat:@"%@?token=%@&serial=1&comprs=2",serverAddress, token];
    
    LRLog(@"聊天服务器登录协议信息:\n%@", self.loginAgreement);
    
    self.webSocket = [[LRWebSocket alloc] initWithURL:[NSURL URLWithString:self.loginAgreement]];
    self.webSocket.delegate = self;
    self.timerArrayManager.delegate = self;
    [self.webSocket open];
    self.connectionServerErrorBlock = [fail copy];
    self.connectionServerSuccessBlock = [success copy];
    [self fireTimer:self.connectionServerTimer];
    [self postChatStatueWithType:LiRivalKitStateConnection];
}

#pragma mark └ reconnection
- (void)reconnectionSuccess:(void (^)(NSString *))success fail:(void (^)(NSError *))fail {
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.webSocket = [[LRWebSocket alloc] initWithURL:[NSURL URLWithString:self.loginAgreement]];
    self.webSocket.delegate = self;
    
    self.connectionServerErrorBlock = [fail copy];
    self.connectionServerSuccessBlock = [success copy];
    [self postChatStatueWithType:LiRivalKitStateConnection];
    [self.webSocket open];
    [self fireTimer:self.connectionServerTimer];
}

#pragma mark └ release
- (void)releaseWebSocket {
    self.webSocket = nil;
    [self releaseTimer:self.keepHeartbeatTimer];
}

#pragma mark - send message
- (void)sendMessageWithMessageEvent:(NSString *)messageEvent messageBody:(id)messageBody messageIdentity:(NSNumber *)messageIdentity completion:(void (^)(NSArray *respondData, NSError *))completion {
    NSParameterAssert(messageEvent);
    NSParameterAssert(messageBody);
    NSParameterAssert(completion);
    
    if ([[LRReachability reachabilityForInternetConnection] currentReachabilityStatus] == NO) {
        completion(nil, [LRErrorCode errorCreateWithErrorCode:LRErrorCodeStatusLostNetWork]);
        return;
    }
    if (self.webSocket == nil) {
        completion(nil, [LRErrorCode errorCreateWithErrorCode:LRErrorCodeStatusLostWebSocket]);
        return;
    }
    if (self.webSocket.readyState == SR_OPEN) {
        if (messageIdentity) { // 验证是否超时
            [self.timerArrayManager createTimerWithIdentity:messageIdentity];
            [self.sendMessageBlockDic setObject:completion forKey:messageIdentity];
            [self.webSocket send:[self addRequestHead:@[messageEvent, messageBody, messageIdentity]]];
//            LRLog(@"send message\n%d%@", (int)self.requestType, [self conversionStringFromArray:@[messageEvent, messageBody, messageIdentity]]);
        } else { // 不验证是否超时
            [self.webSocket send:[self addRequestHead:@[messageEvent, messageBody]]];
            LRLog(@"send message\n%d%@", (int)self.requestType, [self conversionStringFromArray:@[messageEvent, messageBody]]);
        }
        
        if (_keepHeartbeatTimer) { // 每次发送消息 都重置一次心跳计时器
            [_keepHeartbeatTimer invalidate];
            _keepHeartbeatTimer = nil;
            [self fireTimer:self.keepHeartbeatTimer];
        } else {
            [LRException raise:@"消息核心相关错误" format:@"发送消息时,计时器没有正常工作"];
        }
    } else {
        completion(nil, [LRErrorCode errorCreateWithErrorCode:LRErrorCodeStatusLostWebSocket]);
        return;
    }
    
}

- (void)sendPing {
    if (self.webSocket.readyState == SR_OPEN) {
        [self.webSocket sendPing:nil];
        [self fireTimer:self.sendPingRespondTimer];
    } else {
        LRLog(@"发送心跳时, 链接已经被释放");
    }
}

#pragma mark - web socket delegate
#pragma mark └ web socket receive
- (void)webSocketDidOpen:(LRWebSocket *)webSocket {
    [self fireTimer:self.keepHeartbeatTimer];
    if (_connectionServerTimer) {
        [self releaseTimer:_connectionServerTimer];
    }
    self.connectionServerErrorBlock = nil;
    if (self.connectionServerSuccessBlock) {
        self.connectionServerSuccessBlock(@"Login success.");
    }
    [self postChatStatueWithType:LiRivalKitStateSuccess];
}

- (void)webSocket:(LRWebSocket *)webSocket didReceiveRespondData:(id)respondData {
    Byte respondType = [self respondDataTypeFromReadRespondData:respondData];
    if (respondType == LRRequestTypeReachabilityACK) {
        return;
    }
    NSArray *messageArray = [self respondBodyFromReadRespondData:respondData];
#if DEBUG /** 调试模式下,会收集并且打印异常消息接收 */
    @try {
#else
#endif
        if ([messageArray[0] isKindOfClass:[NSString class]] == NO) {
            LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
            [exception raise];
        }
        NSString *messageEvent = messageArray[0];
        if (respondType == LRRequestTypeData) { // 消息包 直接发送通知
            NSDictionary *userInfo = @{@"message":messageEvent, @"messageBody":messageArray[1]};
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificaitonForliRivalKitReceiveMessage object:nil userInfo:userInfo];
        }
        if (respondType == LRRequestTypeDataACK) {
            if (messageArray.count == 3) {
                NSAssert(messageArray.count == 3, @"响应数据必须含有事件,数据包和标识");
                if ([messageArray[0] isKindOfClass:[NSString class]] == NO || [messageArray[2] isKindOfClass:[NSNumber class]] == NO) {
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
                    [exception raise];
                }
                WebSocketRespondDataBlock block = [self.sendMessageBlockDic objectForKey:messageArray[2]];
                if (block) { // 如果查收到的消息编号不存在与消息字典中,就不处理
                    block(messageArray,nil);
                    [self.timerArrayManager invaliTimerWithIdentity:messageArray[2]];
                    [self.sendMessageBlockDic removeObjectForKey:messageArray[2]];
                } else {
#if DEBUG
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidArgument];
                    [exception raise];
#endif
                }
            }
        }
        if (respondType == LRRequestTypeErrorACK) {
            if (messageArray.count == 3) {
                NSAssert(messageArray.count == 3, @"响应数据必须含有事件,数据包和标识");
                if ([messageArray[0] isKindOfClass:[NSString class]] == NO || [messageArray[1] isKindOfClass:[NSDictionary class]] == NO || [messageArray[2] isKindOfClass:[NSNumber class]] == NO) {
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
                    [exception raise];
                }
                [self.timerArrayManager invaliTimerWithIdentity:messageArray[2]];
                NSDictionary *messageErrorBody = messageArray[1];
                NSArray *valus = [messageErrorBody allValues];
                WebSocketRespondDataBlock block = [self.sendMessageBlockDic objectForKey:messageArray[2]];
                if (block) { // 如果查收到的消息编号不存在与消息字典中,就不处理
                    if (valus.count == 1) { // 数据包 不一定含有 错误信息("msg")字段
                        block(nil, [LRErrorCode errorCreateWithCoustomDomain:@"WebSocketErorDomain" errorCode:[messageErrorBody[@"code"] unsignedIntegerValue] description:@"server don't have error info"]);
                    } else {
                        NSError *error = [NSError errorWithDomain:@"WebSocketErorDomain" code:[messageErrorBody[@"code"] unsignedIntegerValue] userInfo:messageErrorBody];
                        block(nil, error);
                    }
                    [self.sendMessageBlockDic removeObjectForKey:messageArray[2]];
                } else {
#if DEBUG
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidArgument];
                    [exception raise];
#endif
                }
            }
        }
#if DEBUG
    }
    @catch (NSException *exception) {
        LRLog(@"%@", exception);
        LRLog(@"did recevice error data is %@", messageArray);
    }
    @finally {
    }
#else
#endif
}

- (void)webSocket:(LRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    if (_sendPingRespondTimer) {
        [self releaseTimer:_sendPingRespondTimer];
    }
    [self postChatStatueWithType:LiRivalKitStateSuccess];
}

#pragma mark └ error and close
- (void)webSocket:(LRWebSocket *)webSocket didFailWithError:(NSError *)error {
    LRLog(@"LiRivalKit did fail with %@", [error debugDescription]);
    [self releaseWebSocket];
    [self postChatStatueWithType:LiRivalKitStateFail];
}

- (void)webSocket:(LRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSString *errorInfo = [self errorCodeConvertToErrorString:code];
    LRLog(@"LiRivalKit did close with %@", errorInfo);
    [self releaseWebSocket];
    [self postChatStatueWithType:LiRivalKitStateFail];
}

#pragma mark - request/respond head
- (NSData *)addRequestHead:(NSArray *)messageBody {
    NSData *requestBody = [MPMessagePackWriter writeObject:messageBody error:nil];
    Byte packType = self.requestType; //  2表示发消息
    Byte sType = 1; // 1表示maspack  0表示json
    Byte zlib = 0; //   0表示未压缩 1表示 deflate 压缩 2表示 zlib 压缩 3 表示 gzip 压缩
    if (requestBody.length > 1024) { // 如果数据大于1kb 进行压缩
        requestBody = [LRToolbox compressDataByZlib:requestBody];
        zlib = 2;
    }
    
    Byte result = (packType<<4)|(sType<<2)|(zlib<<2);
    const unsigned char bytes[] = {result};
    NSData *firstByte = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSMutableData *allData = [[NSMutableData alloc] initWithData:firstByte];
    
    [allData appendData:requestBody];
    return allData;
}

- (Byte)respondDataTypeFromReadRespondData:(id)respondData {
    NSData *firestData = [respondData subdataWithRange:NSMakeRange(0, 1)];
    unsigned char *bytePtr = (unsigned char *)[firestData bytes];
    Byte firestByte = bytePtr[0];
    Byte respondType = firestByte>>4;
    return respondType; // 1 服务器 PONG 客户端, 2 消息类, 3 应答类, 4 错误信息应答
}

- (NSArray *)respondBodyFromReadRespondData:(id)respondData {
    NSData *bodyData = [respondData subdataWithRange:NSMakeRange(1, [respondData length] - 1)];
    NSData *firestData = [respondData subdataWithRange:NSMakeRange(0, 1)];
    unsigned char *bytePtr = (unsigned char *)[firestData bytes];
    Byte firestByte = bytePtr[0];
    Byte c = 2&firestByte;
    if (c != 0) { // 数据经过了压缩
        bodyData = [LRToolbox decompressZlibData:bodyData];
    }
    
    NSArray *bodyArray = [MPMessagePackReader readData:bodyData error:nil];
    return bodyArray;
}

#pragma mark └ config web socket
- (BOOL)webSocketShouldConvertTextFrameToString:(LRWebSocket *)webSocket {
    return NO;
}

- (NSString *)errorCodeConvertToErrorString:(NSInteger)code {
    switch (code) {
            // 0–999: Reserved and not used.
        case 1000:
            return @"SRStatusCodeNormal";
            break;
        case 1001:
            return @"SRStatusCodeGoingAway";
            break;
        case 1002:
            return @"SRStatusCodeProtocolError";
            break;
        case 1003:
            return @"SRStatusCodeUnhandledType";
            break;
            // 1004 reserved.
        case 1005:
            return @"SRStatusNoStatusReceived";
            break;
        case 1006:
            return @"SRStatusCodeAbnormal";
            break;
        case 1007:
            return @"SRStatusCodeInvalidUTF8";
            break;
        case 1008:
            return @"SRStatusCodePolicyViolated";
            break;
        case 1009:
            return @"SRStatusCodeMessageTooBig";
            break;
        case 1010:
            return @"SRStatusCodeMissingExtension";
            break;
        case 1011:
            return @"SRStatusCodeInternalError";
            break;
        case 1012:
            return @"SRStatusCodeServiceRestart";
            break;
        case 1013:
            return @"SRStatusCodeTryAgainLater";
            break;
            // 1014: Reserved for future use by the WebSocket standard.
        case 1015:
            return @"SRStatusCodeTLSHandshake";
            break;
            // 1016–1999: Reserved for future use by the WebSocket standard.
            // 2000–2999: Reserved for use by WebSocket extensions.
            // 3000–3999: Available for use by libraries and frameworks. May not be used by applications. Available for registration at the IANA via first-come, first-serve.
            // 4000–4999: Available for use by applications.
        default:
            return [NSString stringWithFormat:@"Reserved and not used code is :%d", (int)code];
            break;
    }
}

#pragma mark - LR timer
- (void)LRTimerArrayLifecycleManager:(LRTimerArrayLifecycleManager *)manager timeOutTimer:(NSNumber *)identity {
    WebSocketRespondDataBlock block = [self.sendMessageBlockDic objectForKey:identity];
    [self.timerArrayManager invaliTimerWithIdentity:identity];
    block(nil, [LRErrorCode errorCreateWithErrorCode:LRErrorCodeStatusSendIMTimeout]);
    [self.sendMessageBlockDic removeObjectForKey:identity];
}

#pragma mark - other
- (NSString *)conversionStringFromArray:(NSArray *)array {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

#pragma mark - notification
- (void)postChatStatueWithType:(LiRivalKitState)statue {
    NSDictionary *userInfo = @{@"statue":@(statue)};
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificaitonForliRivalKitStatueChange object:nil userInfo:userInfo];
}

#pragma mark - timer
#pragma mark └ timer lazy load
- (NSTimer *)connectionServerTimer {
    if (_connectionServerTimer == nil) {
        _connectionServerTimer = [NSTimer timerWithTimeInterval:ktimeByLoginRespond target:self selector:@selector(connectionServerTimeOver) userInfo:nil repeats:NO];
    }
    return _connectionServerTimer;
}

- (NSTimer *)sendPingRespondTimer {
    if (_sendPingRespondTimer == nil) {
        _sendPingRespondTimer = [NSTimer timerWithTimeInterval:kTimeBySendPingRespond target:self selector:@selector(sendPingRespondTimeOver) userInfo:nil repeats:NO];
    }
    return _sendPingRespondTimer;
}

- (NSTimer *)keepHeartbeatTimer {
    if (_keepHeartbeatTimer == nil) {
        _keepHeartbeatTimer = [NSTimer timerWithTimeInterval:self.timeByHeart target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    }
    return _keepHeartbeatTimer;
}

#pragma mark └ timer over means
- (void)connectionServerTimeOver {
    [self releaseTimer:_connectionServerTimer];
    self.connectionServerSuccessBlock = nil;
    if (self.connectionServerErrorBlock) {
        self.connectionServerErrorBlock([LRErrorCode errorCreateWithErrorCode:LRErrorCodeStatusSendIMTimeout]);
    }
    [self releaseWebSocket];
}

- (void)sendPingRespondTimeOver {
    [self releaseTimer:_sendPingRespondTimer];
    [self postChatStatueWithType:LiRivalKitStateFail];
    LRLog(@"LiRivalKit did fail with Error Domain=LiRivalKitLinkError Code=0000 \"Operation timed out\"");
    [self releaseWebSocket];
}

#pragma mark └ timer lifecycle
- (void)fireTimer:(NSTimer *)timer {
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)releaseTimer:(NSTimer *)timer {
    [timer invalidate];
    timer = nil;
}

@end
