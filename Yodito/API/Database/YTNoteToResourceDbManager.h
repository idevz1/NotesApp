
#import <Foundation/Foundation.h>
#import "YTDbNoteEntitiesBaseManager.h"

@interface YTNoteToResourceDbManager : YTDbNoteEntitiesBaseManager {
@private
	NSMutableDictionary *_mapEntitiesById;
	NSMutableDictionary *_mapEntitiesByNote;
}

+ (YTNoteToResourceDbManager *)shared;
- (NSDictionary *)getMapEntitiesById;
- (NSDictionary *)getMapEntitiesByNote;
- (NSDictionary *)getNoteResourcesByResourceId:(int64_t)resourceId;
- (NSDictionary *)getNoteResourcesByNoteGuid:(NSString *)noteGuid;
- (YTNoteToResourceInfo *)getNoteResourceByNoteGuid:(NSString *)noteGuid resourceId:(int64_t)resourceId;
- (YTNoteToResourceInfo *)addNoteResourceWithNoteGuid:(NSString *)noteGuid resourceId:(int64_t)resourceId;

@end

