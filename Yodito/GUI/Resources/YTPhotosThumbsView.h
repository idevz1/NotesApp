
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"
#import "YTResourceImageView.h"
#import "YTNoteViewDelegate.h"

@class YTEmptyNotesView;
@class YTPhotosThumbsView;
@class YTPhotosThumbsView_ThumbView;

@protocol YTPhotosThumbsView_ThumbViewDelegate <NSObject>
@optional
- (BOOL)thumbView:(YTPhotosThumbsView_ThumbView *)thumbView isVisible:(id)param;

@end

@interface YTPhotosThumbsView_ThumbView : YTBaseView <YTNoteViewDelegate, YTResourceImageViewDelegate> {
@private
	YTResourceImageView *_resourceImageView;
	UIButton *_button;
	BOOL _forcedShowImage;
	VLLabel *_lbTime;
	VLLabel *_lbDay;
	VLLabel *_lbDate;
	NSObject<YTPhotosThumbsView_ThumbViewDelegate> *_delegate;
	BOOL _showImageView;
}

@property(nonatomic, assign) NSObject<YTPhotosThumbsView_ThumbViewDelegate> *delegate;
@property(nonatomic, readonly) YTResourceImageView *resourceImageView;
@property(nonatomic, assign) BOOL showImageView;

@end


@interface YTPhotosThumbsView_ContentView : YTBaseView <YTPhotosThumbsView_ThumbViewDelegate> {
@private
	UIView *_backViewSep;
	NSMutableArray *_arrResImages;
	NSMutableArray *_arrResImagesSizes;
	NSMutableArray *_arrResViewsFrames;
	float _allViewsHeight;
	float _allViewsWidth;
	NSMutableArray *_arrThumbs;
	NSTimeInterval _maxWaitingTimeToLoad;
	BOOL _updatingInBackground;
	int _updatingInBackgroundTicket;
	int _updatingInBackgroundAllViewsWidth;
	NSMutableArray *_updatingInBackgroundArrResImages;
	YTPhotosThumbsView *_parentThumbsViewRef;
}

@property(nonatomic, assign) YTPhotosThumbsView *parentThumbsViewRef;
@property(nonatomic, readonly) NSArray *arrThumbs;
@property(nonatomic, readonly) NSArray *arrResViewsFrames;

- (id)initWithFrame:(CGRect)frame parentThumbsView:(YTPhotosThumbsView *)parentThumbsView maxWaitingTimeToLoad:(NSTimeInterval)maxWaitingTimeToLoad;

@end


@interface YTPhotosThumbsView : YTBaseView <UIScrollViewDelegate> {
@private
	UIScrollView *_scrollView;
	YTPhotosThumbsView_ContentView *_contentView;
	NSTimeInterval _maxWaitingTimeToLoad;
	VLTimer *_timer;
}

+ (YTPhotosThumbsView *)currentInstance;
- (id)initWithFrame:(CGRect)frame maxWaitingTimeToLoad:(NSTimeInterval)maxWaitingTimeToLoad;
- (BOOL)isAllImagesShown;

@end

