
#import "YTNoteToResourceDbManager.h"
#import "YTDatabaseManager.h"

static YTNoteToResourceDbManager *_shared;

@implementation YTNoteToResourceDbManager

+ (YTNoteToResourceDbManager *)shared {
	if(!_shared)
		_shared = [[YTNoteToResourceDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTNoteToResourceInfo class] database:[YTDatabaseManager shared].database];
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
	for(YTNoteToResourceInfo *entity in self.entities) {
		NSNumber *numId = [NSNumber numberWithLongLong:entity.resourceId];
		
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
	YTNoteToResourceInfo *ent = (YTNoteToResourceInfo *)entity;
	
	NSNumber *numId = [NSNumber numberWithLongLong:ent.resourceId];
	
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
	YTNoteToResourceInfo *ent = (YTNoteToResourceInfo *)entity;
	
	NSNumber *numId = [NSNumber numberWithLongLong:ent.resourceId];
	
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
	YTResourceInfo *res = ObjectCast(args.entity, YTResourceInfo);
	if(res) {
		NSNumber *numdIdLast = [NSNumber numberWithLongLong:args.idLast];
		NSNumber *numdINew = [NSNumber numberWithLongLong:args.idNew];
		NSDictionary *map = [_mapEntitiesById objectForKey:numdIdLast];
		if(map) {
			[_mapEntitiesById setObject:map forKey:numdINew];
			[_mapEntitiesById removeObjectForKey:numdIdLast];
			for(YTNoteToResourceInfo *entity in map.allValues)
				entity.resourceId = args.idNew;
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

- (NSDictionary *)getNoteResourcesByResourceId:(int64_t)resourceId {
	[self checkIsDatabaseThread];
	NSNumber *numId = [NSNumber numberWithLongLong:resourceId];
	NSDictionary *entities = [_mapEntitiesById objectForKey:numId];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (NSDictionary *)getNoteResourcesByNoteGuid:(NSString *)noteGuid {
	[self checkIsDatabaseThread];
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (YTNoteToResourceInfo *)getNoteResourceByNoteGuid:(NSString *)noteGuid resourceId:(int64_t)resourceId {
	[self checkIsDatabaseThread];
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return nil;
	NSNumber *numId = [NSNumber numberWithLongLong:resourceId];
	YTNoteToResourceInfo *res = [entities objectForKey:numId];
	return res;
}

- (YTNoteToResourceInfo *)addNoteResourceWithNoteGuid:(NSString *)noteGuid resourceId:(int64_t)resourceId {
	[self checkIsDatabaseThread];
	YTNoteToResourceInfo *entity = [self getNoteResourceByNoteGuid:noteGuid resourceId:resourceId];
	if(!entity)
		entity = [[[YTNoteToResourceInfo alloc] init] autorelease];
	entity.noteGuid = noteGuid;
	entity.resourceId = resourceId;
	entity.added = YES;
	[self addEntity:entity];
	return entity;
}

- (void)onEntityFromListingUpdated:(YTEntityBase *)entity param:(NSObject *)param {
	[super onEntityFromListingUpdated:entity param:param];
	YTResourceInfo *res = ObjectCast(entity, YTResourceInfo);
	YTNoteInfo *note = ObjectCast(param, YTNoteInfo);
	//YTNoteToResourceInfo *info =
	[self addNoteResourceWithNoteGuid:note.noteGuid resourceId:res.attachmentId];
}

- (void)dealloc {
	[super dealloc];
}

@end

