
#import <Foundation/Foundation.h>
#import "YTDbNoteEntitiesBaseManager.h"

@interface YTLocationsDbManager : YTDbNoteEntitiesBaseManager {
@private
	NSMutableDictionary *_mapEntityById;
}

+ (YTLocationsDbManager *)shared;
- (YTLocationInfo *)getLocationById:(int64_t)locId;
- (void)changeLocationIdFromLast:(int64_t)lastLocId toNew:(int64_t)newLocId;

@end

