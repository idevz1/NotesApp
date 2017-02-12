
#import "VLCtrlsUtils.h"
#import "../Common/Classes.h"
#import "../Drawing/Classes.h"

@implementation VLCtrlsUtils

+ (BOOL)viewController:(UIViewController*)parVC containsChild:(UIViewController*)childVC
{
	UINavigationController *navVC = ObjectCast(parVC, UINavigationController);
	UITabBarController *tabVC = ObjectCast(parVC, UITabBarController);
	NSArray *vcs = nil;
	if(navVC)
		vcs = navVC.viewControllers;
	else if(tabVC)
		vcs = tabVC.viewControllers;
	else
		vcs = [NSArray array];
	for(UIViewController *vc in vcs)
		if(vc == childVC || [VLCtrlsUtils viewController:vc containsChild:childVC])
			return YES;
	return NO;
}

+ (UIView*)findFirstResponder:(UIView*)parentView
{
	if(!parentView)
		return nil;
	if([parentView isFirstResponder])
		return parentView;
	for(UIView *view in [parentView subviews])
	{
		UIView *v = [VLCtrlsUtils findFirstResponder:view];
		if(v)
			return v;
	}
	return nil;
}

+ (void)findAndResignFirstResponder:(UIView*)parentView
{
	UIView *view = [self findFirstResponder:parentView];
	if(view)
		[view resignFirstResponder];
}

+ (void)getSubViewsOfClass:(Class)cl parentView:(UIView*)parView result:(NSMutableArray*)result
{
	if(!parView)
		return;
	if([parView isKindOfClass:cl] && ![result containsObject:parView])
		[result addObject:parView];
	for(UIView *view in [parView subviews])
		[VLCtrlsUtils getSubViewsOfClass:cl parentView:view result:result];
}
+ (NSArray*)getSubViewsOfClass:(Class)cl parentView:(UIView*)parView
{
	NSMutableArray *result = [NSMutableArray array];
	[VLCtrlsUtils getSubViewsOfClass:cl parentView:parView result:result];
	return result;
}

+ (UIView*)getSubViewOfClass:(Class)cl parentView:(UIView*)parView
{
	if(!parView)
		return nil;
	if([parView isKindOfClass:cl])
		return parView;
	for(UIView *view in [parView subviews])
	{
		UIView *res = [VLCtrlsUtils getSubViewOfClass:cl parentView:view];
		if(res)
			return res;
	}
	return nil;
}

+ (UIView*)getParentViewOfClass:(Class)cl ofView:(UIView*)view
{
	if(!view)
		return nil;
	if([view isKindOfClass:cl])
		return view;
	view = [view superview];
	return [VLCtrlsUtils getParentViewOfClass:cl ofView:view];
}

+ (void)setBackgroundColorOfTableToView:(UIView*)view
{
	static UIImage *image = nil;
	if(!image)
	{
		NSData *data = [NSData dataWithBase64String:@"Qk12BQAAAAAAADYAAAAoAAAANwAAAAgAAAABABgAAAAAAEAFAAAAAAAAAAAAAAAAAAAAAAAA4NvV4NvV3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3tjS4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3dfR4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NvV3tjS3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NrU39nT3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ39rU39rU3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQAAAA4NvV4NvV3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3tjS4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3dfR4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NvV3tjS3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NrU39nT3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ39rU39rU3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQAAAA4NvV4NvV3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3tjS4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3dfR4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NvV3tjS3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NrU39nT3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ39rU39rU3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQAAAA4NvV4NvV3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3tjS4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3dfR4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NvV3tjS3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NrU39nT3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ39rU39rU3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQAAAA4NvV4NvV3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3tjS4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3dfR4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NvV3tjS3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NrU39nT3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ39rU39rU3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQAAAA4NvV4NvV3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3tjS4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3dfR4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NvV3tjS3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NrU39nT3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ39rU39rU3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQAAAA4NvV4NvV3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3tjS4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3dfR4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NvV3tjS3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NrU39nT3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ39rU39rU3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQAAAA4NvV4NvV3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3tjS4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3dfR4NvV3dfR3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NvV3tjS3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ4NrU39nT3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ39rU39rU3NbQ3NbQ3NbQ3NbQ3NbQ3NbQ3NbQAAAA"];
		image = [UIImage imageWithData:data];
		if(image)
			[image retain];
	}
	if(image)
	{
		UIColor *color = [UIColor colorWithPatternImage:image];
		view.backgroundColor = color;
	}
}

+ (BOOL)isView:(UIView *)view containsView:(UIView *)childView
{
	if(!view || !childView)
		return NO;
	for(UIView *subView in [view subviews])
		if(subView == childView || [VLCtrlsUtils isView:subView containsView:childView])
			return YES;
	return NO;
}

@end





