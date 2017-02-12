
#import "VLNavigationController.h"
#import "VLBaseViewController.h"

@implementation VLNavigationController

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

- (void)initialize
{
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
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

- (void)pervormRequiredSelectors
{
	UIViewController *curTopVC = self.topViewController;
	if(curTopVC != _lastTopVC)
	{
		if(_lastTopVC && ![self.viewControllers containsObject:_lastTopVC])
		{
			NSMutableArray *lastTopBaseVCS = [NSMutableArray array];
			VLBaseViewController *bvc = ObjectCast(_lastTopVC, VLBaseViewController);
			if(bvc)
				[lastTopBaseVCS addObject:bvc];
			UITabBarController *tbc = ObjectCast(_lastTopVC, UITabBarController);
			if(tbc)
			{
				for(UIViewController *vc in tbc.viewControllers)
				{
					if(!vc.isViewLoaded)
						continue;
					bvc = ObjectCast(vc, VLBaseViewController);
					if(bvc)
					{
						[lastTopBaseVCS addObject:bvc];
						continue;
					}
				}
			}
			
			NSMutableArray *newTopBaseVCS = [NSMutableArray array];
			bvc = ObjectCast(curTopVC, VLBaseViewController);
			if(bvc)
				[newTopBaseVCS addObject:bvc];
			tbc = ObjectCast(curTopVC, UITabBarController);
			if(tbc)
			{
				for(UIViewController *vc in tbc.viewControllers)
				{
					if(!vc.isViewLoaded)
						continue;
					bvc = ObjectCast(vc, VLBaseViewController);
					if(bvc)
					{
						[newTopBaseVCS addObject:bvc];
						continue;
					}
				}
			}
			
			for(VLBaseViewController *bvc in lastTopBaseVCS)
				[bvc onPopFromNavigation];
			for(VLBaseViewController *bvc in newTopBaseVCS)
				[bvc onBecomeTopAgainInNavigation];
		}
		
		[_lastTopVC release];
		_lastTopVC = curTopVC;
		if(_lastTopVC)
			[_lastTopVC retain];
	}
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[super pushViewController:viewController animated:animated];
	[self pervormRequiredSelectors];
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	UIViewController *res = [super popViewControllerAnimated:animated];
	[self pervormRequiredSelectors];
	return res;
}
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSArray *res = [self popToViewController:viewController animated:animated];
	[self pervormRequiredSelectors];
	return res;
}
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	NSArray *res = [super popToRootViewControllerAnimated:animated];
	[self pervormRequiredSelectors];
	return res;
}
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
	[super setViewControllers:viewControllers animated:animated];
	[self pervormRequiredSelectors];
}
- (void)setViewControllers:(NSArray *)viewControllers
{
	[super setViewControllers:viewControllers];
	[self pervormRequiredSelectors];
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
	[_lastTopVC release];
	[_msgrUpdateView release];
    [super dealloc];
}

@end
