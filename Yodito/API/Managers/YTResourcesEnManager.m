
#import "YTResourcesEnManager.h"
#import "YTNotesEnManager.h"
#import "YTNoteToResourceEnManager.h"

static YTResourcesEnManager *_shared;

@implementation YTResourcesEnManager

+ (YTResourcesEnManager *)shared {
	if(!_shared)
		_shared = [[YTResourcesEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		_arrEntitiesDT = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_arrEntities = [[NSMutableArray alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapEntityByIdDT = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapEntityById = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		[[YTNoteToResourceEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNoteToResourceEnManagerChanged:)];
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTResourcesDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTResourcesDbManager *manrDb = [YTResourcesDbManager shared];
	[manrDb loadEntitiesFromDb];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTResourcesDbManager *manrDbRes = [YTResourcesDbManager shared];
	int64_t curVersionDT = manrDbRes.version;
	if(_lastVersionDT != curVersionDT) {
		[_arrEntitiesDT removeAllObjects];
		[_mapEntityByIdDT removeAllObjects];
		for(YTResourceInfo *entity in manrDbRes.entities) {
			if(entity.deleted)
				continue;
			[_arrEntitiesDT addObject:entity];
		}
		_photosCountDT = 0;
		for(YTResourceInfo *entity in _arrEntitiesDT) {
			if([entity isImage] && ![entity isThumbnail]) {
				_photosCountDT++;
			}
			[_mapEntityByIdDT setObject:entity forKey:[NSNumber numberWithLongLong:entity.attachmentId]];
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
	[_mapEntityById removeAllObjects];
	[_mapEntityById addEntriesFromDictionary:_mapEntityByIdDT];
	_photosCount = _photosCountDT;
	[self modifyVersion];
	_updatingMT = NO;
}

- (void)onNoteToResourceEnManagerChanged:(id)sender {
	[self modifyVersion];
}

- (NSArray *)getAllResources {
	return _arrEntities;
}

- (YTResourceInfo *)getResourceById:(int64_t)resourceId {
	NSNumber *numId = [[NSNumber alloc] initWithLongLong:resourceId];
	YTResourceInfo *res = [_mapEntityById objectForKey:numId];
	[numId release];
	return res;
}

- (int)getPhotosCount {
	return _photosCount;
}

- (YTResourceInfo *)thumbnailForImage:(YTResourceInfo *)resImage inResources:(NSArray *)resources {
	if(!resImage || ![resImage isImage] || resImage.isThumbnail)
		return nil;
	for(YTResourceInfo *res in resources) {
		if(![res isImage] || !res.isThumbnail)
			continue;
		if(res.parentAttachmentId && res.parentAttachmentId == resImage.attachmentId)
			return res;
	}
	return nil;
}

- (YTResourceInfo *)thumbnailForImage:(YTResourceInfo *)resImage {
	return [self thumbnailForImage:resImage inResources:[self getAllResources]];
}

- (NSDictionary *)getResourcesForNoteWithGuid:(NSString *)noteGuid {
	NSDictionary *infos = [[YTNoteToResourceEnManager shared] getNoteResourcesByNoteGuid:noteGuid];
	if(!infos.count)
		return [NSDictionary dictionary];
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:infos.count];
	for(YTNoteToResourceInfo *info in infos.allValues) {
		YTResourceInfo *resource = [self getResourceById:info.resourceId];
		if(resource)
			[result setObject:resource forKey:[NSNumber numberWithLongLong:resource.attachmentId]];
	}
	return result;
}

- (NSDictionary *)getMapResourcesByNoteGuid {
	NSDictionary *mapByNote = [[YTNoteToResourceEnManager shared] getMapEntitiesByNote];
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:mapByNote.count];
	for(NSString *noteGuid in mapByNote.allKeys) {
		NSDictionary *mapById = [mapByNote objectForKey:noteGuid];
		NSMutableDictionary *entities = [NSMutableDictionary dictionaryWithCapacity:mapById.count];
		[result setObject:entities forKey:noteGuid];
		for(NSNumber *numId in mapById.allKeys) {
			YTResourceInfo *resource = [self getResourceById:numId.longLongValue];
			if(resource)
				[entities setObject:resource forKey:numId];
		}
	}
	return result;
}

- (void)dealloc {
	[super dealloc];
}

@end

