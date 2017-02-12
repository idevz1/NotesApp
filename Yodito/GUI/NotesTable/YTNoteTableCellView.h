
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNoteTableCellInfo.h"
#import "../Resources/Classes.h"
#import "YTNoteCellTextView.h"

@class YTNoteTableCellView_ThumbFrame;
@class YTNoteTableCellView_Separator;


@interface YTNoteTableCellViewManager : YTLogicObject {
@private
}

+ (YTNoteTableCellViewManager *)shared;
- (void)initialize;

@end



@interface YTNoteTableCellView : YTBaseView  {
@private
	YTNoteCellTextView *_textView;
	BOOL _showThumbnail;
	BOOL _showAttachmentIcon;
	YTResourceImageView *_thumbnailView;
	YTNoteTableCellView_ThumbFrame *_thumbFrame;
	YTResourceInfo *_resourceImage;
	BOOL _showDate;
	VLLabel *_lbDateDay;
	VLLabel *_lbDateWeekday;
	UIImageView *_iconAttachment;
	YTNoteTableCellView_Separator *_separator;
	YTNoteTableCellInfo *_cellInfo;
}

@property(nonatomic, readonly) YTNoteTableCellInfo *cellInfo;
@property(nonatomic, readonly) YTNoteCellTextView *textView;
@property(nonatomic, readonly) YTResourceImageView *thumbnailView;
@property(nonatomic, readonly) YTResourceInfo *resourceImage;

+ (float)optimalHeight;
- (id)initWithFrame:(CGRect)frame showDate:(BOOL)showDate showThumbnail:(BOOL)showThumbnail
				showAttachmentIcon:(BOOL)showAttachmentIcon;
- (void)prepareForAddToTable;
- (void)applyCellInfo:(YTNoteTableCellInfo *)cellInfo;
- (void)onSelectedChanged:(BOOL)selected;
- (BOOL)canBeSelected;
- (void)showThumbnailFrame:(BOOL)show animated:(BOOL)animated;

@end


@interface YTNotesTableViewCell : VLTableViewCell {
@private
	BOOL _lastSelected;
}

@end


@interface YTNoteTableCellView_Separator : YTBaseView {
@private
}

- (float)optimalHeight;

@end





