
#import <Foundation/Foundation.h>
#import "VLNavigationController.h"

@interface VLPopupViewController : VLNavigationController
{
	
}

- (id)initWithChildViewController:(UIViewController*)childViewController;

+ (void)showWithChildViewController:(UIViewController*)childViewController;

@end
