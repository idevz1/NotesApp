
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@class YTTagsLineView;

@interface YTTagsLineView_TagView : YTBaseView {
@private
	VLLabel *_labelTitle;
	BOOL _isBlank;
	BOOL _isEditing;
	UITextField *_textField;
}

@property(nonatomic, assign) BOOL isEditing;
@property(nonatomic, readonly) UITextField *textField;
@property(nonatomic, assign) NSString *title;
@property(nonatomic, assign) NSString *editedTitle;

- (id)initWithFrame:(CGRect)frame isBlank:(BOOL)isBlank;

@end


@interface YTTagsLineView_ContentView : YTBaseView {
@private
}

@end


@protocol YTTagsLineViewDelegate <NSObject>
@optional
- (void)tagsLineView:(YTTagsLineView *)view tagRemoved:(YTTagInfo *)tag;
@end


@interface YTTagsLineView : YTBaseView <UIScrollViewDelegate, UITextFieldDelegate, VLPopupBubbleMenuViewDelegate> {
@private
	BOOL _allowEditing;
	UIScrollView *_scrollView;
	YTTagsLineView_ContentView *_contentView;
	UIButton *_buttonAdd;
	NSMutableArray *_tagsViews;
	YTTagsLineView_TagView *_blankTagView;
	BOOL _tagsListBuilt;
	VLPopupBubbleMenuView *_popupBubbleMenuView;
	YTTagsLineView_TagView *_editedTagView;
	YTTagsLineView_TagView *_popupTargetTagView;
	VLTimer *_timer;
	NSObject<YTTagsLineViewDelegate> *_delegate;
}

@property(nonatomic, assign) BOOL allowEditing;
@property(nonatomic, readonly) UIButton *buttonAdd;
@property(nonatomic, readonly) BOOL popupMenuShown;
@property(nonatomic, assign) NSObject<YTTagsLineViewDelegate> *delegate;

- (void)startEditNewTag;
- (void)stopEditingTag;

@end

