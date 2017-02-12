
#import "YTResourceView.h"

@implementation YTResourceView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
	
	_lbError = [VLLabel new];
	_lbError.visible = NO;
	_lbError.backgroundColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0];
	_lbError.textColor = [UIColor redColor];
	_lbError.numberOfLines = 0;
	[_lbError centerText];
	_lbError.lineBreakMode = NSLineBreakByWordWrapping;
	[_lbError roundCorners:4];
	_lbError.adjustsFontSizeToFitWidthMultiLine = YES;
	_lbError.font = [[YTFontsManager shared] lightFontWithSize:16 fixed:YES];
	[self addSubview:_lbError];
	
	_btnReload = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	_btnReload.visible = NO;
	[_btnReload setTitleForAllStates:NSLocalizedString(@"Reload {Button}", nil)];
	[_btnReload addTarget:self action:@selector(onBtnReloadTap:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_btnReload];
	
	_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
	//[self addGestureRecognizer:tap];
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 0.2;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	
	[self updateViewAsync];
}

- (YTResourceBaseView *)subResourceView {
	if(_imageView)
		return _imageView;
	else if(_mediaView)
		return _mediaView;
	else if(_webDocView)
		return _webDocView;
	else if(_otherView)
		return _otherView;
	return nil;
}

- (void)resetState {
	_waitingForReloadStarted = NO;
}

- (void)setResource:(YTResourceInfo *)resource {
	if(self.resource != resource) {
		[super setResource:resource];
		[self resetState];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	YTResourceBaseView *lastSubView = [self subResourceView];
	YTResourceInfo *resource = self.resource;
	if(resource) {
		if(lastSubView)
			[[lastSubView retain] autorelease];
		BOOL isOtherType = [resource isOtherType];
		if([resource isImage]) {
			if(_mediaView) {
				[_mediaView removeFromSuperview];
				[_mediaView release];
				_mediaView = nil;
			}
			if(_webDocView) {
				[_webDocView removeFromSuperview];
				[_webDocView release];
				_webDocView = nil;
			}
			if(_otherView) {
				[_otherView removeFromSuperview];
				[_otherView release];
				_otherView = nil;
			}
			if(!_imageView) {
				_imageView = [YTResourceImageView new];
				_imageView.drawOnMainThread = YES;
				_imageView.useMiniImage = YES;
				_imageView.backgroundColor = [UIColor clearColor];
				_imageView.activityBackColor = self.activityBackColor;
				[self addSubview:_imageView];
				[self setNeedsLayout];
			}
		} else if([resource isVideo] || [resource isAudio]) {
			if(_imageView) {
				[_imageView removeFromSuperview];
				[_imageView release];
				_imageView = nil;
			}
			if(_webDocView) {
				[_webDocView removeFromSuperview];
				[_webDocView release];
				_webDocView = nil;
			}
			if(_otherView) {
				[_otherView removeFromSuperview];
				[_otherView release];
				_otherView = nil;
			}
			if(!_mediaView) {
				_mediaView = [YTResourceMediaView new];
				_mediaView.backgroundColor = [UIColor clearColor];
				_mediaView.activityBackColor = self.activityBackColor;
				[self addSubview:_mediaView];
				[self setNeedsLayout];
			}
		} else if([resource isWebDocViewable] && !isOtherType) {
			if(_imageView) {
				[_imageView removeFromSuperview];
				[_imageView release];
				_imageView = nil;
			}
			if(_mediaView) {
				[_mediaView removeFromSuperview];
				[_mediaView release];
				_webDocView = nil;
			}
			if(_otherView) {
				[_otherView removeFromSuperview];
				[_otherView release];
				_otherView = nil;
			}
			if(!_webDocView) {
				_webDocView = [YTResourceWebDocView new];
				_webDocView.activityBackColor = self.activityBackColor;
				[self addSubview:_webDocView];
				[self setNeedsLayout];
			}
		} else {
			if(_imageView) {
				[_imageView removeFromSuperview];
				[_imageView release];
				_imageView = nil;
			}
			if(_mediaView) {
				[_mediaView removeFromSuperview];
				[_mediaView release];
				_mediaView = nil;
			}
			if(_webDocView) {
				[_webDocView removeFromSuperview];
				[_webDocView release];
				_webDocView = nil;
			}
			if(!_otherView) {
				_otherView = [YTResourceOtherView new];
				_otherView.backgroundColor = [UIColor clearColor];
				_otherView.activityBackColor = self.activityBackColor;
				[self addSubview:_otherView];
				[self setNeedsLayout];
			}
		}
	}
	if(_imageView)
		_imageView.resource = resource;
	if(_mediaView)
		_mediaView.resource = resource;
	if(_webDocView)
		_webDocView.resource = resource;
	if(_otherView)
		_otherView.resource = resource;
	YTResourceBaseView *curSubView = [self subResourceView];
	if(curSubView) {
		curSubView.makeThumbnails = self.makeThumbnails;
		curSubView.makePreview = self.makePreview;
		curSubView.aspectFill = self.aspectFill;
	}
	if(curSubView != lastSubView) {
		if(lastSubView)
			[lastSubView.loadingReference.msgrVersionChanged removeObserver:self];
		if(curSubView)
			[curSubView.loadingReference.msgrVersionChanged addObserver:self selector:@selector(onLoadingReferenceChanged_YTResourceView:)];
	}
	[self onLoadingReferenceChanged_YTResourceView:self];
}

- (void)onLoadingReferenceChanged_YTResourceView:(id)sender {
	[self updateMessageControls];
}

- (void)updateMessageControls {
	YTResourceBaseView *curSubView = [self subResourceView];
	if(curSubView && curSubView.loadingReference && curSubView.loadingReference.parentInfoRef) {
		YTResourceLoadingReference *loadingReference = curSubView.loadingReference;
		YTResourceLoadingInfo *parentInfoRef = loadingReference.parentInfoRef;
		BOOL processing = parentInfoRef.processing;
		NSError *error = parentInfoRef.error;
		if(error && !processing) {
			//NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Synchronization failure. This may be due to a network problem or service maintenance.", nil), @""];
			NSString *text = NSLocalizedString(@"Synchronization failure. This may be due to a network problem or service maintenance.", nil);
			NSTimeInterval uptime = [VLTimer systemUptime];
			if(!_waitingForReloadStarted && kYTResourceDownloadWaitingForReloadEnabled) {
				_waitingForReloadStarted = YES;
				_waitingForReloadStartTime = uptime;
			}
			if(_waitingForReloadStarted) {
				NSTimeInterval timeCounted = uptime - _waitingForReloadStartTime;
				int seconds = round(timeCounted);
				if(seconds < kYTResourceDownloadWaitingForReloadMaxTime) {
					//text = [NSString stringWithFormat:NSLocalizedString(@"FAILED\n(tap to reload)\nreload in %d sec", nil), (int)kYTResourceDownloadWaitingForReloadMaxTime - seconds];
					text = NSLocalizedString(@"Synchronization failure. This may be due to a network problem or service maintenance.", nil);
				} else {
					_waitingForReloadStarted = NO;
					if(_lbError.visible) {
						_lbError.visible = NO;
						[self removeGestureRecognizer:_tapRecognizer];
					}
					[_timer stop];
					[self startReload];
					return;
				}
				if(!_timer.started)
					[_timer start];
			}
			if(!_lbError.visible) {
				_lbError.visible = YES;
				[self setNeedsLayout];
				[self addGestureRecognizer:_tapRecognizer];
			}
			if(_waitingForReloadStarted && kYTResourceDownloadWaitingForReloadObscureWaiting) {
				_lbError.alpha = 0.01;
				text = @"";
			} else {
				_lbError.alpha = 1.0;
				[self bringSubviewToFront:_lbError];
			}
			_lbError.text = text;
		} else {
			if(_lbError.visible) {
				_lbError.visible = NO;
				[self removeGestureRecognizer:_tapRecognizer];
			}
		}
		if(_waitingForReloadStarted && kYTResourceDownloadWaitingForReloadObscureWaiting) {
			[self setIsProcessing:YES];
			[self bringSubviewToFront:self.activityView];
			[self bringSubviewToFront:_lbError];
		} else {
			[self setIsProcessing:NO];
		}
	} else {
		if(_lbError.visible) {
			_lbError.visible = NO;
			[self removeGestureRecognizer:_tapRecognizer];
		}
		_lbError.text = @"";
	}
}

- (void)setIsProcessing:(BOOL)processing {
	if(processing != self.activityView.visible) {
		if(processing) {
			self.activityView.visible = YES;
			[self.activityView startAnimating];
		} else {
			[self.activityView stopAnimating];
			self.activityView.visible = NO;
		}
	}
}

- (void)onTimerEvent:(id)sender {
	[self updateMessageControls];
}

- (void)onResourceDataChanged {
	[super onResourceDataChanged];
	[self updateViewAsync];
}

- (void)startReload {
	_waitingForReloadStarted = NO;
	YTResourceBaseView *curSubView = [self subResourceView];
	if(curSubView && curSubView.loadingReference && curSubView.loadingReference.parentInfoRef) {
		YTResourceLoadingReference *loadingReference = curSubView.loadingReference;
		YTResourceLoadingInfo *parentInfoRef = loadingReference.parentInfoRef;
		BOOL processing = parentInfoRef.processing;
		NSError *error = parentInfoRef.error;
		if(error && !processing) {
			[[YTResourcesStorage shared] startLoadResource:parentInfoRef];
		}
	}
}

- (void)onBtnReloadTap:(id)sender {
	[self startReload];
}

- (void)onTap:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized) {
		[self startReload];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	if(_imageView)
		_imageView.frame = rcBnds;
	if(_mediaView)
		_mediaView.frame = rcBnds;
	if(_webDocView)
		_webDocView.frame = rcBnds;
	if(_otherView)
		_otherView.frame = rcBnds;
	if(_lbError.visible) {
		CGRect rcLabel = rcBnds;
		rcLabel = CGRectInset(rcLabel, 1, 1);
		rcLabel.origin.x = CGRectGetMidX(rcBnds) - rcLabel.size.width/2;
		rcLabel.origin.y = CGRectGetMidY(rcBnds) - rcLabel.size.height/2;
		_lbError.frame = [UIScreen roundRect:rcLabel];
	}
}

- (BOOL)isImageShown {
	return _imageView && [_imageView isImageShown];
}

- (UIView *)getImageHolderView {
	if(_imageView)
		return _imageView.imageHolderView;
	else
		return nil;
}

- (void)dealloc {
	[_imageView release];
	[_mediaView release];
	[_webDocView release];
	[_otherView release];
	[_lbError release];
	[_btnReload release];
	[_tapRecognizer release];
	[_timer release];
	[super dealloc];
}

@end

