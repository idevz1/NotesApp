
#import "YTTagsDbManager.h"
#import "YTDatabaseManager.h"
#import "YTNotesDbManager.h"

static YTTagsDbManager *_shared;

@implementation YTTagsDbManager

+ (YTTagsDbManager *)shared {
	if(!_shared)
		_shared = [[YTTagsDbManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super initWithEntityClass:[YTTagInfo class] database:[YTDatabaseManager shared].database];
	if(self) {
		_shared = self;
		_mapTagById = [[NSMutableDictionary alloc] init];
		_mapEntitiesByNoteGuid = [[NSMutableDictionary alloc] init];
		[[YTDatabaseManager shared].dlgtEntityIdChanged addObserver:self selector:@selector(onEntityIdChanged:args:)];
	}
	return self;
}

- (void)initialize {
	[super initialize];
}

- (void)loadEntitiesFromDb {
	[super loadEntitiesFromDb];
	[_mapTagById removeAllObjects];
	[_mapEntitiesByNoteGuid removeAllObjects];
	for(YTTagInfo *entity in [NSArray arrayWithArray:self.entities]) {
		NSNumber *numId = [NSNumber numberWithLongLong:entity.tagId];
		[_mapTagById setObject:entity forKey:numId];
		NSMutableDictionary *entities = [_mapEntitiesByNoteGuid objectForKey:numId];
		if(!entities) {
			entities = [NSMutableDictionary dictionary];
			[_mapEntitiesByNoteGuid setObject:entities forKey:numId];
		}
		[entities setObject:entity forKey:numId];
	}
}

- (void)addEntity:(VLSqliteEntity *)entity {
	[super addEntity:entity];
	YTTagInfo *tag = (YTTagInfo *)entity;
	NSNumber *numId = [NSNumber numberWithLongLong:tag.tagId];
	[_mapTagById setObject:tag forKey:numId];
	NSMutableDictionary *entities = [_mapEntitiesByNoteGuid objectForKey:numId];
	if(!entities) {
		entities = [NSMutableDictionary dictionary];
		[_mapEntitiesByNoteGuid setObject:entities forKey:numId];
	}
	[entities setObject:entity forKey:numId];
}

- (void)deleteEntityFromDb:(VLSqliteEntity *)entity {
	[super deleteEntityFromDb:entity];
	YTTagInfo *tag = (YTTagInfo *)entity;
	NSNumber *numId = [NSNumber numberWithLongLong:tag.tagId];
	[_mapTagById removeObjectForKey:numId];
	NSMutableDictionary *entities = [_mapEntitiesByNoteGuid objectForKey:numId];
	if(entities) {
		[entities removeObjectForKey:numId];
	}
}

- (void)deleteAllEntitiesFromDb {
	[super deleteAllEntitiesFromDb];
	[_mapTagById removeAllObjects];
	[_mapEntitiesByNoteGuid removeAllObjects];
}

- (void)onEntityIdChanged:(id)sender args:(YTEntityIdChangedArgs *)args {
	[self checkIsDatabaseThread];
	YTTagInfo *tag = ObjectCast(args.entity, YTTagInfo);
	if(tag) {
		NSNumber *numdIdLast = [NSNumber numberWithLongLong:args.idLast];
		NSNumber *numdINew = [NSNumber numberWithLongLong:args.idNew];
		YTEntityBase *entity = [_mapTagById objectForKey:numdIdLast];
		if(entity) {
			[_mapTagById setObject:entity forKey:numdINew];
			[_mapTagById removeObjectForKey:numdIdLast];
		}
	}
}

- (YTTagInfo *)getTagById:(int64_t)tagId {
	NSNumber *numId = [[NSNumber alloc] initWithLongLong:tagId];
	YTTagInfo *res = [_mapTagById objectForKey:numId];
	[numId release];
	return res;
}

- (NSString *)apiOperationForDelete {
	return @"";
	//return kYTUrlValueOperationDeleteTag;
}

- (NSString *)apiOperationForAddEntity:(YTEntityBase *)entity {
	return @"";
	//return kYTUrlValueOperationCreateTag;
}

- (NSString *)apiOperationForModifyEntity:(YTEntityBase *)entity {
	// Do not modify tags, just add/delete
	//return kYTUrlValueOperationUpdateTag;
	return @"";
}

- (NSString *)apiOperationForList {
	return @"";
	//return kYTUrlValueOperationListTags;
}

- (void)getRequestForDeleteEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	/*YTTagInfo *tag = ObjectCast(entity, YTTagInfo);
	YTNoteInfo *note = [[YTNotesDbManager shared] getNoteByTagId:tag.tagId];
	[postValues addObject:note ? note.noteGuid : @""];
	[postValues addObject:[NSNumber numberWithLongLong:tag.tagId]];
	[postValues addObject:[tag.lastUpdateTS yoditoToString]];*/
}

- (void)getRequestForAddEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues arrFiles:(NSMutableArray *)arrFiles needSkip:(BOOL *)needSkip {
	/*YTTagInfo *tag = ObjectCast(entity, YTTagInfo);
	YTNoteInfo *note = [[YTNotesDbManager shared] getNoteByTagId:tag.tagId];
	[postValues addObject:note ? note.noteGuid : @""];
	NSString *sFormat = @"{\n\
    \"Name\": \"%@\",\n\
	\"LastUpdateTS\": \"%@\"\n\
	}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   [YTWebRequest escapeJsonText:tag.name],
					   [tag.lastUpdateTS yoditoToString]
					   ];
	[postValues addObject:sData];*/
}

- (void)onGetResponseForAddEntity:(YTEntityBase *)entity response:(NSDictionary *)response {
	/*YTTagInfo *tag = ObjectCast(entity, YTTagInfo);
	int64_t newId = [response int64ValueForKey:kYTJsonKeyResultCode defaultVal:0];
	YTTagInfo *existedTag = [self getTagById:newId];
	if(existedTag) {
		[self deleteEntityFromDb:tag];
		return;
	}
	BOOL wasModified = tag.modified;
	VLDate *lastUpdateTS = [[tag.lastUpdateTS retain] autorelease];
	int64_t lastTagId = tag.tagId;
	tag.tagId = newId;
	if([[YTDatabaseManager shared] isTempId:lastTagId]) {
		[[YTDatabaseManager shared] changeTagIdFromLast:lastTagId toNew:tag.tagId];
	}
	tag.added = NO;
	tag.lastUpdateTS = lastUpdateTS;
	tag.modified = wasModified;*/
}

- (void)getRequestForModifyEntity:(YTEntityBase *)entity postValues:(NSMutableArray *)postValues {
	YTTagInfo *tag = ObjectCast(entity, YTTagInfo);
	NSString *sFormat = @"{\n\
\"TagId\":%@,\n\
\"Name\":\"%@\",\n\
\"LastUpdateTS\":\"%@\"\n\
}";
	NSString *sData = [NSString stringWithFormat:sFormat,
					   tag.tagId ? [[NSNumber numberWithLongLong:tag.tagId] stringValue] : @"null",
					   [YTWebRequest escapeJsonText:tag.name],
					   [tag.lastUpdateTS yoditoToString]
					   ];
	[postValues addObject:sData];
}

- (void)parseEntitiesFromDataArray:(NSArray *)arrData param:(NSObject *)param result:(NSMutableArray *)arrEntities {
	//YTNoteInfo *note = ObjectCast(param, YTNoteInfo);
	NSMutableSet *tagsIds = [NSMutableSet setWithCapacity:arrData.count];
	for(NSDictionary *data in arrData) {
		YTTagInfo *tag = [[YTTagInfo new] autorelease];
		[tag loadFromData:data urlDecode:YES];
		[arrEntities addObject:tag];
		[tagsIds addObject:[NSNumber numberWithLongLong:tag.tagId]];
	}
	//note.tagsIds = tagsIds;
}

- (void)dealloc {
	[super dealloc];
}

@end

