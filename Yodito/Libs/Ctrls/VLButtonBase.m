
#import "VLButtonBase.h"
#import "VLCtrlsCommon.h"
#import "../Drawing/Classes.h"
#import "VLCtrlsResources.h"

#define kDefaultTextColor [UIColor blackColor]
#define kDefaultShadowColor [UIColor whiteColor]

@implementation VLButtonBase

@synthesize touched = _touched;
@synthesize pressed = _pressed;
@synthesize msgrTapped = _msgrTapped;
@synthesize title = _title;
@synthesize textAlign = _textAlign;
@synthesize image = _image;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;
@synthesize contentInsetRelLeft = _contentInsetRelLeft;
@synthesize contentInsetRelTop = _contentInsetRelTop;
@synthesize contentInsetRelRight = _contentInsetRelRight;
@synthesize contentInsetRelBottom = _contentInsetRelBottom;

- (void)initialize
{
	self.alpha = 1.0;
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.multipleTouchEnabled = NO;
	_msgrTapped = [VLMessenger new];
	_msgrTapped.owner = self;
	_title = [@"" retain];
	_textAlign = NSTextAlignmentCenter;
	_font = [[UIFont systemFontOfSize:15] retain];
	_textColor = [kDefaultTextColor retain];
	_shadowColor = [kDefaultShadowColor retain];
	_contentInsetRelTop = _contentInsetRelBottom = 0.2;
	_contentInsetRelLeft = _contentInsetRelRight = 0.4;
}

- (void)setTitle:(NSString*)value
{
	if(!value)
		value = @"";
	if(![_title isEqual:value])
	{
		[_title release];
		_title = [value copy];
		[self setNeedsDisplay];
	}
}

- (void)setTextAlign:(UITextAlignment)textAlign
{
	if(_textAlign != textAlign)
	{
		_textAlign = textAlign;
		[self setNeedsDisplay];
	}
}

- (void)setImage:(UIImage *)image
{
	if(_image != image)
	{
		if(_image)
			[_image release];
		_image = image;
		if(_image)
			[_image retain];
		[self setNeedsDisplay];
	}
}

- (void)setFont:(UIFont *)font
{
	if(_font != font)
	{
		[_font release];
		_font = font ? [font retain] : nil;
	}
}

- (void)setTextColor:(UIColor *)textColor
{
	if(!textColor)
		textColor = kDefaultTextColor;
	[_textColor release];
	_textColor = [textColor retain];
	[self setNeedsDisplay];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
	if(!shadowColor)
		shadowColor = kDefaultShadowColor;
	[_shadowColor release];
	_shadowColor = [shadowColor retain];
	[self setNeedsDisplay];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
	if(!CGSizeEqualToSize(_shadowOffset, shadowOffset))
	{
		_shadowOffset = shadowOffset;
		[self setNeedsDisplay];
	}
}

- (void)setContentInsetRelLeft:(float)value
{
	if(_contentInsetRelLeft != value)
	{
		_contentInsetRelLeft = value;
		[self setNeedsDisplay];
	}
}
- (void)setContentInsetRelTop:(float)value
{
	if(_contentInsetRelTop != value)
	{
		_contentInsetRelTop = value;
		[self setNeedsDisplay];
	}
}
- (void)setContentInsetRelRight:(float)value
{
	if(_contentInsetRelRight != value)
	{
		_contentInsetRelRight = value;
		[self setNeedsDisplay];
	}
}
- (void)setContentInsetRelBottom:(float)value
{
	if(_contentInsetRelBottom != value)
	{
		_contentInsetRelBottom = value;
		[self setNeedsDisplay];
	}
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
	if(self.userInteractionEnabled != userInteractionEnabled)
	{
		[super setUserInteractionEnabled:userInteractionEnabled];
		[self setNeedsDisplay];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self setNeedsDisplay];
}

- (CGRect)rectContent
{
	CGRect rcBnds = self.bounds;
	float side = MIN(rcBnds.size.width, rcBnds.size.height);
	CGRect result = rcBnds;
	result.origin.x += side * _contentInsetRelLeft;
	result.size.width -= side * (_contentInsetRelLeft + _contentInsetRelRight);
	result.origin.y += side * _contentInsetRelTop;
	result.size.height -= side * (_contentInsetRelTop + _contentInsetRelBottom);
	result = [VLGeometry roundRect:result];
	return result;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_touchedEnded = NO;
	_touched = YES;
    [self setNeedsDisplay];
}

- (void)endTouch
{
	_touched = NO;
    [self setNeedsDisplay];
}

- (BOOL)isTouchAbove:(NSSet *)touches
{
	UITouch *touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	CGRect rcView = self.bounds;
	return CGRectContainsPoint(rcView, pt);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	BOOL touched = [self isTouchAbove:touches];
	if(_touched != touched)
	{
		_touched = touched;
		[self setNeedsDisplay];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self endTouch];
	if([self isTouchAbove:touches])
		[_msgrTapped postMessage];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self endTouch];
}

- (void)setPressed:(BOOL)pressed
{
	if(_pressed != pressed)
	{
		_pressed = pressed;
		[self setNeedsDisplay];
	}
}

- (void)drawTitle:(NSString*)title inArea:(CGRect)rcArea align:(UITextAlignment)align
{
	if([NSString isEmpty:title])
		return;
	CGRect rcText = rcArea;
	rcText.size = [title vlSizeWithFont:self.font];
	rcText.origin.y = CGRectGetMidY(rcArea) - rcText.size.height/2;
	if(self.textAlign == NSTextAlignmentLeft)
		rcText.origin.x = rcArea.origin.x;
	else if(self.textAlign == NSTextAlignmentCenter)
		rcText.origin.x = CGRectGetMidX(rcArea) - rcText.size.width/2;
	else if(self.textAlign == NSTextAlignmentRight)
		rcText.origin.x = CGRectGetMaxX(rcArea) - rcText.size.width;
	rcText = [UIScreen roundRect:rcText];
	
	CGSize offset = self.shadowOffset;
	if(offset.width != 0 || offset.height != 0)
	{
		[self.shadowColor setFill];
		rcText.origin.x += offset.width;
		rcText.origin.y += offset.height;
		[title vlDrawInRect:rcText withFont:self.font color:self.shadowColor];
		rcText.origin.x -= offset.width;
		rcText.origin.y -= offset.height;
	}
	
	[self.textColor setFill];
	[title vlDrawInRect:rcText withFont:self.font color:self.textColor];
}

- (void)dealloc
{
	[_msgrTapped release];
	[_title release];
	[_image release];
	[_font release];
	[_textColor release];
	[_shadowColor release];
	[super dealloc];
}

@end




@implementation VLButtonDrawerBase

- (void)VLBaseDrawableView:(VLBaseDrawableView*)view drawRect:(CGRect)rect
{
	
}

- (void)drawTitle:(NSString*)title
		   inRect:(CGRect)rect
		 withFont:(UIFont*)font
		withColor:(UIColor*)color
		textAlign:(UITextAlignment)textAlign
{
	if([NSString isEmpty:title])
		return;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, color.CGColor);
	CGSize szTitle = [title vlSizeWithFont:font];
	CGPoint ptCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGRect rcText = CGRectZero;
	rcText.size = szTitle;
	rcText.origin.y = round(ptCenter.y - szTitle.height/2);
	if(textAlign == NSTextAlignmentLeft)
		rcText.origin.x = rect.origin.x;
	else if(textAlign == NSTextAlignmentCenter)
		rcText.origin.x = round(ptCenter.x - szTitle.width/2);
	else if(textAlign == NSTextAlignmentRight)
		rcText.origin.x = round(CGRectGetMaxX(rect) - szTitle.width);
	[title vlDrawInRect:rcText withFont:font color:color];
}

@end


@implementation VLButtonDrawerStandard

+ (VLButtonDrawerStandard*)sharedVLButtonDrawerStandard
{
	static VLButtonDrawerStandard *_shared = nil;
	if(!_shared)
		_shared = [[VLButtonDrawerStandard alloc] init];
	return _shared;
}

- (void)VLBaseDrawableView:(VLBaseDrawableView*)view drawRect:(CGRect)rect
{
	VLButtonBase *button = ObjectCast(view, VLButtonBase);
	if(!button)
		return;
	CGRect rcBnds = button.bounds;
	if(rcBnds.size.width < 3 || rcBnds.size.height < 3)
		return;
	float lineWidth = 1.0;
	CGRect rcBtn = CGRectInset(rcBnds, lineWidth/2, lineWidth/2);
	float corner = MIN(iUiChoice(10, 10), MIN(rcBtn.size.width/2, rcBtn.size.height/2));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	UIColor *colBack1 = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
	UIColor *colBack2 = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
	UIColor *colText = [UIColor colorWithRed:54/255.0 green:83/255.0 blue:135/255.0 alpha:1.0];
	UIColor *colBorder = [UIColor colorWithWhite:159/255.0 alpha:1.0];
	if(button.touched)
	{
		colBack1 = [UIColor colorWithRed:5/255.0 green:140/255.0 blue:245/255.0 alpha:1.0];
		colBack2 = [UIColor colorWithRed:1/255.0 green:95/255.0 blue:230/255.0 alpha:1.0];
		colText = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
		colBorder = [UIColor colorWithRed:90/255.0 green:136/255.0 blue:177/255.0 alpha:1.0];
	}
	CGContextSaveGState(ctx);
	[VLGraphicsUtils context:ctx addRoundedRect:rcBtn withCornerRadius:corner];
	CGContextClip(ctx);
	[VLGraphicsUtils context:ctx drawLinearGradientWithColor1:colBack1 color2:colBack2
					  point1:CGPointMake(rcBtn.origin.x, rcBtn.origin.y)
					  point2:CGPointMake(rcBtn.origin.x, CGRectGetMaxY(rcBtn))];
	CGContextRestoreGState(ctx);
	[VLGraphicsUtils context:ctx drawRoundedRect:rcBtn withCornerRadius:corner
				   lineWidth:lineWidth lineColor:colBorder fillColor:[UIColor clearColor]];
	NSString *title = button.title;
	if(![NSString isEmpty:title])
	{
		UIFont *font = button.font;
		[self drawTitle:title inRect:rcBtn withFont:font withColor:colText textAlign:button.textAlign];
	}
}

@end


@implementation VLButtonDrawerImage

- (id)initWithImage:(UIImage*)image
	  timageTouched:(UIImage*)imageTouched
	  imageDisabled:(UIImage*)imageDisabled
		  colorText:(UIColor*)colorText
   colorTextTouched:(UIColor*)colorTextTouched
{
	self = [super init];
	if(self)
	{
		if(image)
			_image = [image retain];
		if(imageTouched)
			_imageTouched = [imageTouched retain];
		if(imageDisabled)
			_imageDisabled = [imageDisabled retain];
		if(colorText)
			_colorText = [colorText retain];
		if(colorTextTouched)
			_colorTextTouched = [colorTextTouched retain];
	}
	return self;
}

- (void)VLBaseDrawableView:(VLBaseDrawableView*)view drawRect:(CGRect)rect onlyBack:(BOOL)onlyBack
{
	VLButtonBase *button = ObjectCast(view, VLButtonBase);
	if(!button)
		return;
	CGRect rcBnds = button.bounds;
	if(rcBnds.size.width < 3 || rcBnds.size.height < 3)
		return;
	UIImage *image = _image;
	if(!button.userInteractionEnabled && _imageDisabled)
		image = _imageDisabled;
	else if(button.touched && _image && button.userInteractionEnabled)
		image = _imageTouched;
	if(image)
		[image drawInRect:rcBnds];
	NSString *title = button.title;
	if(!onlyBack && ![NSString isEmpty:title])
	{
		UIColor *colText = _colorText;
		if(button.touched && _colorTextTouched)
			colText = _colorTextTouched;
		if(!colText)
			colText = [UIColor blackColor];
		UIFont *font = button.font;
		[self drawTitle:title inRect:rcBnds withFont:font withColor:colText textAlign:button.textAlign];
	}
}

- (void)VLBaseDrawableView:(VLBaseDrawableView*)view drawRect:(CGRect)rect
{
	[self VLBaseDrawableView:view drawRect:rect onlyBack:NO];
}

- (void)dealloc
{
	[_image release];
	[_imageTouched release];
	[_imageDisabled release];
	[_colorText release];
	[_colorTextTouched release];
	[super dealloc];
}

@end




