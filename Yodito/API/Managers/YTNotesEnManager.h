
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTNotesEnManager : YTEntitiesManager {
@private
	NSMutableDictionary *_mapNotesByGuid;
	NSMutableDictionary *_mapNotesByGuidST;
	NSMutableDictionary *_mapNotesInNotebooks; // Array of notes by notebook guid
	NSMutableDictionary *_mapNotesInNotebooksST;
	NSMutableArray *_arrNotes;
	NSMutableArray *_arrNotesST;
	NSMutableArray *_arrNotesStarred;
	NSMutableArray *_arrNotesStarredST;
	int _notesStarredCount;
	int _notesStarredCountST;
	int64_t _lastVersionST;
	BOOL _updatingMT;
}

+ (YTNotesEnManager *)shared;
- (YTNoteInfo *)getNoteByGuidDT:(NSString *)noteGuid;
- (YTNoteInfo *)getNoteByGuid:(NSString *)noteGuid;
- (NSArray *)getNotesInNotebookWithGuid:(NSString *)notebookGuid;
- (NSArray *)getNotes;
- (NSArray *)getNotesStarred;
- (int)getNotesStarredCount;
- (int)getNotesCountInNotebookWithGuid:(NSString *)notebookGuid;
- (YTNoteInfo *)getNoteByResourceId:(int64_t)resourceId;

@end

