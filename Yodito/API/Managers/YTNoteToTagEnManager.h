
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTNoteToTagEnManager : YTEntitiesManager {
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

+ (YTNoteToTagEnManager *)shared;
- (NSDictionary *)getMapEntitiesByNote;
- (BOOL)hasNoteTagsById:(int64_t)tagId;
- (NSDictionary *)getNoteTagsById:(int64_t)tagId;
- (NSDictionary *)getNoteTagsByNoteGuid:(NSString *)noteGuid;
- (YTNoteToTagInfo *)getNoteTagByNoteGuid:(NSString *)noteGuid tagId:(int64_t)tagId;

@end

