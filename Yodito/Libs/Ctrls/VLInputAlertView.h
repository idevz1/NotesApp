
#import <UIKit/UIKit.h>

typedef enum 
{
	VLInputAlertViewButtonLayoutNormal,
	VLInputAlertViewButtonLayoutStacked
	
} VLInputAlertViewButtonLayout;

typedef enum
{
	VLInputAlertViewStyleNormal,
	VLInputAlertViewStyleInput,
	
} VLInputAlertViewStyle;

@class VLInputAlertViewController;
@class VLInputAlertView;
@class VLInputAlertOverlayWindow;

@protocol VLInputAlertViewDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(VLInputAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(VLInputAlertView *)alertView;

- (void)willPresentAlertView:(VLInputAlertView *)alertView;  // before animation and showing view
- (void)didPresentAlertView:(VLInputAlertView *)alertView;  // after animation

- (void)alertView:(VLInputAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(VLInputAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end

typedef void (^VLInputAlertView_ClickResultBlock)(int btnIndex, NSString *btnTitle);

@interface VLInputAlertView : UIView <VLInputAlertViewDelegate, UITextFieldDelegate>
{
	UIImage*				_backgroundImage;
	UILabel*				_titleLabel;
	UILabel*				_messageLabel;
	UITextView*				_messageTextView;
	UIImageView*			_messageTextViewMaskImageView;
	NSMutableArray*			_inputTitleLabels; // Array of UILabel
	NSMutableArray*			_inputTextFields; // Array of UITextField
	NSMutableArray*			_buttons;
	VLInputAlertView_ClickResultBlock _resultBlock;
	VLInputAlertOverlayWindow* _ow;
}
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, assign) id<VLInputAlertViewDelegate> delegate;
@property(nonatomic) NSInteger cancelButtonIndex;
@property(nonatomic) NSInteger returnKeyDoneTargetButtonIndex;
@property(nonatomic, readonly) NSInteger firstOtherButtonIndex;
@property(nonatomic, readonly) NSInteger numberOfButtons;
@property(nonatomic, readonly, getter=isVisible) BOOL visible;

@property(nonatomic, assign) VLInputAlertViewButtonLayout buttonLayout;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat maxHeight;
@property(nonatomic, assign) BOOL usesMessageTextView;
@property(nonatomic, retain) UIImage* backgroundImage;
@property(nonatomic, assign) VLInputAlertViewStyle style;
@property(nonatomic, readonly) NSArray* inputTextFields;
@property(nonatomic, readonly) UITextField* inputTextField;
@property(nonatomic, readonly) UITextField* lastInputTextField;
@property(nonatomic) BOOL focusFirstNonEmptyTextField;
@property(nonatomic) int inputTextFieldIndexToFocus;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (NSInteger)addButtonWithTitle:(NSString *)title;
- (UITextField *)addInputTextFieldWithTitle:(NSString*)title;
- (UITextField *)addInputTextFieldWithPlaceholder:(NSString*)placeholder;
- (void)chainInputTextFields;
- (UITextField *)inputTextFieldAtIndex:(int)index;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
- (void)show;
- (void)showWithResultBlock:(VLInputAlertView_ClickResultBlock)resultBlock;

@end




