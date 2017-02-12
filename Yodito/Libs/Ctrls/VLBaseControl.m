
#import "VLBaseControl.h"

@implementation VLBaseControl

- (id)init
{
    self = [super init];
	if(self)
	{
		if(!_initialized)
		{
			_initialized = YES;
			[self initialize];
		}
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		if(!_initialized)
		{
			_initialized = YES;
			[self initialize];
		}
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if(self)
	{
		if(!_initialized)
		{
			_initialized = YES;
			[self initialize];
		}
	}
	return self;
}

- (void)initialize
{
	
}

- (void)didUpdateViewAsync:(NSObject*)sender
{
	[self onUpdateView];
}

- (void)updateViewAsync
{
	if(!_msgrUpdateView)
	{
		_msgrUpdateView = [VLMessenger new];
		[_msgrUpdateView addObserver:self selector:@selector(didUpdateViewAsync:)];
	}
	[_msgrUpdateView postMessage];
}

- (void)updateViewNow
{
	if(_msgrUpdateView)
		[_msgrUpdateView cancelPostMessage];
	[self onUpdateView];
}

- (void)onUpdateView
{
	
}

- (void)dealloc
{
	[_msgrUpdateView release];
    [super dealloc];
}

@end
