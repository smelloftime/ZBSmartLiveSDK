//
//  ZBMessageModel.m
//  Pods
//
//  Created by lip on 16/8/24.
//
//

#import "ZBMessageModel.h"
#import "MJExtension.h"

@implementation ZBMessageModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"conversationIdentity": @"cid",
             @"targetArray": @"to",
             @"senderIdentity": @"uid",
             @"realTime": @"rt",
             @"messageContent": @"txt",
             @"extend" : @"ext",
             @"identityCloud":@"mid",
             @"sequence": @"seq"};
}

@end
