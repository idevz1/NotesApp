
#import "YTNotesEnManager.h"
#import "YTNoteToResourceEnManager.h"

static YTNotesEnManager *_shared;

@implementation YTNotesEnManager

+ (YTNotesEnManager *)shared {
	if(!_shared)
		_shared = [[YTNotesEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		_mapNotesByGuid = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapNotesByGuidST = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapNotesInNotebooks = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapNotesInNotebooksST = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_arrNotes = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_arrNotesST = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_arrNotesStarred = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_arrNotesStarredST = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTNotesDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTNotesDbManager *manrDb = [YTNotesDbManager shared];
	[manrDb loadEntitiesFromDb];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTNotesDbManager *manrDbNotes = [YTNotesDbManager shared];
	int64_t curVersionST = manrDbNotes.version;
	if(_lastVersionST != curVersionST) {
		[_mapNotesByGuidST removeAllObjects];
		[_mapNotesInNotebooksST removeAllObjects];
		[_arrNotesST removeAllObjects];
		[_arrNotesStarredST removeAllObjects];
		NSArray *allNotes = manrDbNotes.entities;
		_notesStarredCountST = 0;
		for(YTNoteInfo *note in allNotes) {
			if(note.deleted)
				continue;
			NSString *noteGuid = note.noteGuid;
			if([NSString isEmpty:noteGuid])
				continue;
			NSString *bookGuid = note.notebookGuid;
			if([NSString isEmpty:bookGuid])
				continue;
			[_arrNotesST addObject:note];
			if(note.priorityId > EYTPriorityTypeNone)
				[_arrNotesStarredST addObject:note];
			[_mapNotesByGuidST setObject:note forKey:noteGuid];
			NSMutableArray *notes = [_mapNotesInNotebooksST objectForKey:bookGuid];
			if(!notes) {
				notes = [NSMutableArray array];
				[_mapNotesInNotebooksST setObject:notes forKey:bookGuid];
			}
			[notes addObject:note];
		}
		_lastVersionST = curVersionST;
		_updatingMT = YES;
	}
}

- (void)updateOnMT {
	[super updateOnMT];
	if(!_updatingMT)
		return;
	[_mapNotesByGuid removeAllObjects];
	[_mapNotesByGuid addEntriesFromDictionary:_mapNotesByGuidST];
	[_mapNotesInNotebooks removeAllObjects];
	[_mapNotesInNotebooks addEntriesFromDictionary:_mapNotesInNotebooksST];
	[_arrNotes removeAllObjects];
	[_arrNotes addObjectsFromArray:_arrNotesST];
	[_arrNotesStarred removeAllObjects];
	[_arrNotesStarred addObjectsFromArray:_arrNotesStarredST];
	_notesStarredCount = _notesStarredCountST;
	[self modifyVersion];
	_updatingMT = NO;
}

- (YTNoteInfo *)getNoteByGuidDT:(NSString *)noteGuid {
	return [_mapNotesByGuidST objectForKey:noteGuid];
}

- (YTNoteInfo *)getNoteByGuid:(NSString *)noteGuid {
	return [_mapNotesByGuid objectForKey:noteGuid];
}

- (NSArray *)getNotesInNotebookWithGuid:(NSString *)notebookGuid {
	NSArray *notes = [_mapNotesInNotebooks objectForKey:notebookGuid];
	return notes ? notes : [NSArray array];
}

- (NSArray *)getNotes {
	return _arrNotes;
}

- (NSArray *)getNotesStarred {
	return _arrNotesStarred;
}

- (int)getNotesStarredCount {
	return _notesStarredCount;
}

- (int)getNotesCountInNotebookWithGuid:(NSString *)notebookGuid {
	NSArray *notes = [_mapNotesInNotebooks objectForKey:notebookGuid];
	if(notes)
		return (int)notes.count;
	return 0;
}

- (YTNoteInfo *)getNoteByResourceId:(int64_t)resourceId {
	NSDictionary *map = [[YTNoteToResourceEnManager shared] getNoteResourcesByResourceId:resourceId];
	if(!map.count)
		return nil;
	YTNoteToResourceInfo *info = [map.allValues objectAtIndex:0];
	YTNoteInfo *note = [self getNoteByGuid:info.noteGuid];
	return note;
}

- (void)dealloc {
	[super dealloc];
}

@end

