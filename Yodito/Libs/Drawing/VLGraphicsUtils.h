
#import <Foundation/Foundation.h>

@interface VLGraphicsUtils : NSObject
{
	
}

+ (CGFloat)fontSizeForText:(NSString*)text
				  withFont:(UIFont *)font
 constrainedToSizeMultiline:(CGSize)size
			  lineBreakMode:(UILineBreakMode)lineBreakMode;

+ (void)context:(CGContextRef)ctx addRoundedRect:(CGRect)rect withCornerRadius:(float)corner_radius;

+ (void)context:(CGContextRef)ctx drawRoundedRect:(CGRect)rect
				withCornerRadius:(float)corner_radius
					lineWidth:(float)lineWidth
					lineColor:(UIColor*)lineColor
				fillColor:(UIColor*)fillColor;

+ (void)context:(CGContextRef)ctx drawLinearGradientWithColor1:(UIColor*)color1
				color2:(UIColor*)color2
				point1:(CGPoint)point1
				point2:(CGPoint)point2;

+ (void)context:(CGContextRef)ctx drawRadialGradientWithColor1:(UIColor*)color1
		 color2:(UIColor*)color2
		 center1:(CGPoint)center1
		radius1:(float)radius1
		 center2:(CGPoint)center2
		radius2:(float)radius2;

+ (void)fillRect:(CGRect)rect withTileImage:(UIImage*)image;

+ (void)context:(CGContextRef)ctx drawLineFromPoint:(CGPoint)pt1 toPoint:(CGPoint)pt2;

@end
