
#import "YTDatabaseManager.h"
#import "YTUsersDbManager.h"
#import "YTNotebooksDbManager.h"
#import "YTNotesDbManager.h"
#import "YTResourcesDbManager.h"
#import "YTStacksDbManager.h"
#import "YTLocationsDbManager.h"
#import "YTTagsDbManager.h"
#import "YTNotesContentDbManager.h"
#import "YTNoteToLocationDbManager.h"
#import "YTNoteToResourceDbManager.h"
#import "YTNoteToTagDbManager.h"
#import "../Managers/Classes.h"

#define kCurrentTempIdKey @"YTDatabaseManager_kCurrentTempIdKey_2"
#define kStartTempId (-4398046511104)//(((int64_t)-1024)*4294967296)

@interface YTDatabaseManagerThreadArgs : NSObject {
@private
	VLBlockVoid _blockVoid1;
	VLBlockVoid _blockVoid2;
}

@property(nonatomic, assign) VLBlockVoid blockVoid1;
@property(nonatomic, assign) VLBlockVoid blockVoid2;

@end

@implementation YTDatabaseManagerThreadArgs

@synthesize blockVoid1 = _blockVoid1;
@synthesize blockVoid2 = _blockVoid2;

- (void)setBlockVoid1:(VLBlockVoid)blockVoid1 {
	if(_blockVoid1 != blockVoid1) {
		if(_blockVoid1) {
			Block_release(_blockVoid1);
			_blockVoid1 = nil;
		}
		if(blockVoid1)
			_blockVoid1 = Block_copy(blockVoid1);
	}
}

- (void)setBlockVoid2:(VLBlockVoid)blockVoid2 {
	if(_blockVoid2 != blockVoid2) {
		if(_blockVoid2) {
			Block_release(_blockVoid2);
			_blockVoid2 = nil;
		}
		if(blockVoid2)
			_blockVoid2 = Block_copy(blockVoid2);
	}
}

- (void)dealloc {
	self.blockVoid1 = nil;
	self.blockVoid2 = nil;
	[super dealloc];
}

@end



static YTDatabaseManager *_shared;

@implementation YTDatabaseManager

@dynamic database;
@synthesize initialized = _initialized;
@synthesize dlgtEntityIdChanged = _dlgtEntityIdChanged;

+ (YTDatabaseManager *)shared {
	if(!_shared)
		_shared = [[YTDatabaseManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		_delegates = [[NSMutableArray alloc] init];
		_managersOrdered = [[NSMutableArray alloc] init];
		_managersOrderedSavedVersions = [[NSMutableArray alloc] init];
		_dlgtEntityIdChanged = [[VLDelegate alloc] init];
		_dlgtEntityIdChanged.owner = self;
	}
	return self;
}

- (void)initializeMT {
	_thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadFunc:) object:nil];
	//double mainThreadPriority = [[NSThread mainThread] threadPriority];
	//[_thread setThreadPriority:mainThreadPriority / 2];
	[_thread start];
	//[self performSelector:@selector(initializeOnOtherThread) onThread:_thread withObject:nil waitUntilDone:YES];
	[self waitingUntilDone:NO performBlockOnDT:^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSString *databaseFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		//databaseFilePath = [databaseFilePath stringByAppendingPathComponent:kYTDatabaseFileNameNew];
		databaseFilePath = [databaseFilePath stringByAppendingPathComponent:kYTDatabaseFileName];
		_databaseManager = [[YTSqliteDatabaseManager alloc] initWithFilePath:databaseFilePath version:kYTDatabaseVersion];
		_databaseManager.delegate = self;
		
		[_databaseManager open];
		[_databaseManager initialize];
		
		[_managersOrdered addObject:[YTUsersDbManager shared]];
		[_managersOrdered addObject:[YTStacksDbManager shared]];
		[_managersOrdered addObject:[YTNotebooksDbManager shared]];
		[_managersOrdered addObject:[YTNotesDbManager shared]];
		[_managersOrdered addObject:[YTNotesContentDbManager shared]];
		[_managersOrdered addObject:[YTResourcesDbManager shared]];
		[_managersOrdered addObject:[YTLocationsDbManager shared]];
		[_managersOrdered addObject:[YTTagsDbManager shared]];
		[_managersOrdered addObject:[YTNoteToResourceDbManager shared]];
		[_managersOrdered addObject:[YTNoteToLocationDbManager shared]];
		[_managersOrdered addObject:[YTNoteToTagDbManager shared]];
		
		for(int i = 0; i < (int)_managersOrdered.count; i++)
			[_managersOrderedSavedVersions addObject:[NSNumber numberWithLongLong:0]];
		
		[pool drain];
	}];
}

- (void)initializeWithResultBlockMT:(VLBlockVoid)resultBlockMT {
	[self waitingUntilDone:NO performBlockOnDT:^{
		[self checkIsDatabaseThread];
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSTimeInterval tm1 = [[NSProcessInfo processInfo] systemUptime];
		
		for(YTDbEntitiesManager *manr in [_managersOrdered reverseObjectEnumerator])
			[manr updateTableInDb];
		
		for(YTDbEntitiesManager *manr in _managersOrdered)
			[manr initialize];
		
		[self cleanDatabase];
		
		NSTimeInterval tm2 = [[NSProcessInfo processInfo] systemUptime];
		VLLoggerTrace(@"Stage2 %0.4f s", tm2 - tm1);
		
		[pool drain];
		
		[self waitingUntilDone:NO performBlockOnMT:^{
			_initialized = YES;
			[self modifyVersion];
			resultBlockMT();
		}];
	}];
}

- (VLSqliteDatabase *)database {
	return _databaseManager.database;
}

- (void)recreateDatabase {
	[self checkIsDatabaseThread];
	[self.database dropTableWithName:kYTDbTableNoteToResource];
	[self.database dropTableWithName:kYTDbTableNoteToLocation];
	[self.database dropTableWithName:kYTDbTableNoteToTag];
	[self.database dropTableWithName:kYTDbTableTag];
	[self.database dropTableWithName:kYTDbTableResource];
	[self.database dropTableWithName:kYTDbTableLocation];
	[self.database dropTableWithName:kYTDbTableNoteContent];
	[self.database dropTableWithName:kYTDbTableNote];
	[self.database dropTableWithName:kYTDbTableNotebook];
	[self.database dropTableWithName:kYTDbTableStack];
	[self.database dropTableWithName:kYTDbTableUser];
	for(YTDbEntitiesManager *manr in [_managersOrdered reverseObjectEnumerator])
		[manr recreateTableInDb];
}

- (void)sqliteDatabaseManager:(YTSqliteDatabaseManager *)sqliteDatabaseManager databaseVersionChanged:(id)param {
	[self checkIsDatabaseThread];
	[self recreateDatabase];
}

- (BOOL)isDatabaseThread {
	return ([NSThread currentThread] == _thread);
}

- (void)checkIsDatabaseThread {
	if(![self isDatabaseThread]) {
		NSString *msg = @"EXCEPTION: YTDatabaseManager: checkIsDatabaseThread: Not database thread";
		NSLog(@"%@", msg);
		[NSException raise:msg format:@""];
	}
}

- (void)checkIsMainThread {
	if(![NSThread isMainThread]) {
		NSString *msg = @"EXCEPTION: YTDatabaseManager: checkIsMainThread: Not main thread";
		NSLog(@"%@", msg);
		[NSException raise:msg format:@""];
	}
}

- (void)threadFunc:(id)parameter {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	[runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
	
	while(YES) {
		[runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
		
		NSArray *delegates = nil;
		@synchronized(_delegates) {
			delegates = [NSArray arrayWithArray:_delegates];
		}
		for(NSObject<YTDatabaseManagerDelegate> *delegate in delegates) {
			[delegate databaseManager:self updateOnDT:nil];
		}
		for(int i = 0; i < (int)_managersOrdered.count; i++) {
			YTDbEntitiesManager *manr = [_managersOrdered objectAtIndex:i];
			int64_t versionLast = [(NSNumber *)[_managersOrderedSavedVersions objectAtIndex:i] longLongValue];
			if(versionLast != manr.version) {
				[manr saveChangesToDb];
				[_managersOrderedSavedVersions replaceObjectAtIndex:i withObject:[NSNumber numberWithLongLong:manr.version]];
			}
		}
		
		[pool drain];
		pool = [[NSAutoreleasePool alloc] init];
	}
	
	[pool drain];
}

- (void)addDelegate:(NSObject<YTDatabaseManagerDelegate> *)delegate {
	@synchronized(_delegates) {
		[_delegates addObject:delegate];
	}
}

- (void)deleteAllUserEntities {
	[self checkIsDatabaseThread];
	for(YTDbEntitiesManager *manr in [_managersOrdered reverseObjectEnumerator]) {
		if(manr != [YTUsersDbManager shared])
			[manr deleteAllEntitiesFromDb];
	}
}

- (void)checkHasAnyChangesForSyncWithResultBlock:(void(^)(BOOL result, NSString *info))resultBlock {
	[self checkIsMainThread];
	NSMutableString *info = [NSMutableString string];
	[self waitingUntilDone:NO performBlockOnDT:^
	{
		BOOL hasChanges = NO;
		for(YTDbEntitiesManager *manr in _managersOrdered) {
			NSArray *entities = [NSArray arrayWithArray:manr.entities];
			for(YTEntityBase *entity in entities) {
				if(entity.isTemporary)
					continue;
				if(entity.added && entity.deleted)
					continue;
				if(entity.added || entity.deleted || entity.modified) {
					if(ObjectCast(entity, YTNoteContentInfo)) {
						entity.added = entity.deleted = entity.modified = NO;
						continue;
					}
					if(entity.added) {
						if(ObjectCast(entity, YTTagInfo)
						   || ObjectCast(entity, YTLocationInfo)) {
							entity.added = NO;
							continue;
						}
					}
					if(entity.deleted) {
						if(ObjectCast(entity, YTTagInfo)
						   || ObjectCast(entity, YTLocationInfo)) {
							entity.deleted = NO;
							continue;
						}
					}
					if(entity.modified) {
						if(ObjectCast(entity, YTNoteToResourceInfo)
						   || ObjectCast(entity, YTNoteToLocationInfo)
						   || ObjectCast(entity, YTNoteToTagInfo)) {
							entity.modified = NO;
							continue;
						}
					}
					YTNoteToResourceInfo *noteToRes = ObjectCast(entity, YTNoteToResourceInfo);
					if(noteToRes) {
						YTResourceInfo *resource = [[YTResourcesDbManager shared] getResourceById:noteToRes.resourceId];
						if(!resource) {
							[[YTNoteToResourceDbManager shared] deleteEntityFromDb:noteToRes];
							continue;
						} else if(noteToRes.added && !resource.added) {
							noteToRes.added = NO;
							continue;
						}
						if(resource) {
							if((noteToRes.deleted || resource.deleted) && (noteToRes.deleted != resource.deleted)) {
								noteToRes.deleted = resource.deleted = YES;
							}
						}
					}
					YTNoteToLocationInfo *noteToLoc = ObjectCast(entity, YTNoteToLocationInfo);
					if(noteToLoc) {
						YTLocationInfo *location = [[YTLocationsDbManager shared] getLocationById:noteToLoc.locationId];
						if(!location) {
							[[YTNoteToLocationDbManager shared] deleteEntityFromDb:noteToLoc];
							continue;
						}/* else if(noteToLoc.added && !location.added) {
							noteToLoc.added = NO;
							continue;
						}
						if(location) {
							if((noteToLoc.deleted || location.deleted) && (noteToLoc.deleted != location.deleted)) {
								noteToLoc.deleted = location.deleted = YES;
							}
						}*/
					}
					YTNoteToTagInfo *noteToTag = ObjectCast(entity, YTNoteToTagInfo);
					if(noteToTag) {
						YTTagInfo *tag = [[YTTagsDbManager shared] getTagById:noteToTag.tagId];
						if(!tag) {
							[[YTNoteToTagDbManager shared] deleteEntityFromDb:noteToTag];
							continue;
						}/* else if(noteToTag.added && !tag.added) {
							noteToTag.added = NO;
							continue;
						}
						if(tag) {
							if((noteToTag.deleted || tag.deleted) && (noteToTag.deleted != tag.deleted)) {
								noteToTag.deleted = tag.deleted = YES;
							}
						}*/
					}
					
					hasChanges = YES;
					[info appendString:[entity description]];
					break;
				}
			}
		}
		[self waitingUntilDone:NO performBlockOnMT:^
		{
			resultBlock(hasChanges, info);
		}];
	}];
}

- (void)cleanDatabase {
	VLLoggerTrace(@"");
	[self checkIsDatabaseThread];
	YTNotebooksDbManager *manrDbNotebooks = [YTNotebooksDbManager shared];
	YTNotesDbManager *manrDbNotes = [YTNotesDbManager shared];
	YTLocationsDbManager *manrDbLocations = [YTLocationsDbManager shared];
	YTTagsDbManager *manrDbTags = [YTTagsDbManager shared];
	YTResourcesDbManager *manrDbResources = [YTResourcesDbManager shared];
	
	YTNoteToLocationDbManager *manrDbNoteLocations = [YTNoteToLocationDbManager shared];
	YTNoteToTagDbManager *manrDbNoteTags = [YTNoteToTagDbManager shared];
	YTNoteToResourceDbManager *manrDbNoteResources = [YTNoteToResourceDbManager shared];
	
	// Delete temporary:
	for(YTDbEntitiesManager *manr in [_managersOrdered reverseObjectEnumerator]) {
		for(YTEntityBase *entity in [NSArray arrayWithArray:manr.entities]) {
			if(entity.isTemporary) {
				[manr deleteEntityFromDb:entity];
			}
		}
	}
	// Delete notebooks without stack
	NSArray *stacks = [NSArray arrayWithArray:[YTStacksDbManager shared].entities];
	NSMutableSet *setStackId = [NSMutableSet set];
	for(YTStackInfo *stack in stacks)
		[setStackId addObject:[NSNumber numberWithLongLong:stack.stackId]];
	NSArray *notebooks = [NSArray arrayWithArray:manrDbNotebooks.entities];
	for(YTNotebookInfo *notebook in notebooks) {
		if(![setStackId containsObject:[NSNumber numberWithLongLong:notebook.stackId]]) {
			[manrDbNotebooks deleteEntityFromDb:notebook];
			continue;
		}
		// Delete temp && deleted:
		if(notebook.deleted && [self isTempId:notebook.notebookId]) {
			[manrDbNotebooks deleteEntityFromDb:notebook];
			continue;
		}
	}
	
	// Delete notes without notebooks:
	NSDictionary *mapNotebookByGuid = [manrDbNotebooks getMapNotebookByGuid];
	NSArray *notes = [NSArray arrayWithArray:manrDbNotes.entities];
	for(YTNoteInfo *note in notes) {
		YTNotebookInfo *notebook = [mapNotebookByGuid objectForKey:note.notebookGuid];
		if(!notebook) {
			[manrDbNotes deleteEntityFromDb:note];
			continue;
		}
		if(notebook.deleted) {
			note.deleted = YES;
		}
	}
	notes = [NSArray arrayWithArray:manrDbNotes.entities];
	
	// Remove deleted data from db for demo user
	if([YTUsersEnManager shared].isDemo) {
		for(YTNoteInfo *note in notes) {
			if(note.deleted) {
				[manrDbNotes deleteEntityFromDb:note];
			}
		}
		notes = [NSArray arrayWithArray:manrDbNotes.entities];
	}
	
	NSArray *arrLocs = [NSArray arrayWithArray:manrDbLocations.entities];
	for(YTLocationInfo *entity in arrLocs) {
		// Delete temp && deleted:
		if(entity.deleted && [self isTempId:entity.locationId]) {
			[manrDbLocations deleteEntityFromDb:entity];
			continue;
		}
	}
	// Delete locations relations without note or location:
	NSArray *arrNoteLocs = [NSArray arrayWithArray:manrDbNoteLocations.entities];
	for(YTNoteToLocationInfo *entity in arrNoteLocs) {
		YTNoteInfo *note = [manrDbNotes getNoteByGuid:entity.noteGuid];
		if(!note) {
			[manrDbNoteLocations deleteEntityFromDb:entity];
			continue;
		}
		YTLocationInfo *loc = [manrDbLocations getLocationById:entity.locationId];
		if(!loc) {
			[manrDbNoteLocations deleteEntityFromDb:entity];
			continue;
		}
	}
	arrLocs = [NSArray arrayWithArray:manrDbLocations.entities];
	for(YTLocationInfo *entity in arrLocs) {
		if(![manrDbNoteLocations getNoteLocationsById:entity.locationId].count) {
			[manrDbLocations deleteEntityFromDb:entity];
			continue;
		}
	}
	
	NSArray *arrTags = [NSArray arrayWithArray:manrDbTags.entities];
	for(YTTagInfo *entity in arrTags) {
		// Delete temp && deleted:
		if(entity.deleted && [self isTempId:entity.tagId]) {
			[manrDbTags deleteEntityFromDb:entity];
			continue;
		}
	}
	// Delete tags relations without note or tag:
	NSArray *arrNoteTags = [NSArray arrayWithArray:manrDbNoteTags.entities];
	for(YTNoteToTagInfo *entity in arrNoteTags) {
		YTNoteInfo *note = [manrDbNotes getNoteByGuid:entity.noteGuid];
		if(!note) {
			[manrDbNoteTags deleteEntityFromDb:entity];
			continue;
		}
		YTTagInfo *tag = [manrDbTags getTagById:entity.tagId];
		if(!tag) {
			[manrDbNoteTags deleteEntityFromDb:entity];
			continue;
		}
	}
	arrTags = [NSArray arrayWithArray:manrDbTags.entities];
	for(YTTagInfo *entity in arrTags) {
		if(![manrDbNoteTags getNoteTagsById:entity.tagId].count) {
			[manrDbTags deleteEntityFromDb:entity];
			continue;
		}
	}
	
	NSArray *arrRess = [NSArray arrayWithArray:manrDbResources.entities];
	for(YTResourceInfo *entity in arrRess) {
		// Delete temp && deleted:
		if(entity.deleted && [self isTempId:entity.attachmentId]) {
			[manrDbResources deleteEntityFromDb:entity];
			continue;
		}
	}
	// Delete resource relations without note or resource
	NSArray *arrNoteRess = [NSArray arrayWithArray:manrDbNoteResources.entities];
	for(YTNoteToResourceInfo *entity in arrNoteRess) {
		YTNoteInfo *note = [manrDbNotes getNoteByGuid:entity.noteGuid];
		if(!note) {
			[manrDbNoteResources deleteEntityFromDb:entity];
			continue;
		}
		YTResourceInfo *res = [manrDbResources getResourceById:entity.resourceId];
		if(!res) {
			[manrDbNoteResources deleteEntityFromDb:entity];
			continue;
		}
	}
	arrRess = [NSArray arrayWithArray:manrDbResources.entities];
	for(YTResourceInfo *entity in arrRess) {
		if(![manrDbNoteResources getNoteResourcesByResourceId:entity.attachmentId].count) {
			//[manrDbResources deleteEntityFromDb:entity];
			entity.deleted = YES;
		}
		// Delete temp && deleted:
		if(entity.deleted && [self isTempId:entity.attachmentId]) {
			[manrDbResources deleteEntityFromDb:entity];
			continue;
		}
	}
	
	/*NSDictionary *mapNoteByGuid = [manrDbNotes getMapNoteByGuid];
	NSArray *resources = [NSArray arrayWithArray:manrDbResources.entities];
	for(YTResourceInfo *resource in resources) {
		YTNoteInfo *note = [mapNoteByGuid objectForKey:resource.noteGuid];
		if(!note) {
			[manrDbResources deleteEntityFromDb:resource];
		} else if(note.deleted) {
			if(!resource.deleted) {
				resource.deleted = YES;
			}
		}
	}*/
	
	// For demo account:
	if([YTUsersEnManager shared].isDemo) {
		// Remove deleted:
		for(YTDbEntitiesManager *manr in [_managersOrdered reverseObjectEnumerator]) {
			for(YTEntityBase *entity in [NSArray arrayWithArray:manr.entities]) {
				if(entity.deleted) {
					[manr deleteEntityFromDb:entity];
				}
			}
		}
	}
	
	// Update 'has*' flags
	for(YTNoteInfo *note in notes) {
		BOOL hasAttachment = ([[YTNoteToResourceDbManager shared] getNoteResourcesByNoteGuid:note.noteGuid].count > 0);
		note.hasAttachment = hasAttachment;
		BOOL hasTag = ([[YTNoteToTagDbManager shared] getNoteTagsByNoteGuid:note.noteGuid].count > 0);
		note.hasTag = hasTag;
		BOOL hasLocation = ([[YTNoteToLocationDbManager shared] getNoteLocationsByNoteGuid:note.noteGuid].count > 0);
		note.hasLocation = hasLocation;
	}
}

- (void)cleanDatabaseWithResultBlock:(VLBlockVoid)resultBlock {
	[self checkIsMainThread];
	[self waitingUntilDone:NO performBlockOnDT:^
	{
		[self cleanDatabase];
		if(resultBlock) {
			[self waitingUntilDone:NO performBlockOnMT:^
			{
				resultBlock();
			}];
		}
	}];
}

- (void)searchNotesWithText:(NSString *)searchText resultBlock:(void(^)(NSArray *notes))resultBlock {
	[self checkIsMainThread];
	YTNotesDbManager *manrNotes = [YTNotesDbManager shared];
	YTNotesContentDbManager *manrCont = [YTNotesContentDbManager shared];
	sqlite3 *db = manrCont.database.db;
	YTNoteContentInfo *dummyEntity = [[[YTNoteContentInfo alloc] init] autorelease];
	NSMutableString *sQuery = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ LIKE '%%%@%%'",
									kYTJsonKeyNoteGUID,
									[dummyEntity dbTableName],
							   kYTJsonKeyContent,
							   searchText];
	NSMutableSet *setNoteGuids = [NSMutableSet set];
	NSMutableArray *resultNotes = [NSMutableArray array];
	[self waitingUntilDone:NO performBlockOnDT:^
	{
		sqlite3_stmt *stmt;
		int res = sqlite3_prepare_v2(db, [sQuery UTF8String], -1, &stmt, NULL);
		if(res == SQLITE_OK) {
			//int res1 = sqlite3_step(stmt);
			//if(res1 != SQLITE_OK) {
			//	VLLogError(([NSString stringWithFormat:@"%s", sqlite3_errmsg(db)]));
			//}
			while(sqlite3_step(stmt) == SQLITE_ROW) {
				const char *text = (const char *)sqlite3_column_text(stmt, 0);
				NSString *sVal = [[[NSString alloc] initWithUTF8String:text] autorelease];
				[setNoteGuids addObject:sVal];
			}
			sqlite3_finalize(stmt);
			for(YTNoteInfo *note in manrNotes.entities) {
				if(note.deleted || note.isTemporary)
					continue;
				if([setNoteGuids containsObject:note.noteGuid])
					[resultNotes addObject:note];
			}
		}
		[self waitingUntilDone:NO performBlockOnMT:^
		{
			resultBlock(resultNotes);
		}];
	}];
}

- (void)performBlockHandlerST:(YTDatabaseManagerThreadArgs *)args {
	args.blockVoid1();
	args.blockVoid1 = nil;
}

- (void)waitingUntilDone:(BOOL)wait performBlockOnDT:(VLBlockVoid)blockOnDT; {
	YTDatabaseManagerThreadArgs *args = [[[YTDatabaseManagerThreadArgs alloc] init] autorelease];
	args.blockVoid1 = blockOnDT;
	[self performSelector:@selector(performBlockHandlerST:) onThread:_thread withObject:args waitUntilDone:wait];
}

- (void)performBlockHandlerMT:(YTDatabaseManagerThreadArgs *)args {
	args.blockVoid2();
	args.blockVoid2 = nil;
}

- (void)waitingUntilDone:(BOOL)wait performBlockOnMT:(VLBlockVoid)blockOnMT {
	YTDatabaseManagerThreadArgs *args = [[[YTDatabaseManagerThreadArgs alloc] init] autorelease];
	args.blockVoid2 = blockOnMT;
	[self performSelectorOnMainThread:@selector(performBlockHandlerMT:) withObject:args waitUntilDone:wait];
}

- (int64_t)makeNewTempId {
	int64_t curId = -1;
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *num = [defs objectForKey:kCurrentTempIdKey];
	if(num) {
		curId = [num longLongValue];
	} else {
		curId = kStartTempId;
	}
	int64_t newId = curId - 1;
	num = [NSNumber numberWithLongLong:newId];
	[defs setObject:num forKey:kCurrentTempIdKey];
	return [num longLongValue];
	return newId;
}

- (BOOL)isTempId:(int64_t)nId {
	return (nId < kStartTempId);
}

- (void)notifyIdChangedForEntiy:(YTEntityBase *)entity formId:(int64_t)idLast toId:(int64_t)idNew {
	[self checkIsDatabaseThread];
	YTEntityIdChangedArgs *args = [[[YTEntityIdChangedArgs alloc] init] autorelease];
	args.entity = entity;
	args.idLast = idLast;
	args.idNew = idNew;
	[_dlgtEntityIdChanged sendMessage:self withArgs:args];
}

- (void)dealloc {
	[super dealloc];
}

@end





@implementation YTEntityIdChangedArgs

@synthesize entity = _entity;
@synthesize idLast = _idLast;
@synthesize idNew = _idNew;

- (void)dealloc {
	self.entity = nil;
	[super dealloc];
}

@end




