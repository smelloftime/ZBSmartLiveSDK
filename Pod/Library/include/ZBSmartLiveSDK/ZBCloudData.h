//
//  ZBCloudData.h
//  Pods
//
//  Created by lip on 16/7/23.
//
//

#import <Foundation/Foundation.h>

@interface ZBCloudData : NSObject
+ (void)getZBCloudDataWithApi:(NSString *)requestApi parameter:(NSDictionary *)parameter success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;

@end
