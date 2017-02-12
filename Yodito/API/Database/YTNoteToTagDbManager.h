
#import <Foundation/Foundation.h>
#import "YTDbNoteEntitiesBaseManager.h"

@interface YTNoteToTagDbManager : YTDbNoteEntitiesBaseManager {
@private
	NSMutableDictionary *_mapEntitiesById;
	NSMutableDictionary *_mapEntitiesByNote;
}

+ (YTNoteToTagDbManager *)shared;
- (NSDictionary *)getMapEntitiesById;
- (NSDictionary *)getMapEntitiesByNote;
- (NSDictionary *)getNoteTagsById:(int64_t)tagId;
- (NSDictionary *)getNoteTagsByNoteGuid:(NSString *)noteGuid;
- (YTNoteToTagInfo *)getNoteTagByNoteGuid:(NSString *)noteGuid tagId:(int64_t)tagId;
- (YTNoteToTagInfo *)addNoteTagWithNoteGuid:(NSString *)noteGuid tagId:(int64_t)tagId;

@end

