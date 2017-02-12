
#import "YTTagsEnManager.h"
#import "YTUsersEnManager.h"
#import "YTNoteToTagEnManager.h"

static YTTagsEnManager *_shared;

@implementation YTTagsEnManager

+ (YTTagsEnManager *)shared {
	if(!_shared)
		_shared = [[YTTagsEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		
		_arrEntities = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_arrEntitiesST = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapTagById = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapTagByIdST = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		[[YTNoteToTagEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNoteToTagEnManagerChanged:)];
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTTagsDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTTagsDbManager *manrDb = [YTTagsDbManager shared];
	[manrDb loadEntitiesFromDb];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTTagsDbManager *manrDbTags = [YTTagsDbManager shared];
	int64_t curVersionST = manrDbTags.version;
	if(_lastVersionST != curVersionST) {
		[_arrEntitiesST removeAllObjects];
		[_mapTagByIdST removeAllObjects];
		for(YTTagInfo *entity in manrDbTags.entities) {
			if(entity.deleted)
				continue;
			[_arrEntitiesST addObject:entity];
		}
		for(YTTagInfo *ent in _arrEntitiesST) {
			int64_t nId = ent.tagId;
			[_mapTagByIdST setObject:ent forKey:[NSNumber numberWithLongLong:nId]];
		}
		_lastVersionST = curVersionST;
		_updatingMT = YES;
	}
}

- (void)updateOnMT {
	[super updateOnMT];
	if(!_updatingMT)
		return;
	[_arrEntities removeAllObjects];
	[_arrEntities addObjectsFromArray:_arrEntitiesST];
	[_mapTagById removeAllObjects];
	[_mapTagById addEntriesFromDictionary:_mapTagByIdST];
	[self modifyVersion];
	_updatingMT = NO;
}

- (void)onNoteToTagEnManagerChanged:(id)sender {
	[self modifyVersion];
}

- (NSArray *)getAllTags {
	[self checkIsMainThread];
	return _arrEntities;
}

- (YTTagInfo *)getTagById:(int64_t)tagId {
	[self checkIsMainThread];
	NSNumber *numId = [[NSNumber alloc] initWithLongLong:tagId];
	YTTagInfo *res = [_mapTagById objectForKey:numId];
	[numId release];
	return res;
}

- (NSArray *)getTagsByIds:(NSSet *)ids {
	[self checkIsMainThread];
	if(!ids.count)
		return [NSArray array];
	NSMutableArray *res = [NSMutableArray arrayWithCapacity:ids.count];
	for(NSNumber *numId in ids) {
		YTTagInfo *tag = [_mapTagById objectForKey:numId];
		if(tag)
			[res addObject:tag];
	}
	return res;
}

- (BOOL)hasTagsWithIds:(NSSet *)ids {
	[self checkIsMainThread];
	if(ids.count) {
		for(NSNumber *numId in ids) {
			if([_mapTagById objectForKey:numId])
				return YES;
		}
	}
	return NO;
}

- (NSDictionary *)getMapTagById {
	[self checkIsMainThread];
	NSDictionary *res = [NSDictionary dictionaryWithDictionary:_mapTagById];
	return res;
}

- (NSDictionary *)getTagsByNoteGuid:(NSString *)noteGuid {
	[self checkIsMainThread];
	NSDictionary *infos = [[YTNoteToTagEnManager shared] getNoteTagsByNoteGuid:noteGuid];
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:infos.count];
	for(YTNoteToTagInfo *info in infos.allValues) {
		YTTagInfo *tag = [self getTagById:info.tagId];
		if(tag)
			[result setObject:tag forKey:[NSNumber numberWithLongLong:tag.tagId]];
	}
	return result;
}

- (BOOL)hasTagsByNoteGuid:(NSString *)noteGuid {
	[self checkIsMainThread];
	NSDictionary *infos = [[YTNoteToTagEnManager shared] getNoteTagsByNoteGuid:noteGuid];
	return (infos.count > 0);
}

- (NSDictionary *)getMapTagsByNoteGuid {
	[self checkIsMainThread];
	NSDictionary *mapByNote = [[YTNoteToTagEnManager shared] getMapEntitiesByNote];
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:mapByNote.count];
	for(NSString *noteGuid in mapByNote.allKeys) {
		NSDictionary *mapById = [mapByNote objectForKey:noteGuid];
		NSMutableDictionary *entities = [NSMutableDictionary dictionaryWithCapacity:mapById.count];
		[result setObject:entities forKey:noteGuid];
		for(NSNumber *numId in mapById.allKeys) {
			YTTagInfo *tag = [self getTagById:numId.longLongValue];
			if(tag)
				[entities setObject:tag forKey:numId];
		}
	}
	return result;
}

- (void)dealloc {
	[super dealloc];
}

@end

