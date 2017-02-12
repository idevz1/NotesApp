
#import "VLImagesManager.h"
#import "../Common/Classes.h"

@interface VLImageNamedInfo : NSObject
{
	UIImage *_image;
	NSString *_name;
}

@property(nonatomic,retain) UIImage *image;
@property(nonatomic,copy) NSString *name;

@end


@implementation VLImageNamedInfo

@synthesize image = _image;
@synthesize name = _name;

- (id)init
{
	self = [super init];
	if(self)
	{
		_name = [NSString new];
	}
	return self;
}

- (void)dealloc
{
	[_image release];
	[_name release];
	[super dealloc];
}

@end


@implementation VLImagesManager

+ (VLImagesManager*)shared
{
	static VLImagesManager *_shared = nil;
	if(!_shared)
		_shared = [[VLImagesManager alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_mapImagesNamed = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (BOOL)fileExists:(NSString*)filePath
{
	if([NSString isEmpty:filePath])
		return NO;
	NSFileManager *manr = [NSFileManager defaultManager];
	BOOL isDir = false;
	BOOL bRes = [manr fileExistsAtPath:filePath isDirectory:&isDir];
	return bRes && !isDir;
}

- (UIImage*)imageNamed:(NSString*)name
{
	if([NSString isEmpty:name])
		return nil;
	VLImageNamedInfo *info = [_mapImagesNamed objectForKey:name];
	if(!info)
	{
		info = [[[VLImageNamedInfo alloc] init] autorelease];
		info.name = name;
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *sFileName = [name stringByDeletingPathExtension];
		NSString *sFileExt = [name pathExtension];
		NSString *sFileName2x = [sFileName stringByAppendingString:@"@2x"];
		NSString *path = [bundle pathForResource:sFileName ofType:sFileExt];
		NSString *path2x = [bundle pathForResource:sFileName2x ofType:sFileExt];
		NSString *pathToLoad = (([UIScreen mainScreen].scale == 2.0) && [self fileExists:path2x]) ? path2x : path;
		UIImage *image = [UIImage imageWithContentsOfFile:pathToLoad];
		info.image = image;
		[_mapImagesNamed setObject:info forKey:name];
	}
	return info.image;
}

- (void)releaseImageNamed:(NSString*)name
{
	if([NSString isEmpty:name])
		return;
	VLImageNamedInfo *info = [_mapImagesNamed objectForKey:name];
	if(info)
		[_mapImagesNamed removeObjectForKey:name];
}

- (void)freeUnusedMemory
{
	[_mapImagesNamed removeAllObjects];
}

- (void)dealloc
{
	[_mapImagesNamed release];
	[super dealloc];
}

@end
