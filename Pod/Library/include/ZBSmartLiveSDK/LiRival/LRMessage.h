//
//  LRMessage.h
//  Pods
//
//  Created by lip on 16/8/20.
//
//

#import <Foundation/Foundation.h>

@interface LRMessage : NSObject
/** 文本消息 */
@property (copy, nonatomic) NSString *content;
/**
 *  创建一条文本消息
 *
 *  @param content 消息内容
 *
 *  @return 创建好的消息
 */
+ (instancetype)messageWithContent:(NSString *)content;

// 语言消息 ...

@end
