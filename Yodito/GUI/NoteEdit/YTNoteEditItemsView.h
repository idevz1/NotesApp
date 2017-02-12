
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTNoteEditItemsView;
@class YTNoteEditItemsView_Button;


typedef enum
{
	EYTNoteEditButtonTypeNone = 0,
	EYTNoteEditButtonTypeBook,
	EYTNoteEditButtonTypeLocation,
	EYTNoteEditButtonTypeCamera,
	EYTNoteEditButtonTypeMic,
	EYTNoteEditButtonTypeAttachment,
	EYTNoteEditButtonTypeCalendar,
	EYTNoteEditButtonTypeReminder,
	EYTNoteEditButtonTypeTag,
	EYTNoteEditButtonTypeStarred
}
EYTNoteEditButtonType;


@protocol YTNoteEditItemsViewDelegate <NSObject>
@optional
- (void)noteEditItemsView:(YTNoteEditItemsView *)view buttonTapped:(YTNoteEditItemsView_Button *)button withType:(EYTNoteEditButtonType)buttonType;
@end


@protocol YTNoteEditItemsView_ButtonDelegate <NSObject>
@optional
- (void)noteEditItemsView_Button:(YTNoteEditItemsView_Button *)button tappedWithType:(EYTNoteEditButtonType)buttonType;
@end


@interface YTNoteEditItemsView_Button : YTBaseView {
@private
	EYTNoteEditButtonType _type;
	UIButton *_buttonIcon;
	UIImage *_icon;
	UIImage *_iconGrayed;
	NSObject<YTNoteEditItemsView_ButtonDelegate> *_delegate;
	BOOL _touched;
	BOOL _grayed;
	VLLabel *_labelBadge;
}

@property(nonatomic, assign) EYTNoteEditButtonType type;
@property(nonatomic, assign) UIImage *icon;
@property(nonatomic, assign) UIImage *iconGrayed;
@property(nonatomic, assign) NSObject<YTNoteEditItemsView_ButtonDelegate> *delegate;
@property(nonatomic, assign) BOOL grayed;
@property(nonatomic, assign) NSString *badgeText;

- (void)enableButtonWithType:(EYTNoteEditButtonType)type enable:(BOOL)enable;

@end





@interface YTNoteEditItemsView : YTBaseView <YTNoteEditItemsView_ButtonDelegate> {
@private
	NSMutableArray *_allButtons;
	NSMutableArray *_visibleButtons;
	YTNoteEditItemsView_Button *_buttonTag;
	YTNoteEditItemsView_Button *_buttonLocation;
	YTNoteEditItemsView_Button *_buttonCamera;
	YTNoteEditItemsView_Button *_buttonStar;
	YTNoteEditItemsView_Button *_buttonBook;
	NSObject<YTNoteEditItemsViewDelegate> *_delegate;
}

@property(nonatomic, assign) NSObject<YTNoteEditItemsViewDelegate> *delegate;
@property(nonatomic, readonly) YTNoteEditItemsView_Button *buttonTag;
@property(nonatomic, readonly) YTNoteEditItemsView_Button *buttonLocation;
@property(nonatomic, readonly) YTNoteEditItemsView_Button *buttonCamera;
@property(nonatomic, readonly) YTNoteEditItemsView_Button *buttonStar;
@property(nonatomic, readonly) YTNoteEditItemsView_Button *buttonBook;

- (void)showButtonWithType:(EYTNoteEditButtonType)type show:(BOOL)show;
- (void)enableButtonWithType:(EYTNoteEditButtonType)type enable:(BOOL)enable;

@end

