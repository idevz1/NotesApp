
#import <UIKit/UIKit.h>
#import "VLProgressHUD.h"

@interface VLToastView : NSObject
{
@private
	NSString *_text;
	NSTimeInterval _duration;
}

- (void)setText:(NSString *)text;
- (void)show;
- (void)showAfterDelay:(NSTimeInterval)delay;
- (void)showAfterDelay:(NSTimeInterval)delay duration:(NSTimeInterval)duration;
+ (VLToastView *)makeText:(NSString *)text;
+ (BOOL)isAnyToastVisible;

@end





