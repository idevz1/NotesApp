
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTNoteToLocationEnManager : YTEntitiesManager {
@private
	int64_t _lastVersionDT;
	BOOL _updatingMT;
	NSMutableArray *_arrEntitiesDT;
	NSMutableArray *_arrEntities;
	NSMutableDictionary *_mapEntitiesByIdDT;
	NSMutableDictionary *_mapEntitiesById;
	NSMutableDictionary *_mapEntitiesByNoteDT;
	NSMutableDictionary *_mapEntitiesByNote;
}

+ (YTNoteToLocationEnManager *)shared;
- (NSDictionary *)getNoteLocationsByNoteGuid:(NSString *)noteGuid;
- (YTNoteToLocationInfo *)getNoteLocationByNoteGuid:(NSString *)noteGuid locationId:(int64_t)locationId;

@end

