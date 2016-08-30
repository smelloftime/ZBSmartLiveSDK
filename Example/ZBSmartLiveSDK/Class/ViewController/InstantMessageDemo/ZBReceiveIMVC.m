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

@interface ZBReceiveIMVC ()
@property (weak, nonatomic) IBOutlet UITextView *receiveTextView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ZBReceiveIMVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (IBAction)getChatrromCount:(id)sender {
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    [chatroom getChatroom:@(4) viewerCountCompletion:^(id respondData, NSError *error) {
        if (error) {
            self.receiveTextView.text = [NSString stringWithFormat:@"%@\n错误 %@", self.receiveTextView.text, error];
        } else {
            self.receiveTextView.text = [NSString stringWithFormat:@"%@\n成功 %@", self.receiveTextView.text, respondData];
        }
    }];
}

- (IBAction)shoutDown:(id)sender {
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    [chatroom disableChatroomUserIdentity:self.textField.text sendMessageWithTime:120 completion:^(id respondData, NSError *error) {
        if (error) {
            self.receiveTextView.text = [NSString stringWithFormat:@"%@\n错误 %@", self.receiveTextView.text, error];
        } else {
            self.receiveTextView.text = [NSString stringWithFormat:@"%@\n成功 %@", self.receiveTextView.text, respondData];
        }
    }];
}

- (IBAction)unShoutDown:(id)sender {
    ZBChatroom *chatroom = [[ZBChatroom alloc] init];
    [chatroom enableChatroomUserIdentity:self.textField.text sendMessageCompletion:^(id respondData, NSError *error) {
        if (error) {
            self.receiveTextView.text = [NSString stringWithFormat:@"%@\n错误 %@", self.receiveTextView.text, error];
        } else {
            self.receiveTextView.text = [NSString stringWithFormat:@"%@\n成功 %@", self.receiveTextView.text, respondData];
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
