
#import "YTBaseView.h"
#import "../Ctrls/Classes.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"

@implementation YTBaseView_StatusBarBackView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
}

@end


@implementation YTBaseView

@dynamic customNavBar;
@dynamic customNavBarCreated;
@dynamic boundsNoBars;
@dynamic frameOfBar;
@synthesize stickNavigationBar = _stickNavigationBar;
@synthesize note = _note;
@synthesize resource = _resource;
@synthesize noteTag = _noteTag;
@synthesize noteEditInfo = _noteEditInfo;
@synthesize locationInfo = _locationInfo;
@synthesize objectTag = _objectTag;
@synthesize navigatingViewDelegate = _navigatingViewDelegate;

- (void)initialize {
	[super initialize];
	
	[[YTNotesEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNotesManagerChanged:)];
	[[YTNotesContentEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNotesContentManagerChanged:)];
	[[YTResourcesEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onResourcesManagerChanged:)];
	[[YTLocationsEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onLocationsManagerChanged:)];
}

- (YTNotesContentView *)parentContentView {
	YTNotesContentView *view = (YTNotesContentView *)[VLCtrlsUtils getParentViewOfClass:[YTNotesContentView class] ofView:self];
	return view;
}

- (YTCustomNavigationBar *)customNavBar {
	if(!_statusBarBackView) {
		_statusBarBackView = [[YTBaseView_StatusBarBackView alloc] initWithFrame:CGRectZero];
		[self addSubview:_statusBarBackView];
		[self setNeedsLayout];
	}
	if(!_customNavBar) {
		_customNavBar = [[YTCustomNavigationBar alloc] initWithFrame:CGRectZero];
		[self addSubview:_customNavBar];
		[self setNeedsLayout];
	}
	return _customNavBar;
}

- (BOOL)customNavBarCreated {
	return (_customNavBar != nil);
}

- (CGRect)boundsNoBars {
	CGRect res = self.bounds;
	if(res.size.width < 1 || res.size.height < 1)
		return res;
	if(_customNavBar) {
		float dy = [_customNavBar sizeThatFits:res.size].height;
		if(_navigationBarHidden)
			dy = 0;
		res.origin.y += dy;
		res.size.height -= dy;
	}
	return res;
}

- (CGRect)frameOfBar {
	CGRect rcBar = self.bounds;
	rcBar.size.height = 0;
	if(_customNavBar) {
		rcBar.size.height = [_customNavBar sizeThatFits:rcBar.size].height;
		if(_navigationBarHidden)
			rcBar.origin.y -= rcBar.size.height;
	}
	return rcBar;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	if(_customNavBar) {
		CGRect rcBar = [self frameOfBar];
		if(_customNavBar.superview == self)
			if(_stickNavigationBar) {
				CGPoint pt1 = CGPointZero;
				CGPoint pt2 = [self convertPoint:pt1 toView:[VLAppDelegateBase sharedAppDelegateBase].rootViewController.view];
				if(pt2.x > 0)
					rcBar.origin.x -= pt2.x;
			}
		if(_statusBarBackView) {
			float statusBarHeight = MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
			if(_navigationBarHidden)
				rcBar.origin.y -= statusBarHeight;
			UIView *viewRoot = [VLAppDelegateBase sharedAppDelegateBase].rootViewController.view;
			//CGRect rcBarRoot = [_customNavBar.superview convertRect:rcBar toView:viewRoot];
			CGRect rcBack = rcBar;//rcBarRoot;
			rcBack.size.height = 0;
			rcBack.origin.y = CGRectGetMaxY(rcBar);//CGRectGetMaxY(rcBarRoot);
			if(_navigationBarHidden) {
				rcBack.size.height = statusBarHeight;
			}
			if(_navigationBarHidden) {
				if(_statusBarBackView.superview != viewRoot) {
					[viewRoot addSubview:_statusBarBackView];
				}
			}
			_statusBarBackView.frame = [self convertRect:rcBack toView:_statusBarBackView.superview];
		}
		_customNavBar.frame = [self convertRect:rcBar toView:_customNavBar.superview];
	}
}

- (void)setUpdateViewMinDelay:(NSTimeInterval)updateViewMinDelay {
	_updateViewMinDelay = updateViewMinDelay;
}

- (void)resetUpdateViewMinDelay {
	_updateViewMinDelay = 0;
	_lastUpdateViewUptime = 0;
}

- (void)callOnUpdateViewYTWithDelay {
	if(!_callingOnUpdateViewYTWithDelay)
		return;
	_callingOnUpdateViewYTWithDelay = NO;
	if(_updateViewMinDelay) {
		[self onUpdateViewYT];
		_lastUpdateViewUptime = [VLTimer systemUptime];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	if(_updateViewMinDelay) {
		NSTimeInterval uptime = [VLTimer systemUptime];
		NSTimeInterval dUptime = uptime - _lastUpdateViewUptime;
		if(dUptime >= _updateViewMinDelay) {
			_callingOnUpdateViewYTWithDelay = NO;
			[self onUpdateViewYT];
			_lastUpdateViewUptime = [VLTimer systemUptime];
		} else {
			if(!_callingOnUpdateViewYTWithDelay) {
				NSTimeInterval dTime = _updateViewMinDelay - dUptime;
				_callingOnUpdateViewYTWithDelay = YES;
				[self performSelector:@selector(callOnUpdateViewYTWithDelay) withObject:nil afterDelay:dTime];
			}
		}
	} else {
		[self onUpdateViewYT];
	}
}

- (void)onUpdateViewYT {
	
}

- (void)setNote:(YTNoteInfo *)note {
	if(_note != note) {
		if(_note) {
			[_note.msgrVersionChanged removeObserver:self];
			[_note release];
		}
		_note = note;
		if(_note) {
			[_note retain];
			[_note.msgrVersionChanged addObserver:self selector:@selector(onNoteDataChanged:)];
			[self onNoteDataChanged];
		}
	}
}

- (void)onNoteDataChanged:(id)sender {
	[self onNoteDataChanged];
}

- (void)onNoteDataChanged {
	
}

- (void)setResource:(YTResourceInfo *)resource {
	if(_resource != resource) {
		if(_resource) {
			[_resource.msgrVersionChanged removeObserver:self];
			[_resource release];
		}
		_resource = resource;
		if(_resource) {
			[_resource retain];
			[_resource.msgrVersionChanged addObserver:self selector:@selector(onResourceDataChanged:)];
			[self onResourceDataChanged];
		}
	}
}

- (void)onResourceDataChanged:(id)sender {
	[self onResourceDataChanged];
}

- (void)onResourceDataChanged {
	
}

- (void)setNoteTag:(YTTagInfo *)noteTag {
	if(_noteTag != noteTag) {
		if(_noteTag) {
			[_noteTag.msgrVersionChanged removeObserver:self];
			[_noteTag release];
		}
		_noteTag = noteTag;
		if(_noteTag) {
			[_noteTag retain];
			[_noteTag.msgrVersionChanged addObserver:self selector:@selector(onNoteTagDataChanged:)];
			[self onNoteTagDataChanged];
		}
	}
}

- (void)onNoteTagDataChanged:(id)sender {
	[self onNoteTagDataChanged];
}

- (void)onNoteTagDataChanged {
	
}

- (void)setNoteEditInfo:(YTNoteEditInfo *)noteEditInfo {
	if(_noteEditInfo != noteEditInfo) {
		if(_noteEditInfo) {
			[_noteEditInfo.msgrVersionChanged removeObserver:self];
			[_noteEditInfo release];
		}
		_noteEditInfo = noteEditInfo;
		if(_noteEditInfo) {
			[_noteEditInfo retain];
			[_noteEditInfo.msgrVersionChanged addObserver:self selector:@selector(onNoteEditInfoDataChanged:)];
			[self onNoteEditInfoDataChanged];
		}
	}
}

- (void)onNoteEditInfoDataChanged:(id)sender {
	[self onNoteEditInfoDataChanged];
}

- (void)onNoteEditInfoDataChanged {
	
}

- (void)setLocationInfo:(YTLocationInfo *)locationInfo {
	if(_locationInfo != locationInfo) {
		if(_locationInfo) {
			[_locationInfo.msgrVersionChanged removeObserver:self];
			[_locationInfo release];
		}
		_locationInfo = locationInfo;
		if(_locationInfo) {
			[_locationInfo retain];
			[_locationInfo.msgrVersionChanged addObserver:self selector:@selector(onLocationInfoDataChanged:)];
			[self onLocationInfoDataChanged];
		}
	}
}

- (void)onLocationInfoDataChanged:(id)sender {
	[self onLocationInfoDataChanged];
}

- (void)onLocationInfoDataChanged {
	
}

- (void)onNotesManagerChanged:(id)sender {
	[self onNotesManagerChanged];
}
- (void)onNotesManagerChanged {
	
}

- (void)onNotesContentManagerChanged:(id)sender {
	[self onNotesContentManagerChanged];
}
- (void)onNotesContentManagerChanged {
	
}

- (void)onResourcesManagerChanged:(id)sender {
	[self onResourcesManagerChanged];
}
- (void)onResourcesManagerChanged {
	
}

- (void)onLocationsManagerChanged:(id)sender {
	[self onLocationsManagerChanged];
}
- (void)onLocationsManagerChanged {
	
}

- (void)assignEntitiesFrom:(YTBaseView *)other {
	self.note = other.note;
	self.resource = other.resource;
	self.noteTag = other.noteTag;
	self.noteEditInfo = other.noteEditInfo;
}

- (void)setNavigationBarHidden:(BOOL)hidden withStatusBarBackColor:(UIColor *)statusBarBackColor animated:(BOOL)animated {
	if(_navigationBarHidden != hidden) {
		if(_statusBarBackView && hidden)
			_statusBarBackView.backgroundColor = statusBarBackColor;
		UIApplication *application = [UIApplication sharedApplication];
		UIStatusBarStyle statusBarStyleNew = application.statusBarStyle;
		if(hidden && kIosVersionFloat >= 7.0) {
			_lastStatusBarStyle = application.statusBarStyle;
			VLColor *vlCol = [VLColor fromUIColor:statusBarBackColor];
			float lightness = [vlCol lightness];
			if(lightness < 0.5)
				statusBarStyleNew = UIStatusBarStyleLightContent;
			else
				statusBarStyleNew = UIStatusBarStyleDefault;
		}
		if(animated) {
			UIView *viewRoot = [VLAppDelegateBase sharedAppDelegateBase].rootViewController.view;
			if(_customNavBar) {
				if(_customNavBar.superview != viewRoot) {
					[viewRoot addSubview:_customNavBar];
					[self layoutSubviews];
				}
				if(_statusBarBackView.superview != viewRoot) {
					[viewRoot addSubview:_statusBarBackView];
					[self layoutSubviews];
				}
				[viewRoot bringSubviewToFront:_statusBarBackView];
				[self layoutSubviews];
			}
			[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
				_navigationBarHidden = hidden;
				if(_customNavBar) {
					_customNavBar.contentView.alpha = _navigationBarHidden ? 0.0 : 1.0;
				}
				[self layoutSubviews];
			} completion:^(BOOL finished) {
				if(finished) {
					if(_customNavBar) {
						if(_customNavBar.superview != self) {
							[self addSubview:_customNavBar];
							[self layoutSubviews];
						}
						if(!_navigationBarHidden && _statusBarBackView.superview != self) {
							[self addSubview:_statusBarBackView];
							[self layoutSubviews];
						}
					}
				}
			}];
			if(kIosVersionFloat >= 7.0)
				[application setStatusBarStyle:hidden ? statusBarStyleNew : _lastStatusBarStyle animated:YES];
		} else {
			if(kIosVersionFloat >= 7.0)
				application.statusBarStyle = hidden ? statusBarStyleNew : _lastStatusBarStyle;
			_navigationBarHidden = hidden;
			if(_customNavBar) {
				if(_customNavBar.superview != self)
					[self addSubview:_customNavBar];
				if(!_navigationBarHidden && _statusBarBackView.superview != self)
					[self addSubview:_statusBarBackView];
				_customNavBar.contentView.alpha = _navigationBarHidden ? 0.0 : 1.0;
			}
			[self setNeedsLayout];
		}
	}
}

- (void)suspendSliding:(BOOL)suspend {
	if(_slidingSuspended != suspend) {
		_slidingSuspended = suspend;
		if(_slidingSuspended)
			[[YTSlidingContainerView shared] suspendSliding];
		else
			[[YTSlidingContainerView shared] resumeSliding];
	}
}

- (void)willRemoveSubview:(UIView *)subview {
	[super willRemoveSubview:subview];
	YTBaseView *subviewBase = ObjectCast(subview, YTBaseView);
	if(subviewBase) {
		// Revert original state
		[subviewBase suspendSliding:NO];
		[subviewBase setNavigationBarHidden:NO withStatusBarBackColor:[UIColor clearColor] animated:NO];
	}
}

- (void)beginIsScrolling {
	if(!_isScrolling) {
		_isScrolling = YES;
		[[YTUiMediator shared] beginIsScrolling];
	}
}

- (void)endIsScrolling {
	if(_isScrolling) {
		_isScrolling = NO;
		[[YTUiMediator shared] endIsScrolling];
	}
}

- (void)dealloc {
	[self endIsScrolling];
	[self suspendSliding:NO];
	_navigatingViewDelegate = nil;
	[[YTNotesEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTNotesContentEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTResourcesEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTLocationsEnManager shared].msgrVersionChanged removeObserver:self];
	self.note = nil;
	self.resource = nil;
	self.noteTag = nil;
	self.noteEditInfo = nil;
	self.locationInfo = nil;
	if(_customNavBar) {
		[_customNavBar removeFromSuperview];
		[_customNavBar release];
		_customNavBar = nil;
	}
	if(_statusBarBackView) {
		[_statusBarBackView removeFromSuperview];
		[_statusBarBackView release];
		_statusBarBackView = nil;
	}
	[_objectTag release];
	[super dealloc];
}

@end
