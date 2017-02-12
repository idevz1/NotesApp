
#import "VLActivityScreen.h"
#import "VLAppDelegateBase.h"

@interface VLActivityScreen()

- (void)updateViewFrame;

@end


@implementation VLActivityScreen

+ (VLActivityScreen*)shared
{
	static VLActivityScreen *_shared = nil;
	if(!_shared)
		_shared = [[VLActivityScreen alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_activityView = [[VLActivityView alloc] initWithFrame:CGRectZero];
		_activityView.hidden = YES;
		_arrTitles = [[NSMutableArray alloc] init];
		_arrYOffsets = [[NSMutableArray alloc] init];
		[[VLAppDelegateBase sharedAppDelegateBase].ntfrWillAnimateRotationToInterfaceOrientation addObserver:self
						selector:@selector(onRotateToInterfaceOrientation:)];
	}
	return self;
}

- (void)startActivityWithTitle:(NSString *)title yOffset:(float)yOffset {
	if(++_activitylevel == 1) {
		//UIWindow *parentView = [[UIApplication sharedApplication] keyWindow];
		UIView *parentView = [VLAppDelegateBase sharedAppDelegateBase].rootViewController.view;
		//UIView *parentView = [VLAppDelegateBase sharedAppDelegateBase].topModalViewController.view; // Will may be hidden
		if(parentView && !parentView.window)
			parentView = nil;
		if(!parentView)
			parentView = [VLAppDelegateBase sharedAppDelegateBase].topModalViewController.view;
		if(parentView && !parentView.window)
			parentView = nil;
		if(!parentView)
			parentView = [[UIApplication sharedApplication] keyWindow];
		[self updateViewFrame];
		if(_activityView.superview != parentView)
			[parentView addSubview:_activityView];
		[self updateViewFrame];
	}
	if(title && title.length) {
		[_arrTitles addObject:[[title copy] autorelease]];
	} else {
		[_arrTitles addObject:[NSNull null]];
	}
	[_arrYOffsets addObject:[NSNumber numberWithFloat:yOffset]];
	_activityView.yOffset = yOffset;
	_activityView.title = title;
	if(_activitylevel == 1) {
		_activityView.hidden = NO;
		[_activityView startActivity];
	}
}

- (void)startActivityWithTitle:(NSString *)title {
	[self startActivityWithTitle:title yOffset:0];
}

- (void)startActivity
{
	[self startActivityWithTitle:nil];
}

- (void)updateViewFrame
{
	if(_activityView)
	{
		//CGRect appFrame = [[UIScreen mainScreen] bounds];//applicationFrame];
		UIView *parentView = _activityView.superview;
		if(parentView) {
			CGRect rect = parentView.bounds;
			//CGRect rc1 = [parentView convertRect:rect toView:nil];
			_activityView.frame = rect;
		}
	}
}

- (void)onRotateToInterfaceOrientation:(id)sender
{
	[self updateViewFrame];
}

- (void)stopActivity
{
	if (_activitylevel == 0)
		return;
	[_arrTitles removeLastObject];
	[_arrYOffsets removeLastObject];
	if(_arrTitles.count && _activityView) {
		_activityView.title = ObjectCast([_arrTitles lastObject], NSString);
		_activityView.yOffset = [((NSNumber *)[_arrYOffsets lastObject]) floatValue];
	}
	if (--_activitylevel == 0)
	{
		[_activityView removeFromSuperview];
		_activityView.hidden = YES;
		[_activityView stopActivity];
	}
}

- (void)dealloc
{
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrWillAnimateRotationToInterfaceOrientation removeObserver:self];
	[_activityView release];
	[_arrTitles release];
	[_arrYOffsets release];
	[super dealloc];
}

@end
