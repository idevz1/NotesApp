
#import "VLCachedDictionary.h"

@implementation VLCachedDictionary

@synthesize maxSize = _maxSize;

- (id)init
{
	self = [super init];
	if(self) {
		_maxSize = 100;
		_map = [NSMutableDictionary new];
		_keys = [NSMutableArray new];
	}
	return self;
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	while([_keys count] && [_keys count] > _maxSize)
	{
		id key = [_keys objectAtIndex:0];
		[_map removeObjectForKey:key];
		[_keys removeObjectAtIndex:0];
	}
	bool contained = ([_map objectForKey:aKey] != nil);
	[_map setObject:anObject forKey:aKey];
	if(!contained)
		[_keys addObject:aKey];
	else
		[self pushToFront:(id)aKey];
}

- (id)objectForKey:(id)aKey
{
	id obj = [_map objectForKey:aKey];
	if(!obj)
		return nil;
	[self pushToFront:(id)aKey];
	return obj;
}

- (void)pushToFront:(id)aKey
{
	for(int i = (int)[_keys count] - 1; i >= 0; i--)
	{
		if([_keys objectAtIndex:i] == aKey)
		{
			if(i != [_keys count] - 1)
			{
				[aKey retain];
				[_keys removeObjectAtIndex:i];
				[_keys addObject:aKey];
				[aKey release];
			}
			break;
		}
	}
}

- (void)clear
{
	[_map removeAllObjects];
	[_keys removeAllObjects];
}

- (void)freeUnusedMemory
{
	[self clear];
}

- (void)dealloc
{
	[_map release];
	[_keys release];
	[super dealloc];
}

@end
