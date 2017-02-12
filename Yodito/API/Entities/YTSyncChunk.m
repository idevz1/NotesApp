
#import "YTSyncChunk.h"

@implementation YTSyncChunk

@synthesize currentTime = _currentTime;
@synthesize chunkHighTS = _chunkHighTS;
@synthesize lastUpdatedTS = _lastUpdatedTS;
@synthesize notes = _notes;
@synthesize notebooks = _notebooks;
@synthesize tags = _tags;
@synthesize resources = _resources;
@synthesize linkedNotebooks = _linkedNotebooks;

- (id)iinit {
	self = [super init];
	if(self) {
		_currentTime = [[VLDate empty] retain];
		_chunkHighTS = [[VLDate empty] retain];
		_lastUpdatedTS = [[VLDate empty] retain];
		_notes = [NSMutableArray new];
		_notebooks = [NSMutableArray new];
		_tags = [NSMutableArray new];
		_resources = [NSMutableArray new];
		_linkedNotebooks = [NSMutableArray new];
	}
	return self;
}

- (void)dealloc {
	[_currentTime release];
	[_chunkHighTS release];
	[_lastUpdatedTS release];
	[_notes release];
	[_notebooks release];
	[_tags release];
	[_resources release];
	[_linkedNotebooks release];
	[super dealloc];
}

@end

