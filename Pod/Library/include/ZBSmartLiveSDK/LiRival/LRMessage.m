//
//  LRMessage.m
//  Pods
//
//  Created by lip on 16/8/20.
//
//

#import "LRMessage.h"

@implementation LRMessage
+ (instancetype)messageWithContent:(NSString *)content {
    LRMessage *message = [[self alloc] init];
    message.content = content;
    return message;
}

@end
