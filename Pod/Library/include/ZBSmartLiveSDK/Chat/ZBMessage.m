//
//  ZBMessage.m
//  Pods
//
//  Created by lip on 16/8/24.
//
//

#import "ZBMessage.h"

@implementation ZBMessage

- (NSString *)description {
    if (self.extend) {
        return [NSString stringWithFormat:@"fromUserIdentity:%@,messageContent:%@,messageType:%d.isRealTime:%d,extend:%@,extendCode:%d", self.fromUserIdentity, self.messageContent, (int)self.messageType, self.isRealTime, self.extend, (int)self.extendCode];
    } else {
        return [NSString stringWithFormat:@"fromUserIdentity:%@,messageContent:%@,messageType:%d.isRealTime:%d", self.fromUserIdentity, self.messageContent, (int)self.messageType, self.isRealTime];
    }
}

@end
