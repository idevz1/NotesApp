
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTSyncState : YTEntityBase {
@private
	VLDate *_currentTime;
	VLDate *_chunkHighTS;
	int64_t _uploaded;
}

@property(nonatomic, assign) VLDate *currentTime;
@property(nonatomic, assign) VLDate *chunkHighTS;
@property(nonatomic, assign) int64_t uploaded;

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

@end

/*
 14	Data Structure Name: 		SyncState
 Field Structure:
 
 currentTime		Timestamp
 chunkHighTS		Timestamp
 uploaded		Int

*/

