
#import "VLTouchSplashView.h"
#import "VLCtrlsCommon.h"
#import "../Logic/Classes.h"
#import "../Drawing/Classes.h"

#define kSplashSide iUiChoice(32.0, 42.0)
#define kViewMult 4
#define kShowDuration 0.10
#define kHideDuration 0.10
#define kMaxVisibleDuration (kShowDuration + 0.1 + kHideDuration)

@implementation VLTouchSplashView

+ (VLTouchSplashView*)getInstanceWithGet:(BOOL)get create:(BOOL)create delete:(BOOL)delete
{
	static VLTouchSplashView* _instance = nil;
	if(create)
	{
		if(!_instance)
			_instance = [[VLTouchSplashView alloc] initWithFrame:CGRectZero];
	}
	else if(delete)
	{
		if(_instance)
		{
			[_instance release];
			_instance = nil;
		}
	}
	return _instance;
}

- (void)initialize
{
	[super initialize];
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
	self.frame = CGRectMake(0, 0, kSplashSide*kViewMult, kSplashSide*kViewMult);
	self.hidden = YES;
	_timer = [[VLTimer alloc] init];
}

+ (void)showInView:(UIView*)view point:(CGPoint)point
{
	[VLTouchSplashView hide];
	
	UIWindow *wnd = [UIApplication sharedApplication].keyWindow;
	CGPoint ptWnd = [view convertPoint:point toView:wnd];
	VLTouchSplashView *instance = [VLTouchSplashView getInstanceWithGet:YES create:YES delete:NO];
	CGRect rcFrame = instance.frame;
	rcFrame.origin.x = ptWnd.x - rcFrame.size.width/2;
	rcFrame.origin.y = ptWnd.y - rcFrame.size.height/2;
	instance.frame = rcFrame;
	instance.alpha = 0.0;
	instance.hidden = NO;
	[wnd addSubview:instance];
	[instance performSelector:@selector(hideInt) withObject:nil afterDelay:kMaxVisibleDuration];
	[UIView beginAnimations:@"VLTouchSplashView_Show" context:instance];
	[UIView setAnimationDuration:kShowDuration];
	instance.alpha = 1.0;
	[UIView commitAnimations];
}

- (void)completeHiding
{
	if(self.superview)
		[self removeFromSuperview];
}

- (void)hideInt
{
	[UIView beginAnimations:@"VLTouchSplashView_Hide" context:self];
	[UIView setAnimationDuration:kHideDuration];
	self.alpha = 0.0;
	[UIView commitAnimations];
	[self performSelector:@selector(completeHiding) withObject:nil afterDelay:kHideDuration*1.5];
	if([VLTouchSplashView getInstanceWithGet:YES create:NO delete:NO] == self)
		[VLTouchSplashView getInstanceWithGet:NO create:NO delete:YES];
}
+ (void)hide
{
	VLTouchSplashView *instance = [VLTouchSplashView getInstanceWithGet:YES create:NO delete:NO];
	if(!instance)
		return;
	[[instance retain] autorelease];
	[VLTouchSplashView getInstanceWithGet:NO create:NO delete:YES];
	[instance hideInt];
}

- (void)drawRect:(CGRect)rect
{
	CGRect rcBnds = self.bounds;
	CGPoint ptCen = CGPointMake(CGRectGetMidX(rcBnds), CGRectGetMidY(rcBnds));
	float side = kSplashSide;//MIN(rcBnds.size.width, rcBnds.size.height);
	CGRect rcSplash = CGRectMake(ptCen.x - side/2, ptCen.y - side/2, side, side);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	UIColor *col1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	UIColor *col2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
	float radius = MAX(rcSplash.size.width, rcSplash.size.height)*1.2;
	[VLGraphicsUtils context:ctx
		drawRadialGradientWithColor1:col1
					  color2:col2
					 center1:ptCen
					 radius1:0.1
					 center2:ptCen
					 radius2:radius];
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	return nil;
}

- (void)dealloc
{
	[_timer release];
	[super dealloc];
}

@end


