
#import <Foundation/Foundation.h>
#import "YTEntitiesManager.h"

@interface YTNotesContentEnManager : YTEntitiesManager {
@private
	int64_t _lastVersionDT;
	BOOL _updatingMT;
}

+ (YTNotesContentEnManager *)shared;
- (void)readNoteContentForNoteWithGuid:(NSString *)noteGuid waitingUntilDone:(BOOL)wait resultBlock:(void(^)(YTNoteContentInfo *entity))resultBlock;
- (void)writeNoteContent:(YTNoteContentInfo *)noteContent resultBlock:(VLBlockVoid)resultBlock;

@end

