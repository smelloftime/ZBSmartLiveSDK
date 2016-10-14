//
//  ZBCloudData.h
//  Pods
//
//  Created by lip on 16/7/23.
//
//  负责和智播云通讯

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZBCloudData : NSObject
/**
 *  获取智播云服务器上关于直播相关的数据
 *
 *  @param requestApi 请求的接口名称，接口相关请查阅智播云通讯文档
 *  @param parameter  请求的接口参数
 *  @param success    请求的正确结果
 *  @param fail       请求的错误结果
 */
+ (void)getZBCloudDataWithApi:(NSString *)requestApi parameter:(NSDictionary *)parameter success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;
/**
 *  上传推流直播封面图片至智播云的服务器
 *  
 *  @note  图片会被压缩至 500 kb 以下
 *
 *  @param image     需要上传的图片
 *  @param parameter 图片的规格,可以不传该参数
 *  @param success   请求的正确结果
 *  @param fail      请求的错误结果
 */
+ (void)uploadImage:(UIImage *)image parameter:(NSDictionary *)parameter success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;
/**
 *  赠送礼物给某个用户
 *
 *  @warning beta 版的ZBSmartLiveSDK 不包括收发聊天信息的功能
 *
 *  @param giftCode 礼物代号,该礼物代号从智播云返回
 *  @param usid     接收礼物的用户唯一标识
 *  @param count    赠送礼物的数量
 *  @param success  请求正确的结果
 *  @param fail     请求错误的结果
 */
+ (void)sendGift:(NSString *)giftCode toUser:(NSString *)usid andGiftCount:(NSUInteger)count success:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;
/**
 *  获取智播云配置的礼物清单信息,该清单可以登录直播云后台进行修改
 *
 *  @param success 请求正确的结果
 *  @param fail    请求错误的结果
 */
+ (void)getGiftConfigInfoSuccess:(void(^)(id data))success fail:(void(^)(NSError *fail))fail;
/**
 *  获取智播云配置的直播间公告信息,该信息可以登录直播云后台进行修改
 *
 *  @return 直播间公告,如果返回空表示初始化失败
 */
+ (NSString *)getStreamNotice;
/**
 *  获取智播云配置的敏感词信息,该信息可以登录直播云后台进行修改
 *
 *  @return 敏感词信息,如果返回空表示初始化失败
 */
+ (NSArray *)getFilterStringArray;
/**
 *  获取智播云配置的敏感词替换字符,该信息可以登录直播云后台进行修改
 *
 *  @return 敏感词替换字符,如果返回空表示初始化失败
 */
+ (NSString *)getFilterReplaceString;
/**
 *  获取智播云配置的直播筛选配置数组,该信息可以登录直播云后台进行修改
 *
 *  @return 直播筛选配置数组,如果返回空表示初始化失败
 */
+ (NSArray *)getLiveFilterListConfig;

/**
 *  获取直播云登录用户的聊天室id，该信息在第一次成功初始化 ZBStreamingSession 推流类的实例后有值，在用户退出程序后清空。

 *  @return 登录用户的聊天室id，如果返回为空，则表示 ZBStreamingSession 推流类初始化失败
 */
+ (NSNumber *)getImCid;



@end
