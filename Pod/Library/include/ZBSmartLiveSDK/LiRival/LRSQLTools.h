//
//  LRSQLTools.h
//  Pods
//
//  Created by lip on 16/8/16.
//
//

#import <Foundation/Foundation.h>

@interface LRSQLTools : NSObject
//+ (NSString *)SQLForCreateLRMessageTable;
// 提供 SQL 语句
// 提供 类转换为字段
/**
 *  将一个类的属性类型转换为 SQL 字段类型,所有属性名称转换为 SQL 字段名称
 *
 *  @warning 该类属性类型只能为 NS类型,其他类型无法识别
 *
 *  @note 只能转为2种 SQL 类型,NSNumber 类型转换为 integer , 其余类型转换为 text
 *
 *  @param class 需要转换的类
 *
 *  @return 转换后的 SQL 字段语句
 */
+ (NSString *)SQLFieldsFromClass:(Class)class;
/**
 *  获取所有属性类型组成的数组
 *
 *  @param class 需要获取的类
 *
 *  @return 属性组成的数组,字典返回@"Dictionary", 数组返回@"Array",  数字返回@"Number", 其余返回@"Other"
 */
+ (NSArray *)allPropertyAttributesWithClass:(Class)class;
/**
 *  获取类的所有属性类型
 *
 *  @param class 获取的类
 *
 *  @return 获取后的属性类型, name => 所有 属性名称, type => 所有属性类型
 */
+ (NSDictionary *)allPropertysWithClass:(Class)class;
/**
 *  将实例对象有值的属性的名称转换为 SQL 字段名称
 *
 *  @warning 该类属性类型只能为 NS类型,其他类型无法识别
 *
 *  @param instance 需要转换的对象
 *
 *  @return 转换后的 SQL 字段语句
 */
+ (NSString *)SQLColumnsFromInstance:(id)instance;
/**
 *  将实例对象有值的属性的数值转换为 SQL 占位语句
 *
 *  @warning 该类属性类型只能为 NS类型,其他类型无法识别
 *
 *  @param instance 需要转换的对象
 *
 *  @return 转换后的 SQL 字段语句 例如: ?,?
 */
+ (NSString *)SQLValuesFromInstance:(id)instance;
/**
 *  将实例对象有值的属性名称组成数组
 *
 *  @param instance 实例对象
 *
 *  @return 组成的数组
 */
+ (NSArray *)columnsFromInstance:(id)instance;
/**
 *  将实例对象有值的属性的数值组成数组
 *
 *  @note 非 NSNumber 类型会被转为 json 格式的的NSString类型
 *
 *  @param instance 需要转换的对象
 *
 *  @return 转换后的数组
 */
+ (NSArray *)valuesFromInstance:(id)instance;

@end
