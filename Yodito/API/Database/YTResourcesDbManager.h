
#import <Foundation/Foundation.h>
#import "YTDbNoteEntitiesBaseManager.h"

@interface YTResourcesDbManager : YTDbNoteEntitiesBaseManager {
@private
	NSMutableSet *_cachedAllAttachementHashes;
	int64_t _versionCachedAllAttachementHashes;
	NSMutableDictionary *_mapEntityById;
}

+ (YTResourcesDbManager *)shared;
- (NSSet *)getAllAttachementHashes;
- (YTResourceInfo *)getResourceById:(int64_t)resourceId;
- (YTResourceInfo *)getThumbnailForImage:(YTResourceInfo *)resImage;

@end

