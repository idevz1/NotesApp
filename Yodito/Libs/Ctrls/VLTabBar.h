
#import <Foundation/Foundation.h>
#import "VLBaseView.h"

@interface VLTabBarItem : VLBaseView
{
@private
	NSString *_title;
	UIImage *_image;
}

@property(nonatomic, assign) NSString *title;
@property(nonatomic, assign) UIImage *image;
@property(nonatomic, assign) BOOL isSelected;

@end


@interface VLTabBar : VLBaseView
{
@private
	NSMutableArray *_items;
	VLTabBarItem *_selectedItem;
	VLMessenger *_msgrSelectedItemChanged;
}

@property(nonatomic, assign) VLTabBarItem *selectedItem;
@property(nonatomic, assign) int selectedItemIndex;
@property(nonatomic, readonly) VLMessenger *msgrSelectedItemChanged;

- (VLTabBarItem*)addItem:(VLTabBarItem*)item;

@end
