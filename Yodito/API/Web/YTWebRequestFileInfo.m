
#import "YTWebRequestFileInfo.h"

@implementation YTWebRequestFileInfo

@synthesize filePath = _filePath;
@synthesize fileName = _fileName;
@synthesize contentType = _contentType;
@synthesize key = _key;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)dealloc {
	[_filePath release];
	[_fileName release];
	[_contentType release];
	[_key release];
	[super dealloc];
}

@end

