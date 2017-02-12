
#import <Foundation/Foundation.h>

@interface VLGuid : NSObject <NSCopying, NSCoding>
{
	CFUUIDBytes _bytes;
}

- (id)initUnique;
- (id)initWithString:(NSString*)str;
- (void)clear;
- (void)generateUnique;
+ (VLGuid*)makeEmpty;
+ (VLGuid*)makeUnique;
- (NSUInteger)hash;
- (NSComparisonResult)compare:(VLGuid*)other;
- (BOOL)isEqual:(VLGuid*)other;
- (CFUUIDBytes*)bytes;
- (id)copyWithZone:(NSZone *)zone;
- (NSString*)toString;
- (void)createFromString:(NSString*)str;
+ (VLGuid*)makeFromString:(NSString*)str;
- (BOOL)isEmpty;
- (VLGuid*)makeNewByAppendingGuid:(VLGuid*)other;
- (VLGuid*)makeNewBySubtractingGuid:(VLGuid*)other;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
+ (VLGuid*)makeFromMD5string:(NSString*)str;


@end

