
#import <Foundation/Foundation.h>
#import "YTDbEntitiesManager.h"

@interface YTNotesDbManager : YTDbEntitiesManager {
@private
	NSMutableDictionary *_mapNoteByGuid;
	NSMutableDictionary *_mapNotesByNotebookGuid;
}

+ (YTNotesDbManager *)shared;
- (YTNoteInfo *)getNoteByGuid:(NSString *)noteGuid;
- (NSArray *)getNotesByNotebookGuid:(NSString *)notebookGuid;
- (NSDictionary *)getMapNoteByGuid;
- (YTNoteInfo *)getNoteByResourceId:(int64_t)resourceId;
- (void)changeNote:(YTNoteInfo *)note withNotebookGuid:(NSString *)notebookGuid notebookId:(int64_t)notebookId;
- (void)updateNoteWithNewNote:(YTNoteInfo *)newNote fromWebWithData:(NSDictionary *)dictData;

@end

