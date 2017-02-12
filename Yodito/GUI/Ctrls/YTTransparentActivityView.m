
#import "YTTransparentActivityView.h"

@implementation YTTransparentActivityView

- (void)initialize {
	[super initialize];
	self.alpha = 0.33;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return nil;
}

@end


