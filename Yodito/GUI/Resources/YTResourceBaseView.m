
#import "YTResourceBaseView.h"

@implementation YTResourceBaseView

@synthesize loadingReference = _loadingReference;
@synthesize activityView = _activityView;
@synthesize makeThumbnails = _makeThumbnails;
@synthesize makePreview = _makePreview;
@synthesize aspectFill = _aspectFill;
@synthesize activityBackColor = _activityBackColor;
@synthesize showActivityIndicator = _showActivityIndicator;

- (void)initialize {
	[super initialize];
	_showActivityIndicator = YES;
	self.backgroundColor = [UIColor blackColor];
	_makePreview = YES;
	_activityBackColor = [[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] retain];
	
	_activityView = [[UIActivityIndicatorView alloc] init];
	_activityView.hidden = YES;
	_activityView.contentMode = UIViewContentModeCenter;
	_activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	_activityView.backgroundColor = _activityBackColor;
	_activityView.alpha = 0.7;
	[self addSubview:_activityView];
	
	_loadingReference = [[YTResourceLoadingReference alloc] init];
	[_loadingReference.msgrVersionChanged addObserver:self selector:@selector(onLoadingReferenceChanged:)];
	
	[self updateViewAsync];
}

- (void)setActivityBackColor:(UIColor *)activityBackColor {
	[_activityBackColor release];
	_activityBackColor = [activityBackColor retain];
	_activityView.backgroundColor = _activityBackColor;
}

- (void)onUpdateView {
	[super onUpdateView];
}

- (void)onResourceDataChanged {
	[super onResourceDataChanged];
	[self updateViewAsync];
}

- (void)onLoadingReferenceChanged:(id)sender {
	[self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(_activityView)
		_activityView.frame = rcBnds;
}

- (void)dealloc {
	[_activityView release];
	_activityView = nil;
	[_loadingReference release];
	_loadingReference = nil;
	[_activityBackColor release];
	[super dealloc];
}

@end

