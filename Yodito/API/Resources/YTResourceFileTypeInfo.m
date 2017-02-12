
#import "YTResourceFileTypeInfo.h"

@implementation YTResourceFileTypeInfo

@synthesize fileExt = _fileExt;
@synthesize icon = _icon;

- (id)initWithFileExt:(NSString *)fileExt icon:(UIImage *)icon {
	self = [super init];
	if(self) {
		_fileExt = [fileExt copy];
		if(!icon)
			icon = [UIImage imageNamed:@"res_file_attachment.png"];
		_icon = [icon retain];
	}
	return self;
}

+ (YTResourceFileTypeInfo *)infoByFileExt:(NSString *)fileExt {
	static NSMutableArray *_allInfos;
	if(!_allInfos) {
		_allInfos = [NSMutableArray new];
		
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"jpg" icon:nil] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"jpeg" icon:nil] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"png" icon:nil] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"gif" icon:nil] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"bmp" icon:nil] autorelease]];
		
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"mp3" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"wav" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"m4a" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"caf" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"avi" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"mpeg" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"wmv" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"mp4" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"m4v" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"f4v" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"mov" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"flv" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"3gp" icon:[UIImage imageNamed:@"res_media_image.png"]] autorelease]];
		
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"doc" icon:[UIImage imageNamed:@"res_doc_icon.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"docx" icon:[UIImage imageNamed:@"res_doc_icon.png"]] autorelease]];
		//[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"docx" icon:nil] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"rtf" icon:nil] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"pdf" icon:[UIImage imageNamed:@"res_pdf_icon.png"]] autorelease]];
		
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"xls" icon:[UIImage imageNamed:@"res_xls_icon.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"xlsx" icon:[UIImage imageNamed:@"res_xls_icon.png"]] autorelease]];
		
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"ppt" icon:[UIImage imageNamed:@"res_ppt_icon.png"]] autorelease]];
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"pptx" icon:[UIImage imageNamed:@"res_ppt_icon.png"]] autorelease]];
		
		[_allInfos addObject:[[[YTResourceFileTypeInfo alloc] initWithFileExt:@"txt" icon:nil] autorelease]];
	}
	
	for(YTResourceFileTypeInfo *info in _allInfos) {
		if([info.fileExt isEqual:fileExt])
			return info;
	}
	return nil;
}

+ (UIImage *)imageByFileExt:(NSString *)fileExt {
	YTResourceFileTypeInfo *info = [[self class] infoByFileExt:fileExt];
	if(info && info.icon)
		return info.icon;
	return [UIImage imageNamed:@"res_file_attachment.png"];
}

- (void)dealloc {
	[_fileExt release];
	[super dealloc];
}

@end

