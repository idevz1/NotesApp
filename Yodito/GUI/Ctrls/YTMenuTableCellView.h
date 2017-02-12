
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTMenuTableCellView;

@protocol YTMenuTableCellViewDelegate <NSObject>
@optional
- (void)menuTableCellView:(YTMenuTableCellView *)view iconTapped:(id)param;
@end

@interface YTMenuTableCellView : YTBaseView {
@private
	UIEdgeInsets _contentInsets;
	UIImageView *_imageIcon;
	VLLabel *_labelTitle;
	VLLabel *_labelTitleRight;
	UIView *_separatorBottom;
	BOOL _enableIconTouches;
	BOOL _iconTouchBegan;
	NSObject<YTMenuTableCellViewDelegate> *_delegate;
}

@property(nonatomic, assign) UIEdgeInsets contentInsets;
@property(nonatomic, assign) NSString *title;
@property(nonatomic, assign) UIImage *icon;
@property(nonatomic, readonly) VLLabel *labelTitle;
@property(nonatomic, assign) NSString *titleRight;
@property(nonatomic, readonly) VLLabel *labelTitleRight;
@property(nonatomic, assign) BOOL enableIconTouches;
@property(nonatomic, assign) BOOL separatorBottomHidden;
@property(nonatomic, assign) NSObject<YTMenuTableCellViewDelegate> *delegate;

@end

