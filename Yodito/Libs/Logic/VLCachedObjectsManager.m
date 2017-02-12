
#import "VLCachedObjectsManager.h"

@implementation VLCachedObjectsOwner

- (id)init
{
	self = [super init];
	if(self)
	{
		[[VLCachedObjectsManager shared] registerObject:self];
	}
	return self;
}
- (void)freeUnusedMemory
{
	
}
- (void)dealloc
{
	[[VLCachedObjectsManager shared] unregisterObject:self];
	[super dealloc];
}

@end



@implementation VLCachedObjectHolder

@dynamic object;

- (id)object
{
	return _object;
}
- (void)setObject:(id)value
{
	if(_object != value)
	{
		[self releaseObject];
		_object = value;
		if(_object)
			[_object retain];
	}
}
- (void)releaseObject
{
	if(_object)
	{
		[_object release];
		_object = nil;
	}
}
- (void)freeUnusedMemory
{
	[self releaseObject];
}
- (void)dealloc
{
	[self releaseObject];
	[super dealloc];
}

@end




@implementation VLCachedObjectsManager

+ (VLCachedObjectsManager*)shared
{
	static VLCachedObjectsManager *_shared = nil;
	if(!_shared)
		_shared = [VLCachedObjectsManager new];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		CFArrayCallBacks acb = { 0, NULL, NULL, CFCopyDescription, CFEqual };
		_objects = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &acb);
		_objectsVersion = 1;
	}
	return self;
}

- (void)registerObject:(VLCachedObjectsOwner*)obj
{
	[_objects addObject:obj];
	_objectsVersion++;
}

- (void)unregisterObject:(VLCachedObjectsOwner*)obj
{
	[_objects removeObject:obj];
	_objectsVersion++;
}

- (void)freeUnusedMemory
{
	int64_t lastVers = 0;
	while(lastVers != _objectsVersion)
	{
		lastVers = _objectsVersion;;
		for(VLCachedObjectsOwner *obj in _objects)
		{
			[obj freeUnusedMemory];
			if(lastVers != _objectsVersion)
				break;
		}
	}
}

- (void)dealloc
{
	[_objects release];
	[super dealloc];
}


@end
