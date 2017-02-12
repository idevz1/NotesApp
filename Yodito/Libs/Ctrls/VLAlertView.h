
#import <Foundation/Foundation.h>

typedef void (^VLAlertView_ClickResultBlock)(int btnIndex, NSString *btnTitle);

@interface VLAlertView : UIAlertView <UIAlertViewDelegate>
{
	VLAlertView_ClickResultBlock _resultBlock;
}

+ (void)showWithOkAndTitle:(NSString*)title message:(NSString*)message resultBlock:(void (^)())resultBlock;
+ (void)showWithOkAndTitle:(NSString*)title message:(NSString*)message;
+ (void)showWithYesNoTitle:(NSString*)title message:(NSString*)message resultBlock:(void (^)(BOOL yesTapped))resultBlock;
- (void)showWithResultBlock:(VLAlertView_ClickResultBlock)resultBlock;
- (void)showOrSkip:(BOOL)skip withResultBlock:(VLAlertView_ClickResultBlock)resultBlock;

@end
