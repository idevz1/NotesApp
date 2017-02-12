
#import "VLPeriodicalReminderBase.h"

#define kDataVersion 2
#define kInitialDateKey(sId, version) [NSString stringWithFormat:@"VLPeriodicalReminderBase_kInitialDateKey_%@_%d_%d", sId, version, kDataVersion]
#define kLastAskDateKey(sId, version) [NSString stringWithFormat:@"VLPeriodicalReminderBase_kLastAskDateKey_%@_%d_%d", sId, version, kDataVersion]

@implementation VLPeriodicalReminderBaseArgs

@synthesize resultBlock;

- (void)dealloc {
	if(_resultBlock)
		Block_release(_resultBlock);
	[super dealloc];
}

@end


@implementation VLPeriodicalReminderBase

@synthesize dlgtRemindering = _dlgtRemindering;

- (id)initWithId:(NSString *)sId
		minDelay:(double)minDelay
	 askInterval:(double)askInterval
		 version:(int)version {
	self = [super init];
	if(self) {
		_version = version;
		_sId = [sId copy];
		_minDelay = minDelay;
		_askInterval = askInterval;
		_dlgtRemindering = [[VLDelegate alloc] init];
		_dlgtRemindering.owner = self;
		
		_timer = [[VLTimer alloc] init];
		[_timer setObserver:self selector:@selector(timerEvent:)];
		_timer.interval = 1.0;
		[_timer start];
		
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSString *initDateKey = kInitialDateKey(_sId, _version);
		id obj = [defs objectForKey:initDateKey];
		if(!obj) {
			[defs setDouble:[[NSDate date] timeIntervalSinceReferenceDate] forKey:initDateKey];
			[defs synchronize];
		}
	}
	return self;
}

- (void)performRemindering {
	if(_remindering)
		return;
	_remindering = YES;
	VLPeriodicalReminderBaseArgs *args = [[[VLPeriodicalReminderBaseArgs alloc] init] autorelease];
	args.resultBlock = ^() {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		[defs setDouble:[[NSDate date] timeIntervalSinceReferenceDate] forKey:kLastAskDateKey(_sId, _version)];
		[defs synchronize];
		_remindering = NO;
	};
	[_dlgtRemindering sendMessage:self withArgs:args];
}

- (void)timerEvent:(id)sender {
	if(!_remindering) {
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSDate *initialDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[defs doubleForKey:kInitialDateKey(_sId, _version)]];
		NSDate *lastAskDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[defs doubleForKey:kLastAskDateKey(_sId, _version)]];
		NSDate *now = [NSDate date];
		double timeSinceInit = [now timeIntervalSinceDate:initialDate];
		double timeSinceLastAsk = [now timeIntervalSinceDate:lastAskDate];
		BOOL needAsk = NO;
		if(timeSinceInit >= _minDelay) {
			if(timeSinceLastAsk >= _askInterval) {
				needAsk = YES;
			}
		}
		if(needAsk)
			[self performRemindering];
	}
}

- (void)dealloc {
	[_timer release];
	[_sId release];
	[_dlgtRemindering release];
	[super dealloc];
}

@end
