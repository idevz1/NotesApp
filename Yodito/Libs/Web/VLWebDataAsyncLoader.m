
#import "VLWebDataAsyncLoader.h"
#import "VLHttpWebRequest.h"
#import "../Common/Classes.h"

@implementation VLWebDataAsyncLoaderArgs

@synthesize url = _url;
@synthesize sHash = _sHash;
@synthesize downloadDataToFile = _downloadDataToFile;
@synthesize data = _data;
@synthesize dataFilePath = _dataFilePath;
@synthesize error = _error;
@synthesize cancelable = _cancelable;

- (void)dealloc {
	[_url release];
	[_sHash release];
	[_data release];
	[_dataFilePath release];
	[_error release];
	[super dealloc];
}

@end


@implementation VLWebDataAsyncLoader

@synthesize dlgtDataLoaded = _dlgtDataLoaded;
@synthesize loadingDataCount = _loadingDataCount;

- (id)init {
	self = [super init];
	if(self) {
		_queueToLoad = [[NSMutableArray alloc] init];
		_queueLoading = [[NSMutableArray alloc] init];
		_queueLoaded = [[NSMutableArray alloc] init];
		_dlgtDataLoaded = [[VLDelegate alloc] init];
		_dlgtDataLoaded.owner = self;
		_maxConcurrentOperationCount = 1;
		
		[self setBlockLoader:^(VLWebDataAsyncLoaderArgs *args, VLWebDataAsyncLoaderBlockLoaderResult resultBlock) {
			args.error = [NSError makeWithText:@"Not implemented"];
			resultBlock(args);
		}];
	}
	return self;
}

- (void)checkTrimerStarted {
	if(!_timer) {
		_timer = [[VLTimer alloc] init];
		[_timer setObserver:self selector:@selector(onTimerEvent:)];
		_timer.enabledAlwaysFiring = YES;
		_timer.interval = 0.1;
		[_timer start];
	}
}

- (void)setMaxConcurrentOperationCount:(int)cnt {
	_maxConcurrentOperationCount = MAX(cnt, 1);
}

- (void)setBlockLoader:(VLWebDataAsyncLoaderBlockLoader)blockLoader {
	if(_blockLoader) {
		Block_release(_blockLoader);
		_blockLoader = nil;
	}
	if(blockLoader) {
		_blockLoader = Block_copy(blockLoader);
	}
}

- (void)startDownloadDataWithUrl:(NSString *)url sHash:(NSString *)sHash downloadDataToFile:(BOOL)downloadDataToFile {
	if([self containsDataWithUrl:url sHash:sHash])
		return;
	[self checkTrimerStarted];
	VLWebDataAsyncLoaderArgs *args = [[[VLWebDataAsyncLoaderArgs alloc] init] autorelease];
	args.url = url;
	args.sHash = sHash;
	args.downloadDataToFile = downloadDataToFile;
	[_queueToLoad addObject:args];
	[self updateStatistics];
}

- (void)startDownloadDataWithUrl:(NSString *)url sHash:(NSString *)sHash {
	[self startDownloadDataWithUrl:url sHash:sHash downloadDataToFile:NO];
}

- (BOOL)containsDataWithUrl:(NSString *)url sHash:(NSString *)sHash {
	for(VLWebDataAsyncLoaderArgs *obj in _queueToLoad) {
		if([obj.url isEqual:url] && [obj.sHash isEqual:sHash])
			return YES;
	}
	for(VLWebDataAsyncLoaderArgs *obj in _queueLoading) {
		if([obj.url isEqual:url] && [obj.sHash isEqual:sHash])
			return YES;
	}
	for(VLWebDataAsyncLoaderArgs *obj in _queueLoaded) {
		if([obj.url isEqual:url] && [obj.sHash isEqual:sHash])
			return YES;
	}
	return NO;
}

- (void)cancelRequestWithUrl:(NSString *)url sHash:(NSString *)sHash {
	for(VLWebDataAsyncLoaderArgs *obj in _queueToLoad) {
		if([obj.url isEqual:url] && [obj.sHash isEqual:sHash]) {
			[_queueToLoad removeObject:obj];
			[self updateStatistics];
			break;
		}
	}
	for(VLWebDataAsyncLoaderArgs *obj in _queueLoaded) {
		if([obj.url isEqual:url] && [obj.sHash isEqual:sHash]) {
			[_queueToLoad removeObject:obj];
			[self updateStatistics];
			break;
		}
	}
	for(VLWebDataAsyncLoaderArgs *obj in _queueLoading) {
		if([obj.url isEqual:url] && [obj.sHash isEqual:sHash]) {
			[[obj retain] autorelease];
			[_queueLoading removeObject:obj];
			[self updateStatistics];
			if(obj.cancelable)
				[obj.cancelable cancel];
			break;
		}
	}
}

- (void)updateStatistics {
	int loadingDataCount = (int)(_queueToLoad.count + _curOperationsCount + _queueLoaded.count);
	if(_loadingDataCount != loadingDataCount) {
		_loadingDataCount = loadingDataCount;
		[self modifyVersion];
	}
}

- (void)onTimerEvent:(id)sender {
	VLWebDataAsyncLoaderArgs *args = nil;
	
	do {
		args = nil;
		if(_curOperationsCount < _maxConcurrentOperationCount) {
			if(_queueToLoad.count) {
				args = [_queueToLoad objectAtIndex:0];
				[_queueLoading addObject:args];
				[_queueToLoad removeObjectAtIndex:0];
			}
			if(args) {
				_curOperationsCount++;
				_blockLoader(args, ^(VLWebDataAsyncLoaderArgs *argsLocal) {
					[_queueLoaded addObject:argsLocal];
					[_queueLoading removeObject:argsLocal];
					_curOperationsCount--;
				});
			}
		}
	}
	while(args);

	do {
		args = nil;
		if(_queueLoaded.count) {
			@synchronized(_queueLoaded) {
				if(_queueLoaded.count) {
					args = [_queueLoaded objectAtIndex:0];
					[args retain];
					[_queueLoaded removeObjectAtIndex:0];
					[self updateStatistics];
				}
			}
		}
		if(args) {
			[_dlgtDataLoaded sendMessage:self withArgs:args];
			[args release];
		}
	}
	while(args);
}

- (void)dealloc {
	[_queueToLoad release];
	[_queueLoaded release];
	[_queueLoading release];
	[_dlgtDataLoaded release];
	[_timer release];
	if(_blockLoader)
		Block_release(_blockLoader);
	[super dealloc];
}

@end
