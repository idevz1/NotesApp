
#import <Foundation/Foundation.h>

@class VLMagnifier_View;

@interface VLMagnifier : NSObject
{
@private
	VLMagnifier_View *_view;
}

+ (VLMagnifier*)shared;

- (void)startShowWithPoint:(CGPoint)pt inView:(UIView*)view;
- (void)continueShowWithPoint:(CGPoint)pt inView:(UIView*)view;
- (void)stopShow;
- (void)refreshMagnifiedImage;

@end
