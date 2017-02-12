
#import "VLMD5Encoder.h"
#import "VLCommon.h"

@implementation VLMD5Encoder

@dynamic md5;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if(self)
	{
		if(aDecoder)
		{
			NSUInteger length = 0;
			const uint8_t *buffer = [aDecoder decodeBytesForKey:@"_md5" returnedLength:&length];
			assert(length);
            memcpy(&_md5, buffer, length);
		}
		else
			memset(&_md5, sizeof(_md5), 0);
	}
	return self;
}
- (id)init
{
	return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeBytes:(const void*)&_md5 length:sizeof(_md5) forKey:@"_md5"];
}

- (CC_MD5_CTX*)md5
{
	return &_md5;
}

- (void)initMD5
{
	CC_MD5_Init(&_md5);
}

- (void)addData:(const void *)data length:(int)length
{
	CC_MD5_Update(&_md5, data, length);
}

- (void)addString:(NSString*)str
{
	if(!str)
		return;
	const char *cStr = [str UTF8String];
	[self addData:cStr length:(int)strlen(cStr)];
}

- (void)addInt:(int)value
{
	[self addData:&value length:sizeof(value)];
}

- (void)addDate:(NSDate*)date
{
	if(!date)
		return;
	double seconds = [date timeIntervalSinceReferenceDate];
	[self addData:&seconds length:sizeof(seconds)];
}

- (void)finalMD5
{
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &_md5);
}

- (void)assignFrom:(VLMD5Encoder*)other
{
	memcpy(&_md5, other.md5, sizeof(_md5));
}

- (id)copyWithZone:(NSZone*)zone
{
	VLMD5Encoder *copy = [[VLMD5Encoder allocWithZone:zone] init];
	[copy assignFrom:self];
	return copy;
}

- (NSComparisonResult)compare:(VLMD5Encoder*)other
{
	int res = memcmp(&_md5, other.md5, sizeof(_md5));
	if(res > 0)
		res = 1;
	if(res < 0)
		res = -1;
	return res;
}

- (BOOL)isEqual:(id)object
{
	VLMD5Encoder *other = ObjectCast(object, VLMD5Encoder);
	if(!other)
		return NO;
	return [self compare:other] == 0;
}

- (NSUInteger)hash
{
	NSUInteger *pBytes = ((NSUInteger*)&_md5);
	NSUInteger hashValue = *pBytes + *(pBytes + 1);
	return hashValue;
}

- (void)dealloc
{
	[super dealloc];
}

@end
