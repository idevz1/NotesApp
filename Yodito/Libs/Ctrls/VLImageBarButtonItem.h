
#import <UIKit/UIKit.h>

@interface VLImageBarButtonItem : UIBarButtonItem
{
@private
	UIButton *_button;
	id _targetInt;
	SEL _actionInt;
	float _insetsRel;
}

@property(nonatomic, readonly) UIButton *button;
@property(nonatomic, assign) float insetsRel;

- (id)initWithImage:(UIImage*)image
			 imageH:(UIImage*)imageH
			  scale:(float)scale
			 target:(id)target
			 action:(SEL)action;

@end
