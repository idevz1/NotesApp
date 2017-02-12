
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"

#define kYTSyncChunkManager_SyncInBackground

@interface YTSyncChunkManager : YTLogicObject <NSCoding> {
@private
	int64_t _savedDataVersion;
}

+ (YTSyncChunkManager *)shared;

- (void)startCheckSyncChunkDTWithTicket:(int)ticket
						  resultBlockDT:(void (^)(NSArray *outErrors))resultBlockDT;

@end

