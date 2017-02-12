
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTResourcesEnManager : YTEntitiesManager {
@private
	int64_t _lastVersionDT;
	BOOL _updatingMT;
	NSMutableArray *_arrEntitiesDT;
	NSMutableArray *_arrEntities;
	NSMutableDictionary *_mapEntityByIdDT;
	NSMutableDictionary *_mapEntityById;
	int _photosCountDT;
	int _photosCount;
}

+ (YTResourcesEnManager *)shared;
- (NSArray *)getAllResources;
- (YTResourceInfo *)getResourceById:(int64_t)resourceId;
- (int)getPhotosCount;
- (YTResourceInfo *)thumbnailForImage:(YTResourceInfo *)resImage inResources:(NSArray *)resources;
- (YTResourceInfo *)thumbnailForImage:(YTResourceInfo *)resImage;
- (NSDictionary *)getResourcesForNoteWithGuid:(NSString *)noteGuid;
- (NSDictionary *)getMapResourcesByNoteGuid;

@end

