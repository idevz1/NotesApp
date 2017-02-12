
#import <UIKit/UIKit.h>
#import "VLAlertView.h"

@interface VLTextFieldAlertView : VLAlertView <UITextFieldDelegate>
{
	UITextField *_textField;
}

@property(nonatomic, readonly) UITextField *textField;

@end

