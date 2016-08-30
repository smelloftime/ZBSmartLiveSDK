//
//  ZBInstantMessageTabBarController.m
//  ZBSmartLiveSDK
//
//  Created by lip on 16/7/29.
//  Copyright © 2016年 LipYoung. All rights reserved.
//

#import "ZBInstantMessageTabBarController.h"
#import <ZBSmartLiveSDK/ZBChatroom.h>

@interface ZBInstantMessageTabBarController ()

@end

@implementation ZBInstantMessageTabBarController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 界面显示完毕后进入测试用的直播间
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    [chatroom joinChatroom:@(4) password:nil completion:^(id respondData, NSError *error) {
        if (error) {
            NSLog(@"加入聊天室错误 %@", error);
        } else {
            NSLog(@"加入聊天室成功 %@", respondData);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    // 发送离开聊天室的信息
    [chatroom leaveChatroom:@(4) password:nil completion:^(id respondData, NSError *error) {
        if (error) {
            NSLog(@"离开聊天室错误 %@", error);
        } else {
            NSLog(@"离开聊天室成功 %@", respondData);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"dealloc");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
