
#import "VLViewsTransitionAnimator.h"

@implementation VLViewsTransitionAnimator

@synthesize animationDuration = _animationDuration;

- (id)init {
	self = [super init];
	if(self) {
		_animationDuration = kDefaultAnimationDuration;
	}
	return self;
}

- (NSTimeInterval)animationDuration {
	return _animationDuration;
}

- (UIView *)getSharedSuperviewOfView:(UIView *)view1 andView:(UIView *)view2 {
	UIView *viewOn = nil;
	NSMutableArray *arrSuperviewsFrom = [NSMutableArray array];
	UIView *superview = view1 ? view1.superview : nil;
	while(superview) {
		[arrSuperviewsFrom addObject:superview];
		superview = superview.superview;
	}
	NSMutableArray *arrSuperviewsTo = [NSMutableArray array];
	superview = view2 ? view2.superview : nil;
	while(superview) {
		[arrSuperviewsTo addObject:superview];
		superview = superview.superview;
	}
	for(UIView *superviewFrom in arrSuperviewsFrom) {
		for(UIView *superviewTo in arrSuperviewsTo) {
			if(superviewFrom == superviewTo) {
				viewOn = superviewFrom;
				break;
			}
		}
		if(viewOn)
			break;
	}
	return viewOn;
}

- (void)startAnimateUsingImageFromView:(UIView *)viewFrom
					  toView:(UIView *)viewTo
				  animations:(void (^)(void))animations
				  completion:(void (^)())completion {
	
	UIView *viewOn = [self getSharedSuperviewOfView:viewFrom andView:viewTo];
	NSTimeInterval animationDuration = [self animationDuration];
	if(!viewOn) {
		[UIView animateWithDuration:animationDuration animations:^{
			animations();
		} completion:^(BOOL finished) {
			if(finished) {
				completion();
			}
		}];
		return;
	}
	
	CGRect rcFromOrig = viewFrom.frame;
	CGRect rcToOrig = viewTo.frame;
	BOOL hiddenFromOrig = viewFrom.hidden;
	BOOL hiddenToOrig = viewTo.hidden;
	float alphaFromOrig = viewFrom.alpha;
	float alphaToOrig = viewTo.alpha;
	
	UIImage *imageFrom = nil;
	UIImage *imageTo = nil;
	
	UIGraphicsBeginImageContext(rcFromOrig.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[viewFrom.layer renderInContext:ctx];
	imageFrom = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	UIGraphicsBeginImageContext(rcToOrig.size);
	ctx = UIGraphicsGetCurrentContext();
	[viewTo.layer renderInContext:ctx];
	imageTo = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageView *imageViewFrom = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
	imageViewFrom.contentMode = UIViewContentModeScaleToFill;
	imageViewFrom.image = imageFrom;
	[viewOn addSubview:imageViewFrom];
	UIImageView *imageViewTo = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
	imageViewTo.contentMode = UIViewContentModeScaleToFill;
	imageViewTo.image = imageTo;
	[viewOn addSubview:imageViewTo];
	
	viewFrom.hidden = YES;
	viewTo.hidden = NO;
	viewTo.alpha = 0.01;
	
	CGRect rect = [viewOn convertRect:rcFromOrig fromView:viewFrom.superview];
	imageViewFrom.frame = rect;
	imageViewTo.frame = rect;
	imageViewFrom.alpha = 1.0;
	imageViewTo.alpha = 0.0;
	
	[UIView animateWithDuration:animationDuration animations:^
	{
		CGRect rect = [viewOn convertRect:rcToOrig fromView:viewTo.superview];
		imageViewFrom.frame = rect;
		imageViewTo.frame = rect;
		imageViewFrom.alpha = 0.0;
		imageViewTo.alpha = 1.0;
		
		animations();
	}
	 completion:^(BOOL finished)
	{
		if(finished) {
			[imageViewFrom removeFromSuperview];
			[UIView animateWithDuration:0.05 animations:^{
				imageViewTo.alpha = 0.0;
			} completion:^(BOOL finished) {
				if(finished) {
					[imageViewTo removeFromSuperview];
				}
			}];
			viewFrom.hidden = hiddenFromOrig;
			viewTo.hidden = hiddenToOrig;
			viewFrom.alpha = alphaFromOrig;
			viewTo.alpha = alphaToOrig;
			
			completion();
		}
	}];
}

- (void)startAnimateUsingMovingFromView:(UIView *)viewFrom
					  toView:(UIView *)viewTo
				  animations:(void (^)(void))animations
				  completion:(void (^)())completion {
	
	UIView *viewOn = [self getSharedSuperviewOfView:viewFrom andView:viewTo];
	NSTimeInterval animationDuration = [self animationDuration];
	if(!viewOn) {
		[UIView animateWithDuration:animationDuration animations:^{
			animations();
		} completion:^(BOOL finished) {
			if(finished) {
				completion();
			}
		}];
		return;
	}
	
	UIView *superviewFromOrig = viewFrom.superview;
	UIView *superviewToOrig = viewTo.superview;
	CGRect rcFromOrig = viewFrom.frame;
	CGRect rcToOrig = viewTo.frame;
	float alphaFromOrig = viewFrom.alpha;
	float alphaToOrig = viewTo.alpha;
	
	CGRect rcFrom = [viewOn convertRect:viewFrom.frame fromView:viewFrom.superview];
	CGRect rcTo = [viewOn convertRect:viewTo.frame fromView:viewTo.superview];
	
	[[viewFrom retain] autorelease];
	[viewFrom removeFromSuperview];
	viewFrom.frame = rcFrom;
	[viewOn addSubview:viewFrom];
	
	[[viewTo retain] autorelease];
	[viewTo removeFromSuperview];
	viewTo.frame = rcFrom;
	[viewOn addSubview:viewTo];
	
	viewFrom.alpha = 1.0;
	viewTo.alpha = 0.0;
	
	[UIView animateWithDuration:animationDuration
					 animations:^
	{
		viewFrom.frame = rcTo;
		viewTo.frame = rcTo;
		viewFrom.alpha = 0.0;
		viewTo.alpha = 1.0;
		
		animations();
	}
	 completion:^(BOOL finished)
	{
		if(finished) {
			[[viewFrom retain] autorelease];
			[viewFrom removeFromSuperview];
			[superviewFromOrig addSubview:viewFrom];
			viewFrom.frame = rcFromOrig;
			
			[[viewTo retain] autorelease];
			[viewTo removeFromSuperview];
			[superviewToOrig addSubview:viewTo];
			viewTo.frame = rcToOrig;
			
			viewFrom.alpha = alphaFromOrig;
			viewTo.alpha = alphaToOrig;
			
			completion();
		}
	}];
}

- (void)startAnimateUsingIncrementalMovingFromView:(UIView *)viewFrom
								 toView:(UIView *)viewTo
							 animations:(void (^)(void))animations
							 completion:(void (^)())completion {
	
	UIView *viewOn = [self getSharedSuperviewOfView:viewFrom andView:viewTo];
	NSTimeInterval animationDuration = [self animationDuration];
	if(!viewOn) {
		[UIView animateWithDuration:animationDuration animations:^{
			animations();
		} completion:^(BOOL finished) {
			if(finished) {
				completion();
			}
		}];
		return;
	}
	
	UIView *superviewFromOrig = viewFrom.superview;
	UIView *superviewToOrig = viewTo.superview;
	CGRect rcFromOrig = viewFrom.frame;
	CGRect rcToOrig = viewTo.frame;
	float alphaFromOrig = viewFrom.alpha;
	float alphaToOrig = viewTo.alpha;
	
	CGRect rcFrom = [viewOn convertRect:viewFrom.frame fromView:viewFrom.superview];
	CGRect rcTo = [viewOn convertRect:viewTo.frame fromView:viewTo.superview];
	
	[[viewFrom retain] autorelease];
	[viewFrom removeFromSuperview];
	viewFrom.frame = rcFrom;
	[viewOn addSubview:viewFrom];
	
	[[viewTo retain] autorelease];
	[viewTo removeFromSuperview];
	viewTo.frame = rcFrom;
	[viewOn addSubview:viewTo];
	
	viewFrom.alpha = 1.0;
	viewTo.alpha = 0.0;
	
	NSTimeInterval uptimeStart = [VLTimer systemUptime];
	NSTimeInterval uptimeEnd = uptimeStart + animationDuration;
	
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL
	{
		NSTimeInterval uptime = [VLTimer systemUptime];
		if(uptime >= uptimeEnd) {
			return YES;
		}
		float ratio = (uptime - uptimeStart) / animationDuration;
		CGRect rcCur = rcFrom;
		rcCur.origin.x = rcFrom.origin.x + (rcTo.origin.x - rcFrom.origin.x) * ratio;
		rcCur.origin.y = rcFrom.origin.y + (rcTo.origin.y - rcFrom.origin.y) * ratio;
		rcCur.size.width = rcFrom.size.width + (rcTo.size.width - rcFrom.size.width) * ratio;
		rcCur.size.height = rcFrom.size.height + (rcTo.size.height - rcFrom.size.height) * ratio;
		viewFrom.frame = rcCur;
		viewTo.frame = rcCur;
		viewFrom.alpha = (1.0 - ratio);
		viewTo.alpha = ratio;
		return NO;
	}
	 ignoringTouches:YES completeBlock:^
	{
		[[viewFrom retain] autorelease];
		[viewFrom removeFromSuperview];
		[superviewFromOrig addSubview:viewFrom];
		viewFrom.frame = rcFromOrig;
		
		[[viewTo retain] autorelease];
		[viewTo removeFromSuperview];
		[superviewToOrig addSubview:viewTo];
		viewTo.frame = rcToOrig;
		
		viewFrom.alpha = alphaFromOrig;
		viewTo.alpha = alphaToOrig;
		
		completion();
	}];
	
	[UIView animateWithDuration:animationDuration
					 animations:^
	{
		animations();
	}
	 completion:^(BOOL finished)
	{
		if(finished) {
		}
	}];
}

- (void)startAnimateFromView:(UIView *)viewFrom
					  toView:(UIView *)viewTo
			   animationType:(EVLViewsTransitionAnimatorType)animationType
				  animations:(void (^)(void))animations
				  completion:(void (^)())completion {
	if(animationType == EVLViewsTransitionAnimatorTypeFrame) {
		[self startAnimateUsingMovingFromView:viewFrom toView:viewTo animations:animations completion:completion];
	} else if(animationType == EVLViewsTransitionAnimatorTypeIncrementalFrame) {
		[self startAnimateUsingIncrementalMovingFromView:viewFrom toView:viewTo animations:animations completion:completion];
	} else {
		[self startAnimateUsingImageFromView:viewFrom toView:viewTo animations:animations completion:completion];
	}
}

- (void)startAnimateFromViews:(NSArray *)viewsFrom
					  toViews:(NSArray *)viewsTo
			   animationTypes:(NSArray *)animationTypes
				   animations:(void (^)(void))animations
				   completion:(void (^)())completion {
	
	int viewsCount = (int)MIN(MIN(viewsFrom.count, viewsTo.count), animationTypes.count);
	if(!viewsCount) {
		animations();
		completion();
		return;
	}
	NSMutableArray *resultsAnimation = [NSMutableArray array];
	NSMutableArray *resultsCompletion = [NSMutableArray array];
	
	for(int i = 0; i < viewsCount; i++) {
		UIView *viewFrom = ObjectCast([viewsFrom objectAtIndex:i], UIView);
		UIView *viewTo = ObjectCast([viewsTo objectAtIndex:i], UIView);
		EVLViewsTransitionAnimatorType animationType = (EVLViewsTransitionAnimatorType)[[animationTypes objectAtIndex:i] intValue];
		
		[self startAnimateFromView:viewFrom
							toView:viewTo
					 animationType:animationType
		 animations:^
		{
			[resultsAnimation addObject:[NSNull null]];
			if(resultsAnimation.count == viewsCount) {
				animations();
			}
		}
		 completion:^
		{
			[resultsCompletion addObject:[NSNull null]];
			if(resultsCompletion.count == viewsCount) {
				completion();
			}
		}];
	}
}

/*- (void)startAnimateFromView:(UIView *)viewFrom toView:(UIView *)viewTo animations:(void (^)(void))animations completion:(void (^)())completion {
	
	UIView *viewOn = nil;
	NSMutableArray *arrSuperviewsFrom = [NSMutableArray array];
	UIView *superview = viewFrom ? viewFrom.superview : nil;
	while(superview) {
		[arrSuperviewsFrom addObject:superview];
		superview = superview.superview;
	}
	NSMutableArray *arrSuperviewsTo = [NSMutableArray array];
	superview = viewTo ? viewTo.superview : nil;
	while(superview) {
		[arrSuperviewsTo addObject:superview];
		superview = superview.superview;
	}
	for(UIView *superviewFrom in arrSuperviewsFrom) {
		for(UIView *superviewTo in arrSuperviewsTo) {
			if(superviewFrom == superviewTo) {
				viewOn = superviewFrom;
				break;
			}
		}
		if(viewOn)
			break;
	}
	NSTimeInterval animationDuration = 0.35 * 10;
	if(!viewOn) {
		[UIView animateWithDuration:animationDuration animations:^{
			animations();
		} completion:^(BOOL finished) {
			if(finished) {
				completion();
			}
		}];
		return;
	}
	
	CGRect rcFromOrig = viewFrom.frame;
	CGRect rcToOrig = viewTo.frame;
	UIView *superviewFromOrig = viewFrom.superview;
	UIView *superviewToOrig = viewTo.superview;
	CGAffineTransform transformFromOrig = viewFrom.transform;
	CGAffineTransform transformToOrig = viewTo.transform;
	float alphaFromOrig = viewFrom.alpha;
	float alphaToOrig = viewTo.alpha;
	
	CGAffineTransform transformFromNew = CGAffineTransformScale(transformFromOrig,
																rcToOrig.size.width / rcFromOrig.size.width,
																rcToOrig.size.height / rcFromOrig.size.height);
	//transformFromNew = CGAffineTransformMakeScale(rcToOrig.size.width / rcFromOrig.size.width,
	//											  rcToOrig.size.height / rcFromOrig.size.height);
	CGAffineTransform transformToNew = CGAffineTransformScale(transformToOrig,
																rcFromOrig.size.width / rcToOrig.size.width,
																rcFromOrig.size.height / rcToOrig.size.height);
	
	CGRect rcFromNew = [viewOn convertRect:rcToOrig fromView:superviewToOrig];
	rcFromNew.size.width = rcFromOrig.size.width;
	rcFromNew.size.height = rcFromOrig.size.height;
	CGRect rcToNew = [viewOn convertRect:rcFromOrig fromView:superviewFromOrig];
	rcToNew.size.width = rcToOrig.size.width;
	rcToNew.size.height = rcToOrig.size.height;
	
	[[viewFrom retain] autorelease];
	[viewFrom removeFromSuperview];
	[viewOn addSubview:viewFrom];
	CGRect rect = [viewOn convertRect:rcFromOrig fromView:superviewFromOrig];
	viewFrom.frame = rect;
	[[viewTo retain] autorelease];
	[viewTo removeFromSuperview];
	[viewOn addSubview:viewTo];
	
	viewTo.alpha = 0.0;
	viewTo.transform = transformToNew;
	viewTo.frame = rcToNew;
	
	viewTo.hidden = YES;
	//viewFrom.transform = transformFromNew;
	//viewFrom.frame = rcFromNew;
	//return;
	
	[UIView animateWithDuration:animationDuration animations:^
	{
		viewFrom.transform = transformFromNew;
		viewFrom.frame = rcFromNew;
		viewFrom.alpha = 0.0;
		viewTo.alpha = alphaToOrig;
		viewTo.transform = transformToOrig;
		CGRect rect = [viewOn convertRect:rcToOrig fromView:superviewToOrig];
		viewTo.frame = rect;
		
		animations();
	}
	 completion:^(BOOL finished)
	{
		if(finished) {
			viewFrom.transform = transformFromOrig;
			viewFrom.frame = rcFromOrig;
			viewTo.transform = transformToOrig;
			viewTo.frame = rcToOrig;
			[[viewFrom retain] autorelease];
			[viewFrom removeFromSuperview];
			[superviewFromOrig addSubview:viewFrom];
			[[viewTo retain] autorelease];
			[viewTo removeFromSuperview];
			[superviewToOrig addSubview:viewTo];
			viewFrom.alpha = alphaFromOrig;
			viewTo.alpha = alphaToOrig;
			
			viewTo.hidden = NO;
			
			completion();
		}
	}];
	
}*/

- (void)dealloc {
	[super dealloc];
}

@end

