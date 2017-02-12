
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTResourceBaseView : YTBaseView {
@private
	YTResourceLoadingReference *_loadingReference;
	UIActivityIndicatorView *_activityView;
	BOOL _makeThumbnails;
	BOOL _makePreview;
	BOOL _aspectFill;
	UIColor *_activityBackColor;
	BOOL _showActivityIndicator;
}

@property(nonatomic, readonly) YTResourceLoadingReference *loadingReference;
@property(nonatomic, readonly) UIActivityIndicatorView *activityView;
@property(nonatomic, assign) BOOL makeThumbnails;
@property(nonatomic, assign) BOOL makePreview;
@property(nonatomic, assign) BOOL aspectFill;
@property(nonatomic, assign) UIColor *activityBackColor;
@property(nonatomic, assign) BOOL showActivityIndicator;

@end

