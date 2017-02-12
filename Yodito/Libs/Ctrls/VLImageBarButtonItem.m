
#import "VLImageBarButtonItem.h"
#import "VL_UIControls_Categories.h"

#define kButtonDisabledAlpha 0.7

@implementation VLImageBarButtonItem

@synthesize button = _button;
@synthesize insetsRel = _insetsRel;

- (id)initWithImage:(UIImage*)image
			 imageH:(UIImage*)imageH
			  scale:(float)scale
			 target:(id)target
			 action:(SEL)action
{
	UIImage *imageToSize = image ? image : imageH;
	CGSize szImage = imageToSize.size;
	szImage.width = szImage.width * scale;
	szImage.height = szImage.height * scale;
	szImage = [UIScreen roundSize:szImage];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, szImage.width, szImage.height);
	button.backgroundColor = [UIColor clearColor];
	button.contentMode = UIViewContentModeScaleAspectFit;
	button.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[button setBackgroundImage:image forState:UIControlStateNormal];
	[button setBackgroundImage:imageH forState:UIControlStateSelected];
	[button setBackgroundImage:imageH forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	self = [super initWithCustomView:button];
	if(self)
	{
		_button = [button retain];
		_targetInt = target;
		_actionInt = action;
		[self setTarget:self];
		[self setAction:@selector(onTap:)];
	}
	return self;
}

- (void)setEnabled:(BOOL)enabled
{
	if(self.enabled != enabled)
	{
		_button.alpha = enabled ? 1.0 : kButtonDisabledAlpha;
	}
	[super setEnabled:enabled];
}

- (void)onTap:(id)sender
{
	if(_targetInt && _actionInt)
		[_targetInt performSelector:_actionInt withObject:self];
}

- (void)onTouchDown:(id)sender
{
	//[VLTouchSplashView showInView:_button point:CGPointMake(CGRectGetMidX(_button.bounds), CGRectGetMidY(_button.bounds))];
}

- (void)onTouchUpInside:(id)sender
{
	//[VLTouchSplashView hide];
	[self onTap:self];
}

- (void)dealloc
{
	[_button release];
	[super dealloc];
}

@end
