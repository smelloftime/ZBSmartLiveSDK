//
//  NSTimer+lifecycle.h
//  Pods
//
//  Created by lip on 16/8/19.
//
//
/**
 1. 管理计时器的生命周期
 * 生成计时器
 * 开启计时器
 * 释放计时器
 2. 存放计时器
 * 给计时器打上编号 然后 生成 计时器 惠存起来成计时器组
 * 计时器组 的生命周期维护
 *
 */

#import <Foundation/Foundation.h>

void loadLifecycleCategory();

@interface NSTimer (lifecycle)

@end
