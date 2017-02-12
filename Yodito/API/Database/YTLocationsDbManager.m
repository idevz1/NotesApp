
#import "YTLocationsDbManager.h"
#import "YTDatabaseManager.h"
#import "YTNotesDbManager.h"

static YTLocationsDbManager *_shared;

@implementation YTLocationsDbManager

+ (YTLocationsDbManager *)shared {
	if(!_shared)
		_shared = [[YTLocationsDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTLocationInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
		_mapEntityById = [[NSMutableDictionary alloc] init];
		[[YTDatabaseManager shared].dlgtEntityIdChanged addObserver:self selector:@selector(onEntityIdChanged:args:)];
	}
	return self;
}

- (void)initialize {
	[super initialize];
}

- (void)loadEntitiesFromDb {
	[super loadEntitiesFromDb];
	[_mapEntityById removeAllObjects];
	for(YTLocationInfo *entity in self.entities)
		[_mapEntityById setObject:entity forKey:[NSNumber numberWithLongLong:entity.locationId]];
}

- (void)addEntity:(VLSqliteEntity *)entity {
	[super addEntity:entity];
	[_mapEntityById setObject:entity forKey:[NSNumber numberWithLongLong:((YTLocationInfo *)entity).locationId]];
}

- (void)deleteEntityFromDb:(VLSqliteEntity *)entity {
	[super deleteEntityFromDb:entity];
	[_mapEntityById removeObjectForKey:[NSNumber numberWithLongLong:((YTLocationInfo *)entity).locationId]];
}

- (void)deleteAllEntitiesFromDb {
	[super deleteAllEntitiesFromDb];
	[_mapEntityById removeAllObjects];
}

- (void)onEntityIdChanged:(id)sender args:(YTEntityIdChangedArgs *)args {
	[self checkIsDatabaseThread];
	YTLocationInfo *loc = ObjectCast(args.entity, YTLocationInfo);
	if(loc) {
		NSNumber *numdIdLast = [NSNumber numberWithLongLong:args.idLast];
		NSNumber *numdINew = [NSNumber numberWithLongLong:args.idNew];
		YTEntityBase *entity = [_mapEntityById objectForKey:numdIdLast];
		if(entity) {
			[_mapEntityById setObject:entity forKey:numdINew];
			[_mapEntityById removeObjectForKey:numdIdLast];
		}
	}
}

- (YTLocationInfo *)getLocationById:(int64_t)locId; {
	[self checkIsDatabaseThread];
	NSNumber *numId = [[NSNumber alloc] initWithLongLong:locId];
	YTLocationInfo *res = [_mapEntityById objectForKey:numId];
	[numId release];
	return res;
}

- (void)changeLocationIdFromLast:(int64_t)lastLocId toNew:(int64_t)newLocId {
	[self checkIsDatabaseThread];
	NSNumber *numLastId = [NSNumber numberWithLongLong:lastLocId];
	NSNumber *numNewId = [NSNumber numberWithLongLong:newLocId];
	YTLocationInfo *entity = [_mapEntityById objectForKey:numLastId];
	if(entity) {
		[[entity retain] autorelease];
		[_mapEntityById removeObjectForKey:numLastId];
		[_mapEntityById setObject:entity forKey:numNewId];
	}
}

- (NSString *)apiOperationForDelete {
	return @"";
	//return kYTUrlValueOperationDeleteLocation;
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	return @"";
	//return kYTUrlValueOperationCreateLocation;
}

- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity {
	// Do not modify locations, just add/delete
	//return kYTUrlValueOperationUpdateLocation;
	return @"";
}

- (NSString *)apiOperationForList {
	return @"";
	//return kYTUrlValueOperationListLocations;
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	/*YTLocationInfo *loc = ObjectCast(entity, YTLocationInfo);
	YTNoteInfo *note = [[YTNotesDbManager shared] getNoteByLocationId:loc.locationId];
	[postValues addObject:note ? note.noteGuid : @""];
	[postValues addObject:[NSNumber numberWithLongLong:loc.locationId]];
	[postValues addObject:[loc.lastUpdateTS yoditoToString]];*/
}

- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip {
	/*YTLocationInfo *loc = ObjectCast(entity, YTLocationInfo);
	YTNoteInfo *note = [[YTNotesDbManager shared] getNoteByLocationId:loc.locationId];
	[postValues addObject:note ? note.noteGuid : @""];
	NSString *sFormat = @"{\n\
	\"LastUpdateTS\": \"%@\",\n\
	\"Name\": \"%@\",\n\
	\"Latitude\": \"%f\",\n\
	\"Longitude\": \"%f\"\n\
	}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   [loc.lastUpdateTS yoditoToString],
					   [YTWebRequest escapeJsonText:loc.name],
					   loc.latitude,
					   loc.longitude
					   ];
	[postValues addObject:sData];*/
}

- (void)onGetResponseForAddEntity:(YTEntityBase *)entity response:(NSDictionary *)response {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	/*YTLocationInfo *loc = ObjectCast(entity, YTLocationInfo);
	int64_t newId = [response int64ValueForKey:kYTJsonKeyResultCode defaultVal:0];
	YTLocationInfo *existedLoc = [self getLocationById:newId];
	if(existedLoc) {
		[self deleteEntityFromDb:loc];
		return;
	}
	BOOL wasModified = loc.modified;
	VLDate *lastUpdateTS = [[loc.lastUpdateTS retain] autorelease];
	int64_t lastId = loc.locationId;
	loc.locationId = newId;
	if([[YTDatabaseManager shared] isTempId:lastId]) {
		[[YTDatabaseManager shared] changeLocationIdFromLast:lastId toNew:newId];
	}
	loc.added = NO;
	loc.lastUpdateTS = lastUpdateTS;
	loc.modified = wasModified;*/
}

- (void)getRequestForModifyEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	YTLocationInfo *loc = ObjectCast(entity, YTLocationInfo);
	/*{
	 "LocationId": 1,
	 "Name": "LA, California",
	 "Latitude": "34",
	 "Longitude": "118"
	 }*/
	NSString *sFormat = @"{\n\
	\"LocationId\": %@,\n\
	\"LastUpdateTS\": \"%@\",\n\
	\"Name\": \"%@\",\n\
	\"Latitude\": \"%f\",\n\
	\"Longitude\": \"%f\"\n\
	}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   loc.locationId ? [[NSNumber numberWithLongLong:loc.locationId] stringValue] : @"null",
					   [loc.lastUpdateTS yoditoToString],
					   [YTWebRequest escapeJsonText:loc.name],
					   loc.latitude,
					   loc.longitude
					   ];
	[postValues addObject:sData];
}

- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities {
	//YTNoteInfo *note = ObjectCast(param, YTNoteInfo);
	for(NSDictionary *data in arrData) {
		YTLocationInfo *loc = [[[YTLocationInfo alloc] init] autorelease];
		//loc.noteGuid = note.noteGuid;
		[loc loadFromData:data];
		[arrEntities addObject:loc];
	}
}

- (void)dealloc {
	[super dealloc];
}

@end

