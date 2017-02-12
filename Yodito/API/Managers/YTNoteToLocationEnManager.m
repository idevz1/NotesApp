
#import "YTNoteToLocationEnManager.h"

static YTNoteToLocationEnManager *_shared;

@implementation YTNoteToLocationEnManager

+ (YTNoteToLocationEnManager *)shared {
	if(!_shared)
		_shared = [[YTNoteToLocationEnManager alloc] init];
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
	return [YTNoteToLocationDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTNoteToLocationDbManager *manrDb = [YTNoteToLocationDbManager shared];
	[manrDb loadEntitiesFromDb];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTNoteToLocationDbManager *manrDb = [YTNoteToLocationDbManager shared];
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

- (NSDictionary *)getNoteLocationsByNoteGuid:(NSString *)noteGuid {
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (YTNoteToLocationInfo *)getNoteLocationByNoteGuid:(NSString *)noteGuid locationId:(int64_t)locationId {
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return nil;
	NSNumber *numId = [NSNumber numberWithLongLong:locationId];
	YTNoteToLocationInfo *res = [entities objectForKey:numId];
	return res;
}

- (void)dealloc {
	[super dealloc];
}

@end

