
#import <Foundation/Foundation.h>

@interface YTImageSizeCacheInfo : NSObject {
@private
	CGSize _size;
	UIImageOrientation _orient;
}

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) UIImageOrientation orient;

@end


@interface YTImageUtilities : NSObject
{
	
}

+ (void)saveJPEGImage:(UIImage*)image path:(NSString *)path quality:(float)quality;
+ (void)saveJPEGImage:(UIImage*)image path:(NSString *)path;
+ (void)savePNGImage:(UIImage*)image path:(NSString *)path;

+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath imageOrientation:(UIImageOrientation*)imageOrientation fileExt:(NSString *)fileExt;
+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath imageOrientation:(UIImageOrientation*)imageOrientation;
+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath;

@end
