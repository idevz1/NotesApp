
#import "VLBaseView.h"
#import "../Drawing/Classes.h"
#import "VLNavigationView.h"
#import "VLCtrlsUtils.h"
#import "VLNavigationView.h"

@implementation VLBaseView

@dynamic viewController;

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

- (void)viewDidLoad
{
	
}

- (void)onBecomeTopAgainInNavigation
{
	
}

- (UIViewController*)viewController
{
	for(UIView *next = self; next; next = next.superview)
	{
		UIResponder* nextResponder = [next nextResponder];
		if(nextResponder && [nextResponder isKindOfClass:[UIViewController class]])
		{
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}

- (UINavigationItem *)navigationItem
{
	VLNavigationView *navView = (VLNavigationView *)[VLCtrlsUtils getParentViewOfClass:[VLNavigationView class] ofView:self];
	if(navView) {
		UINavigationItem *navItem = [navView navigationItemForView:self];
		if(navItem)
			return navItem;
	}
	return nil;
}

- (void)onNavigationItemAttached {
	
}

- (VLNavigationView *)navigationView {
	VLNavigationView *navView = (VLNavigationView *)[VLCtrlsUtils getParentViewOfClass:[VLNavigationView class] ofView:self];
	return navView;
}

- (void)dealloc
{
	[_msgrUpdateView release];
    [super dealloc];
}

@end



@implementation VLBaseDrawableView

@synthesize drawDelegate = _drawDelegate;

- (void)drawRect:(CGRect)rect
{
	if(_drawDelegate && [_drawDelegate respondsToSelector:@selector(VLBaseDrawableView:drawRect:)])
	{
		[_drawDelegate performSelector:@selector(VLBaseDrawableView:drawRect:)
							withObject:self
							withObject:[VLRect makeWithCGRect:rect]];
	}
	else
		[super drawRect:rect];
}

@end



