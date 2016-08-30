//
//  ZBSendIMVC.m
//  ZBSmartLiveSDK
//
//  Created by lip on 16/8/1.
//  Copyright © 2016年 LipYoung. All rights reserved.
//

#import "ZBSendIMVC.h"
#import <ZBChat.h>
#import <ZBMessage.h>

@interface ZBSendIMVC () <
    ZBChatDelegate
>

@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
/** 聊天管理器 */
@property (strong, nonatomic) ZBChat *chat;

@end

@implementation ZBSendIMVC
#pragma mark - property
- (ZBChat *)chat {
    if (_chat == nil) {
        _chat = [[ZBChat alloc] init];
        _chat.delegate = self;
    }
    return _chat;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - setup

#pragma mark └ means
- (IBAction)sendMessage:(UIButton *)sender {
    if ([self.sendMessageTextField.text length] == 0) {
        NSLog(@"发送聊天信息时,消息不能为空");
        return;
    }
    ZBMessage *message = [[ZBMessage alloc] init];
    message.messageContent = self.sendMessageTextField.text;
    message.messageType = ZBMessageTypeText;
    message.fromUserIdentity = @"zbusid_9"; // 该数值来自三方用户服务器
    [self.chat sendMessage:message toConversation:@(4) completion:^(id respondData, NSError *error) {
        if (error == nil) {
            self.messageTextView.text = [NSString stringWithFormat:@"%@\n发送消息:\n%@", self.messageTextView.text, message.messageContent];
            NSLog(@"%@", respondData);
        } else {
            NSLog(@"%@", [NSString stringWithFormat:@"errorcode => %d ;\nerror info => %@ ;\nerror localized description => %@", (int)error.code, error.domain, [error localizedDescription]]);
        }
    }];
}

#pragma mark └ chat manager delegate
- (void)chat:(ZBChat *)chat connectionStateDidChange:(ZBChatState)connectionState {
    int index = connectionState;
    switch (index) {
        case ZBChatStateReconnection:
            self.tabBarController.title = @"正在重连";
            break;
        case ZBChatStateSuccess:
            self.tabBarController.title = @"链接成功";
            break;
        default:
            break;
    }
}

- (IBAction)refresh:(id)sender {
    [self.chat reconnectionSuccess:^(NSString *info) {
        NSLog(@"%@", info);
    } fail:^(NSError *error) {
        NSLog(@"%@", [error debugDescription]);
    }];
}

- (void)chat:(ZBChat *)chat didReceiveMessage:(ZBMessage *)message {
    self.messageTextView.text = [NSString stringWithFormat:@"%@\n接收消息:\n%@", self.messageTextView.text, message.messageContent];
    NSLog(@"%@", message);
}

#pragma mark - other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
