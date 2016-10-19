//
//  ZBApplicationGlobal.m
//  ZhiBoLaboratory
//
//  Created by lip on 16/7/11.
//  Copyright © 2016年 ZhiBo. All rights reserved.
//

#import "ZBApplicationCenter.h"
#import "MJExtension.h"
#import "LRException.h"

#define kAppKeySaveKey          @"kAppKeySaveKey"
#define kAppTokenSaveKey        @"kAppTokenSaveKey"
#define kBaseURLSaveKey         @"kBaseURLSaveKey"
#define kConfigDataSaveKey      @"kConfigDataSaveKey"
#define kConfigVersionSaveKey   @"kConfigVersionSaveKey"
#define kApiVersionSaveKey      @"kApiVersionSaveKey"
#define kUserAuthSaveKey        @"kUserAuthSaveKey"
#define kTicketSaveKey          @"kTicketSaveKey"
#define kFilterSaveKey          @"kFilterSaveKey"
#define kBusinessAuthInfo       @"kBusinessAuthInfo"

@interface ZBApplicationCenter ()
@property (strong, nonatomic) ZBConfigInfoModel *configInfoModel;
@property (strong, nonatomic) ZBUserAuthenticityModel *userAuthenticityModel;
@property (strong, nonatomic) NSArray *filterArray;
@property (strong, nonatomic) NSDictionary *businessAuthInfo;

@end

@implementation ZBApplicationCenter
@synthesize appID = _appID;
@synthesize appToken = _appToken;
@synthesize baseURL = _baseURL;
@synthesize configVersion = _configVersion;
@synthesize ticket = _ticket;
@synthesize apiVersion = _apiVersion;
@synthesize businessAuthInfo = _businessAuthInfo;

#pragma mark - property
- (void)setAppID:(NSString *)appID {
    _appID = appID;
    [[NSUserDefaults standardUserDefaults] setValue:appID forKey:kAppKeySaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)appID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppKeySaveKey];
}

- (void)setAppToken:(NSString *)appToken {
    _appToken = appToken;
    [[NSUserDefaults standardUserDefaults] setValue:appToken forKey:kAppTokenSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)appToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppTokenSaveKey];
}

/**
 *  提交智播云分配的 APPID 到智播云 获取分配到的根地址,整个应用程序的通讯都建立在跟地址上
 *  如果没有获取到跟地址 就会默认和服务器进行通讯
 */
- (NSString *)baseURL {
    if (_baseURL == nil) {
        _baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:kBaseURLSaveKey];
    }
    return _baseURL;
}

- (void)setBaseURL:(NSString *)baseURL {
    _baseURL = baseURL;
    [[NSUserDefaults standardUserDefaults] setValue:baseURL forKey:kBaseURLSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)configVersion {
    if (_configVersion == nil) {
        _configVersion = [[NSUserDefaults standardUserDefaults] valueForKey:kConfigVersionSaveKey];
    }
    return _configVersion;
}

- (void)setConfigVersion:(NSString *)configVersion {
    _configVersion = configVersion;
    [[NSUserDefaults standardUserDefaults] setValue:configVersion forKey:kConfigVersionSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)apiVersion {
    if (_apiVersion == nil) {
        _apiVersion = [[NSUserDefaults standardUserDefaults] valueForKey:kApiVersionSaveKey];
    }
    return _apiVersion;
}

- (void)setApiVersion:(NSString *)apiVersion {
    _apiVersion = apiVersion;
    [[NSUserDefaults standardUserDefaults] setValue:apiVersion forKey:kApiVersionSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setTicket:(NSString *)ticket {
    _ticket = ticket;
    [[NSUserDefaults standardUserDefaults] setValue:ticket forKey:kTicketSaveKey];
}

- (NSString *)ticket {
    if (_ticket == nil) {
        _ticket = [[NSUserDefaults standardUserDefaults] objectForKey:kTicketSaveKey];
    }
    return _ticket;
}

- (ZBConfigInfoModel *)configInfoModel {
    if (_configInfoModel == nil) {
        NSData *jsonData = [[NSUserDefaults standardUserDefaults] valueForKey:kConfigDataSaveKey];
        if (jsonData == nil) {
            return nil;
        }
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        _configInfoModel = [ZBConfigInfoModel mj_objectWithKeyValues:dictionary];
    }
    return _configInfoModel;
}

- (ZBUserAuthenticityModel *)userAuthenticityModel {
    if (_userAuthenticityModel == nil) {
        NSData *jsonData = [[NSUserDefaults standardUserDefaults] valueForKey:kUserAuthSaveKey];
        if (jsonData == nil) {
            return nil;
        }
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        _userAuthenticityModel = [ZBUserAuthenticityModel mj_objectWithKeyValues:dictionary];
    }
    return _userAuthenticityModel;
}

- (NSDictionary *)businessAuthInfo {
    if (_businessAuthInfo == nil) {
        _businessAuthInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kBusinessAuthInfo];
    }
    return _businessAuthInfo;
}

- (NSArray *)filterArray {
    if (_filterArray == nil) {
        _filterArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFilterSaveKey];
    }
    return _filterArray;
}

#pragma mark - lifecycle

#pragma mark - means
#pragma mark └ class means
+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    static ZBApplicationCenter *onceObject;
    dispatch_once(&onceToken, ^{
        onceObject = [[ZBApplicationCenter alloc] init];
    });
    return onceObject;
}

#pragma mark └ instance means
- (void)saveRootServerAddress:(NSString *)rootServerAddress {
    NSParameterAssert(rootServerAddress);
    _rootURL = rootServerAddress;
}

- (void)saveBusinessRootServerAddress:(NSString *)businessRootServerAddress {
    NSParameterAssert(businessRootServerAddress);
    _businessRootServerAddress = businessRootServerAddress;
}

- (void)saveConfigData:(NSData *)configData {
    NSParameterAssert(configData);
    _configInfoModel = [ZBConfigInfoModel mj_objectWithKeyValues:configData];
    
    NSData *configJsonData = [NSJSONSerialization dataWithJSONObject:configData options:NSJSONWritingPrettyPrinted error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:configJsonData forKey:kConfigDataSaveKey];
}

- (void)updataAuthenticityData:(NSData *)authenticity {
    NSParameterAssert(authenticity);
    _userAuthenticityModel = [ZBUserAuthenticityModel mj_objectWithKeyValues:authenticity];
    
    NSData *configJsonData = [NSJSONSerialization dataWithJSONObject:authenticity options:NSJSONWritingPrettyPrinted error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:configJsonData forKey:kUserAuthSaveKey];
}

- (void)updataBusinessAuthenticityData:(id)businessAuthenticity {
    NSParameterAssert(businessAuthenticity);
    NSArray *tempArray = (NSArray *)businessAuthenticity;
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSDictionary *dic in tempArray) {
        [tempDic setValue:dic[@"auth_value"] forKey:dic[@"auth_key"]];
    }
    _businessAuthInfo = tempDic;
    [[NSUserDefaults standardUserDefaults] setObject:_businessAuthInfo forKey:kBusinessAuthInfo];}

- (void)updateFilterWord:(NSArray *)filterArray {
    NSParameterAssert(filterArray);
    self.filterArray = filterArray;
    [[NSUserDefaults standardUserDefaults] setObject:filterArray forKey:kFilterSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - other

@end
