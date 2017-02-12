
#import "YTResourceTypeInfo.h"

@implementation YTResourceTypeInfo

@synthesize categoryType = _categoryType;
@synthesize filesExts = _filesExts;
@synthesize downloadable = _downloadable;
@synthesize storable = _storable;
@synthesize viewable = _viewable;

- (id)initWithCategoryType:(EYTResourceCategoryType)categoryType
				 filesExts:(NSArray *)filesExts
			  downloadable:(BOOL)downloadable
				  storable:(BOOL)storable
				  viewable:(BOOL)viewable {
	self = [super init];
	if(self) {
		_categoryType = categoryType;
		_filesExts = [[NSMutableArray alloc] initWithArray:filesExts];
		_downloadable = downloadable;
		_storable = storable;
		_viewable = viewable;
	}
	return self;
}

+ (NSArray *)allTypes {
	static NSMutableArray *_result;
	if(!_result) {
		_result = [[NSMutableArray alloc] init];
		[_result addObject:[[[YTResourceTypeInfo alloc]
							initWithCategoryType:EYTResourceCategoryTypeImage
							 filesExts:[NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"bmp", nil]
							 downloadable:YES
							 storable:YES
							 viewable:YES]
							autorelease]];
		[_result addObject:[[[YTResourceTypeInfo alloc]
							 initWithCategoryType:EYTResourceCategoryTypeAudio
							 filesExts:[NSArray arrayWithObjects: @"mp3", @"wav", @"m4a", @"caf", nil]
							 downloadable:YES
							 storable:YES
							 viewable:YES]
							autorelease]];
		[_result addObject:[[[YTResourceTypeInfo alloc]
							 initWithCategoryType:EYTResourceCategoryTypeVideo
							 filesExts:[NSArray arrayWithObjects: @"avi", @"mpeg", @"wmv", @"mp4", @"m4v", @"f4v",
										@"mov", @"flv", @"3gp", nil]
							 downloadable:YES
							 storable:NO
							 viewable:YES]
							autorelease]];
		[_result addObject:[[[YTResourceTypeInfo alloc]
							 initWithCategoryType:EYTResourceCategoryTypeRichText
							 filesExts:[NSArray arrayWithObjects: @"doc", @"docx", @"rtf", @"pdf", nil]
							 downloadable:NO
							 storable:NO
							 viewable:YES]
							autorelease]];
		[_result addObject:[[[YTResourceTypeInfo alloc]
							 initWithCategoryType:EYTResourceCategoryTypeSpreadSheet
							 filesExts:[NSArray arrayWithObjects: @"xls", @"xlsx", nil]
							 downloadable:NO
							 storable:NO
							 viewable:YES]
							autorelease]];
		[_result addObject:[[[YTResourceTypeInfo alloc]
							 initWithCategoryType:EYTResourceCategoryTypeSlideShow
							 filesExts:[NSArray arrayWithObjects: @"ppt", @"pptx", nil]
							 downloadable:NO
							 storable:NO
							 viewable:YES]
							autorelease]];
		[_result addObject:[[[YTResourceTypeInfo alloc]
							 initWithCategoryType:EYTResourceCategoryTypeTextDoc
							 filesExts:[NSArray arrayWithObjects: @"txt", nil]
							 downloadable:NO
							 storable:NO
							 viewable:YES]
							autorelease]];
		[_result addObject:[[[YTResourceTypeInfo alloc]
							 initWithCategoryType:EYTResourceCategoryTypeOther
							 filesExts:[NSArray arrayWithObjects: nil]
							 downloadable:NO
							 storable:NO
							 viewable:NO]
							autorelease]];
	}
	return _result;
}

+ (BOOL)isWebDocViewable:(NSString *)sFileExt {
	sFileExt = [sFileExt lowercaseString];
	static NSMutableSet *_arrDocViewableExt;
	if(!_arrDocViewableExt) {
		_arrDocViewableExt = [[NSMutableSet setWithObjects:@"txt", @"pdf", @"rtf", @"doc", @"docx", @"ppt", @"pptx", @"xls", @"xlsx", nil] retain];
	}
	if([_arrDocViewableExt containsObject:sFileExt])
		return YES;
	return NO;
}

+ (BOOL)isOtherType:(NSString *)sFileExt {
	sFileExt = [sFileExt lowercaseString];
	static NSMutableSet *_arrOtherExt;
	if(!_arrOtherExt) {
		_arrOtherExt = [[NSMutableSet setWithObjects:@"zip", @"gzip", @"tar", @"rar", @"iso", @"gz", @"lz", @"7z", @"ace",
						 @"arc", @"arj", @"cab", @"dmg", @"*", nil] retain];
	}
	if([_arrOtherExt containsObject:sFileExt])
		return YES;
	return NO;
}

+ (YTResourceTypeInfo *)infoByCategoryType:(EYTResourceCategoryType)categoryType {
	for(YTResourceTypeInfo *info in [YTResourceTypeInfo allTypes])
		if(info.categoryType == categoryType)
			return info;
	return nil;
}

+ (YTResourceTypeInfo *)infoByFileExt:(NSString *)fileExt {
	for(YTResourceTypeInfo *info in [YTResourceTypeInfo allTypes])
		for(NSString *str in info.filesExts)
			if([str compare:fileExt options:NSCaseInsensitiveSearch] == 0)
				return info;
	return [YTResourceTypeInfo infoByCategoryType:EYTResourceCategoryTypeOther];
}

- (BOOL)containsFileExt:(NSString *)fileExt {
	for(NSString *str in _filesExts)
		if([str compare:fileExt options:NSCaseInsensitiveSearch] == 0)
			return YES;
	return NO;
}

- (BOOL)isImage {
	return _categoryType == EYTResourceCategoryTypeImage;
}

- (void)dealloc {
	[_filesExts release];
	[super dealloc];
}

@end

