
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTNoteToResourceEnManager : YTEntitiesManager {
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

+ (YTNoteToResourceEnManager *)shared;
- (NSDictionary *)getMapEntitiesByNote;
- (NSDictionary *)getNoteResourcesByResourceId:(int64_t)resourceId;
- (NSDictionary *)getNoteResourcesByNoteGuid:(NSString *)noteGuid;

@end

