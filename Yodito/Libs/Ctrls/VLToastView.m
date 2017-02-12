
#import "VLToastView.h"
#import "../Logic/Classes.h"
#import "VLCtrlsUtils.h"

@implementation VLToastView

- (id)init
{
	self = [super init];
	if(self)
	{
		_text = [@"" retain];
		_duration = 2.0;
	}
	return self;
}

- (void)setText:(NSString *)text
{
	if(!text)
		text = @"";
	[_text release];
	_text = [text copy];
}

- (void)show
{
	VLProgressHUD *hud = [VLProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.transparentForTouches = YES;
	[self retain];
	[hud setCompletionBlock:^()
	{
		[self autorelease];
	}];
	hud.mode = VLProgressHUDModeText;
	hud.labelText = _text;
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:_duration];
}

- (void)showAfterDelay:(NSTimeInterval)delay
{
	[[VLMessageCenter shared] performBlock:^{
		[self show];
	} afterDelay:delay ignoringTouches:NO];
}

- (void)showAfterDelay:(NSTimeInterval)delay duration:(NSTimeInterval)duration
{
	_duration = duration;
	[self showAfterDelay:delay];
}

+ (VLToastView *)makeText:(NSString *)text
{
	VLToastView *toast = [[[VLToastView alloc] init] autorelease];
	[toast setText:text];
	return toast;
}

+ (BOOL)isAnyToastVisible {
	VLProgressHUD *view = (VLProgressHUD *)[VLCtrlsUtils getSubViewOfClass:[VLProgressHUD class] parentView:[UIApplication sharedApplication].keyWindow];
	return (view != nil);
}

- (void)dealloc
{
	[_text release];
	[super dealloc];
}

@end




