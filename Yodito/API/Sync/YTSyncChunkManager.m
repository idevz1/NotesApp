
#import "YTSyncChunkManager.h"
#import "YTSyncManager.h"
#import "../Managers/Classes.h"
#import "../Notes/Classes.h"
#import "../Storage/Classes.h"
#import "../Web/Classes.h"

#define kSavedDataKey @"YTSyncChunkManager"
#define kSavedDataVersion (kYTManagersBaseVersion + 2)

static YTSyncChunkManager *_shared;

@implementation YTSyncChunkManager

+ (YTSyncChunkManager *)shared {
	if(!_shared) {
		_shared = [VLObjectFileStorage loadRootObjectWithKey:kSavedDataKey version:kSavedDataVersion];
		if(!_shared)
			_shared = [[[YTSyncChunkManager alloc] init] autorelease];
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
		VLLogEvent(@"Saving");
		[VLObjectFileStorage saveDataWithRootObject:self key:kSavedDataKey version:kSavedDataVersion];
		_savedDataVersion = self.version;
	}
}

- (void)deleteEntityDTByEntityName:(NSString *)entityName
									noteGuid:(NSString *)noteGuid
									entityId:(int64_t)entityId
								   sEntityId:(NSString *)sEntityId {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	if([entityName isEqual:[[YTNoteToLocationInfo class] entityName]]) {
		YTNoteToLocationInfo *noteToLoc = [[YTNoteToLocationDbManager shared] getNoteLocationByNoteGuid:noteGuid locationId:entityId];
		if(noteToLoc) {
			[[YTNoteToLocationDbManager shared] deleteEntityFromDb:noteToLoc];
			return;
		}
	}
	if([entityName isEqual:[[YTNoteToTagInfo class] entityName]]) {
		YTNoteToTagInfo *noteToTag = [[YTNoteToTagDbManager shared] getNoteTagByNoteGuid:noteGuid tagId:entityId];
		if(noteToTag) {
			[[YTNoteToTagDbManager shared] deleteEntityFromDb:noteToTag];
			return;
		}
	}
	if([entityName isEqual:[[YTResourceInfo class] entityName]]) {
		NSArray *allEntities = [NSArray arrayWithArray:[YTResourcesDbManager shared].entities];
		for(YTResourceInfo *entity in allEntities) {
			if(entity.attachmentId == entityId || [entity.attachmenthash isEqual:sEntityId]) {
				[[entity retain] autorelease];
				[[YTResourcesDbManager shared] deleteEntityFromDb:entity];
				NSDictionary *noteToRess = [[YTNoteToResourceDbManager shared] getNoteResourcesByResourceId:entity.attachmentId];
				for(YTNoteToResourceInfo *noteToRes in [NSArray arrayWithArray:noteToRess.allValues])
					[[YTNoteToResourceDbManager shared] deleteEntityFromDb:noteToRes];
				return;
			}
		}
	}
	VLLogWarning(([NSString stringWithFormat:@"NOT FOUND: entityName = %@, noteGuid = %@, entityId = %lld", entityName, noteGuid, entityId]));
	return;
}

- (void)startCheckSyncChunkDTWithTicket:(int)ticket
						  resultBlockDT:(void (^)(NSArray *outErrors))resultBlockDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	NSMutableArray *outErrors = [NSMutableArray array];
	[self startCheckSyncChunkDTWithTicket:ticket
							currentPage:1
					processedNotesCount:0
							  outErrors:outErrors
							resultBlockDT:^()
	{
		resultBlockDT(outErrors);
	}];
}

- (NSArray *)arrayOfEntitiesDictionariesInRootObject:(id)rootObj {
	NSMutableArray *result = [NSMutableArray array];
	NSArray *rootArray = ObjectCast(rootObj, NSArray);
	if(!rootArray) {
		NSDictionary *rootDict = ObjectCast(rootObj, NSDictionary);
		if(rootDict)
			rootArray = [NSArray arrayWithArray:rootDict.allValues];
	}
	if(!rootArray)
		return result;
	for(id idVal in rootArray) {
		NSDictionary *dictEntity = ObjectCast(idVal, NSDictionary);
		if(dictEntity) {
			[result addObject:dictEntity];
			continue;
		}
		NSArray *arrVal = ObjectCast(idVal, NSArray);
		if(arrVal) {
			for(id val in arrVal) {
				NSDictionary *dict = ObjectCast(val, NSDictionary);
				if(dict) {
					[result addObject:dict];
					continue;
				}
			}
			continue;
		}
		VLLogError(@"for(id idVal in rootArray): dictEntity = null");
	}
	return result;
}

- (void)startCheckSyncChunkDTWithTicket:(int)ticket
						  currentPage:(int)currentPage
				  processedNotesCount:(int)processedNotesCount
							outErrors:(NSMutableArray *)outErrors
						  resultBlockDT:(void (^)())resultBlockDT {
	
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	YTSyncManager *manrSync = [YTSyncManager shared];
	if(!kYTUseSyncChunksApi) {
		resultBlockDT();
		return;
	}
	
	NSString *sUrlGetStacks = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
							   kYTUrlParamOperation, kYTUrlValueOperationListStacks];
	NSMutableArray *postValuesGetStacks = [NSMutableArray array];
	[postValuesGetStacks addObject:[YTUsersEnManager shared].authenticationToken];
	YTWebRequest *requestGetStacks = [[[YTWebRequest alloc] init] autorelease];
	[requestGetStacks postWithUrl:sUrlGetStacks
						   values:postValuesGetStacks
					  resultBlock:^(NSDictionary *response, NSError *error)
	{
		if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
			[outErrors addObject:[NSError makeCancel]];
			resultBlockDT();
			return;
		}
		if(error) {
			VLLogError(error);
			[outErrors addObject:error];
			resultBlockDT();
			return;
		}
		NSArray *arrStackIds = response.allValues.count ? ObjectCast([response.allValues objectAtIndex:0], NSArray) : nil;
		if(!arrStackIds)
			arrStackIds = [NSArray array];
		NSMutableArray *arrStacks = [NSMutableArray array];
		for(int i = 0; i < arrStackIds.count; i++) {
			
			int64_t nId = [arrStackIds int64ValueAtIndex:i defaultVal:0];
			if(nId) {
				YTStackInfo *stack = [[[YTStackInfo alloc] init] autorelease];
				stack.stackId = nId;
				[arrStacks addObject:stack];
			}
		}
		[[YTStacksDbManager shared] updateEntitiesFromOutside:arrStacks];
	
		NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
						  kYTUrlParamOperation, kYTUrlValueOperationGetSyncChunk3];
		NSMutableArray *postValues = [NSMutableArray array];
		[postValues addObject:[YTUsersEnManager shared].authenticationToken];
		[postValues addObject:[manrSync.lastSyncTime yoditoToString]];
		[postValues addObject:[NSString stringWithFormat:@"%d", currentPage]]; // Current page
		[postValues addObject:@"1"]; // Get notes with content
		//[postValues addObject:@"0"]; // Notes per page (default 5)
		[postValues addObject:[NSString stringWithFormat:@"%d", kYTGetSyncChunkNotesPerPage]];
		YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
		[request postWithUrl:sUrl
					  values:postValues
				 resultBlock:^(NSDictionary *response, NSError *error)
		{
			if(![[YTSyncManager shared] isSyncTicketValid:ticket]) {
				[outErrors addObject:[NSError makeCancel]];
				resultBlockDT();
				return;
			}
			if(error) {
				VLLogError(error);
				[outErrors addObject:error];
				resultBlockDT();
				return;
			}
			
			NSAutoreleasePool *arpoolMain = [[NSAutoreleasePool alloc] init];
			
			NSMutableArray *arrReceivedNotes = [NSMutableArray array];
			NSMutableArray *arrReceivedNotesAll = [NSMutableArray array];
			
			NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
			
			NSTimeInterval tmTotal1 = [[NSProcessInfo processInfo] systemUptime];

			NSDictionary *dictData = response;
			YTNotesDbManager *manrNotes = [YTNotesDbManager shared];
			YTNotebooksDbManager *manrNotebooks = [YTNotebooksDbManager shared];
			YTTagsDbManager *manrTags = [YTTagsDbManager shared];
			YTLocationsDbManager *manrLocations = [YTLocationsDbManager shared];
			YTResourcesDbManager *manrResources = [YTResourcesDbManager shared];
			YTNoteToTagDbManager *manrNoteTags = [YTNoteToTagDbManager shared];
			YTNoteToLocationDbManager *manrNoteLocations = [YTNoteToLocationDbManager shared];
			YTNoteToResourceDbManager *manrNoteResources = [YTNoteToResourceDbManager shared];
			
			int currentPage = [dictData intValueForKey:kYTJsonKeyCurrentPage defaultVal:1];
			int totalNotes = [dictData intValueForKey:kYTJsonKeyTotalNotes defaultVal:0];
			
			NSArray *arrDictNotebooks = [dictData arrayValueForKey:@"Notebooks" defaultIsEmpty:YES];
			for(NSDictionary *dictNotebook in arrDictNotebooks) {
				YTNotebookInfo *notebook = [[[YTNotebookInfo alloc] init] autorelease];
				[notebook loadFromData:dictNotebook urlDecode:YES];
				if([NSString isEmpty:notebook.notebookGuid])
					continue;
				VLDate *newLastUpdateTS = [VLDate yoditoDateWithString:[dictNotebook stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""]];
				YTNotebookInfo *existedNotebook = [manrNotebooks getNotebookByGuid:notebook.notebookGuid];
				if(existedNotebook) {
					if(notebook.visibility) {
						if([newLastUpdateTS compare:existedNotebook.lastUpdateTS] < 0 && existedNotebook.modified) {
							// Updated after change on web. Keep iOS version.
							int debug = 0;
							debug++;
						} else {
							[existedNotebook assignDataFrom:notebook];
							existedNotebook.added = existedNotebook.modified = existedNotebook.deleted = NO;
							existedNotebook.needSave = YES;
						}
					} else {
						[manrNotebooks deleteEntityFromDb:existedNotebook];
					}
				} else if(notebook.visibility) {
					[manrNotebooks addEntity:notebook];
					notebook.added = notebook.modified = notebook.deleted = NO;
					notebook.needSave = YES;
				}
			}
				
			if(arpool)
				[arpool drain];
			arpool = [[NSAutoreleasePool alloc] init];
			
			NSArray *arrDeletions = [dictData arrayValueForKey:@"Deletions" defaultIsEmpty:YES];
			for(NSDictionary *dictDeletion in arrDeletions) {
				NSString *entityName = [dictDeletion stringValueForKey:kYTJsonKeyEntity defaultVal:@""];
				if([NSString isEmpty:entityName])
					continue;
				int64_t entityId = [dictDeletion int64ValueForKey:kYTJsonKeyEntityID defaultVal:0];
				NSString *sEntityId = [dictDeletion stringValueForKey:kYTJsonKeyEntityID defaultVal:@""];
				if(entityId <= 0 && [NSString isEmpty:sEntityId]) {
					VLLoggerError(@"entityId <= 0 && [NSString isEmpty:sEntityId]");
					continue;
				}
				NSString *noteGuid = [dictDeletion stringValueForKey:kYTJsonKeyNoteID defaultVal:@""];
				if([NSString isEmpty:noteGuid])
					continue;
				[self deleteEntityDTByEntityName:entityName noteGuid:noteGuid entityId:entityId sEntityId:sEntityId];
			}
			
			if(arpool)
				[arpool drain];
			arpool = [[NSAutoreleasePool alloc] init];
			
			NSArray *arrDictNote = [dictData arrayValueForKey:@"Notes" defaultIsEmpty:YES];
			NSTimeInterval tm1 = [[NSProcessInfo processInfo] systemUptime];
			for(NSDictionary *dictNote in arrDictNote) {
				YTNoteInfo *note = [[[YTNoteInfo alloc] init] autorelease];
				[note loadFromData:dictNote urlDecode:YES];
				if([NSString isEmpty:note.noteGuid])
					continue;
				if([NSString isEmpty:note.notebookGuid]) {
					YTNotebookInfo *notebook = [manrNotebooks getNotebookByGuid:note.notebookId];
					if(!notebook)
						continue;
					note.notebookGuid = notebook.notebookGuid;
				}
				[arrReceivedNotesAll addObject:note];
				//VLLoggerTrace(@"Timing 1; %.04f s", [[NSProcessInfo processInfo] systemUptime]);
				YTNoteInfo *noteExisted = [manrNotes getNoteByGuid:note.noteGuid];
				//VLLoggerTrace(@"Timing 2; %.04f s", [[NSProcessInfo processInfo] systemUptime]);
				if(noteExisted && noteExisted.deleted && note.isValid) {
					continue;
				}
				VLDate *newLastUpdateTS = [VLDate yoditoDateWithString:[dictNote stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""]];
				if(noteExisted && [newLastUpdateTS compare:noteExisted.lastUpdateTS] < 0 && noteExisted.modified) {
					// Updated after change on web. Keep iOS note version.
					int debug = 0;
					debug++;
				} else {
					[manrNotes updateNoteWithNewNote:note fromWebWithData:dictNote];
					[arrReceivedNotes addObject:note];
				}
			}
			NSTimeInterval tm2 = [[NSProcessInfo processInfo] systemUptime];
			VLLoggerTrace(@"Parsed notes, %d count; %.04f s", arrDictNote.count, tm2 - tm1);
				
			if(arpool)
				[arpool drain];
			arpool = [[NSAutoreleasePool alloc] init];
			
			NSArray *arrDictAttachment = [self arrayOfEntitiesDictionariesInRootObject:[dictData objectForKey:@"Attachments"]];
			tm1 = [[NSProcessInfo processInfo] systemUptime];
			for(NSDictionary *dictEntity in arrDictAttachment) {
				YTResourceInfo *entity = [[[YTResourceInfo alloc] init] autorelease];
				[entity loadFromData:dictEntity urlDecode:YES];
				NSString *noteGuid = [dictEntity objectForKey:kYTJsonKeyNoteGUID];
				if([NSString isEmpty:noteGuid])
					continue;
				YTNoteInfo *note = [manrNotes getNoteByGuid:noteGuid];
				if(!note)
					continue;
				YTResourceInfo *existedEntity = [manrResources getResourceById:entity.attachmentId];
				if(existedEntity) {
					YTNoteToResourceInfo *existedInfo = [manrNoteResources getNoteResourceByNoteGuid:note.noteGuid resourceId:entity.attachmentId];
					if(existedEntity.deleted || (existedInfo && existedInfo.deleted)) {
						// It was deleted on client. Skip so deletion will sync to server.
						existedEntity.deleted = YES;
						continue;
					}
					[existedEntity assignDataFrom:entity];
					existedEntity.added = existedEntity.modified = existedEntity.deleted = NO;
					existedEntity.needSave = YES;
				} else {
					[manrResources addEntity:entity];
					entity.added = entity.modified = entity.deleted = NO;
					entity.needSave = YES;
				}
				if(note) {
					YTNoteToResourceInfo *info = [manrNoteResources addNoteResourceWithNoteGuid:note.noteGuid resourceId:entity.attachmentId];
					info.added = info.modified = NO;
				}
			}
			tm2 = [[NSProcessInfo processInfo] systemUptime];
			VLLoggerTrace(@"Parsed attachments, %d count; %.04f s", arrDictAttachment.count, tm2 - tm1);
				
			if(arpool)
				[arpool drain];
			arpool = [[NSAutoreleasePool alloc] init];
			
			NSArray *arrDictTag = [dictData arrayValueForKey:@"Tags" defaultIsEmpty:YES];
			if(arrDictTag.count && ObjectCast([arrDictTag objectAtIndex:0], NSArray))
				arrDictTag = [arrDictTag objectAtIndex:0];
			for(NSDictionary *dictEntity in arrDictTag) {
				YTTagInfo *entity = [[[YTTagInfo alloc] init] autorelease];
				[entity loadFromData:dictEntity urlDecode:YES];
				NSString *noteGuid = [dictEntity objectForKey:kYTJsonKeyNoteGUID];
				if([NSString isEmpty:noteGuid])
					continue;
				YTTagInfo *existedEntity = [manrTags getTagById:entity.tagId];
				if(existedEntity) {
					[existedEntity assignDataFrom:entity];
					existedEntity.added = existedEntity.modified = existedEntity.deleted = NO;
					existedEntity.needSave = YES;
					entity = existedEntity;
				} else {
					[manrTags addEntity:entity];
					entity.added = entity.modified = entity.deleted = NO;
					entity.needSave = YES;
				}
				YTNoteInfo *note = [manrNotes getNoteByGuid:noteGuid];
				if(note) {
					YTNoteToTagInfo *existedInfo = [manrNoteTags getNoteTagByNoteGuid:note.noteGuid tagId:entity.tagId];
					if(existedInfo && existedInfo.deleted) {
						// It was deleted on client. Skip so deletion will sync to server.
					} else {
						YTNoteToTagInfo *info = [manrNoteTags addNoteTagWithNoteGuid:note.noteGuid tagId:entity.tagId];
						info.added = info.modified = NO;
					}
				}
			}
			
			NSArray *arrDictLocation = [dictData arrayValueForKey:@"Locations" defaultIsEmpty:YES];
			if(arrDictLocation.count && ObjectCast([arrDictLocation objectAtIndex:0], NSArray))
				arrDictLocation = [arrDictLocation objectAtIndex:0];
			for(NSDictionary *dictEntity in arrDictLocation) {
				YTLocationInfo *entity = [[[YTLocationInfo alloc] init] autorelease];
				[entity loadFromData:dictEntity urlDecode:YES];
				NSString *noteGuid = [dictEntity objectForKey:kYTJsonKeyNoteGUID];
				if([NSString isEmpty:noteGuid])
					continue;
				YTLocationInfo *existedEntity = [manrLocations getLocationById:entity.locationId];
				if(existedEntity) {
					[existedEntity assignDataFrom:entity];
					existedEntity.added = existedEntity.modified = existedEntity.deleted = NO;
					existedEntity.needSave = YES;
					entity = existedEntity;
				} else {
					[manrLocations addEntity:entity];
					entity.added = entity.modified = entity.deleted = NO;
					entity.needSave = YES;
				}
				YTNoteInfo *note = [manrNotes getNoteByGuid:noteGuid];
				if(note) {
					YTNoteToLocationInfo *existedInfo = [manrNoteLocations getNoteLocationByNoteGuid:note.noteGuid locationId:entity.locationId];
					if(existedInfo && existedInfo.deleted) {
						// It was deleted on client. Skip so deletion will sync to server.
					} else {
						YTNoteToLocationInfo *info = [manrNoteLocations addNoteLocationWithNoteGuid:note.noteGuid locationId:entity.locationId];
						info.added = info.deleted = info.modified = NO;
					}
				}
			}
				
			if(arpool)
				[arpool drain];
			arpool = [[NSAutoreleasePool alloc] init];
				
			if(arpool)
				[arpool drain];
			arpool = [[NSAutoreleasePool alloc] init];
				
			if(arpool)
				[arpool drain];
			arpool = nil;
			
			if(arpoolMain)
				[arpoolMain drain];
			arpoolMain = nil;
			
			NSTimeInterval tmTotal2 = [[NSProcessInfo processInfo] systemUptime];
			VLLoggerTrace(@"Parsed all response; %.04f s", tmTotal2 - tmTotal1);
	
			int notesCountReceivedInCurPage = (int)arrDictNote.count;
			int newProcessedNotesCount = (int)(processedNotesCount + arrDictNote.count);
			if(newProcessedNotesCount >= totalNotes || notesCountReceivedInCurPage == 0) {
				resultBlockDT();
			} else {
				[self startCheckSyncChunkDTWithTicket:ticket
										currentPage:currentPage + 1
								processedNotesCount:newProcessedNotesCount
										  outErrors:outErrors
										resultBlockDT:^()
				{
					resultBlockDT();
				}];
			}
			
#ifdef kYTSyncChunkManager_SyncInBackground
		//}];
#endif
				
		}];
	}];
}

- (void)dealloc {
	[super dealloc];
}

@end

