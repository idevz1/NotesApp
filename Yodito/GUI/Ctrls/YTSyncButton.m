
#import "YTSyncButton.h"
#import "../../API/Classes.h"

#define kRotatingInterval 3.0
#define kImageSide 36.0//20.0

@implementation YTSyncButton

@synthesize isRotating = _isRotating;

- (void)initialize
{
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	
	_lastAngle = 0;
	_lastAngleUptime = [VLTimer systemUptime];
	
	_timerRotating = [[VLTimer alloc] init];
	[_timerRotating setObserver:self selector:@selector(onTimerRotatingEvent:)];
	_timerRotating.interval = 0.01;
	_timerRotating.enabledAlwaysFiring = YES;
	
	[[YTSyncManager shared].msgrVersionChanged addObserver:self selector:@selector(onSyncManagerChanged:)];
	
	[self updateViewAsync];
}

- (void)updateImage
{
	if(!_imageView)
		return;
	UIImage *image = [UIImage imageNamed:_isPressed ? @"icon_syncing.png" : @"icon_syncing.png"];
	_imageView.image = image;
}

- (void)onTimerRotatingEvent:(id)sender
{
	if(!_imageView)
		return;
	if(_isRotating != [YTSyncManager shared].processing)
		[self updateViewNow];
	if(!_isRotating) {
		[_timerRotating stop];
		return;
	}
	NSTimeInterval uptime = [VLTimer systemUptime];
	NSTimeInterval dTime = uptime - _lastAngleUptime;
	float dAngle = dTime / kRotatingInterval * 2 * M_PI;
	_lastAngleUptime = uptime;
	float newAngle = _rotationView.rotation + dAngle;
	_rotationView.rotation = newAngle;
}

- (void)createControls
{
	if(_imageView)
		return;
	CGRect rcBnds = self.bounds;
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imageView.backgroundColor = [UIColor clearColor];
	_imageView.contentMode = UIViewContentModeCenter;// UIViewContentModeScaleAspectFit;
	
	_rotationView = [[VLRotatableContentView alloc] initWithFrame:rcBnds contentView:_imageView];
	[self addSubview:_rotationView];
	
	[self updateImage];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	[self createControls];
	CGRect rcImage = rcBnds;
	rcImage.size.width = rcImage.size.height = kImageSide;
	rcImage.origin.x = CGRectGetMidX(rcBnds) - rcImage.size.width/2;
	rcImage.origin.y = CGRectGetMidY(rcBnds) - rcImage.size.height/2;
	rcImage = [UIScreen roundRect:rcImage];
	_rotationView.frame = rcImage;
}

- (void)setIsPressed:(BOOL)isPressed
{
	if(_isPressed != isPressed)
	{
		_isPressed = isPressed;
		[self updateImage];
	}
}

- (void)setIsRotating:(BOOL)isRotating
{
	if(_isRotating != isRotating)
	{
		_isRotating = isRotating;
		if(_isRotating) {
			_lastAngleUptime = [VLTimer systemUptime];
			if(!_timerRotating.started)
				[_timerRotating start];
		}
	}
}

- (void)onUpdateView
{
	[super onUpdateView];
	YTSyncManager *manr = [YTSyncManager shared];
	[self setIsRotating:manr.processing];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	[self setIsPressed:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	CGPoint pt = [[[event allTouches] anyObject] locationInView:self];
	if(CGRectContainsPoint(self.bounds, pt))
	{
		[self setIsPressed:YES];
	}
	else
	{
		[self setIsPressed:NO];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	if(_isPressed)
	{
		[self setIsPressed:NO];
		YTSyncManager *manr = [YTSyncManager shared];
		if(!manr.processing)
		{            
			[[YTSyncManager shared] startSyncMTWithResultBlockMT:^(NSError *error) {
				if(error && !error.isCancel) {
					[VLAlertView showWithOkAndTitle:@"Error" message:[error localizedDescription]];
				}
			}];
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	[self setIsPressed:NO];
}

- (void)onSyncManagerChanged:(id)sender
{
	[self updateViewAsync];
}

- (void)dealloc
{
	[[YTSyncManager shared].msgrVersionChanged removeObserver:self];
	[_imageView release];
	[_rotationView release];
	[_timerRotating release];
	[super dealloc];
}

@end
