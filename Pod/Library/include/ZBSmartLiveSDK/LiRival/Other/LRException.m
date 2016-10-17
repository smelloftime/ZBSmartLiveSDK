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
NSString * const LRInvalidConversionError = @"LRInvalidConversionError";

@implementation LRException

+ (instancetype)raiseWithLRExceptionCode:(LRExceptionCode)exceptionCode {
    NSDictionary *exceptionDic = @{
                               @(101): @[LRInvalidArgumentException, @"Unrecognized data Argument"],
                               @(102): @[LRInvalidArgumentException, @"Unrecognized data class"],
                               @(103): @[LRInvalidArgumentException, @"Conversion error"],
                               };
    NSArray *exceptionArray = exceptionDic[@(exceptionCode)];
    NSParameterAssert(exceptionArray);
    return (LRException *)[self exceptionWithName:exceptionArray[0] reason:exceptionArray[1] userInfo:nil];
}

@end
