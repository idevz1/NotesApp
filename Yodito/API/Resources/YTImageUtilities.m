
#import "YTImageUtilities.h"
#import <ImageIO/ImageIO.h>
#import "../../Libs/Classes.h"

#define kUseNSData NO//YES

@implementation YTImageSizeCacheInfo

@synthesize size = _size;
@synthesize orient = _orient;

@end


@implementation YTImageUtilities

+ (int)propertyOrientationFromImageOrientation:(UIImageOrientation)imageOrient
{
	int orientation = 1;
	switch(imageOrient)
	{
		case UIImageOrientationUp:				orientation =	1; break;
		case UIImageOrientationDown:			orientation =	3; break;
		case UIImageOrientationLeft:			orientation =	8; break;
		case UIImageOrientationRight:			orientation =	6; break;
		case UIImageOrientationUpMirrored:		orientation =	2; break;
		case UIImageOrientationDownMirrored:	orientation =	4; break;
		case UIImageOrientationLeftMirrored:	orientation =	5; break;
		case UIImageOrientationRightMirrored:	orientation =	7; break;
	}
	return orientation;
}
+ (UIImageOrientation)imageOrientationFromPropertyOrientation:(int)orientation
{
	UIImageOrientation imageOrient = UIImageOrientationUp;
	switch(orientation)
	{
		case 1: imageOrient = UIImageOrientationUp; break;
		case 2: imageOrient = UIImageOrientationUpMirrored; break;
		case 3: imageOrient = UIImageOrientationDown; break;
		case 4: imageOrient = UIImageOrientationDownMirrored; break;
		case 5: imageOrient = UIImageOrientationLeftMirrored; break;
		case 6: imageOrient = UIImageOrientationRight; break;
		case 7: imageOrient = UIImageOrientationRightMirrored; break;
		case 8: imageOrient = UIImageOrientationLeft; break;
	}
	return imageOrient;
}

/*
 EXIF orientation:
 1	Top	Left side
 2*	Top	Right side
 3	Bottom	Right side
 4*	Bottom	Left side
 5*	Left side	Top
 6	Right side	Top
 7*	Right side	Bottom
 8	Left side	Bottom
*/

+ (void)saveJPEGImage:(UIImage*)image path:(NSString *)path quality:(float)quality
{
	quality = MIN(MAX(quality, 0.0), 1.0);
	if(kUseNSData || kIosVersionFloat < 4.0)
	{
		NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
		NSData *imageData = UIImageJPEGRepresentation(image, quality);
		if (imageData != nil)
			[imageData writeToFile:path atomically:YES];
		[arpool drain];
		return;
	}
	CGImageRef imageRef = image.CGImage;
	int orientation = [[self class] propertyOrientationFromImageOrientation:image.imageOrientation];
	
	NSDictionary *imageDestinationWriteOptions = [NSDictionary dictionaryWithObjectsAndKeys:
												  [NSNumber numberWithInt:orientation], (id)kCGImagePropertyOrientation,
												  (id)kCFBooleanFalse, (id)kCGImagePropertyHasAlpha,
												  [NSNumber numberWithInt:quality], kCGImageDestinationLossyCompressionQuality,
												  nil];
	
	NSURL *outURL = [[[NSURL alloc] initFileURLWithPath:path] autorelease];
	CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((CFURLRef)outURL, (CFStringRef)@"public.jpeg", 1, NULL);
	if(imageDestination)
	{
		CGImageDestinationAddImage(imageDestination, imageRef, (CFDictionaryRef)imageDestinationWriteOptions);
		CGImageDestinationFinalize(imageDestination);
		CFRelease(imageDestination);
	}
}

+ (void)saveJPEGImage:(UIImage*)image path:(NSString *)path
{
	[[self class] saveJPEGImage:image path:path quality:1.0];
}

+ (void)savePNGImage:(UIImage*)image path:(NSString *)path
{
	if(kUseNSData || kIosVersionFloat < 4.0)
	{
		NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
		NSData *imageData = UIImagePNGRepresentation(image);
		if (imageData != nil)
			[imageData writeToFile:path atomically:YES];
		[arpool drain];
		return;
	}
	CGImageRef imageRef = image.CGImage;
	int orientation = [[self class] propertyOrientationFromImageOrientation:image.imageOrientation];
	
	NSDictionary *imageDestinationWriteOptions = [NSDictionary dictionaryWithObjectsAndKeys:
												  [NSNumber numberWithInt:orientation], (id)kCGImagePropertyOrientation,
												  (id)kCFBooleanFalse, (id)kCGImagePropertyHasAlpha,
												  [NSNumber numberWithInt:1.0], kCGImageDestinationLossyCompressionQuality,
												  nil];
	NSURL *outURL = [[[NSURL alloc] initFileURLWithPath:path] autorelease]; 
	CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((CFURLRef)outURL, (CFStringRef)@"public.png", 1, NULL);
	if(imageDestination)
	{
		CGImageDestinationAddImage(imageDestination, imageRef, (CFDictionaryRef)imageDestinationWriteOptions);
		CGImageDestinationFinalize(imageDestination);
		CFRelease(imageDestination);
	}
}

+ (CGSize)getPngSizeFromMetaData:(NSString*)fullFileName
{
	long resultWidth = 0;
    long resultHeight = 0;
    // File Name to C String.
    const char* fileName = [fullFileName UTF8String];
    /* source file */ 
    FILE * infile;
    // Check if can open the file.
    if ((infile = fopen(fileName, "rb")) == NULL) 
    {
        NSLog(@"ERROR: getPngSizeFromMetaData: can't open the file: %@", fullFileName );
    }
	else
	{
		//////  //////      //////  //////  //////  //////  //////  //////  //////  //////  //////
		// Lenght of Buffer.
	#define bytesLenght 30
		// Bytes Buffer.
		unsigned char buffer[bytesLenght];
		// Grab Only First Bytes.
		fread(buffer, 1, bytesLenght, infile);
		// Close File.
		fclose(infile);
		//////  //////      //////  //////  ////// 
		// PNG Signature.
		unsigned char png_signature[8] = {137, 80, 78, 71, 13, 10, 26, 10};
		// Compare File signature.
		if ((int)(memcmp(&buffer[0], &png_signature[0], 8)))
		{
			NSLog(@"ERROR: getPngSizeFromMetaData: The file (%@) don't is one PNG file.", fullFileName);  
		}
		else
		{
			//////  //////      //////  //////  ////// //////   //////  //////  //////  //////
			// Calc Sizes. Isolate only four bytes of each size (width, height).
			int width[4];
			int height[4];
			for ( int d = 16; d < ( 16 + 4 ); d++ )
			{
				width[ d-16] = buffer[ d ];
				height[d-16] = buffer[ d + 4];
			}
			// Convert bytes to Long (Integer)
			resultWidth = (width[0] << (int)24) | (width[1] << (int)16) | (width[2] << (int)8) | width[3]; 
			resultHeight = (height[0] << (int)24) | (height[1] << (int)16) | (height[2] << (int)8) | height[3];
		}
	}
	if(resultWidth == 0 || resultHeight == 0) {
		// Try to get from UIImage
		NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
		UIImage *image = [UIImage imageWithContentsOfFile:fullFileName];
		if(image) {
			UIImageOrientation orient = image.imageOrientation;
			//if(imageOrientation)
			//	*imageOrientation = orient;
			if(orient == UIImageOrientationLeft || orient == UIImageOrientationRight
			   || orient == UIImageOrientationLeftMirrored || orient == UIImageOrientationRightMirrored) {
				resultWidth = image.size.height;
				resultHeight = image.size.width;
			} else {
				resultWidth = image.size.width;
				resultHeight = image.size.height;
			}
		}
		[arpool drain];
	}
    // Return Size.
    return CGSizeMake( resultWidth, resultHeight );
}

+ (CGSize)getJpegSizeFromMetaData:(NSString*)fullFileName imageOrientation:(UIImageOrientation*)imageOrientation
{
	if(imageOrientation)
		*imageOrientation = 1;
	const char* fileName = [fullFileName UTF8String];
    /* source file */ 
    FILE * infile;
    // Check if can open the file.
	infile = fopen(fileName, "rb");
    if(infile == NULL) 
    {
        NSLog(@"ERROR: getJpegSizeFromMetaData: can't open the file: %@", fullFileName);
        return CGSizeZero;
    }
#define maxBufLenght 1000
	fseek(infile, 0, SEEK_END);
	int maxBytesRead = (int)MIN(maxBufLenght, ftell(infile));
	rewind(infile);
	
    unsigned char buffer[maxBufLenght];
	fread(buffer, 1, maxBytesRead, infile);
    fclose(infile);
	
	if(buffer[0] != 0xff || buffer[1] != 0xd8)
	{
		NSLog(@"ERROR: getJpegSizeFromMetaData: not a valid jpg: %@", fullFileName);
        return CGSizeZero;
	}
	int pos = 2;
	while(pos < (maxBufLenght - 12))
	{
		unsigned char p1 = buffer[pos++];
		unsigned char p2 = buffer[pos++];
		if(p1 == 0x01 && p2 == 0x12) // Exif orientation tag
		{
			int orient = buffer[pos+7];
			if(orient >= 1 && orient <= 8)
			{
				if(imageOrientation)
					*imageOrientation = [[self class] imageOrientationFromPropertyOrientation:orient];
			}
		}
		if(p1 == 0xff && 0xc0 <= p2 && p2 <= 0xc3)
		{
			pos += 3;
			short height = ((short)buffer[pos+1]) | (((short)buffer[pos+0]) << 8);
			short width = ((short)buffer[pos+3]) | (((short)buffer[pos+2]) << 8);
			return CGSizeMake(width, height);
		}
	}
	NSLog(@"ERROR: getJpegSizeFromMetaData: could not get size: %@", fullFileName);
	// Try to get from UIImage
	CGSize result = CGSizeZero;
	NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
	UIImage *image = [UIImage imageWithContentsOfFile:fullFileName];
	if(image) {
		UIImageOrientation orient = image.imageOrientation;
		if(imageOrientation)
			*imageOrientation = orient;
		if(orient == UIImageOrientationLeft || orient == UIImageOrientationRight
		   || orient == UIImageOrientationLeftMirrored || orient == UIImageOrientationRightMirrored) {
			result.width = image.size.height;
			result.height = image.size.width;
		} else {
			result.width = image.size.width;
			result.height = image.size.height;
		}
	}
	[arpool drain];
	return result;
}

+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath imageOrientation:(UIImageOrientation*)imageOrientation fileExt:(NSString *)fileExt {
	
	static NSMutableDictionary *_cache;
	if(!_cache)
		_cache = [[NSMutableDictionary alloc] init];
	static int64_t _lastUptime = 0;
	int64_t curUptime = (int64_t)[VLTimer systemUptime];
	if(curUptime >= (_lastUptime + 5))
		[_cache removeAllObjects];
	_lastUptime = curUptime;
	NSString *key = [NSString stringWithFormat:@"filePath=%@, fileExt=%@", filePath, fileExt];
	YTImageSizeCacheInfo *info = [_cache objectForKey:key];
	if(info) {
		if(imageOrientation)
			*imageOrientation = info.orient;
		return info.size;
	}
	
	NSString *extension = fileExt;
	CGSize result = CGSizeZero;
	if( [extension compare:@"jpg" options:NSCaseInsensitiveSearch] == 0
	   || [extension compare:@"jpeg" options:NSCaseInsensitiveSearch] == 0)
		result = [[self class] getJpegSizeFromMetaData:filePath imageOrientation:imageOrientation];
	else if([extension compare:@"png" options:NSCaseInsensitiveSearch] == 0)
		result = [[self class] getPngSizeFromMetaData:filePath];
	else
	{
		NSLog(@"ERROR: getImageSizeWithFilePath: undefined extension: %@", filePath);
        return CGSizeZero;
	}
	
	info = [[[YTImageSizeCacheInfo alloc] init] autorelease];
	info.size = result;
	if(imageOrientation)
		info.orient = *imageOrientation;
	[_cache setObject:info forKey:key];
	
	return result;
}

+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath imageOrientation:(UIImageOrientation*)imageOrientation
{
	return [self getImageSizeWithFilePath:filePath imageOrientation:imageOrientation fileExt:[filePath pathExtension]];
}

+ (CGSize)getImageSizeWithFilePath:(NSString*)filePath
{
	return [[self class] getImageSizeWithFilePath:filePath imageOrientation:nil];
}

@end
