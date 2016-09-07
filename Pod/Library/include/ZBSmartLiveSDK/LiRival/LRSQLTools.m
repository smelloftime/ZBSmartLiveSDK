//
//  LRSQLTools.m
//  Pods
//
//  Created by lip on 16/8/16.
//
//

#import "LRSQLTools.h"
#import <objc/runtime.h>

#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"

@implementation LRSQLTools
+ (NSString *)SQLFieldsFromClass:(Class)class {
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self allPropertysWithClass:class];
    
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    
    for (int i=0; i< proNames.count; i++) {
        [pars appendFormat:@"%@ %@",[proNames objectAtIndex:i],[proTypes objectAtIndex:i]];
        if(i+1 != proNames.count)
        {
            [pars appendString:@","];
        }
    }
    return pars;
}

+ (NSArray *)allPropertyAttributesWithClass:(Class)class {
    NSMutableArray *proTypeArray = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        if ([propertyType hasPrefix:@"T@\"NS"]) {
            if ([propertyType hasPrefix:@"T@\"NSNumber"]) {
                [proTypeArray addObject:@"Number"];
            } else if ([propertyType hasPrefix:@"T@\"NSMutableArray"] || [propertyType hasPrefix:@"T@\"NSArray"]) {
                [proTypeArray addObject:@"Array"];
            }  else if ([propertyType hasPrefix:@"T@\"NSMutableDictionary"] || [propertyType hasPrefix:@"T@\"NSDictionary"]) {
                [proTypeArray addObject:@"Dictionary"];
            } else {
                [proTypeArray addObject:@"Other"];
            }
        } else {
            /* 暂时只支持 使用 对象类型 */
            [NSException raise:@"LRInvalidArgumentException" format:@"Unrecognized data type"];
        }
    }
    free(properties);
    
    return [NSArray arrayWithArray:proTypeArray];
}

+ (NSString *)SQLColumnsFromInstance:(id)instance {
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self allPropertysWithClass:[instance class]];
    
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    
    for (int i=0; i< proNames.count; i++) {
        id value = [instance valueForKey:proNames[i]];
        if (value != nil) {
            [pars appendFormat:@"%@,",[proNames objectAtIndex:i]];
        }
    }
    [pars deleteCharactersInRange:NSMakeRange(pars.length - 1, 1)];
    
    return pars;
}

+ (NSString *)SQLValuesFromInstance:(id)instance {
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self allPropertysWithClass:[instance class]];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    
    for (int i=0; i< proNames.count; i++) {
        id value = [instance valueForKey:proNames[i]];
        if (value != nil) {
            [pars appendString:@"?,"];
        }
    }
    [pars deleteCharactersInRange:NSMakeRange(pars.length - 1, 1)];
    return pars;
}

+ (NSArray *)columnsFromInstance:(id)instance {
    NSMutableArray *columnValues = [NSMutableArray  array];
    NSDictionary *dict = [self allPropertysWithClass:[instance class]];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    for (int i = 0; i < proNames.count; i++) {
        id value = [instance valueForKey:proNames[i]];
        if (value != nil) {
            [columnValues addObject:proNames[i]];
        }
    }
    return [NSArray arrayWithArray:columnValues];
}

+ (NSArray *)valuesFromInstance:(id)instance {
    NSMutableArray *insertValues = [NSMutableArray  array];
    NSDictionary *dict = [self allPropertysWithClass:[instance class]];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    for (int i = 0; i < proNames.count; i++) {
        id value = [instance valueForKey:proNames[i]];
        if (value != nil) {
            if ([value isKindOfClass:[NSNumber class]]) {
                [insertValues addObject:value];
            } else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSMutableString class]]) {
                [insertValues addObject:value];
            } else {
                [insertValues addObject:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:value options:0 error:nil] encoding:NSUTF8StringEncoding]];
            }
        }
    }
    return [NSArray arrayWithArray:insertValues];
}

#pragma mark - public
+ (NSDictionary *)allPropertysWithClass:(Class)class {
    NSMutableArray *proNameArray = [NSMutableArray array];
    NSMutableArray *proTypeArray = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [proNameArray addObject:propertyName];
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        if ([propertyType hasPrefix:@"T@\"NS"]) {
            if ([propertyType hasPrefix:@"T@\"NSNumber"]) {
                [proTypeArray addObject:SQLINTEGER];
            } else {
                [proTypeArray addObject:SQLTEXT];
            }
        } else {
            /* 暂时只支持 使用 对象类型 */
            [NSException raise:@"LRInvalidArgumentException" format:@"Unrecognized data type"];
        }
    }
    free(properties);
    
    return @{@"name":proNameArray,@"type":proTypeArray};
}

@end
