
#import "VLImagesButtonBase.h"
#import "../Drawing/Classes.h"

@implementation VLImagesButtonBase

- (void)initialize
{
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
}

- (void)drawImage:(UIImage*)image inRect:(CGRect)rect xMax:(float)xMax yMax:(float)yMax
{
	if(xMax >= CGRectGetMaxX(rect) && yMax >= CGRectGetMaxY(rect))
	{
		[image drawInRect:rect];
		return;
	}
	CGRect rcClip = rect;
	if(xMax < CGRectGetMaxX(rect))
		rcClip.size.width = xMax - rcClip.origin.x;
	if(yMax < CGRectGetMaxY(rect))
		rcClip.size.height = yMax - rcClip.origin.y;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextClipToRect(ctx, rcClip);
	[image drawInRect:rect];
	CGContextRestoreGState(ctx);
}

- (void)drawRect:(CGRect)rect
{
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	UIImage *imageL = [self getLeftImage];
	UIImage *imageM = [self getMiddleImage];
	UIImage *imageR = [self getRightImage];
	if(!imageL || !imageM || !imageR)
		return;
	CGRect rcL = rcBnds;
	rcL.size.width = round(rcL.size.height * imageL.size.width / imageL.size.height);
	CGRect rcR = rcBnds;
	rcR.size.width = round(rcR.size.height * imageR.size.width / imageR.size.height);
	rcR.origin.x = CGRectGetMaxX(rcBnds) - rcR.size.width;
	[imageL drawInRect:rcL];
	[imageR drawInRect:rcR];
	CGSize szM = rcBnds.size;
	szM.width = round(szM.height * imageM.size.width / imageM.size.height);
	for(float x = CGRectGetMaxX(rcL); ; x += szM.width)
	{
		float xMax = CGRectGetMaxX(rcBnds) - rcR.size.width;
		if(x >= xMax)
			break;
		CGRect rcM = rcBnds;
		rcM.size = szM;
		rcM.origin.x = x;
		[self drawImage:imageM
				 inRect:rcM
				   xMax:xMax yMax:CGRectGetMaxY(rcBnds)];
	}
	
	CGRect rcContent = [self rectContent];
	float distHorzRel = 0.05;
	UIImage *image = self.image;
	if(image)
	{
		CGRect rcImage = rcContent;
		rcImage.size.width = rcContent.size.height;
		float dx = rcImage.size.width + rcBnds.size.width * distHorzRel;
		rcContent.origin.x += dx;
		rcContent.size.width -= dx;
		CGRect rcImageToDraw = [VLGeometry rectOfFitToRect:rcImage size:image.size];
		[image drawInRect:rcImageToDraw];
	}
	rcContent = [UIScreen roundRect:rcContent];
	NSString *title = self.title;
	[super drawTitle:title inArea:rcContent align:self.textAlign];
}

- (UIImage*)getLeftImage
{
	return nil;
}

- (UIImage*)getMiddleImage
{
	return nil;
}

- (UIImage*)getRightImage
{
	return nil;
}

- (void)dealloc
{
	[super dealloc];
}

@end
