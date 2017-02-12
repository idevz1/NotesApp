
#import "VLTabBarController.h"

@implementation VLTabBarController

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

- (void)viewDidLoad
{
	[super viewDidLoad];
	if(!_initialized)
	{
		_initialized = YES;
		[self initialize];
	}
}

- (void)initialize
{
	
}

- (void)didUpdateViewAsync:(NSObject*)sender
{
	if(self.isViewLoaded)
		[self onUpdateView];
}

- (void)updateViewAsync
{
	if(!_msgrUpdateView)
	{
		_msgrUpdateView = [[VLMessenger alloc] init];
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

- (void)releaseViews
{
	
}

- (void)viewDidUnload
{
	[self releaseViews];
	[super viewDidUnload];
}

- (void)dealloc
{
	[self releaseViews];
	[_msgrUpdateView release];
    [super dealloc];
}

@end
