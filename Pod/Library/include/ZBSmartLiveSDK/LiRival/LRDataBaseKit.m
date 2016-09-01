//
//  LRDataBaseKit.m
//  Pods
//
//  Created by lip on 16/8/15.
//
//

#import "LRDataBaseKit.h"
#import "LRDB.h"
#import "LRToolbox.h"
#import "LRException.h"
#import <objc/runtime.h>

static LRDatabase *_db;

@implementation LRDataBaseKit
+ (void)initialize {
//    NSString *path = @"/Users/lip/Desktop/MessageCenter.sqlite";
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"MessageCenter.sqlite"];
    LRLog(@"database path\n%@", path);
    _db = [LRDatabase databaseWithPath:path];
}

+ (BOOL)createTable:(Class)tableName {
    NSParameterAssert(tableName);
    BOOL result = [_db open];
    NSAssert(result != NO, @"打开数据库失败");
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);",NSStringFromClass(tableName), [LRSQLTools SQLFieldsFromClass:tableName]];
    LRLog(@"SQL:\n%@", sql);
    result = [_db executeUpdate:sql];
    [_db close];
    return result;
}

+ (BOOL)insterTable:(Class)tableName data:(id)instanceData {
    NSParameterAssert(tableName);
    BOOL result = [_db open];
    NSAssert(result != NO, @"打开数据库失败");
    if (![instanceData isKindOfClass:tableName]) {
        [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);", NSStringFromClass(tableName), [LRSQLTools SQLColumnsFromInstance:instanceData], [LRSQLTools SQLValuesFromInstance:instanceData]];
    NSArray *array = [LRSQLTools valuesFromInstance:instanceData];
    LRLog(@"SQL:\n%@\n%@", sql, array);
    result = [_db executeUpdate:sql withArgumentsInArray:array];
    [_db close];
    return result;
}

+ (BOOL)updateTable:(Class)tableName data:(id)instanceData format:(NSString *)format {
    NSParameterAssert(tableName);
    NSParameterAssert(instanceData);
    NSParameterAssert(format);
    if (![instanceData isKindOfClass:tableName]) {
        [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
    }
    BOOL result = [_db open];
    NSAssert(result != NO, @"打开数据库失败");
    NSMutableString *keyValueString = [NSMutableString string];
    NSArray *columns = [LRSQLTools columnsFromInstance:instanceData];
    for (int i = 0; i < columns.count; i++) {
        NSString *key = columns[i];
        id value = [instanceData valueForKey:key];
        if (value == nil) {
            
        } else {
            [keyValueString appendFormat:@"%@= ?,", key];
        }
    }
    
    [keyValueString deleteCharactersInRange:NSMakeRange(keyValueString.length - 1, 1)];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@;", NSStringFromClass(tableName), keyValueString,format];
    NSArray *valueArray = [LRSQLTools valuesFromInstance:instanceData];
    LRLog(@"SQL:\n%@\n%@", sql, valueArray);
    result = [_db executeUpdate:sql withArgumentsInArray:valueArray];
    [_db close];
    return result;
}

+ (BOOL)deleteTable:(Class)tableName format:(NSString *)format {
    NSParameterAssert(tableName);
    NSParameterAssert(format);
    BOOL result = [_db open];
    NSAssert(result != NO, @"打开数据库失败");
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@;", NSStringFromClass(tableName),format];
    LRLog(@"SQL:\n%@", sql);
    result = [_db executeUpdate:sql];
    [_db close];
    return result;
}

+ (NSArray *)findTable:(Class)tableName {
    NSParameterAssert(tableName);
    return [self selectTable:tableName field:nil withFormat:nil];
}

+ (NSArray *)findTable:(Class)tableName withFormat:(NSString *)format {
    NSParameterAssert(tableName);
    NSParameterAssert(format);
    return [self selectTable:tableName field:nil withFormat:format];
}

+ (NSArray *)findTable:(Class)tableName field:(NSString *)field withFormat:(NSString *)format {
    NSParameterAssert(tableName);
    NSParameterAssert(field);
    NSParameterAssert(format);
    return [self selectTable:tableName field:field withFormat:format];
}

+ (NSArray *)selectTable:(Class)tableName field:(NSString *)field withFormat:(NSString *)format {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    BOOL result = [_db open];
#pragma clang diagnostic pop
    NSAssert(result != NO, @"打开数据库失败");
    NSString *sql = nil;
    if ((field == nil || [field length] <= 0) && (format == nil || [format length] <= 0)) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    } else {
        if (field == nil || [field length] <= 0) {
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableName, format];
        }
        if (format == nil || [format length] <= 0) {
            sql = [NSString stringWithFormat:@"SELECT %@ FROM %@", field, tableName];
        }
    }
    LRLog(@"SQL:\n%@", sql);
    NSMutableArray *array = [NSMutableArray array];
    LRResultSet *resultSet = [_db executeQuery:sql];
    while ([resultSet next]) {
        NSDictionary *resultDic = [resultSet resultDictionary];
        NSArray *propertyNameArray = [LRSQLTools allPropertysWithClass:tableName][@"name"];
        NSArray *propertyTypeArray = [LRSQLTools allPropertyAttributesWithClass:tableName];
        for (int i = 0; i < propertyTypeArray.count; i ++) {
            NSString *type = propertyTypeArray[i];
            if ([type isEqualToString:@"Array"] || [type isEqualToString:@"Dictionary"]) {
                id obj = [resultDic valueForKey:propertyNameArray[i]];
                if ([obj isKindOfClass:[NSNull class]]) {
                    NSLog(@"aa");
                } else {
                    NSData * jsonData = [obj dataUsingEncoding:NSUTF8StringEncoding];
                    NSError * error=nil;
                    id parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                    [resultDic setValue:parsedData forKey:propertyNameArray[i]];
                }
            }
        }
        [array addObject:resultDic];
    }
    [_db close];
    // 将 字典对应的 值 转换为 各自 本来的 类型 例如
    
    return [NSArray arrayWithArray:array];
}

+ (NSArray *)findColumnsInTable:(Class)tableName {
    NSParameterAssert(tableName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    BOOL result = [_db open];
#pragma clang diagnostic pop
    NSAssert(result != NO, @"打开数据库失败");
    NSMutableArray *columns = [NSMutableArray array];
    LRResultSet *resultSet = [_db getTableSchema:NSStringFromClass(tableName)];
    while ([resultSet next]) {
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    [_db close];
    return [columns copy];
}

+ (BOOL)isExistInTable:(Class)tableName {
    NSParameterAssert(tableName);
    BOOL result = [_db open];
    NSAssert(result != NO, @"打开数据库失败");
    result = [_db tableExists:NSStringFromClass(tableName)];
    [_db close];
    return result;
}

+ (BOOL)clearTable:(Class)tableName {
    NSParameterAssert(tableName);
    if (![self isExistInTable:tableName]) {
        [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
    }
    BOOL result = [_db open];
    NSAssert(result != NO, @"打开数据库失败");
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@;", NSStringFromClass(tableName)];
    LRLog(@"SQL:\n%@", sql);
    result = [_db executeUpdate:sql];
    [_db close];
    return result;
}

+ (BOOL)dropTable:(Class)tableName {
    NSParameterAssert(tableName);
    if (![self isExistInTable:tableName]) {
        [LRException raiseWithLRExceptionCode:LRExceptionInvalidClass];
    }
    BOOL result = [_db open];
    NSAssert(result != NO, @"打开数据库失败");
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@;", NSStringFromClass(tableName)];
    LRLog(@"SQL:\n%@", sql);
    result = [_db executeUpdate:sql];
    [_db close];
    return result;
}

@end
