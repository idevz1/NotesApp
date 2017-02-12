
#import "YTSlidingContainerView.h"
#import "../Settings/Classes.h"
#import "AppDelegate.h"
#define kSlightlyMoveMenuWhenOpen YES//NO

static YTSlidingContainerView *_shared;

@implementation YTSlidingContainerView

+ (YTSlidingContainerView *)shared {
	return _shared;
}

- (void)initialize {
	[super initialize];
	_shared = self;
	
	//_menuView = [[YTSlidingMenuView alloc] initWithFrame:CGRectZero];
	//_menuView.delegate = self;
	//[self addSubview:_menuView];
	_contentView = [[YTSlidingContentView alloc] initWithFrame:CGRectZero];
	_contentView.navigatingViewDelegate = self;
	[self addSubview:_contentView];
	
	_sliddenOverlay = [[YTSlidingContainerView_SliddenContentOverlayView alloc] initWithFrame:CGRectZero];
	_sliddenOverlay.hidden = YES;
	[_sliddenOverlay addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSliddenOverlayTap:)] autorelease]];
	[self addSubview:_sliddenOverlay];
	
	UISwipeGestureRecognizer *swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)] autorelease];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	//[self addGestureRecognizer:swipeLeft];
	
	UISwipeGestureRecognizer *swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)] autorelease];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	//[self addGestureRecognizer:swipeRight];
	
	_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
	[self addGestureRecognizer:_panGesture];
	
	if(kYTShowSplashView) {
		_splashView = [[YTSplashView alloc] initWithFrame:CGRectZero];
		[self addSubview:_splashView];
		_showSplashRatio = 1.0;
	}
	
	[[YTApiMediator shared].msgrVersionChanged addObserver:self selector:@selector(onUpdateView)];
	
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning addObserver:self selector:@selector(onReceiveMemoryWarning:)];
	
	[[VLMessageCenter shared] performBlock:^{
		[self hideSplashView];
	} afterDelay:0.001 ignoringTouches:NO];
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	if(!_menuView && [[YTApiMediator shared] isDataInitialized]) {
		_menuView = [[YTSlidingMenuView alloc] initWithFrame:CGRectZero];
		_menuView.delegate = self;
		[self addSubview:_menuView];
		[self sendSubviewToBack:_menuView];
		[self layoutSubviews];
	}
	if([[YTApiMediator shared] isDataInitialized] && [[YTApiMediator shared] notesTableWasLoadadOnce]) {
		if(_activityViewLoading) {
			[_activityViewLoading removeFromSuperview];
			[_activityViewLoading release];
			_activityViewLoading = nil;
		}
	} else {
		if(!_activityViewLoading) {
			_activityViewLoading = [[YTActivityView alloc] initWithFrame:CGRectZero];
			_activityViewLoading.title = NSLocalizedString(@"Loading...", nil);
			//_activityViewLoading.color = kYTProgressIndicatorBackColor;
			_activityViewLoading.dimBackground = NO;
			[self addSubview:_activityViewLoading];
			[self layoutSubviews];
			[_activityViewLoading startActivity];
		}
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	float maxOffset = round(rcBnds.size.width * kYTLeftMenuSlideMaxOffsetRatio);
	YTNoteView *noteView = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class]
			parentView:[VLAppDelegateBase sharedAppDelegateBase].rootViewController.view];
	if(noteView) // Removing view
		maxOffset = rcBnds.size.width;
	float offset = maxOffset * _slideRatio;
	offset += rcBnds.size.width * _showSplashRatio;
	CGRect rcMenu = rcBnds;
	rcMenu.size.width = maxOffset;
	if(kSlightlyMoveMenuWhenOpen)
		rcMenu.origin.x -= rcMenu.size.width * 0.15 * (1 - _slideRatio);
	if(_menuView)
		_menuView.frame = rcMenu;
	CGRect rcCont = rcBnds;
	CGRect rcContSlid = rcCont;
	rcContSlid.origin.x += offset;
	if(_splashView) {
		CGRect rcSplash = rcBnds;
		rcSplash.origin.x -= rcSplash.size.width;
		rcSplash.origin.x += rcSplash.size.width * _showSplashRatio;
		_splashView.frame = rcSplash;
	}
	if(_activityViewLoading)
		_activityViewLoading.frame = rcBnds;
	if(_contentView_noteView) {
		_contentView_noteView.frame = rcContSlid;
		_contentView.frame = rcCont;
		if(_contentView_noteEditView)
			_contentView_noteEditView.frame = rcContSlid;
	} else if(_contentView_noteEditView) {
		_contentView_noteEditView.frame = rcContSlid;
		_contentView.frame = rcCont;
		if(_contentView_noteView)
			_contentView_noteView.frame = rcContSlid;
	} else {
		_contentView.frame = rcContSlid;
		if(_contentView_noteEditView)
			_contentView_noteEditView.frame = rcContSlid;
	}
	if(_sliddenOverlay)
		_sliddenOverlay.frame = rcContSlid;
}

- (void)setSlideRatio:(float)slideRatio animated:(BOOL)animated resultBlock:(VLBlockVoid)resultBlock {
	if(!_menuView) {
		if(resultBlock)
			resultBlock();
		return;
	}
	slideRatio = MAX(MIN(slideRatio, 1.0), 0.0);
	if(_slideRatio != slideRatio) {
		_sliddenOverlay.hidden = (slideRatio != 1.0);
		if(slideRatio == 1.0)
			[self bringSubviewToFront:_sliddenOverlay];
		if(animated) {
			[UIView animateWithDuration:kDefaultAnimationDuration
							 animations:^
			{
				_slideRatio = slideRatio;
				[self layoutSubviews];
				[self updateBarsAlphas];
			}
			 completion:^(BOOL finished)
			{
				if(finished) {
					if(_slideRatio == 1.0) {
						YTNoteView *noteView = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class]
							parentView:[VLAppDelegateBase sharedAppDelegateBase].rootViewController.view];
						if(noteView) { // Removing view
							[noteView close];
						}
					}
					if(resultBlock)
						resultBlock();
				}
			}];
		} else {
			_slideRatio = slideRatio;
			[self setNeedsLayout];
			[self updateBarsAlphas];
			if(resultBlock)
				resultBlock();
		}
	} else {
		if(resultBlock)
			resultBlock();
	}
}

- (void)setSlideRatio:(float)slideRatio animated:(BOOL)animated {
	[self setSlideRatio:slideRatio animated:animated resultBlock:nil];
}

- (void)updateBarsAlphas {
	YTMainNotesView *mainNotesView = (YTMainNotesView *)[VLCtrlsUtils getSubViewOfClass:[YTMainNotesView class] parentView:_contentView];
	if(_openingNoteView || _closingNoteView) {
		_noteView.customNavBar.alpha = 1.0;
		if(mainNotesView)
			mainNotesView.customNavBar.alpha = 1.0;
		return;
	}
	if(_noteView) {
		[_noteView layoutSubviews];
		float alpha;
		if(_slideRatio >= 0.5)
			alpha = 0.0;
		else
			alpha = (0.5 - _slideRatio) * 2;
		_noteView.customNavBar.alpha = alpha;
		if(mainNotesView) {
			float alpha1;
			if(_slideRatio < 0.5)
				alpha1 = 0.0;
			else
				alpha1 = (_slideRatio - 0.5) * 2;
			//if(_slideRatio == 0.0)
			//	alpha1 = 1.0;
			mainNotesView.customNavBar.alpha = alpha1;
		}
		_noteView.customNavBar.userInteractionEnabled = (_noteView.customNavBar.alpha != 0.0);
	} else {
		if(mainNotesView)
			mainNotesView.customNavBar.alpha = 1.0;
	}
}

- (void)navigatingView:(YTBaseView *)navigatingView handleGoBack:(id)param {
	YTNotesContentView *homeView = _contentView.notesContentView;
	YTNavigationView *navigView = homeView.navigationView;
	NSArray *views = navigView.views;
	if([views containsObject:navigatingView]) {
		if(navigatingView == [views objectAtIndex:0]) {
			if(_slideRatio > 0) {
				[self setSlideRatio:0 animated:YES];
			} else {
				[self setSlideRatio:1 animated:YES];
			}
		} else {
			[homeView popView:navigatingView animated:YES];
		}
	}
}

- (void)slidingMenuView:(YTSlidingMenuView *)slidingMenuView actionSelected:(YTSlidingMenuActionArgs *)actionArgs {
	YTNotesContentView *homeView = _contentView.notesContentView;
	YTNavigationView *navigView = homeView.navigationView;
	if(actionArgs.action != EYTSlidingMenuViewActionShowPhotos) {
		if(_cachedPhotosThumbsView && !kYTCashingPhotosThumbsView) {
			[[VLMessageCenter shared] performBlock:^{
				if(_cachedPhotosThumbsView && !_cachedPhotosThumbsView.superview) {
					[_cachedPhotosThumbsView release];
					_cachedPhotosThumbsView = nil;
				}
			} afterDelay:kDefaultAnimationDuration ignoringTouches:NO];
		}
	}
	if(actionArgs.action == EYTSlidingMenuViewActionShowTimeline || actionArgs.action == EYTSlidingMenuViewActionShowStarred) {
		YTMainNotesView *view = nil;
		view = (YTMainNotesView *)[VLCtrlsUtils getSubViewOfClass:[YTMainNotesView class] parentView:homeView];
		YTNotesDisplayParams *params = [[[YTNotesDisplayParams alloc] init] autorelease];
		if(actionArgs.action == EYTSlidingMenuViewActionShowTimeline) {
			
		} else if(actionArgs.action == EYTSlidingMenuViewActionShowStarred) {
			params.priorityType = EYTPriorityTypeHigh;
		}
		if(view) {
			if(!view.notesDisplayParams || ![view.notesDisplayParams.notebookGuid isEqual:@""]
			   || ![view.notesDisplayParams.tagName isEqual:@""] || view.notesDisplayParams.priorityType != params.priorityType)
				view = nil;
		}
		if(!view) {
			view = [[[YTMainNotesView alloc] initWithFrame:navigView.bounds notesDisplayParams:params] autorelease];
			view.navigatingViewDelegate = homeView;
			while(navigView.views.count)
				[navigView popView:[navigView.views objectAtIndex:0] animated:NO];
			[homeView pushView:view animated:NO];
		}
		[self setSlideRatio:0 animated:YES];
	} else if(actionArgs.action == EYTSlidingMenuViewActionShowPhotos) {
		YTPhotosThumbsView *view = nil;
		view = (YTPhotosThumbsView *)[VLCtrlsUtils getSubViewOfClass:[YTPhotosThumbsView class] parentView:homeView];
		if(!view) {
			if(!_cachedPhotosThumbsView) {
				_cachedPhotosThumbsView = [[YTPhotosThumbsView alloc] initWithFrame:self.bounds maxWaitingTimeToLoad:0.5];
			}
			view = _cachedPhotosThumbsView;
			view.navigatingViewDelegate = homeView;
			[[VLMessageCenter shared] performBlock:^{
				//VLDelayedScreenActivity *activity = [[VLDelayedScreenActivity alloc] init];
				//[activity startActivityWithTitle:NSLocalizedString(@"Opening", nil) delay:0.05/*kDefaultAnimationDuration/2*/ maxDuration:0.5
				//			 checkForCancelBlock:^BOOL
				//{
				//	if([view isAllImagesShown] || [activity isMaxDurationExceeded]) {
						while(navigView.views.count)
							[navigView popView:[navigView.views objectAtIndex:0] animated:NO];
						[homeView pushView:view animated:NO];
				//		[activity cancelActivity];
				//		[activity release];
						[self setSlideRatio:0 animated:YES];
				//		return YES;
				//	}
				//	return NO;
				//}];
			} afterDelay:0.001/*0.35*/ ignoringTouches:YES];
		} else {
			[self setSlideRatio:0 animated:YES];
		}
	} else if(actionArgs.action == EYTSlidingMenuViewActionShowNotebook) {
		YTNotebookInfo *notebook = ObjectCast(actionArgs.param, YTNotebookInfo);
		YTMainNotesView *view = nil;
		view = (YTMainNotesView *)[VLCtrlsUtils getSubViewOfClass:[YTMainNotesView class] parentView:homeView];
		YTNotesDisplayParams *params = [[[YTNotesDisplayParams alloc] init] autorelease];
		params.notebookGuid = notebook.notebookGuid;
		if(view) {
			if(!view.notesDisplayParams || ![view.notesDisplayParams.notebookGuid isEqual:params.notebookGuid]
				|| ![view.notesDisplayParams.tagName isEqual:@""] || view.notesDisplayParams.priorityType)
				view = nil;
		}
		if(!view) {
			view = [[[YTMainNotesView alloc] initWithFrame:navigView.bounds notesDisplayParams:params] autorelease];
			view.navigatingViewDelegate = homeView;
			while(navigView.views.count)
				[navigView popView:[navigView.views objectAtIndex:0] animated:NO];
			[homeView pushView:view animated:NO];
		}
		[self setSlideRatio:0 animated:YES];
	} else if(actionArgs.action == EYTSlidingMenuViewActionShowTag) {
		YTTagInfo *tag = ObjectCast(actionArgs.param, YTTagInfo);
		YTMainNotesView *view = nil;
		view = (YTMainNotesView *)[VLCtrlsUtils getSubViewOfClass:[YTMainNotesView class] parentView:homeView];
		YTNotesDisplayParams *params = [[[YTNotesDisplayParams alloc] init] autorelease];
		params.tagName = tag.name;
		if(view) {
			if(![view.notesDisplayParams.tagName isEqual:params.tagName])
				view = nil;
		}
		if(!view) {
			view = [[[YTMainNotesView alloc] initWithFrame:navigView.bounds notesDisplayParams:params] autorelease];
			view.navigatingViewDelegate = homeView;
			while(navigView.views.count)
				[navigView popView:[navigView.views objectAtIndex:0] animated:NO];
			[homeView pushView:view animated:NO];
		}
		[self setSlideRatio:0 animated:YES];
	} else if(actionArgs.action == EYTSlidingMenuViewActionShowSettings) {
		YTSettingsView *view = nil;
		view = (YTSettingsView *)[VLCtrlsUtils getSubViewOfClass:[YTSettingsView class] parentView:homeView];
		if(!view) {
			view = [[[YTSettingsView alloc] initWithFrame:CGRectZero] autorelease];
			view.navigatingViewDelegate = homeView;
            
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
            {
                [[AppDelegate instance]showSettings:view];
            }
            else{
			while(navigView.views.count)
				[navigView popView:[navigView.views objectAtIndex:0] animated:NO];
                [homeView pushView:view animated:NO];}
		}
		[self setSlideRatio:0 animated:YES];
	} else {
		[self setSlideRatio:0 animated:YES];
	}
}

- (void)onSwipeLeft:(UISwipeGestureRecognizer *)swipe {
	if(swipe.state == UIGestureRecognizerStateRecognized) {
		[self setSlideRatio:0 animated:YES];
	}
}

- (void)onSwipeRight:(UISwipeGestureRecognizer *)swipe {
	if(swipe.state == UIGestureRecognizerStateRecognized) {
		[self setSlideRatio:1 animated:YES];
	}
}

- (void)onSliddenOverlayTap:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized) {
		[self setSlideRatio:0.0 animated:YES];
	}
}

- (void)onPanGesture:(UIPanGestureRecognizer *)pan {
	if(_slideIgnoringCounter > 0)
		return;
	CGRect rcBnds = self.bounds;
	CGPoint ptLoc = [pan locationInView:self];
	CGPoint ptVel = [pan velocityInView:self];
	//CGPoint ptTran = [pan translationInView:self];
	UIGestureRecognizerState state = pan.state;
	if(state == UIGestureRecognizerStateBegan) {
		_dragStartSlideRatio = _slideRatio;
		_dragStartPoint = ptLoc;
		_dragStarted = YES;
		if(_splashView) {
			_dragStarted = NO;
			return;
		}
	} else if(state == UIGestureRecognizerStateChanged) {
		if(!_dragStarted)
			return;
		float maxOffset = round(rcBnds.size.width * kYTLeftMenuSlideMaxOffsetRatio);
		//float dragOffset = ptTran.x;
		float dragOffset = ptLoc.x - _dragStartPoint.x;
		float dRatio = dragOffset / maxOffset;
		float newRatio = _dragStartSlideRatio + dRatio;
		[self setSlideRatio:newRatio animated:YES];
		
		float velocityLimit = 1000;
		if(ABS(ptVel.x) > velocityLimit) {
			if(ptVel.x > 0)
				[self setSlideRatio:1 animated:YES];
			else
				[self setSlideRatio:0 animated:YES];
			_dragStarted = NO;
			return;
		}
	} else if(state == UIGestureRecognizerStateEnded) {
		if(!_dragStarted)
			return;
		float dRatio = 0.15;
		if(_dragStartSlideRatio > 0.5) {
			if(_slideRatio < (1 - dRatio))
				[self setSlideRatio:0 animated:YES];
			else
				[self setSlideRatio:1 animated:YES];
		} else {
			if(_slideRatio > dRatio)
				[self setSlideRatio:1 animated:YES];
			else
				[self setSlideRatio:0 animated:YES];
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if(_splashView) {
		[self hideSplashView];
		return;
	}
	[super touchesBegan:touches withEvent:event];
}

- (void)hideSplashView {
	if(_splashView && _showSplashRatio) {
		[UIView animateWithDuration:kDefaultAnimationDuration * 0.75 animations:^{
			_showSplashRatio = 0.0;
			[self layoutSubviews];
		} completion:^(BOOL finished) {
			if(finished) {
				[_splashView removeFromSuperview];
				[_splashView release];
				_splashView = nil;
			}
		}];
	}
}

- (void)suspendSliding {
	_slideIgnoringCounter++;
	if(_slideIgnoringCounter == 1) {
		[self removeGestureRecognizer:_panGesture];
		//VLLoggerTrace(@"%@", @"[self removeGestureRecognizer:_panGesture];");
	}
}

- (void)resumeSliding {
	if(_slideIgnoringCounter > 0) {
		_slideIgnoringCounter--;
		if(_slideIgnoringCounter == 0) {
			[self addGestureRecognizer:_panGesture];
			//VLLoggerTrace(@"%@", @"[self addGestureRecognizer:_panGesture];");
		}
	}
}

- (void)suspendSliding:(BOOL)suspend {
	if(suspend)
		[self suspendSliding];
	else
		[self resumeSliding];
}

- (void)animiteShowHideNoteView:(YTNoteView *)noteView fromToCellView:(YTNoteTableCellView *)noteCellView
					   fromCell:(BOOL)fromCell resultBlock:(VLBlockVoid)resultBlock {
	
	UIView *imageViewCell = nil;
	UIView *imageViewNote = nil;
	if(noteCellView.thumbnailView && noteCellView.resourceImage
	   && [noteCellView.thumbnailView isImageShown]) {
		YTResourceInfo *resource = noteCellView.resourceImage;
		YTNoteResourceRowView *resRowView = nil;
		for(YTNoteResourceRowView *view in noteView.contentView.resourcesListView.rowsViews) {
			if(view.resource == resource) {
				resRowView = view;
				break;
			}
		}
		if(resRowView && [resRowView.resourceView isImageShown]) {
			imageViewCell = noteCellView.thumbnailView;
			imageViewNote = resRowView.resourceView;
		}
	}
	
	//UIView *textViewCell = noteCellView.textView;
	//UIView *textViewNote = [_noteView getContentTextView];
	
	NSMutableArray *viewsFrom = [NSMutableArray array];
	[viewsFrom addObject:fromCell ? (imageViewCell ? imageViewCell : [NSNull null]) : (imageViewNote ? imageViewNote : [NSNull null])];
	//[viewsFrom addObject:fromCell ? (textViewCell ? textViewCell : [NSNull null]) : (textViewNote ? textViewNote : [NSNull null])];
	
	NSMutableArray *viewsTo = [NSMutableArray array];
	[viewsTo addObject:fromCell ? (imageViewNote ? imageViewNote : [NSNull null]) : (imageViewCell ? imageViewCell : [NSNull null])];
	//[viewsTo addObject:fromCell ? (textViewNote ? textViewNote : [NSNull null]) : (textViewCell ? textViewCell : [NSNull null])];
	
	_contentView_noteView.alpha = fromCell ? 0.0 : 1.0;
	
	[[VLMessageCenter shared] performBlock:^
	{
		if(fromCell)
			[noteView onShowAnimationBefore];
		else
			[noteView onCloseAnimationBefore];
		
		[noteCellView showThumbnailFrame:!fromCell animated:YES];
		VLViewsTransitionAnimator *animator = [[[VLViewsTransitionAnimator alloc] init] autorelease];
		if(_disableAnimationCounter)
			animator.animationDuration = 0;
		[animator startAnimateFromViews:viewsFrom
								toViews:viewsTo
						 animationTypes:[NSArray arrayWithObjects:
										 [NSNumber numberWithInt:EVLViewsTransitionAnimatorTypeImage],
										 //[NSNumber numberWithInt:EVLViewsTransitionAnimatorTypeFrame],
										 nil]
		 animations:^
		{
			_contentView_noteView.alpha = fromCell ? 1.0 : 0.0;
			if(fromCell)
				[noteView onShowAnimationDuring];
			else
				[noteView onCloseAnimationDuring];
		}
		 completion:^
		{
			[noteCellView layoutSubviews];
			
			if(fromCell)
				[noteView onShowAnimationAfter];
			else
				[noteView onCloseAnimationAfter];
			
			resultBlock();
		 }];
	}
	 afterDelay:0.001 ignoringTouches:YES];
}

- (void)showNoteView:(YTNoteView *)noteView fromCellView:(YTNoteTableCellView *)noteCellView {
	if(_noteView) {
		[_contentView_noteView popView:_noteView animated:NO];
		[_noteView release];
		_noteView = nil;
		_noteView = [noteView retain];
		[_contentView_noteView pushView:_noteView animated:NO];
		[self updateBarsAlphas];
		return;
	}
	[self setSlideRatio:0.0 animated:YES resultBlock:^{
		if(_contentView_noteView) {
			[_contentView_noteView removeFromSuperview];
			[_contentView_noteView release];
			_contentView_noteView = nil;
		}
		if(_noteView) {
			[_noteView release];
			_noteView = nil;
		}
		_noteView = [noteView retain];
		_contentView_noteView = [[YTNotesContentView alloc] initWithFrame:CGRectZero];
		_contentView_noteView.navigationView.clipsToBounds = NO;
		_noteView.stickNavigationBar = YES;
		[self addSubview:_contentView_noteView];
		[self layoutSubviews];
		[_contentView_noteView pushView:_noteView animated:NO];
		_openingNoteView = YES;
		[self updateBarsAlphas];
		[self animiteShowHideNoteView:noteView fromToCellView:noteCellView fromCell:YES resultBlock:^{
			_openingNoteView = NO;
			[self updateBarsAlphas];
		}];
	}];
}

- (BOOL)closeNoteView:(YTNoteView *)noteView toCellView:(YTNoteTableCellView *)noteCellView {
	if(!_noteView || _noteView != noteView)
		return NO;
	if(_slideRatio == 1.0) { // Removing view
		if(_contentView_noteView) {
			[_contentView_noteView removeFromSuperview];
			[_contentView_noteView release];
			_contentView_noteView = nil;
		}
		if(_noteView) {
			[_noteView release];
			_noteView = nil;
		}
		_closingNoteView = NO;
		[self setSlideRatio:0.0 animated:NO];
		[self updateBarsAlphas];
		[self layoutSubviews];
		return YES;
	}
	double animationDuration = !_disableAnimationCounter ? kDefaultAnimationDuration : 0;
	if(!noteCellView) {
		_closingNoteView = YES;
		[self updateBarsAlphas];
		[noteView onCloseAnimationBefore];
		[UIView animateWithDuration:animationDuration
						 animations:^
		{
			_contentView_noteView.alpha = 0.0;
			[self updateBarsAlphas];
			[noteView onCloseAnimationDuring];
		}
		 completion:^(BOOL finished)
		{
			if(finished) {
				[noteView onCloseAnimationAfter];
				if(_contentView_noteView) {
					[_contentView_noteView removeFromSuperview];
					[_contentView_noteView release];
					_contentView_noteView = nil;
				}
				if(_noteView) {
					[_noteView release];
					_noteView = nil;
				}
				_closingNoteView = NO;
				[self updateBarsAlphas];
			}
		}];
		return YES;
	}
	_closingNoteView = YES;
	[self updateBarsAlphas];
	[self animiteShowHideNoteView:noteView fromToCellView:noteCellView fromCell:NO resultBlock:^{
		if(_contentView_noteView) {
			[_contentView_noteView removeFromSuperview];
			[_contentView_noteView release];
			_contentView_noteView = nil;
		}
		if(_noteView) {
			[_noteView release];
			_noteView = nil;
		}
		_closingNoteView = NO;
		[self updateBarsAlphas];
	}];
	return YES;
}

- (void)animiteShowHideNoteView:(YTNoteView *)noteView fromToThumbView:(YTPhotosThumbsView_ThumbView *)thumbView
					   fromCell:(BOOL)fromCell resultBlock:(VLBlockVoid)resultBlock {
	
	UIView *imageViewCell = nil;
	UIView *imageViewNote = nil;
	
	imageViewCell = thumbView;
	YTResourceInfo *resource = thumbView.resource;
	YTNoteResourceRowView *resRowView = nil;
	for(YTNoteResourceRowView *view in noteView.contentView.resourcesListView.rowsViews) {
		if(view.resource == resource) {
			resRowView = view;
			break;
		}
	}
	if(resRowView) {
		imageViewNote = resRowView.resourceView;
	}
	
	_contentView_noteView.alpha = fromCell ? 0.0 : 1.0;
	
	VLViewsTransitionAnimator *animator = [[[VLViewsTransitionAnimator alloc] init] autorelease];
	[animator startAnimateFromView:fromCell ? imageViewCell : imageViewNote
							toView:fromCell ? imageViewNote : imageViewCell
					 animationType:EVLViewsTransitionAnimatorTypeImage
	animations:^{
		_contentView_noteView.alpha = fromCell ? 1.0 : 0.0;
	}
	completion:^{
		[thumbView layoutSubviews];
		resultBlock();
	}];
}


- (void)showNoteView:(YTNoteView *)noteView fromThumbView:(YTPhotosThumbsView_ThumbView *)thumbView {
	if(_noteView) {
		[_contentView_noteView popView:_noteView animated:NO];
		[_noteView release];
		_noteView = nil;
		_noteView = [noteView retain];
		[_contentView_noteView pushView:_noteView animated:NO];
		[self updateBarsAlphas];
		return;
	}
	[self setSlideRatio:0.0 animated:YES resultBlock:^{
		if(_contentView_noteView) {
			[_contentView_noteView removeFromSuperview];
			[_contentView_noteView release];
			_contentView_noteView = nil;
		}
		if(_noteView) {
			[_noteView release];
			_noteView = nil;
		}
		_noteView = [noteView retain];
		_contentView_noteView = [[YTNotesContentView alloc] initWithFrame:CGRectZero];
		_contentView_noteView.alpha = 0.0;
		_contentView_noteView.navigationView.clipsToBounds = NO;
		_noteView.stickNavigationBar = YES;
		[self addSubview:_contentView_noteView];
		[self layoutSubviews];
		[_contentView_noteView pushView:_noteView animated:NO];
		_openingNoteView = YES;
		[self updateBarsAlphas];
		[[VLMessageCenter shared] performBlock:^{
			[self animiteShowHideNoteView:noteView fromToThumbView:thumbView fromCell:YES resultBlock:^{
				_openingNoteView = NO;
				[self updateBarsAlphas];
			}];
		}
		 afterDelay:0.001 ignoringTouches:YES];
	}];
}

- (BOOL)closeNoteView:(YTNoteView *)noteView toThumbView:(YTPhotosThumbsView_ThumbView *)thumbView {
	if(!_noteView || _noteView != noteView)
		return NO;
	if(_slideRatio == 1.0) { // Removing view
		if(_contentView_noteView) {
			[_contentView_noteView removeFromSuperview];
			[_contentView_noteView release];
			_contentView_noteView = nil;
		}
		if(_noteView) {
			[_noteView release];
			_noteView = nil;
		}
		_closingNoteView = NO;
		[self setSlideRatio:0.0 animated:NO];
		[self updateBarsAlphas];
		[self layoutSubviews];
		return YES;
	}
	if(!thumbView) {
		_closingNoteView = YES;
		[self updateBarsAlphas];
		[UIView animateWithDuration:kDefaultAnimationDuration
						 animations:^
		{
			_noteView.alpha = 0.0;
			[self updateBarsAlphas];
		}
		 completion:^(BOOL finished)
		{
			if(finished) {
				if(_contentView_noteView) {
					[_contentView_noteView removeFromSuperview];
					[_contentView_noteView release];
					_contentView_noteView = nil;
				}
				if(_noteView) {
					[_noteView release];
					_noteView = nil;
				}
				_closingNoteView = NO;
				[self updateBarsAlphas];
			}
		}];
		return YES;
	}
	_closingNoteView = YES;
	[self updateBarsAlphas];
	[self animiteShowHideNoteView:noteView fromToThumbView:thumbView fromCell:NO resultBlock:^{
		if(_contentView_noteView) {
			[_contentView_noteView removeFromSuperview];
			[_contentView_noteView release];
			_contentView_noteView = nil;
		}
		if(_noteView) {
			[_noteView release];
			_noteView = nil;
		}
		_closingNoteView = NO;
		[self updateBarsAlphas];
	}];
	return YES;
}

- (void)showNoteEditView:(YTNoteEditView *)noteEditView {
	[self setSlideRatio:0.0 animated:YES resultBlock:^{
		if(_contentView_noteEditView) {
			[_contentView_noteEditView removeFromSuperview];
			[_contentView_noteEditView release];
			_contentView_noteEditView = nil;
		}
		if(_noteEditView) {
			[_noteEditView release];
			_noteEditView = nil;
		}
		_noteEditView = [noteEditView retain];
		_contentView_noteEditView = [[YTNotesContentView alloc] initWithFrame:CGRectZero];
		[self addSubview:_contentView_noteEditView];
		[self layoutSubviews];
		[_contentView_noteEditView pushView:_noteEditView animated:NO];
		_contentView_noteEditView.alpha = 0.0;
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			_contentView_noteEditView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	}];
}

- (BOOL)closeNoteEditView:(YTNoteEditView *)noteEditView {
	if(!noteEditView || _noteEditView != noteEditView)
		return NO;
	YTNoteEditInfo *noteEditInfo = noteEditView.noteEditInfo;
	if(_noteView && (_noteView.note != noteEditInfo.noteLast) && (_noteView.note != noteEditInfo.noteNew)
	   && ((noteEditInfo.noteLast && [noteEditInfo.noteLast isInDb])
		   || (noteEditInfo.noteNew && [noteEditInfo.noteNew isInDb]))
			   ) {
		_disableAnimationCounter++;
		[self closeNoteView:_noteView toCellView:nil];
		_disableAnimationCounter--;
	}
	_contentView_noteEditView.alpha = 0.99;
	_noteEditView.alpha = 0.99;
	[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
		_contentView_noteEditView.alpha = 0.0;
	} completion:^(BOOL finished) {
		if(finished) {
			if(_contentView_noteEditView) {
				[_contentView_noteEditView removeFromSuperview];
				[_contentView_noteEditView release];
				_contentView_noteEditView = nil;
			}
			if(_noteEditView) {
				[_noteEditView release];
				_noteEditView = nil;
			}
		}
	}];
	return YES;
}

/*- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	VLLoggerTrace(@"");
	return [super hitTest:point withEvent:event];
}*/

- (void)onReceiveMemoryWarning:(id)sender {
	if(_cachedPhotosThumbsView && !_cachedPhotosThumbsView.superview) {
		[_cachedPhotosThumbsView release];
		_cachedPhotosThumbsView = nil;
	}
}

- (void)dealloc {
	if(_shared == self)
		_shared = nil;
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning removeObserver:self];
	[[YTApiMediator shared].msgrVersionChanged removeObserver:self];
	[_menuView release];
	[_contentView release];
	[_sliddenOverlay release];
	[_splashView release];
	[_activityViewLoading release];
	[_cachedPhotosThumbsView release];
	[_panGesture release];
	[_contentView_noteView release];
	[_noteView release];
	
	[_contentView_noteEditView release];
	[_noteEditView release];
	
	[super dealloc];
}

@end






@implementation YTSlidingContainerView_SliddenContentOverlayView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.01];
}

- (void)dealloc {
	[super dealloc];
}

@end








