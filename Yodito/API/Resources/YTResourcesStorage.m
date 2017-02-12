
#import "YTResourcesStorage.h"
#import "../Web/Classes.h"
#import "YTResourceTypeInfo.h"
#import "../Notes/Classes.h"
#import "YTImageUtilities.h"
#import "../YTCommon.h"
#import "../Database/Classes.h"
#import "../Managers/Classes.h"
#import "YTPhotoPreviewMaker.h"
#import "../YTApiMediator.h"

#define kFileStorageKey @"YTResourcesStorage_VLCachedDataFileStorage_Key_1"
#define kFileStorageVersion (kYTManagersBaseVersion + 6)

static YTResourcesStorage *_shared;

@implementation YTResourcesStorage

@dynamic downloadingFilesCount;

+ (YTResourcesStorage *)shared {
	if(!_shared)
		_shared = [[YTResourcesStorage alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		_dirPath = [[_dirPath stringByAppendingPathComponent:@"YTResourcesStorage"] retain];
		_maxFilesStorageSize = 1024 * 1024 * 10;
		
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		int lastFileStorageVersion = (int)[defs integerForKey:kFileStorageKey];
		if(lastFileStorageVersion != kFileStorageVersion) {
			[defs setInteger:kFileStorageVersion forKey:kFileStorageKey];
			[defs synchronize];
			if([[VLFileManager shared] dirExists:_dirPath])
				[[VLFileManager shared] deleteFileOrDir:_dirPath error:nil];
		}
		[[VLFileManager shared] forceDir:_dirPath error:nil];
		
		_fileStorage = [[VLCachedDataFileStorage alloc] initWithDirPath:_dirPath];
		[_fileStorage.dlgtDataLoaded addObserver:self selector:@selector(onFileDataLoaded:args:)];
		[_fileStorage.dlgtDataSaved addObserver:self selector:@selector(onFileDataSaved:args:)];
		_fileStorage.clearDiskInterval = 10;
		[_fileStorage setBlockBeforeClearDisk:^(NSArray *arrFileInfo, NSMutableArray *outArrFileInfoToDelete) {
			[self beforeClearDiskWithArrFileInfo:arrFileInfo outArrFileInfoToDelete:outArrFileInfoToDelete];
		} callOnMainThread:NO];
		
		_webDataAsyncLoader = [[VLWebDataAsyncLoader alloc] init];
		[_webDataAsyncLoader setMaxConcurrentOperationCount:kYTMaxImagesDownloadingAtOnce];
		[_webDataAsyncLoader.dlgtDataLoaded addObserver:self selector:@selector(onWebDataLoaded:args:)];
		[_webDataAsyncLoader setBlockLoader:^(VLWebDataAsyncLoaderArgs *args, VLWebDataAsyncLoaderBlockLoaderResult resultBlock) {
			[self startDownloadData:args resultBlock:resultBlock];
		}];
		_webDataAsyncLoader.parent = self;
		
		_loadingInfos = [[NSMutableArray alloc] init];
		
		[[VLAppDelegateBase sharedAppDelegateBase].msgrApplicationDidBecomeActive addObserver:self selector:@selector(onAppActivated:)];
		
		[self checkAndFixData];
	}
	return self;
}

- (void)initialize {
	
}

- (int)downloadingFilesCount {
	return _webDataAsyncLoader.loadingDataCount;
}

- (void)addReference:(YTResourceLoadingReference *)reference {
	[[YTDatabaseManager shared] checkIsMainThread];
	NSString *resourceHash = reference.resourceHash;
	if([NSString isEmpty:resourceHash])
		return;
	YTResourceLoadingInfo *loadingInfo = nil;
	for(YTResourceLoadingInfo *obj in _loadingInfos) {
		if([obj.resourceHash isEqual:resourceHash]) {
			loadingInfo = obj;
			break;
		}
	}
	BOOL isNew = NO;
	if(!loadingInfo) {
		isNew = YES;
		loadingInfo = [[[YTResourceLoadingInfo alloc] init] autorelease];
		loadingInfo.resourceHash = resourceHash;
		loadingInfo.resourceType = reference.resourceType;
		loadingInfo.resourceCategoryId = reference.resourceCategoryId;
		loadingInfo.parent = self;
		[_loadingInfos addObject:loadingInfo];
	}
	[loadingInfo addReference:reference];
	[reference modifyVersion];
	if(isNew)
		[self onResourceFirstRequested:loadingInfo];
}

- (void)removeReference:(YTResourceLoadingReference *)reference {
	[[YTDatabaseManager shared] checkIsMainThread];
	YTResourceLoadingInfo *loadingInfo = nil;
	for(YTResourceLoadingInfo *obj in _loadingInfos) {
		if([obj.resourceHash isEqual:reference.resourceHash]) {
			loadingInfo = obj;
			break;
		}
	}
	if(!loadingInfo)
		return;
	[loadingInfo removeReference:reference];
	if(!loadingInfo.references.count) {
		[[loadingInfo retain] autorelease];
		[loadingInfo resetParent:self];
		[_loadingInfos removeObject:loadingInfo];
		[self onResourceRequestsCanceled:loadingInfo];
	}
}

- (void)onResourceFirstRequested:(YTResourceLoadingInfo *)loadingInfo {
	[[YTDatabaseManager shared] checkIsMainThread];
	[self startLoadResource:loadingInfo];
}

- (void)onResourceRequestsCanceled:(YTResourceLoadingInfo *)loadingInfo {
	[[YTDatabaseManager shared] checkIsMainThread];
	NSString *resourceHash = loadingInfo.resourceHash;
	[_webDataAsyncLoader cancelRequestWithUrl:@"" sHash:resourceHash];
}

- (void)startLoadResource:(YTResourceLoadingInfo *)loadingInfo {
	[[YTDatabaseManager shared] checkIsMainThread];
	NSString *resourceHash = loadingInfo.resourceHash;
	if([NSString isEmpty:resourceHash])
		return;
	
	YTResourceTypeInfo *resType = [YTResourceTypeInfo infoByFileExt:loadingInfo.resourceType];
	BOOL isImage = [resType isImage];
	BOOL notExisted = NO;
	BOOL startedLoadAsync = NO;
	VLCachedDataFileStorageArgs *args = [_fileStorage loadDataByHash:resourceHash
													   doNotLoadData:YES//!isImage
														  notExisted:&notExisted
													startedLoadAsync:&startedLoadAsync];
	if(startedLoadAsync) {
		loadingInfo.processingState = EVLProcessingStateProcessing;
		return;
	}
	if(args) {
		loadingInfo.resourceFilePath = args.filePathInner;
		loadingInfo.processingState = EVLProcessingStateSucceed;
		[loadingInfo notifyReferences];
		return;
	}
	if([_webDataAsyncLoader containsDataWithUrl:@"" sHash:resourceHash]) {
		loadingInfo.processingState = EVLProcessingStateProcessing;
		return;
	}
	YTUsersEnManager *manrUser = [YTUsersEnManager shared];
	if(manrUser.isLoggedIn && !manrUser.isDemo) {
		if(isImage) {
			[_webDataAsyncLoader startDownloadDataWithUrl:@"" sHash:resourceHash downloadDataToFile:YES];
			loadingInfo.processingState = EVLProcessingStateProcessing;
		} else {
			[_webDataAsyncLoader startDownloadDataWithUrl:@"" sHash:resourceHash downloadDataToFile:YES];
			loadingInfo.processingState = EVLProcessingStateProcessing;
		}
	} else {
		loadingInfo.processingState = EVLProcessingStateFailed;
	}
	[loadingInfo notifyReferences];
}

- (void)startDownloadData:(VLWebDataAsyncLoaderArgs *)args resultBlock:(VLWebDataAsyncLoaderBlockLoaderResult)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
					  kYTUrlParamOperation, kYTUrlValueOperationGetResourceData];
	
	NSMutableArray *postValues = [NSMutableArray array];
	[postValues addObject:[YTUsersEnManager shared].authenticationToken];
	[postValues addObject:args.sHash];
	
	NSMutableDictionary *valuesToPost = [NSMutableDictionary dictionary];
	for(int i = 0; i < postValues.count; i++) {
		NSString *sVal = [postValues stringValueAtIndex:i defaultVal:@""];
		[valuesToPost setValue:sVal forKey:[NSString stringWithFormat:@"arg%d", i]];
	}
	static int _curTicket = 0;
	int ticket = ++_curTicket;
	VLLoggerTrace(@"ticket = %d; url = %@; post = %@", ticket, [sUrl yoditoCutServerUrl], valuesToPost);
	
	VLHttpWebRequest *request = [[[VLHttpWebRequest alloc] init] autorelease];
	NSString *tempDir = NSTemporaryDirectory();
	NSString *tempPath = [tempDir stringByAppendingPathComponent:[[VLGuid makeUnique] toString]];
	tempPath = [tempPath stringByAppendingPathExtension:@"dat"];
	request.downloadDestinationPath = tempPath;
	args.cancelable = request;
	[[VLAppDelegateBase sharedAppDelegateBase] startAnimateNetworkActivityIndicator];
	[request startWithUrl:sUrl
				   method:kVLHttpWebRequest_MethodPost
				 postData:valuesToPost
				  timeout:kYTDefaultWebTimeoutBigData
			   cachPolicy:NSURLRequestReloadIgnoringCacheData
			 headerFields:nil
			  synchronous:NO
			  resultBlock:^(NSError *error, NSData *dataResponse)
	{
		[[VLAppDelegateBase sharedAppDelegateBase] stopAnimateNetworkActivityIndicator];
		
		if(error) {
			VLLoggerError(@"ticket = %d; %@", ticket, error);
			args.error = error;
			resultBlock(args);
			[self modifyVersion];
			return;
		}
		NSString *destPath = request.downloadDestinationPath;
		VLLoggerTrace(@"ticket = %d; downloaded to '%@'", ticket, destPath);
		args.dataFilePath = destPath;
		resultBlock(args);
		[self modifyVersion];
	}];
	[self modifyVersion];
}

- (void)onFileDataLoaded:(id)sender args:(VLCachedDataFileStorageArgs *)args {
	[[YTDatabaseManager shared] checkIsMainThread];
	NSArray *loadingInfos = [NSArray arrayWithArray:_loadingInfos];
	for(YTResourceLoadingInfo *info in loadingInfos) {
		if(info.processing && [info.resourceHash isEqual:args.sHash]) {
			if(args.error) {
				info.error = args.error;
				info.processingState = EVLProcessingStateFailed;
				[info notifyReferences];
				return;
			}
			info.resourceFilePath = args.filePathInner;
			info.error = nil;
			info.processingState = EVLProcessingStateSucceed;
			[info notifyReferences];
		}
	}
}
- (void)onFileDataSaved:(id)sender args:(VLCachedDataFileStorageArgs *)args {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(_hashWaitingForSave && [args.sHash isEqual:_hashWaitingForSave]) {
		[_argsWaitedForSave release];
		_argsWaitedForSave = [args retain];
	}
	NSArray *loadingInfos = [NSArray arrayWithArray:_loadingInfos];
	for(YTResourceLoadingInfo *info in loadingInfos) {
		if(info.processing && [info.resourceHash isEqual:args.sHash]) {
			if(args.error) {
				info.error = args.error;
				info.processingState = EVLProcessingStateFailed;
				[info notifyReferences];
				return;
			}
			if(![NSString isEmpty:args.filePathOuter]) {
				NSError *error = nil;
				if([[VLFileManager shared] fileExists:args.filePathOuter]) {
					[[VLFileManager shared] deleteFileOrDir:args.filePathOuter error:&error];
					if(error)
						VLLogError(error);
				}
			}
			if(info.resourceCategoryId == EYTResourceCategoryTypeImage) {
				[[YTPhotoPreviewMaker shared] startMakeWithImageHash:args.sHash imageFilePath:args.filePathInner skip:NO resultBlock:^{
					info.resourceFilePath = args.filePathInner;
					info.error = nil;
					info.processingState = EVLProcessingStateSucceed;
					[info notifyReferences];
				}];
			} else {
				info.resourceFilePath = args.filePathInner;
				info.error = nil;
				info.processingState = EVLProcessingStateSucceed;
				[info notifyReferences];
			}
		}
	}
	[[YTResourcesEnManager shared] modifyVersion];
}

- (void)onWebDataLoaded:(id)sender args:(VLWebDataAsyncLoaderArgs *)args {
	[[YTDatabaseManager shared] checkIsMainThread];
	NSArray *loadingInfos = [NSArray arrayWithArray:_loadingInfos];
	for(YTResourceLoadingInfo *info in loadingInfos) {
		if(info.processing && [info.resourceHash isEqual:args.sHash]) {
			if(args.error) {
				info.error = args.error;
				info.processingState = EVLProcessingStateFailed;
				[info notifyReferences];
				return;
			}
			[_fileStorage startSaveData:args.data orDataFromFile:args.dataFilePath withHash:info.resourceHash];
		}
	}
}

- (void)beforeClearDiskWithArrFileInfo:(NSArray *)arrFileInfo outArrFileInfoToDelete:(NSMutableArray *)outArrFileInfoToDelete {
	[[YTDatabaseManager shared] waitingUntilDone:YES performBlockOnDT:^
	{
		NSSet *setHash = [[YTResourcesDbManager shared] getAllAttachementHashes];
		for(VLCachedDataFileStorage_FileInfo *info in arrFileInfo) {
			if([setHash containsObject:info.sHash])
				continue;
			[outArrFileInfoToDelete addObject:info];
		}
	}];
}

- (void)saveData:(NSData *)data orDataFromFile:(NSString *)dataFilePath
		withHash:(NSString *)sHash skip:(BOOL)skip resultBlock:(VLBlockVoid)resultBlock {
	if(skip) {
		resultBlock();
		return;
	}
	[[YTDatabaseManager shared] checkIsMainThread];
	[_hashWaitingForSave release];
	_hashWaitingForSave = [sHash copy];
	[_argsWaitedForSave release];
	_argsWaitedForSave = nil;
	[_fileStorage startSaveData:data orDataFromFile:dataFilePath withHash:sHash];
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
		return (_argsWaitedForSave != nil);
	} ignoringTouches:YES completeBlock:^{
		[_hashWaitingForSave release];
		_hashWaitingForSave = nil;
		[_argsWaitedForSave release];
		_argsWaitedForSave = nil;
		resultBlock();
	}];
}

- (NSData *)getDataSynchronousWithHash:(NSString *)sHash {
	NSData *data = [_fileStorage getDataSynchronousWithHash:sHash];
	return data;
}

- (BOOL)isResourceDownloadedWithHash:(NSString *)sHash {
	//[[YTDatabaseManager shared] checkIsMainThread];
	if([_fileStorage containsDataWithHash:sHash])
		return YES;
	return NO;
}

- (NSString *)filePathToDownloadedResourceWithHash:(NSString *)sHash {
	NSString *path = [_fileStorage filePathToDataWithHash:sHash];
	return path;
}

- (void)checkAndFixData {
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
		return [[YTApiMediator shared] isDataInitialized];
	} ignoringTouches:NO completeBlock:^{
		[self checkAndFixDataInternal];
	}];
}

- (void)checkAndFixDataInternal {
	// Delete images with no corresponding resource
	NSArray *allRes = [[YTResourcesEnManager shared] getAllResources];
	NSMutableSet *setAllResHash = [NSMutableSet set];
	for(YTResourceInfo *res in allRes) {
		[setAllResHash addObject:res.attachmenthash];
	}
	NSMutableDictionary *mapResByHash = [NSMutableDictionary dictionary];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^{
		for(YTResourceInfo *res in [YTResourcesDbManager shared].entities) {
			[setAllResHash addObject:res.attachmenthash];
			[mapResByHash setObject:res forKey:res.attachmenthash];
		}
		//[setAllResHash addObjectsFromArray:[[[YTResourcesDbManager shared] getAllAttachementHashes] allObjects]];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^{
			NSArray *arrDataHashes = [_fileStorage getAllDataHashes];
			for(NSString *sHash in arrDataHashes) {
				if(![setAllResHash containsObject:sHash]) {
					[_fileStorage deleteDataWithHash:sHash];
				}
			}
			
			// Delete downloaded images if there is no previews
			NSArray *arrPreviewHashes = [[YTPhotoPreviewMaker shared] getAllImagesHashes];
			NSSet *setPreviewHashes = [NSSet setWithArray:arrPreviewHashes];
			arrDataHashes = [_fileStorage getAllDataHashes];
			for(NSString *sHash in arrDataHashes) {
				YTResourceInfo *res = [mapResByHash objectForKey:sHash];
				if(!res || ![res isImage] || [res isThumbnail])
					continue;
				if(![setPreviewHashes containsObject:sHash]) {
					[_fileStorage deleteDataWithHash:sHash];
				}
			}
			
			// Delete previous with missing resources
			NSSet *setDataHashes = [NSSet setWithArray:arrDataHashes];
			for(NSString *sHash in arrPreviewHashes) {
				if(![setDataHashes containsObject:sHash]) {
					[[YTPhotoPreviewMaker shared] deleteImageWithHash:sHash];
				}
			}
		}];
	}];
}

- (CGSize)sizeOfLoadedImage:(YTResourceInfo *)res {
	if(!res || !res.isImage)
		return CGSizeZero;
	NSString *sHash = res.attachmenthash;
	static NSMutableDictionary *_cache;
	if(!_cache)
		_cache = [NSMutableDictionary new];
	VLSize *pSize = [_cache objectForKey:sHash];
	if(pSize)
		return [pSize toCGSize];
	NSString *path = [[YTResourcesStorage shared] filePathToDownloadedResourceWithHash:res.attachmenthash];
	if([NSString isEmpty:path])
		return CGSizeZero;
	UIImageOrientation orient = UIImageOrientationUp;
	CGSize size = [YTImageUtilities getImageSizeWithFilePath:path imageOrientation:&orient fileExt:res.attachmentTypeName];
	if( orient == UIImageOrientationLeft
	   || orient == UIImageOrientationRight
	   || orient == UIImageOrientationLeftMirrored
	   || orient == UIImageOrientationRightMirrored)
	{
		float f = size.width;
		size.width = size.height;
		size.height = f;
	}
	pSize = [VLSize sizeWithWidth:size.width height:size.height];
	[_cache setObject:pSize forKey:sHash];
	return size;
}

- (void)onAppActivated:(id)sender {
	[self checkAndFixData];
}

- (void)dealloc {
	[_dirPath release];
	[_fileStorage release];
	[_webDataAsyncLoader release];
	[_loadingInfos release];
	[_hashWaitingForSave release];
	[_argsWaitedForSave release];
	[super dealloc];
}

@end

