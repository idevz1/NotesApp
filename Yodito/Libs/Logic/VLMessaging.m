
#import "VLMessaging.h"

@implementation VLBinder

@synthesize owner = _owner;

- (id)init
{
	self = [super init];
	if(self)
	{
		CFArrayCallBacks acb = { 0, NULL, NULL, CFCopyDescription, CFEqual };
		_targets = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &acb);
		_selectors = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addObserver:(NSObject*)target selector:(SEL)selector
{
	for(int i = 0; i < _targets.count; i++) {
		NSObject *curTarget = [_targets objectAtIndex:i];
		if(curTarget == target) {
			NSValue *valSel = [_selectors objectAtIndex:i];
			SEL curSelector = [valSel pointerValue];
			if([NSStringFromSelector(curSelector) isEqual:NSStringFromSelector(selector)]) {
				return;
			}
		}
	}
	[_targets addObject:target];
	NSValue *valSel = [NSValue valueWithPointer:selector];
	[_selectors addObject:valSel];
}

- (void)removeObserver:(NSObject*)target
{
	for(int i = (int)[_targets count] - 1; i >= 0; i--)
	{
		if([_targets objectAtIndex:i] == target)
		{
			[_targets removeObjectAtIndex:i];
			[_selectors removeObjectAtIndex:i];
		}
	}
}

- (void)processMessageWithArgs:(id)args
{
	if(![_targets count])
		return;
	NSArray *targetsCopy = [[NSArray alloc] initWithArray:_targets];
	NSArray *selectorsCopy = [[NSArray alloc] initWithArray:_selectors];
	for(int i = 0; i < [targetsCopy count]; i++)
	{
		NSObject *target = [targetsCopy objectAtIndex:i];
		id objSel = [selectorsCopy objectAtIndex:i];
		if([objSel isKindOfClass:[NSValue class]])
		{
			NSValue *valSel = (NSValue*)objSel;
			SEL selector = [valSel pointerValue];
			
			// Usefull to find crashes:
			//NSLog(@"call selector begin");
			//NSLog(@"target: %@, selector: %@", target, NSStringFromSelector(selector));
			
			if(args)
				[target performSelector:selector withObject:self withObject:args];
			else
				[target performSelector:selector withObject:self];
			
			//NSLog(@"call selector end");
		}
	}
	[targetsCopy release];
	[selectorsCopy release];
}

- (BOOL)hasSubscribers
{
	return ([_targets count] > 0);
}

- (void)dealloc
{
	[_targets release];
	[_selectors release];
	[super dealloc];
}

@end






@implementation VLDelegate

- (id)init
{
	self = [super init];
	if(self)
	{
	}
	return self;
}

- (void)sendMessage:(NSObject*)sender
{
	if(![_targets count])
		return;
	[super processMessageWithArgs:nil];
}

- (void)sendMessage:(NSObject*)sender withArgs:(NSObject*)args
{
	if(![_targets count])
		return;
	[super processMessageWithArgs:args];
}

- (void)dealloc
{
	[super dealloc];
}

@end


@implementation VLEventArgs
@end

@implementation VLCancelEventArgs
@synthesize cancel = _cancel;
@end

@implementation VLDataEventArgs
@synthesize data = _data;
- (void)dealloc
{
	[_data release];
	[super dealloc];
}
@end

@implementation VLStringEventArgs
@synthesize string = _string;
- (void)dealloc
{
	[_string release];
	[super dealloc];
}
@end

@implementation VLIntEventArgs
@synthesize value = _value;
@end

















@implementation VLMessenger

@synthesize args = _args;

- (id)init
{
	self = [super init];
	if(self)
	{
	}
	return self;
}

- (void)postMessage
{
	_argsTicket++;
	if(![_targets count])
	{
		[_args release];
		_args = nil;
		return;
	}
	[[VLMessageCenter shared] postMessage:self];
}

- (void)postMessageWithArgs:(id)args
{
	[_args release];
	_args = args;
	if(_args)
		[_args retain];
	_argsTicket++;
	[self postMessage];
}

- (void)processMessage
{
	if(![_targets count])
	{
		[_args release];
		_args = nil;
		_argsTicket++;
		return;
	}
	id curArgs = nil;
	if(_args)
		curArgs = [_args retain];
	int curArgsTicket = _argsTicket;
	[super processMessageWithArgs:curArgs];
	if(curArgs)
	{
		if(curArgsTicket == _argsTicket)
		{
			[_args release];
			_args = nil;
			_argsTicket++;
		}
		[curArgs release];
	}
}

- (void)cancelPostMessage
{
	[_args release];
	_args = nil;
	_argsTicket++;
	[[VLMessageCenter shared] cancelMessage:self];
}

- (void)dealloc
{
	[[VLMessageCenter shared] cancelMessage:self];
	[_args release];
	[super dealloc];
}

@end

















void CFRunLoopObserverCallBackImpl(CFRunLoopObserverRef observer,
								   CFRunLoopActivity activity, void *info)
{
	[[VLMessageCenter shared] performSelector:@selector(processMessages)];
}


@interface VLMessageCenter_WaitArgs : NSObject
{
	NSNumber *_paramNumber;
	VLBlockVoid _blockVoid;
	VLBlockCheck _blockCheck;
	BOOL _ignoreTouches;
	id _objectToPerformModalSelector;
	SEL _selectorToPerformModal;
	id _objectModalParam;
}
@property(nonatomic,retain) NSNumber *paramNumber;
@property(nonatomic,copy) VLBlockVoid blockVoid;
@property(nonatomic,copy) VLBlockCheck blockCheck;
@property(nonatomic,assign) BOOL ignoreTouches;
@property(nonatomic,assign) id objectToPerformModalSelector;
@property(nonatomic,assign) SEL selectorToPerformModal;
@property(nonatomic,retain) id objectModalParam;
@end
@implementation VLMessageCenter_WaitArgs
@synthesize paramNumber = _paramNumber;
@synthesize blockVoid = _blockVoid;
@synthesize blockCheck = _blockCheck;
@synthesize ignoreTouches = _ignoreTouches;
@synthesize objectToPerformModalSelector = _objectToPerformModalSelector;
@synthesize selectorToPerformModal = _selectorToPerformModal;
@synthesize objectModalParam = _objectModalParam;
- (void)dealloc
{
	[_paramNumber release];
	[_objectModalParam release];
	if(_blockVoid)
		Block_release(_blockVoid);
	if(_blockCheck)
		Block_release(_blockCheck);
	[super dealloc];
}
@end


@implementation VLMessageCenter

+ (VLMessageCenter*)shared
{
	static VLMessageCenter *_shared = nil;
	if(!_shared)
		_shared = [[VLMessageCenter alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_timerInterval = kVLMessageCenterDefaultTimerInterval;
		
		CFArrayCallBacks acb = { 0, NULL, NULL, CFCopyDescription, CFEqual };
		_messengers = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &acb);
		[self startTimer];
		
		CFRunLoopRef curLoop = CFRunLoopGetCurrent();
		CFRunLoopObserverRef obs = CFRunLoopObserverCreate (
															NULL,
															kCFRunLoopAllActivities,
															YES,
															0,
															CFRunLoopObserverCallBackImpl,
															NULL
															);
		CFArrayRef arr = CFRunLoopCopyAllModes(curLoop);
		CFIndex count = CFArrayGetCount(arr);
		for(CFIndex i = 0; i < count; i++)
		{
			CFStringRef sMode = (CFStringRef)CFArrayGetValueAtIndex(arr, i);
			CFRunLoopAddObserver(curLoop, obs, sMode);
			//CFRelease(sMode);
		}
		CFRelease(arr);
		CFRelease(obs);
	}
	return self;
}

- (void)startTimer {
	if(_timer)
		return;
	_timer = [[NSTimer scheduledTimerWithTimeInterval:_timerInterval
											  target:self
											selector:@selector(timerEvent:)
											userInfo:nil
											 repeats:YES] retain];
}

- (void)setTimerInterval:(NSTimeInterval)interval {
	if(_timerInterval != interval) {
		_timerInterval = interval;
		if(_timer) {
			[_timer invalidate];
			[_timer release];
			_timer = nil;
		}
		[self startTimer];
	}
}

- (void)postMessage:(VLMessenger*)messenger
{
	for(VLMessenger *obj in _messengers)
		if(obj == messenger)
			return;
	[_messengers addObject:messenger];
}

- (void)processMessages
{
	while([_messengers count] > 0)
	{
		VLMessenger *messenger = [_messengers objectAtIndex:0];
		[messenger retain];
		[_messengers removeObjectAtIndex:0];
		[messenger processMessage];
		[messenger release];
	}
	{
		static Class _timersManagerClass = nil;
		static id _timersManagerInstance = nil;
		static BOOL _timersChecked = NO;
		if(!_timersChecked)
		{
			_timersChecked = YES;
			if(!_timersManagerClass && !_timersManagerInstance)
			{
				_timersManagerClass = NSClassFromString(@"VLTimersManager");
				if(_timersManagerClass)
					_timersManagerInstance = [_timersManagerClass shared];
			}
		}
		if(_timersManagerInstance)
			[_timersManagerInstance performSelector:@selector(processEvents)];
	}
}

- (void)timerEvent:(NSTimer*)timer
{
	[self processMessages];
}

- (void)cancelMessage:(VLMessenger*)messenger
{
	for(int i = (int)[_messengers count] - 1; i >= 0; i--)
		if([_messengers objectAtIndex:i] == messenger)
			[_messengers removeObjectAtIndex:i];
}

- (void)performModalSelectorAfterDelay:(VLMessageCenter_WaitArgs*)args
{
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	if(args.objectModalParam)
		[args.objectToPerformModalSelector performSelector:args.selectorToPerformModal withObject:args.objectModalParam];
	else
		[args.objectToPerformModalSelector performSelector:args.selectorToPerformModal];
}
- (void)performModalSelector:(SEL)selector
				   forObject:(id)object
				  afterDelay:(NSTimeInterval)delay
				   withParam:(id)param
{
	VLMessageCenter_WaitArgs *args = [[[VLMessageCenter_WaitArgs alloc] init] autorelease];
	args.objectToPerformModalSelector = object;
	args.selectorToPerformModal = selector;
	args.objectModalParam = param;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[self performSelector:@selector(performModalSelectorAfterDelay:) withObject:args afterDelay:delay];
}

- (void)performModalSelector:(SEL)selector forObject:(id)object afterDelay:(NSTimeInterval)delay
{
	[self performModalSelector:selector
					 forObject:object
					afterDelay:delay
					 withParam:nil];
}

- (void)performBlockHandler:(VLMessageCenter_WaitArgs*)args
{
	if(args.ignoreTouches)
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	args.blockVoid();
}
- (void)performBlock:(VLBlockVoid)block
		  afterDelay:(NSTimeInterval)delay
	 ignoringTouches:(BOOL)ignoringTouches
{
	VLMessageCenter_WaitArgs *args = [[[VLMessageCenter_WaitArgs alloc] init] autorelease];
	args.blockVoid = Block_copy(block);
	Block_release(args.blockVoid);
	args.ignoreTouches = ignoringTouches;
	if(args.ignoreTouches)
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[self performSelector:@selector(performBlockHandler:) withObject:args afterDelay:delay];
}

- (void)waitForFlagStep1:(VLMessageCenter_WaitArgs*)args
{
	if(!args.blockCheck())
	{
		[self performSelector:@selector(waitForFlagStep1:) withObject:args afterDelay:0.001];
		return;
	}
	if(args.ignoreTouches)
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	args.blockVoid();
}
- (void)waitWithCheckBlock:(VLBlockCheck)checkBlock
		   ignoringTouches:(BOOL)ignoringTouches
			 completeBlock:(VLBlockVoid)completeBlock
{
	VLMessageCenter_WaitArgs *args = [[[VLMessageCenter_WaitArgs alloc] init] autorelease];
	args.blockCheck = [[checkBlock copy] autorelease];
	args.ignoreTouches = ignoringTouches;
	args.blockVoid = [[completeBlock copy] autorelease];
	if(ignoringTouches)
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[self waitForFlagStep1:args];
}

- (void)dealloc
{
	[_messengers release];
	[super dealloc];
}

@end






