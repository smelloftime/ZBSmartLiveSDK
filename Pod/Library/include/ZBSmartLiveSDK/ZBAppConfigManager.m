//
//  ZBAppConfigManager.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/12.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBAppConfigManager.h"
#import "ZBApplicationCenter.h"
#import "ZBHttpRequestManager.h"
#import "ZBInitializeRequestManager.h"
#import "SSZipArchive.h"

@implementation ZBAppConfigManager
#pragma mark - init Application
+ (void)initializeApplicationCompletion:(void (^)(NSError *))error {
    if ([ZBApplicationCenter defaultCenter].baseURL == nil) {
            [self initializeCompletion:error];
    } else {
        [self contrastServerConfigVersionCompletion:error];
    }
}

+ (void)contrastServerConfigVersionCompletion:(void (^)(NSError *))error {
    NSString *configVersion = [ZBApplicationCenter defaultCenter].configVersion;
    if (configVersion == nil) {
        [self initializeCompletion:error];
        return;
    } else {
        ZBConfigInfoModel *model = [ZBApplicationCenter defaultCenter].configInfoModel;
        if (model) {
            if (error) {
                error(nil);
            }
        } else {
            [self initializeCompletion:error];
            return;
        }
        [self saveConfigFile];
    }
}

#pragma mark - config
+ (void)saveConfigFile {
    [ZBInitializeRequestManager sendGetConfigVersionSuccess:^(NSString *configVersion) {
        NSString *newConfigVersion = configVersion;
        NSString *oldConfigVersion = [ZBApplicationCenter defaultCenter].configVersion;
        if ([newConfigVersion isEqualToString:oldConfigVersion] == NO || oldConfigVersion == nil) {
            [ZBInitializeRequestManager sendGetConfigRequestSuccess:^(id data) {
                [ZBApplicationCenter defaultCenter].configVersion = newConfigVersion;
                NSString *oldFilterVersion = [ZBApplicationCenter defaultCenter].configInfoModel.filterWordVersion;
                [[ZBApplicationCenter defaultCenter] saveConfigData:data];
                NSString *nowFilterVersion = [ZBApplicationCenter defaultCenter].configInfoModel.filterWordVersion;
                if (![oldFilterVersion isEqualToString:nowFilterVersion]) {
                    [ZBInitializeRequestManager downloadFilterWordRequestCompletion:^(NSError *fail) {
                        if (fail == nil) {
                            NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *documentsDirectory = [paths objectAtIndex:0];
                            NSString *zipPath = [documentsDirectory stringByAppendingPathComponent:@"filter_word.zip"];
                            
                            NSString *destinationPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                            
                            BOOL isbool = [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
                            
                            NSString *filterPath = [documentsDirectory stringByAppendingPathComponent:@"filter_word.json"];
                            if (isbool) {
                                NSString *jsonPath = [destinationPath stringByAppendingPathComponent:@"filter_word.json"];
                                NSData *data = [NSData dataWithContentsOfFile:jsonPath];
                                NSArray *filterStringArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                [[ZBApplicationCenter defaultCenter] updateFilterWord:filterStringArray];
                                // 更新成功后删除掉旧的压缩文件
                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                
                                [fileManager removeItemAtPath:filterPath error:nil];
                                [fileManager removeItemAtPath:zipPath error:nil];
                            }
                        }
                    }];
                }
            } fail:^(NSError *err) {
                NSLog(@"%@", err);
            }];
        }
    } fail:^(NSError *err) {
        NSLog(@"%@", [err localizedDescription]);
    }];
}

#pragma mark - user authenticity
+ (void)getUserAuthenticityWithZBTicket:(NSString *)ticket completion:(void (^)(NSError *))error {
    ZBApplicationCenter *center = [ZBApplicationCenter defaultCenter];
    if ([center.ticket isEqualToString:ticket] == NO || center.userAuthenticityModel == nil) {
        [ZBInitializeRequestManager sendGetAndUpdataUserAuthenticityRequestWithTicket:ticket success:^(id data) {
            [center updataAuthenticityData:data];
            [ZBInitializeRequestManager sendGetBusinessAuthenticityRequestWithTicket:ticket success:^(id data) {
                center.ticket = ticket; // 全部逻辑成功后,将票据持久化
                
                if (error) {
                    error(nil);
                }
            } fail:^(NSError *fail) {
                if (error) {
                    error(fail);
                }
            }];
        } fail:^(NSError *fail) {
            if (error) {
                error(fail);
            }
        }];
    } else if ([center.ticket isEqualToString:ticket] == YES) {
        if (error) {
            error(nil);
        }
    }
}

#pragma mark - initialize'stream
+ (void)initializeCompletion:(void (^)(NSError *))error {
    NSString *versionSring = [ZBApplicationCenter defaultCenter].apiVersion;
    NSAssert([versionSring length] != 0, @"初始化时,api版本号为空");
    // 获取 baseURL 
    [ZBHttpRequestManager sendGetBaseURLRequestWithAPIVersion:versionSring successCallback:^(NSString *baseURL) {
        // 保存 baseURL
        NSAssert([baseURL isKindOfClass:[NSString class]] != NO, @"基础API地址类型错误");
        [ZBApplicationCenter defaultCenter].baseURL = baseURL;
        // 通过 baseURL 获取配置信息
        [ZBInitializeRequestManager sendGetConfigRequestSuccess:^(id respondData) {
            [[ZBApplicationCenter defaultCenter] saveConfigData:respondData];
            [ZBInitializeRequestManager downloadFilterWordRequestCompletion:^(NSError *fail) {
                if (fail) {
                    if (error) {
                        error(fail);
                    }
                } else {
                    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *zipPath = [documentsDirectory stringByAppendingPathComponent:@"filter_word.zip"];
                    
                    NSString *destinationPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    
                    BOOL isbool = [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
                    if (isbool) {
                        NSString *jsonPath = [destinationPath stringByAppendingPathComponent:@"filter_word.json"];
                        NSData *data = [NSData dataWithContentsOfFile:jsonPath];
                        NSArray *filterStringArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        [[ZBApplicationCenter defaultCenter] updateFilterWord:filterStringArray];
                        // 更新成功后删除掉旧的压缩文件
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSString *filterPath = [documentsDirectory stringByAppendingPathComponent:@"filter_word.json"];
                        [fileManager removeItemAtPath:filterPath error:nil];
                        [fileManager removeItemAtPath:zipPath error:nil];
                        if (error) {
                            error(nil);
                        }
                        // 解压成功后表示配置获取成功,然后成功保存配置版本号
                        [ZBApplicationCenter defaultCenter].configVersion = respondData[@"api_config_version"];
                    } else {
                        if (error) {
                            error([NSError errorWithDomain:@"unZipError" code:10089 userInfo:nil]);
                        }
                    }
                }
            }];
        } fail:^(NSError *fail) {
            if (error) {
                error(fail);
            }
        }];
    } failCallback:^(NSError *fail) {
        if (error) {
            error(fail);
        }
    }];
}

@end
