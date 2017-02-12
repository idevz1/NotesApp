
#import <Foundation/Foundation.h>
#import "YTDbEntitiesManager.h"

@interface YTNotesContentDbManager : YTDbEntitiesManager {
@private
}

+ (YTNotesContentDbManager *)shared;
- (YTNoteContentInfo *)readContentInfoWithNoteGuid:(NSString *)noteGuid;
- (NSString *)readContentWithNoteGuid:(NSString *)noteGuid;
- (void)writeNoteConentInfo:(YTNoteContentInfo *)noteContent;
- (void)writeConent:(NSString *)sContent toNoteWithGuid:(NSString *)noteGuid;

@end

