
#import "YTNotebooksDbManager.h"
#import "YTDatabaseManager.h"
#import "../Notes/Classes.h"
#import "YTStacksDbManager.h"
#import "YTUsersDbManager.h"
#import "YTNotesDbManager.h"

static YTNotebooksDbManager *_shared;

@implementation YTNotebooksDbManager

+ (YTNotebooksDbManager *)shared {
	if(!_shared)
		_shared = [[YTNotebooksDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTNotebookInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
		_mapNotebooks = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)initialize {
	[super initialize];
}

- (void)loadEntitiesFromDb {
	[super loadEntitiesFromDb];
	[_mapNotebooks removeAllObjects];
	for(YTNotebookInfo *entity in self.entities)
		[_mapNotebooks setObject:entity forKey:entity.notebookGuid];
}

- (void)addEntity:(VLSqliteEntity *)entity {
	[super addEntity:entity];
	[_mapNotebooks setObject:entity forKey:((YTNotebookInfo *)entity).notebookGuid];
}

- (void)deleteEntityFromDb:(VLSqliteEntity *)entity {
	[super deleteEntityFromDb:entity];
	[_mapNotebooks removeObjectForKey:((YTNotebookInfo *)entity).notebookGuid];
}

- (void)deleteAllEntitiesFromDb {
	[super deleteAllEntitiesFromDb];
	[_mapNotebooks removeAllObjects];
}

- (YTNotebookInfo *)getNotebookByGuid:(NSString *)notebookGuid {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	return [_mapNotebooks objectForKey:notebookGuid];
}

- (NSDictionary *)getMapNotebookByGuid {
	return _mapNotebooks;
}

- (NSString *)apiOperationForDelete {
	return kYTUrlValueOperationDeleteNotebook;
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	return kYTUrlValueOperationCreateNotebook;
}

- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity {
	return kYTUrlValueOperationUpdateNotebook;
}

- (NSString *)apiOperationForList {
	return kYTUrlValueOperationListNotebooks;
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	YTNotebookInfo *notebook = ObjectCast(entity, YTNotebookInfo);
	[postValues addObject:notebook.notebookGuid ? notebook.notebookGuid : @""];
	//[postValues addObject:[notebook.lastUpdateTS yoditoToString]];
}

- (NSString *)stringForPostFromEntity:(YTNotebookInfo *)entity {
	NSString *sFormat = @"{\n\
\"NotebookGUID\": \"%@\",\n\
\"StackId\": \"%@\",\n\
\"ColourId\": \"%@\",\n\
\"LastUpdateTS\": \"%@\",\n\
\"Name\": \"%@\",\n\
\"Visibility\": %d,\n\
\"IsDefault\": %d\n\
}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   entity.notebookGuid,
					   entity.stackId ? [[NSNumber numberWithLongLong:entity.stackId] stringValue] : @"null",
					   entity.colorId ? [[NSNumber numberWithLongLong:entity.colorId] stringValue] : @"0",//@"null",
					   [entity.lastUpdateTS yoditoToString],
					   [[YTNoteHtmlParser shared] urlEncode:entity.name],
					   entity.visibility ? 1 : 0,
					   entity.isDefault ? 1 : 0
					   ];
	return sData;
}

- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip {
	YTNotebookInfo *notebook = ObjectCast(entity, YTNotebookInfo);
	[postValues addObject:[self stringForPostFromEntity:notebook]];
}

- (void)getRequestForModifyEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	YTNotebookInfo *notebook = ObjectCast(entity, YTNotebookInfo);
	[postValues addObject:[self stringForPostFromEntity:notebook]];
}

- (void)onRequestFailedWithEntity:(YTEntityBase *)entity param:(NSObject *)param syncType:(EYTSyncOperationType)syncType error:(NSError *)error {
	//if(syncType == EYTSyncOperationTypeAdd || syncType == EYTSyncOperationTypeModify || syncType == EYTSyncOperationTypeDelete) {
	//	if(kYTStopSyncSubentitiesIfErrorReceived)
	//		[self.entitiesFailedToSync addObject:entity];
	//}
}

- (void)getRequestsParamsForList:(NSMutableArray *)arrRequestsParams {
	YTStacksDbManager *manrStacks = [YTStacksDbManager shared];
	[arrRequestsParams addObjectsFromArray:manrStacks.entities];
}

- (void)getRequestForListWithParam:(NSObject *)param postValues:(NSMutableArray *)postValues {
	YTStackInfo *stack = ObjectCast(param, YTStackInfo);
	[postValues addObject:[NSNumber numberWithLongLong:stack.stackId]];
	[postValues addObject:[[VLDate empty] yoditoToString]];
}

- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities {
	for(NSDictionary *data in arrData) {
		YTNotebookInfo *notebook = [[[YTNotebookInfo alloc] init] autorelease];
		[notebook loadFromData:data urlDecode:YES];
		[arrEntities addObject:notebook];
	}
	NSArray *curEntities = self.entities;
	for(YTNotebookInfo *curEntity in curEntities) {
		for(YTNotebookInfo *newEntity in arrEntities) {
			if([curEntity compareIdentityTo:newEntity] == 0) {
				if([curEntity.lastUpdateTS isEqual:newEntity.lastUpdateTS]) {
					//if(!kYTFullSyncEventIfTimeStampsEqual)
					//	[self.entitiesNotNeededToSync addObject:curEntity];
				}
			}
		}
	}
}

- (void)onBeforeSyncEntitiesAdded:(NSMutableArray *)entitiesAdded
				 entitiesModified:(NSMutableArray *)entitiesModified
				  entitiesDeleted:(NSMutableArray *)entitiesDeleted {
	[super onBeforeSyncEntitiesAdded:entitiesAdded entitiesModified:entitiesModified entitiesDeleted:entitiesDeleted];
	YTUsersDbManager *manrUsers = [YTUsersDbManager shared];
	YTUserInfo *userInfo = [manrUsers getUserInfo];
	if(userInfo.hasDemoData) {
		// Do not upload demo stacks and notebooks
		[entitiesAdded removeAllObjects];
		[entitiesModified removeAllObjects];
	}
}

- (void)onEntitiesListGotten {
	[super onEntitiesListGotten];
	YTUsersDbManager *manrUsers = [YTUsersDbManager shared];
	YTNotesDbManager *manrNotes = [YTNotesDbManager shared];
	YTUserInfo *userInfo = [manrUsers getUserInfo];
	if(userInfo.hasDemoData) {
		// Move notebooks in demo stacks to real stack
		YTNotebookInfo *bookDemo = nil;
		YTNotebookInfo *bookNew = nil;
		YTNotebookInfo *bookNewSpare = nil;
		NSArray *allBooks = self.entities;
		for(YTNotebookInfo *book in allBooks) {
			if(book.notebookId == kYTNotebookIdDemo) {
				bookDemo = book;
			} else {
				if(!bookNew) {
					if(book.isDefault)
						bookNew = book;
				}
				if(!bookNewSpare)
					bookNewSpare = book;
			}
		}
		if(!bookNew && bookNewSpare)
			bookNew = bookNewSpare;
		if(bookDemo && bookNew) {
			NSArray *notesDemo = [NSArray arrayWithArray:[manrNotes getNotesByNotebookGuid:bookDemo.notebookGuid]];
			for(YTNoteInfo *note in notesDemo) {
				//if(note.notebookId == kYTNotebookIdDemo) {
				if([note.notebookGuid isEqual:bookDemo.notebookGuid]) {
					[manrNotes changeNote:note withNotebookGuid:bookNew.notebookGuid notebookId:bookNew.notebookId];
				}
			}
		}
		if(bookDemo) {
			[self deleteEntityFromDb:bookDemo];
		}
		// All demo data moved to real book. Reset flag.
		userInfo.hasDemoData = NO;
		userInfo.needSave = YES;
	}
}

- (void)dealloc {
	[super dealloc];
}

@end

