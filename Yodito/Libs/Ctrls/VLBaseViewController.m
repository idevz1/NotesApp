
#import "VLBaseViewController.h"
#import "VLAppDelegateBase.h"
#import "VLBaseView.h"

@implementation VLBaseViewController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
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

- (id)initWithViewClass:(Class)viewClass
{
	self = [super init];
	if(self)
	{
		_viewClass = viewClass;
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

- (void)loadView
{
	[super loadView];
	if(_viewClass)
	{
		UIView *view = [[[_viewClass alloc] initWithFrame:CGRectZero] autorelease];
		self.view = view;
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	if(self.isViewLoaded)
	{
		VLBaseView *baseView = ObjectCast(self.view, VLBaseView);
		if(baseView)
			[baseView viewDidLoad];
	}
}

- (void)viewDidUnload
{
	[self releaseViews];
	[super viewDidUnload];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[VLAppDelegateBase sharedAppDelegateBase] raiseWillAnimateRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)onBecomeTopAgainInNavigation
{
	if(self.isViewLoaded)
	{
		VLBaseView *baseView = ObjectCast(self.view, VLBaseView);
		if(baseView)
			[baseView onBecomeTopAgainInNavigation];
	}
}

- (void)onPopFromNavigation
{
	
}

- (void)releaseViews
{
	
}

- (void)dealloc
{
	[self releaseViews];
	[_msgrUpdateView release];
    [super dealloc];
}

@end
