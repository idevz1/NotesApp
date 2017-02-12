
#import <Foundation/Foundation.h>
#import "VLCommon.h"

@class VLTimer;

@interface VLTimer_eventHandler : NSObject
{
	VLTimer *_parent;
}

@property(nonatomic,assign) VLTimer *parent;

- (void)timerEvent:(NSTimer*)timer;

@end


@interface VLTimer : NSObject
{
	NSTimer *_timer;
	NSTimeInterval _interval;
	NSObject *_target;
	SEL _selector;
	VLTimer_eventHandler *_handler;
	BOOL _enabledAlwaysFiring;
	NSTimeInterval _lastFireTime;
	BOOL _timerFiring;
	VLBlockVoid _targetBlock;
}

@property(nonatomic, assign) NSTimeInterval interval;
@property(nonatomic, assign) BOOL enabledAlwaysFiring;
@property(nonatomic, readonly) BOOL started;

+ (double)timerIntervalMultiplier;
+ (void)setTimerIntervalMultiplier:(double)multiplier;

- (void)setObserver:(NSObject*)target selector:(SEL)selector;
- (void)setObserverBlock:(VLBlockVoid)block;

- (void)start;
- (void)stop;
- (void)timerEvent:(NSTimer*)timer;
- (void)checkAlwaysFiring;

+ (NSTimeInterval)systemUptime;

@end




@interface VLTimersManager : NSObject
{
	NSMutableArray *_timers;
}

+ (VLTimersManager*)shared;

- (void)registerTimer:(VLTimer*)timer;
- (void)unregisterTimer:(VLTimer*)timer;

- (void)processEvents;

@end



