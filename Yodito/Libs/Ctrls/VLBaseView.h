
#import <UIKit/UIKit.h>
#import "VLMessaging.h"

@class VLBaseDrawableView;
@class VLNavigationView;

@interface VLBaseView : UIView
{
@private
	BOOL _initialized;
	VLMessenger *_msgrUpdateView;
}

@property(nonatomic, readonly) UIViewController *viewController;

- (void)initialize;

- (void)updateViewAsync;
- (void)updateViewNow;
- (void)onUpdateView;
- (void)viewDidLoad;
- (void)onBecomeTopAgainInNavigation;
- (UINavigationItem *)navigationItem;
- (void)onNavigationItemAttached;
- (VLNavigationView *)navigationView;

@end



@protocol VLBaseDrawableView_drawDelegate <NSObject>
@required
- (void)VLBaseDrawableView:(VLBaseDrawableView*)view drawRect:(CGRect)rect;

@end


@interface VLBaseDrawableView : VLBaseView
{
@private
	id<VLBaseDrawableView_drawDelegate> _drawDelegate;
}

@property(nonatomic,assign) id<VLBaseDrawableView_drawDelegate> drawDelegate;

@end
