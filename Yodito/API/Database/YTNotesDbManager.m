
#import "YTNotesDbManager.h"
#import "YTDatabaseManager.h"
#import "../Notes/Classes.h"
#import "YTNotesContentDbManager.h"
#import "YTNotebooksDbManager.h"
#import "YTNoteToResourceDbManager.h"

static YTNotesDbManager *_shared;

@implementation YTNotesDbManager

+ (YTNotesDbManager *)shared {
	if(!_shared)
		_shared = [[YTNotesDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTNoteInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
		_mapNoteByGuid = [[NSMutableDictionary alloc] init];
		_mapNotesByNotebookGuid = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)initialize {
	[super initialize];
}

- (void)loadEntitiesFromDb {
	[super loadEntitiesFromDb];
	[_mapNoteByGuid removeAllObjects];
	for(YTNoteInfo *entity in self.entities)
		[_mapNoteByGuid setObject:entity forKey:entity.noteGuid];
	[_mapNotesByNotebookGuid removeAllObjects];
	for(YTNoteInfo *entity in self.entities) {
		NSMutableArray *array = [_mapNotesByNotebookGuid objectForKey:entity.notebookGuid];
		if(!array) {
			array = [NSMutableArray array];
			[_mapNotesByNotebookGuid setObject:array forKey:entity.notebookGuid];
		}
		[array addObject:entity];
	}
}

- (void)addEntity:(VLSqliteEntity *)entity {
	[super addEntity:entity];
	[_mapNoteByGuid setObject:entity forKey:((YTNoteInfo *)entity).noteGuid];
	NSMutableArray *array = [_mapNotesByNotebookGuid objectForKey:((YTNoteInfo *)entity).notebookGuid];
	if(!array) {
		array = [NSMutableArray array];
		[_mapNotesByNotebookGuid setObject:array forKey:((YTNoteInfo *)entity).notebookGuid];
	}
	[array addObject:entity];
}

- (void)deleteEntityFromDb:(VLSqliteEntity *)entity {
	[super deleteEntityFromDb:entity];
	[_mapNoteByGuid removeObjectForKey:((YTNoteInfo *)entity).noteGuid];
	NSMutableArray *array = [_mapNotesByNotebookGuid objectForKey:((YTNoteInfo *)entity).notebookGuid];
	if(array)
		[array removeObject:entity];
}

- (void)deleteAllEntitiesFromDb {
	[super deleteAllEntitiesFromDb];
	[_mapNoteByGuid removeAllObjects];
	[_mapNotesByNotebookGuid removeAllObjects];
}

- (YTNoteInfo *)getNoteByGuid:(NSString *)noteGuid {
	[self checkIsDatabaseThread];
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	return [_mapNoteByGuid objectForKey:noteGuid];
}

- (NSArray *)getNotesByNotebookGuid:(NSString *)notebookGuid {
	[self checkIsDatabaseThread];
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	NSMutableArray *array = [_mapNotesByNotebookGuid objectForKey:notebookGuid];
	return array ? array : [NSArray array];
}

- (NSDictionary *)getMapNoteByGuid {
	[self checkIsDatabaseThread];
	return _mapNoteByGuid;
}

- (YTNoteInfo *)getNoteByResourceId:(int64_t)resourceId {
	[self checkIsDatabaseThread];
	NSDictionary *map = [[YTNoteToResourceDbManager shared] getNoteResourcesByResourceId:resourceId];
	if(!map.count)
		return nil;
	YTNoteToResourceInfo *info = [map.allValues objectAtIndex:0];
	YTNoteInfo *note = [self getNoteByGuid:info.noteGuid];
	return note;
}

- (void)changeNote:(YTNoteInfo *)note withNotebookGuid:(NSString *)notebookGuid notebookId:(int64_t)notebookId {
	[self checkIsDatabaseThread];
	note.notebookId = notebookId;
	if(![note.notebookGuid isEqual:notebookGuid]) {
		NSMutableArray *array = [_mapNotesByNotebookGuid objectForKey:note.notebookGuid];
		if(array)
			[array removeObject:note];
		note.notebookGuid = notebookGuid;
		array = [_mapNotesByNotebookGuid objectForKey:note.notebookGuid];
		if(!array) {
			array = [NSMutableArray array];
			[_mapNotesByNotebookGuid setObject:array forKey:note.notebookGuid];
		}
		[array addObject:note];
	}
}

- (NSString *)apiOperationForDelete {
	[self checkIsDatabaseThread];
	return kYTUrlValueOperationDeleteNote;
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	[self checkIsDatabaseThread];
	return kYTUrlValueOperationCreateNote;
}

- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity {
	[self checkIsDatabaseThread];
	YTNoteInfo *note = ObjectCast(entity, YTNoteInfo);
	if(![NSString isEmpty:note.contentToUpdateFromIPhone])
		return kYTUrlValueOperationUpdateNoteFromiPhone2;
	return kYTUrlValueOperationUpdateNote;
}

- (NSString *)apiOperationForList {
	[self checkIsDatabaseThread];
	return kYTUrlValueOperationListNotes;
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	[self checkIsDatabaseThread];
	YTNoteInfo *note = (YTNoteInfo *)entity;
	[postValues addObject:note.noteGuid ? note.noteGuid : @""];
	[postValues addObject:[note.lastUpdateTS yoditoToString]];
}

- (NSString *)stringForAddPostFromEntity:(YTNoteInfo *)entity {
	[self checkIsDatabaseThread];
	NSString *sFormat = @"{\n\
\"NotebookGUID\": \"%@\",\n\
\"NoteGUID\": \"%@\",\n\
\"PriorityId\": %@,\n\
\"CreatedDate\": \"%@\",\n\
\"LastUpdateTS\": \"%@\",\n\
\"Title\": \"%@\",\n\
\"Content\": \"%@\",\n\
\"Characters\": %d,\n\
\"Words\": %d,\n\
\"IsValid\": %@,\n\
\"HasAttachment\": %@,\n\
\"HasTag\": %@,\n\
\"HasLocation\": %@,\n\
\"ActionStatus\": null\n\
}";
	NSString *sTitle = [[YTNoteHtmlParser shared] urlEncode:entity.title];
	NSString *sContent = [[YTNoteHtmlParser shared] urlEncode:[[YTNotesContentDbManager shared] readContentWithNoteGuid:entity.noteGuid]];
	NSString *sPriority = entity.priorityId ? [[NSNumber numberWithLongLong:entity.priorityId] stringValue] : @"null";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   entity.notebookGuid,
					   entity.noteGuid,
					   sPriority,
					   [entity.createdDate yoditoToString],
					   [entity.lastUpdateTS yoditoToString],
					   sTitle,
					   sContent,
					   entity.characters,
					   entity.words,
					   entity.isValid ? @"\"true\"" : @"null",
					   entity.hasAttachment ? @"\"true\"" : @"null",
					   entity.hasTag ? @"\"true\"" : @"null",
					   entity.hasLocation ? @"\"true\"" : @"null"
					   ];
	return sData;
	/*[self checkIsDatabaseThread];
	NSString *sFormat = @"{\n\
	\"NotebookGUID\": \"%@\",\n\
	\"NoteGUID\": \"%@\",\n\
	\"PriorityId\": %@,\n\
	\"CreatedDate\": \"%@\",\n\
	\"LastUpdateTS\": \"%@\",\n\
	\"Title\": \"%@\",\n\
	\"Content\": \"%@\",\n\
	\"Characters\": %d,\n\
	\"Words\": %d,\n\
	\"DueDate\": \"%@\",\n\
	\"EndDate\": \"%@\",\n\
	\"IsCheckList\": %@,\n\
	\"IsValid\": %@,\n\
	\"ToDoActionId\": %lld,\n\
	\"HasLocation\": %@,\n\
	\"Recurrenceid\": %@,\n\
	\"Author\": \"%@\",\n\
	\"IOSEventId\": null,\n\
	\"ActionStatus\": %@\n\
	}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   entity.notebookGuid,
					   entity.noteGuid,
					   entity.priorityId ? [[NSNumber numberWithLongLong:entity.priorityId] stringValue] : @"null",
					   [entity.createdDate yoditoToString],
					   [entity.lastUpdateTS yoditoToString],
					   [[YTNoteHtmlParser shared] urlEncode:entity.title],
					   [[YTNoteHtmlParser shared] urlEncode:[[YTNotesContentDbManager shared] readContentWithNoteGuid:entity.noteGuid]],
					   entity.characters,
					   entity.words,
					   [entity.dueDate yoditoToString],
					   [entity.endDate yoditoToString],
					   @"null",//entity.isCheckList ? @"\"true\"" : @"null",
					   entity.isValid ? @"\"true\"" : @"null",
					   0,//entity.todoActionId,
					   //entity.status ? @"\"true\"" : @"null",
					   //entity.actionStatus ? @"1" : @"null",
					   entity.hasLocation ? @"\"true\"" : @"null",
					   @"null",//entity.recurrenceId ? [[NSNumber numberWithLongLong:entity.recurrenceId] stringValue] : @"null",
					   @"",//[YTWebRequest escapeJsonText:entity.author],
					   @"null"//entity.actionStatus ? @"1" : @"null"
					   ];
	return sData;*/
}

- (NSString *)stringForModifyPostFromEntity:(YTNoteInfo *)entity {
	[self checkIsDatabaseThread];
	NSString *sFormat = @"{\n\
	\"NotebookGUID\": \"%@\",\n\
	\"NoteGUID\": \"%@\",\n\
	\"PriorityId\": %@,\n\
	\"CreatedAt\": \"%@\",\n\
	\"CreatedDate\": \"%@\",\n\
	\"LastUpdateTS\": \"%@\",\n\
	\"Title\": \"%@\",\n\
	\"Content\": \"%@\",\n\
	\"Characters\": %d,\n\
	\"Words\": %d,\n\
	\"DueDate\": \"%@\",\n\
	\"EndDate\": \"%@\",\n\
	\"IsValid\": %@,\n\
	\"HasAttachment\": %@,\n\
	\"HasTag\": %@,\n\
	\"HasLocation\": %@,\n\
	\"NoteChanges\":[\n\
	\n\
	]\n\
	}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   entity.notebookGuid,
					   entity.noteGuid,
					   entity.priorityId ? [[NSNumber numberWithLongLong:entity.priorityId] stringValue] : @"null",
					   entity.createdAt ? [[NSNumber numberWithLongLong:entity.createdAt] stringValue] : @"null",
					   [entity.createdDate yoditoToString],
					   [entity.lastUpdateTS yoditoToString],
					   [[YTNoteHtmlParser shared] urlEncode:entity.title],
					   [[YTNoteHtmlParser shared] urlEncode:[[YTNotesContentDbManager shared] readContentWithNoteGuid:entity.noteGuid]],
					   entity.characters,
					   entity.words,
					   [entity.dueDate yoditoToString],
					   [entity.endDate yoditoToString],
					   entity.isValid ? @"\"true\"" : @"null",
					   entity.hasAttachment ? @"\"true\"" : @"null",
					   entity.hasTag ? @"\"true\"" : @"null",
					   entity.hasLocation ? @"\"true\"" : @"null"
					   ];
	return sData;
	/*[self checkIsDatabaseThread];
	NSString *sFormat = @"{\n\
	\"NotebookGUID\": \"%@\",\n\
	\"NoteGUID\": \"%@\",\n\
	\"PriorityId\": %@,\n\
	\"CreatedAt\": \"%@\",\n\
	\"CreatedDate\": \"%@\",\n\
	\"LastUpdateTS\": \"%@\",\n\
	\"Title\": \"%@\",\n\
	\"Content\": \"%@\",\n\
	\"Characters\": %d,\n\
	\"Words\": %d,\n\
	\"DueDate\": \"%@\",\n\
	\"EndDate\": \"%@\",\n\
	\"IsCheckList\": %@,\n\
	\"IsValid\": %@,\n\
	\"ToDoActionId\": %lld,\n\
	\"HasLocation\": %@,\n\
	\"Recurrenceid\": %@,\n\
	\"NoteChanges\":[\n\
	\n\
	],\n\
	\"Author\": \"%@\",\n\
	\"Favicon\": null,\n\
	\"IOSEventId\": null,\n\
	\"ActionStatus\": %@\n\
	}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   entity.notebookGuid,
					   entity.noteGuid,
					   entity.priorityId ? [[NSNumber numberWithLongLong:entity.priorityId] stringValue] : @"null",
					   entity.createdAt ? [[NSNumber numberWithLongLong:entity.createdAt] stringValue] : @"null",
					   [entity.createdDate yoditoToString],
					   [entity.lastUpdateTS yoditoToString],
					   [[YTNoteHtmlParser shared] urlEncode:entity.title],
					   [[YTNoteHtmlParser shared] urlEncode:[[YTNotesContentDbManager shared] readContentWithNoteGuid:entity.noteGuid]],
					   entity.characters,
					   entity.words,
					   [entity.dueDate yoditoToString],
					   [entity.endDate yoditoToString],
					   @"null",//entity.isCheckList ? @"\"true\"" : @"null",
					   entity.isValid ? @"\"true\"" : @"null",
					   0,//entity.todoActionId,
					   //entity.status ? @"\"true\"" : @"null",
					   //entity.actionStatus ? @"1" : @"null",
					   //entity.actionStatus ? @"1" : @"0",
					   entity.hasLocation ? @"\"true\"" : @"null",
					   @"null",//entity.recurrenceId ? [[NSNumber numberWithLongLong:entity.recurrenceId] stringValue] : @"null",
					   @"",//[YTWebRequest escapeJsonText:entity.author],
					   //![NSString isEmpty:entity.favicon] ? [NSString stringWithFormat:@"\"%@\"", entity.favicon] : @"null",
					   @"null"//entity.actionStatus ? @"1" : @"null"
					   ];
	return sData;*/
}

- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip {
	[self checkIsDatabaseThread];
	YTNoteInfo *note = ObjectCast(entity, YTNoteInfo);
	[postValues addObject:note.notebookGuid ? note.notebookGuid : @""];
	[postValues addObject:[self stringForAddPostFromEntity:note]];
}

- (void)getRequestForModifyEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	[self checkIsDatabaseThread];
	YTNoteInfo *note = ObjectCast(entity, YTNoteInfo);
	if(![NSString isEmpty:note.contentToUpdateFromIPhone]) {
		//[postValues addObject:[self stringForModifyPostFromEntity:note]];
		NSString *sFormat =
		@"{\n\
		\"NoteGUID\": \"%@\"\n\
		}";
		NSString *sData = [NSString stringWithFormat:sFormat,
						   note.noteGuid
						   ];
		[postValues addObject:sData];
		NSString *contentToUpdate = note.contentToUpdateFromIPhone;
		//NSString *contentToUpdateEncoded = [[YTNoteHtmlParser shared] urlEncode:contentToUpdate];
		[postValues addObject:contentToUpdate ? contentToUpdate : @""];
	} else {
		[postValues addObject:[self stringForModifyPostFromEntity:note]];
	}
}

- (BOOL)canPerformOperationWithEntity:(YTEntityBase *)entity syncType:(EYTSyncOperationType)syncType {
	[self checkIsDatabaseThread];
	return YES;
}

- (void)onRequestFailedWithEntity:(YTEntityBase *)entity param:(NSObject *)param syncType:(EYTSyncOperationType)syncType error:(NSError *)error {
	[self checkIsDatabaseThread];
}

- (void)getRequestsParamsForList:(NSMutableArray *)arrRequestsParams {
	[self checkIsDatabaseThread];
	YTNotebooksDbManager *manrNotebooks = [YTNotebooksDbManager shared];
	NSMutableArray *parentEntitiesToSync = [NSMutableArray arrayWithArray:manrNotebooks.entities];
	[arrRequestsParams addObjectsFromArray:parentEntitiesToSync];
}

- (void)getRequestForListWithParam:(NSObject *)param postValues:(NSMutableArray *)postValues {
	YTNotebookInfo *notebook = ObjectCast(param, YTNotebookInfo);
	[postValues addObject:notebook.notebookGuid ? notebook.notebookGuid : @""];
	[postValues addObject:@"True"]; // True/False - With content or without it
}

- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities {
	[self checkIsDatabaseThread];
	NSTimeInterval tm1 = [[NSProcessInfo processInfo] systemUptime];
	for(NSDictionary *data in arrData) {
		
		NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
		
		YTNoteInfo *note = [[YTNoteInfo new] autorelease];
		[note loadFromData:data urlDecode:YES];
		
		if(note.isValid) {
			NSString *content = [data stringValueForKey:kYTJsonKeyContent defaultVal:@""];
			content = [[YTNoteHtmlParser shared] urlDecode:content];
			int wordsCount = 0;
			int charsCount = 0;
			note.contentLimited = [YTNoteInfo getContentLimitedWithContent:content wordsCount:&wordsCount charsCount:&charsCount];
			
			YTNotesContentDbManager *manrCont = [YTNotesContentDbManager shared];
			
			VLDate *lastUpdateTS = [[note.lastUpdateTS copy] autorelease];
			[YTEntityBase setModifyingBreakpointDisabled];
			
			[manrCont writeConent:content toNoteWithGuid:note.noteGuid];
			
			note.lastUpdateTS = lastUpdateTS;
			[YTEntityBase resetModifyingBreakpointDisabled];
			
			NSString *sLastUpdateTS = [data stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""];
			if([NSString isEmpty:sLastUpdateTS]) {
				int idebug = 0;
				idebug++;
			}
			note.lastUpdateTS = [VLDate yoditoDateWithString:sLastUpdateTS];
			note.added = note.deleted = note.modified = note.needSave = NO;
			
			[arrEntities addObject:note];
		}
		
		[arpool drain];
	}
	NSTimeInterval tm2 = [[NSProcessInfo processInfo] systemUptime];
	VLLogEvent(([NSString stringWithFormat:@"%0.4f s", tm2 - tm1]));
}

- (void)updateNoteWithNewNote:(YTNoteInfo *)newNote fromWebWithData:(NSDictionary *)dictData {
	[self checkIsDatabaseThread];
	YTNoteInfo *noteExisted = [self getNoteByGuid:newNote.noteGuid];
	YTNotesContentDbManager *manrCont = [YTNotesContentDbManager shared];
	NSString *content = [dictData stringValueForKey:kYTJsonKeyContent defaultVal:@""];
	int wordsCount = 0;
	int charsCount = 0;
	NSString *contentLimited = [YTNoteInfo getContentLimitedWithContent:content wordsCount:&wordsCount charsCount:&charsCount];
	content = [[YTNoteHtmlParser shared] urlDecode:content];
	NSString *sLastUpdateTS = [dictData stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""];
	VLDate *newLastUpdateTS = [VLDate yoditoDateWithString:sLastUpdateTS];
	if(noteExisted) {
		if(newNote.isValid) {
			if([newLastUpdateTS compare:noteExisted.lastUpdateTS] < 0 && noteExisted.modified) {
				// Updated after change on web. Keep iOS note version.
				int debug = 0;
				debug++;
			} else {
				[self changeNote:noteExisted withNotebookGuid:newNote.notebookGuid notebookId:newNote.notebookId];
				[noteExisted assignDataFrom:newNote];
				noteExisted.contentLimited = contentLimited;
				//[manrCont writeConent:content toNoteWithGuid:noteExisted.noteGuid];
				noteExisted.lastUpdateTS = newLastUpdateTS;
				noteExisted.modified = noteExisted.added = noteExisted.deleted = NO;
				noteExisted.needSave = YES;
			}
			[manrCont writeConent:content toNoteWithGuid:newNote.noteGuid];
		} else {
			[self deleteEntityFromDb:noteExisted];
		}
	} else if(newNote.isValid) {
		newNote.contentLimited = contentLimited;
		[self addEntity:newNote];
		[manrCont writeConent:content toNoteWithGuid:newNote.noteGuid];
		newNote.lastUpdateTS = newLastUpdateTS;
		newNote.modified = newNote.added = newNote.deleted = NO;
		newNote.needSave = YES;
	}
}

- (void)dealloc {
	[super dealloc];
}

@end

