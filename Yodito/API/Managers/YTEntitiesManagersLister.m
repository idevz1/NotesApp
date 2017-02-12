
#import "YTEntitiesManagersLister.h"
#import "YTNotebooksEnManager.h"
#import "YTUsersEnManager.h"
#import "YTNotesEnManager.h"
#import "YTResourcesEnManager.h"
#import "YTStacksEnManager.h"
#import "YTLocationsEnManager.h"
#import "YTTagsEnManager.h"
#import "YTNotesContentEnManager.h"
#import "YTNoteToLocationEnManager.h"
#import "YTNoteToResourceEnManager.h"
#import "YTNoteToTagEnManager.h"
#import "../Resources/Classes.h"
#import "../YTApiMediator.h"

static YTEntitiesManagersLister *_shared;

@implementation YTEntitiesManagersLister

@synthesize initialized = _initialized;

+ (YTEntitiesManagersLister *)shared {
	if(!_shared)
		_shared = [[YTEntitiesManagersLister alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
	}
	return self;
}

- (void)initializeMT {
	_managersOrdered = [[NSMutableArray alloc] init];
	
	[_managersOrdered addObject:[YTUsersEnManager shared]];
	[_managersOrdered addObject:[YTStacksEnManager shared]];
	[_managersOrdered addObject:[YTNotebooksEnManager shared]];
	[_managersOrdered addObject:[YTNotesEnManager shared]];
	[_managersOrdered addObject:[YTNotesContentEnManager shared]];
	[_managersOrdered addObject:[YTResourcesEnManager shared]];
	[_managersOrdered addObject:[YTLocationsEnManager shared]];
	[_managersOrdered addObject:[YTTagsEnManager shared]];
	[_managersOrdered addObject:[YTNoteToResourceEnManager shared]];
	[_managersOrdered addObject:[YTNoteToLocationEnManager shared]];
	[_managersOrdered addObject:[YTNoteToTagEnManager shared]];
}

- (void)initializeWithResultBlockMT:(VLBlockVoid)resultBlockMT {
	
	for(YTEntitiesManager *manr in _managersOrdered)
		[manr initialize];
	
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^{
		
		NSTimeInterval tm1 = [[NSProcessInfo processInfo] systemUptime];
		
		for(YTEntitiesManager *manr in _managersOrdered)
			[manr initializeDT];
		
		[self managersUpdateOnDT];
		
		NSTimeInterval tm2 = [[NSProcessInfo processInfo] systemUptime];
		VLLoggerTrace(@"Stage1 %0.4f s", tm2 - tm1);
		
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^{
			
			[[YTDatabaseManager shared] addDelegate:self];
			
			_timer = [[VLTimer alloc] init];
			_timer.interval = 0.25;
			_timer.enabledAlwaysFiring = YES;
			[_timer setObserver:self selector:@selector(onTimerEvent:)];
			[_timer start];
			
			[self managersUpdateOnMT];
			
			_initialized = YES;
			[self modifyVersion];
			
			resultBlockMT();
		}];
	}];
}

- (void)databaseManager:(YTDatabaseManager *)databaseManager updateOnDT:(id)param {
	[self managersUpdateOnDT];
}

- (void)managersUpdateOnDT {
	for(YTEntitiesManager *manr in _managersOrdered)
		[manr updateOnDT];
	_counterManagersUpdateOnDT++;
}

- (void)managersUpdateOnMT {
	for(YTEntitiesManager *manr in _managersOrdered)
		[manr updateOnMT];
	_counterManagersUpdateOnMT++;
}

- (void)onTimerEvent:(id)sender {
	[self managersUpdateOnMT];
	/*NSTimeInterval tm1 = [[NSProcessInfo processInfo] systemUptime];
	for(YTEntitiesManager *manr in _managersOrdered)
		[manr updateOnMT];
	NSTimeInterval tm2 = [[NSProcessInfo processInfo] systemUptime];
	if(tm2 - tm1 > 0.111)
		VLLogEvent(([NSString stringWithFormat:@"Delay Warning: %0.4f s", tm2 - tm1]));*/
}

- (void)waitForNextUpdateWithResultBlock:(VLBlockVoid)resultBlock {
	long counterManagersUpdateOnDT = _counterManagersUpdateOnDT;
	__block long counterManagersUpdateOnMT = -1;
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
		if(counterManagersUpdateOnDT == _counterManagersUpdateOnDT)
			return NO;
		if(counterManagersUpdateOnMT < 0) {
			counterManagersUpdateOnMT = _counterManagersUpdateOnMT;
			return NO;
		}
		if(counterManagersUpdateOnMT == _counterManagersUpdateOnMT)
			return NO;
		return YES;
	} ignoringTouches:NO completeBlock:^{
		resultBlock();
	}];
}

- (void)addNewNote:(YTNoteEditInfo *)noteEditInfo resultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(!noteEditInfo.isNewNote)
		[NSException raise:@"YTEntitiesManagersLister: addNewNote: not a new note" format:@""];
	YTNotesDbManager *manrDbNotes = [YTNotesDbManager shared];
	YTNotesContentDbManager *manrDbNotesContent = [YTNotesContentDbManager shared];
	YTLocationsDbManager *manrDbLocations = [YTLocationsDbManager shared];
	YTResourcesDbManager *manrDbResources = [YTResourcesDbManager shared];
	YTTagsDbManager *manrDbTags = [YTTagsDbManager shared];
	YTNoteToLocationDbManager *manrDbNoteLocations = [YTNoteToLocationDbManager shared];
	YTNoteToResourceDbManager *manrDbNoteResources = [YTNoteToResourceDbManager shared];
	YTNoteToTagDbManager *manrDbNoteTags = [YTNoteToTagDbManager shared];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		YTNoteInfo *noteNew = noteEditInfo.noteNew;
		//YTNoteInfo *newNote = [[[YTNoteInfo alloc] init] autorelease];
		//[newNote assignDataFrom:note];
		noteNew.added = YES;
		noteNew.modified = noteNew.deleted = noteNew.isTemporary = NO;
		[manrDbNotes addEntity:noteNew];
		YTNoteContentInfo *noteContentInfo = noteEditInfo.noteContentNew;
		noteContentInfo.noteGuid = noteNew.noteGuid;
		[manrDbNotesContent writeNoteConentInfo:noteContentInfo];
		
		YTLocationInfo *location = noteEditInfo.locationNew;
		if(location) {
			if(!location.locationId)
				location.locationId = [[YTDatabaseManager shared] makeNewTempId];
			location.added = YES;
			location.modified = location.deleted = location.isTemporary = NO;
			[manrDbLocations addEntity:location];
			[manrDbNoteLocations addNoteLocationWithNoteGuid:noteNew.noteGuid locationId:location.locationId];
		}
		
		for(YTResourceInfo *resource in [NSArray arrayWithArray:noteEditInfo.resourcesNew]) {
			if(!resource.attachmentId)
				resource.attachmentId = [[YTDatabaseManager shared] makeNewTempId];
			resource.added = YES;
			resource.modified = resource.deleted = resource.isTemporary = NO;
			[manrDbResources addEntity:resource];
			[manrDbNoteResources addNoteResourceWithNoteGuid:noteNew.noteGuid resourceId:resource.attachmentId];
		}
		
		for(YTTagInfo *tag in [NSArray arrayWithArray:noteEditInfo.tagsNew]) {
			if(!tag.tagId)
				tag.tagId = [[YTDatabaseManager shared] makeNewTempId];
			tag.added = YES;
			tag.modified = tag.deleted = tag.isTemporary = NO;
			[manrDbTags addEntity:tag];
			[manrDbNoteTags addNoteTagWithNoteGuid:noteNew.noteGuid tagId:tag.tagId];
		}
		
		[[YTDatabaseManager shared] cleanDatabase];
		
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			resultBlock();
		}];
	}];
}

- (void)applyModifiedNote:(YTNoteEditInfo *)noteEditInfo doneEditing:(BOOL)doneEditing resultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(noteEditInfo.isNewNote)
		[NSException raise:@"YTEntitiesManagersLister: addNewNote: is a new note" format:@""];
	YTNotesDbManager *manrDbNotes = [YTNotesDbManager shared];
	YTNotesContentDbManager *manrDbNotesContent = [YTNotesContentDbManager shared];
	YTLocationsDbManager *manrDbLocations = [YTLocationsDbManager shared];
	YTResourcesDbManager *manrDbResources = [YTResourcesDbManager shared];
	YTTagsDbManager *manrDbTags = [YTTagsDbManager shared];
	YTNoteToLocationDbManager *manrDbNoteLocations = [YTNoteToLocationDbManager shared];
	YTNoteToResourceDbManager *manrDbNoteResources = [YTNoteToResourceDbManager shared];
	YTNoteToTagDbManager *manrDbNoteTags = [YTNoteToTagDbManager shared];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		YTNoteInfo *note = noteEditInfo.noteLast;
		YTNoteInfo *noteNew = noteEditInfo.noteNew;
		YTNoteContentInfo *noteContentLast = noteEditInfo.noteContentLast;
		YTNoteContentInfo *noteContentNew = noteEditInfo.noteContentNew;
		
		NSString *lastNotebookGuid = [[note.notebookGuid copy] autorelease];
		int64_t lastNotebookId = note.notebookId;
		NSString *newNotebookGuid = [[noteNew.notebookGuid copy] autorelease];
		int64_t newNotebookId = noteNew.notebookId;
		[note assignDataFrom:noteNew];
		if(![lastNotebookGuid isEqual:newNotebookGuid] || lastNotebookId != newNotebookId) {
			note.notebookGuid = lastNotebookGuid;
			note.notebookId = lastNotebookId;
			[manrDbNotes changeNote:note withNotebookGuid:newNotebookGuid notebookId:newNotebookId];
		}
		if(![noteContentNew.content isEqual:noteContentLast.content]) {
			[noteContentLast assignDataFrom:noteContentNew];
			[manrDbNotesContent writeNoteConentInfo:noteContentLast];
			note.modified = YES;
			note.lastUpdateTS = [VLDate date];
			[note modifyVersion];
			noteNew.lastUpdateTS = note.lastUpdateTS;
		}
		//[manrDbNotes saveEntityToDb:note];
		//noteContentNew.nId = noteContentLast.nId;
		//noteContentNew.noteGuid = note.noteGuid;
		//[manrDbNotesContent writeNoteConentInfo:noteContentNew];
		
		BOOL locationsChanged = NO;
		BOOL remindersChanged = NO;
		BOOL tagsChanged = NO;
		BOOL resourcesChanged = NO;
		
		YTLocationInfo *locationLast = noteEditInfo.locationLast;
		YTLocationInfo *locationNew = noteEditInfo.locationNew;
		if(locationLast && !locationNew) {
			//locationLast.deleted = YES;
			for(YTNoteToLocationInfo *info in [manrDbNoteLocations getNoteLocationsByNoteGuid:note.noteGuid].allValues)
				info.deleted = YES;
			locationsChanged = YES;
		} else if(!locationLast && locationNew) {
			//if(!locationNew.locationId)
				locationNew.locationId = [[YTDatabaseManager shared] makeNewTempId];
			locationNew.added = YES;
			locationNew.modified = locationNew.deleted = locationNew.isTemporary = NO;
			[manrDbLocations addEntity:locationNew];
			[manrDbNoteLocations addNoteLocationWithNoteGuid:note.noteGuid locationId:locationNew.locationId];
			locationsChanged = YES;
		} else if(locationLast && locationNew && [locationLast compareDataTo:locationNew] != 0) {
			//locationLast.deleted = YES;
			for(YTNoteToLocationInfo *info in [manrDbNoteLocations getNoteLocationsByNoteGuid:note.noteGuid].allValues)
				info.deleted = YES;
			//if(!locationNew.locationId)
				locationNew.locationId = [[YTDatabaseManager shared] makeNewTempId];
			locationNew.added = YES;
			locationNew.modified = locationNew.deleted = locationNew.isTemporary = NO;
			[manrDbLocations addEntity:locationNew];
			[manrDbNoteLocations addNoteLocationWithNoteGuid:note.noteGuid locationId:locationNew.locationId];
			locationsChanged = YES;
		}
		note.hasLocation = (locationNew != nil);
		
		NSArray *tagsLast = [NSArray arrayWithArray:noteEditInfo.tagsLast];
		NSArray *tagsNew = [NSArray arrayWithArray:noteEditInfo.tagsNew];
		// Remove deleted
		for(YTTagInfo *tagLast in tagsLast) {
			YTTagInfo *tagNew = nil;
			for(YTTagInfo *tag in tagsNew)
				if(tag.tagId == tagLast.tagId)
				   tagNew = tag;
			if(!tagNew) {
				//tagLast.deleted = YES;
				YTNoteToTagInfo *info = [manrDbNoteTags getNoteTagByNoteGuid:note.noteGuid tagId:tagLast.tagId];
				if(info)
					info.deleted = YES;
				tagsChanged = YES;
			}
		}
		// Add new
		for(YTTagInfo *tagNew in tagsNew) {
			YTTagInfo *tagLast = nil;
			for(YTTagInfo *tag in tagsLast)
				if(tag.tagId == tagNew.tagId)
					tagLast = tag;
			if(!tagLast) {
				if(!tagNew.tagId)
					tagNew.tagId = [[YTDatabaseManager shared] makeNewTempId];
				tagNew.added = YES;
				tagNew.modified = tagNew.deleted = tagNew.isTemporary = NO;
				// Check if tag with this name already exists
				YTTagInfo *tagExisted = nil;
				for(YTTagInfo *tag in [NSArray arrayWithArray:manrDbTags.entities]) {
					if(tag.deleted)
						continue;
					if([tag.name isEqual:tagNew.name]) {
						tagExisted = tag;
						break;
					}
				}
				if(tagExisted) {
					[manrDbNoteTags addNoteTagWithNoteGuid:note.noteGuid tagId:tagExisted.tagId];
					[noteEditInfo replaceTagNew:tagNew withTag:tagExisted];
				} else {
					[manrDbTags addEntity:tagNew];
					[manrDbNoteTags addNoteTagWithNoteGuid:note.noteGuid tagId:tagNew.tagId];
				}
				tagsChanged = YES;
			}
		}
		// We do not modify tags now
		note.hasTag = (tagsNew.count > 0);
		
		NSArray *resourcesLast = [NSArray arrayWithArray:noteEditInfo.resourcesLast];
		NSArray *resourcesNew = [NSArray arrayWithArray:noteEditInfo.resourcesNew];
		// Remove deleted
		for(YTResourceInfo *resLast in resourcesLast) {
			YTResourceInfo *resNew = nil;
			for(YTResourceInfo *res in resourcesNew)
				if(res.attachmentId == resLast.attachmentId)
					resNew = res;
			if(!resNew) {
				resLast.deleted = YES;
				YTNoteToResourceInfo *info = [manrDbNoteResources getNoteResourceByNoteGuid:note.noteGuid resourceId:resLast.attachmentId];
				if(info)
					info.deleted = YES;
				resourcesChanged = YES;
			} else if(doneEditing && resLast.isTemporary) {
				resLast.isTemporary = NO;
				resourcesChanged = YES;
			}
		}
		// Add new
		for(YTResourceInfo *resNew in resourcesNew) {
			YTResourceInfo *resLast = nil;
			for(YTResourceInfo *res in resourcesLast)
				if(res.attachmentId == resNew.attachmentId)
					resLast = res;
			if(!resLast) {
				if(!resNew.attachmentId)
					resNew.attachmentId = [[YTDatabaseManager shared] makeNewTempId];
				resNew.added = YES;
				resNew.modified = resNew.deleted = resNew.isTemporary = NO;
				[manrDbResources addEntity:resNew];
				[manrDbNoteResources addNoteResourceWithNoteGuid:note.noteGuid resourceId:resNew.attachmentId];
				resourcesChanged = YES;
			}
			if(doneEditing && resNew.isTemporary) {
				resNew.isTemporary = NO;
				resourcesChanged = YES;
			}
		}
		// Modify changed
		// We do not modify resources now
		/*for(YTResourceInfo *resLast in resourcesLast) {
			YTResourceInfo *resNew = nil;
			for(YTResourceInfo *res in resourcesNew)
				if(res.attachmentId == resLast.attachmentId)
					resNew = res;
			if(resNew) {
				[resLast assignDataFrom:resNew];
				resourcesChanged = YES;
			}
		}*/
		
		[manrDbNotes saveEntityToDb:note];
		
		if([YTApiMediator shared].isShowingMainView || doneEditing) {
			
			// For debug:
			NSMutableArray *arr = [NSMutableArray arrayWithArray:resourcesLast];
			[arr addObjectsFromArray:resourcesNew];
			for(uint i = 0; i < arr.count; i++) {
				YTResourceInfo *res = [arr objectAtIndex:i];
				if(res.isTemporary) {
					int idebug = 0;
					idebug++;
				}
			}
			
			[[YTDatabaseManager shared] cleanDatabase];
		}
		
		if(locationsChanged || remindersChanged || tagsChanged || resourcesChanged)
			[note modifyVersion];
		
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			resultBlock();
		}];
	}];
}

- (void)deleteNote:(YTNoteInfo *)note withResultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	//YTLocationsDbManager *manrDbLocations = [YTLocationsDbManager shared];
	YTResourcesDbManager *manrDbResources = [YTResourcesDbManager shared];
	//YTTagsDbManager *manrDbTags = [YTTagsDbManager shared];
	YTNoteToResourceDbManager *manrDbNoteResources = [YTNoteToResourceDbManager shared];
	YTNoteToLocationDbManager *manrDbNoteLocations = [YTNoteToLocationDbManager shared];
	YTNoteToTagDbManager *manrDbNoteTags = [YTNoteToTagDbManager shared];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		//YTLocationInfo *location = [manrDbLocations getLocationByNoteGuid:note.noteGuid];
		//if(location)
		//	location.deleted = YES;
		NSDictionary *noteLocations = [manrDbNoteLocations getNoteLocationsByNoteGuid:note.noteGuid];
		for(YTNoteToLocationInfo *info in noteLocations.allValues) {
			//YTLocationInfo *loc = [manrDbLocations getLocationById:info.locationId];
			//if(loc)
			//	loc.deleted = YES;
			info.deleted = YES;
		}
		NSDictionary *noteResources = [manrDbNoteResources getNoteResourcesByNoteGuid:note.noteGuid];
		for(YTNoteToResourceInfo *info in noteResources.allValues) {
			YTResourceInfo *res = [manrDbResources getResourceById:info.resourceId];
			if(res)
				res.deleted = YES;
			info.deleted = YES;
		}
		NSDictionary *noteTags = [manrDbNoteTags getNoteTagsByNoteGuid:note.noteGuid];
		for(YTNoteToTagInfo *info in noteTags.allValues) {
			//YTTagInfo *tag = [manrDbTags getTagById:info.tagId];
			//if(tag)
			//	tag.deleted = YES;
			info.deleted = YES;
		}
		//NSArray *tags = [manrDbTags getTagsByNoteGuid:note.noteGuid];
		//for(YTTagInfo *tag in tags)
		//	tag.deleted = YES;
		note.deleted = YES;
		[[YTDatabaseManager shared] cleanDatabase];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			resultBlock();
		}];
	}];
}

- (void)changeNote:(YTNoteInfo *)note withNewDueDate:(VLDate *)dtDayNoTime resultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		VLDate *lastDueDate = note.dueDate;
		VLDate *lastEndDate = note.endDate;
		VLDate *lastDueDateNoTime = nil;
		int dDays = 0;
		NSTimeZone *tzDef = [NSTimeZone defaultTimeZone];
		NSTimeZone *tz0 = [NSTimeZone timeZoneForSecondsFromGMT:0];
		VLDate *dtDayNoTimeTZ0 = [[[VLDate alloc] initWithYear:[dtDayNoTime yearWithTimezone:tzDef]
														 month:[dtDayNoTime monthWithTimezone:tzDef]
														   day:[dtDayNoTime dayWithTimezone:tzDef]
													  timeZone:tz0] autorelease];
		if(![VLDate isEmpty:lastEndDate]) {
			lastDueDateNoTime = [lastDueDate dateByResettingTimeWimezone:tzDef];
			dDays = [dtDayNoTime diffDaysFrom:lastDueDateNoTime timezone:tzDef];
		} else {
			lastDueDateNoTime = [lastDueDate dateByResettingTimeWimezone:tz0];
			dDays = [dtDayNoTimeTZ0 diffDaysFrom:lastDueDateNoTime timezone:tz0];
		}
		if(![VLDate isEmpty:note.dueDate])
			note.dueDate = [note.dueDate dateByAppendingDays:dDays];
		else { // dueDate and endDate empty
			note.dueDate = dtDayNoTimeTZ0;
		}
		if(![VLDate isEmpty:note.endDate])
			note.endDate = [note.endDate dateByAppendingDays:dDays];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			resultBlock();
		}];
	}];
}

- (void)saveResourceImage:(UIImage *)image
				 fileName:(NSString *)fileName
		 withNoteEditInfo:(YTNoteEditInfo *)noteEditInfo
			  resultBlock:(VLBlockVoid)resultBlock {
	
	YTResourcesEnManager *manrRes = [YTResourcesEnManager shared];
	YTResourcesStorage *manrStor = [YTResourcesStorage shared];
	
	YTResourceInfo *resImage = [[[YTResourceInfo alloc] init] autorelease];
	resImage.attachmentId = [[YTDatabaseManager shared] makeNewTempId];
	resImage.attachmenthash = [[[VLGuid makeUnique] toString] md5];
	resImage.attachmentCategoryId = EYTResourceCategoryTypeImage;
	resImage.attachmentTypeName = kYTResourceImageFileExt;
	resImage.filename = fileName;
	
	// For tests:
	NSData *testResData = nil;
	/*int bmk;
	resImage.attachmentCategoryId = EYTResourceCategoryTypeTextDoc;
	resImage.attachmentTypeName = @"doc";
	//resImage.attachmentCategoryId = EYTResourceCategoryTypeOther;
	//resImage.attachmentTypeName = @"pdf";
	//resImage.attachmentTypeName = @"zip";
	resImage.filename = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:resImage.attachmentTypeName];
	testResData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]
	pathForResource:@"test" ofType:resImage.attachmentTypeName]];*/
	
	resImage.isTemporary = YES;
	resImage.lastUpdateTS = [VLDate date];
	BOOL isResImage = (resImage.attachmentCategoryId == EYTResourceCategoryTypeImage);
	
	YTResourceInfo *resThumb = nil;
	if(isResImage && kYTCreateResourceImageThumbnails) {
		resThumb = [[[YTResourceInfo alloc] init] autorelease];
		resThumb.attachmentId = [[YTDatabaseManager shared] makeNewTempId];
		resThumb.isThumbnail = YES;
		resThumb.attachmenthash = [[[VLGuid makeUnique] toString] md5];
		resThumb.parentAttachmentId = resImage.attachmentId;
		resThumb.attachmentCategoryId = EYTResourceCategoryTypeImage;
		resThumb.attachmentTypeName = kYTResourceThumbnailFileExt;
		resThumb.filename = [NSString stringWithFormat:@"%@ thm.%@", [fileName stringByDeletingPathExtension], resThumb.attachmentTypeName];
		resThumb.isTemporary = YES;
		resThumb.lastUpdateTS = [VLDate date];
	}
	NSArray *arrRes = [NSArray arrayWithObjects:resImage, resThumb, nil];
	[manrRes addEntities:arrRes withAddingBlockDT:^
	{
		for(YTResourceInfo *res in arrRes) {
			[[YTNoteToResourceDbManager shared] addNoteResourceWithNoteGuid:noteEditInfo.noteNew.noteGuid
																 resourceId:res.attachmentId];
		}
	}
	 withResultBlock:^
	{
		NSData *resData = nil;
		if(testResData) {
			resData = testResData;
		} else if([kYTResourceImageFileExt compare:@"png" options:NSCaseInsensitiveSearch] == 0) {
			resData = UIImagePNGRepresentation(image);
			if(!resData)
				resData = UIImageJPEGRepresentation(image, kYTDefaultJpegImageQuality);
		} else {
			resData = UIImageJPEGRepresentation(image, kYTDefaultJpegImageQuality);
			if(!resData)
				resData = UIImagePNGRepresentation(image);
		}
		if(!resData)
			resData = [NSData data];
		[manrStor saveData:resData orDataFromFile:nil withHash:resImage.attachmenthash skip:NO resultBlock:^{
			UIImage *imageThumb = nil;
			if(isResImage && kYTCreateResourceImageThumbnails)
				imageThumb = [[YTPhotoPreviewMaker shared] makeThumbnailWithImage:image
																		thumbSize:CGSizeMake(kYTPhotoThumbnailSize.width, kYTPhotoThumbnailSize.height)
																	  contentMode:EVLThumbnailContentModeAspectFill];
			 
			// Make Thumbnail and Preview
			NSString *imageHash = resImage.attachmenthash;
			NSString *imageFilePath = [manrStor filePathToDownloadedResourceWithHash:imageHash];
			[[YTPhotoPreviewMaker shared] startMakeWithImageHash:imageHash imageFilePath:imageFilePath skip:!isResImage resultBlock:^{
				NSData *imageThumbData = imageThumb ? UIImageJPEGRepresentation(imageThumb, kYTDefaultJpegImageQuality) : nil;
				NSString *thumbAttachmenthash = resThumb ? resThumb.attachmenthash : nil;
				[manrStor saveData:imageThumbData orDataFromFile:nil
						  withHash:thumbAttachmenthash skip:!imageThumbData resultBlock:^
				{
					// Check if files exist:
					NSString *sDataFilePath = [[YTResourcesStorage shared] filePathToDownloadedResourceWithHash:resImage.attachmenthash];
					BOOL filesExist = YES;
					if(![[VLFileManager shared] fileExists:sDataFilePath]) {
						filesExist = NO;
						VLLoggerError(@"Image file does not exists: %@", [resImage description]);
					}
					if(resThumb) {
						NSString *sThumbFilePath = [[YTResourcesStorage shared] filePathToDownloadedResourceWithHash:resThumb.attachmenthash];
						if(![[VLFileManager shared] fileExists:sThumbFilePath]) {
							filesExist = NO;
							VLLoggerError(@"Thumbnail file does not exists: %@", [resThumb description]);
						}
					}
					
					if(filesExist) {
						[noteEditInfo addResourceNew:resImage];
						if(resThumb)
							[noteEditInfo addResourceNew:resThumb];
					} else {
						[[YTDatabaseManager shared] waitingUntilDone:YES performBlockOnDT:^{
							[[YTResourcesDbManager shared] deleteEntityFromDb:resImage];
							if(resThumb)
								[[YTResourcesDbManager shared] deleteEntityFromDb:resThumb];
						}];
					}
					resultBlock();
				}];
			}];
		}];
	}];
}

- (void)addNewNotebook:(YTNotebookInfo *)newNotebook resultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	YTNotebooksDbManager *manrDbBooks = [YTNotebooksDbManager shared];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		newNotebook.added = YES;
		newNotebook.modified = newNotebook.deleted = newNotebook.isTemporary = NO;
		[manrDbBooks addEntity:newNotebook];
		[self managersUpdateOnDT];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			[self managersUpdateOnMT];
			resultBlock();
		}];
	}];
}

- (void)deleteNotebook:(YTNotebookInfo *)notebook resultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	//YTNotebooksDbManager *manrDbBooks = [YTNotebooksDbManager shared];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		notebook.deleted = YES;
		[self managersUpdateOnDT];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			[self managersUpdateOnMT];
			resultBlock();
		}];
	}];
}

- (void)renameNotebook:(YTNotebookInfo *)notebook withNewName:(NSString *)newName resultBlock:(VLBlockVoid)resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		notebook.name = newName;
		[self managersUpdateOnDT];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			[self managersUpdateOnMT];
			resultBlock();
		}];
	}];
}

- (void)dealloc {
	[super dealloc];
}

@end

