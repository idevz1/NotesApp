
#import "YTNotesContentView.h"
#import "YTUiMediator.h"

@implementation YTNotesContentView_StatusBarBackView

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTHeaderBackColor;
	//_backColors = [[NSMutableArray alloc] init];
	//[_backColors addObject:self.backgroundColor];
}

/*- (void)pushBackColor:(UIColor *)color {
	[_backColors addObject:color];
	self.backgroundColor = color;
	[self updateStatusBarColor];
}

- (void)popBackColor {
	if(_backColors.count > 1) {
		[_backColors removeLastObject];
		self.backgroundColor = [_backColors lastObject];
		[self updateStatusBarColor];
	}
}

- (void)updateStatusBarColor {
	if(kIosVersionFloat >= 7.0) {
		UIColor *color = [_backColors lastObject];
		VLColor *vlCol = [VLColor fromUIColor:color];
		float lightness = [vlCol lightness];
		UIApplication *application = [UIApplication sharedApplication];
		if(lightness < 0.5)
			[application setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
		else
			[application setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	}
}*/

- (void)dealloc {
	//[_backColors release];
	[super dealloc];
}

@end




@implementation YTNotesContentView

@synthesize isMainNotesContentView = _isMainNotesContentView;
@synthesize navigationView = _navigationView;
@synthesize statusBarBack = _statusBarBack;

- (id)initWithFrame:(CGRect)frame isMainNotesContentView:(BOOL)isMainNotesContentView {
	_isMainNotesContentView = isMainNotesContentView;
	return [super initWithFrame:frame];
}

- (void)initialize {
	[super initialize];
	
	_statusBarBack = [[YTNotesContentView_StatusBarBackView alloc] initWithFrame:CGRectZero];
	if(kIosVersionFloat >= 7.0) {
		[self addSubview:_statusBarBack];
		_statusBarBackVisible = YES;
		//_statusBarBack.hidden = YES;
	}
	
	_navigationView = [[YTNavigationView alloc] initWithFrame:CGRectZero];
	[self addSubview:_navigationView];
	
	_mainStatusView = [[YTMainStatusView alloc] initWithFrame:CGRectZero];
	_mainStatusView.delegate = self;
	_mainStatusView.alpha = 0.0;
	[self addSubview:_mainStatusView];
	
	[[YTUsersEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTApiMediator shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	
	[self checkLoggedInState];
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	[self checkLoggedInState];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcContent = rcBnds;
	float topIndent = 0;
	if(kIosVersionFloat >= 7.0 && ![UIApplication sharedApplication].statusBarHidden) {
		// In iOS7 status bar is transparent. Move controls down.
		topIndent = [self convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil].size.height;
		CGRect rcBar = rcBnds;
		rcBar.size.height = topIndent;
		if(!_statusBarBackVisible) {
			rcBar.origin.y -= rcBar.size.height;
			topIndent = 0;
		}
		_statusBarBack.frame = rcBar;
	}
    if(!IsUiIPad){
	rcContent.origin.y += topIndent;
        rcContent.size.height -= topIndent;}
	
	CGRect rcNavigation = rcContent;
	CGRect rcStatus = rcContent;
	rcStatus.size.height = [_mainStatusView sizeThatFits:rcContent.size].height;
	rcStatus.origin.y = CGRectGetMaxY(rcNavigation);
	if(_mainStatusViewShown && kYTShowMainStatusView) {
		rcNavigation.size.height -= rcStatus.size.height;
		rcStatus.origin.y -= rcStatus.size.height;
	}
	_navigationView.frame = rcNavigation;
	_mainStatusView.frame = rcStatus;
	
	// Fix strange bu when layoutSubviews not called sometimes
	[_navigationView layoutSubviews];
}

- (void)setMainStatusViewShown:(BOOL)shown {
	if(_mainStatusViewShown != shown) {
		[self layoutSubviews];
		_mainStatusView.alpha = _mainStatusViewShown ? 1.0 : 0.0;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kDefaultAnimationDuration];
		_mainStatusViewShown = shown;
		[self layoutSubviews];
		_mainStatusView.alpha = _mainStatusViewShown ? 1.0 : 0.0;
		[UIView commitAnimations];
	}
}

- (void)mainStatusView:(YTMainStatusView *)mainStatusView statusChanged:(id)param {
	[self setMainStatusViewShown:_mainStatusView.shouldBeShown];
}

- (void)pushView:(YTBaseView *)view animated:(BOOL)animated {
	[_navigationView pushView:view animated:animated];
}

- (void)popView:(YTBaseView *)view animated:(BOOL)animated {
	[_navigationView popView:view animated:animated];
}

- (void)checkLoggedInState {
	if([[YTApiMediator shared] isDataInitialized] && _isMainNotesContentView) {
		YTUsersEnManager *manrUser = [YTUsersEnManager shared];
		BOOL isLoggedIn = manrUser.isLoggedIn;
		if(!isLoggedIn) {
			[manrUser startDemoUser];
		}
	}
	if(!_navigationView.views.count && _isMainNotesContentView) {
		YTNotesDisplayParams *params = [[[YTNotesDisplayParams alloc] init] autorelease];
		YTMainNotesView *mainNotesViewToPush = [[[YTMainNotesView alloc] initWithFrame:_navigationView.bounds notesDisplayParams:params] autorelease];
		mainNotesViewToPush.navigatingViewDelegate = self;
		[self pushView:mainNotesViewToPush animated:NO];
	}
}

- (void)navigatingView:(YTBaseView *)navigatingView handleGoBack:(id)param {
	if(self.navigatingViewDelegate && [self.navigatingViewDelegate respondsToSelector:@selector(navigatingView:handleGoBack:)])
		[self.navigatingViewDelegate navigatingView:navigatingView handleGoBack:nil];
}

- (void)setStatusBarBackVisible:(BOOL)statusBarBackVisible animated:(BOOL)animated animations:(void (^)(void))animations {
	if(_statusBarBackVisible != statusBarBackVisible) {
		if(animated) {
			[[UIApplication sharedApplication] setStatusBarHidden:!statusBarBackVisible withAnimation:UIStatusBarAnimationSlide];
			[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
				_statusBarBackVisible = statusBarBackVisible;
				[self layoutSubviews];
				if(animations)
					animations();
			} completion:^(BOOL finished) {
				if(finished) {
					//[[UIApplication sharedApplication] setStatusBarHidden:!statusBarBackVisible withAnimation:UIStatusBarAnimationSlide];
				}
			}];
		} else {
			_statusBarBackVisible = statusBarBackVisible;
			[self setNeedsLayout];
			[[UIApplication sharedApplication] setStatusBarHidden:!_statusBarBackVisible];
		}
	}
}

- (void)dealloc {
	[[YTUsersEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTApiMediator shared].msgrVersionChanged removeObserver:self];
	[_navigationView release];
	[_statusBarBack release];
	[_mainStatusView release];
	[super dealloc];
}

@end

