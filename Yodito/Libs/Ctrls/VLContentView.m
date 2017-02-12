
#import "VLContentView.h"
#import "VLCtrlsUtils.h"
#import "../Logic/Classes.h"

@implementation VLContentView

@dynamic rectContent;

- (CGRect)rectContent {
	return _rectContent;
}

- (UIViewController *)getViewControllerForView:(UIView *)view {
	UIResponder* nextResponder = [view nextResponder];
	if(nextResponder && [nextResponder isKindOfClass:[UIViewController class]]) {
		return (UIViewController*)nextResponder;
	}
	return nil;
}

- (void)setFrame:(CGRect)frame {
	CGRect rcBndsLast = self.bounds;
	[super setFrame:frame];
	CGRect rcBndsNew = self.bounds;
	if(!CGRectEqualToRect(rcBndsLast, rcBndsNew))
		[self layoutSubviews];
}

- (void)layoutSubviews {
	if(kIosVersionFloat < 7.0) {
		_rectContent = self.bounds;
		return;
	}
	CGRect rcBnds = self.bounds;
	CGRect rcCont = rcBnds;
	BOOL statusBarVisible = ![UIApplication sharedApplication].statusBarHidden;
	float statusBarHeight = MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
	CGRect rcContWnd = [self convertRect:rcCont toView:nil];
	UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if(statusBarOrientation != UIInterfaceOrientationPortrait) {
		// Need to correct rect according to orientation
		CGRect rcWnd = [UIApplication sharedApplication].keyWindow.bounds;
		float xNew = rcContWnd.origin.x;
		float yNew = rcContWnd.origin.y;
		float widthNew = rcContWnd.size.width;
		float heightNew = rcContWnd.size.height;
		if(statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
			xNew = CGRectGetMaxY(rcWnd) - rcContWnd.origin.y;
			yNew = rcContWnd.origin.x;
			widthNew = rcContWnd.size.height;
			heightNew = rcContWnd.size.width;
		} else if(statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
			xNew = rcContWnd.origin.y;
			yNew = CGRectGetMaxX(rcWnd) - CGRectGetMaxX(rcContWnd);
			widthNew = rcContWnd.size.height;
			heightNew = rcContWnd.size.width;
		} else if(statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			xNew = CGRectGetMaxX(rcWnd) - CGRectGetMaxX(rcContWnd);
			yNew = CGRectGetMaxY(rcWnd) - CGRectGetMaxY(rcContWnd);
			widthNew = rcContWnd.size.width;
			heightNew = rcContWnd.size.height;
		}
		rcContWnd.origin.x = xNew;
		rcContWnd.origin.y = yNew;
		rcContWnd.size.width = widthNew;
		rcContWnd.size.height = heightNew;
	}
	if(statusBarVisible && rcContWnd.origin.y < statusBarHeight) {
		float dh = statusBarHeight - rcContWnd.origin.y;
		rcCont.origin.y += dh;
		rcCont.size.height -= dh;
	}
	UIViewController *viewController = nil;
	UINavigationController *navigationController = nil;
	UITabBarController *tabBarController = nil;
	UIView *view = self;
	while(view) {
		UIViewController *vc = [self getViewControllerForView:view];
		if(vc) {
			if(!navigationController && [vc isKindOfClass:[UINavigationController class]]) {
				UINavigationController *navC = (UINavigationController *)vc;
				if(!navC.navigationBarHidden)
					navigationController = navC;
			} else if(!tabBarController && [vc isKindOfClass:[UITabBarController class]]) {
				tabBarController = (UITabBarController *)vc;
			} else if(!viewController) {
				viewController = vc;
			}
		}
		view = view.superview;
	}
	if(tabBarController) {
		UITabBar *tabBar = tabBarController.tabBar;
		CGRect frameTab = tabBar.frame;
		CGRect rcContTab = [self convertRect:rcCont toView:tabBar.superview];
		if(CGRectGetMaxY(rcContTab) > frameTab.origin.y) {
			float dh = CGRectGetMaxY(rcContTab) - frameTab.origin.y;
			rcCont.size.height -= dh;
		}
	}
	if(navigationController) {
		UINavigationBar *navBar = navigationController.navigationBar;
		CGRect frameBar = navBar.frame;
		CGRect rcContNav = [self convertRect:rcCont toView:navBar.superview];
		if(rcContNav.origin.y < CGRectGetMaxY(frameBar)) {
			float dh = CGRectGetMaxY(frameBar) - rcContNav.origin.y;
			rcCont.origin.y += dh;
			rcCont.size.height -= dh;
		}
	}
	_rectContent = rcCont;
}

@end




@implementation VLTabBarControllerMoreTabFixer

- (id)initWithTabBarController:(UITabBarController *)tabBarController {
	self = [super init];
	if(self) {
		_tabBarControllerRef = tabBarController;
		_timer = [[VLTimer alloc] init];
		_timer.interval = 0.1;
		[_timer setObserver:self selector:@selector(onTimerEvent:)];
		_timer.enabledAlwaysFiring = YES;
		[_timer start];
		
	}
	return self;
}

- (CGRect)getFrameForTableView:(UITableView *)tableView {
	if(_tabBarControllerRef && [_tabBarControllerRef isViewLoaded]) {
		UINavigationController *moreNVC = [_tabBarControllerRef moreNavigationController];
		if(moreNVC && [moreNVC isViewLoaded]) {
				
			CGRect rcTableOrig = tableView.frame;
			CGRect rcTableNew = rcTableOrig;
			
			UITabBar *tabBar = _tabBarControllerRef.tabBar;
			CGRect rcTabBar = tabBar.frame;
			CGRect rcToTabBar = [tableView.superview convertRect:rcTableNew toView:tabBar.superview];
			if(CGRectGetMaxY(rcToTabBar) > rcTabBar.origin.y) {
				float dh = CGRectGetMaxY(rcToTabBar) - rcTabBar.origin.y;
				rcTableNew.size.height -= dh;
			}
			
			UINavigationController *navVC = nil;
			UIView *view = tableView.superview;
			while(view) {
				UIViewController *vc = nil;
				UIResponder* nextResponder = [view nextResponder];
				if(nextResponder && [nextResponder isKindOfClass:[UIViewController class]])
					vc = (UIViewController*)nextResponder;
				if(vc) {
					if(!navVC && [vc isKindOfClass:[UINavigationController class]]) {
						UINavigationController *nvc = (UINavigationController *)vc;
						if(!nvc.navigationBarHidden) {
							navVC = nvc;
							break;
						}
					}
				}
				view = view.superview;
			}
			if(navVC && [navVC isViewLoaded]) {
				UINavigationBar *navBar = navVC.navigationBar;
				CGRect rcNavBar = navBar.frame;
				CGRect rcToNavBar = [tableView.superview convertRect:rcTableNew toView:navBar.superview];
				if(rcToNavBar.origin.y < CGRectGetMaxY(rcNavBar)) {
					float dh = CGRectGetMaxY(rcNavBar) - rcToNavBar.origin.y;
					rcTableNew.origin.y += dh;
					rcTableNew.size.height -= dh;
				}
			}
			
			return rcTableNew;
		}
	}
	return CGRectZero;
}

- (void)onTimerEvent:(id)sender {
	if(_tabBarControllerRef && [_tabBarControllerRef isViewLoaded]) {
		UINavigationController *moreNVC = [_tabBarControllerRef moreNavigationController];
		if(moreNVC && [moreNVC isViewLoaded]) {
			UITableView *tableView = (UITableView *)[VLCtrlsUtils getSubViewOfClass:[UITableView class] parentView:moreNVC.view];
			if(tableView) {
				
				if(tableView != _tableViewRegisteredForFrameChange) {
					if(_tableViewRegisteredForFrameChange) {
						[_tableViewRegisteredForFrameChange removeObserver:self forKeyPath:@"frame"];
						[_tableViewRegisteredForFrameChange release];
					}
					_tableViewRegisteredForFrameChange = [tableView retain];
					if(_tableViewRegisteredForFrameChange) {
						CGRect rectNew = [self getFrameForTableView:_tableViewRegisteredForFrameChange];
						_tableViewRegisteredForFrameChange.frame = rectNew;
						[_tableViewRegisteredForFrameChange addObserver:self forKeyPath:@"frame"
									   options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
					}
				}
			}
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	UITableView *tableView = ObjectCast(object, UITableView);
	if(tableView && tableView == _tableViewRegisteredForFrameChange && [keyPath isEqualToString:@"frame"]) {
		CGRect rectNew = [self getFrameForTableView:_tableViewRegisteredForFrameChange];
		[_tableViewRegisteredForFrameChange removeObserver:self forKeyPath:@"frame"];
		_tableViewRegisteredForFrameChange.frame = rectNew;
		[_tableViewRegisteredForFrameChange addObserver:self forKeyPath:@"frame"
					   options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)dealloc {
	[_timer release];
	[_tableViewRegisteredForFrameChange release];
	[super dealloc];
}

@end




@implementation VLTableViewFixer

- (id)initWithTableView:(UITableView *)tableView {
	self = [super init];
	if(self) {
		_tableView = [tableView retain];
		UIEdgeInsets contentInsetCurrent = _tableView.contentInset;
		UIEdgeInsets contentInsetNeeded = UIEdgeInsetsZero;
		if(!UIEdgeInsetsEqualToEdgeInsets(contentInsetCurrent, contentInsetNeeded)) {
			_tableView.contentInset = contentInsetNeeded;
		}
		[_tableView addObserver:self forKeyPath:@"contentInset"
				options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	UITableView *tableView = ObjectCast(object, UITableView);
	if(tableView && tableView == _tableView && [keyPath isEqualToString:@"contentInset"]) {
		UIEdgeInsets contentInsetCurrent = _tableView.contentInset;
		UIEdgeInsets contentInsetNeeded = UIEdgeInsetsZero;
		if(!UIEdgeInsetsEqualToEdgeInsets(contentInsetCurrent, contentInsetNeeded)) {
			[_tableView removeObserver:self forKeyPath:@"contentInset"];
			_tableView.contentInset = contentInsetNeeded;
			[_tableView addObserver:self forKeyPath:@"contentInset"
					options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
		}
	}
}

- (void)dealloc {
	if(_tableView) {
		[_tableView removeObserver:self forKeyPath:@"contentInset"];
		[_tableView release];
	}
	[super dealloc];
}

@end


