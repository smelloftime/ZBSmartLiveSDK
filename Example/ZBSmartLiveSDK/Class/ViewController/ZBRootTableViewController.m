//
//  ZBRootTableViewController.m
//  ZBSmartLiveSDK
//
//  Created by lip on 16/7/23.
//  Copyright © 2016年 LipYoung. All rights reserved.
//

#import "ZBRootTableViewController.h"

@interface ZBRootTableViewController ()
/** demo 名称数组 */
@property (strong, nonatomic) NSArray *demoNameArray;
/** demo 控制器数组 */
@property (strong, nonatomic) NSArray *demoViewControllerArray;

@end

@implementation ZBRootTableViewController

- (NSArray *)demoNameArray {
    if (_demoNameArray == nil) {
        _demoNameArray = [[NSArray alloc] initWithObjects:
                          @"登录智播云",
                          @"获取直播数据",
                          @"收发直播间消息",
//                          @"直播功能(进入,开启,结束)",
//                          @"观看直播",
//                          @"回放直播",
                          nil];
    }
    return _demoNameArray;
}

- (NSArray *)demoViewControllerArray {
    if (_demoViewControllerArray == nil) {
        _demoViewControllerArray = [[NSArray alloc] initWithObjects:
                                    @"ZBLoginZBCloudDemoVC",
                                    @"ZBGetZBCloudDataDemo",
                                    @"ZBInstantMessageTabBarController",
                                    nil];
    }
    return _demoViewControllerArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZBSmartLiveSDK";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ZBRootTableViewControllerCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ZBRootTableViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.demoNameArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:self.demoViewControllerArray[indexPath.row] bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:self.demoViewControllerArray[indexPath.row]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
