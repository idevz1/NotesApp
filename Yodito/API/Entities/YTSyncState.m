
#import "YTSyncState.h"

@implementation YTSyncState

@synthesize currentTime = _currentTime;
@synthesize chunkHighTS = _chunkHighTS;
@synthesize uploaded = _uploaded;

- (id)iinit {
	self = [super init];
	if(self) {
		_currentTime = [[VLDate empty] retain];
		_chunkHighTS = [[VLDate empty] retain];
		_uploaded = 0;
	}
	return self;
}

- (void)setCurrentTime:(VLDate *)currentTime {
	if(!currentTime)
		currentTime = [VLDate empty];
	if(![_currentTime isEqual:currentTime]) {
		[_currentTime release];
		_currentTime = [currentTime retain];
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setChunkHighTS:(VLDate *)chunkHighTS {
	if(!chunkHighTS)
		chunkHighTS = [VLDate empty];
	if(![_chunkHighTS isEqual:chunkHighTS]) {
		[_chunkHighTS release];
		_chunkHighTS = [chunkHighTS retain];
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setUploaded:(int64_t)uploaded {
	if(_uploaded != uploaded) {
		_uploaded = uploaded;
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.uploaded = [data int64ValueForKey:kYTJsonKeyuploaded defaultVal:0];
	NSString *sCurrentTime = [data stringValueForKey:kYTJsonKeycurrentTime defaultVal:@""];
	self.currentTime = [VLDate yoditoDateWithString:sCurrentTime];
	NSString *sChunkHighTS = [data stringValueForKey:kYTJsonKeychunkHighTS defaultVal:@""];
	self.chunkHighTS = [VLDate yoditoDateWithString:sChunkHighTS];
}

- (void)dealloc {
	[_currentTime release];
	[_chunkHighTS release];
	[super dealloc];
}

@end

