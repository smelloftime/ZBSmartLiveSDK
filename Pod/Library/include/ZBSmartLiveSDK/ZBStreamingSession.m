//
//  ZBStreamingSession.m
//  ZhiBo
//
//  Created by app on 16/9/13.
//  Copyright © 2016年 lip. All rights reserved.
//

#import "ZBStreamingSession.h"
#import "ZBStreamingRequestManager.h"

#import <PLCameraStreamingKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ZBStreamingSession ()<CLLocationManagerDelegate,PLCameraStreamingSessionDelegate, PLStreamingSendingBufferDelegate>

/** 位置信息管理 */
@property (strong, nonatomic) CLLocationManager *locationManager;
/** 位置信息 */
@property (strong, nonatomic) CLLocation *location;
/** 推流核心 */
@property (nonatomic, strong) PLCameraStreamingSession  *session;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
/** 推流 ID */
@property (nonatomic, copy) NSString *streamID;
/** 推流编码配置组 */
@property (nonatomic, strong) NSArray<PLVideoStreamingConfiguration *>   *videoStreamingConfigurations;
/** 摄像头是否朝向屏幕 */
@property (assign, nonatomic) BOOL isCameraToScreen;
/** 是否已经开始推流 */
@property (nonatomic, assign) BOOL isStartStreaming;

/** 重连 */
@property (strong, nonatomic) NSTimer *reconnectionTimer;
@property (strong, nonatomic) NSDate *reconnectionKeyTime;
/** 滤镜 */
@property (nonatomic, strong) CIContext *context;

@end

@implementation ZBStreamingSession

- (instancetype)init {
    self = [super init];
    if (self) {
        // 开启定位
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

+ (void)initStreamingSessionWithCallBack:(void (^)(ZBStreamingInitialStatus, NSString * _Nullable, ZBStreamingSession * _Nullable instance))handler {
    [ZBStreamingRequestManager sendCreatSteamRequestWithsuccess:^(id responsObject) {
        if ([responsObject[@"code"] isEqualToString:@"60000"]) {
            // 主播被禁播
            if (handler) {
                handler(ZBInitialStatusLiverBeBande, responsObject[@"time"], nil);
            }
        } else {
            // 主播没有被禁播
            if (handler) {
                ZBStreamingSession *session = [[ZBStreamingSession alloc] init];
                [session initializeCameraStreamSessionWithJson:responsObject[@"stream"] withView:^{
                    session.streamID = responsObject[@"stream_id"];
                    handler(ZBInitialStatusSuccess, @"初始化成功", session);
                }];
            }
            
        }
    } faild:^(NSError *err) {
        // 创建失败
        if (handler) {
            handler(ZBInitialStatusFaild, [err debugDescription], nil);
        }
    }];
}

#pragma mark - public methord
- (void)startStreamingWithTitle:(NSString *)title coverImage:(UIImage *)coverImage thum:(NSString *)thum callBack:(void (^ _Nullable)(ZBStreamingStartStatus))handler {
    // 设置地址
    NSString *locationString = nil;
    if (self.location != nil) {
        locationString = [NSString stringWithFormat:@"%lf,%lf", self.location.coordinate.latitude, self.location.coordinate.longitude];
    }
    //上传配置信息
    __weak __typeof__(self) weakSelf = self;
    if (coverImage) { // 有图片先上传图片，在上传标题和地址
        [ZBStreamingRequestManager uploadCoverImgBySDKRequestWithImg:coverImage Thumb:thum success:^(id responsObject) {
            [ZBStreamingRequestManager sendStartSteamRequestWithTitle:title location:locationString success:^(id responsObject) {
                // 上传配置成功 ，切换直播界面 开始推流
                dispatch_async(weakSelf.sessionQueue, ^{
                    // 在开始直播之前请确保已经从业务服务器获取到了 streamURL，streamURL 的格式为 "rtmp://"
                    [weakSelf.session startWithFeedback:^(PLStreamStartStateFeedback feedback) {
                        if (handler) {
                            handler((ZBStreamingStartStatus)feedback);
                        }
                        if (feedback == PLStreamStartStateSuccess) {
                            weakSelf.isStartStreaming = YES;
                        }
                    }];
                });
            } faild:^(NSError *err) {
                // 上传配置失败
                if (handler) {
                    handler(ZBStartStatusUploadFaild);
                }
            }];
        } faild:^(NSError *err) {
            // 上传配置失败
            if (handler) {
                handler(ZBStartStatusUploadFaild);
            }
        }];
        
    } else {  // 没图片直接推上传标题和地址
        [ZBStreamingRequestManager sendStartSteamRequestWithTitle:title location:locationString success:^(id responsObject) {
            // 上传配置成功 ，切换直播界面 开始推流
            dispatch_async(self.sessionQueue, ^{
                // 在开始直播之前请确保已经从业务服务器获取到了 streamURL，streamURL 的格式为 "rtmp://"
                [weakSelf.session startWithFeedback:^(PLStreamStartStateFeedback feedback) {
                    if (handler) {
                        handler((ZBStreamingStartStatus)feedback);
                    }
                    if (feedback == PLStreamStartStateSuccess) {
                        weakSelf.isStartStreaming = YES;
                    }
                }];
            });

        } faild:^(NSError *err) {
            // 上传配置失败
            if (handler) {
                handler(ZBStartStatusUploadFaild);
            }
        }];
    }
    
}

 // 初始化 session
- (void)initializeCameraStreamSessionWithJson:(id)json withView:(void (^)())viewBlock{
    // 预先设定几组编码质量，之后可以切换
    CGSize videoSize = CGSizeMake(720 , 1280);
    PLStream *stream = [PLStream streamWithJSON:[self dictionaryWithJsonString:json]];
    self.videoStreamingConfigurations = @[
                                          [[PLVideoStreamingConfiguration alloc] initWithVideoSize:videoSize expectedSourceVideoFrameRate:30 videoMaxKeyframeInterval:90 averageVideoBitRate:1200 * 1000 videoProfileLevel:AVVideoProfileLevelH264Baseline31]
                                          ];
    void (^permissionBlock)(void) = ^{
        dispatch_async(self.sessionQueue, ^{
            // 视频采集配置
            PLVideoCaptureConfiguration *videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
            videoCaptureConfiguration.sessionPreset = AVCaptureSessionPreset1280x720;
            // 音频采集配置
            PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
            // 视频编码配置
            PLVideoStreamingConfiguration *videoStreamingConfiguration = [self.videoStreamingConfigurations lastObject];
            // 音频编码配置
            PLAudioStreamingConfiguration *audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
            self.session = [[PLCameraStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:stream];
            // 美颜
            [self.session setBeautifyModeOn:YES];
            [self.session setBeautify:0.5];
            self.session.delegate = self;
            self.session.captureDevicePosition = AVCaptureDevicePositionFront;
            self.session.bufferDelegate = self;
            self.isCameraToScreen = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.liveView.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
                viewBlock();
                if (self.sessionQueue == nil) {
                    return ;
                }
            });
        });
    };
    void (^noAccessBlock)(void) = ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"没有获得摄像头授权", nil)
                                                            message:NSLocalizedString(@"!", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    };
    switch ([PLCameraStreamingSession cameraAuthorizationStatus]) {
        case PLAuthorizationStatusAuthorized:
            permissionBlock();
            break;
        case PLAuthorizationStatusNotDetermined: {
            [PLCameraStreamingSession requestCameraAccessWithCompletionHandler:^(BOOL granted) {
                granted ? permissionBlock() : noAccessBlock();
            }];
        }
            break;
        default:
            noAccessBlock();
            break;
    }
}

- (UIImage *)captureImage {
    UIImage *image = [self captureView:self.session.previewView];
    
/** 将截图保存到相册 和 裁剪图片的方法   
    UIImageWriteToSavedPhotosAlbum(image, self,nil, nil);// 将图片保存至相册
    CGRect screenRect = CGRectMake(0, 64 * 1.5 , ScreenWidth, ScreenWidth);// 裁剪图片
    image = [image cropImageWithRect:screenRect];*/
    return image;
}

- (UIImage*)captureView:(UIView *)theView {
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *img;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [theView drawViewHierarchyInRect:theView.bounds afterScreenUpdates:YES];
        img = UIGraphicsGetImageFromCurrentImageContext();
    } else {
        CGContextSaveGState(context);
        [theView.layer renderInContext:context];
        img = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return img;
}

- (void)toggleCamera {
    if (self.session) {
        dispatch_async(self.sessionQueue, ^{
            [self.session toggleCamera];
            self.isCameraToScreen = !self.isCameraToScreen;
        });
    }
}

- (void)changFocusWithPoint:(CGPoint)focusPoint {
    self.session.focusPointOfInterest = CGPointMake(focusPoint.x / [UIScreen mainScreen].bounds.size.width, focusPoint.y / [UIScreen mainScreen].bounds.size.height);
}

- (void)endStreaming {
    if (self.sessionQueue) {
        self.sessionQueue = nil;
    }
    if (self.session) {
        [self.session destroy];
    }
    [self.reconnectionTimer invalidate];
    self.reconnectionTimer = nil;
    self.reconnectionKeyTime = nil;
    if (self.isStartStreaming) {
        self.isStartStreaming = NO;
        // 告诉后台停止直播
        [ZBStreamingRequestManager sendEndSteamRequestWithStreamId:self.streamID success:^(id responsObject) {
            NSLog(@"告诉后台停止直播 success %@",responsObject);
        } faild:^(NSError *err) {
            NSLog(@"告诉后台停止直播 faild %@",[err debugDescription]);
        }];
    }
}

#pragma mark - delegate
#pragma mark └ LocationManager delegate 定位代理
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.location = [locations firstObject];
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

#pragma mark └ PLCameraStreamingSession delegate 推流代理
// 流状态已变更的回调
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session streamStateDidChange:(PLStreamState)state {
    // 这个回调会确保在主线程，所以可以直接对 UI 做操作
    if (state == PLStreamStateConnected) {
        [self.reconnectionTimer invalidate];
        self.reconnectionTimer = nil;
        self.reconnectionKeyTime = nil;
    }
}

// 因产生了某个 error 而断开时的回调
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session didDisconnectWithError:(NSError *)error {
    [self reconnectStatusChangedWithType:ZBStreamingStatusStartReconnect];
    [self.reconnectionTimer fire];
}

// 当开始推流时，会每间隔 3s 调用该回调方法来反馈该 3s 内的流状态，包括视频帧率、音频帧率、音视频总码率
- (void)cameraStreamingSession:(PLCameraStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status {
    if (_delegate && [_delegate respondsToSelector:@selector(streamingSession:streamStatusDidUpdate:)]) {
        [_delegate streamingSession:self streamingStateDidUpload:(ZBStreamingStatus)status];
    }
    NSLog(@"videoFPS %f", status.videoFPS);
}

- (CVPixelBufferRef)cameraStreamingSession:(PLCameraStreamingSession *)session cameraSourceDidGetPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    // 滤镜
    CIImage *outImage = [self addfilterViewWithIndex:self.filterType pixelBufferRef:pixelBuffer];
    [self.context render:outImage toCVPixelBuffer:pixelBuffer];
    return pixelBuffer;
}


#pragma mark - filter 滤镜
// 添加滤镜
- (CIImage *)addfilterViewWithIndex:(NSInteger)index pixelBufferRef:(CVPixelBufferRef)pixelBuffer {
    NSArray *nameArray = @[@"OriginImage",
                           @"CIPhotoEffectNoir",
                           @"CIPhotoEffectChrome",
                           @"CIPhotoEffectFade",
                           @"CISepiaTone",
                           @"CIPhotoEffectInstant",
                           @"CIColorMatrix",
                           @"CIPhotoEffectTransfer"];
    CIFilter *filter;
    if (index == 0) {
    } else {
        //将UIImage转换成CIImage
        CIImage *ciImage = [CIImage imageWithCVImageBuffer:pixelBuffer];
        //创建滤镜
        filter = [CIFilter filterWithName:nameArray[index] keysAndValues:kCIInputImageKey, ciImage, nil];
        //已有的值不改变，其他的设为默认值
        if (index == 4) {
            [filter setValue:@(0.5) forKey:kCIInputIntensityKey];
        } else if (index == 6) {
            [filter setDefaults];
            [filter setValue:[CIVector vectorWithX:1 Y:0.1 Z:0 W:0] forKey:@"inputRVector"];
            [filter setValue:[CIVector vectorWithX:0.1 Y:1 Z:0 W:0] forKey:@"inputGVector"];
            [filter setValue:[CIVector vectorWithX:0.2 Y:0.3 Z:1 W:0] forKey:@"inputBVector"];
            [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputAVector"];
        } else {
            [filter setDefaults];
        }
    }
    if (index == 6) {
        [self.session setBeautify:0.8];
    } else {
        [self.session setBeautify:0.5];
    }
    //渲染并输出CIImage
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}

#pragma mark - reconnect 重连
//定时重连
- (void)resolveThatReconnection {
    if (self.reconnectionKeyTime == nil) {
        self.reconnectionKeyTime = [NSDate date];
    }
    int timeAway = -[self.reconnectionKeyTime timeIntervalSinceDate:[NSDate date]];
    if (timeAway == 1.5 || timeAway == 4 || timeAway == 7.5) {
        [self.session restartWithFeedback:^(PLStreamStartStateFeedback feedback) {
            if (feedback == PLStreamStartStateSuccess) {
                [self.reconnectionTimer invalidate];
                self.reconnectionTimer = nil;
                self.reconnectionKeyTime = nil;
                [self reconnectStatusChangedWithType:ZBStreamingStatusReconnectSuccess];
            } else if (feedback == PLStreamStartStateSessionStillRunning) {
                [self.reconnectionTimer invalidate];
                self.reconnectionTimer = nil;
                self.reconnectionKeyTime = nil;
            }
        }];
    } else if (timeAway > 10.0f) {
        [self.session stop];
        [self reconnectStatusChangedWithType:ZBStreamingStatusReconnectFaild];
        [self endStreaming];
    }
}

- (void)reconnectStatusChangedWithType:(ZBStreamingReconnectStatus)type {
    if (_delegate && [_delegate respondsToSelector:@selector(streamingSession:streamingReconnectStateDidChange:)]) {
        [_delegate streamingSession:self streamingReconnectStateDidChange:type];
    }
}

#pragma mark - other tools
/// 七牛提供的字符串转字典的方法
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

#pragma mark - lazy load
- (void)setFilterType:(ZBStreamingFilterType)filterType {
    NSInteger filterIndex = filterType;
    if (filterIndex > 7) {
        filterIndex = 0;
    } else if (filterIndex < 0) {
        filterIndex = 7;
    }
    _filterType = filterIndex;
}

- (UIView *)liveView {
    if (self.session) {
        return self.session.previewView;
    } else {
        return [[UIView alloc] init];
    }
}

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 10;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

- (NSTimer *)reconnectionTimer {
    if (_reconnectionTimer == nil) {
        _reconnectionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resolveThatReconnection) userInfo:nil repeats:YES];
    }
    return _reconnectionTimer;
}

- (dispatch_queue_t)sessionQueue {
    if (_sessionQueue == nil) {
        _sessionQueue = dispatch_queue_create("pili.queue.streaming", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}

- (CIContext *)context {
    if (_context == nil) {
        // 获取OpenGLES渲染环境
        _context = [CIContext contextWithEAGLContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
    }
    return _context;
}

@end
