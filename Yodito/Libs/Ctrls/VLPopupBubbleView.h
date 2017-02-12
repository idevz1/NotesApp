
#import <Foundation/Foundation.h>
#import "VLBaseView.h"
#import "VLLabel.h"

@interface VLPopupBubbleView : VLBaseView {
@private
	VLLabel *_lbTitle;
	float _arrowPosRel;
}

@property(nonatomic, assign) NSString *title;

- (CGSize)sizeThatFits:(CGSize)size;
- (void)showInView:(UIView*)superview point:(CGPoint)point animated:(BOOL)animated;
- (void)hideFromSuperviewAnimated:(BOOL)animated;

@end
