
#import "VLBitmap.h"

@implementation VLBitmap

@dynamic isCreated;
@synthesize width = _width;
@synthesize height = _height;
@dynamic pixelsData;
@synthesize context = _context;

- (id)init
{
	self = [super init];
	if(self)
	{
		_context = nil;
	}
	return self;
}

- (BOOL)isCreated
{
	return (_context != NULL);
}

- (void*)pixelsData
{
	if(!_pixels)
		return nil;
	return [_pixels mutableBytes];
}

- (void)releaseCachedImage
{
	if(_cachedImage)
	{
		[_cachedImage release];
		_cachedImage = nil;
	}
	_cachedImageCreated = NO;
}

- (void)releaseInt
{
	BOOL wasCreated = (_context != NULL);
	if(_context)
	{
		CGContextRelease(_context);
		_context = nil;
	}
	if(_colorSpace)
	{
		CGColorSpaceRelease(_colorSpace);
		_colorSpace = nil;
	}
	if(_pixels)
	{
		[_pixels release];
		_pixels = nil;
	}
	_width = _height = 0;
	if(wasCreated)
	{
		[self performSelector:@selector(onDataChanged)];
	}
}

- (void)onDataChanged
{
	[self releaseCachedImage];
}

- (void)createWithWidth:(int)width height:(int)height
{
	[self releaseInt];
	if(width < 1)
		width = 1;
	if(height < 1)
		height = 1;
	_width = width;
	_height = height;
	
	int bytesPerPixel = 4;
	int bitsPerChannel = 8;
	_pixels = [NSMutableData new];
	[_pixels setLength:_width * _height * bytesPerPixel];
	void* pData = [_pixels mutableBytes];

	_colorSpace = CGColorSpaceCreateDeviceRGB();

	_context = CGBitmapContextCreate(pData, 
			_width,
			_height,
			bitsPerChannel,
			_width * bytesPerPixel,
			_colorSpace,
			kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
}

- (void)createWithImage:(UIImage*)image
{
	[self releaseInt];
	if(!image)
		return;
	CGSize size = image.size;
	[self createWithWidth:size.width height:size.height];
	[self drawImage:image];
	[self onDataChanged];
}

- (void)assignFrom:(VLBitmap*)other
{
	[self releaseData];
	if(!other || !other.isCreated)
		return;
	[self createWithWidth:other.width height:other.height];
	memcpy(self.pixelsData, other.pixelsData, self.width * self.height * 4);
	[self onDataChanged];
}

- (void)getPixel:(VLColor*)color x:(int)x y:(int)y
{
	if(!_pixels)
		return;
	u_int32_t* pPxls = (u_int32_t*)[_pixels mutableBytes];
	u_int32_t val = *(pPxls + (y * _width + x));
	u_int8_t r = (u_int8_t)(val);
	u_int8_t g = (u_int8_t)(val >> 8);
	u_int8_t b = (u_int8_t)(val >> 16);
	u_int8_t a = (u_int8_t)(val >> 24);
	color.alpha = a / 255.0;
	color.red = r / 255.0;
	color.green = g / 255.0;
	color.blue = b / 255.0;
}

- (void)setPixel:(VLColor*)color x:(int)x y:(int)y
{
	if(!_pixels)
		return;
	u_int32_t* pPxls = (u_int32_t*)[_pixels mutableBytes];
	u_int32_t a = (u_int8_t)(color.alpha * 255);
	u_int32_t r = (u_int8_t)(color.red * 255);
	u_int32_t g = (u_int8_t)(color.green * 255);
	u_int32_t b = (u_int8_t)(color.blue * 255);
	u_int32_t val = (r) | (g << 8) | (b << 16) | (a << 24);
	*(pPxls + (y * _width + x)) = val;
	[self onDataChanged];
}

- (void)drawImage:(UIImage*)image
{
	if(!_pixels)
		return;
	CGRect rect = CGRectMake(0, 0, _width, _height);
	CGContextDrawImage(_context,
					   rect,
					   image.CGImage);
	[self onDataChanged];
}

- (void)freeUnusedMemory
{
	[self releaseCachedImage];
}

- (void)releaseData
{
	[self releaseInt];
}

- (UIImage*)getCachedImage
{
	if(!_cachedImage && _context && !_cachedImageCreated)
	{
		_cachedImageCreated = YES;
		
		CGImageRef imgRef = CGBitmapContextCreateImage(_context);
		_cachedImage = [UIImage imageWithCGImage:imgRef];
		CGImageRelease(imgRef);
		if(_cachedImage)
			[_cachedImage retain];
	}
	return _cachedImage;
}

- (void)dealloc
{
	[self releaseInt];
	[super dealloc];
}

@end
