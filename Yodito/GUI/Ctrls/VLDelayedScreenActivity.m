
#import "VLDelayedScreenActivity.h"
#import "../../API/Classes.h"

@implementation VLDelayedScreenActivity

- (id)init {
	self = [super init];
	if(self) {
		[[YTDatabaseManager shared] checkIsMainThread];
	}
	return self;
}

- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay maxDuration:(NSTimeInterval)maxDuration checkForCancelBlock:(VLBlockCheck)checkForCancelBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	[self cancelActivity];
	_activityShowDelay = delay;
	_maxDuration = maxDuration;
	[_title release];
	_title = nil;
	if(title)
		_title = [title copy];
	if(_timer) {
		[_timer stop];
		[_timer release];
		_timer = nil;
	}
	if(checkForCancelBlock)
		_checkForCancelBlock = Block_copy(checkForCancelBlock);
	_timer = [[VLTimer alloc] init];
	_timer.interval = 0.05;
	_timer.enabledAlwaysFiring = YES;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	_uptimeStart = [VLTimer systemUptime];
	[_timer start];
	if(!_started) {
		_started = YES;
		//[self retain];
	}
}

- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay checkForCancelBlock:(VLBlockCheck)checkForCancelBlock {
	[self startActivityWithTitle:title delay:delay maxDuration:0 checkForCancelBlock:checkForCancelBlock];
}

- (void)startActivityWithTitle:(NSString *)title delay:(NSTimeInterval)delay {
	[self startActivityWithTitle:title delay:delay checkForCancelBlock:nil];
}

- (void)onTimerEvent:(id)sender {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(_checkForCancelBlock) {
		[self retain];
		BOOL result = _checkForCancelBlock();
		if(result) {
			[self cancelActivity];
			[self release];
			return;
		}
		[self release];
	}
	NSTimeInterval uptime = [VLTimer systemUptime];
	if(!_activityShown) {
		if(uptime >= _uptimeStart + _activityShowDelay) {
			_activityShown = YES;
			[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
			[[VLActivityScreen shared] startActivityWithTitle:_title];
		}
	}
}

- (void)cancelActivity {
	if(_timer) {
		[[YTDatabaseManager shared] checkIsMainThread];
		[_timer stop];
		[_timer release];
		_timer = nil;
	}
	if(_activityShown) {
		[[YTDatabaseManager shared] checkIsMainThread];
		_activityShown = NO;
		[[VLActivityScreen shared] stopActivity];
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
	if(_checkForCancelBlock) {
		Block_release(_checkForCancelBlock);
		_checkForCancelBlock = nil;
	}
	if(_started) {
		_started = NO;
		//[self autorelease];
	}
}

- (BOOL)isMaxDurationExceeded {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(!_started || !_maxDuration)
		return NO;
	NSTimeInterval uptime = [VLTimer systemUptime];
	if(uptime >= _uptimeStart + _maxDuration)
		return YES;
	return NO;
}

- (id)retain {
	return [super retain];
}

- (oneway void)release {
	[super release];
}

- (id)autorelease {
	return [super autorelease];
}

- (void)dealloc {
	[self cancelActivity];
	if(_checkForCancelBlock) {
		Block_release(_checkForCancelBlock);
		_checkForCancelBlock = nil;
	}
	if(_timer) {
		[_timer stop];
		[_timer release];
		_timer = nil;
	}
	[_title release];
	[super dealloc];
}

@end

