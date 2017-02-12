
#import "YTPhotoPreviewMaker.h"
#import "YTCommon.h"

#define kInfoFileName @"info.txt"
#define kMiniPreviewFileName @"mini_preview.jpg"
#define kThumbFileName @"thumbnail.jpg"
#define kPreviewFileName @"preview.jpg"
#define kMiniPreviewKey @"mini_preview"
#define kThumbKey @"thumbnail"
#define kPreviewKey @"preview"
#define kWidthKey @"width"
#define kHeightKey @"height"

static YTPhotoPreviewMaker *_shared;

@implementation YTPhotoPreviewMaker

+ (YTPhotoPreviewMaker *)shared {
	if(!_shared)
		_shared = [[YTPhotoPreviewMaker alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		_dirPath = [[_dirPath stringByAppendingPathComponent:@"YTPhotoPreviewMaker"] retain];
		[[VLFileManager shared] forceDir:_dirPath error:nil];
		
		[self checkAndFixData];
		
		[[VLAppDelegateBase sharedAppDelegateBase].msgrApplicationDidBecomeActive addObserver:self selector:@selector(onAppActivated:)];
	}
	return self;
}

- (void)checkAndFixData {
	VLFileManager *manrFiles = [VLFileManager shared];
	NSArray *dirs = [manrFiles subDirsInDirectory:_dirPath error:nil];
	for(NSString *partsDirPath in dirs) {
		NSString *infoPath = [partsDirPath stringByAppendingPathComponent:kInfoFileName];
		if(![manrFiles fileExists:infoPath]) {
			[manrFiles deleteFileOrDir:partsDirPath error:nil];
		}
	}
}

- (NSArray *)getAllImagesHashes {
	NSMutableArray *result = [NSMutableArray array];
	VLFileManager *manrFiles = [VLFileManager shared];
	NSArray *dirs = [manrFiles subDirsInDirectory:_dirPath error:nil];
	for(NSString *partsDirPath in dirs) {
		NSString *sHash = [partsDirPath lastPathComponent];
		[result addObject:sHash];
	}
	return result;
}

- (void)startMakeWithImageHash:(NSString *)imageHash imageFilePath:(NSString *)imageFilePath skip:(BOOL)skip resultBlock:(VLBlockVoid)resultBlock {

	if(skip) {
		resultBlock();
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
		
		NSTimeInterval tm1 = [[NSProcessInfo processInfo] systemUptime];
		
		NSString *partsDirPath = [_dirPath stringByAppendingPathComponent:imageHash];
		[[VLFileManager shared] forceDir:partsDirPath error:nil];
		
		NSString *infoPath = [partsDirPath stringByAppendingPathComponent:kInfoFileName];
		if([[VLFileManager shared] fileExists:infoPath])
			[[VLFileManager shared] deleteFileOrDir:infoPath error:nil];
		
		NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
		
		UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
		CGSize imageSize = image.size;
		//float imageRatio = imageSize.width / imageSize.height;
		
		UIImage *imageMiniPreview = [image limitSizeAndRotate:kYTPhotoMiniPreviewMaxSide];
		NSString *miniPreviewPath = [partsDirPath stringByAppendingPathComponent:kMiniPreviewFileName];
		NSData *imageMiniPreviewData = UIImageJPEGRepresentation(imageMiniPreview, kYTDefaultJpegImageQuality);
		[imageMiniPreviewData writeToFile:miniPreviewPath atomically:NO];
		NSDictionary *dictMini = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:imageMiniPreview.size.width], kWidthKey,
								  [NSNumber numberWithInt:imageMiniPreview.size.height], kHeightKey,
								  nil];
		[dictInfo setObject:dictMini forKey:kMiniPreviewKey];
		
		CGSize thumbSize = kYTPhotoThumbnailSize;
		UIImage *imageThumb = [self makeThumbnailWithImage:image thumbSize:thumbSize contentMode:UIViewContentModeScaleAspectFill];
		NSString *thumbPath = [partsDirPath stringByAppendingPathComponent:kThumbFileName];
		NSData *imageThumbData = UIImageJPEGRepresentation(imageThumb, kYTDefaultJpegImageQuality);
		[imageThumbData writeToFile:thumbPath atomically:NO];
		NSDictionary *dictThumb = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithInt:imageThumb.size.width], kWidthKey,
								   [NSNumber numberWithInt:imageThumb.size.height], kHeightKey,
								   nil];
		[dictInfo setObject:dictThumb forKey:kThumbKey];
		
		//UIImage *imagePreview = [image limitSizeAndRotate:kYTPhotoPreviewMaxSide];
		float previewMaxSide = kYTPhotoPreviewMaxWidth;
		if(imageSize.width < imageSize.height)
			previewMaxSide = kYTPhotoPreviewMaxWidth * imageSize.height / imageSize.width;
		previewMaxSide = round(previewMaxSide);
		if(previewMaxSide < 1)
			previewMaxSide = 1;
		UIImage *imagePreview = [image limitSizeAndRotate:previewMaxSide];
		NSString *imagePreviewPath = [partsDirPath stringByAppendingPathComponent:kPreviewFileName];
		NSData *imagePreviewData = UIImageJPEGRepresentation(imagePreview, kYTDefaultJpegImageQuality);
		[imagePreviewData writeToFile:imagePreviewPath atomically:NO];
		NSDictionary *dictPreview = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithInt:imagePreview.size.width], kWidthKey,
									 [NSNumber numberWithInt:imagePreview.size.height], kHeightKey,
									 nil];
		[dictInfo setObject:dictPreview forKey:kPreviewKey];
		
		NSString *sDictInfo = [dictInfo JSONRepresentation];
		[sDictInfo writeToFile:infoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		NSTimeInterval tm2 = [[NSProcessInfo processInfo] systemUptime];
		VLLogEvent(([NSString stringWithFormat:@"%0.4f s", tm2 - tm1]));
		
		[arpool drain];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			resultBlock();
		});
	});
}

- (NSDictionary *)getDictInfo:(NSString *)imageHash {
	NSString *partsDirPath = [_dirPath stringByAppendingPathComponent:imageHash];
	NSString *infoPath = [partsDirPath stringByAppendingPathComponent:kInfoFileName];
	NSString *sDictInfo = [NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *dictInfo = [sDictInfo JSONValue];
	return dictInfo;
}

- (NSString *)getMiniPreviewFilePath:(NSString *)imageHash imageSize:(CGSize *)pImageSize {
	NSDictionary *dictInfo = [self getDictInfo:imageHash];
	NSDictionary *dictImage = [dictInfo dictionaryValueForKey:kMiniPreviewKey defaultIsEmpty:NO];
	if(pImageSize)
		*pImageSize = CGSizeMake([dictImage intValueForKey:kWidthKey defaultVal:64], [dictImage intValueForKey:kHeightKey defaultVal:64]);
	NSString *path = [[_dirPath stringByAppendingPathComponent:imageHash] stringByAppendingPathComponent:kMiniPreviewFileName];
	return path;
}

- (NSString *)getThumbnailFilePath:(NSString *)imageHash imageSize:(CGSize *)pImageSize {
	NSDictionary *dictInfo = [self getDictInfo:imageHash];
	NSDictionary *dictImage = [dictInfo dictionaryValueForKey:kThumbKey defaultIsEmpty:NO];
	if(pImageSize)
		*pImageSize = CGSizeMake([dictImage intValueForKey:kWidthKey defaultVal:64], [dictImage intValueForKey:kHeightKey defaultVal:64]);
	NSString *path = [[_dirPath stringByAppendingPathComponent:imageHash] stringByAppendingPathComponent:kThumbFileName];
	return path;
}

- (NSString *)getPreviewFilePath:(NSString *)imageHash imageSize:(CGSize *)pImageSize {
	NSDictionary *dictInfo = [self getDictInfo:imageHash];
	NSDictionary *dictImage = [dictInfo dictionaryValueForKey:kPreviewKey defaultIsEmpty:NO];
	if(pImageSize)
		*pImageSize = CGSizeMake([dictImage intValueForKey:kWidthKey defaultVal:64], [dictImage intValueForKey:kHeightKey defaultVal:64]);
	NSString *path = [[_dirPath stringByAppendingPathComponent:imageHash] stringByAppendingPathComponent:kPreviewFileName];
	return path;
}

- (UIImage *)makeThumbnailWithImage:(UIImage *)image
						  thumbSize:(CGSize)thumbSize
						contentMode:(UIViewContentMode)contentMode
{
	NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
	CGSize imageSize = image.size;
	float imageScale = MAX(imageSize.width, 1) / MAX(imageSize.height, 1);
	float thumbScale = MAX(thumbSize.width, 1) / MAX(thumbSize.height, 1);
	float maxThumbSide = MAX(thumbSize.width, thumbSize.height);
	if(contentMode == UIViewContentModeScaleAspectFit)
	{
		if(thumbScale >= imageScale)
			maxThumbSide = thumbSize.width;
		else
			maxThumbSide = thumbSize.height;
	}
	else if(contentMode == UIViewContentModeScaleAspectFill)
	{
		if(thumbScale >= imageScale)
			maxThumbSide = MAX(thumbSize.width, (thumbSize.width / imageScale));
		else
			maxThumbSide = MAX(thumbSize.height, (thumbSize.height * imageScale));
	}
	
	// If image is smaller than thumbnail
	float imageMaxSide = MAX(imageSize.width, imageSize.height);
	if(maxThumbSide > imageMaxSide)
	{
		float ratio = imageMaxSide / maxThumbSide;
		maxThumbSide *= ratio;
		thumbSize.width *= ratio;
		thumbSize.height *= ratio;
	}
	
	maxThumbSide = round(maxThumbSide);
	if(maxThumbSide < 1)
		maxThumbSide = 1;
	thumbSize.width = round(thumbSize.width);
	if(thumbSize.width < 1)
		thumbSize.width = 1;
	thumbSize.height = round(thumbSize.height);
	if(thumbSize.height < 1)
		thumbSize.height = 1;
	
	UIImage *thumbnail = [image limitSizeAndRotate:maxThumbSide];
	CGSize thumbnailSize = thumbnail.size;
	if(contentMode == UIViewContentModeScaleAspectFill && imageScale != thumbScale)
	{
		CGRect rectCrop = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
		rectCrop.origin.x = thumbnailSize.width/2 - rectCrop.size.width/2;
		rectCrop.origin.y = thumbnailSize.height/2 - rectCrop.size.height/2;
		
		rectCrop.origin.x = round(rectCrop.origin.x);
		rectCrop.origin.y = round(rectCrop.origin.y);
		rectCrop.size.width = round(rectCrop.size.width);
		if(rectCrop.size.width < 1)
			rectCrop.size.width = 1;
		rectCrop.size.height = round(rectCrop.size.height);
		if(rectCrop.size.height < 1)
			rectCrop.size.height = 1;
		
		CGImageRef imageRef = CGImageCreateWithImageInRect(thumbnail.CGImage, rectCrop);
		thumbnail = [UIImage imageWithCGImage:imageRef];
		//thumbnailSize = thumbnail.size;
		CGImageRelease(imageRef);
	}
	if(thumbnail)
		[thumbnail retain];
	[arpool drain];
	if(thumbnail)
		[thumbnail autorelease];
	return thumbnail;
}

- (void)deleteImageWithHash:(NSString *)sHash {
	NSString *partsDirPath = [_dirPath stringByAppendingPathComponent:sHash];
	[[VLFileManager shared] deleteFileOrDir:partsDirPath error:nil];
}

- (void)onAppActivated:(id)sender {
	[self checkAndFixData];
}

- (void)dealloc {
	[_dirPath release];
	[super dealloc];
}

@end





