
#import <Foundation/Foundation.h>

@interface VLCtrlsUtils : NSObject
{
	
}

+ (BOOL)viewController:(UIViewController*)parVC containsChild:(UIViewController*)childVC;

+ (UIView*)findFirstResponder:(UIView*)parentView;
+ (void)findAndResignFirstResponder:(UIView*)parentView;
+ (NSArray*)getSubViewsOfClass:(Class)cl parentView:(UIView*)parView;
+ (UIView*)getSubViewOfClass:(Class)cl parentView:(UIView*)parView;
+ (UIView*)getParentViewOfClass:(Class)cl ofView:(UIView*)view;
+ (void)setBackgroundColorOfTableToView:(UIView*)view;
+ (BOOL)isView:(UIView *)view containsView:(UIView *)childView;

@end





