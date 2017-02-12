
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTSlidingMenuView.h"
#import "YTSlidingContentView.h"
#import "YTSplashView.h"

@class YTSlidingContainerView_SliddenContentOverlayView;

@interface YTSlidingContainerView : YTBaseView <YTNavigatingViewDelegate, YTSlidingMenuViewDelegate> {
@private
	YTSlidingMenuView *_menuView;
	YTSlidingContentView *_contentView;
	YTSlidingContainerView_SliddenContentOverlayView *_sliddenOverlay;
	float _slideRatio;
	YTSplashView *_splashView;
	float _showSplashRatio;
	float _dragStartSlideRatio;
	BOOL _dragStarted;
	CGPoint _dragStartPoint;
	int _slideIgnoringCounter;
	VLActivityView *_activityViewLoading;
	YTPhotosThumbsView *_cachedPhotosThumbsView;
	UIPanGestureRecognizer *_panGesture;
	
	YTNotesContentView *_contentView_noteView;
	YTNoteView *_noteView;
	BOOL _openingNoteView;
	BOOL _closingNoteView;
	
	YTNotesContentView *_contentView_noteEditView;
	YTNoteEditView *_noteEditView;
	int _disableAnimationCounter;
}

+ (YTSlidingContainerView *)shared;

- (void)suspendSliding;
- (void)resumeSliding;
- (void)suspendSliding:(BOOL)suspend;

- (void)showNoteView:(YTNoteView *)noteView fromCellView:(YTNoteTableCellView *)noteCellView;
- (BOOL)closeNoteView:(YTNoteView *)noteView toCellView:(YTNoteTableCellView *)noteCellView;

- (void)showNoteView:(YTNoteView *)noteView fromThumbView:(YTPhotosThumbsView_ThumbView *)thumbView;
- (BOOL)closeNoteView:(YTNoteView *)noteView toThumbView:(YTPhotosThumbsView_ThumbView *)thumbView;

- (void)showNoteEditView:(YTNoteEditView *)noteEditView;
- (BOOL)closeNoteEditView:(YTNoteEditView *)noteEditView;

@end




@interface YTSlidingContainerView_SliddenContentOverlayView : YTBaseView {
@private
}

@end




