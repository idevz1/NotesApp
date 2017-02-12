
#import "YTNoteToLocationDbManager.h"
#import "YTDatabaseManager.h"
#import "YTLocationsDbManager.h"

static YTNoteToLocationDbManager *_shared;

@implementation YTNoteToLocationDbManager

+ (YTNoteToLocationDbManager *)shared {
	if(!_shared)
		_shared = [[YTNoteToLocationDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTNoteToLocationInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
		_mapEntitiesById = [[NSMutableDictionary alloc] init];
		_mapEntitiesByNote = [[NSMutableDictionary alloc] init];
		[[YTDatabaseManager shared].dlgtEntityIdChanged addObserver:self selector:@selector(onEntityIdChanged:args:)];
	}
	return self;
}

- (void)initialize {
	[super initialize];
}

- (void)loadEntitiesFromDb {
	[super loadEntitiesFromDb];
	[_mapEntitiesById removeAllObjects];
	[_mapEntitiesById removeAllObjects];
	for(YTNoteToLocationInfo *entity in self.entities) {
		NSNumber *numId = [NSNumber numberWithLongLong:entity.locationId];
		
		NSMutableDictionary *entities = [_mapEntitiesById objectForKey:numId];
		if(!entities) {
			entities = [NSMutableDictionary dictionary];
			[_mapEntitiesById setObject:entities forKey:numId];
		}
		[entities setObject:entity forKey:entity.noteGuid];
		
		entities = [_mapEntitiesByNote objectForKey:entity.noteGuid];
		if(!entities) {
			entities = [NSMutableDictionary dictionary];
			[_mapEntitiesByNote setObject:entities forKey:entity.noteGuid];
		}
		[entities setObject:entity forKey:numId];
	}
}

- (void)addEntity:(VLSqliteEntity *)entity {
	[super addEntity:entity];
	YTNoteToLocationInfo *ent = (YTNoteToLocationInfo *)entity;
	
	NSNumber *numId = [NSNumber numberWithLongLong:ent.locationId];
	
	NSMutableDictionary *entities = [_mapEntitiesById objectForKey:numId];
	if(!entities) {
		entities = [NSMutableDictionary dictionary];
		[_mapEntitiesById setObject:entities forKey:numId];
	}
	[entities setObject:entity forKey:ent.noteGuid];
	
	entities = [_mapEntitiesByNote objectForKey:ent.noteGuid];
	if(!entities) {
		entities = [NSMutableDictionary dictionary];
		[_mapEntitiesByNote setObject:entities forKey:ent.noteGuid];
	}
	[entities setObject:entity forKey:numId];
}

- (void)deleteEntityFromDb:(VLSqliteEntity *)entity {
	[super deleteEntityFromDb:entity];
	YTNoteToLocationInfo *ent = (YTNoteToLocationInfo *)entity;
	
	NSNumber *numId = [NSNumber numberWithLongLong:ent.locationId];
	
	NSMutableDictionary *entities = [_mapEntitiesById objectForKey:numId];
	if(entities) {
		[entities removeObjectForKey:ent.noteGuid];
	}
	
	entities = [_mapEntitiesByNote objectForKey:ent.noteGuid];
	if(entities) {
		[entities removeObjectForKey:numId];
	}
}

- (void)deleteAllEntitiesFromDb {
	[super deleteAllEntitiesFromDb];
	[_mapEntitiesById removeAllObjects];
	[_mapEntitiesByNote removeAllObjects];
}

- (void)onEntityIdChanged:(id)sender args:(YTEntityIdChangedArgs *)args {
	[self checkIsDatabaseThread];
	YTLocationInfo *loc = ObjectCast(args.entity, YTLocationInfo);
	if(loc) {
		NSNumber *numdIdLast = [NSNumber numberWithLongLong:args.idLast];
		NSNumber *numdINew = [NSNumber numberWithLongLong:args.idNew];
		NSDictionary *map = [_mapEntitiesById objectForKey:numdIdLast];
		if(map) {
			[_mapEntitiesById setObject:map forKey:numdINew];
			[_mapEntitiesById removeObjectForKey:numdIdLast];
			for(YTNoteToLocationInfo *entity in map.allValues)
				entity.locationId = args.idNew;
			for(NSMutableDictionary *mapById in _mapEntitiesByNote.allValues) {
				YTEntityBase *entity = [mapById objectForKey:numdIdLast];
				if(entity) {
					[mapById setObject:entity forKey:numdINew];
					[mapById removeObjectForKey:numdIdLast];
				}
			}
		}
	}
}

- (NSDictionary *)getMapEntitiesById {
	[self checkIsDatabaseThread];
	return _mapEntitiesById;
}

- (NSDictionary *)getMapEntitiesByNote {
	[self checkIsDatabaseThread];
	return _mapEntitiesByNote;
}

- (NSDictionary *)getNoteLocationsById:(int64_t)locationId {
	[self checkIsDatabaseThread];
	NSNumber *numId = [NSNumber numberWithLongLong:locationId];
	NSDictionary *entities = [_mapEntitiesById objectForKey:numId];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (NSDictionary *)getNoteLocationsByNoteGuid:(NSString *)noteGuid {
	[self checkIsDatabaseThread];
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (YTNoteToLocationInfo *)getNoteLocationByNoteGuid:(NSString *)noteGuid locationId:(int64_t)locationId {
	[self checkIsDatabaseThread];
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return nil;
	NSNumber *numId = [NSNumber numberWithLongLong:locationId];
	YTNoteToLocationInfo *res = [entities objectForKey:numId];
	return res;
}

- (YTNoteToLocationInfo *)addNoteLocationWithNoteGuid:(NSString *)noteGuid locationId:(int64_t)locationId {
	[self checkIsDatabaseThread];
	YTNoteToLocationInfo *entity = [self getNoteLocationByNoteGuid:noteGuid locationId:locationId];
	if(!entity)
		entity = [[[YTNoteToLocationInfo alloc] init] autorelease];
	entity.noteGuid = noteGuid;
	entity.locationId = locationId;
	entity.added = YES;
	[self addEntity:entity];
	return entity;
}

- (void)deleteNoteLocationWithNoteGuid:(NSString *)noteGuid locationId:(int64_t)locationId {
	YTNoteToLocationInfo *entity = [self getNoteLocationByNoteGuid:noteGuid locationId:locationId];
	if(entity) {
		[self deleteEntityFromDb:entity];
	}
}

- (void)deleteNoteLocationsWithNoteGuid:(NSString *)noteGuid {
	NSDictionary *map = [_mapEntitiesByNote objectForKey:noteGuid];
	if(map) {
		for(YTNoteToLocationInfo *entity in [NSArray arrayWithArray:map.allValues])
			[self deleteEntityFromDb:entity];
	}
}

- (NSString *)apiOperationForDelete {
	return kYTUrlValueOperationDeleteLocation;
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	return kYTUrlValueOperationCreateLocation;
}

- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity {
	// Do not modify locations, just add/delete
	return @"";
}

- (NSString *)apiOperationForList {
	return kYTUrlValueOperationListLocations;
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	[self checkIsDatabaseThread];
	YTNoteToLocationInfo *info = ObjectCast(entity, YTNoteToLocationInfo);
	[postValues addObject:info.noteGuid ? info.noteGuid : @""];
	[postValues addObject:[NSNumber numberWithLongLong:info.locationId]];
	VLDate *lastUpdateTS = [VLDate date];
	[postValues addObject:[lastUpdateTS yoditoToString]];
}

- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip {
	[self checkIsDatabaseThread];
	YTNoteToLocationInfo *info = ObjectCast(entity, YTNoteToLocationInfo);
	YTLocationInfo *loc = [[YTLocationsDbManager shared] getLocationById:info.locationId];
	[postValues addObject:info.noteGuid ? info.noteGuid : @""];
	NSString *sFormat = @"{\n\
\"LastUpdateTS\": \"%@\",\n\
\"Name\": \"%@\",\n\
\"Latitude\": \"%f\",\n\
\"Longitude\": \"%f\"\n\
}";
	VLDate *lastUpdateTS = [VLDate date];
	NSString *sData = [NSString stringWithFormat:sFormat,
					   [lastUpdateTS yoditoToString],
					   loc ? [YTWebRequest escapeJsonText:loc.name] : @"",
					   loc ? loc.latitude : 0,
					   loc ? loc.longitude : 0
					   ];
	[postValues addObject:sData];
}

- (void)onGetResponseForAddEntity:(YTEntityBase *)entity response:(NSDictionary *)response {
	[super onGetResponseForAddEntity:entity response:response];
	YTNoteToLocationInfo *info = ObjectCast(entity, YTNoteToLocationInfo);
	YTLocationInfo *loc = [[YTLocationsDbManager shared] getLocationById:info.locationId];
	int64_t newId = [response int64ValueForKey:kYTJsonKeyResultCode defaultVal:0];
	if(newId) {
		if(info.locationId != newId) {
			int64_t lastId = info.locationId;
			YTLocationInfo *locExist = [[YTLocationsDbManager shared] getLocationById:newId];
			if(locExist) {
				[locExist assignDataFrom:loc];
				locExist.locationId = newId;
				locExist.added = locExist.deleted = locExist.modified = locExist.isTemporary = NO;
				NSDictionary *mapInfo = [[YTNoteToLocationDbManager shared] getNoteLocationsById:newId];
				for(YTNoteToLocationInfo *info in mapInfo.allValues) {
					info.added = info.deleted = info.modified = info.isTemporary = NO;
				}
				
				[[YTLocationsDbManager shared] deleteEntityFromDb:loc];
				NSDictionary *mapInfoToDelete = [[YTNoteToLocationDbManager shared] getNoteLocationsById:lastId];
				for(YTNoteToLocationInfo *info in [NSArray arrayWithArray:mapInfoToDelete.allValues]) {
					[[YTNoteToLocationDbManager shared] deleteEntityFromDb:info];
				}
			} else {
				if(loc) {
					loc.locationId = newId;
					[[YTDatabaseManager shared] notifyIdChangedForEntiy:loc formId:lastId toId:newId];
				}
			}
		}
		YTEntityBase *entityTo = [[YTLocationsDbManager shared] getLocationById:newId];
		if(entityTo) {
			entityTo.added = entityTo.deleted = entityTo.modified = entityTo.isTemporary = NO;
		}
	}
}

- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities {
	[self checkIsDatabaseThread];
	//YTNoteInfo *note = ObjectCast(param, YTNoteInfo);
	for(NSDictionary *data in arrData) {
		YTLocationInfo *loc = [[[YTLocationInfo alloc] init] autorelease];
		[loc loadFromData:data];
		[arrEntities addObject:loc];
	}
}

- (void)onEntityFromListingUpdated:(YTEntityBase *)entity param:(NSObject *)param {
	[super onEntityFromListingUpdated:entity param:param];
	YTLocationInfo *loc = ObjectCast(entity, YTLocationInfo);
	YTNoteInfo *note = ObjectCast(param, YTNoteInfo);
	//YTNoteToLocationInfo *info =
	[self addNoteLocationWithNoteGuid:note.noteGuid locationId:loc.locationId];
}

- (void)dealloc {
	[super dealloc];
}

@end

