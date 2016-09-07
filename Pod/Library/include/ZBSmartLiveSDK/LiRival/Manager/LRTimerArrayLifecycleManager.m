//
//  LRTimerArrayLifecycle.m
//  Pods
//
//  Created by lip on 16/8/19.
//
//

#import "LRTimerArrayLifecycleManager.h"
#import "LRException.h"

@interface LRTimerArrayLifecycleManager ()
/** 计时器字典 */
@property (strong, nonatomic) NSMutableDictionary *timerDictionary;

@end

@implementation LRTimerArrayLifecycleManager
- (NSMutableDictionary *)timerDictionary {
    if (_timerDictionary == nil) {
        _timerDictionary = [NSMutableDictionary dictionary];
    }
    return _timerDictionary;
}

- (void)createTimerWithIdentity:(NSNumber *)identity {
    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(timeout:) userInfo:identity repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self.timerDictionary setObject:timer forKey:identity];
}

- (void)invaliTimerWithIdentity:(NSNumber *)identity {
    if (self.timerCount == 0) {
        [LRException raiseWithLRExceptionCode:LRExceptionInvalidArgument];
    }
    [self removeTimerWithIdentity:identity];
}

- (void)timeout:(NSTimer *)timer {
    if ([self.delegate respondsToSelector:@selector(LRTimerArrayLifecycleManager:timeOutTimer:)]) {
        [self.delegate LRTimerArrayLifecycleManager:self timeOutTimer:timer.userInfo];
    }
}

- (void)removeTimerWithIdentity:(NSNumber *)identity {
    if (self.timerDictionary[identity]) {
        NSTimer *timerInDic = [self.timerDictionary objectForKey:identity];
        [timerInDic invalidate];
        [self.timerDictionary removeObjectForKey:identity];
    }
}

- (void)removeAllTimer {
    if (self.timerDictionary.count == 0) {
        return;
    }
    for (NSNumber *key in self.timerDictionary) {
        NSTimer *timer = self.timerDictionary[key];
        [timer invalidate];
    }
    [self.timerDictionary removeAllObjects];
}

- (NSUInteger)timerCount {
    return self.timerDictionary.count;
}

@end
