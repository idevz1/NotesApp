
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"
#import "YTNoteEditItemsView.h"
#import <AVFoundation/AVFoundation.h>
#import "../Notebook/Classes.h"
#import "YTMapSearchView.h"
#import "../ELCImagePicker/Classes.h"
#import "../Tags/Classes.h"
#import "YTSearchTagView.h"

@class YTNoteEditView;
@class YTNoteContentSeparator;

@protocol YTNoteEditViewDelegate <NSObject>
@required
- (void)noteEditView:(YTNoteEditView *)noteEditView finishWithAction:(EYTUserActionType)action;

@end



@interface YTNoteEditView_PlaceholderView : VLLabel {
@private
}

@end


@interface YTNoteEditView : YTBaseView <UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate,
	YTNoteEditItemsViewDelegate, YTNotebookSelectViewDelegate, YTMapSearchViewDelegate,
	YTSearchTagViewDelegate, NSLayoutManagerDelegate, YTTagsLineViewDelegate, YTNoteEditViewDelegate> {
@private
	VLTimer *_timer;
	YTTagsLineView *_tagsLineView;
	YTNoteContentSeparator *_sepTagsBot;
	UITextView *_tvContent;
	YTNoteEditView_PlaceholderView *_tvPlaceholder;
	NSString *_lastText;
	NSObject<YTNoteEditViewDelegate> *_delegate;
	BOOL _isNoteContentHtml;
	BOOL _startEditTitleAfterOpen;
	YTNoteEditItemsView *_itemsView;
	BOOL _keyboardShown;
	CGRect _frameOfKeyboard;
	BOOL _triedGetCurLocation;
	int _tryGetCurLocTicket;
	UIView *_lastFirstResponderRef;
	BOOL _wasFirstResponder;
	BOOL _isNewNote;
	int _gettingCurrentLocationCounter;
	BOOL _showingGettingCurLocActivity;
	UIView *_overlayGettingCurLoc;
	YTActivityView *_activityGettingCurLoc;
	BOOL _tagsShown;
	BOOL _animatingShowingTags;
	BOOL _isScrollingNEV;
	BOOL _savingImagesStarted;
	int64_t _lastAutoSavedDataVersion;
	BOOL _isAutoSaving;
	NSTimeInterval _lastAutosavedUptime;
	BOOL _newNoteNeedsAutosave;
	YTActivityView *_activitySaveImages;
	int _imagesToSave;
	int _imagesToSaveLeft;
	int _pickerShownCounter;
}

@property(nonatomic, assign) NSObject<YTNoteEditViewDelegate> *delegate;
@property(nonatomic, assign) BOOL startEditTitleAfterOpen;
@property(nonatomic, assign) BOOL isNewNote;

- (void)initializeWithNoteEditInfo:(YTNoteEditInfo *)noteEditInfo previousScreenTitle:(NSString *)previousScreenTitle;
- (void)addImagesFromAssets:(NSArray *)assets;
- (void)addResourceWithImage:(UIImage *)image
					 orVideo:(NSString *)pathToVideo
				 resultBlock:(VLBlockVoid)resultBlock;

@end
