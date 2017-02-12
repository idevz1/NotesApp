
#import "YTLocationsEnManager.h"
#import "YTNoteToLocationEnManager.h"

static YTLocationsEnManager *_shared;

@implementation YTLocationsEnManager

+ (YTLocationsEnManager *)shared {
	if(!_shared)
		_shared = [[YTLocationsEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		_mapLocationById = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		_mapLocationByIdST = [[NSMutableDictionary alloc] initWithCapacity:kYTEntitiesManager_InitialCollectionCapacity];
		[[YTNoteToLocationEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNoteToLocationEnManagerChanged:)];
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTLocationsDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTLocationsDbManager *manrDb = [YTLocationsDbManager shared];
	[manrDb loadEntitiesFromDb];
}

- (void)updateOnDT {
	[super updateOnDT];
	if(_updatingMT)
		return;
	YTLocationsDbManager *manrDb = [YTLocationsDbManager shared];
	int64_t curVersionST = manrDb.version;
	if(_lastVersionST != curVersionST) {
		[_mapLocationByIdST removeAllObjects];
		for(YTLocationInfo *entity in manrDb.entities) {
			if(entity.deleted)
				continue;
			[_mapLocationByIdST setObject:entity forKey:[NSNumber numberWithLongLong:entity.locationId]];
		}
		_lastVersionST = curVersionST;
		_updatingMT = YES;
	}
}

- (void)updateOnMT {
	[super updateOnMT];
	if(!_updatingMT)
		return;
	[_mapLocationById removeAllObjects];
	[_mapLocationById addEntriesFromDictionary:_mapLocationByIdST];
	[self modifyVersion];
	_updatingMT = NO;
}

- (void)onNoteToLocationEnManagerChanged:(id)sender {
	[self modifyVersion];
}

- (YTLocationInfo *)getLocationById:(int64_t)locId; {
	[[YTDatabaseManager shared] checkIsMainThread];
	NSNumber *numId = [[NSNumber alloc] initWithLongLong:locId];
	YTLocationInfo *res = [_mapLocationById objectForKey:numId];
	[numId release];
	return res;
}

- (YTLocationInfo *)getLocationByNoteGuid:(NSString *)noteGuid {
	NSDictionary *infos = [[YTNoteToLocationEnManager shared] getNoteLocationsByNoteGuid:noteGuid];
	if(!infos.count)
		return nil;
	YTNoteToLocationInfo *info = [infos.allValues objectAtIndex:0];
	YTLocationInfo *res = [self getLocationById:info.locationId];
	return res;
}

- (void)dealloc {
	[super dealloc];
}

@end

