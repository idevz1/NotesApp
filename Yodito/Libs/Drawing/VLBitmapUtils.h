
#import <Foundation/Foundation.h>

@interface VLBitmapUtils : NSObject

+ (UIImage*)grayscaleImageFromImage:(UIImage*)image;
+ (UIImage*)flipImageHorizontal:(UIImage*)image;
+ (UIImage*)cropImage:(UIImage*)image withRect:(CGRect)rect;
+ (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)newSize;
+ (UIImage*)lightUpImage:(UIImage*)image withRatio:(float)ratio;

@end
