
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface VLMD5Encoder : NSObject <NSCopying, NSCoding>
{
@private
	CC_MD5_CTX _md5;
}

@property(nonatomic, readonly) CC_MD5_CTX *md5;

- (void)initMD5;

- (void)addData:(const void *)data length:(int)length;
- (void)addString:(NSString*)str;
- (void)addInt:(int)value;
- (void)addDate:(NSDate*)date;

- (void)finalMD5;

- (void)assignFrom:(VLMD5Encoder*)other;
- (id)copyWithZone:(NSZone*)zone;
- (NSComparisonResult)compare:(VLMD5Encoder*)other;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end
