
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTLocationsEnManager : YTEntitiesManager {
@private
	NSMutableDictionary *_mapLocationById;
	NSMutableDictionary *_mapLocationByIdST;
	int64_t _lastVersionST;
	BOOL _updatingMT;
}

+ (YTLocationsEnManager *)shared;
- (YTLocationInfo *)getLocationById:(int64_t)locId;
- (YTLocationInfo *)getLocationByNoteGuid:(NSString *)noteGuid;

@end

