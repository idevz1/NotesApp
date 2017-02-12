
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

@interface YTActionSheet : VLActionSheet {
@private
}

- (void)showAsyncFromView:(UIView*)view resultBlock:(VLActionSheet_ClickResultBlock)resultBlock;
- (void)showAsyncFromRect:(CGRect)rect
				   inView:(UIView *)view
			  orBarButton:(UIBarButtonItem*)barButton
			  resultBlock:(VLActionSheet_ClickResultBlock)resultBlock;

+ (BOOL)isShown;

@end

