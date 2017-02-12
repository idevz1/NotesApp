
#import "VLTextFieldAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "VLCtrlsUtils.h"

#define kTextFieldHeight 28
#define kEdgeInsets UIEdgeInsetsMake(12, 12, 68, 12)

@implementation VLTextFieldAlertView

@synthesize textField = _textField;

- (id)init
{
	self = [super init];
	if(self)
	{
		_textField = [[UITextField alloc] initWithFrame:CGRectZero];
		_textField.borderStyle = UITextBorderStyleRoundedRect;
		_textField.returnKeyType = UIReturnKeyDone;
		_textField.delegate = self;
		[self addSubview:_textField];
		[_textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.35];
		
		self.message = @"                                                                                                                                                                   ";
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect rcBnds = self.bounds;
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, kEdgeInsets);
	CGRect rcField = rcCtrls;
	rcField.size.height = kTextFieldHeight;
	rcField.origin.y = CGRectGetMaxY(rcCtrls) - rcField.size.height;
	_textField.frame = rcField;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return [super sizeThatFits:size];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

- (void)dealloc
{
	[_textField release];
	[super dealloc];
}

@end


