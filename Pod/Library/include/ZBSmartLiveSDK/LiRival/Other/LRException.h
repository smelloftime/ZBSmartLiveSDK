//
//  LRException.h
//  Pods
//
//  Created by lip on 16/8/18.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LRExceptionCode) {
    LRExceptionInvalidArgument = 101,    ///< 不可识别的参数
    LRExceptionInvalidClass = 102,    ///< 不可识别的类型
    LRExceptionInvalidConversionError = 103 ///< 错误的转换
};

@interface LRException : NSException

+ (instancetype)raiseWithLRExceptionCode:(LRExceptionCode)exceptionCode;

@end
