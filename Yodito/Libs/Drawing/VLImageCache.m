
#import "VLImageCache.h"
#import "../Ctrls/Classes.h"

@implementation VLImageCache_ImageInfo

@synthesize image = _image;
@synthesize sHash = _sHash;
@synthesize lastAccessTime = _lastAccessTime;

- (void)dealloc {
	[_image release];
	[_sHash release];
	[_lastAccessTime release];
	[super dealloc];
}

@end


static VLImageCache *_shared;

@implementation VLImageCache

@synthesize maxAllPixelsAmount = _maxAllPixelsAmount;

+ (VLImageCache *)shared {
	if(!_shared)
		_shared = [[VLImageCache alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_mapInfoByHash = [[NSMutableDictionary alloc] init];
		_maxAllPixelsAmount = 1 * 1024 * 1024;
		[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning addObserver:self selector:@selector(onMemoryWarning:)];
	}
	return self;
}

- (void)clear {
	[_mapInfoByHash removeAllObjects];
}

- (void)onMemoryWarning:(id)sender {
	[self clear];
}

- (UIImage *)imageByHash:(NSString *)sHash {
	VLImageCache_ImageInfo *info = [_mapInfoByHash objectForKey:sHash];
	if(info) {
		info.lastAccessTime = [NSDate date];
		return info.image;
	}
	return nil;
}

- (void)setImage:(UIImage *)image withHash:(NSString *)sHash {
	if(image == nil) {
		VLLogWarning(@"image == nil");
		return;
	}
	if([NSString isEmpty:sHash]) {
		VLLogWarning(@"[NSString isEmpty:sHash]");
		return;
	}
	[_mapInfoByHash removeObjectForKey:sHash];
	VLImageCache_ImageInfo *info = [[[VLImageCache_ImageInfo alloc] init] autorelease];
	info.image = image;
	info.sHash = sHash;
	info.lastAccessTime = [NSDate date];
	[_mapInfoByHash setObject:info forKey:sHash];
	[self clearOutdatedData];
}

- (void)clearOutdatedData {
	NSMutableArray *allInfos = [NSMutableArray arrayWithArray:_mapInfoByHash.allValues];
	[allInfos sortUsingComparator:^NSComparisonResult(VLImageCache_ImageInfo *obj1, VLImageCache_ImageInfo *obj2) {
		double val = [obj1.lastAccessTime timeIntervalSinceReferenceDate] - [obj2.lastAccessTime timeIntervalSinceReferenceDate];
		if(val < 0)
			return 1;
		else if(val > 0)
			return -1;
		return 0;
	}];
	int64_t curAllPixelsAmount = 0;
	for(int i = 0; i < allInfos.count; i++) {
		VLImageCache_ImageInfo *info = [allInfos objectAtIndex:i];
		curAllPixelsAmount += info.image.size.width * info.image.size.height;
		if(curAllPixelsAmount > _maxAllPixelsAmount) {
			for(int k = (int)allInfos.count - 1; k >= i; k--) {
				info = [allInfos objectAtIndex:k];
				[_mapInfoByHash removeObjectForKey:info.sHash];
			}
			break;
		}
	}
}

- (void)dealloc {
	[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning removeObserver:self];
	[_mapInfoByHash release];
	[super dealloc];
}

@end

