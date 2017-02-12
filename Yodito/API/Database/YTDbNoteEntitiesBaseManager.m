
#import "YTDbNoteEntitiesBaseManager.h"
#import "YTNotesDbManager.h"

@implementation YTDbNoteEntitiesBaseManager

- (BOOL)canPerformOperationWithEntity:(YTEntityBase *)entity syncType:(EYTSyncOperationType)syncType {
	[self checkIsDatabaseThread];
	return YES;
}

- (void)getRequestsParamsForList:(NSMutableArray *)arrRequestsParams {
	[self checkIsDatabaseThread];
	YTNotesDbManager *manrNotes = [YTNotesDbManager shared];
	NSMutableArray *parentEntitiesToSync = [NSMutableArray arrayWithArray:manrNotes.entities];
	for(int i = (int)parentEntitiesToSync.count - 1; i >= 0; i--) {
		YTNoteInfo *note = [parentEntitiesToSync objectAtIndex:i];
		if(note.deleted || note.added || note.isTemporary)
			[parentEntitiesToSync removeObjectAtIndex:i];
	}
	[arrRequestsParams addObjectsFromArray:parentEntitiesToSync];
}

- (void)getRequestForListWithParam:(NSObject *)param postValues:(NSMutableArray *)postValues {
	[self checkIsDatabaseThread];
	YTNoteInfo *note = ObjectCast(param, YTNoteInfo);
	[postValues addObject:note.noteGuid ? note.noteGuid : @""];
}

@end

