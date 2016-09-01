//
//  LRException.m
//  Pods
//
//  Created by lip on 16/8/18.
//
//

#import "LRException.h"

/***************	LiRival Generic Exception names		***************/

NSString * const LRGenericException = @"LRGenericException";
NSString * const LRInvalidArgumentException = @"LRInvalidArgumentException";

@implementation LRException

+ (instancetype)raiseWithLRExceptionCode:(LRExceptionCode)exceptionCode {
    NSDictionary *exceptionDic = @{
                               @(101): @[LRInvalidArgumentException, @"Unrecognized data Argument"],
                               @(102): @[LRInvalidArgumentException, @"Unrecognized data class"],
                               };
    NSArray *exceptionArray = exceptionDic[@(exceptionCode)];
    NSParameterAssert(exceptionArray);
    return (LRException *)[self exceptionWithName:exceptionArray[0] reason:exceptionArray[1] userInfo:nil];
}

@end
