//
//  LRToolbox.h
//  Pods
//
//  Created by lip on 16/8/11.
//
//

#import <Foundation/Foundation.h>

#define LRLog(format, ...) do {                                                                                 \
fprintf(stderr, "\n");          \
(NSLog)((format), ##__VA_ARGS__);                                               \
fprintf(stderr, "<%s : %d>\n%s\n",                                               \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
fprintf(stderr, "\n");           \
} while (0)

@interface LRToolbox : NSObject
/**
 *  将时间和安全口令转换为加密后的安全词
 *
 *  @param date       加密的时间
 *  @param token      云服务器返回的安全口令
 *  @param lockedWord 加密后的安全词和16进制的加密时间
 */
+ (void)transformDate:(NSDate *)date token:(NSString *)token intoLockedWord:(void(^)(NSString *hextime, NSString *lockedToken))lockedWord;

/**
 *  对时间进行加密
 *
 *  @param date       加密的时间
 *  @param lockedWord 加密后的安全词和16进制的加密时间
 */
+ (void)transformDate:(NSDate *)date intoLockedWord:(void(^)(NSString *hextime, NSString *lockedToken))lockedWord;

/**
 *  压缩数据data 为 zlib
 *
 *  @param waitCompressData 需要压缩的数据
 *
 *  @return 压缩后的 zip-data 格式的数据
 */
+ (NSData *)compressDataByZlib:(NSData *)waitCompressData;

/**
 *  解压缩 zip-data 格式的数据为 data 格式
 *
 *  @param zlibData 待解压缩的数据 需要时 zlib 格式的压缩数据
 *
 *  @return 解压缩后的数据
 */
+ (NSData *)decompressZlibData:(NSData *)zlibData;

@end
