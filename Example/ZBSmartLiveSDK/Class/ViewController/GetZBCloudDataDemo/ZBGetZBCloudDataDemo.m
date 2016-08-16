//
//  ZBGetZBCloudDataDemo.m
//  ZBSmartLiveSDK
//
//  Created by lip on 16/7/24.
//  Copyright © 2016年 LipYoung. All rights reserved.
//

#import "ZBGetZBCloudDataDemo.h"
#import <ZBSmartLiveSDK/ZBCloudData.h>

@interface ZBGetZBCloudDataDemo ()
@property (weak, nonatomic) IBOutlet UIButton *sendRequestButton;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end

@implementation ZBGetZBCloudDataDemo


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.sendRequestButton addTarget:self action:@selector(sendGift) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sendRequest {
    // 此处请求的所有参数请查阅说明 文档 https://github.com/LipYoung/ZBSmartLiveSDK/wiki
    [ZBCloudData getZBCloudDataWithApi:@"ZBCloud_Get_Live_List"
                             parameter:@{
                                         @"order": @"airtime",
                                         @"p": @(1),
                                         @"limit": @(10)
                                         }
                               success:^(id data) {
                                   self.resultTextView.text = [NSString stringWithFormat:@"%@", data];
                               }
                                  fail:^(NSError *fail) {
                                      self.resultTextView.text = [NSString stringWithFormat:@"errorcode => %d ;\nerror info => %@ ;\nerror localized description => %@", (int)fail.code, fail.domain, [fail localizedDescription]];
                                  }];
}

- (void)sendGift {
    NSDictionary *dic = [ZBCloudData giftConfigInfo][0];
    [ZBCloudData sendGift:dic[@"gift_code"] toUser:@"11" andGiftCount:1 success:^(id data) {
        self.resultTextView.text = [NSString stringWithFormat:@"%@", data];
    } fail:^(NSError *fail) {
        self.resultTextView.text = [NSString stringWithFormat:@"errorcode => %d ;\nerror info => %@ ;\nerror localized description => %@", (int)fail.code, fail.domain, [fail localizedDescription]];
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
