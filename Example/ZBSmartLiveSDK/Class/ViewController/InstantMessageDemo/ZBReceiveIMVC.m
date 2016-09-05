//
//  ZBReceiveIMVC.m
//  ZBSmartLiveSDK
//
//  Created by lip on 16/8/1.
//  Copyright © 2016年 LipYoung. All rights reserved.
//

#import "ZBReceiveIMVC.h"
#import <ZBSmartLiveSDK/ZBChatroom.h>
#import <ZBChat.h>
#import "ZBInstantMessageTabBarController.h"

@interface ZBReceiveIMVC ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *chatroomIDTextField;

@end

@implementation ZBReceiveIMVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (IBAction)join:(id)sender {
    // 界面显示完毕后进入测试用的直播间
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    [chatroom joinChatroom:@([self.chatroomIDTextField.text intValue]) password:nil completion:^(id respondData, NSError *error) {
        if (error) {
            NSLog(@"加入聊天室错误 %@", error);
        } else {
            NSLog(@"加入聊天室成功 %@", respondData);
            ZBInstantMessageTabBarController *controller = (ZBInstantMessageTabBarController *)self.tabBarController;
            controller.chatroomId = self.chatroomIDTextField.text;
        }
    }];
}

- (IBAction)leav:(id)sender {
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    // 发送离开聊天室的信息
    [chatroom leaveChatroom:@([self.chatroomIDTextField.text intValue]) password:nil completion:^(id respondData, NSError *error) {
        if (error) {
            NSLog(@"离开聊天室错误 %@", error);
        } else {
            NSLog(@"离开聊天室成功 %@", respondData);
            ZBInstantMessageTabBarController *controller = (ZBInstantMessageTabBarController *)self.tabBarController;
            controller.chatroomId = nil;
        }
    }];
}

- (IBAction)getChatrromCount:(id)sender {
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    [chatroom getChatroom:@([self.chatroomIDTextField.text intValue]) viewerCountCompletion:^(id respondData, NSError *error) {
        if (error) {
            NSLog(@"%@", [error debugDescription]);
        } else {
            NSLog(@"%@", respondData);
        }
    }];
}

- (IBAction)shoutDown:(id)sender {
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    [chatroom disableChatroomUserIdentity:self.textField.text sendMessageWithTime:120 completion:^(id respondData, NSError *error) {
        if (error) {
            NSLog(@"%@", [error debugDescription]);
        } else {
            NSLog(@"%@", respondData);
        }
    }];
}

- (IBAction)unShoutDown:(id)sender {
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    [chatroom enableChatroomUserIdentity:self.textField.text sendMessageCompletion:^(id respondData, NSError *error) {
        if (error) {
            NSLog(@"%@", [error debugDescription]);
        } else {
            NSLog(@"%@", respondData);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
