
#import <Foundation/Foundation.h>
#import "../Logic/Classes.h"

@interface VLWebDataAsyncLoaderArgs : VLCancelEventArgs {
@private
	NSString *_url;
	NSString *_sHash;
	BOOL _downloadDataToFile;
	NSData *_data;
	NSString *_dataFilePath;
	NSError *_error;
	NSObject<VLCancelable> *_cancelable;
}

@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSString *sHash;
@property(nonatomic, assign) BOOL downloadDataToFile;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) NSString *dataFilePath;
@property(nonatomic, retain) NSError *error;
@property(nonatomic, assign) NSObject<VLCancelable> *cancelable;

@end


typedef void (^VLWebDataAsyncLoaderBlockLoaderResult)(VLWebDataAsyncLoaderArgs *args);
typedef void (^VLWebDataAsyncLoaderBlockLoader)(VLWebDataAsyncLoaderArgs *args, VLWebDataAsyncLoaderBlockLoaderResult resultBlock);


@interface VLWebDataAsyncLoader : VLLogicObject {
@private
	NSMutableArray *_queueToLoad;
	NSMutableArray *_queueLoading;
	NSMutableArray *_queueLoaded;
	VLDelegate *_dlgtDataLoaded;
	VLTimer *_timer;
	VLWebDataAsyncLoaderBlockLoader _blockLoader;
	int _maxConcurrentOperationCount;
	int _curOperationsCount;
	int _loadingDataCount;
}

@property(nonatomic, readonly) VLDelegate *dlgtDataLoaded;
@property(nonatomic, readonly) int loadingDataCount;

- (void)setMaxConcurrentOperationCount:(int)cnt;
- (void)setBlockLoader:(VLWebDataAsyncLoaderBlockLoader)blockLoader;
- (void)startDownloadDataWithUrl:(NSString *)url sHash:(NSString *)sHash downloadDataToFile:(BOOL)downloadDataToFile;
- (void)startDownloadDataWithUrl:(NSString *)url sHash:(NSString *)sHash;
- (BOOL)containsDataWithUrl:(NSString *)url sHash:(NSString *)sHash;
- (void)cancelRequestWithUrl:(NSString *)url sHash:(NSString *)sHash;

@end
