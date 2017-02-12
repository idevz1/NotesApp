
#import "VLGuid.h"
#import "VL_NSString_Category.h"
#import <CommonCrypto/CommonDigest.h>

@implementation VLGuid

- (id)init
{
	self = [super init];
	if(self)
	{
		[self clear];
	}
	return self;
}

- (id)initUnique
{
	self = [super init];
	if(self)
	{
		[self generateUnique];
	}
	return self;
}

- (id)initWithString:(NSString*)str
{
	self = [super init];
	if(self)
	{
		[self createFromString:str];
	}
	return self;
}

- (void)clear
{
	memset(&_bytes, 0, sizeof(_bytes));
}

- (void)generateUnique
{
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	_bytes = CFUUIDGetUUIDBytes(uuidRef);
	CFRelease(uuidRef);
}

+ (VLGuid*)makeEmpty
{
	VLGuid *res = [[[VLGuid alloc] init] autorelease];
	return res;
}

+ (VLGuid*)makeUnique
{
	VLGuid *res = [[[VLGuid alloc] initUnique] autorelease];
	return res;
}

- (NSComparisonResult)compare:(VLGuid*)other
{
	int res = memcmp(&_bytes, [other bytes], sizeof(_bytes));
	return res;
}

- (CFUUIDBytes*)bytes
{
	return &_bytes;
}

- (id)copyWithZone:(NSZone *)zone
{
	VLGuid *res = [[VLGuid allocWithZone:zone] init];
	memcpy([res bytes], &_bytes, sizeof(_bytes));
	return res;
}

- (BOOL)isEqual:(id)anObject
{
	VLGuid *other = (VLGuid*)anObject;
	return ([self compare:other] == NSOrderedSame);
}

- (NSUInteger)hash
{
	NSUInteger *pBytes = ((NSUInteger*)&_bytes);
	NSUInteger hashValue = *pBytes + *(pBytes + 1);
	return hashValue;
}

- (NSString*)toString
{
	NSString* res = nil;
	CFUUIDRef uuidRef = CFUUIDCreateFromUUIDBytes(NULL, _bytes);
	CFStringRef strRef = CFUUIDCreateString(NULL, uuidRef);
	CFRelease(uuidRef);
	res = [NSString stringWithString:(NSString*)strRef];
	CFRelease(strRef);
	res = [res lowercaseString];
	return res;
}

- (void)createFromString:(NSString*)str
{
	[self clear];
	CFUUIDRef uuidRef = CFUUIDCreateFromString(NULL, (CFStringRef)str);
	if(uuidRef)
	{
		_bytes = CFUUIDGetUUIDBytes(uuidRef);
		CFRelease(uuidRef);
	}
}

+ (VLGuid*)makeFromString:(NSString*)str
{
	VLGuid* res = [[VLGuid new] autorelease];
	[res createFromString:str];
	return res;
}

- (BOOL)isEmpty
{
	CFUUIDBytes zeroBytes;
	memset(&zeroBytes, 0, sizeof(zeroBytes));
	return memcmp(&_bytes, &zeroBytes, sizeof(zeroBytes)) == 0;
}

- (VLGuid*)makeNewByAppendingGuid:(VLGuid*)other
{
	VLGuid *newGuid = [[VLGuid new] autorelease];
	unsigned* newInts = (unsigned*)[newGuid bytes];
	const unsigned* thisInts = (unsigned*)&_bytes;
	const unsigned* otherInts = (unsigned*)[other bytes];
	for(int i = 0; i < sizeof(CFUUIDBytes) / sizeof(unsigned int); i++)
		*(newInts + i) = *(thisInts + i) + *(otherInts + i);
	return newGuid;
}

- (VLGuid*)makeNewBySubtractingGuid:(VLGuid*)other
{
	VLGuid *newGuid = [[VLGuid new] autorelease];
	unsigned* newInts = (unsigned*)[newGuid bytes];
	const unsigned* thisInts = (unsigned*)&_bytes;
	const unsigned* otherInts = (unsigned*)[other bytes];
	for(int i = 0; i < sizeof(CFUUIDBytes) / sizeof(unsigned int); i++)
		*(newInts + i) = *(thisInts + i) - *(otherInts + i);
	return newGuid;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeBytes:(const uint8_t *)(&_bytes) length:sizeof(_bytes) forKey:@"g"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	NSUInteger length = 0;
	const uint8_t *pBuf = [aDecoder decodeBytesForKey:@"g" returnedLength:&length];
	if(length == sizeof(_bytes))
		memcpy(&_bytes, pBuf, length);
	return self;
}

+ (VLGuid*)makeFromMD5string:(NSString*)str
{
	VLGuid *guid = [[VLGuid new] autorelease];
	unsigned char md5[16];
	[str copyMD5toBuffer:md5];
	CFUUIDBytes *bytes = [guid bytes];
	memcpy(bytes, &md5, sizeof(md5));
	return guid;
}

@end

