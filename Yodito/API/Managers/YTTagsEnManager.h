
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTTagsEnManager : YTEntitiesManager {
@private
	NSMutableArray *_arrEntities;
	NSMutableArray *_arrEntitiesST;
	NSMutableDictionary *_mapTagById;
	NSMutableDictionary *_mapTagByIdST;
	int64_t _lastVersionST;
	BOOL _updatingMT;
}

+ (YTTagsEnManager *)shared;
- (NSArray *)getAllTags;
- (YTTagInfo *)getTagById:(int64_t)tagId;
- (NSArray *)getTagsByIds:(NSSet *)ids;
- (BOOL)hasTagsWithIds:(NSSet *)ids;
- (NSDictionary *)getMapTagById;
- (NSDictionary *)getTagsByNoteGuid:(NSString *)noteGuid;
- (BOOL)hasTagsByNoteGuid:(NSString *)noteGuid;
- (NSDictionary *)getMapTagsByNoteGuid;

@end

