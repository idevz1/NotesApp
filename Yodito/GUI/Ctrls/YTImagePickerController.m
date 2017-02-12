
#import "YTImagePickerController.h"

static int _showsCounter;

@implementation YTImagePickerController

- (void)showWithSource:(UIImagePickerControllerSourceType)sourceType
		fromParentView:(UIView *)parentView
				  rect:(CGRect)rect
		   orBarButton:(UIBarButtonItem*)barButton
		   resultBlock:(VLImagePickerController_ResultBlock)resultBlock {
	
	_showsCounter++;
	
	[super showWithSource:sourceType
		   fromParentView:parentView
					 rect:rect
			  orBarButton:barButton
			  resultBlock:^(UIImage *image)
	{
		_showsCounter--;
		if(kIosVersionFloat >= 7.0)
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
		resultBlock(image);
	}];
}

+ (BOOL)isShown {
	return (_showsCounter > 0);
}

@end

