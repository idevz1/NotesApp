
#import "VLLogicObject.h"

@implementation VLLogicObject

@synthesize version = _version;
@dynamic msgrVersionChanged;
@dynamic parent;
@dynamic processingState;
@dynamic processing;

- (id)init
{
	self = [super init];
	if(self)
	{
		[self modifyVersion]; // First initialization
	}
	return self;
}

- (void)modifyVersion
{
	//static int64_t _currentVersion = 1;
	int64_t lastVersion = _version;
	//_version = _currentVersion++;
	_version++;
	if(lastVersion)
	{
		[self onVersionChanged];
		if(_msgrVersionChanged && [NSThread isMainThread])
			[_msgrVersionChanged postMessage];
		if(_parent)
			[_parent modifyVersion];
	}
}

- (VLMessenger*)msgrVersionChanged
{
	if(!_msgrVersionChanged)
	{
		_msgrVersionChanged = [[VLMessenger alloc] init];
		_msgrVersionChanged.owner = self;
	}
	return _msgrVersionChanged;
}

- (VLLogicObject*)parent
{
	return _parent;
}

- (void)setParent:(VLLogicObject*)newParent
{
	if(_parent != newParent)
	{
		VLLogicObject *lastParent = _parent;
		if(lastParent)
			[lastParent retain];
		_parent = newParent;
		[self onParentChanged:lastParent];
		if(lastParent)
			[lastParent release];
	}
}

- (void)onVersionChanged
{
	
}

- (void)onParentChanged:(VLLogicObject*)lastParent
{
	
}

- (void)resetParent:(VLLogicObject*)parent
{
	if(self.parent == parent)
		self.parent = nil;
}

- (EVLProcessingState)processingState
{
	return _processingState;
}
- (void)setProcessingState:(EVLProcessingState)value
{
	if(_processingState != value)
	{
		_processingState = value;
		[self modifyVersion];
	}
}

- (BOOL)processing
{
	return ([self processingState] == EVLProcessingStateProcessing);
}

- (void)dealloc
{
	self.parent = nil;
	[_msgrVersionChanged release];
	[super dealloc];
}

@end
