
#import "YTCheckBoxView.h"

@implementation YTCheckBoxView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
}

- (UIImage *)imageUnchecked {
	return [UIImage imageNamed:@"chk_box_unchecked.png"];
}

- (UIImage *)imageChecked {
	return [UIImage imageNamed:@"chk_box_checked.png"];
}

- (void)dealloc {
	[super dealloc];
}

@end
