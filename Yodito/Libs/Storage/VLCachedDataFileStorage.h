
#import <Foundation/Foundation.h>
#import "../Common/Classes.h"
#import "../Logic/Classes.h"

@interface VLCachedDataFileStorageArgs : VLCancelEventArgs {
@private
	NSString *_sHash;
	NSData *_data;
	NSString *_filePathOuter;
	NSString *_filePathInner;
	BOOL _doNotLoadData;
	NSError *_error;
	NSObject<VLCancelable> *_cancelable;
}

@property(nonatomic, retain) NSString *sHash;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) NSString *filePathOuter;
@property(nonatomic, retain) NSString *filePathInner;
@property(nonatomic, assign) BOOL doNotLoadData;
@property(nonatomic, retain) NSError *error;
@property(nonatomic, assign) NSObject<VLCancelable> *cancelable;

@end


@interface VLCachedDataFileStorage_FileInfo : NSObject {
@private
}

@property(nonatomic, retain) NSString *sHash;
@property(nonatomic, retain) NSDate *timestamp;
@property(nonatomic, assign) int fileSize;

@end


typedef void (^VLCachedDataFileStorage_BlockBeforeClearDisk)(NSArray *arrFileInfo, NSMutableArray *outArrFileInfoToDelete);


@interface VLCachedDataFileStorage : NSObject {
@private
	NSString *_dirPath;
	VLTimer *_timer;
	
	NSThread *_threadSave;
	NSMutableArray *_queueToSave;
	NSMutableArray *_queueSaved;
	VLDelegate *_dlgtDataSaved;
	
	NSThread *_threadLoad;
	NSMutableArray *_queueToLoad;
	NSMutableArray *_queueLoaded;
	VLDelegate *_dlgtDataLoaded;
	
	VLCachedDataFileStorage_BlockBeforeClearDisk _blockBeforeClearDisk;
	BOOL _callBlockBeforeClearDiskOnMainThread;
	NSThread *_threadClearDisk;
	NSTimeInterval _clearDiskInterval;
	BOOL _needsClearing;
}

@property(nonatomic,readonly) VLDelegate *dlgtDataSaved;
@property(nonatomic,readonly) VLDelegate *dlgtDataLoaded;
@property(nonatomic,assign) NSTimeInterval clearDiskInterval;

- (id)initWithDirPath:(NSString *)dirPath;
- (void)setBlockBeforeClearDisk:(VLCachedDataFileStorage_BlockBeforeClearDisk)blockBeforeClearDisk callOnMainThread:(BOOL)callOnMainThread;
- (void)setBlockBeforeClearDisk:(VLCachedDataFileStorage_BlockBeforeClearDisk)blockBeforeClearDisk;
- (void)startSaveData:(NSData *)data orDataFromFile:(NSString *)dataFilePath withHash:(NSString *)sHash;
- (VLCachedDataFileStorageArgs *)loadDataByHash:(NSString *)sHash
			 doNotLoadData:(BOOL)doNotLoadData
				 notExisted:(BOOL *)notExisted
		   startedLoadAsync:(BOOL *)startedLoadAsync;
- (BOOL)containsDataWithHash:(NSString *)sHash;
- (NSData *)getDataSynchronousWithHash:(NSString *)sHash;
- (NSString *)filePathToDataWithHash:(NSString *)sHash;
- (NSArray *)getAllDataHashes;
- (void)deleteDataWithHash:(NSString *)sHash;

@end

