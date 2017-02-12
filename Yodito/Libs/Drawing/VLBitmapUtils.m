
#import "VLBitmapUtils.h"
#import "VLBitmap.h"

@implementation VLBitmapUtils

+ (UIImage*)grayscaleImageFromImage:(UIImage*)image
{
	VLBitmap *bitmap = [[VLBitmap alloc] init];
	VLColor *color = [[VLColor alloc] init];
	
	[bitmap createWithImage:image];
	for(int y = 0; y < bitmap.height; y++)
	{
		for(int x = 0; x < bitmap.width; x++)
		{
			[bitmap getPixel:color x:x y:y];
			float light = color.lightness;
			color.red = color.green = color.blue = light;
			[bitmap setPixel:color x:x y:y];
		}
	}
	UIImage *result = [[[bitmap getCachedImage] retain] autorelease];
	
	[bitmap release];
	[color release];

	return result;
}

+ (UIImage*)flipImageHorizontal:(UIImage*)image
{
	VLBitmap *bitmap = [[VLBitmap alloc] init];
	VLColor *color1 = [[VLColor alloc] init];
	VLColor *color2 = [[VLColor alloc] init];
	
	[bitmap createWithImage:image];
	for(int y = 0; y < bitmap.height; y++)
	{
		for(int x1 = 0; x1 < bitmap.width/2; x1++)
		{
			int x2 = (bitmap.width - 1) - x1;
			[bitmap getPixel:color1 x:x1 y:y];
			[bitmap getPixel:color2 x:x2 y:y];
			[bitmap setPixel:color2 x:x1 y:y];
			[bitmap setPixel:color1 x:x2 y:y];
		}
	}
	UIImage *result = [[[bitmap getCachedImage] retain] autorelease];
	
	[bitmap release];
	[color1 release];
	[color2 release];
	
	return result;
}

+ (UIImage*)cropImage:(UIImage*)image withRect:(CGRect)rect
{
	if(!image)
		return nil;
	CGRect rcImage = CGRectMake(0, 0, image.size.width, image.size.height);
	CGRect rcInt = CGRectIntersection(rcImage, rect);
	if(CGRectEqualToRect(rcInt, rect))
	{
		CGImageRef imageCropped = CGImageCreateWithImageInRect([image CGImage], rect);
		UIImage *result = [UIImage imageWithCGImage:imageCropped];
		CGImageRelease(imageCropped);
		return result;
	}
	VLBitmap *bmp = [[VLBitmap alloc] init];
	[bmp createWithWidth:rect.size.width height:rect.size.height];
	UIGraphicsPushContext(bmp.context);
	CGRect rcContext = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGContextClearRect(bmp.context, CGRectMake(0, 0, rcContext.size.width, rcContext.size.height));
	float dx = rect.origin.x - rcImage.origin.x;
	float dy = rect.origin.y - rcImage.origin.y;
	CGRect rcImageDraw = rcImage;
	rcImageDraw.origin.x -= dx;
	rcImageDraw.origin.y -= dy;
	
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0, rcContext.size.height);
	transform = CGAffineTransformScale(transform, 1, -1);
	CGContextConcatCTM(bmp.context, transform);
	
	float imageScale = image.scale;
	if(imageScale != 1.0)
	{
		rcImageDraw.size.width *= imageScale;
		rcImageDraw.size.height *= imageScale;
	}
	[image drawInRect:rcImageDraw];
	
	UIGraphicsPopContext();
	UIImage *result = [[[bmp getCachedImage] retain] autorelease];
	[bmp release];
	return result;
}

+ (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)newSize
{
	CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    
    // Build a context that's the same dimensions as the new size
	UIGraphicsBeginImageContext(newSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    // Draw into the context; this scales the image
	CGRect rcImageDraw = newRect;
	float imageScale = image.scale;
	if(imageScale != 1.0)
	{
		//rcImageDraw.size.width *= imageScale;
		//rcImageDraw.size.height *= imageScale;
	}
	[image drawInRect:rcImageDraw];
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
	CGSize szNewImage = newImage ? newImage.size : CGSizeZero; szNewImage = szNewImage;
	float newImageScale = newImage ? newImage.scale : 1.0; newImageScale = newImageScale;
    
    // Clean up
    UIGraphicsEndImageContext(); 
    CGImageRelease(newImageRef);

    return newImage;
}

+ (UIImage*)lightUpImage:(UIImage*)image withRatio:(float)ratio
{
	VLBitmap *bitmap = [[[VLBitmap alloc] init] autorelease];
	VLColor *color = [[[VLColor alloc] init] autorelease];
	[bitmap createWithImage:image];
	for(int y = 0; y < bitmap.height; y++)
	{
		for(int x = 0; x < bitmap.width; x++)
		{
			[bitmap getPixel:color x:x y:y];
			if(color.alpha == 0)
				continue;
			float light = color.lightness;
			float lightNew = light + (1.0 - light) * ratio;
			color.lightness = lightNew;
			[bitmap setPixel:color x:x y:y];
		}
	}
	UIImage *result = [bitmap getCachedImage];
	return result;
}

@end
