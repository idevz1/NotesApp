
#import <Foundation/Foundation.h>

@interface VLViewLocalizator : NSObject
{	
}

+ (void)localizeView:(UIView*)view andSubViews:(BOOL)andSubViews;
+ (void)localizeViewController:(UIViewController*)vc andSubViews:(BOOL)andSubViews;

@end
