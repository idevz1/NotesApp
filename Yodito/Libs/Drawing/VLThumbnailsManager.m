
#import "VLThumbnailsManager.h"
#import "../Storage/Classes.h"
#import "VLUIObjects+Categories.h"

#define kThumbnailsCacheSize 1//36
#define kMaxImageSizeToCache (100*000) // Pixels

@implementation VLThumbnailCreateInfo

@synthesize thumbnailHash = _thumbnailHash;
@synthesize imageFilePath = _imageFilePath;
@synthesize imageHash = _imageHash;
@synthesize thumbWidth = _thumbWidth;
@synthesize thumbHeight = _thumbHeight;
@synthesize thumbContentMode = _thumbContentMode;
@synthesize image = _image;
@synthesize thumbnail = _thumbnail;
@synthesize thumbnailFilePath = _thumbnailFilePath;
@synthesize saveThumbnailToFile = _saveThumbnailToFile;
@synthesize error = _error;

- (id)init
{
	self = [super init];
	if(self) {
	}
	return self;
}

- (void)dealloc {
	[_thumbnail release];
	[_imageFilePath release];
	[_imageHash release];
	[_thumbnailHash release];
	[_thumbnailFilePath release];
	[_image release];
	[_error release];
	[super dealloc];
}

@end


@implementation VLThumbnailsManager

@synthesize ntfrThumbnailReady = _ntfrThumbnailReady;

- (id)initWithCachedImageStore:(VLCachedImageStore *)cachedImageStore
{
	self = [super init];
	if(self)
	{
		_cachedImageStore = [cachedImageStore retain];
		_queueToProcess = [[NSMutableArray alloc] init];
		_queueProcessedReady = [[NSMutableArray alloc] init];
		_queueWaitingForLoad = [[NSMutableArray alloc] init];
		
		_ntfrThumbnailReady = [[VLDelegate alloc] init];
		_ntfrThumbnailReady.owner = self;
		
		_cacheThumbnails = [[VLCachedDictionary alloc] init];
		_cacheThumbnails.maxSize = kThumbnailsCacheSize;
		
		_timer = [[VLTimer alloc] init];
		_timer.interval = 0.1;
		[_timer setObserver:self selector:@selector(onTimerEvent:)];
		_timer.enabledAlwaysFiring = YES;
		[_timer start];
		
		[_cachedImageStore.ntfrImageLoaded addObserver:self selector:@selector(onImageLoaded:args:)];
	}
	return self;
}

+ (NSString *)thumbnailHashWithImageHash:(NSString *)imageHash
							width:(float)width
						   height:(float)height
					  contentMode:(EVLThumbnailContentMode)contentMode
{
	NSMutableString *str = [NSMutableString stringWithCapacity:64];
	[str appendFormat:@"%@_%f_%f_%d", imageHash, width, height, (int)contentMode];
	NSString *result = [str md5];
	return result;
}

- (UIImage *)makeThumbnailWithImage:(UIImage *)image
						 thumbSize:(CGSize)thumbSize
					   contentMode:(EVLThumbnailContentMode)contentMode
{
	NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
	CGSize imageSize = image.size;
	float imageScale = MAX(imageSize.width, 1) / MAX(imageSize.height, 1);
	float thumbScale = MAX(thumbSize.width, 1) / MAX(thumbSize.height, 1);
	float maxThumbSide = MAX(thumbSize.width, thumbSize.height);
	if(contentMode == EVLThumbnailContentModeAspectFit)
	{
		if(thumbScale >= imageScale)
			maxThumbSide = thumbSize.width;
		else
			maxThumbSide = thumbSize.height;
	}
	else if(contentMode == EVLThumbnailContentModeAspectFill)
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
	
	UIImage *thumbnail = [image limitSizeAndRotate:maxThumbSide];
	CGSize thumbnailSize = thumbnail.size;
	if(contentMode == EVLThumbnailContentModeAspectFill && imageScale != thumbScale)
	{
		CGRect rectCrop = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
		rectCrop.origin.x = thumbnailSize.width/2 - rectCrop.size.width/2;
		rectCrop.origin.y = thumbnailSize.height/2 - rectCrop.size.height/2;
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

- (void)threadFuncCreateThumbs:(id)param
{
	while(YES)
	{
		VLThumbnailCreateInfo *info = nil;
		NSAutoreleasePool *arpool = nil;
		@synchronized(_queueToProcess)
		{
			if([_queueToProcess count])
			{
				info = [_queueToProcess objectAtIndex:0];
				[info retain];
				//[_queueToProcess removeObjectAtIndex:0];
			}
		}
		if(info)
		{
			arpool = [[NSAutoreleasePool alloc] init];
			UIImage *image = info.image;
			if(!image)
			{
				image = [UIImage imageWithContentsOfFile:info.imageFilePath];
				if(!image)
					info.error = [NSError makeWithText:[NSString stringWithFormat:@"ERROR: VLThumbnailsManager: imageWithContentsOfFile %@ returned nil", info.imageFilePath]];
			}
			if(image)
			{
				info.thumbnail = [self makeThumbnailWithImage:image
													thumbSize:CGSizeMake(info.thumbWidth, info.thumbHeight)
												  contentMode:info.thumbContentMode];
			}
			info.image = nil;
			if(info.thumbnail && info.saveThumbnailToFile) {
				VLCachedImageStore_ImageInfo *thumbInfo = [_cachedImageStore startSaveImage:info.thumbnail
							  orImageFromFilePath:nil
										 withHash:info.thumbnailHash
									  synchronous:YES];
				info.thumbnailFilePath = thumbInfo.filePathInner;
				info.thumbnail = nil;
			}
			@synchronized(_queueToProcess)
			{
				@synchronized(_queueProcessedReady)
				{
					[_queueProcessedReady addObject:info];
					[_queueToProcess removeObject:info];
				}
			}
		}
		if(arpool)
			[arpool drain];
		if(info)
		{
			[info release];
			continue;
		}
		[NSThread sleepForTimeInterval:0.1];
	}
}

- (void)onTimerEvent:(id)sender
{
	while(YES)
	{
		VLThumbnailCreateInfo *info = nil;
		@synchronized(_queueProcessedReady)
		{
			if([_queueProcessedReady count])
			{
				info = [_queueProcessedReady objectAtIndex:0];
				[info retain];
				[_queueProcessedReady removeObjectAtIndex:0];
			}
		}
		if(info)
		{
			if(info.thumbnail)
			{
				if(info.thumbnail.size.width * info.thumbnail.size.height <= kMaxImageSizeToCache)
					[_cacheThumbnails setObject:info.thumbnail forKey:info.thumbnailHash];
				[_cachedImageStore startSaveImage:[NSString isEmpty:info.imageFilePath] ? info.thumbnail : nil
							  orImageFromFilePath:![NSString isEmpty:info.imageFilePath] ? info.imageFilePath : nil
										 withHash:info.thumbnailHash];
			}
			[_ntfrThumbnailReady sendMessage:self withArgs:info];
			[info release];
			continue;
		}
		break;
	}
}

- (void)onImageLoaded:(id)sender args:(VLCachedImageStore_ImageInfo*)args
{
	for(int i = 0; i < _queueWaitingForLoad.count; i++)
	{
		VLThumbnailCreateInfo *info = [_queueWaitingForLoad objectAtIndex:i];
		if([info.thumbnailHash isEqual:args.sHash])
		{
			[info retain];
			[_queueWaitingForLoad removeObjectAtIndex:i--];
			info.thumbnail = args.image;
			info.thumbnailFilePath = args.filePathInner;
			if(info.thumbnail && (info.thumbnail.size.width*info.thumbnail.size.height <= kMaxImageSizeToCache))
				[_cacheThumbnails setObject:info.thumbnail forKey:info.thumbnailHash];
			[_ntfrThumbnailReady sendMessage:self withArgs:info];
			[info release];
		}
	}
}

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
			 waitForLoadFromDisk:(BOOL)waitForLoadFromDisk
{
	*startedLoadAsync = NO;
	
	NSString *thumbHash = [[self class] thumbnailHashWithImageHash:imageHash
													 width:width
													height:height
											   contentMode:contentMode];
	if(pThumbnailHash)
		*pThumbnailHash = thumbHash;
	
	VLThumbnailCreateInfo *newInfo = [[[VLThumbnailCreateInfo alloc] init] autorelease];
	newInfo.image = image;
	newInfo.imageFilePath = imageFilePath;
	newInfo.imageHash = imageHash;
	newInfo.thumbnailHash = thumbHash;
	newInfo.thumbWidth = width;
	newInfo.thumbHeight = height;
	newInfo.thumbContentMode = contentMode;
	newInfo.saveThumbnailToFile = saveThumbnailToFile;
	
	UIImage *thumbnail = [_cacheThumbnails objectForKey:thumbHash];
	if(thumbnail) {
		newInfo.thumbnail = thumbnail;
		return newInfo;
	}
	
	@synchronized(_queueToProcess)
	{
		@synchronized(_queueProcessedReady)
		{
			for(VLThumbnailCreateInfo *info in _queueProcessedReady)
				if([info.thumbnailHash isEqual:imageHash])
					return info;
			for(VLThumbnailCreateInfo *info in _queueToProcess)
			{
				if([info.thumbnailHash isEqual:imageHash])
				{
					*startedLoadAsync = YES;
					return nil;
				}
			}
		}
	}
	
	VLCachedImageStore *store = _cachedImageStore;
	if([store containsImageWithHash:newInfo.thumbnailHash])
	{
		if(!allowReturnImage) {
			newInfo.thumbnailFilePath = [store getFilePathForImageWithHash:newInfo.thumbnailHash];
			return newInfo;
		}
		BOOL notExisted = NO;
		BOOL startedLoadAsyncInt = NO;
		//BOOL doNotLoadData = ![NSString isEmpty:newInfo.imageFilePath];
		VLCachedImageStore_ImageInfo *imageArgs = [store loadImageByHash:thumbHash
														   doNotLoadData:NO//doNotLoadData
															  notExisted:&notExisted
														startedLoadAsync:&startedLoadAsyncInt];
		UIImage *thumb = imageArgs ? imageArgs.image : nil;
		//if(!thumb && imageArgs && doNotLoadData) {
		//	thumb = [UIImage imageWithContentsOfFile:imageArgs.filePathInner];
		//}
		if(thumb) {
			newInfo.thumbnail = thumb;
			newInfo.thumbnailFilePath = imageArgs.filePathInner;
			return newInfo;
		}
		if(startedLoadAsyncInt)
		{
			*startedLoadAsync = YES;
			newInfo.image = nil;
			[_queueWaitingForLoad addObject:newInfo];
			return nil;
		}
	}
	@synchronized(_queueToProcess)
	{
		[_queueToProcess addObject:newInfo];
	}
	if(!_threadCreateThumbs)
	{
		_threadCreateThumbs = [[NSThread alloc] initWithTarget:self selector:@selector(threadFuncCreateThumbs:) object:self];
		[_threadCreateThumbs start];
	}
	*startedLoadAsync = YES;
	return nil;
}

- (void)dealloc
{
	[_cachedImageStore.ntfrImageLoaded removeObserver:self];
	[_queueToProcess release];
	[_queueProcessedReady release];
	[_queueWaitingForLoad release];
	[_timer release];
	[_threadCreateThumbs release];
	[_ntfrThumbnailReady release];
	[_cacheThumbnails release];
	[_cachedImageStore release];
	[super dealloc];
}

@end

