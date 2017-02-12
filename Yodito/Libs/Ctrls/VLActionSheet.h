
#import <Foundation/Foundation.h>

typedef void (^VLActionSheet_ClickResultBlock)(int btnIndex, NSString *btnTitle);

@interface VLActionSheet : UIActionSheet <UIActionSheetDelegate>
{
@private
	int _result;
	VLActionSheet_ClickResultBlock _resultBlock;
	int _autoTapButtonIndex;
}

@property(nonatomic,readonly) int result;
@property(nonatomic,assign) int autoTapButtonIndex;

- (void)showAsyncFromView:(UIView*)view resultBlock:(VLActionSheet_ClickResultBlock)resultBlock;
- (void)showAsyncFromRect:(CGRect)rect
				   inView:(UIView *)view
			  orBarButton:(UIBarButtonItem*)barButton
			  resultBlock:(VLActionSheet_ClickResultBlock)resultBlock;

@end
