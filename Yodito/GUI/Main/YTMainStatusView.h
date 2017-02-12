
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTMainStatusView;

@protocol YTMainStatusViewDelegate <NSObject>
@optional
- (void)mainStatusView:(YTMainStatusView *)mainStatusView statusChanged:(id)param;
@end

@interface YTMainStatusView : YTBaseView {
@private
	VLLabel *_labelTitle;
	VLLabel *_labelValue;
	NSObject<YTMainStatusViewDelegate> *_delegate;
	BOOL _shouldBeShown;
}

@property(nonatomic, assign) NSObject<YTMainStatusViewDelegate> *delegate;
@property(nonatomic, readonly) BOOL shouldBeShown;

@end

