
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

typedef enum
{
	EVLViewsTransitionAnimatorTypeImage,
	EVLViewsTransitionAnimatorTypeFrame,
	EVLViewsTransitionAnimatorTypeIncrementalFrame
}
EVLViewsTransitionAnimatorType;


@interface VLViewsTransitionAnimator : NSObject {
@private
	double _animationDuration;
}

@property(nonatomic, assign) double animationDuration;

- (void)startAnimateFromView:(UIView *)viewFrom
					  toView:(UIView *)viewTo
			   animationType:(EVLViewsTransitionAnimatorType)animationType
				  animations:(void (^)(void))animations
				  completion:(void (^)())completion;

- (void)startAnimateFromViews:(NSArray *)viewsFrom
					  toViews:(NSArray *)viewsTo
			   animationTypes:(NSArray *)animationTypes
				   animations:(void (^)(void))animations
				   completion:(void (^)())completion;

@end

