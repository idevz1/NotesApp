
#import "YTActionSheet.h"

static int _showsCounter;

@implementation YTActionSheet

- (void)showAsyncFromView:(UIView*)view resultBlock:(VLActionSheet_ClickResultBlock)resultBlock {
	
	_showsCounter++;
	[super showAsyncFromView:view resultBlock:^(int btnIndex, NSString *btnTitle) {
		_showsCounter--;
		resultBlock(btnIndex, btnTitle);
	}];
}

- (void)showAsyncFromRect:(CGRect)rect
				   inView:(UIView *)view
			  orBarButton:(UIBarButtonItem*)barButton
			  resultBlock:(VLActionSheet_ClickResultBlock)resultBlock {
	
	_showsCounter++;
	[super showAsyncFromRect:rect inView:view orBarButton:barButton resultBlock:^(int btnIndex, NSString *btnTitle) {
		_showsCounter--;
		resultBlock(btnIndex, btnTitle);
	}];
}

+ (BOOL)isShown {
	return (_showsCounter > 0);
}

@end

