
#import "YTNoteToTagDbManager.h"
#import "YTDatabaseManager.h"
#import "YTTagsDbManager.h"

static YTNoteToTagDbManager *_shared;

@implementation YTNoteToTagDbManager

+ (YTNoteToTagDbManager *)shared {
	if(!_shared)
		_shared = [[YTNoteToTagDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTNoteToTagInfo class] database:[YTDatabaseManager shared].database];
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
	for(YTNoteToTagInfo *entity in self.entities) {
		NSNumber *numId = [NSNumber numberWithLongLong:entity.tagId];
		
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
	YTNoteToTagInfo *ent = (YTNoteToTagInfo *)entity;
	
	NSNumber *numId = [NSNumber numberWithLongLong:ent.tagId];
	
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
	YTNoteToTagInfo *ent = (YTNoteToTagInfo *)entity;
	
	NSNumber *numId = [NSNumber numberWithLongLong:ent.tagId];
	
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
	YTTagInfo *tag = ObjectCast(args.entity, YTTagInfo);
	if(tag) {
		NSNumber *numdIdLast = [NSNumber numberWithLongLong:args.idLast];
		NSNumber *numdINew = [NSNumber numberWithLongLong:args.idNew];
		NSDictionary *map = [_mapEntitiesById objectForKey:numdIdLast];
		if(map) {
			[_mapEntitiesById setObject:map forKey:numdINew];
			[_mapEntitiesById removeObjectForKey:numdIdLast];
			for(YTNoteToTagInfo *entity in map.allValues)
				entity.tagId = args.idNew;
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

- (NSDictionary *)getNoteTagsById:(int64_t)tagId {
	[self checkIsDatabaseThread];
	NSNumber *numId = [NSNumber numberWithLongLong:tagId];
	NSDictionary *entities = [_mapEntitiesById objectForKey:numId];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (NSDictionary *)getNoteTagsByNoteGuid:(NSString *)noteGuid {
	[self checkIsDatabaseThread];
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return [NSDictionary dictionary];
	return entities;
}

- (YTNoteToTagInfo *)getNoteTagByNoteGuid:(NSString *)noteGuid tagId:(int64_t)tagId {
	[self checkIsDatabaseThread];
	NSDictionary *entities = [_mapEntitiesByNote objectForKey:noteGuid];
	if(!entities)
		return nil;
	NSNumber *numId = [NSNumber numberWithLongLong:tagId];
	YTNoteToTagInfo *res = [entities objectForKey:numId];
	return res;
}

- (YTNoteToTagInfo *)addNoteTagWithNoteGuid:(NSString *)noteGuid tagId:(int64_t)tagId {
	[self checkIsDatabaseThread];
	YTNoteToTagInfo *entity = [self getNoteTagByNoteGuid:noteGuid tagId:tagId];
	if(!entity)
		entity = [[[YTNoteToTagInfo alloc] init] autorelease];
	entity.noteGuid = noteGuid;
	entity.tagId = tagId;
	if(entity.deleted) {
		entity.deleted = NO;
		entity.added = NO;
	} else {
		entity.added = YES;
	}
	[self addEntity:entity];
	return entity;
}

- (NSString *)apiOperationForDelete {
	return kYTUrlValueOperationDeleteTag;
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	return kYTUrlValueOperationCreateTag;
}

- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity {
	// Do not modify tags, just add/delete
	return @"";
}

- (NSString *)apiOperationForList {
	return kYTUrlValueOperationListTags;
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	[self checkIsDatabaseThread];
	YTNoteToTagInfo *info = ObjectCast(entity, YTNoteToTagInfo);
	[postValues addObject:info.noteGuid ? info.noteGuid : @""];
	[postValues addObject:[NSNumber numberWithLongLong:info.tagId]];
	VLDate *lastUpdateTS = [VLDate date];
	[postValues addObject:[lastUpdateTS yoditoToString]];
}

- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip {
	[self checkIsDatabaseThread];
	YTNoteToTagInfo *info = ObjectCast(entity, YTNoteToTagInfo);
	YTTagInfo *tag = [[YTTagsDbManager shared] getTagById:info.tagId];
	[postValues addObject:info.noteGuid ? info.noteGuid : @""];
	NSString *sFormat = @"{\n\
\"Name\": \"%@\",\n\
\"LastUpdateTS\": \"%@\"\n\
}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   [YTWebRequest escapeJsonText:tag.name],
					   [tag.lastUpdateTS yoditoToString]
					   ];
	[postValues addObject:sData];
}

- (void)onGetResponseForAddEntity:(YTEntityBase *)entity response:(NSDictionary *)response {
	[super onGetResponseForAddEntity:entity response:response];
	YTNoteToTagInfo *info = ObjectCast(entity, YTNoteToTagInfo);
	YTTagInfo *tag = [[YTTagsDbManager shared] getTagById:info.tagId];
	int64_t newId = [response int64ValueForKey:kYTJsonKeyResultCode defaultVal:0];
	if(newId) {
		if(info.tagId != newId) {
			int64_t lastId = info.tagId;
			if(tag) {
				tag.tagId = newId;
				[[YTDatabaseManager shared] notifyIdChangedForEntiy:tag formId:lastId toId:newId];
			}
		}
		YTEntityBase *entityTo = [[YTTagsDbManager shared] getTagById:newId];
		if(entityTo) {
			entityTo.added = entityTo.modified = entityTo.isTemporary = NO;
		}
	}
}

- (void)onEntityFromListingUpdated:(YTEntityBase *)entity param:(NSObject *)param {
	[super onEntityFromListingUpdated:entity param:param];
	YTTagInfo *tag = ObjectCast(entity, YTTagInfo);
	YTNoteInfo *note = ObjectCast(param, YTNoteInfo);
	//YTNoteToTagInfo *info =
	[self addNoteTagWithNoteGuid:note.noteGuid tagId:tag.tagId];
}

- (void)dealloc {
	[super dealloc];
}

@end

