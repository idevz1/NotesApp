
#import "VLGraphicsUtils.h"
#import "VLUIObjects+Categories.h"
#import "../Common/Classes.h"

@implementation VLGraphicsUtils

+ (CGFloat)fontSizeForText:(NSString*)text
				  withFont:(UIFont *)font
constrainedToSizeMultiline:(CGSize)size
			 lineBreakMode:(UILineBreakMode)lineBreakMode
{
	CGFloat fontSize = [font pointSize];
    CGFloat height = [text vlSizeWithFont:font constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:lineBreakMode].height;
    UIFont *newFont = font;
	
    //Reduce font size while too large, break if no height (empty string)
    while (height > size.height && height != 0) {   
        fontSize--;  
        newFont = [UIFont fontWithName:font.fontName size:fontSize];   
        height = [text vlSizeWithFont:newFont constrainedToSize:CGSizeMake(size.width,FLT_MAX) lineBreakMode:lineBreakMode].height;
    };
	
	static NSCharacterSet *_charsSet = nil;
	if(!_charsSet)
		//_charsSet = [[NSCharacterSet characterSetWithCharactersInString:@" \t\n\r/|\\`'\",.;:&^%$#@!(){}[]"] retain];
		//_charsSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		_charsSet = [[NSCharacterSet characterSetWithCharactersInString:@" \t\n\r"] retain];
    // Loop through words in string and resize to fit
	if(lineBreakMode == NSLineBreakByWordWrapping)
	{
		for (NSString *word in [text componentsSeparatedByCharactersInSet:_charsSet])
		{
			CGFloat width = [word vlSizeWithFont:newFont].width;
			while (width > size.width && width != 0)
			{
				fontSize--;
				newFont = [UIFont fontWithName:font.fontName size:fontSize];   
				width = [word vlSizeWithFont:newFont].width;
			}
		}
	}
    return fontSize;
}

+ (void)context:(CGContextRef)ctx addRoundedRect:(CGRect)rect withCornerRadius:(float)corner_radius
{
	CGFloat x_left = rect.origin.x;
    CGFloat x_left_center = rect.origin.x + corner_radius;
    CGFloat x_right_center = rect.origin.x + rect.size.width - corner_radius;
    CGFloat x_right = rect.origin.x + rect.size.width;
    CGFloat y_top = rect.origin.y;
    CGFloat y_top_center = rect.origin.y + corner_radius;
    CGFloat y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
    CGFloat y_bottom = rect.origin.y + rect.size.height;
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x_left, y_top_center);
    CGContextAddArcToPoint(ctx, x_left, y_top, x_left_center, y_top, corner_radius);
    CGContextAddLineToPoint(ctx, x_right_center, y_top);
    CGContextAddArcToPoint(ctx, x_right, y_top, x_right, y_top_center, corner_radius);
    CGContextAddLineToPoint(ctx, x_right, y_bottom_center);
    CGContextAddArcToPoint(ctx, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
    CGContextAddLineToPoint(ctx, x_left_center, y_bottom);
    CGContextAddArcToPoint(ctx, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
    CGContextAddLineToPoint(ctx, x_left, y_top_center);
    CGContextClosePath(ctx);
}

+ (void)context:(CGContextRef)ctx drawRoundedRect:(CGRect)rect
	withCornerRadius:(float)corner_radius
	  lineWidth:(float)lineWidth
	  lineColor:(UIColor*)lineColor
	  fillColor:(UIColor*)fillColor
{
	CGRect rcFill = CGRectInset(rect, lineWidth/6, lineWidth/6);
	CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
	CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
	[self context:ctx addRoundedRect:rcFill withCornerRadius:corner_radius];
	CGContextFillPath(ctx);
	CGContextSetLineWidth(ctx, lineWidth);
	[self context:ctx addRoundedRect:rcFill withCornerRadius:corner_radius];
	CGContextStrokePath(ctx);
}

+ (void)context:(CGContextRef)ctx drawLinearGradientWithColor1:(UIColor*)color1
		 color2:(UIColor*)color2
		 point1:(CGPoint)point1
		 point2:(CGPoint)point2
{
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8];
	[color1 getRGBAComponents:&components[0]];
	[color2 getRGBAComponents:&components[4]];
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	CGContextDrawLinearGradient (ctx, myGradient, point1, point2, 0);
	CGColorSpaceRelease(myColorspace);
	CGGradientRelease(myGradient);
}

+ (void)context:(CGContextRef)ctx drawRadialGradientWithColor1:(UIColor*)color1
		 color2:(UIColor*)color2
		center1:(CGPoint)center1
		radius1:(float)radius1
		center2:(CGPoint)center2
		radius2:(float)radius2
{
	size_t numLocations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8];
	[color1 getRGBAComponents:&components[0]];
	[color2 getRGBAComponents:&components[4]];
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, components, locations, numLocations);
	
	CGContextDrawRadialGradient(ctx,
								gradient,
								center1,
								radius1,
								center2,
								radius2,
								0);
	
	CGColorSpaceRelease(colorspace);
	CGGradientRelease(gradient);
}

+ (void)fillRect:(CGRect)rect withTileImage:(UIImage*)image
{
	if(rect.size.width < 1 || rect.size.height < 1)
		return;
	CGSize szImage = image.size;
	for(float y = rect.origin.y; y < CGRectGetMaxY(rect); y += szImage.height)
	{
		for(float x = rect.origin.x; x < CGRectGetMaxX(rect); x += szImage.width)
		{
			CGRect rcImage = CGRectMake(x, y, szImage.width, szImage.height);
			[image drawInRect:rcImage];
		}
	}
}

+ (void)context:(CGContextRef)ctx drawLineFromPoint:(CGPoint)pt1 toPoint:(CGPoint)pt2
{
	CGContextMoveToPoint(ctx, pt1.x, pt1.y);
	CGContextAddLineToPoint(ctx, pt2.x, pt2.y);
	CGContextStrokePath(ctx);
}

@end
