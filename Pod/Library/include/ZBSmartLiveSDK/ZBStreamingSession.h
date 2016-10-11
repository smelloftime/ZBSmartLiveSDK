//
//  ZBStreamingSession.h
//  ZhiBo
//
//  Created by app on 16/9/13.
//  Copyright © 2016年 lip. All rights reserved.
//
//  ZBStreamingSession 是一个用来进行推流的功能类。基于 ZBSmartLiveSDK 和 PLCameraStreamingKit 实现推流功能,基于`coreImage`实现滤镜效果
//  内部实现了适合弱网环境下的重连策略

#import <Foundation/Foundation.h>

/*! 初始化推流的结果 */
typedef NS_ENUM(NSUInteger, ZBStreamingInitialStatus) {
    ZBInitialStatusSuccess,      ///<  创建成功
    ZBInitialStatusFaild,        ///<  创建失败
    ZBInitialStatusLiverBeBande, ///<  主播被禁播
};

/*! 开启推流的结果 */
typedef NS_ENUM(NSUInteger, ZBStreamingStartStatus) {
    ZBStartStatusSuccess = 0,               ///< 成功开始推流
    ZBStartStatusSessionUnknownError,       ///< 发生未知错误无法启动
    ZBStartStatusSessionStillRunning,       ///< 已经在运行中，无需重复启动
    ZBStartStatusStreamURLUnauthorized,     ///< 当前的 StreamURL 没有被授权
    ZBStartStatusSessionConnectStreamError, ///< 建立 socket 连接错误
    ZBStartStatusUploadFaild                ///< 上传图片和 title 超时，推流失败
};

/*! 推流重连状态 */
typedef NS_ENUM(NSUInteger, ZBStreamingReconnectStatus) {
    ZBStreamingStatusStartReconnect,   ///< 已断开连接状态，开始重连
    ZBStreamingStatusReconnectSuccess, ///< 重连成功
    ZBStreamingStatusReconnectFaild    ///< 重连失败
};

/*! 推流连接状态 */
typedef NS_ENUM(NSUInteger, ZBStreamingStatus) {
    ZBStreamingStatusUnknow = 0,    ///< 未知状态，只会作为 init 的初始状态
    ZBStreamingStatusConnecting,    ///< 连接中状态
    ZBStreamingStatusConnected,     ///< 已连接状态
    ZBStreamingStatusDisconnecting, ///< 断开连接中状态
    ZBStreamingStatusDisconnected,  ///< 已断开连接状态
    ZBStreamingStatusReconnecting,  ///< 正在等待自动重连状态
    ZBStreamingStatuseError         ///< 错误状态
};

/*! 直播滤镜类型 */
typedef NS_ENUM(NSUInteger, ZBStreamingFilterType) {
    ZBLiveFilterTypeNone,        ///< 无
    ZBLiveFilterTypeBlack,       ///< 黑白
    ZBLiveFilterTypeNatural,     ///< 自然
    ZBLiveFilterTypeWarm,        ///< 温暖
    ZBLiveFilterTypeOldPhoto,    ///< 老照片
    ZBLiveFilterTypeFreshBreeze, ///< 小清新
    ZBLiveFilterTypeSilence,     ///< 静谧
    ZBLiveFilterTypeAutumn       ///< 秋色
};

@class ZBStreamingSession;
/**
 *  直播代理方法
 */
@protocol ZBStreamingDelegate <NSObject>

@optional
/** 直播重连状态变更的回调 
 *
 *  @warning 当重连失败时，ZBStreamingSession 会主动断开推流。
 *
 */
- (void)streamingSession:(ZBStreamingSession * _Nonnull)liveSession streamingReconnectStateDidChange:(ZBStreamingReconnectStatus)status;

/** 每 3 秒回调一次返回推流的状态 */
- (void)streamingSession:(ZBStreamingSession * _Nonnull)liveSession streamingStateDidUpload:(ZBStreamingStatus)status;
@end

@interface ZBStreamingSession : NSObject
/** 推流代理 */
@property (nonatomic, weak, nullable) id<ZBStreamingDelegate> delegate;
/** 摄像头数据预览视图
 *
 *  @warning 附加功能方法，以下方法只有在初始化直播间成功后才能调用
 */
@property (nonatomic, strong, null_resettable, readonly) UIView * liveView;
/** 滤镜类型 */
@property (nonatomic, assign) ZBStreamingFilterType filterType;

#pragma mark - 直播
#pragma mark └ 直播的生命周期

/**
 *  初始化推流,并且实例化推流核心
 *  @note 在调用本类的其他实例方法前，请一定保证 session 实例被成功的初始化了
 *
 *  @param handler 通过读取该参数的`status`来判断初始化推流状态,当初始化状态未禁播时,`message`返回解禁时间格式化后的字符串,`handler`在主线程调用,可以直接在`handler`中操作UI,
 *
 *  @note 实例化的推流核心,通过`handler`中的`instance`参数返回
 */
+ (void)initStreamingSessionWithCallBack:(void (^ _Nullable)(ZBStreamingInitialStatus status, NSString * _Nullable message, ZBStreamingSession * _Nullable instance))handler;

/**
 *  开始推流
 *
 *  @param title      直播间标题
 *  @param coverImage 直播间封面,会将图片转换为压缩后的二进制
 *  @param thum       自定义生成的缩略图大小
 *  @param handler 通过读取该参数的`status`来判断初始化推流状态,当初始化状态未禁播时,`message`返回解禁时间格式化后的字符串,`handler`在主线程调用,可以直接在`handler`中操作UI
 *
 */

- (void)startStreamingWithTitle:(NSString *)title coverImage:(UIImage *)coverImage thum:(NSString *)thum callBack:(void(^ _Nullable)(ZBStreamingStartStatus status))handler;

/** 关闭推流 */
- (void)endStreaming;

/** 获取摄像机图片 */
- (UIImage * _Nonnull )captureImage;

/** 切换摄像头 */
- (void)toggleCamera;

/** 手动聚焦 */
- (void)changFocusWithPoint:(CGPoint)focusPoint;

@end
