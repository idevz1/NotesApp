
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

@class VLPopupBubbleMenuViewItem;
@class VLPopupBubbleMenuView_PopupView;
@class VLPopupBubbleMenuView;

@protocol VLPopupBubbleMenuViewDelegate <NSObject>
@optional
- (void)popupBubbleMenuView:(VLPopupBubbleMenuView *)popupBubbleMenuView touchedOutside:(id)param;
- (void)popupBubbleMenuView:(VLPopupBubbleMenuView *)popupBubbleMenuView itemTapped:(VLPopupBubbleMenuViewItem *)item;
@end

@interface VLPopupBubbleMenuView : VLBaseView {
@private
	NSMutableArray *_items;
	VLPopupBubbleMenuView_PopupView *_popupView;
	UIView *_fromViewRef;
	UIFont *_textFont;
	UIColor *_backColor;
	UIColor *_textColor;
	float _cornerRadius;
	float _arrowSize;
	UIEdgeInsets _padding;
	float _itemSpaceX;
	float _separatorWidth;
	UIColor *_separatorColor;
	int _visibleItemsCount;
	CGRect _lastPopupRect;
	CGPoint _lastPopupPoint;
	CGMutablePathRef _popupPath;
	NSObject<VLPopupBubbleMenuViewDelegate> *_delegate;
	int _itemIndexBeganTouched;
}

@property(nonatomic, assign) NSObject<VLPopupBubbleMenuViewDelegate> *delegate;
@property(nonatomic, readonly) NSArray *items;

- (void)setTextFont:(UIFont *)textFont textColor:(UIColor *)textColor backColor:(UIColor *)backColor
	   cornerRadius:(float)cornerRadius padding:(UIEdgeInsets)padding itemSpaceX:(float)itemSpaceX arrowSize:(float)arrowSize;
- (VLPopupBubbleMenuViewItem *)addItemWithTitle:(NSString *)title objectTag:(NSObject *)objectTag;
- (void)removeItemAtIndex:(int)index;
- (void)showInParentView:(UIView *)parentView fromView:(UIView *)fromView;
- (void)hide;

@end


@interface VLPopupBubbleMenuViewItem : NSObject {
@private
	NSString *_title;
	NSObject *_objectTag;
}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSObject *objectTag;

@end

