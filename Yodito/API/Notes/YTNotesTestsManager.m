
#import "YTNotesTestsManager.h"

static YTNotesTestsManager *_shared;

@implementation YTNotesTestsManager

+ (YTNotesTestsManager *)shared {
	if(!_shared)
		_shared = [YTNotesTestsManager new];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)addTestNote {
	
}

- (void)performTest {
	//[self addTestNote];
}

- (void)dealloc {
	[super dealloc];
}

@end

