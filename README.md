# `ZBSmartLiveSDK` 概述

`ZBSmartLiveSDK`是一个适用于 iOS 平台快速集成直播功能的 SDK.配合智播云后台可轻松同步迁移用户数据.

`ZBSmartLiveSDK` 的特色是基于[PLMediaStreamingKit](https://github.com/pili-engineering/PLMediaStreamingKit),[PLPlayerKit](https://github.com/pili-engineering/PLPlayerKit)完成**快速构建**类似[映客](http://www.inke.cn/)的APP.

借助`ZBSmartLiveSDK`和智播云后台,用户可以在几小时内集成直播,聊天核心功能至已有应用中.

(备注:该SDK仅支持ARC环境和object-c工程,以及iOS 8.0以上运行环境)

## 功能特性

- [x]  应用权限验证
- [x]  智能账户迁移(登录,注册,自动登录,自动更新授权,更新用户信息)
- [x]  直播功能(摄像头采集,智能编码,上传推流)
- [x]  直播播放(拉流解码,弱网重连,在线聊天,赠送礼物等功能)
- [x]  视频回放
- [x]  多平台分享功能

## 内容摘要

- [快速集成](#快速集成)
- [初始化SDK](#初始化SDK)
- [用户登录](#用户登录)
- [获取直播列表](#获取直播列表)
- [开启直播功能](#开启直播功能)
- [收发即时通讯文本消息](#收发即时通讯文本消息)
- [基础播放器功能](#基础播放器功能)

## SDK说明

SDK 提供了如下类(协议)和方法,点击类目查询详情

> [ZBSmartLiveSDK](https://github.com/LipYoung/ZBSmartLiveSDK/wiki/home) 整个SDK的主入口
> 
> [ZBChat](https://github.com/LipYoung/ZBSmartLiveSDK/wiki/即时通讯) 聊天管理类,负责收发消息
> 
> ZBRecordKit 视频采集编码的核心
> 
> ZBPlayKit 播放器核心(播放在线回放视频和直播)
> 
> [ZBCloudData](https://github.com/LipYoung/ZBSmartLiveSDK/wiki/智播云通讯文档) 智播云后台的服务器信息配置返回

## 快速集成
你可以通过 CocoaPods 自动集成该 SDK 

- 在 PodFile 文件中加入

```shell
pod '`ZBSmartLiveSDK`'
```

- 安装 CocoaPods 依赖

```shell
pod install
```

## 初始化SDK

注册智播云后台,申请获取 APPKEY 在应用初始化时添加初始化方法

```objc
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      [[ZBSmartLiveSDK shareSDK] registerWithAppID:@"zb60225160269831" appToken:@"tlMvbTrQ6chiymlTROx2TL" completion:^(NSError *error) {
        if (error == nil) {
            NSLog(@"初始化成功");
        } else {
            NSLog(@"初始化失败的错误信息 %@", [error localizedDescription]);
        }
    }];
      return YES;
}
```

## 用户登录

登录智播云进行获取授权.获取到智播云口令后
iOS端直接调用登录接口即可,智播云会自动与三方服务器对接实现智能迁移用户数据.

```objc
[[ZBSmartLiveSDK shareSDK] loginWithZBTicket:ticket completion:^(NSError *error) {
        if (error == nil) {
            NSLog(@"登录成功 %@",ticket);
        } else {
            NSLog(@"ticket = %@，登录失败 = %@", ticket, [NSString stringWithFormat:@"errorcode => %d ;\nerror info => %@ ;\nerror localized description => %@", (int)error.code, error.domain, [error localizedDescription]]);
        }
}];
```


## 获取直播列表

```objc
[ZBCloudData getZBCloudDataWithApi:@"ZBCloud_Get_Video_List" parameter:@{@"order"@"order", @"p":@(p), @"limit":@(limit)} success:^(id data) {
	// data 是详细的直播列表数据
    } fail:^(NSError *fail) {
	// err 是获取直播列表时产生的错误
}];
```
和直播云后台通讯的详细情况查看[智播云通讯文档说明](https://github.com/LipYoung/ZBSmartLiveSDK/wiki/智播云通讯文档)

## 开启直播功能



## 收发即时通讯文本消息

### 链接聊天服务器

聊天模块在应用前台激活时,会默认保持和聊天服务器的长连接,在需要使用聊天功能时,通过该方法可以验证和聊天服务器的链接状态

```objc
#import <ZBSmartLiveSDK/ZBChat.h>

[[ZBChat share] reconnectionSuccess:^(NSString *info) {
        // 链接聊天服务器成功
    } fail:^(NSError *error) {
    	  // 链接聊天服务器失败, 建议手动启动重连逻辑
        [self.chat reconnectLiRivalKit];
}];
```

### 加入聊天室

```objc
#import <ZBSmartLiveSDK/ZBChatroom.h>

[[[ZBChatroom alloc] init] joinChatroom:@(聊天室唯一标识) password:@"聊天室密码,可以为空" completion:^(id respondData, NSError *error) {
        if (error) {
            // 加入聊天室失败
        } else {
        	// 加入聊天室成功
        }
}];
```

### 创建发送聊天消息

```objc
#import <ZBSmartLiveSDK/ZBMessage.h>
#import <ZBSmartLiveSDK/ZBChat.h>

ZBMessage *messageBody = [[ZBMessage alloc] init];
messageBody.messageContent = @"聊天内容";
messageBody.messageType = ZBMessageTypeText;
messageBody.fromUserIdentity = @"发送聊天信息用户的三方服务器ID";
    
[[ZBChat share] sendMessage:messageBody toConversation:@(self.cidByIM) completion:^(id respondData, NSError *error) {
    if (error) {
    	  // 聊天信息发送失败
    } else {
    	  // 聊天信息发送成功
    }
}];
```


## 基础播放器功能













