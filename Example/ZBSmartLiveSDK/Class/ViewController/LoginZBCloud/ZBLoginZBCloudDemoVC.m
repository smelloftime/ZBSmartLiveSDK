//
//  ZBLoginZBCloudDemoVC.m
//  ZBSmartLiveSDK
//
//  Created by lip on 16/7/23.
//  Copyright © 2016年 LipYoung. All rights reserved.
//

#import "ZBLoginZBCloudDemoVC.h"
#import <ZBSmartLiveSDK/ZBSmartLiveSDK.h>

@interface ZBLoginZBCloudDemoVC ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UILabel *resuleLabel;
@property (weak, nonatomic) IBOutlet UITextView *resuleTextView;

@end

@implementation ZBLoginZBCloudDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    // Do any additional setup after loading the view from its nib.
    
    // 此处使用智播云服务返回给你们后台服务器的用户票据信息
    
    /**
        1. 该处票据会不定期更新改变
        2. 所以 ZBSDK 不会持久化用户登录信息
        3. 该方法建议在 应用正常注册 获取配置信息 成功后 再调用
     */
    [self.act startAnimating];
    [[ZBSmartLiveSDK shareSDK] loginWithZBTicket:@"y-WwboXtpT6LECntgW5" completion:^(NSError *error) {
        [self.act stopAnimating];
        if (error == nil) {
            self.resuleLabel.text = @"登录成功";
            NSDictionary *imDic = [[ZBSmartLiveSDK shareSDK] returnIMUserInfo];
            NSString *instantMessageInfo = [NSString stringWithFormat:@"IM账号 %@\nIM密码 %@", imDic[@"IMID"], imDic[@"IMPWD"]];
            self.resuleTextView.text = instantMessageInfo;
        } else {
            self.resuleLabel.text = @"登录失败";
            self.resuleTextView.text = [NSString stringWithFormat:@"errorcode => %d ;\nerror info => %@ ;\nerror localized description => %@", (int)error.code, error.domain, [error localizedDescription]];
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
