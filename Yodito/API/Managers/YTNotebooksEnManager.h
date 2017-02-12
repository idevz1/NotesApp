
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTNotebooksEnManager : YTEntitiesManager {
@private
	NSMutableDictionary *_mapNotebooks; // Notebook by guid
	NSMutableArray *_notebooks;
	NSMutableDictionary *_mapNotebooksST;
	NSMutableArray *_notebooksST;
	int64_t _lastVersionST;
	BOOL _updatingMT;
	YTNotebookInfo *_defaultNotebook;
}

@property(nonatomic, readonly) YTNotebookInfo *defaultNotebook;
@property(nonatomic, readonly) NSString *defaultNotebookGuid;

+ (YTNotebooksEnManager *)shared;
- (NSArray *)getNotebooks;
- (YTNotebookInfo *)getNotebookByGuid:(NSString *)notebookGuid;

@end

