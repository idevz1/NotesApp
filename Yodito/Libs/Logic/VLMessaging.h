
#import <Foundation/Foundation.h>
#import "VLCommon.h"

#define kVLMessageCenterDefaultTimerInterval 0.01

@class VLBinder;

@interface VLBinder : NSObject
{
@protected
	NSObject *_owner;
	NSMutableArray *_targets;
	NSMutableArray *_selectors;
}

@property(nonatomic,assign) NSObject *owner;

- (void)addObserver:(NSObject*)target selector:(SEL)selector;
- (void)removeObserver:(NSObject*)target;
- (BOOL)hasSubscribers;

@end





@interface VLDelegate : VLBinder
{
	
}

- (void)sendMessage:(NSObject*)sender;
- (void)sendMessage:(NSObject*)sender withArgs:(NSObject*)args;

@end


@interface VLEventArgs : NSObject
{
}
@end

@interface VLCancelEventArgs : VLEventArgs
{
	BOOL _cancel;
}
@property(nonatomic,assign) BOOL cancel;
@end

@interface VLDataEventArgs : VLCancelEventArgs
{
	NSData *_data;
}
@property(nonatomic,retain) NSData *data;
@end

@interface VLStringEventArgs : VLCancelEventArgs
{
	NSString *_string;
}
@property(nonatomic,copy) NSString *string;
@end

@interface VLIntEventArgs : VLCancelEventArgs
{
	int _value;
}
@property(nonatomic, assign) int value;
@end











@interface VLMessenger : VLBinder
{
	id _args;
	int _argsTicket;
}

@property(nonatomic,readonly) id args;

- (void)postMessage;
- (void)postMessageWithArgs:(id)args;
- (void)processMessage;
- (void)cancelPostMessage;

@end



















void CFRunLoopObserverCallBackImpl(CFRunLoopObserverRef observer,
								   CFRunLoopActivity activity, void *info);

@interface VLMessageCenter : NSObject
{
	NSTimeInterval _timerInterval;
	NSTimer *_timer;
	NSMutableArray *_messengers;
}

+ (VLMessageCenter*)shared;
- (void)setTimerInterval:(NSTimeInterval)interval;
- (void)timerEvent:(NSTimer*)timer;

- (void)postMessage:(VLMessenger*)messenger;
- (void)cancelMessage:(VLMessenger*)messenger;

- (void)performModalSelector:(SEL)selector
				   forObject:(id)object
				  afterDelay:(NSTimeInterval)delay
				   withParam:(id)param;
- (void)performModalSelector:(SEL)selector forObject:(id)object afterDelay:(NSTimeInterval)delay;

- (void)performBlock:(VLBlockVoid)block
		  afterDelay:(NSTimeInterval)delay
	 ignoringTouches:(BOOL)ignoringTouches;

- (void)waitWithCheckBlock:(VLBlockCheck)checkBlock
		   ignoringTouches:(BOOL)ignoringTouches
			 completeBlock:(VLBlockVoid)completeBlock;

@end






