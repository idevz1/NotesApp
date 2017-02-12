
#import <Foundation/Foundation.h>

@interface NSCoder(VL_NSCoder_Category)

- (NSString*)decodeStringWithKey:(NSString*)key defaultValue:(NSString*)defaultValue;

- (void)encodeDate:(NSDate*)date forKey:(NSString*)key;
- (NSDate*)decodeDateWithKey:(NSString*)key defaultValue:(NSDate*)defaultValue;
- (NSDate*)decodeDateWithDefaultRefDateWithKey:(NSString*)key;

@end
