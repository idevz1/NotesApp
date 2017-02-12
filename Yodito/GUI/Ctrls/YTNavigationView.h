
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

typedef enum
{
	EYTNavigationViewAppearModeSlide,
	EYTNavigationViewAppearModeOverlap
}
EYTNavigationViewAppearMode;


@interface YTNavigationView : VLBaseView {
@private
	NSMutableArray *_arrNavInfo;
	int _curIndex;
}

@property(nonatomic, readonly) NSArray *views;

- (void)pushView:(VLBaseView *)view animated:(BOOL)animated appearMode:(EYTNavigationViewAppearMode)appearMode;
- (void)pushView:(VLBaseView *)view animated:(BOOL)animated;
- (void)popView:(VLBaseView *)view animated:(BOOL)animated;

@end

