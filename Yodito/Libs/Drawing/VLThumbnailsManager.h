
#import <Foundation/Foundation.h>
#import "../Logic/Classes.h"

@class VLCachedImageStore;
@class VLTimer;

typedef enum
{
	EVLThumbnailContentModeAspectFit,
	EVLThumbnailContentModeAspectFill
}
EVLThumbnailContentMode;


@interface VLThumbnailCreateInfo : NSObject
{
@private
	UIImage *_image;
	NSString *_imageFilePath;
	NSString *_imageHash;
	float _thumbWidth;
	float _thumbHeight;
	EVLThumbnailContentMode _thumbContentMode;
	UIImage *_thumbnail;
	NSString *_thumbnailHash;
	NSString *_thumbnailFilePath;
	BOOL _saveThumbnailToFile;
	NSError *_error;
}

@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) NSString *imageFilePath;
@property(nonatomic, retain) NSString *imageHash;
@property(nonatomic, assign) float thumbWidth;
@property(nonatomic, assign) float thumbHeight;
@property(nonatomic, assign) EVLThumbnailContentMode thumbContentMode;
@property(nonatomic, retain) UIImage *thumbnail;
@property(nonatomic, retain) NSString *thumbnailHash;
@property(nonatomic, retain) NSString *thumbnailFilePath;
@property(nonatomic, assign) BOOL saveThumbnailToFile;
@property(nonatomic, retain) NSError *error;

@end


@interface VLThumbnailsManager : NSObject
{
@private
	NSThread *_threadCreateThumbs;
	NSMutableArray *_queueToProcess;
	NSMutableArray *_queueProcessedReady;
	NSMutableArray *_queueWaitingForLoad;
	VLTimer *_timer;
	VLDelegate *_ntfrThumbnailReady;
	VLCachedDictionary *_cacheThumbnails;
	VLCachedImageStore *_cachedImageStore;
}

@property(nonatomic, readonly) VLDelegate *ntfrThumbnailReady;

- (id)initWithCachedImageStore:(VLCachedImageStore *)cachedImageStore;

+ (NSString *)thumbnailHashWithImageHash:(NSString *)imageHash
								   width:(float)width
								  height:(float)height
							 contentMode:(EVLThumbnailContentMode)contentMode;

- (VLThumbnailCreateInfo *)getThumbnailForImage:(UIImage *)image
				 orImageFilePath:(NSString *)imageFilePath
						withHash:(NSString *)imageHash
						   width:(float)width
						  height:(float)height
					 contentMode:(EVLThumbnailContentMode)contentMode
			 saveThumbnailToFile:(BOOL)saveThumbnailToFile
			       thumbnailHash:(NSString **)pThumbnailHash
				startedLoadAsync:(BOOL *)startedLoadAsync
				allowReturnImage:(BOOL)allowReturnImage
			 waitForLoadFromDisk:(BOOL)waitForLoadFromDisk; // waitForLoadFromDisk - not used yet. for future.

- (UIImage *)makeThumbnailWithImage:(UIImage *)image
						 thumbSize:(CGSize)thumbSize
					   contentMode:(EVLThumbnailContentMode)contentMode;

@end

