
#import "YTNavigationView.h"

@interface YTNavigationView_SubViewInfo : NSObject {
@private
	VLBaseView *_view;
	EYTNavigationViewAppearMode _appearMode;
}

@property(nonatomic, assign) VLBaseView *view;
@property(nonatomic, assign) EYTNavigationViewAppearMode appearMode;

@end


@implementation YTNavigationView_SubViewInfo

@synthesize view = _view;
@synthesize appearMode = _appearMode;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)setView:(VLBaseView *)view {
	if(_view != view) {
		if(_view) {
			[_view release];
			_view = nil;
		}
		if(view)
			_view = [view retain];
	}
}

- (void)dealloc {
	if(_view) {
		[_view release];
		_view = nil;
	}
	[super dealloc];
}

@end



@implementation YTNavigationView

@dynamic views;

- (void)initialize {
	[super initialize];
	_arrNavInfo = [[NSMutableArray alloc] init];
	self.clipsToBounds = YES;
}

- (NSArray *)views {
	NSMutableArray *res = [NSMutableArray arrayWithCapacity:_arrNavInfo.count];
	for(YTNavigationView_SubViewInfo *info in _arrNavInfo)
		[res addObject:info.view];
	return res;
}

- (YTNavigationView_SubViewInfo *)infoByView:(VLBaseView *)view {
	for(int i = 0; i < _arrNavInfo.count; i++) {
		YTNavigationView_SubViewInfo *info = [_arrNavInfo objectAtIndex:i];
		if(info.view == view)
			return info;
	}
	return nil;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	NSMutableArray *arrViewsPages = [NSMutableArray array];
	NSMutableArray *arrCurPage = nil;
	int curPageIndex = 0;
	for(int i = 0; i < _arrNavInfo.count; i++) {
		YTNavigationView_SubViewInfo *info = [_arrNavInfo objectAtIndex:i];
		if(info.appearMode == EYTNavigationViewAppearModeSlide)
			arrCurPage = nil;
		if(!arrCurPage) {
			arrCurPage = [NSMutableArray array];
			[arrViewsPages addObject:arrCurPage];
		}
		[arrCurPage addObject:info];
		if(i == _curIndex)
			curPageIndex = (int)[arrViewsPages indexOfObject:arrCurPage];
	}
	for(int iPage = 0; iPage < arrViewsPages.count; iPage++) {
		NSArray *page = [arrViewsPages objectAtIndex:iPage];
		for(int k = 0; k < page.count; k++) {
			YTNavigationView_SubViewInfo *info = [page objectAtIndex:k];
			CGRect rcView = rcBnds;
			rcView.origin.x += rcView.size.width * (iPage - curPageIndex);
			info.view.frame = rcView;
		}
	}
}

- (void)pushView:(VLBaseView *)view animated:(BOOL)animated appearMode:(EYTNavigationViewAppearMode)appearMode {
	YTNavigationView_SubViewInfo *info = [self infoByView:view];
	if(info)
		return;
	for(YTNavigationView_SubViewInfo *item in _arrNavInfo)
		[VLCtrlsUtils findAndResignFirstResponder:item.view];
	info = [[[YTNavigationView_SubViewInfo alloc] init] autorelease];
	info.view = view;
	info.appearMode = appearMode;
	[_arrNavInfo addObject:info];
	[self addSubview:view];
	[self layoutSubviews];
	[view layoutSubviews];
	if(animated) {
		[self layoutSubviews];
		[UIView animateWithDuration:kDefaultAnimationDuration
						 animations:^
		{
			_curIndex = (int)_arrNavInfo.count - 1;
			[self layoutSubviews];
			[view layoutSubviews];
		}
		 completion:^(BOOL finished)
		{
			if(finished) {
			}
		}];
	} else {
		_curIndex = (int)_arrNavInfo.count - 1;
		[self layoutSubviews];
	}
}

- (void)pushView:(VLBaseView *)view animated:(BOOL)animated {
	[self pushView:view animated:animated appearMode:EYTNavigationViewAppearModeSlide];
}

- (void)popView:(VLBaseView *)view animated:(BOOL)animated {
	YTNavigationView_SubViewInfo *info = [self infoByView:view];
	if(!info)
		return;
	int index = (int)[_arrNavInfo indexOfObject:info];
	if(animated) {
		if(_arrNavInfo.count > index) {
			YTNavigationView_SubViewInfo *item = [_arrNavInfo objectAtIndex:index - 1];
			[item.view onBecomeTopAgainInNavigation];
		}
		[UIView animateWithDuration:kDefaultAnimationDuration
						 animations:^
		{
			_curIndex = index - 1;
			[self layoutSubviews];
			[view layoutSubviews];
		}
		 completion:^(BOOL finished)
		{
			if(finished) {
				while(_arrNavInfo.count > index) {
					YTNavigationView_SubViewInfo *infoToDel = [_arrNavInfo lastObject];
					if(infoToDel.view.superview == self)
						[infoToDel.view removeFromSuperview];
					[_arrNavInfo removeObject:infoToDel];
				}
			}
		}];
	} else {
		while(_arrNavInfo.count > index) {
			YTNavigationView_SubViewInfo *infoToDel = [_arrNavInfo lastObject];
			if(infoToDel.view.superview == self)
				[infoToDel.view removeFromSuperview];
			[_arrNavInfo removeObject:infoToDel];
		}
		_curIndex = (int)_arrNavInfo.count - 1;
		[self layoutSubviews];
		if(_arrNavInfo.count) {
			YTNavigationView_SubViewInfo *item = [_arrNavInfo lastObject];
			[item.view onBecomeTopAgainInNavigation];
		}
	}
}

- (void)dealloc {
	[_arrNavInfo release];
	[super dealloc];
}

@end





