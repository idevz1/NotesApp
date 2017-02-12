
#import "VLCachedDataFileStorage.h"
#import "../System/Classes.h"

#define kFileExt @"dat"
#define kDefaultClearDiskInterval 5.0
#define kTimerIntervalMultiplier 1.0

@implementation VLCachedDataFileStorageArgs

@synthesize sHash = _sHash;
@synthesize data = _data;
@synthesize filePathOuter = _filePathOuter;
@synthesize filePathInner = _filePathInner;
@synthesize doNotLoadData = _doNotLoadData;
@synthesize error = _error;
@synthesize cancelable = _cancelable;

- (void)dealloc {
	[_sHash release];
	[_data release];
	[_filePathOuter release];
	[_filePathInner release];
	[_error release];
	[super dealloc];
}

@end


@implementation VLCachedDataFileStorage_FileInfo

@synthesize sHash;
@synthesize timestamp;
@synthesize fileSize;

@end


@implementation VLCachedDataFileStorage

@synthesize dlgtDataSaved = _dlgtDataSaved;
@synthesize dlgtDataLoaded = _dlgtDataLoaded;
@synthesize clearDiskInterval = _clearDiskInterval;

- (id)initWithDirPath:(NSString *)dirPath {
	self = [super init];
	if(self) {
		_dirPath = [dirPath copy];
		[[VLFileManager shared] forceDir:_dirPath error:nil];
		
		_queueToSave = [[NSMutableArray alloc] init];
		_queueSaved = [[NSMutableArray alloc] init];
		_threadSave = [NSThread alloc];
		[_threadSave initWithTarget:self selector:@selector(threadFuncSave:) object:self];
		_dlgtDataSaved = [[VLDelegate alloc] init];
		_dlgtDataSaved.owner = self;
		
		_dlgtDataLoaded = [[VLDelegate alloc] init];
		_dlgtDataLoaded.owner = self;
		_queueToLoad = [[NSMutableArray alloc] init];
		_queueLoaded = [[NSMutableArray alloc] init];
		_threadLoad = [NSThread alloc];
		[_threadLoad initWithTarget:self selector:@selector(threadFuncLoad:) object:self];
		
		_timer = [[VLTimer alloc] init];
		[_timer setObserver:self selector:@selector(timerEvent:)];
		_timer.enabledAlwaysFiring = YES;
		_timer.interval = 0.1 * kTimerIntervalMultiplier;
		
		_clearDiskInterval = kDefaultClearDiskInterval;
		_threadClearDisk = [NSThread alloc];
		[_threadClearDisk initWithTarget:self selector:@selector(threadFuncClearDisk:) object:self];
		[_threadClearDisk start];
		
		_needsClearing = YES;
	}
	return self;
}

- (void)setBlockBeforeClearDisk:(VLCachedDataFileStorage_BlockBeforeClearDisk)blockBeforeClearDisk callOnMainThread:(BOOL)callOnMainThread {
	if(_blockBeforeClearDisk) {
		Block_release(blockBeforeClearDisk);
		_blockBeforeClearDisk = nil;
	}
	if(blockBeforeClearDisk) {
		_blockBeforeClearDisk = Block_copy(blockBeforeClearDisk);
	}
	_callBlockBeforeClearDiskOnMainThread = callOnMainThread;
}

- (void)setBlockBeforeClearDisk:(VLCachedDataFileStorage_BlockBeforeClearDisk)blockBeforeClearDisk {
	[self setBlockBeforeClearDisk:blockBeforeClearDisk callOnMainThread:YES];
}

- (NSString *)pathToDataByHash:(NSString *)sHash {
	NSString *fName = [_dirPath stringByAppendingPathComponent:sHash];
	NSString *fPath = [fName stringByAppendingPathExtension:kFileExt];
	return fPath;
}

- (void)startSaveData:(NSData *)data orDataFromFile:(NSString *)dataFilePath withHash:(NSString *)sHash {
	if([NSString isEmpty:sHash] || (!data && [NSString isEmpty:dataFilePath]))
		return;
	[self onAccessed];
	VLCachedDataFileStorageArgs *args = [[VLCachedDataFileStorageArgs alloc] init];
	args.data = data;
	args.sHash = sHash;
	args.filePathOuter = dataFilePath;
	@synchronized(_queueToSave) {
		[_queueToSave addObject:args];
	}
	[args release];
	if(![_threadSave isExecuting])
		[_threadSave start];
	if(!_timer.started)
		[_timer start];
}

- (VLCachedDataFileStorageArgs *)loadDataByHash:(NSString *)sHash
			 doNotLoadData:(BOOL)doNotLoadData
				notExisted:(BOOL *)notExisted
		  startedLoadAsync:(BOOL *)startedLoadAsync
{
	[self onAccessed];
	*notExisted = NO;
	*startedLoadAsync = NO;
	if([NSString isEmpty:sHash]) {
		*notExisted = YES;
		return nil;
	}
	NSMutableArray *infos = [NSMutableArray array];
	@synchronized(_queueToSave) {
		[infos addObjectsFromArray:_queueToSave];
	}
	for(VLCachedDataFileStorageArgs *args in infos) {
		if([args.sHash isEqual:sHash] && args && !doNotLoadData)
			return args;
	}
	[infos removeAllObjects];
	@synchronized(_queueSaved) {
		[infos addObjectsFromArray:_queueSaved];
	}
	for(VLCachedDataFileStorageArgs *args in infos) {
		if([args.sHash isEqual:sHash] && args)
			return args;
	}
	[infos removeAllObjects];
	@synchronized(_queueLoaded) {
		[infos addObjectsFromArray:_queueLoaded];
	}
	for(VLCachedDataFileStorageArgs *args in infos) {
		if([args.sHash isEqual:sHash] && args)
			return args;
	}
	[infos removeAllObjects];
	@synchronized(_queueToLoad) {
		[infos addObjectsFromArray:_queueToLoad];
	}
	for(VLCachedDataFileStorageArgs *args in infos) {
		if([args.sHash isEqual:sHash]) {
			*startedLoadAsync = YES;
			return nil;
		}
	}
	NSString *path = [self pathToDataByHash:sHash];
	if(![[VLFileManager shared] fileExists:path]) {
		*notExisted = YES;
		return nil;
	}
	VLCachedDataFileStorageArgs *newInfo = [[[VLCachedDataFileStorageArgs alloc] init] autorelease];
	newInfo.sHash = sHash;
	newInfo.doNotLoadData = doNotLoadData;
	if(doNotLoadData) {
		newInfo.filePathInner = path;
		[[VLFileManager shared] setModifiedDate:[NSDate date] toPath:path];
		*startedLoadAsync = NO;
		return newInfo;
	}
	@synchronized(_queueToLoad) {
		[_queueToLoad addObject:newInfo];
	}
	*startedLoadAsync = YES;
	if(![_threadLoad isExecuting])
		[_threadLoad start];
	if(!_timer.started)
		[_timer start];
	return nil;
}

- (void)threadFuncSave:(id)obj {
	while(![_threadSave isCancelled])
	{
		VLCachedDataFileStorageArgs *args = nil;
		if([_queueToSave count]) {
			@synchronized(_queueToSave) {
				if([_queueToSave count]) {
					args = [_queueToSave objectAtIndex:0];
					[args retain];
				}
			}
		}
		if(args) {
			NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
			NSString *path = [self pathToDataByHash:args.sHash];
			NSError *err = nil;
			if(args.data)
				[args.data writeToFile:path options:NSDataWritingAtomic error:&err];
			else if(![NSString isEmpty:args.filePathOuter]) {
				NSString *pathMediate = [NSTemporaryDirectory() stringByAppendingPathComponent:[[VLGuid makeUnique] toString]];
				pathMediate = [pathMediate stringByAppendingPathExtension:@"dat"];
				[[NSFileManager defaultManager] copyItemAtPath:args.filePathOuter toPath:pathMediate error:&err];
				if(!err) {
					[[NSFileManager defaultManager] moveItemAtPath:pathMediate toPath:path error:&err];
				}
			} else
				err = [NSError makeWithText:@"No data to save"];
			if(err) {
				VLLogError([err localizedDescription]);
			} else {
				args.filePathInner = path;
			}
			@synchronized(_queueToSave) {
				@synchronized(_queueSaved) {
					[_queueSaved addObject:args];
					[_queueToSave removeObjectAtIndex:0];
				}
			}
			[args release];
			[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
			[arpool drain];
			_needsClearing = YES;
			continue;
		}
		[NSThread sleepForTimeInterval:0.1 * kTimerIntervalMultiplier];
	}
}

- (void)threadFuncLoad:(id)obj {
	while(![_threadLoad isCancelled]) {
		VLCachedDataFileStorageArgs *args = nil;
		if([_queueToLoad count]) {
			@synchronized(_queueToLoad) {
				if([_queueToLoad count]) {
					args = [_queueToLoad objectAtIndex:0];
					[args retain];
				}
			}
		}
		if(args) {
			NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
			VLFileManager *fileManr = [VLFileManager shared];
			NSString *path = [self pathToDataByHash:args.sHash];
			if(!args.doNotLoadData)
				args.data = [NSData dataWithContentsOfFile:path];
			args.filePathInner = path;
			[fileManr setModifiedDate:[NSDate date] toPath:path];
			@synchronized(_queueToLoad) {
				@synchronized(_queueLoaded) {
					[_queueLoaded addObject:args];
					[_queueToLoad removeObjectAtIndex:0];
				}
			}
			[args release];
			[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
			[arpool drain];
			continue;
		}
		[NSThread sleepForTimeInterval:0.1 * kTimerIntervalMultiplier];
	}
}

- (void)onBeforeClearDisk:(NSArray *)objects {
	NSArray *arrFileInfo = [objects objectAtIndex:0];
	NSMutableArray *outArrFileInfoToDelete = [objects objectAtIndex:1];
	if(_blockBeforeClearDisk)
		_blockBeforeClearDisk(arrFileInfo, outArrFileInfoToDelete);
}

- (NSArray *)getAllDataHashes {
	[self onAccessed];
	NSMutableArray *result = [NSMutableArray array];
	VLFileManager *manrFiles = [VLFileManager shared];
	NSArray *files = [manrFiles filesInDirectory:_dirPath error:nil];
	for(NSString *filePath in files) {
		NSString *sHash = [self hashFromFilePath:filePath];
		if([NSString isEmpty:sHash])
			continue;
		[result addObject:sHash];
	}
	return result;
}

- (void)threadFuncClearDisk:(id)obj {
	while(![_threadClearDisk isCancelled]) {
		if(_needsClearing) {
			_needsClearing = NO;
			NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
			VLFileManager *manrFiles = [VLFileManager shared];
			NSArray *files = [manrFiles filesInDirectory:_dirPath error:nil];
			NSMutableArray *arrFileInfo = [NSMutableArray array];
			NSMutableArray *outArrFileInfoToDelete = [NSMutableArray array];
			for(NSString *filePath in files) {
				VLCachedDataFileStorage_FileInfo *info = [[[VLCachedDataFileStorage_FileInfo alloc] init] autorelease];
				info.sHash = [self hashFromFilePath:filePath];
				if([NSString isEmpty:info.sHash])
					continue;
				info.timestamp = [manrFiles modifiedDate:filePath];
				info.fileSize = [manrFiles fileSize:filePath];
				[arrFileInfo addObject:info];
			}
			if(_blockBeforeClearDisk) {
				if(_callBlockBeforeClearDiskOnMainThread) {
					[self performSelectorOnMainThread:@selector(onBeforeClearDisk:)
									   withObject:[NSArray arrayWithObjects:arrFileInfo, outArrFileInfoToDelete, nil] waitUntilDone:YES];
				} else {
					[self onBeforeClearDisk:[NSArray arrayWithObjects:arrFileInfo, outArrFileInfoToDelete, nil]];
				}
			}
			for(VLCachedDataFileStorage_FileInfo *info in outArrFileInfoToDelete) {
				NSString *filePath = [self pathToDataByHash:info.sHash];
				[manrFiles deleteFileOrDir:filePath error:nil];
			}
			[arpool drain];
		}
		[NSThread sleepForTimeInterval:_clearDiskInterval];
	}
}

- (void)update {
	while(YES) {
		VLCachedDataFileStorageArgs *args = nil;
		@synchronized(_queueSaved) {
			if([_queueSaved count]) {
				args = [_queueSaved objectAtIndex:0];
			}
		}
		if(args) {
			[_dlgtDataSaved sendMessage:self withArgs:args];
			@synchronized(_queueSaved) {
				[_queueSaved removeObjectAtIndex:0];
			}
		}
		else
			break;
	}
	while(YES) {
		VLCachedDataFileStorageArgs *args = nil;
		@synchronized(_queueLoaded) {
			if([_queueLoaded count]) {
				args = [_queueLoaded objectAtIndex:0];
			}
		}
		if(args) {
			[_dlgtDataLoaded sendMessage:self withArgs:args];
			@synchronized(_queueLoaded) {
				[_queueLoaded removeObjectAtIndex:0];
			}
		}
		else
			break;
	}
}

- (NSString *)hashFromFilePath:(NSString*)filePath
{
	NSString *sExt = [filePath pathExtension];
	if([sExt compare:kFileExt] != NSOrderedSame)
		return nil;
	NSString* sFileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
	if([NSString isEmpty:sFileName])
		return nil;
	return sFileName;
}

- (BOOL)containsDataWithHash:(NSString *)sHash {
	[self onAccessed];
	NSString *path = [self pathToDataByHash:sHash];
	VLFileManager *fileManr = [VLFileManager shared];
	if([fileManr fileExists:path])
		return YES;
	return NO;
}

- (NSData *)getDataSynchronousWithHash:(NSString *)sHash {
	[self onAccessed];
	NSString *path = [self pathToDataByHash:sHash];
	VLFileManager *fileManr = [VLFileManager shared];
	if(![fileManr fileExists:path])
		return nil;
	NSData *data = [NSData dataWithContentsOfFile:path];
	return data;
}

- (NSString *)filePathToDataWithHash:(NSString *)sHash {
	[self onAccessed];
	NSString *path = [self pathToDataByHash:sHash];
	VLFileManager *fileManr = [VLFileManager shared];
	if(![fileManr fileExists:path])
		return @"";
	return path;
}

- (void)deleteDataWithHash:(NSString *)sHash {
	[self onAccessed];
	VLFileManager *manrFiles = [VLFileManager shared];
	NSString *filePath = [self pathToDataByHash:sHash];
	[manrFiles deleteFileOrDir:filePath error:nil];
}

- (void)timerEvent:(id)sender {
	[self update];
}

- (void)onAccessed {
	_needsClearing = YES;
}

- (void)dealloc {
	[_threadSave cancel];
	[_threadSave release];
	[_threadLoad cancel];
	[_threadLoad release];
	[_dirPath release];
	[_timer release];
	[_queueToSave release];
	[_queueSaved release];
	[_queueToLoad release];
	[_queueLoaded release];
	[_dlgtDataLoaded release];
	if(_blockBeforeClearDisk)
		Block_release(_blockBeforeClearDisk);
	[_threadClearDisk cancel];
	[_threadClearDisk release];
	[_dlgtDataSaved release];
	[super dealloc];
}

@end

