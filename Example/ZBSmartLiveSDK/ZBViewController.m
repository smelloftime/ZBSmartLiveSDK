//
//  ZBViewController.m
//  ZBSmartLiveSDK
//
//  Created by LipYoung on 07/19/2016.
//  Copyright (c) 2016 LipYoung. All rights reserved.
//

#import "ZBViewController.h"
#import <ZBSmartLiveSDK/ZBSDK.h>

@interface ZBViewController ()

@end

@implementation ZBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [ZBSDK update];
    [ZBSDK test];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
