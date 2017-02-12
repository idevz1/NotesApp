
#import <UIKit/UIKit.h>
#import "VLBaseView.h"

@class VLTimer;

@interface VLTouchSplashView : VLBaseView
{
@private
	VLTimer *_timer;
}

+ (void)showInView:(UIView*)view point:(CGPoint)point;
+ (void)hide;

@end
