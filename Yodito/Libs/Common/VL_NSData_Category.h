
#import <Foundation/Foundation.h>

@interface NSData(VL_NSData_Category)

/**
 * Create a NSData from a base 64 encoded data
 */
+(id) dataWithBase64Data:(NSData *)base64Data;

/**
 * Create a NSData from a base 64 encoded string
 */
+(id) dataWithBase64String:(NSString *)base64String;

/**
 * Init a NSData from a base 64 encoded data
 */
-(id) initWithBase64Data:(NSData *)base64Data;

/**
 * Create a NSData from a base 64 encoded string
 */
-(id) initWithBase64String:(NSString *)base64String;

/**
 * Get a base 64 encoded data
 */
-(NSData *)base64Data;

/**
 * Get a base 64 encoded string
 */
-(NSString *)base64String;

/**
 Convert to 'Hex' string, e.g. "2ac5e4f2"
 */
- (NSString*)toHexString;

@end
