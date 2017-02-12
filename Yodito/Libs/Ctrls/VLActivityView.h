
#import <Foundation/Foundation.h>
#import "VLBaseView.h"
#import "VLMessaging.h"
#import "VLProgressHUD.h"

@interface VLActivityView : VLBaseView
{
	VLProgressHUD *_progressHUD;
	UIProgressView *_progressView;
	UIButton *_bnCancel;
	VLMessenger *_msgrCanceled;
	BOOL _transparentForTouches;
}

@property(nonatomic, assign) NSString *title;
@property(nonatomic, readonly) VLMessenger *msgrCanceled;
@property(nonatomic, assign) BOOL transparentForTouches;
@property(nonatomic, assign) float yOffset;
@property(nonatomic, assign) UIColor *color;
@property(assign) BOOL dimBackground;
@property(assign) VLProgressHUDMode progressMode;
@property(assign) float progress;

+ (void)setDefaultBackgroundcolor:(UIColor *)color;
+ (void)setDefaultCenterBackcolor:(UIColor *)color;
+ (void)setDefaultDimBackground:(BOOL)dimBackground;

- (void)startActivity;
- (void)stopActivity;

- (void)progressShow:(float)value;
- (void)progressHide;

- (void)showCancelButton;

@end
