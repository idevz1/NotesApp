
#import "VLTimer.h"

@implementation VLTimer_eventHandler

@synthesize parent = _parent;

- (void)timerEvent:(NSTimer*)timer
{
	if(_parent)
		[_parent timerEvent:timer];
}

@end



static double _timerIntervalMultiplier = 1.0;

@implementation VLTimer

@dynamic interval;
@dynamic enabledAlwaysFiring;
@dynamic started;

+ (double)timerIntervalMultiplier {
	return _timerIntervalMultiplier;
}

+ (void)setTimerIntervalMultiplier:(double)multiplier {
	_timerIntervalMultiplier = multiplier;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_interval = 1.0;
		_handler = [[VLTimer_eventHandler alloc] init];
		_handler.parent = self;
	}
	return self;
}

- (NSTimeInterval)interval
{
	return _interval;
}
- (void)setInterval:(NSTimeInterval)newInterval
{
	if(_interval != newInterval)
	{
		BOOL wasStarted = (_timer != nil);
		[self stop];
		_interval = newInterval;
		if(wasStarted)
			[self start];
	}
}

- (BOOL)started {
	return (_timer != nil);
}

- (void)setObserver:(NSObject*)target selector:(SEL)selector
{
	_target = target;
	_selector = selector;
}

- (void)setObserverBlock:(VLBlockVoid)block
{
	if(_targetBlock)
		Block_release(_targetBlock);
	_targetBlock = Block_copy(block);
}

- (void)timerEvent:(NSTimer*)timer
{
	if(_timerFiring)
		return;
	if(_enabledAlwaysFiring)
	{
		NSTimeInterval curTime = [VLTimer systemUptime];
		if(curTime < (_lastFireTime + _interval))
			return;
		_lastFireTime = curTime;
	}
	[self retain];
	_timerFiring = YES;
	if(_target && _selector)
	{
		[_target performSelector:_selector withObject:self];
	}
	if(_targetBlock)
		_targetBlock();
	_timerFiring = NO;
	[self release];
}

- (void)checkAlwaysFiring
{
	if(!_enabledAlwaysFiring || !_timer)
		return;
	NSTimeInterval curTime = [VLTimer systemUptime];
	if(curTime >= (_lastFireTime + _interval))
	{
		[self retain];
		[self timerEvent:nil];
		[self release];
	}
}

- (void)start
{
	[self stop];
	_timer = [NSTimer scheduledTimerWithTimeInterval:_interval * _timerIntervalMultiplier
											  target:_handler
											selector:@selector(timerEvent:)
											userInfo:nil
											 repeats:YES];
	[_timer retain];
}

- (void)stop
{
	if(_timer)
	{
		[_timer invalidate];
		[_timer release];
		_timer = nil;
	}
}

+ (NSTimeInterval)systemUptime
{
	NSProcessInfo* proc = [NSProcessInfo processInfo];
	NSTimeInterval res = [proc systemUptime];
	return res;
}

- (BOOL)enabledAlwaysFiring
{
	return _enabledAlwaysFiring;
}
- (void)setEnabledAlwaysFiring:(BOOL)value
{
	if(_enabledAlwaysFiring != value)
	{
		if(_enabledAlwaysFiring)
			[[VLTimersManager shared] unregisterTimer:self];
		_enabledAlwaysFiring = value;
		if(_enabledAlwaysFiring)
		{
			_lastFireTime = [VLTimer systemUptime];
			[[VLTimersManager shared] registerTimer:self];
		}
	}
}

- (void)dealloc
{
	[self stop];
	self.enabledAlwaysFiring = NO;
	_target = nil;
	_handler.parent = nil;
	[_handler release];
	if(_targetBlock)
		Block_release(_targetBlock);
	[super dealloc];
}

@end







@implementation VLTimersManager

+ (VLTimersManager*)shared
{
	static VLTimersManager *_shared = nil;
	if(!_shared)
		_shared = [[VLTimersManager alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		CFArrayCallBacks acb = { 0, NULL, NULL, CFCopyDescription, CFEqual };
		_timers = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &acb);
	}
	return self;
}

- (void)registerTimer:(VLTimer*)timer
{
	if(![_timers containsObject:timer])
		[_timers addObject:timer];
}

- (void)unregisterTimer:(VLTimer*)timer
{
	if([_timers containsObject:timer])
		[_timers removeObject:timer];
}

- (void)processEvents
{
	for(int i = 0; i < [_timers count]; i++)
	{
		VLTimer *timer = [_timers objectAtIndex:i];
		[timer checkAlwaysFiring];
	}
}

- (void)dealloc
{
	[_timers release];
	[super dealloc];
}

@end




