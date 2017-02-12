
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class VLSidesSwipeViewHelper;

@protocol VLSidesSwipeViewHelperDelegate <NSObject>
@required
- (VLBaseView *)sidesSwipeViewHelper:(VLSidesSwipeViewHelper *)sidesSwipeViewHelper getContentView:(id)param;
- (void)sidesSwipeViewHelper:(VLSidesSwipeViewHelper *)sidesSwipeViewHelper slidingStarted:(id)param;
- (void)sidesSwipeViewHelper:(VLSidesSwipeViewHelper *)sidesSwipeViewHelper slidingStopped:(id)param;
- (void)sidesSwipeViewHelper:(VLSidesSwipeViewHelper *)sidesSwipeViewHelper layoutContentView:(id)param;
@end


@interface VLSidesSwipeViewHelper : VLLogicObject {
@private
	//VLBaseView *_leftView;
	//VLBaseView *_rightView;
	float _slideRatio; // -1.0 ... 0.0 ... +1.0
	CGPoint _ptStart;
    float _slideRatioStart;
	BOOL _slideTrackStarted;
	NSTimeInterval _uptimeSlideStart;
	BOOL _sliding;
	BOOL _slidingRight;
	BOOL _slidingLeft;
	NSObject<VLSidesSwipeViewHelperDelegate> *_delegate;
}

@property(nonatomic,assign) NSObject<VLSidesSwipeViewHelperDelegate> *delegate;
@property(nonatomic,readonly) float slideRatio;
@property(nonatomic,readonly) float contentOffsetX;
@property(nonatomic,readonly) BOOL sliding;
@property(nonatomic,readonly) BOOL slidingRight;
@property(nonatomic,readonly) BOOL slidingLeft;

- (void)handleTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)handleTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)handleTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)handleTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)stopSlideWithCancel:(BOOL)cancel;
- (void)resetSlide;

@end

