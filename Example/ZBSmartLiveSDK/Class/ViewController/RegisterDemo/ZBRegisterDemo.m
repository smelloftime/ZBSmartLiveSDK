//
//  ZBRegisterDemo.m
//  ZBSmartLiveSDK
//
//  Created by app on 16/10/13.
//  Copyright © 2016年 LipYoung. All rights reserved.
//

#import "ZBRegisterDemo.h"
#import <ZBSmartLiveSDK/ZBSmartLiveSDK.h>

@interface ZBRegisterDemo ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (weak, nonatomic) IBOutlet UITextView *resuleTextView;

@end

@implementation ZBRegisterDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[ZBSmartLiveSDK shareSDK] registerWithApiVersion:@"1.0" completion:^(NSError *error) {
        [self.act stopAnimating];
        if (error == nil) {
            if (error == nil) {
                self.resultLabel.text = @"初始化成功A";
            } else {
                self.resultLabel.text = @"初始化失败";
                self.resuleTextView.text = [NSString stringWithFormat:@"errorcode => %d ;\nerror info => %@ ;\nerror localized description => %@", (int)error.code, error.domain, [error localizedDescription]];
            }
        }
    }];
}
@end
