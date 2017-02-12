
#import "YTNotebooksEnManager.h"

static YTNotebooksEnManager *_shared;

@implementation YTNotebooksEnManager

@dynamic defaultNotebook;
@dynamic defaultNotebookGuid;

+ (YTNotebooksEnManager *)shared {
	if(!_shared)
		_shared = [[YTNotebooksEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		_mapNotebooks = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapNotebooksST = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_notebooks = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_notebooksST = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTNotebooksDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTNotebooksDbManager *manrDb = [YTNotebooksDbManager shared];
	[manrDb loadEntitiesFromDb];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTNotebooksDbManager *manrDbBooks = [YTNotebooksDbManager shared];
	int64_t curVersionST = manrDbBooks.version;
	if(_lastVersionST != curVersionST) {
		[_notebooksST removeAllObjects];
		for(YTNotebookInfo *entity in manrDbBooks.entities) {
			if(entity.deleted)
				continue;
			[_notebooksST addObject:entity];
		}
		[_mapNotebooksST removeAllObjects];
		for(YTNotebookInfo *book in _notebooksST)
			[_mapNotebooksST setObject:book forKey:book.notebookGuid];
		_lastVersionST = curVersionST;
		_updatingMT = YES;
	}
}

- (void)updateOnMT {
	[super updateOnMT];
	if(!_updatingMT)
		return;
	[_notebooks removeAllObjects];
	[_notebooks addObjectsFromArray:_notebooksST];
	[_mapNotebooks removeAllObjects];
	[_mapNotebooks addEntriesFromDictionary:_mapNotebooksST];
	[self updateDefaultNotebook];
	[self modifyVersion];
	_updatingMT = NO;
}

- (NSArray *)getNotebooks {
	return _notebooks;
}

- (YTNotebookInfo *)getNotebookByGuid:(NSString *)notebookGuid {
	return [_mapNotebooks objectForKey:notebookGuid];
}

- (YTNotebookInfo *)defaultNotebook {
	if(!_defaultNotebook)
		[self updateDefaultNotebook];
	return _defaultNotebook;
}

- (void)updateDefaultNotebook {
	YTNotebookInfo *book = nil;
	for(YTNotebookInfo *ent in _notebooks) {
		if(ent.isDefault) {
			book = ent;
			break;
		}
	}
	if(!book && _notebooks.count)
		book = [_notebooks objectAtIndex:0];
	if(_defaultNotebook != book) {
		[_defaultNotebook release];
		_defaultNotebook = nil;
		_defaultNotebook = [book retain];
		[self modifyVersion];
	}
}

- (NSString *)defaultNotebookGuid {
	YTNotebookInfo *book = self.defaultNotebook;
	return book ? book.notebookGuid : @"";
}

- (void)dealloc {
	[super dealloc];
}

@end

