
#import "VLSidesSwipeViewHelper.h"

#define kPosDelta 8.0
#define kUptimeDelta 3.25
#define kAnimationDuration (kDefaultAnimationDuration/2)

@implementation VLSidesSwipeViewHelper

@synthesize delegate = _delegate;
@synthesize slideRatio = _slideRatio;
@dynamic contentOffsetX;
@synthesize sliding = _sliding;
@synthesize slidingRight = _slidingRight;
@synthesize slidingLeft = _slidingLeft;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (VLBaseView *)contentView {
	if(_delegate)
		return [_delegate sidesSwipeViewHelper:self getContentView:nil];
	return nil;
}

- (void)setSlideRatio:(float)slideRatio animated:(BOOL)animated {
	if(slideRatio < -1.0)
		slideRatio = -1.0;
	if(slideRatio > 1.0)
		slideRatio = 1.0;
	if(_slideRatio != slideRatio) {
		float lastSlideRatio = _slideRatio;
		float newSlideRation = slideRatio;
		if(_delegate)
			[_delegate sidesSwipeViewHelper:self layoutContentView:nil];
		[UIView animateWithDuration:kAnimationDuration
			animations:^
		{
			_slideRatio = slideRatio;
			if(_delegate) {
				if(lastSlideRatio == 0)
					[_delegate sidesSwipeViewHelper:self slidingStarted:nil];
				[_delegate sidesSwipeViewHelper:self layoutContentView:nil];
			}
		}
		 completion:^(BOOL finished)
		{
			if(finished && (_slideRatio == newSlideRation)) {
				if(_slideRatio == 0) {
					if(_sliding || _slidingLeft || _slidingRight) {
						_sliding = NO;
						_slidingLeft = NO;
						_slidingRight = NO;
						if(_delegate)
							[_delegate sidesSwipeViewHelper:self layoutContentView:nil];
					}
					if(_delegate)
						[_delegate sidesSwipeViewHelper:self slidingStopped:nil];
				} else {
					if(_sliding) {
						if(_slideRatio == 1.0 || _slideRatio == -1.0) {
							if(_delegate)
								[_delegate sidesSwipeViewHelper:self slidingStopped:nil];
						}
					}
				}
			}
		}];
	}
}

- (void)stopSlideWithCancel:(BOOL)cancel {
	_slideTrackStarted = NO;
    if(!cancel) {
        if((_slidingRight && _slideRatio > 0.5)
           || (_slidingLeft && _slideRatio < -0.5)) {
            if(_slidingRight) {
                [self setSlideRatio:1.0 animated:YES];
            } else if(_slidingLeft) {
                [self setSlideRatio:-1.0 animated:YES];
            }
            return;
        }
    }
	if(_slideRatio != 0) {
		[self setSlideRatio:0.0 animated:YES];
	} else {
		if(_sliding || _slidingLeft || _slidingRight) {
			_sliding = NO;
			_slidingLeft = NO;
			_slidingRight = NO;
			if(_delegate)
				[_delegate sidesSwipeViewHelper:self layoutContentView:nil];
		}
	}
}

- (void)resetSlide {
	_slideRatio = 0;
	_slideTrackStarted = NO;
	_sliding = NO;
	_slidingRight = NO;
	_slidingLeft = NO;
}

- (float)contentOffsetX {
	VLBaseView *contentView = [self contentView];
	if(contentView) {
		CGRect rcBnds = contentView.bounds;
		float dx = rcBnds.size.width * _slideRatio;
		return dx;
	}
	return 0;
}

- (void)handleTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if(!_sliding)
		[self stopSlideWithCancel:YES];
	CGPoint pt = [[touches anyObject] locationInView:[self contentView]];
	_ptStart = pt;
	_uptimeSlideStart = [VLTimer systemUptime];
	if(!_sliding) {
		_slideTrackStarted = YES;
		_slideRatioStart = 0.0;
	} else {
		_slideRatioStart = _slideRatio;
	}
}

- (void)handleTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	VLBaseView *contentView = [self contentView];
	if(!contentView)
		return;
	CGPoint pt = [[touches anyObject] locationInView:contentView];
	CGRect rcBnds = contentView.bounds;
	if(rcBnds.size.width < 1)
		return;
	NSTimeInterval uptime = [VLTimer systemUptime];
	float newSlideRatio = _slideRatioStart + (pt.x - _ptStart.x) / rcBnds.size.width;
	if(_sliding) {
		[self setSlideRatio:newSlideRatio animated:YES];
	} else if(_slideTrackStarted) {
		float dx = pt.x - _ptStart.x;
		float dy = pt.y - _ptStart.y;
		if(ABS(dy) > kPosDelta || (uptime - _uptimeSlideStart) > kUptimeDelta) {
			[self stopSlideWithCancel:YES];
		} else if(ABS(dx) > kPosDelta) {
			if(dx > 0 && pt.x < CGRectGetMidX(rcBnds)) {
				_sliding = YES;
				_slidingRight = YES;
				[self setSlideRatio:newSlideRatio animated:YES];
			} else if(dx < 0 && pt.x > CGRectGetMidX(rcBnds)) {
				_sliding = YES;
				_slidingLeft = YES;
				[self setSlideRatio:newSlideRatio animated:YES];
			} else {
				[self stopSlideWithCancel:YES];
			}
		}
	}
}

- (void)handleTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self stopSlideWithCancel:NO];
}

- (void)handleTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self stopSlideWithCancel:YES];
}

- (void)dealloc {
	[super dealloc];
}

@end

