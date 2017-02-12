
#import <Foundation/Foundation.h>
#import "../Logic/Classes.h"
#import "../Common/Classes.h"

@class VLTimer;

@interface VLCachedImageStore_ImageInfo : NSObject
{
@private
	UIImage *_image;
	NSString *_sHash;
	NSString *_filePathOuter;
	NSString *_filePathInner;
	BOOL _doNotLoadData;
}

@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) NSString *sHash;
@property(nonatomic, retain) NSString *filePathOuter;
@property(nonatomic, retain) NSString *filePathInner;
@property(nonatomic, assign) BOOL doNotLoadData;

@end


@interface VLCachedImageStore : NSObject
{
@private
	int _version;
	NSString *_dirName;
	NSString *_dirPath;
	VLTimer *_timer;
	int64_t _diskSpaceLimit;
	
	NSThread *_threadSave;
	NSMutableArray *_queueToSave;
	
	NSThread *_threadLoad;
	NSMutableArray *_queueToLoad;
	NSMutableArray *_queueLoaded;
	VLDelegate *_ntfrImageLoaded;
	
	BOOL _allowAutoDelete;
	NSThread *_threadCheckDiskSpace;
}

@property(nonatomic, readonly) VLDelegate *ntfrImageLoaded;
@property(nonatomic, assign) int64_t diskSpaceLimit;
@property(nonatomic, readonly) int64_t minDiskSpaceLimit;
@property(nonatomic, readonly) int64_t maxDiskSpaceLimit;

- (id)initWithDirName:(NSString *)dirName version:(int)version allowAutoDelete:(BOOL)allowAutoDelete;
- (id)initWithDirName:(NSString *)dirName version:(int)version;

- (VLCachedImageStore_ImageInfo *)startSaveImage:(UIImage *)image
   orImageFromFilePath:(NSString *)filePath
			  withHash:(NSString *)sHash
		   synchronous:(BOOL)synchronous;
- (void)startSaveImage:(UIImage *)image
   orImageFromFilePath:(NSString *)filePath
			  withHash:(NSString *)sHash;
- (VLCachedImageStore_ImageInfo *)loadImageByHash:(NSString *)sHash
									doNotLoadData:(BOOL)doNotLoadData
									   notExisted:(BOOL *)notExisted
								 startedLoadAsync:(BOOL *)startedLoadAsync;
- (NSArray *)getAllImagesHashes;
- (BOOL)containsImageWithHash:(NSString *)sHash;
- (NSString *)getFilePathForImageWithHash:(NSString *)sHash;
- (void)deleteImagesWithHashes:(NSArray *)hashes;
- (void)clear;

@end





