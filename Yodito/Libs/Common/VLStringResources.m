
#import "VLStringResources.h"

@implementation VLStringResources

@synthesize buttonOK;
@synthesize buttonCancel;
@synthesize buttonYes;
@synthesize buttonNo;
@synthesize buttonNext;
@synthesize searchBarPlaceholder;
@synthesize errorCanceled;

+ (VLStringResources*)shared
{
	static VLStringResources *_shared;
	if(!_shared)
		_shared = [[VLStringResources alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		self.buttonOK = @"OK";
		self.buttonCancel = @"Cancel";
		self.buttonYes = @"Yes";
		self.buttonNo = @"No";
		self.buttonNext = @"Next";
		self.searchBarPlaceholder = @"Search";
		self.errorCanceled = @"Canceled";
	}
	return self;
}

@end
