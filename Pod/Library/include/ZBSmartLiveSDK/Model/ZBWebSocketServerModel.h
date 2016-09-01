//
//  ZBWebSocketServerModel.h
//  Pods
//
//  Created by lip on 16/8/26.
//
//

#import <Foundation/Foundation.h>

@interface ZBWebSocketServerModel : NSObject
/** 公网地址 */
@property (copy, nonatomic) NSString *extranet;
/** 内网地址 */
@property (copy, nonatomic) NSString *intranet;

@end
