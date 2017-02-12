
#import "YTNoteAttachmentsView.h"
#import "../Ctrls/Classes.h"
#import "YTNoteResourcesListView.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "AppDelegate.h"
#define kBarHeight 44.0
#define kButtonDisabledAlpha 0.33
#define kBackColor [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define kBarBackColor [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0]

@implementation YTNoteAttachmentsView

@synthesize editMode = _editMode;

- (void)initialize {
	[super initialize];
	self.backgroundColor = kBackColor;
	self.clipsToBounds = YES;
	_barsVisible = YES;
	
	_topBar = [[UIView alloc] initWithFrame:CGRectZero];
	_topBar.backgroundColor = kBarBackColor;
	[self addSubview:_topBar];
	
	_borderBack = [[YTFigureView alloc] initWithFrame:CGRectZero];
	_borderBack.type = EYTFigureViewTypeRoundedFilledRect;
	//_borderBack.lineColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
	_borderBack.fillColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.25];
	_borderBack.cornerRadius = 6;
	_borderBack.padding = UIEdgeInsetsMake(8, 12, 8, 12);
	[self addSubview:_borderBack];
	
	_btnBack = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_btnBack setTitle:NSLocalizedString(@"Done {Button}", nil) forState:UIControlStateNormal];
	[_btnBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_btnBack addTarget:self action:@selector(onBtnBackTap:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_btnBack];
	
	_borderDelete = [[YTFigureView alloc] initWithFrame:CGRectZero];
	_borderDelete.type = _borderBack.type;
	_borderDelete.fillColor = _borderBack.fillColor;
	_borderDelete.cornerRadius = _borderBack.cornerRadius;
	_borderDelete.padding = _borderBack.padding;
	[self addSubview:_borderDelete];
	
	_btnDelete = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_btnDelete.hidden = YES;
	//[_btnDelete setTitle:NSLocalizedString(@"Delete {Button}", nil) forState:UIControlStateNormal];
	//[_btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_btnDelete setImage:[UIImage imageNamed:@"button_toolbar_trash_white.png"] forState:UIControlStateNormal];
	[_btnDelete addTarget:self action:@selector(onBtnDeleteTap:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_btnDelete];
	
	_bottomBar = [[UIView alloc] initWithFrame:CGRectZero];
	_bottomBar.backgroundColor = kBarBackColor;
	[self addSubview:_bottomBar];
	
	_borderArrows = [[YTFigureView alloc] initWithFrame:CGRectZero];
	_borderArrows.type = _borderBack.type;
	_borderArrows.fillColor = _borderBack.fillColor;
	_borderArrows.cornerRadius = _borderBack.cornerRadius;
	_borderArrows.padding = _borderBack.padding;
	[self addSubview:_borderArrows];
	
	_btnPrev = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_btnPrev setImage:[UIImage imageNamed:@"bbi_back.png" scale:2] forState:UIControlStateNormal];
	[_btnPrev addTarget:self action:@selector(onBbiPrevTap:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_btnPrev];
	
	_btnNext = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_btnNext setImage:[UIImage imageNamed:@"bbi_next.png" scale:2] forState:UIControlStateNormal];
	[_btnNext addTarget:self action:@selector(onBbiNextTap:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_btnNext];
	
	_lbTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_lbTitle.backgroundColor = [UIColor clearColor];
	_lbTitle.textAlignment = NSTextAlignmentCenter;
	_lbTitle.baselineAdjustment =UIBaselineAdjustmentAlignCenters;
	_lbTitle.textColor = [UIColor whiteColor];
	[self addSubview:_lbTitle];
	
	[self enableButton:_btnPrev enable:NO];
	[self enableButton:_btnNext enable:NO];
	
	_resources = [[NSMutableArray alloc] init];
	_arrViews = [[NSMutableArray alloc] init];
	_curIndex = -1;
	
	UISwipeGestureRecognizer *swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)] autorelease];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	[self addGestureRecognizer:swipeLeft];
	
	UISwipeGestureRecognizer *swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)] autorelease];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	[self addGestureRecognizer:swipeRight];
	
	UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease];
	[self addGestureRecognizer:tap];
	
	if(kIosVersionFloat >= 7.0) {
		_statusBarBackViewNAW = [[UIView alloc] initWithFrame:CGRectZero];
		_statusBarBackViewNAW.backgroundColor = kBackColor;
	}
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[[YTResourcesEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNoteDataChanged)];
	[[YTUiMediator shared].msgrFileCantBeViewedAlerted addObserver:self selector:@selector(onFileCantBeViewedAlerted:)];
	
	[self suspendSliding:YES];
	
	[self updateViewAsync];
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	if(kYTHideStatusBarWhenShowPhotos) {
		[[VLMessageCenter shared] performBlock:^{
			[[self parentContentView] setStatusBarBackVisible:NO animated:YES animations:^{
				[self layoutSubviews];
			}];
		} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
	}
}

- (void)updateFonts:(id)sender {
	_btnBack.titleLabel.font = [[YTFontsManager shared] boldFontWithSize:14 fixed:YES];
	_lbTitle.font = [[YTFontsManager shared] boldFontWithSize:15 fixed:YES];
	[self setNeedsLayout];
}

- (void)enableButton:(UIButton *)button enable:(BOOL)enable {
	button.userInteractionEnabled = enable;
	button.alpha = enable ? 1.0 : kButtonDisabledAlpha;
}

- (void)onNavigationItemAttached {
	[super onNavigationItemAttached];
	//[self updateViewNow];
}

- (void)setEditMode:(BOOL)editMode {
	if(_editMode != editMode) {
		_editMode = editMode;
		_btnDelete.hidden = !_editMode;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	if(kIosVersionFloat >= 7.0) {
		//float statusBarHeight = MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
		//rcBnds.origin.y -= statusBarHeight;
		//rcBnds.size.height += statusBarHeight;
	}
	
	CGRect rcTopBar = rcBnds;
	rcTopBar.size.height = kBarHeight;
	
	CGRect rcBotBar = rcBnds;
	rcBotBar.size.height = kBarHeight;
	rcBotBar.origin.y = CGRectGetMaxY(rcBnds) - rcBotBar.size.height;
	
	if(!_barsVisible) {
		rcTopBar.origin.y -= rcTopBar.size.height;
		rcBotBar.origin.y += rcBotBar.size.height;
	}
	_topBar.frame = rcTopBar;
	_bottomBar.frame = rcBotBar;
	
	CGRect rcBtnDelete = rcTopBar;
	rcBtnDelete.size.width = rcBtnDelete.size.height * 1.25;
	_btnDelete.frame = [UIScreen roundRect:rcBtnDelete];
	CGRect rcBtnBorderDel = rcBtnDelete;
	rcBtnBorderDel.size.height *= 1.05;
	rcBtnBorderDel.size.width *= 1.1;
	rcBtnBorderDel.origin.x = CGRectGetMidX(rcBtnDelete) - rcBtnBorderDel.size.width/2;
	rcBtnBorderDel.origin.y = CGRectGetMidY(rcBtnDelete) - rcBtnBorderDel.size.height/2;
	_borderDelete.frame = [UIScreen roundRect:rcBtnBorderDel];
	
	CGRect rcBtnBack = rcTopBar;
	rcBtnBack.size.width = rcBtnBack.size.height * 2;
	rcBtnBack.origin.x = CGRectGetMaxX(rcTopBar) - rcBtnBack.size.width;
	_btnBack.frame = [UIScreen roundRect:rcBtnBack];
	_borderBack.frame = [UIScreen roundRect:rcBtnBack];
	
	CGRect rcLbTitle = rcBotBar;
	rcLbTitle.size.width = [_lbTitle sizeOfText].width;
	rcLbTitle.origin.x = CGRectGetMidX(rcBotBar) - rcLbTitle.size.width/2;
	_lbTitle.frame = [UIScreen roundRect:rcLbTitle];
	float distX = 8.0;
	CGRect rcBtnPrev = rcBotBar;
	rcBtnPrev.size.width = rcBtnPrev.size.height*2;
	rcBtnPrev.origin.x = rcLbTitle.origin.x - distX - rcBtnPrev.size.width;
	_btnPrev.frame = [UIScreen roundRect:rcBtnPrev];
	CGRect rcBtnNext = rcBotBar;
	rcBtnNext.size.width = rcBtnNext.size.height*2;
	rcBtnNext.origin.x = CGRectGetMaxX(rcLbTitle) + distX;
	_btnNext.frame = [UIScreen roundRect:rcBtnNext];
	
	CGRect rcArrowsBack = rcBotBar;
	rcArrowsBack.origin.x = rcBtnPrev.origin.x + distX;
	rcArrowsBack.size.width = CGRectGetMaxX(rcBtnNext) - distX - rcArrowsBack.origin.x;
	rcArrowsBack.size.height = rcBtnBack.size.height;
	rcArrowsBack.origin.y = CGRectGetMidY(rcBtnPrev) - rcArrowsBack.size.height/2;
	_borderArrows.frame = [UIScreen roundRect:rcArrowsBack];
	
	CGRect rcInner = rcBnds;
	//rcInner.origin.y = CGRectGetMaxY(rcTopBar);
	//rcInner.size.height = rcBotBar.origin.y - rcInner.origin.y;
	for(int i = 0; i < _arrViews.count; i++) {
		YTCachedContentView *view = [_arrViews objectAtIndex:i];
		CGRect rcView = rcInner;
		rcView.origin.x += rcView.size.width * (i - _curIndex);
		view.frame = rcView;
		if(CGRectIntersectsRect(rcBnds, rcView))
			[view checkContentViewCreated];
	}
	
	if(_statusBarBackViewNAW) {
		float statusBarHeight = MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
		if(statusBarHeight == 0)
			statusBarHeight = 20.0;
		//UIView *homeView = [self parentContentView];
		UIView *homeView = [VLAppDelegateBase sharedAppDelegateBase].rootViewController.view;
		CGRect rect = self.bounds;
		rect.size.height = statusBarHeight;
		rect.origin.y -= rect.size.height;
		rect = [self convertRect:rect toView:homeView];
		_statusBarBackViewNAW.frame = rect;
		if(_statusBarBackViewNAW.superview != homeView)
			[homeView addSubview:_statusBarBackViewNAW];
	}
}

- (void)setBarsVisible:(BOOL)barsVisible animated:(BOOL)animated {
	if(_barsVisible != barsVisible) {
		if(animated) {
			[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
				_barsVisible = barsVisible;
				[self layoutSubviews];
			} completion:^(BOOL finished) {
				if(finished) {
					
				}
			}];
		} else {
			_barsVisible = barsVisible;
			[self setNeedsLayout];
		}
	}
}

- (NSArray *)resources {
	if(_editMode) {
		NSMutableArray *resources = [NSMutableArray arrayWithArray:self.noteEditInfo.resourcesNew];
		for(int i = (int)resources.count - 1; i >= 0; i--) {
			YTResourceInfo *res = [resources objectAtIndex:i];
			if([res isThumbnail]) {
				[resources removeObjectAtIndex:i];
				continue;
			}
			if(![res isImage] && !kYTAllowOpenNonImageResources) {
				[resources removeObjectAtIndex:i];
				continue;
			}
		}
		return resources;
	}
	YTNoteInfo *note = self.note;
	if(!note)
		return [NSArray array];
	NSMutableArray *resources = [NSMutableArray array];
	for(YTResourceInfo *info in [[YTResourcesEnManager shared] getResourcesForNoteWithGuid:note.noteGuid].allValues) {
		if([info isThumbnail])
			continue;
		if(![info isImage] && !kYTAllowOpenNonImageResources)
			continue;
		if(!_editMode && info.isTemporary)
			continue;
		[resources addObject:info];
	}
	[YTNoteResourcesListView sortResources:resources optionalMainResource:nil];
	[_resources removeAllObjects];
	[_resources addObjectsFromArray:resources];
	return resources;
}

- (void)onUpdateView {
	[super onUpdateView];
	NSMutableArray *resources = [NSMutableArray arrayWithArray:[self resources]];
	if(resources.count != _arrViews.count) {
		for(YTCachedContentView *view in _arrViews)
			[view removeFromSuperview];
		[_arrViews removeAllObjects];
		for(YTResourceInfo *resource in resources) {
			YTCachedContentView *view = [[[YTCachedContentView alloc] initWithFrame:CGRectZero] autorelease];
			[view setContentViewClass:[YTResourceView class]];
			[_arrViews addObject:view];
			[self addSubview:view];
			[self sendSubviewToBack:view];
			view.resource = resource;
		}
		[self setNeedsLayout];
	}
	if(_curIndex > _arrViews.count) {
		_curIndex = (int)_arrViews.count - 1;
		[self setNeedsLayout];
	}
	[self enableButton:_btnPrev enable:(resources.count > 0) && (_curIndex > 0)];
	[self enableButton:_btnNext enable:(resources.count > 0) && (_curIndex < _arrViews.count - 1)];
	_btnPrev.hidden = _btnNext.hidden = _borderArrows.hidden = (resources.count <= 1);
	NSString *title = @"";
	if(_curIndex >= 0 && _curIndex < resources.count && resources.count > 1) {
		NSString *sFormat = NSLocalizedString(@"%d / %d", nil);
		title = [NSString stringWithFormat:sFormat, _curIndex + 1, resources.count];
	}
	if(![_lbTitle.text isEqual:title]) {
		_lbTitle.text = title;
		[self setNeedsLayout];
	}
	if(_btnDelete)
		_btnDelete.hidden = _borderDelete.hidden = !(_editMode && _arrViews.count);
	if(![self canHideBars])
		[self setBarsVisible:YES animated:YES];
}

- (BOOL)canHideBars {
	if(_arrViews.count < 1)
		return NO;
	if(_curIndex >= 0 && _curIndex < _resources.count) {
		YTResourceInfo *resource = [_resources objectAtIndex:_curIndex];
		if(![resource isImage])
			return NO;
		return YES;
	}
	return NO;
}

- (void)setCurIndex:(int)newCurIndex animated:(BOOL)animated {
	if(!_arrViews.count) {
		_curIndex = 0;
		return;
	}
	if(newCurIndex < 0)
		newCurIndex = 0;
	if(newCurIndex >= _arrViews.count)
		newCurIndex = (int)_arrViews.count - 1;
	if(_curIndex != newCurIndex) {
		if(animated) {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:kDefaultAnimationDuration];
		}
		_curIndex = newCurIndex;
		[self updateViewNow];
		[self layoutSubviews];
		if(animated) {
			[UIView commitAnimations];
		}
	}
}

- (void)setCurrentResource:(YTResourceInfo *)res {
	[self updateViewNow];
	int index = -1;
	for(YTCachedContentView *view in _arrViews)
		if(view.resource == res)
			index = (int)[_arrViews indexOfObject:view];
	if(index >= 0)
		[self setCurIndex:index animated:NO];
}

- (BOOL)isCurrentImageResourceShown {
	if(_curIndex >= 0 && _curIndex < _arrViews.count) {
		YTCachedContentView *contView = [_arrViews objectAtIndex:_curIndex];
		YTResourceView *resView = ObjectCast(contView.contentView, YTResourceView);
		if(resView) {
			if([resView isImageShown])
				return YES;
		}
	}
	return NO;
}

- (void)onNoteDataChanged {
	[super onNoteDataChanged];
	[self updateViewAsync];
}

- (void)onNoteEditInfoDataChanged {
	[super onNoteEditInfoDataChanged];
	[self updateViewAsync];
}

- (void)onBbiPrevTap:(id)sender {
	[self setCurIndex:_curIndex - 1 animated:YES];
}

- (void)onBbiNextTap:(id)sender {
	[self setCurIndex:_curIndex + 1 animated:YES];
}

- (void)onSwipeLeft:(UISwipeGestureRecognizer *)swipe {
	if(swipe.state == UIGestureRecognizerStateRecognized) {
		[self setCurIndex:_curIndex + 1 animated:YES];
	}
}

- (void)onSwipeRight:(UISwipeGestureRecognizer *)swipe {
	if(swipe.state == UIGestureRecognizerStateRecognized) {
		[self setCurIndex:_curIndex - 1 animated:YES];
	}
}

- (void)onTap:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized) {
		CGPoint pt = [tap locationInView:self];
		for(UIView *view in [NSArray arrayWithObjects:_borderBack, _btnBack, _borderDelete, _btnDelete, _btnPrev, _btnNext, nil]) {
			if(CGRectContainsPoint([self convertRect:view.bounds fromView:view], pt))
				return;
		}
		[self setBarsVisible:(!_barsVisible || ![self canHideBars]) animated:YES];
	}
}

- (void)onBtnDeleteTap:(id)sender {
	NSArray *resources = [self resources];
	YTResourceInfo *res = [resources objectAtIndex:_curIndex];
	VLActionSheet *actions = [[[VLActionSheet alloc] init] autorelease];
	[actions addButtonWithTitle:NSLocalizedString(@"Delete {Button}", nil)];
	[actions addButtonWithTitle:NSLocalizedString(@"Cancel {Button}", nil)];
	actions.destructiveButtonIndex = 0;
	actions.cancelButtonIndex = 1;
	[actions showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle) {
		if(btnIndex == 0) {
			[self.noteEditInfo removeResourceNew:res];
			YTResourceInfo *resThumb = [[YTResourcesEnManager shared] thumbnailForImage:res];
			if(resThumb) {
				[self.noteEditInfo removeResourceNew:resThumb];
			}
			[self updateViewNow];
			[self setNeedsLayout];
			if(_curIndex >= _arrViews.count && _arrViews.count)
				[self setCurIndex:(int)_arrViews.count - 1 animated:YES];
		}
	}];
}

- (void)onBtnBackTap:(id)sender {
    NSLog(@"plm");

	if(kYTHideStatusBarWhenShowPhotos) {
		[[self parentContentView] setStatusBarBackVisible:YES animated:YES animations:^{
			[self layoutSubviews];
		}];
	}
	[[VLMessageCenter shared] performBlock:^{
		[self suspendSliding:NO];
		[[self parentContentView] popView:self animated:YES];
	} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [[AppDelegate instance]changeBackTo];
    }
}

- (void)onFileCantBeViewedAlerted:(id)sender {
	[self setBarsVisible:YES animated:YES];
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTResourcesEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTUiMediator shared].msgrFileCantBeViewedAlerted removeObserver:self];
	if(_statusBarBackViewNAW) {
		if(_statusBarBackViewNAW.superview)
			[_statusBarBackViewNAW removeFromSuperview];
		[_statusBarBackViewNAW release];
	}
	[_topBar release];
	[_borderBack release];
	[_btnBack release];
	[_borderDelete release];
	[_btnDelete release];
	[_bottomBar release];
	[_btnPrev release];
	[_btnNext release];
	[_lbTitle release];
	[_borderArrows release];
	[_resources release];
	[_arrViews release];
	[super dealloc];
}

@end
