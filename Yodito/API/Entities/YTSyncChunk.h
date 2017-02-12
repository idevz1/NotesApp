
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

// !!! Not completed
@interface YTSyncChunk : YTEntityBase {
@private
	VLDate *_currentTime;
	VLDate *_chunkHighTS;
	VLDate *_lastUpdatedTS;
	NSMutableArray *_notes;
	NSMutableArray *_notebooks;
	NSMutableArray *_tags;
	NSMutableArray *_resources;
	NSMutableArray *_linkedNotebooks;
}

@property(nonatomic, assign) VLDate *currentTime;
@property(nonatomic, assign) VLDate *chunkHighTS;
@property(nonatomic, assign) VLDate *lastUpdatedTS;
@property(nonatomic, assign) NSArray *notes;
@property(nonatomic, assign) NSArray *notebooks;
@property(nonatomic, assign) NSArray *tags;
@property(nonatomic, assign) NSArray *resources;
@property(nonatomic, assign) NSArray *linkedNotebooks;

@end

/*
 13	Data Structure Name: 		SyncChunk
 Field Structure:
 
 currentTime		Timestamp
 chunkHighTS		Timestamp
 lastUpdatedTS		Timestamp
 notes			List<Note>
 notebooks		List<Notebook>
 tags			List<Tag>
 resources		List<Resource>
 linkedNotebooks	List<Linked Notebook>

*/
