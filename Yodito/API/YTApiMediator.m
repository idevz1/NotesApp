
#import "YTApiMediator.h"
#import "Notes/Classes.h"
#import "Managers/Classes.h"

#define kSavedDataKey @"YTApiMediator"
#define kSavedDataVersion (kYTManagersBaseVersion + 4)

static YTApiMediator *_shared;

@implementation YTApiMediator

@synthesize isShowingMainView = _isShowingMainView;
@synthesize notesTableWasLoadadOnce = _notesTableWasLoadadOnce;

+ (YTApiMediator *)shared {
	if(!_shared) {
		_shared = [VLObjectFileStorage loadRootObjectWithKey:kSavedDataKey version:kSavedDataVersion];
		if(!_shared)
			_shared = [[[YTApiMediator alloc] init] autorelease];
		[_shared retain];
	}
	return _shared;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
		_shared = self;
		
		if(aDecoder) {
			
		}
		
		[[YTUsersEnManager shared].dlgtUserLoggedOut addObserver:self selector:@selector(onUserLoggedOut:)];
		
		_timer = [[VLTimer alloc] init];
		_timer.interval = 0.5;
		[_timer setObserver:self selector:@selector(onTimerEvent:)];
		_timer.enabledAlwaysFiring = YES;
		[_timer start];
		
		[self.msgrVersionChanged addObserver:self selector:@selector(onVersionChanged:)];
		_savedDataVersion = self.version;
	}
	return self;
}

- (id)init {
	return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	
}

- (void)onVersionChanged:(id)sender {
	if(_savedDataVersion != self.version) {
		[VLObjectFileStorage saveDataWithRootObject:self key:kSavedDataKey version:kSavedDataVersion];
		_savedDataVersion = self.version;
	}
}

- (void)onUserLoggedOut:(id)sender {
	
}

- (void)onTimerEvent:(id)sender {
	if(_wasDataInitialized != [self isDataInitialized]) {
		_wasDataInitialized = [self isDataInitialized];
		[self modifyVersion];
		[_timer stop];
	}
}

- (BOOL)isDataInitialized {
	return [YTDatabaseManager shared].initialized && [YTEntitiesManagersLister shared].initialized;
}

- (void)setNotesTableWasLoadadOnce:(BOOL)notesTableWasLoadadOnce {
	if(_notesTableWasLoadadOnce != notesTableWasLoadadOnce) {
		_notesTableWasLoadadOnce = notesTableWasLoadadOnce;
		[self modifyVersion];
	}
}

- (void)dealloc {
	[_timer release];
	[super dealloc];
}

@end
