
#import <Foundation/Foundation.h>
#import "VLBaseView.h"

@class VLNavigationView_SubViewInfo;

@interface VLNavigationView : VLBaseView <UINavigationBarDelegate> {
@private
	NSMutableArray *_arrNavInfo;
	UINavigationBar *_navBar;
	VLNavigationView_SubViewInfo *_pushingInfo;
	BOOL _allowPopNavItemByDelegate;
	
	NSMutableArray *_arrPopupViews;
	UIView *_presentingViewRef;
}

@property(nonatomic, readonly) UINavigationBar *navigationBar;
@property(nonatomic, readonly) NSArray *views;

- (void)pushView:(VLBaseView *)view animated:(BOOL)animated showNavigationBar:(BOOL)showNavigationBar;
- (void)pushView:(VLBaseView *)view animated:(BOOL)animated;
- (void)popView:(VLBaseView *)view animated:(BOOL)animated;
- (void)removePushedViewAtIndex:(int)index;
- (void)replacePushedViewAtIndex:(int)index withView:(VLBaseView *)view;
- (UINavigationItem *)navigationItemForView:(VLBaseView *)view;
- (void)setNavigationBarHidden:(BOOL)hidden aboveTopForView:(VLBaseView *)view animated:(BOOL)animated;

- (void)dismissPopupView:(VLBaseView *)view animated:(BOOL)animated;
- (void)presentPopupView:(VLBaseView *)view animated:(BOOL)animated;

@end
