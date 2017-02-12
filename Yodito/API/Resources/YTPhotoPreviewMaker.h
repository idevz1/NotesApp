
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

@interface YTPhotoPreviewMaker : NSObject {
@private
	NSString *_dirPath;
}

+ (YTPhotoPreviewMaker *)shared;
- (NSArray *)getAllImagesHashes;
- (void)startMakeWithImageHash:(NSString *)imageHash imageFilePath:(NSString *)imageFilePath skip:(BOOL)skip resultBlock:(VLBlockVoid)resultBlock;
- (NSString *)getMiniPreviewFilePath:(NSString *)imageHash imageSize:(CGSize *)pImageSize;
- (NSString *)getThumbnailFilePath:(NSString *)imageHash imageSize:(CGSize *)pImageSize;
- (NSString *)getPreviewFilePath:(NSString *)imageHash imageSize:(CGSize *)pImageSize;
- (UIImage *)makeThumbnailWithImage:(UIImage *)image
						  thumbSize:(CGSize)thumbSize
						contentMode:(UIViewContentMode)contentMode;
- (void)deleteImageWithHash:(NSString *)sHash;

@end





