
#import "VLActivityView.h"
#import "VL_UIControls_Categories.h"
#import "../Common/Classes.h"

#define kBorder 12.0

static UIColor *_defaultBackgroundcolor = nil;
static UIColor *_defaultCenterBackcolor = nil;
static BOOL _defaultDimBackground = YES;

@implementation VLActivityView

@dynamic title;
@dynamic msgrCanceled;
@synthesize transparentForTouches = _transparentForTouches;
@dynamic yOffset;
@dynamic color;
@dynamic dimBackground;
@dynamic progressMode;
@dynamic progress;

+ (void)setDefaultBackgroundcolor:(UIColor *)color {
	[_defaultBackgroundcolor release];
	_defaultBackgroundcolor = [color retain];
}

+ (void)setDefaultCenterBackcolor:(UIColor *)color {
	[_defaultCenterBackcolor release];
	_defaultCenterBackcolor = [color retain];
}

+ (void)setDefaultDimBackground:(BOOL)dimBackground {
	_defaultDimBackground = dimBackground;
}

- (void)initialize
{
	[super initialize];
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
	
	_progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
	_progressView.hidden = YES;
	[self addSubview:_progressView];
	
	_progressHUD = [[VLProgressHUD alloc] initWithView:self];
	_progressHUD.dimBackground = _defaultDimBackground;
	[self addSubview:_progressHUD];
	
	if(_defaultBackgroundcolor)
		_progressHUD.backgroundColor = _defaultBackgroundcolor;
	else if(_progressHUD.backgroundColor)
		_defaultBackgroundcolor = [_progressHUD.backgroundColor retain];
	
	if(_defaultCenterBackcolor)
		_progressHUD.color = _defaultCenterBackcolor;
	else if(_progressHUD.color)
		_defaultCenterBackcolor = [_progressHUD.color retain];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rcView = self.bounds;
	_progressHUD.frame = rcView;
	
	CGRect rcProgress = rcView;
	float border = rcView.size.width * 0.05;
	rcProgress.origin.x += border;
	rcProgress.size.width -= border * 2;
	rcProgress.size = [_progressView sizeThatFits:rcProgress.size];
	rcProgress.origin.y = rcView.origin.y + rcView.size.height/2 - rcProgress.size.height/2;
	_progressView.frame = rcProgress;
	if(_bnCancel)
	{
		CGRect rcBnCancel = CGRectMake(0, 0, 110, 42);
		rcBnCancel.origin.x = CGRectGetMidX(rcView) - rcBnCancel.size.width/2;
		rcBnCancel.origin.y = CGRectGetMaxY(rcProgress) + rcBnCancel.size.height;
		if(_bnCancel)
			_bnCancel.frame = rcBnCancel;
	}
}

- (void)startActivity
{
	[_progressHUD show:YES];
}

- (void)stopActivity
{
	[_progressHUD hide:YES];
}

- (void)progressShow:(float)value
{
	if(value < 0.0)
		value = 0.0;
	if(value > 1.0)
		value = 1.0;
	_progressView.progress = value;
	_progressView.hidden = NO;
}

- (void)progressHide
{
	_progressView.hidden = YES;
}

- (NSString *)title
{
	return _progressHUD.labelText;
}
- (void)setTitle:(NSString *)value
{
	_progressHUD.labelText = value;;
}

- (void)showCancelButton
{
	if(!_bnCancel)
	{
		_bnCancel = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		[_bnCancel setTitleForAllStates:@"Cancel"];
		[_bnCancel addTarget:self action:@selector(onBnCancelTouched:) forControlEvents:UIControlEventTouchUpInside];
		_bnCancel.opaque = NO;
		_bnCancel.alpha = 0.85;
		[self addSubview:_bnCancel];
		[self setNeedsLayout];
	}
}

- (VLMessenger*)msgrCanceled
{
	if(!_msgrCanceled)
	{
		_msgrCanceled = [[VLMessenger alloc] init];
		_msgrCanceled.owner = self;
	}
	return _msgrCanceled;
}

- (float)yOffset {
	return _progressHUD.yOffset;
}
- (void)setYOffset:(float)yOffset {
	_progressHUD.yOffset = yOffset;
}

- (float)progress {
	return _progressHUD.progress;
}
- (void)setProgress:(float)progress {
	_progressHUD.progress = progress;
}

- (UIColor *)color {
	return _progressHUD.color;
}
- (void)setColor:(UIColor *)color {
	_progressHUD.color = color;
}

- (BOOL)dimBackground {
	return _progressHUD.dimBackground;
}
- (void)setDimBackground:(BOOL)dimBackground {
	_progressHUD.dimBackground = dimBackground;
}

- (VLProgressHUDMode)progressMode {
	return _progressHUD.mode;
}
- (void)setProgressMode:(VLProgressHUDMode)progressMode {
	_progressHUD.mode = progressMode;
}

- (void)onBnCancelTouched:(id)sender
{
	if(_msgrCanceled)
		[_msgrCanceled postMessage];
}

- (void)setHidden:(BOOL)hidden
{
	BOOL wasHidden = self.hidden;
	[super setHidden:hidden];
	if(wasHidden != hidden)
	{
		if(hidden)
			[self stopActivity];
		else
			[self startActivity];
	}
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if(_transparentForTouches)
		return nil;
	return [super hitTest:point withEvent:event];
}

- (void)dealloc
{
	[_progressHUD release];
	[_progressView release];
	[_bnCancel release];
	[_msgrCanceled release];
	[super dealloc];
}

@end
