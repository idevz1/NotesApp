
#import <Foundation/Foundation.h>
#import "YTDbNoteEntitiesBaseManager.h"

@interface YTTagsDbManager : YTDbNoteEntitiesBaseManager {
@private
	NSMutableDictionary *_mapTagById; // NSMutableArray of YTTagInfo by Tag ID
	NSMutableDictionary *_mapEntitiesByNoteGuid;
}

+ (YTTagsDbManager *)shared;
- (YTTagInfo *)getTagById:(int64_t)tagId;

@end

