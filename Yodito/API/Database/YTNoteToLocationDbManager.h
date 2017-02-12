
#import <Foundation/Foundation.h>
#import "YTDbNoteEntitiesBaseManager.h"

@interface YTNoteToLocationDbManager : YTDbNoteEntitiesBaseManager {
@private
	NSMutableDictionary *_mapEntitiesById;
	NSMutableDictionary *_mapEntitiesByNote;
}

+ (YTNoteToLocationDbManager *)shared;
- (NSDictionary *)getMapEntitiesById;
- (NSDictionary *)getMapEntitiesByNote;
- (NSDictionary *)getNoteLocationsById:(int64_t)locationId;
- (NSDictionary *)getNoteLocationsByNoteGuid:(NSString *)noteGuid;
- (YTNoteToLocationInfo *)getNoteLocationByNoteGuid:(NSString *)noteGuid locationId:(int64_t)locationId;
- (YTNoteToLocationInfo *)addNoteLocationWithNoteGuid:(NSString *)noteGuid locationId:(int64_t)locationId;
- (void)deleteNoteLocationWithNoteGuid:(NSString *)noteGuid locationId:(int64_t)locationId;
- (void)deleteNoteLocationsWithNoteGuid:(NSString *)noteGuid;

@end

