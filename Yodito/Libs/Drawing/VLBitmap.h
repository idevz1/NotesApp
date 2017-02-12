
#import <Foundation/Foundation.h>
#import "VLColor.h"
#import "../Logic/Classes.h"

@interface VLBitmap : NSObject
{
@private
	CGContextRef _context;
	NSMutableData *_pixels;
	CGColorSpaceRef _colorSpace;
	int _width;
	int _height;
	UIImage *_cachedImage;
	BOOL _cachedImageCreated;
}

@property(nonatomic, readonly) BOOL isCreated;
@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;
@property(nonatomic, readonly) void *pixelsData;
@property(nonatomic, readonly) CGContextRef context;

- (void)createWithWidth:(int)width height:(int)height;
- (void)createWithImage:(UIImage*)image;
- (void)assignFrom:(VLBitmap*)other;
- (void)getPixel:(VLColor*)color x:(int)x y:(int)y;
- (void)setPixel:(VLColor*)color x:(int)x y:(int)y;
- (void)drawImage:(UIImage*)image;
- (void)freeUnusedMemory;
- (void)releaseData;
- (UIImage*)getCachedImage;

@end
