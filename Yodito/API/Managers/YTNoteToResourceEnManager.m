
#import "YTNoteToResourceEnManager.h"

static YTNoteToResourceEnManager *_shared;

@implementation YTNoteToResourceEnManager

+ (YTNoteToResourceEnManager *)shared {
	if(!_shared)
		_shared = [[YTNoteToResourceEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		_arrEntitiesDT = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_arrEntities = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapEntitiesByIdDT = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapEntitiesById = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapEntitiesByNoteDT = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapEntitiesByNote = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTNoteToResourceDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTNoteToResourceDbManager *manrDb = [YTNoteToResourceDbManager shared];
	[manrDb loadEntitiesFromDb];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTNoteToResourceDbManager *manrDb = [YTNoteToResourceDbManager shared];
	int64_t curVersionDT = manrDb.version;
	if(_lastVersionDT != curVersionDT) {
		[_arrEntitiesDT removeAllObjects];
		[_mapEntitiesByIdDT removeAllObjects];
		[_mapEntitiesByNoteDT removeAllObjects];
		for(YTEntityBase *entity in manrDb.entities) {
			if(entity.deleted)
				continue;
			[_arrEntitiesDT addObject:entity];
		}
		NSDictionary *mapEntitiesById = [manrDb getMapEntitiesById];
		for(id<NSCopying> key in mapEntitiesById.allKeys) {
			NSDictionary *map = [mapEntitiesById objectForKey:key];
			NSMutableDictionary *entities = [NSMutableDictionary dictionaryWithCapacity:map.count];
			for(id<NSCopying> key1 in map.allKeys) {
				YTEntityBase *entity = [map objectForKey:key1];
				if(!entity.deleted)
					[entities setObject:entity forKey:key1];
			}
			if(entities.count)
				[_mapEntitiesByIdDT setObject:entities forKey:key];
		}
		NSDictionary *mapEntitiesByNote = [manrDb getMapEntitiesByNote];
		for(id<NSCopying> key in mapEntitiesByNote.allKeys) {
			NSDictionary *map = [mapEntitiesByNote objectForKey:key];
			NSMutableDictionary *entities = [NSMutableDictionary dictionaryWithCapacity:map.count];
			for(id<NSCopying> key1 in map.allKeys) {
				YTEntityBase *entity = [map objectForKey:key1];
				if(!entity.deleted)
					[entities setObject:entity forKey:key1];
			}
			if(entities.count)
				[_mapEntitiesByNoteDT setObject:entities forKey:key];
		}
		_lastVersionDT = curVersionDT;
		_updatingMT = YES;
	}
}

- (void)updateOnMT {
	[super updateOnMT];
	if(!_updatingMT)
		return;
	[_arrEntities removeAllObjects];
	[_arrEntities addObjectsFromArray:_arrEntitiesDT];
	[_mapEntitiesById removeAllObjects];
	[_mapEntitiesById addEntriesFromDictionary:_mapEntitiesByIdDT];
	[_mapEntitiesByNote removeAllObjects];
	[_mapEntitiesByNote addEntriesFromDictionary:_mapEntitiesByNoteDT];
	[self modifyVersion];
	_updatingMT = NO;
}

- (NSDictionary *)getMapEntitiesByNote {
	[self checkIsMainThread];
	return _mapEntitiesByNote;
}

- (NSDictionary *)getNoteResourcesByResourceId:(int64_t)resourceId {
	[self checkIsMainThread];
	NSNumber *numId = [NSNumber numberWithLongLong:resourceId];
	NSDictionary *entities = [_mapEntitiesById objectForKey:numId];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (NSDictionary *)getNoteResourcesByNoteGuid:(NSString *)noteGuid {
	[self checkIsMainThread];
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (void)dealloc {
	[super dealloc];
}

@end

