//
//  ZBChatroom.m
//  Pods
//
//  Created by lip on 16/8/24.
//
//

#import "ZBChatroom.h"
#import "LiRivalKit.h"
#import "ZBConversationEvent.h"
#import "LRException.h"
#import "ZBErrorCode.h"
#import "ZBMessageModel.h"
#import "ZBApplicationCenter.h"
#import "ZBCloudData.h"
#import "MJExtension/MJExtension.h"

@interface ZBChatroom () <
    LiRivalKitDelegate
>
/** 聊天核心 */
@property (weak, nonatomic) LiRivalKit *liRivalKit;

@end

@implementation ZBChatroom

- (instancetype)init {
    if (self = [super init]) {
        self.liRivalKit = [LiRivalKit coreKit];
        self.liRivalKit.delegate = self;
    }
    return self;
}

- (void)joinChatroom:(NSNumber *)chatroomID password:(NSString *)password completion:(void (^)(id, NSError *))completion {
    NSDictionary *messageBody = nil;
    if (password) {
        messageBody = @{@"cid": chatroomID, @"pwd": password};
    } else {
        messageBody = @{@"cid": chatroomID};
    }
    
    if (chatroomID == nil) {
        completion(nil, [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
    }
    
    [self.liRivalKit sendMessageWithMessageEvent:ZBConversationEventChatroomJoin messageBody:messageBody messageIdentity:@(self.liRivalKit.sendMessageIdentity) completion:^(NSArray *respondData, NSError *error) {
        if (completion) {
            if (error) {
                completion(nil, error);
            } else {
                if ([respondData[0] isEqualToString:ZBConversationEventChatroomJoin]) {
                    [ZBApplicationCenter defaultCenter].chatroomIdentity = chatroomID;
                    completion(respondData[1], nil);
                } else {
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidArgument];
                    [exception raise];
                }
            }
        }
    }];
}

- (void)disableChatroomUserIdentity:(NSString *)userIdentity sendMessageWithTime:(NSUInteger)disableTime completion:(void(^)(id respondData, NSError *error))completion {
    if (userIdentity == nil) {
        completion(nil, [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        return;
    }
    if (disableTime == 0) {
        [ZBCloudData getZBCloudDataWithApi:@"ZBCloud_Im_Stream_Disable" parameter:@{@"usid": userIdentity, @"time": @(disableTime)} success:^(id data) {
            completion(data, nil);
        } fail:^(NSError *fail) {
            completion(nil, fail);
        }];
        return;
    }
    NSUInteger disableTimestamp = (long)[[NSDate date] timeIntervalSince1970];
    disableTimestamp += disableTime;
    [ZBCloudData getZBCloudDataWithApi:@"ZBCloud_Im_Stream_Disable" parameter:@{@"usid": userIdentity, @"time": @(disableTimestamp)} success:^(id data) {
        completion(data, nil);
    } fail:^(NSError *fail) {
        completion(nil, fail);
    }];
}

- (void)enableChatroomUserIdentity:(NSString *)userIdentity sendMessageCompletion:(void(^)(id respondData, NSError *error))completion {
    if (userIdentity == nil) {
        completion(nil, [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusUnInitialize]);
        return;
    }
    [ZBCloudData getZBCloudDataWithApi:@"ZBCloud_Im_Stream_Enable" parameter:@{@"usid": userIdentity} success:^(id data) {
        completion(data, nil);
    } fail:^(NSError *fail) {
        completion(nil, fail);
    }];
}

- (void)getChatroom:(NSNumber *)chatroomID viewerCountCompletion:(void (^)(id, NSError *))completion {
    if (chatroomID == nil) {
        completion(nil, [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
    }
    
    NSDictionary *messageBody = @{@"cid": chatroomID, @"field": @"mc"};
    
    [self.liRivalKit sendMessageWithMessageEvent:ZBConversationEventGetConversationDetailInfo messageBody:messageBody messageIdentity:@(self.liRivalKit.sendMessageIdentity) completion:^(NSArray *respondData, NSError *error) {
        if (completion) {
            if (error) {
                completion(nil, error);
            } else {
                if ([respondData[0] isEqualToString:ZBConversationEventGetConversationDetailInfo]) {
                    completion(respondData[1], nil);
                } else {
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidArgument];
                    [exception raise];
                }
            }
        }
    }];
}

- (void)leaveChatroom:(NSNumber *)chatroomID password:(NSString *)password completion:(void (^)(id, NSError *))completion {
    NSDictionary *messageBody = nil;
    if (password) {
        messageBody = @{@"cid": chatroomID, @"pwd": password};
    } else {
        messageBody = @{@"cid": chatroomID};
    }
    
    if (chatroomID == nil) {
        completion(nil, [ZBErrorCode errorCreateWithErrorCode:ZBErrorCodeStatusEmptyParameter]);
    }
    
    ZBMessageModel *messageModel = [[ZBMessageModel alloc] init];
    messageModel.conversationIdentity = chatroomID;
    messageModel.type = @(ZBMessageModelTypeCoustomAvailable);
    NSString *ZBUSID = [ZBApplicationCenter defaultCenter].userAuthenticityModel.businessUserIdentity;
    messageModel.extend = @{@"ZBUSID": ZBUSID, @"customID" : @(50400)};
    
    [self.liRivalKit sendMessageWithMessageEvent:ZBConversationEventChatroomLeave messageBody:messageBody messageIdentity:@(self.liRivalKit.sendMessageIdentity) completion:^(NSArray *respondData, NSError *error) {
        if (completion) {
            if (error) {
                completion(nil, error);
            } else {
                if ([respondData[0] isEqualToString:ZBConversationEventChatroomLeave]) {
                    completion(respondData[1], nil);
                } else {
                    LRException *exception = [LRException raiseWithLRExceptionCode:LRExceptionInvalidArgument];
                    [exception raise];
                }
            }
        }
    }];
}

@end
