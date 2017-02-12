
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"

@interface YTSyncCommitManager : YTLogicObject {
@private
	
}

+ (YTSyncCommitManager *)shared;

- (void)startSyncDTWithTicket:(int)ticket
				   managers:(NSArray *)managers
	syncExceptResourcesDoneBlockDT:(VLBlockVoid)syncExceptResourcesDoneBlockDT
				resultBlockDT:(void (^)(NSArray *outErrors))resultBlockDT;

@end

