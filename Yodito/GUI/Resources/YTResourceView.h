
#import <Foundation/Foundation.h>
#import "YTResourceImageView.h"
#import "YTResourceMediaView.h"
#import "YTResourceOtherView.h"
#import "YTResourceBaseView.h"
#import "YTResourceWebDocView.h"

@interface YTResourceView : YTResourceBaseView {
@private
	YTResourceImageView *_imageView;
	YTResourceMediaView *_mediaView;
	YTResourceWebDocView *_webDocView;
	YTResourceOtherView *_otherView;
	VLLabel *_lbError;
	UIButton *_btnReload;
	UITapGestureRecognizer *_tapRecognizer;
	VLTimer *_timer;
	BOOL _waitingForReloadStarted;
	NSTimeInterval _waitingForReloadStartTime;
}

- (BOOL)isImageShown;
- (UIView *)getImageHolderView;

@end

