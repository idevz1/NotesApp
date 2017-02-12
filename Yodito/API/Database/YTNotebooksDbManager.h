
#import <Foundation/Foundation.h>
#import "YTDbEntitiesManager.h"

@interface YTNotebooksDbManager : YTDbEntitiesManager {
@private
	NSMutableDictionary *_mapNotebooks; // Notebook by guid
}

+ (YTNotebooksDbManager *)shared;
- (YTNotebookInfo *)getNotebookByGuid:(NSString *)notebookGuid;
- (NSDictionary *)getMapNotebookByGuid;

@end

