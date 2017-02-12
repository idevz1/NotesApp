
#import <Foundation/Foundation.h>
#import "Base/Classes.h"
#import "NoteEdit/Classes.h"
#import "Resources/Classes.h"

@class YTNoteView;
@class YTNoteTableCellView;

@interface YTUiMediator : YTLogicObject <YTNoteEditViewDelegate, UIPopoverControllerDelegate> {
@private
	int64_t _savedDataVersion;
	VLMessenger *_msgrNoteAddedManually;
	VLMessenger *_msgrFileCantBeViewedAlerted;
	int _isScrollingCounter;
	VLMessenger *_msgrScrollingEnded;
}

@property(nonatomic, readonly) VLMessenger *msgrNoteAddedManually;
@property(nonatomic, readonly) VLMessenger *msgrFileCantBeViewedAlerted;
@property(nonatomic, readonly) VLMessenger *msgrScrollingEnded;

+ (YTUiMediator *)shared;

- (YTNotebookInfo *)notebookForNewNotes;
- (YTStackInfo *)mainStack;
- (void)deleteNoteWithNoteView:(YTNoteView *)noteView resultBlock:(VLBlockBool)resultBlock;

- (void)startAddNewNoteAsPhoto:(BOOL)isPhoto
				  notebookGuid:(NSString *)notebookGuid
					 isStarred:(BOOL)isStarred
		   previousScreenTitle:(NSString *)previousScreenTitle;

- (void)startEditNote:(YTNoteInfo *)note
  previousScreenTitle:(NSString *)previousScreenTitle;

- (void)showNoteView:(YTNoteView *)noteView
		optionalFromCellView:(YTNoteTableCellView *)noteCellView
	optionalOnThumbsView:(YTPhotosThumbsView *)thumbsView
	optionalFromThumbView:(YTPhotosThumbsView_ThumbView *)thumbView;
- (void)saveTakenPhotoToCameraRoll:(UIImage *)image;

- (void)beginIsScrolling;
- (void)endIsScrolling;
- (BOOL)isScrolling;

@end

