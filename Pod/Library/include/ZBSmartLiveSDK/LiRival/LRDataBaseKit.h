//
//  LRDataBaseKit.h
//  Pods
//
//  Created by lip on 16/8/15.
//
//

#import <Foundation/Foundation.h>
#import "LRSQLTools.h"

@interface LRDataBaseKit : NSObject
/**
*  创建数据表
*
*  @param tableName 表的名称
*
*
*  @return 建表是否成功
*/
+ (BOOL)createTable:(Class)tableName;

/**
 *  添加数据到数据表
 *
 *  @param tableName 表的名称
 *  @param instance  添加的数据
 *
 *  @return 是够添加成功
 */
+ (BOOL)insterTable:(Class)tableName data:(id)instanceData;

/**
 *  更新数据到数据表
 *
 *  @param tableName    表名称
 *  @param instanceData 添加的数据
 *  @param format       SQL条件语句指定格式
 *
 *  @return 是否添加成功
 */
+ (BOOL)updateTable:(Class)tableName data:(id)instanceData format:(NSString *)format;

/**
 *  删除数据表的数据通过 where 的条件
 *
 *  @param tableName 表的名称
 *  @param format    SQL条件语句指定格式
 *
 *  @return 删除是否成功
 */
+ (BOOL)deleteTable:(Class)tableName format:(NSString *)format;

/**
 *  查询整张表的所有数据
 *
 *  @param tableName 表名称
 *
 *  @return 查询结果
 */
+ (NSArray *)findTable:(Class)tableName;

/**
 *  查询整个表里面满足 format 条件的数据
 *
 *  @param tableName 表名称
 *  @param format    SQL条件语句指定格式
 *
 *  @return 查询结果
 */
+ (NSArray *)findTable:(Class)tableName withFormat:(NSString *)format;

/**
 *  通过 format 格式在数据表中选择数据
 *
 *  @param tableName 表名称
 *  @param field     查询区域,如果为空表示查询全部
 *  @param format    SQL条件语句指定格式,
 *
 *  @return 查询结果
 */
+ (NSArray *)findTable:(Class)tableName field:(NSString *)field withFormat:(NSString *)format;

/**
 *  获取列名称(字段名称)
 *
 *  @return 返回字段名称
 */
+ (NSArray *)findColumnsInTable:(Class)tableName;

/**
 *  是否存在表
 *
 *  @param tableName 表名称
 *
 *  @return 存在结果
 */
+ (BOOL)isExistInTable:(Class)tableName;

/**
 *  清空表
 *
 *  @param tableName 表名称
 *
 *  @return 是够清空成功
 */
+ (BOOL)clearTable:(Class)tableName;

/**
 *  删除表
 *
 *  @param tableName 表名称
 *
 *  @return 是否删除成功
 */
+ (BOOL)dropTable:(Class)tableName;

@end
