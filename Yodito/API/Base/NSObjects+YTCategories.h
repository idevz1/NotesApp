
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

@interface VLDate (YTCategory)

- (NSString *)yoditoToString;
+ (VLDate *)yoditoDateWithString:(NSString *)str;

@end


@interface VLDateNoTime (YTCategory)

- (NSString *)yoditoToString;
+ (VLDateNoTime *)yoditoFromString:(NSString *)str;

@end


@interface NSDictionary(YTCategory)

- (BOOL)yoditoBoolValueForKey:(id)key defaultVal:(BOOL)defaultVal;
- (VLDate *)yoditoDateValueForKey:(id)key defaultVal:(VLDate *)defaultVal;

@end


@interface VLGuid(YTCategory)

- (NSString *)yoditoToString;

@end


@interface NSString(YTCategory)

- (NSString *)yoditoCutServerUrl;

@end



