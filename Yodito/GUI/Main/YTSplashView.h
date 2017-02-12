
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTSplashView : YTBaseView {
@private
	UIView *_topStrip;
	UIView *_bottomStrip;
	UIImageView *_imageSnippet;
	UIImageView *_imagePageCtrl;
	VLLabel *_labelText1;
	UIImageView *_imageArrow;
}

@end
