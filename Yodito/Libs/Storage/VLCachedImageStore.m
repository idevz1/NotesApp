
#import "VLCachedImageStore.h"
#import "../System/Classes.h"

#define kBaseVersion 23
#define kCachedImageStoreDirName @"CachedImageStore"
#define kImageExtension @"jpg"
#define kDefaultImageQuality 1.0
#define kDefaultDiskSpaceLimit (32 * 1024 * 1024)
#define kMinDiskSpaceLimit (1 * 1024 * 1024)
#define kMaxDiskSpaceLimit (100 * 1024 * 1024)
#define kVersionKey(version) ([NSString stringWithFormat:@"%@_%@_%d", @"CachedImageStore_kVersionKey_3", NSStringFromClass([self class]), version])
#define kDiskSpaceLimitKey(version) ([NSString stringWithFormat:@"%@_%@_%d", @"CachedImageStore_kDiskSpaceLimitKey_3", NSStringFromClass([self class]), version])
#define kCheckDiskSpaceInterval 10.0

#define kUseTempDirToStore YES//NO




@implementation VLCachedImageStore_ImageInfo

@synthesize image = _image;
@synthesize sHash = _sHash;
@synthesize filePathOuter = _filePathOuter;
@synthesize filePathInner = _filePathInner;
@synthesize doNotLoadData = _doNotLoadData;

- (id)init
{
	self = [super init];
	if(self) {
	}
	return self;
}

- (void)dealloc {
	[_image release];
	[_sHash release];
	[_filePathOuter release];
	[_filePathInner release];
	[super dealloc];
}

@end





@implementation VLCachedImageStore

@synthesize ntfrImageLoaded = _ntfrImageLoaded;
@dynamic diskSpaceLimit;
@dynamic minDiskSpaceLimit;
@dynamic maxDiskSpaceLimit;

- (id)initWithDirName:(NSString *)dirName version:(int)version allowAutoDelete:(BOOL)allowAutoDelete
{
	self = [super init];
	if(self)
	{
		_version = kBaseVersion + kVLCurManagersVersion + version;
		_allowAutoDelete = allowAutoDelete;
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSString *key = kDiskSpaceLimitKey(_version);
		_diskSpaceLimit = [defs integerForKey:key];
		if(!_diskSpaceLimit)
			_diskSpaceLimit = kDefaultDiskSpaceLimit;
		
		_dirName = [dirName copy];
		VLFileManager *fileManager = [VLFileManager shared];
		NSString *rootDir = nil;
		if(kUseTempDirToStore)
		{
			NSString *tempDirectory = NSTemporaryDirectory();
			rootDir = tempDirectory;
		}
		else {
			NSString *pathDirDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
			rootDir = pathDirDocuments;
		}
		_dirPath = [[rootDir stringByAppendingPathComponent:_dirName] retain];
		if(kVLLogEvents)
			NSLog(@"CachedImageStoreBase: initWithDirName: _dirPath = %@", _dirPath);
		[fileManager forceDir:_dirPath error:nil];
		
		_queueToSave = [[NSMutableArray alloc] init];
		_threadSave = [NSThread alloc];
		[_threadSave initWithTarget:self selector:@selector(threadFuncSave:) object:self];
		
		_ntfrImageLoaded = [[VLDelegate alloc] init];
		_queueToLoad = [[NSMutableArray alloc] init];
		_queueLoaded = [[NSMutableArray alloc] init];
		_threadLoad = [NSThread alloc];
		[_threadLoad initWithTarget:self selector:@selector(threadFuncLoad:) object:self];
		
		_timer = [[VLTimer alloc] init];
		[_timer setObserver:self selector:@selector(timerEvent:)];
		_timer.interval = kCheckDiskSpaceInterval;
		_timer.enabledAlwaysFiring = YES;
		[_timer start];
		
		key = kVersionKey(_version);
		int curVersion = (int)[defs integerForKey:key];
		if(curVersion != _version)
		{
			[defs setInteger:_version forKey:key];
			[defs synchronize];
			VLFileManager *fileManager = [VLFileManager shared];
			[fileManager deleteFileOrDir:_dirPath error:nil];
			[fileManager forceDir:_dirPath error:nil];
		}
		
		if(_allowAutoDelete) {
			_threadCheckDiskSpace = [NSThread alloc];
			[_threadCheckDiskSpace initWithTarget:self selector:@selector(threadFuncCheckDiskSpace:) object:self];
			//[_threadCheckDiskSpace setThreadPriority:0.25];
		}
		
		[_threadLoad start];
		[_threadSave start];
		if(_threadCheckDiskSpace)
			[_threadCheckDiskSpace start];
	}
	return self;
}

- (id)initWithDirName:(NSString *)dirName version:(int)version {
	return [self initWithDirName:dirName version:version allowAutoDelete:YES];
}

- (int64_t)diskSpaceLimit
{
	return _diskSpaceLimit;
}
- (void)setDiskSpaceLimit:(int64_t)value
{
	if(value < [self minDiskSpaceLimit])
		value = [self minDiskSpaceLimit];
	if(value > [self maxDiskSpaceLimit])
		value = [self maxDiskSpaceLimit];
	if(_diskSpaceLimit != value)
	{
		_diskSpaceLimit = value;
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		[defs setInteger:_diskSpaceLimit forKey:kDiskSpaceLimitKey(_version)];
		[defs synchronize];
	}
}

- (int64_t)minDiskSpaceLimit
{
	return kMinDiskSpaceLimit;
}
- (int64_t)maxDiskSpaceLimit
{
	return kMaxDiskSpaceLimit;
}

- (NSString*)pathToImageByHash:(NSString *)sHash
{
	NSString *fName = [_dirPath stringByAppendingPathComponent:sHash];
	NSString *fPath = [fName stringByAppendingPathExtension:kImageExtension];
	return fPath;
}

- (VLCachedImageStore_ImageInfo *)startSaveImage:(UIImage *)image
   orImageFromFilePath:(NSString *)filePath
			  withHash:(NSString *)sHash
		   synchronous:(BOOL)synchronous
{
	if([NSString isEmpty:sHash] || (!image && [NSString isEmpty:filePath]))
		return nil;
	VLCachedImageStore_ImageInfo *info = [[VLCachedImageStore_ImageInfo alloc] init];
	info.image = image;
	info.sHash = sHash;
	info.filePathOuter = filePath;
	if(synchronous) {
		NSError *error = nil;
		[self saveImageInfo:info
					  error:&error];
		if(error && kVLLogErrors)
			NSLog(@"ERROR: CachedImageStore: threadFuncSave: error: %@", error);
		[info autorelease];
		return info;
	}
	@synchronized(_queueToSave)
	{
		[_queueToSave addObject:info];
	}
	[info release];
	return nil;
}

- (void)startSaveImage:(UIImage *)image
   orImageFromFilePath:(NSString *)filePath
			  withHash:(NSString *)sHash
{
	[self startSaveImage:image
	 orImageFromFilePath:filePath
				withHash:sHash
			 synchronous:NO];
}

- (VLCachedImageStore_ImageInfo *)loadImageByHash:(NSString *)sHash
									doNotLoadData:(BOOL)doNotLoadData
									   notExisted:(BOOL *)notExisted
								 startedLoadAsync:(BOOL *)startedLoadAsync
{
	*notExisted = NO;
	*startedLoadAsync = NO;
	if([NSString isEmpty:sHash])
	{
		*notExisted = YES;
		return nil;
	}
	NSMutableArray *infos = [NSMutableArray array];
	@synchronized(_queueToSave)
	{
		[infos addObjectsFromArray:_queueToSave];
	}
	for(VLCachedImageStore_ImageInfo *info in infos)
	{
		if([info.sHash isEqual:sHash] && info.image && !doNotLoadData)
			return info;
	}
	[infos removeAllObjects];
	@synchronized(_queueLoaded)
	{
		[infos addObjectsFromArray:_queueLoaded];
	}
	for(VLCachedImageStore_ImageInfo *info in infos)
	{
		if([info.sHash isEqual:sHash] && (info.image || doNotLoadData))
			return info;
	}
	[infos removeAllObjects];
	@synchronized(_queueToLoad)
	{
		[infos addObjectsFromArray:_queueToLoad];
	}
	for(VLCachedImageStore_ImageInfo *info in infos)
	{
		if([info.sHash isEqual:sHash])
		{
			*startedLoadAsync = YES;
			return nil;
		}
	}
	NSString *path = [self pathToImageByHash:sHash];
	if(![[VLFileManager shared] fileExists:path]) {
		*notExisted = YES;
		return nil;
	} else if(doNotLoadData) {
		VLCachedImageStore_ImageInfo *info = [[[VLCachedImageStore_ImageInfo alloc] init] autorelease];
		info.sHash = sHash;
		info.filePathInner = path;
		info.doNotLoadData = doNotLoadData;
		return info;
	}
	VLCachedImageStore_ImageInfo *newInfo = [[[VLCachedImageStore_ImageInfo alloc] init] autorelease];
	newInfo.sHash = sHash;
	newInfo.doNotLoadData = doNotLoadData;
	@synchronized(_queueToLoad)
	{
		[_queueToLoad addObject:newInfo];
	}
	*startedLoadAsync = YES;
	return nil;
}

- (BOOL)saveImageInfo:(VLCachedImageStore_ImageInfo *)imageInfo
					error:(NSError **)pError {
	NSString *pathInner = [self pathToImageByHash:imageInfo.sHash];
	NSError *error = nil;
	if(imageInfo.image) {
		NSData *data = UIImageJPEGRepresentation(imageInfo.image, kDefaultImageQuality);
		[data writeToFile:pathInner options:NSDataWritingAtomic error:&error];
	} else if(![NSString isEmpty:imageInfo.filePathOuter]) {
		NSString *pathMediate = [NSTemporaryDirectory() stringByAppendingPathComponent:[[VLGuid makeUnique] toString]];
		pathMediate = [pathMediate stringByAppendingPathExtension:@"dat"];
		[[NSFileManager defaultManager] copyItemAtPath:imageInfo.filePathOuter toPath:pathMediate error:&error];
		if(!error) {
			[[NSFileManager defaultManager] moveItemAtPath:pathMediate toPath:pathInner error:&error];
		}
	}
	imageInfo.filePathInner = pathInner;
	if(pError)
		*pError = error;
	return !!error;
}

- (void)threadFuncSave:(id)obj
{
	while(![_threadSave isCancelled])
	{
		VLCachedImageStore_ImageInfo *imageInfo = nil;
		@synchronized(_queueToSave)
		{
			if([_queueToSave count])
			{
				imageInfo = [_queueToSave objectAtIndex:0];
				[imageInfo retain];
			}
		}
		if(imageInfo)
		{
			NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
			//NSString *path = [self pathToImageByHash:imageInfo.sHash];
			NSError *error = nil;
			[self saveImageInfo:imageInfo
						  error:&error];
			/*if(imageInfo.image) {
				NSData *data = UIImageJPEGRepresentation(imageInfo.image, kDefaultImageQuality);
				[data writeToFile:path options:NSDataWritingAtomic error:&error];
			} else if(![NSString isEmpty:imageInfo.filePath]) {
				NSString *pathMediate = [NSTemporaryDirectory() stringByAppendingPathComponent:[[VLGuid makeUnique] toString]];
				pathMediate = [pathMediate stringByAppendingPathExtension:@"dat"];
				[[NSFileManager defaultManager] copyItemAtPath:imageInfo.filePath toPath:pathMediate error:&error];
				if(!error) {
					[[NSFileManager defaultManager] moveItemAtPath:pathMediate toPath:path error:&error];
				}
			}*/
			if(error && kVLLogErrors)
				NSLog(@"ERROR: CachedImageStore: threadFuncSave: error: %@", [error localizedDescription]);
			[arpool drain];
			
			@synchronized(_queueToSave)
			{
				[_queueToSave removeObjectAtIndex:0];
			}
			[imageInfo release];
			continue;
		}
		[NSThread sleepForTimeInterval:0.1];
	}
}

- (void)threadFuncLoad:(id)obj
{
	while(![_threadLoad isCancelled])
	{
		VLCachedImageStore_ImageInfo *imageInfo = nil;
		@synchronized(_queueToLoad)
		{
			if([_queueToLoad count])
			{
				imageInfo = [_queueToLoad objectAtIndex:0];
				[imageInfo retain];
			}
		}
		if(imageInfo)
		{
			NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
			VLFileManager *fileManr = [VLFileManager shared];
			NSString *path = [self pathToImageByHash:imageInfo.sHash];
			if(!imageInfo.doNotLoadData) {
				UIImage *image = [UIImage imageWithContentsOfFile:path];
				imageInfo.image = image;
			} else {
				imageInfo.filePathInner = path;
			}
			[fileManr setModifiedDate:[NSDate date] toPath:path];
			[arpool drain];
			
			@synchronized(_queueToLoad)
			{
				@synchronized(_queueLoaded)
				{
					[_queueLoaded addObject:imageInfo];
					[_queueToLoad removeObjectAtIndex:0];
				}
			}
			[imageInfo release];
			[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
			continue;
		}
		[NSThread sleepForTimeInterval:0.1];
	}
}

- (void)update
{
	while(YES)
	{
		VLCachedImageStore_ImageInfo *imageInfo = nil;
		@synchronized(_queueLoaded)
		{
			if([_queueLoaded count])
			{
				imageInfo = [_queueLoaded objectAtIndex:0];
			}
		}
		if(imageInfo)
		{
			[_ntfrImageLoaded sendMessage:self withArgs:imageInfo];
			@synchronized(_queueLoaded)
			{
				[_queueLoaded removeObjectAtIndex:0];
			}
		}
		else
			break;
	}
}

- (NSString *)imageHashFromFilePath:(NSString *)filePath
{
	NSString *sExt = [filePath pathExtension];
	if([sExt compare:kImageExtension] != NSOrderedSame)
		return nil;
	NSString *sFileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
	if(!sFileName)
		return nil;
	NSString *sHash = sFileName;
	if(![NSString isEmpty:sHash])
		return sHash;
	return nil;
}

- (NSArray *)getAllImagesHashes {
	NSError *err = nil;
	VLFileManager *fileManr = [VLFileManager shared];
	NSArray *files = [fileManr filesInDirectory:_dirPath error:&err];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:files.count];
	for(NSString *filePath in files) {
		NSString *imageHash = [self imageHashFromFilePath:filePath];
		if([NSString isEmpty:imageHash]) {
			[fileManr deleteFileOrDir:filePath error:nil];
			continue;
		}
		[result addObject:imageHash];
	}
	return result;
}

- (void)checkDiskSpaceLimit
{
	NSMutableArray *paths = [NSMutableArray array];
	NSMutableArray *sHashs = [NSMutableArray array];
	NSMutableArray *dates = [NSMutableArray array];
	NSMutableArray *sizes = [NSMutableArray array];
	NSMutableArray *curInfos = [NSMutableArray array];
	
	NSError *err = nil;
	VLFileManager *fileManr = [VLFileManager shared];
	NSArray *files = [fileManr filesInDirectory:_dirPath error:&err];
	int64_t totalSize = 0;
	for(NSString *filePath in files)
	{
		NSString *imageHash = [self imageHashFromFilePath:filePath];
		if([NSString isEmpty:imageHash])
		{
			[fileManr deleteFileOrDir:filePath error:nil];
			continue;
		}
		[paths addObject:filePath];
		[sHashs addObject:imageHash];
		NSDate* date = [fileManr modifiedDate:filePath];
		if(!date)
			date = [NSDate dateWithTimeIntervalSince1970:0];
		[dates addObject:date];
		NSNumber *size = [NSNumber numberWithInt:[fileManr fileSize:filePath]];
		[sizes addObject:size];
		totalSize += [size intValue];
	}
	
	@synchronized(_queueToLoad)
	{
		@synchronized(_queueLoaded)
		{
			@synchronized(_queueToSave)
			{
				[curInfos addObjectsFromArray:_queueToLoad];
				[curInfos addObjectsFromArray:_queueLoaded];
				[curInfos addObjectsFromArray:_queueToSave];
			}
		}
	}
	
	while(totalSize > _diskSpaceLimit && [sHashs count])
	{
		int idxEarliest = 0;
		NSDate *dtEarliest = [dates objectAtIndex:0];
		for(int i = 1; i < [sHashs count]; i++)
		{
			NSString *imageHash = [sHashs objectAtIndex:i];
			BOOL busy = NO;
			for(VLCachedImageStore_ImageInfo *info in curInfos)
				if([info.sHash isEqual:imageHash])
					busy = YES;
			if(busy)
				continue;
			NSDate *dt = [dates objectAtIndex:i];
			if([dt timeIntervalSinceDate:dtEarliest] < 0)
			{
				idxEarliest = i;
				dtEarliest = dt;
			}
		}
		NSString *filePath = [paths objectAtIndex:idxEarliest];
		[[VLFileManager shared] deleteFileOrDir:filePath error:nil];
		totalSize -= [((NSNumber*)[sizes objectAtIndex:idxEarliest]) intValue];
		[paths removeObjectAtIndex:idxEarliest];
		[sHashs removeObjectAtIndex:idxEarliest];
		[dates removeObjectAtIndex:idxEarliest];
		[sizes removeObjectAtIndex:idxEarliest];
	}
}

- (void)threadFuncCheckDiskSpace:(id)obj
{
	while(![_threadCheckDiskSpace isCancelled])
	{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		{
			[self checkDiskSpaceLimit];
		}
        [pool release];
		
        [NSThread sleepForTimeInterval:kCheckDiskSpaceInterval];
	}
}

- (BOOL)containsImageWithHash:(NSString *)sHash
{
	NSString *path = [self pathToImageByHash:sHash];
	VLFileManager *fileManr = [VLFileManager shared];
	if([fileManr fileExists:path])
		return YES;
	return NO;
}

- (NSString *)getFilePathForImageWithHash:(NSString *)sHash {
	NSString *path = [self pathToImageByHash:sHash];
	return path;
}

- (void)deleteImagesWithHashes:(NSArray *)hashes {
	VLFileManager *fileManr = [VLFileManager shared];
	for(NSString *sHash in hashes) {
		NSString *path = [self pathToImageByHash:sHash];
		[fileManr deleteFileOrDir:path error:nil];
	}
}

- (void)timerEvent:(id)sender
{
	[self update];
}

- (void)clear {
	VLFileManager *fileManager = [VLFileManager shared];
	NSError *error = nil;
	NSArray *files = [fileManager filesInDirectory:_dirPath error:&error];
	if(error) {
		VLLogError(error);
	} else {
		for(NSString *filePath in files) {
			[fileManager deleteFileOrDir:filePath error:&error];
			if(error)
				VLLogError(error);
		}
	}
}

- (void)dealloc
{	
	[_threadSave cancel];
	[_threadSave release];
	[_threadLoad cancel];
	[_threadLoad release];
	[_threadCheckDiskSpace release];
	
	[_dirName release];
	[_dirPath release];
	[_timer release];
	[_queueToSave release];
	[_queueToLoad release];
	[_queueLoaded release];
	[_ntfrImageLoaded release];
	
	[super dealloc];
}

@end

