
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTEntitiesManagersLister : VLLogicObject <YTDatabaseManagerDelegate> {
@private
	NSMutableArray *_managersOrdered;
	VLTimer *_timer;
	BOOL _initialized;
	long _counterManagersUpdateOnDT;
	long _counterManagersUpdateOnMT;
}

@property(readonly) BOOL initialized;

+ (YTEntitiesManagersLister *)shared;
- (void)initializeMT;
- (void)initializeWithResultBlockMT:(VLBlockVoid)resultBlockMT;
- (void)waitForNextUpdateWithResultBlock:(VLBlockVoid)resultBlock;
- (void)addNewNote:(YTNoteEditInfo *)noteEditInfo resultBlock:(VLBlockVoid)resultBlock;
- (void)applyModifiedNote:(YTNoteEditInfo *)noteEditInfo doneEditing:(BOOL)doneEditing resultBlock:(VLBlockVoid)resultBlock;
- (void)deleteNote:(YTNoteInfo *)note withResultBlock:(VLBlockVoid)resultBlock;
- (void)changeNote:(YTNoteInfo *)note withNewDueDate:(VLDate *)dtDayNoTime resultBlock:(VLBlockVoid)resultBlock;
- (void)saveResourceImage:(UIImage *)image
				 fileName:(NSString *)fileName
		 withNoteEditInfo:(YTNoteEditInfo *)noteEditInfo
			  resultBlock:(VLBlockVoid)resultBlock;

- (void)addNewNotebook:(YTNotebookInfo *)notebook resultBlock:(VLBlockVoid)resultBlock;
- (void)deleteNotebook:(YTNotebookInfo *)notebook resultBlock:(VLBlockVoid)resultBlock;
- (void)renameNotebook:(YTNotebookInfo *)notebook withNewName:(NSString *)newName resultBlock:(VLBlockVoid)resultBlock;

@end

