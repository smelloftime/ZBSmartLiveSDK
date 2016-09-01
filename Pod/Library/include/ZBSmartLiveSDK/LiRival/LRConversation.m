//
//  LRConversation.m
//  Pods
//
//  Created by lip on 16/8/20.
//
//

#import "LRConversation.h"

@implementation LRConversation

+ (instancetype)conversationWithIdentity:(NSString *)identity type:(LRConversationType)type {
    LRConversation *conversation = [[LRConversation alloc] init];
    conversation.identity = identity;
    conversation.conversationType = type;
    return conversation;
}

@end
