//
//  LRTimerArrayLifecycle.h
//  Pods
//
//  Created by lip on 16/8/19.
//
//

#import <Foundation/Foundation.h>

@class LRTimerArrayLifecycleManager;

@protocol LRTimerArrayLifecycleProtocol <NSObject>
@required
/**
 *  返回超时的计时器的唯一标识
 *
 *  @warning 需要在该回调中调用''invaliTimerWithIdentity:''来释放计时器
 *
 *  @param manager  管理者
 *  @param identity 唯一标识
 */
- (void)LRTimerArrayLifecycleManager:(LRTimerArrayLifecycleManager *)manager timeOutTimer:(NSNumber *)identity;
@end

@interface LRTimerArrayLifecycleManager : NSObject
/** 代理 */
@property (weak, nonatomic) id<LRTimerArrayLifecycleProtocol> delegate;
/**
 *  通过唯一标识创建一个计时器
 *
 *  @param identity 唯一标识,计时器均为一次性,5秒的超时间隔
 */
- (void)createTimerWithIdentity:(NSNumber *)identity;
/**
 *  通过唯一标识失效一个计时器
 *
 *  @param identity 唯一标识
 */
- (void)invaliTimerWithIdentity:(NSNumber *)identity;

- (void)removeAllTimer;

- (NSUInteger)timerCount;

@end
