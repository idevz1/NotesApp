
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"
#import "YTResourceLoadingInfo.h"

@interface YTResourcesStorage : VLLogicObject {
@private
	NSString *_dirPath;
	VLCachedDataFileStorage *_fileStorage;
	VLWebDataAsyncLoader *_webDataAsyncLoader;
	NSMutableArray *_loadingInfos;
	int _maxFilesStorageSize;
	NSString *_hashWaitingForSave;
	VLCachedDataFileStorageArgs *_argsWaitedForSave;
}

@property(nonatomic, readonly) int downloadingFilesCount;

+ (YTResourcesStorage *)shared;
- (void)initialize;
- (void)addReference:(YTResourceLoadingReference *)reference;
- (void)removeReference:(YTResourceLoadingReference *)reference;
- (void)saveData:(NSData *)data orDataFromFile:(NSString *)dataFilePath
		withHash:(NSString *)sHash skip:(BOOL)skip resultBlock:(VLBlockVoid)resultBlock;
- (NSData *)getDataSynchronousWithHash:(NSString *)sHash;
- (BOOL)isResourceDownloadedWithHash:(NSString *)sHash;
- (NSString *)filePathToDownloadedResourceWithHash:(NSString *)sHash;
- (void)startLoadResource:(YTResourceLoadingInfo *)loadingInfo;
- (CGSize)sizeOfLoadedImage:(YTResourceInfo *)res;

@end

