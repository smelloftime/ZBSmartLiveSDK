//
//  ZBPrefix.h
//  Pods
//
//  Created by lip on 16/8/3.
//
//

#ifndef ZBPrefix_h
#define ZBPrefix_h

#define ZBLog(format, ...) do {                                                                                 \
fprintf(stderr, "\n");          \
(NSLog)((format), ##__VA_ARGS__);                                               \
fprintf(stderr, "<%s : %d>\n%s\n",                                               \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
fprintf(stderr, "\n");           \
} while (0)

#endif /* ZBPrefix_h */
