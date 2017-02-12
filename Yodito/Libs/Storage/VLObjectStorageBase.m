
#import "VLObjectStorageBase.h"
#import "../Common/Classes.h"

@implementation VLObjectStorageBase

@synthesize key = _key;
@synthesize version = _version;

- (id)initWithKey:(NSString*)key version:(int)version
{
	self = [super init];
	if(self)
	{
		_key = [key copy];
		_version = version;
	}
	return self;
}

- (void)saveDataWithRootObject:(NSObject*)rootObject
{
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeInt32:_version forKey:@"version"];
	[archiver encodeObject:rootObject forKey:@"rootObject"];
	[archiver finishEncoding];
	[archiver release];
	
	[self saveData:data];
}

- (id)loadRootObject
{
	NSData *data = [self loadData];
	if(data)
	{
		id rootObject = nil;
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		int version = [unarchiver decodeInt32ForKey:@"version"];
		if(version == _version)
		{
			rootObject = [unarchiver decodeObjectForKey:@"rootObject"];
			if(rootObject)
				[[rootObject retain] autorelease];
		}
		[unarchiver release];
		return rootObject;
	}
	return nil;
}

- (void)saveData:(NSData*)data
{
	
}

- (NSData*)loadData
{
	return nil;
}

- (void)removeData
{
	
}

- (void)dealloc
{
	[_key release];
	[super dealloc];
}

@end





