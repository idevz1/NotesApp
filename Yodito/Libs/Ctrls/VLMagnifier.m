
#import "VLMagnifier.h"
#import <QuartzCore/QuartzCore.h>
#import "../Drawing/Classes.h"

#define kViewSize CGSizeMake(128, 128)
#define kMagnifyingRatio 2.0

@interface VLMagnifier_View : UIView
{
	UIImage *_cachedImage;
}

+ (UIView*)viewToAddMagnifier;
+ (UIView*)viewToMagnify;

@end

@implementation VLMagnifier_View

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

+ (UIView*)viewToAddMagnifier
{
	UIWindow *wnd = [UIApplication sharedApplication].keyWindow;
	UIView *result = nil;
	for(UIView *subView in wnd.subviews)
	{
		if(subView.hidden)
			continue;
		if(!result)
		{
			result = subView;
			continue;
		}
		CGRect rectRes = result.frame;
		CGRect rectNew = subView.frame;
		if(rectNew.size.width*rectNew.size.height > rectRes.size.width*rectRes.size.height)
			result = subView;
	}
	return result;
}

+ (UIView*)viewToMagnify
{
	UIView *viewToAddMagnifier = [VLMagnifier_View viewToAddMagnifier];
	if(!viewToAddMagnifier)
		return nil;
	UIView *result = nil;
	for(UIView *subView in viewToAddMagnifier.subviews)
	{
		if(subView.hidden)
			continue;
		if(!result)
		{
			result = subView;
			continue;
		}
		CGRect rectRes = result.frame;
		CGRect rectNew = subView.frame;
		if(rectNew.size.width*rectNew.size.height > rectRes.size.width*rectRes.size.height)
			result = subView;
	}
	return result;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	
	float scale = [UIScreen mainScreen].scale;
	
	if(_cachedImage == nil)
	{
		UIView *viewToMagnify = [VLMagnifier_View viewToMagnify];
		if(!viewToMagnify)
			return;
		
		CGPoint ptCenter = CGPointMake(CGRectGetMidX(rcBnds), CGRectGetMaxY(rcBnds));
		ptCenter = [viewToMagnify convertPoint:ptCenter fromView:self];
		
		CGRect rcCrop = CGRectMake(0, 0, rcBnds.size.width/kMagnifyingRatio, rcBnds.size.height/kMagnifyingRatio);
		rcCrop.origin.x = ptCenter.x - rcCrop.size.width/2;
		rcCrop.origin.y = ptCenter.y - rcCrop.size.height/2;

		CGRect rcViewToMagnifyBnds = viewToMagnify.bounds;
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(rcViewToMagnifyBnds.size.width, rcViewToMagnifyBnds.size.height),
				YES, scale);
		[viewToMagnify.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *imageAll = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		_cachedImage = [[VLBitmapUtils cropImage:imageAll
			withRect:CGRectMake(rcCrop.origin.x*scale, rcCrop.origin.y*scale, rcCrop.size.width*scale, rcCrop.size.height*scale)
			//withRect:rcCrop
			] retain];
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[[VLImagesManager shared] imageNamed:@"vl-magnifier-loupe-lo.png"] drawInRect:rcBnds];
    if(_cachedImage)
	{
        
        CGContextSaveGState(ctx);
        CGContextClipToMask(ctx, rcBnds, [[VLImagesManager shared] imageNamed:@"vl-magnifier-loupe-mask.png"].CGImage);
        [_cachedImage drawInRect:rcBnds];        
        CGContextRestoreGState(ctx);
        
    }
    [[[VLImagesManager shared] imageNamed:@"vl-magnifier-loupe-hi.png"] drawInRect:rcBnds];
}

- (void)refreshMagnifiedImage
{
	if(_cachedImage)
	{
		[_cachedImage release];
		_cachedImage = nil;
	}
	[self setNeedsDisplay];
}

- (void)dealloc
{
	[_cachedImage release];
	[super dealloc];
}

@end



@implementation VLMagnifier

+ (VLMagnifier*)shared
{
	static VLMagnifier *_shared = nil;
	if(!_shared)
		_shared = [[VLMagnifier alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		
	}
	return self;
}

- (void)startShowWithPoint:(CGPoint)pt inView:(UIView*)view
{
	[self stopShow];
	UIView *viewToAddMagnifier = [VLMagnifier_View viewToAddMagnifier];
	UIView *viewToMagnify = [VLMagnifier_View viewToMagnify];
	if(!viewToAddMagnifier || !viewToMagnify)
		return;
	if(!_view)
	{
		_view = [[VLMagnifier_View alloc] initWithFrame:CGRectMake(0, 0,
						kViewSize.width, kViewSize.height)];
		[viewToAddMagnifier addSubview:_view];
	}
	[self continueShowWithPoint:pt inView:view];
}

- (void)continueShowWithPoint:(CGPoint)pt inView:(UIView*)view
{
	if(!_view)
		return;
	UIView *viewToAddMagnifier = [VLMagnifier_View viewToAddMagnifier];
	if(!viewToAddMagnifier)
		return;
	CGPoint ptWnd = [view convertPoint:pt toView:viewToAddMagnifier];
	CGRect rcView = _view.frame;
	rcView.origin.x = ptWnd.x - rcView.size.width/2;
	rcView.origin.y = ptWnd.y - rcView.size.height;
	if(!CGRectEqualToRect(_view.frame, rcView))
	{
		_view.frame = rcView;
		[self refreshMagnifiedImage];
	}
}

- (void)stopShow
{
	if(!_view)
		return;
	[_view removeFromSuperview];
	[_view release];
	_view = nil;
}

- (void)refreshMagnifiedImage
{
	if(_view)
		[_view refreshMagnifiedImage];
}

- (void)dealloc
{
	[_view release];
	[super dealloc];
}

@end
