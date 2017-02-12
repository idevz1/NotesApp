
#import <Foundation/Foundation.h>
#import "VLBaseView.h"
#import "VLTimer.h"

@class VLKeyboardScrollView_ZoomingView;
@class VLKeyboardScrollView_ContainerView;

@protocol VLKeyboardScrollView_ContainerViewDelegate <NSObject>

- (void)VLKeyboardScrollView_ContainerView_layoutSubviews:(VLKeyboardScrollView_ContainerView*)view;

@optional

- (UIView *)VLKeyboardScrollView_ContainerView_getFirstResponder:(VLKeyboardScrollView_ContainerView*)view;

@end

@interface VLKeyboardScrollView_ContainerView : VLBaseView
{
	id<VLKeyboardScrollView_ContainerViewDelegate> _delegate;
}

@property(nonatomic, assign) id<VLKeyboardScrollView_ContainerViewDelegate> delegate;

@end


@interface VLKeyboardScrollView : VLBaseView <UIScrollViewDelegate>
{
@private
	UIScrollView *_scrollView;
	VLKeyboardScrollView_ZoomingView *_scrollZoomingView;
	BOOL _keyboardShown;
	CGRect _frameOfKeyboard;
	float _scrollableContentHeight;
	BOOL _isScrolled;
	VLTimer *_timer;
	UIView *_lastFirstResponder;
	BOOL _hideKeyboardOnBeginDragging;
	UIColor *_backColorForViewToFill;
	BOOL _scrollEnabled;
}

@property(nonatomic, readonly) VLBaseView *contentView;
@property(nonatomic, assign) UIView *viewToFill;
@property(nonatomic, assign) float scrollableContentHeight;
@property(nonatomic, assign) BOOL hideKeyboardOnBeginDragging;
@property(nonatomic, assign) BOOL scrollEnabled;

- (void)initializeScrollingFromNib:(BOOL)fromNib;
- (void)initializeScrolling;
- (void)setContentViewBackColor:(UIColor*)color;

- (void)scrollToBottom;

@end
