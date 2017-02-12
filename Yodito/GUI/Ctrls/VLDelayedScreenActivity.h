
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

@interface VLDelayedScreenActivity : NSObject {
@private
	NSTimeInterval _uptimeStart;
	NSTimeInterval _activityShowDelay;
	NSTimeInterval _maxDuration;
	VLBlockCheck _checkForCancelBlock;
	NSString *_title;
	BOOL _activityShown;
	VLTimer *_timer;
	BOOL _started;
}

- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay maxDuration:(NSTimeInterval)maxDuration checkForCancelBlock:(VLBlockCheck)checkForCancelBlock;
- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay checkForCancelBlock:(VLBlockCheck)checkForCancelBlock;
- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay;
- (void)cancelActivity;
- (BOOL)isMaxDurationExceeded;

@end

