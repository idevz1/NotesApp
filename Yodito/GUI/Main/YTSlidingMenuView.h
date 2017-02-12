
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Notes/Classes.h"

@class YTSlidingMenuView;

typedef enum
{
	EYTSlidingMenuViewActionNone,
	EYTSlidingMenuViewActionShowTimeline,
	EYTSlidingMenuViewActionShowStarred,
	EYTSlidingMenuViewActionShowPhotos,
	EYTSlidingMenuViewActionShowSettings,
	EYTSlidingMenuViewActionShowNotebook,
	EYTSlidingMenuViewActionShowTag
}
EYTSlidingMenuViewAction;


@interface YTSlidingMenuActionArgs : NSObject {
@private
	EYTSlidingMenuViewAction _action;
	NSObject *_param;
}

@property(nonatomic, assign) EYTSlidingMenuViewAction action;
@property(nonatomic, retain) NSObject *param;

- (id)initWithAction:(EYTSlidingMenuViewAction)action param:(NSObject *)param;

@end



@protocol YTSlidingMenuViewDelegate <NSObject>
@optional
- (void)slidingMenuView:(YTSlidingMenuView *)slidingMenuView actionSelected:(YTSlidingMenuActionArgs *)actionArgs;
@end



@interface YTSlidingMenuView : YTBaseView <UITableViewDataSource, UITableViewDelegate, YTMenuTableCellViewDelegate> {
@private
	UIImageView *_statusBarBack;
	UIImageView *_imageViewBack;
	UIView *_overlayView;
	
	UITableView *_tableView;
	NSMutableArray *_cellsSections;
	YTMenuTableCellView *_viewTimeline;
	YTMenuTableCellView *_viewStarred;
	YTMenuTableCellView *_viewPhotos;
	NSMutableArray *_cellsNotebooks;
	NSMutableArray *_cellsTags;
	NSMutableArray *_cellsBottom;
	YTMenuTableCellView *_viewSettings;
	
	NSObject<YTSlidingMenuViewDelegate> *_delegate;
	
	int _lastCustomWallpaperVersion;
	BOOL _wasRegistered;
}

@property(nonatomic, assign) NSObject<YTSlidingMenuViewDelegate> *delegate;

@end

