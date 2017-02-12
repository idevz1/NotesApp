
#import "YTResourcesDbManager.h"
#import "YTDatabaseManager.h"
#import "../Managers/Classes.h"
#import "../Resources/Classes.h"

static YTResourcesDbManager *_shared;

@implementation YTResourcesDbManager

+ (YTResourcesDbManager *)shared {
	if(!_shared)
		_shared = [[YTResourcesDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTResourceInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
		_cachedAllAttachementHashes = [[NSMutableSet alloc] init];
		_mapEntityById = [[NSMutableDictionary alloc] init];
		[[YTDatabaseManager shared].dlgtEntityIdChanged addObserver:self selector:@selector(onEntityIdChanged:args:)];
	}
	return self;
}

- (void)initialize {
	[super initialize];
}

- (NSSet *)getAllAttachementHashes {
	[self checkIsDatabaseThread];
	if(_versionCachedAllAttachementHashes != self.version) {
		[_cachedAllAttachementHashes removeAllObjects];
		NSMutableArray *arrHashes = [NSMutableArray array];
		[self.database readRowsValuesInTable:kYTDbTableResource columnName:kYTJsonKeyAttachmenthash result:arrHashes];
		[_cachedAllAttachementHashes addObjectsFromArray:arrHashes];
		_versionCachedAllAttachementHashes = self.version;
	}
	return _cachedAllAttachementHashes;
}

- (void)loadEntitiesFromDb {
	[super loadEntitiesFromDb];
	[_mapEntityById removeAllObjects];
	for(YTResourceInfo *entity in self.entities) {
		[_mapEntityById setObject:entity forKey:[NSNumber numberWithLongLong:entity.attachmentId]];
	}
}

- (void)addEntity:(VLSqliteEntity *)entity {
	[super addEntity:entity];
	[_mapEntityById setObject:entity forKey:[NSNumber numberWithLongLong:((YTResourceInfo *)entity).attachmentId]];
}

- (void)deleteEntityFromDb:(VLSqliteEntity *)entity {
	[super deleteEntityFromDb:entity];
	[_mapEntityById removeObjectForKey:[NSNumber numberWithLongLong:((YTResourceInfo *)entity).attachmentId]];
}

- (void)deleteAllEntitiesFromDb {
	[super deleteAllEntitiesFromDb];
	[_mapEntityById removeAllObjects];
}

- (void)onEntityIdChanged:(id)sender args:(YTEntityIdChangedArgs *)args {
	[self checkIsDatabaseThread];
	YTResourceInfo *res = ObjectCast(args.entity, YTResourceInfo);
	if(res) {
		NSNumber *numdIdLast = [NSNumber numberWithLongLong:args.idLast];
		NSNumber *numdINew = [NSNumber numberWithLongLong:args.idNew];
		YTEntityBase *entity = [_mapEntityById objectForKey:numdIdLast];
		if(entity) {
			[_mapEntityById setObject:entity forKey:numdINew];
			[_mapEntityById removeObjectForKey:numdIdLast];
		}
	}
}

- (YTResourceInfo *)getResourceById:(int64_t)resourceId {
	NSNumber *numId = [[NSNumber alloc] initWithLongLong:resourceId];
	YTResourceInfo *res = [_mapEntityById objectForKey:numId];
	[numId release];
	return res;
}

- (YTResourceInfo *)getThumbnailForImage:(YTResourceInfo *)resImage {
	if(!resImage || ![resImage isImage] || resImage.isThumbnail)
		return nil;
	NSArray *resources = [NSArray arrayWithArray:self.entities];
	for(YTResourceInfo *res in resources) {
		if(![res isImage] || !res.isThumbnail)
			continue;
		if(res.parentAttachmentId && res.parentAttachmentId == resImage.attachmentId)
			return res;
	}
	return nil;
}

- (NSString *)apiOperationForDelete {
	return kYTUrlValueOperationDeleteResource;
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	YTResourceInfo *resource = ObjectCast(entity, YTResourceInfo);
	// Currently sync only images
	if([resource isImage] && resource.isThumbnail)
		return @"";
	return kYTUrlValueOperationSetResource;
}

- (NSString *)apiOperationForList {
	return kYTUrlValueOperationGetResources;
}

- (void)onSortEntitiesToDelete:(NSMutableArray *)entitiesToDelete {
	[entitiesToDelete sortUsingComparator:^NSComparisonResult(YTResourceInfo *obj1, YTResourceInfo *obj2) {
		if(obj1.attachmentId > obj2.attachmentId)
			return -1;
		else if(obj1.attachmentId < obj2.attachmentId)
			return 1;
		return 0;
	}];
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	YTResourceInfo *resource = ObjectCast(entity, YTResourceInfo);
	[postValues addObject:[NSString stringWithFormat:@"%lld", resource.attachmentId]];
	NSString *sLastUpdateTS = [resource.lastUpdateTS yoditoToString];
	[postValues addObject:sLastUpdateTS ? sLastUpdateTS : @""];
}

- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip {
	[postValues removeAllObjects];
	[arrFiles removeAllObjects];
	
	YTResourceInfo *resource = (YTResourceInfo *)entity;
	YTResourceInfo *resThumb = nil;
	if(resource.isImage)
		resThumb = [self getThumbnailForImage:resource];
	
	[postValues addObject:[YTUsersEnManager shared].authenticationToken];
	YTNoteInfo *note = [[YTNotesDbManager shared] getNoteByResourceId:resource.attachmentId];
	[postValues addObject:note ? note.noteGuid : @""];
	[postValues addObject:[[YTNoteHtmlParser shared] urlEncode:resource.descr ? resource.descr : @""]];
	[postValues addObject:resource.attachmenthash];
	[postValues addObject:resThumb ? resThumb.attachmenthash : @""];
	[postValues addObject:[resource.lastUpdateTS yoditoToString]];
	
	NSString *sDataFilePath = [[YTResourcesStorage shared] filePathToDownloadedResourceWithHash:resource.attachmenthash];
	NSString *sThumbFilePath = resThumb ? [[YTResourcesStorage shared] filePathToDownloadedResourceWithHash:resThumb.attachmenthash] : @"";
	VLFileManager *manrFile = [VLFileManager shared];
	if((resThumb && ![manrFile fileExists:sThumbFilePath]) || ![manrFile fileExists:sDataFilePath]) {
		// TODO: Fast Kludge, sometimes thumbnail does not exist, and sync stuck. As we don't need to upload now, let's send fake. Same thing fro image for any case.
		// It's fixed. But left this for any case.
		NSString *fakeImagePath = [[NSBundle mainBundle] pathForResource:@"clear" ofType:@".png"]; // "clear.png"
		if(resThumb && ![manrFile fileExists:sThumbFilePath]) {
			VLLoggerError(@"Thumbnail file does not exists: %@", [resThumb description]);
			sThumbFilePath = [[YTPhotoPreviewMaker shared] getThumbnailFilePath:resource.attachmenthash imageSize:nil];
			if(![manrFile fileExists:sThumbFilePath]) {
				sThumbFilePath = fakeImagePath;
				VLLoggerError(@"Thumbnail file does not exists: %@", [resThumb description]);
			}
		}
		if(![manrFile fileExists:sDataFilePath]) {
			VLLoggerError(@"Image file does not exists: %@", [resource description]);
			// Something wrong here, delete it from db, otherwise won't sync.
			[self deleteEntityFromDb:resource];
			if(resThumb)
				[self deleteEntityFromDb:resThumb];
			*needSkip = YES;
			return;
		}
	}
	
	YTWebRequestFileInfo *fileInfo = [[[YTWebRequestFileInfo alloc] init] autorelease];
	fileInfo.filePath = sDataFilePath;
	fileInfo.fileName = resource.filename;
	//fileInfo.fileName = [[YTNoteHtmlParser shared] urlEncode:resource.filename];
	//fileInfo.fileName = [NSString stringWithFormat:@"%@.%@", resource.attachmenthash, resource.attachmentTypeName];
	VLLoggerTrace(@"Image filename = %@", fileInfo.fileName);
	fileInfo.contentType = resource.isImage ? [NSString stringWithFormat:@"image/%@", resource.attachmentTypeName] : @"application/octet-stream";
	fileInfo.key = @"attachment[0]";
	[arrFiles addObject:fileInfo];
	if(resThumb) {
		YTWebRequestFileInfo *fileInfoThumb = [[[YTWebRequestFileInfo alloc] init] autorelease];
		fileInfoThumb.filePath = sThumbFilePath;
		fileInfoThumb.fileName = resThumb.filename;
		//fileInfoThumb.fileName = [[YTNoteHtmlParser shared] urlEncode:resThumb.filename];
		//fileInfoThumb.fileName = [NSString stringWithFormat:@"%@.%@", resThumb.attachmenthash, resThumb.attachmentTypeName];
		VLLoggerTrace(@"Thumbnail filename = %@", fileInfoThumb.fileName);
		fileInfoThumb.contentType = [NSString stringWithFormat:@"image/%@", resThumb.attachmentTypeName];
		fileInfoThumb.key = @"attachment[1]";
		[arrFiles addObject:fileInfoThumb];
	}
}

- (void)onGetResponseForAddEntity:(YTEntityBase *)entity response:(NSDictionary *)response {
	YTResourceInfo *resource = ObjectCast(entity, YTResourceInfo);
	YTResourceInfo *resThumb = nil;
	if(resource.isImage && kYTCreateResourceImageThumbnails)
		resThumb = [self getThumbnailForImage:resource];
	int64_t attachmentIdNew = [response int64ValueForKey:kYTJsonKeyResultCode defaultVal:0];
	int64_t attachmentIdLast = resource.attachmentId;
	if(attachmentIdLast != attachmentIdNew) {
		resource.attachmentId = attachmentIdNew;
		[[YTDatabaseManager shared] notifyIdChangedForEntiy:resource formId:attachmentIdLast toId:attachmentIdNew];
	}
	NSDictionary *infos = [[YTNoteToResourceDbManager shared] getNoteResourcesByResourceId:attachmentIdNew];
	for(YTNoteToResourceInfo *info in infos.allValues)
		info.added = info.modified = info.isTemporary = NO;
	if(resThumb) {
		BOOL wasModified = resThumb.modified;
		int64_t thumbAttachmentIdNew = attachmentIdNew + 1;
		int64_t thumbAttachmentIdLast = resThumb.attachmentId;
		if(thumbAttachmentIdLast != thumbAttachmentIdNew) {
			resThumb.attachmentId = thumbAttachmentIdNew;
			[[YTDatabaseManager shared] notifyIdChangedForEntiy:resThumb formId:thumbAttachmentIdLast toId:thumbAttachmentIdNew];
		}
		resThumb.parentAttachmentId = resource.attachmentId;
		resThumb.modified = wasModified;
		resThumb.added = NO;
		NSDictionary *infosThumb = [[YTNoteToResourceDbManager shared] getNoteResourcesByResourceId:thumbAttachmentIdNew];
		for(YTNoteToResourceInfo *infoThumb in infosThumb.allValues)
			infoThumb.added = infoThumb.modified = infoThumb.isTemporary = NO;
	}
}

- (void)onRequestDeleteSucceedWithEntity:(YTEntityBase *)entity {
	YTResourceInfo *resource = ObjectCast(entity, YTResourceInfo);
	YTResourceInfo *resThumb = nil;
	if(resource.isImage && kYTCreateResourceImageThumbnails)
		resThumb = [self getThumbnailForImage:resource];
	[self deleteEntityFromDb:resource];
	if(resThumb)
		[self deleteEntityFromDb:resThumb];
}

- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities {
	//YTNoteInfo *note = ObjectCast(param, YTNoteInfo);
	for(NSDictionary *data in arrData) {
		YTResourceInfo *resource = [[YTResourceInfo new] autorelease];
		//resource.noteGuid = note.noteGuid;
		[resource loadFromData:data urlDecode:YES];
		[arrEntities addObject:resource];
	}
}

- (void)onEntityFromListingUpdated:(YTEntityBase *)entity param:(NSObject *)param {
	YTResourceInfo *resource = ObjectCast(entity, YTResourceInfo);
	if(resource.isImage && !resource.isThumbnail) {
		YTResourceInfo *thumb = [self getThumbnailForImage:resource];
		if(thumb) {
			thumb.added = NO;
			thumb.modified = NO;
		}
	}
}

- (void)dealloc {
	[super dealloc];
}

@end

