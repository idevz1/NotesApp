
#import "VLNavigationView.h"
#import "VLCtrlsUtils.h"

@interface VLNavigationView_SubViewInfo : NSObject {
@private
	VLBaseView *_view;
	UINavigationItem *_navItem;
	BOOL _showNavBar;
	BOOL _hideNavBarAboveTop;
}

@property(nonatomic, readonly) UINavigationItem *navItem;
@property(nonatomic, retain) VLBaseView *view;
@property(nonatomic, assign) BOOL showNavBar;
@property(nonatomic, assign) BOOL hideNavBarAboveTop;

@end


@implementation VLNavigationView_SubViewInfo

@synthesize navItem = _navItem;
@synthesize view = _view;
@synthesize showNavBar = _showNavBar;
@synthesize hideNavBarAboveTop = _hideNavBarAboveTop;

- (id)init {
	self = [super init];
	if(self) {
		_navItem = [[UINavigationItem alloc] init];
		_showNavBar = YES;
	}
	return self;
}

- (void)dealloc {
	[_navItem release];
	[_view release];
	[super dealloc];
}

@end


@implementation VLNavigationView

@dynamic navigationBar;
@dynamic views;

- (void)initialize {
	[super initialize];
	_arrNavInfo = [[NSMutableArray alloc] init];
	_navBar = [[UINavigationBar alloc] init];
	_navBar.delegate = self;
	[self addSubview:_navBar];
	
	_arrPopupViews = [[NSMutableArray alloc] init];
}

- (UINavigationBar *)navigationBar {
	return _navBar;
}

- (NSArray *)views {
	NSMutableArray *res = [NSMutableArray arrayWithCapacity:_arrNavInfo.count];
	for(VLNavigationView_SubViewInfo *info in _arrNavInfo)
		[res addObject:info.view];
	return res;
}

- (VLNavigationView_SubViewInfo *)infoByView:(VLBaseView *)view {
	for(int i = 0; i < _arrNavInfo.count; i++) {
		VLNavigationView_SubViewInfo *info = [_arrNavInfo objectAtIndex:i];
		if(info.view == view)
			return info;
	}
	return nil;
}

- (void)pushView:(VLBaseView *)view animated:(BOOL)animated showNavigationBar:(BOOL)showNavigationBar {
	if([self infoByView:view])
		return;
	[VLCtrlsUtils findAndResignFirstResponder:self];
	VLNavigationView_SubViewInfo *info = [[[VLNavigationView_SubViewInfo alloc] init] autorelease];
	info.view = view;
	info.showNavBar = showNavigationBar;
	[_arrNavInfo addObject:info];
	[_pushingInfo release];
	_pushingInfo = [info retain];
	[self addSubview:view];
	[self layoutSubviews];
	[view onNavigationItemAttached];
	[_navBar pushNavigationItem:info.navItem animated:animated];
	if(animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kDefaultAnimationDuration];
	}
	[_pushingInfo release];
	_pushingInfo = nil;
	[self layoutSubviews];
	if(animated)
		[UIView commitAnimations];
	//[_navBar pushNavigationItem:info.navItem animated:animated];
}

- (void)pushView:(VLBaseView *)view animated:(BOOL)animated {
	[self pushView:view animated:animated showNavigationBar:YES];
}

- (void)popView:(VLBaseView *)view animated:(BOOL)animated {
	VLNavigationView_SubViewInfo *info = [self infoByView:view];
	if(!info)
		return;
	[VLCtrlsUtils findAndResignFirstResponder:self];
	int infoIndex = (int)[_arrNavInfo indexOfObject:info];
	for(int i = (int)_arrNavInfo.count - 1; i > infoIndex; i--) {
		VLNavigationView_SubViewInfo *obj = [_arrNavInfo objectAtIndex:i];
		[self popView:obj.view animated:NO];
	}
	[[view retain] autorelease];
	[self layoutSubviews];
	if(animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kDefaultAnimationDuration];
	}
	[_pushingInfo release];
	_pushingInfo = [info retain];
	[self layoutSubviews];
	if(animated)
		[UIView commitAnimations];
	[[info retain] autorelease];
	[_arrNavInfo removeObjectAtIndex:_arrNavInfo.count - 1];
	
	if(_arrNavInfo.count) {
		VLNavigationView_SubViewInfo *info = [_arrNavInfo lastObject];
		VLBaseView *view = info.view;
		[view onBecomeTopAgainInNavigation];
	}
	
	[[VLMessageCenter shared] performBlock:^{
		[_pushingInfo release];
		_pushingInfo = nil;
		if(view.superview == self)
			[view removeFromSuperview];
		
	} afterDelay:kDefaultAnimationDuration*1.1 ignoringTouches:YES];
	_allowPopNavItemByDelegate = YES;
	[_navBar popNavigationItemAnimated:animated];
	_allowPopNavItemByDelegate = NO;
}

- (void)removePushedViewAtIndex:(int)index {
	if(index < 0 || index >= _arrNavInfo.count)
		return;
	VLNavigationView_SubViewInfo *info = [_arrNavInfo objectAtIndex:index];
	if(info.view.superview == self)
		[info.view removeFromSuperview];
	[_arrNavInfo removeObjectAtIndex:index];
	NSMutableArray *items = [NSMutableArray arrayWithArray:_navBar.items];
	[items removeObjectAtIndex:index];
	[_navBar setItems:items animated:NO];
	[self layoutSubviews];
}

- (void)replacePushedViewAtIndex:(int)index withView:(VLBaseView *)view {
	if(index < 0 || index >= _arrNavInfo.count)
		return;
	VLNavigationView_SubViewInfo *info = [_arrNavInfo objectAtIndex:index];
	if(info.view.superview == self)
		[info.view removeFromSuperview];
	info.view = view;
	if(info.view.superview != self)
		[self addSubview:info.view];
	[self layoutSubviews];
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
	if(_allowPopNavItemByDelegate)
		return YES;
	if(_arrNavInfo.count < 1)
		return NO;
	[[VLMessageCenter shared] performBlock:^{
		if(_arrNavInfo.count < 1)
			return;
		VLNavigationView_SubViewInfo *info = [_arrNavInfo lastObject];
		[self popView:info.view animated:YES];
	} afterDelay:0.001 ignoringTouches:YES];
	return NO;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	CGRect rcBar = rcBnds;
	rcBar.size.height = [_navBar sizeThatFits:rcBar.size].height;
	if(_arrNavInfo.count >= 2) {
		VLNavigationView_SubViewInfo *infoLast = [_arrNavInfo objectAtIndex:_arrNavInfo.count - 1];
		VLNavigationView_SubViewInfo *infoPrev = [_arrNavInfo objectAtIndex:_arrNavInfo.count - 2];
		if(_pushingInfo) {
			if(infoPrev.showNavBar != infoLast.showNavBar) {
				if(infoLast.showNavBar) {
					rcBar.origin.x = CGRectGetMaxX(rcBnds);
				}
			}
		} else {
			if(infoPrev.showNavBar != infoLast.showNavBar) {
				if(infoPrev.showNavBar) {
					rcBar.origin.x = rcBnds.origin.x - rcBar.size.width;
				}
			}
		}
	}
	VLNavigationView_SubViewInfo *curItem = _arrNavInfo.count ? [_arrNavInfo lastObject] : nil;
	if(curItem && !_pushingInfo && curItem.showNavBar && curItem.hideNavBarAboveTop)
		rcBar.origin.y = rcBnds.origin.y - rcBar.size.height;
	_navBar.frame = rcBar;
	CGRect rcViews = rcBnds;
	rcViews.origin.y = CGRectGetMaxY(rcBar);
	rcViews.size.height = CGRectGetMaxY(rcBnds) - rcViews.origin.y;
	for(int i = 0; i < _arrNavInfo.count; i++) {
		VLNavigationView_SubViewInfo *info = [_arrNavInfo objectAtIndex:i];
		UIView *view = info.view;
		CGRect rcView = rcViews;
		if(!info.showNavBar)
			rcView = rcBnds;
		rcView.origin.x -= rcViews.size.width * (_arrNavInfo.count - i - 1);
		if(_pushingInfo)
			rcView.origin.x += rcViews.size.width;
		view.frame = rcView;
	}
	
	for(int i = 0; i < _arrPopupViews.count; i++) {
		VLBaseView *view = [_arrPopupViews objectAtIndex:i];
		CGRect rcView = rcBnds;
		if(view == _presentingViewRef)
			rcView.origin.y += rcView.size.height;
		view.frame = rcView;
	}
}

- (UINavigationItem *)navigationItemForView:(VLBaseView *)view {
	VLNavigationView_SubViewInfo *info = [self infoByView:view];
	if(info)
		return info.navItem;
	return nil;
}

- (void)setNavigationBarHidden:(BOOL)hidden aboveTopForView:(VLBaseView *)view animated:(BOOL)animated {
	VLNavigationView_SubViewInfo *info = [self infoByView:view];
	if(!info)
		return;
	if(info.hideNavBarAboveTop != hidden) {
		if(animated) {
			[self layoutSubviews];
			[UIView beginAnimations:@"setNavigationBarHidden" context:self];
			[UIView setAnimationDuration:kDefaultAnimationDuration];
		}
		info.hideNavBarAboveTop = hidden;
		if(animated) {
			[self layoutSubviews];
			[UIView commitAnimations];
		} else
			[self setNeedsLayout];
	}
}

- (void)dismissPopupView:(VLBaseView *)view animated:(BOOL)animated {
	if(!_arrPopupViews.count)
		return;
	VLBaseView *viewToDismiss = [_arrPopupViews lastObject];
	if(viewToDismiss != view && ![VLCtrlsUtils isView:viewToDismiss containsView:view]) {
		return;
	}
	[VLCtrlsUtils findAndResignFirstResponder:self];
	_presentingViewRef = nil;
	[self layoutSubviews];
	if(!animated) {
		[_arrPopupViews removeObject:viewToDismiss];
		if(viewToDismiss.superview == self)
			[viewToDismiss removeFromSuperview];
		return;
	}
	[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
		_presentingViewRef = viewToDismiss;
		[self layoutSubviews];
	} completion:^(BOOL finished) {
		if(_presentingViewRef == viewToDismiss)
			_presentingViewRef = nil;
		[_arrPopupViews removeObject:viewToDismiss];
		if(viewToDismiss.superview == self)
			[viewToDismiss removeFromSuperview];
	}];
}

- (void)presentPopupView:(VLBaseView *)view animated:(BOOL)animated {
	if([_arrPopupViews containsObject:view])
		return;
	[VLCtrlsUtils findAndResignFirstResponder:self];
	[self addSubview:view];
	[_arrPopupViews addObject:view];
	if(!animated) {
		[self layoutSubviews];
		return;
	}
	_presentingViewRef = view;
	[self layoutSubviews];
	[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
		_presentingViewRef = nil;
		[self layoutSubviews];
	} completion:^(BOOL finished) {
	}];
}

- (void)dealloc {
	[_arrNavInfo release];
	[_navBar release];
	[_pushingInfo release];
	[_arrPopupViews release];
	[super dealloc];
}

@end

