
#import "VLPopupViewController.h"
#import "VLAppDelegateBase.h"

@implementation VLPopupViewController

- (id)initWithChildViewController:(UIViewController*)childViewController
{
	self = [super init];
	if(self)
	{
		[self pushViewController:childViewController animated:NO];
		UIBarButtonItem *bbiClose = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
							target:self action:@selector(onBnCancelTap:)] autorelease];
		childViewController.navigationItem.leftBarButtonItem = bbiClose;
	}
	return self;
}

- (void)onBnCancelTap:(id)sender
{
	[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:self animated:YES];
}

+ (void)showWithChildViewController:(UIViewController*)childViewController
{
	VLPopupViewController *vcPopup = [[[VLPopupViewController alloc] initWithChildViewController:childViewController] autorelease];
	[[[VLAppDelegateBase sharedAppDelegateBase] topModalViewController] presentViewController:vcPopup animated:YES completion:^{
	}];
}

@end
