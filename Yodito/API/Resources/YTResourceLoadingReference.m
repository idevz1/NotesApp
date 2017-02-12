
#import "YTResourceLoadingReference.h"
#import "YTResourceLoadingInfo.h"
#import "YTResourcesStorage.h"

@interface YTResourceLoadingReference()

@end

@implementation YTResourceLoadingReference

@synthesize resourceHash = _resourceHash;
@synthesize resourceType = _resourceType;
@synthesize resourceCategoryId = _resourceCategoryId;
@synthesize parentInfoRef = _parentInfoRef;

- (id)init {
	self = [super init];
	if(self) {
		_resourceHash = [@"" retain];
		_resourceType = [@"" retain];
	}
	return self;
}

- (void)setResourceHash:(NSString *)resourceHash andType:(NSString *)resourceType categoryId:(int)resourceCategoryId {
	if(!resourceType)
		resourceType = @"";
	if(![_resourceType isEqual:resourceType]) {
		[_resourceType release];
		_resourceType = [resourceType copy];
		[self modifyVersion];
	}
	if(_resourceCategoryId != resourceCategoryId) {
		_resourceCategoryId = resourceCategoryId;
		[self modifyVersion];
	}
	if(!resourceHash)
		resourceHash = @"";
	if(![_resourceHash isEqual:resourceHash]) {
		if(![NSString isEmpty:_resourceHash])
			[[YTResourcesStorage shared] removeReference:self];
		[_resourceHash release];
		_resourceHash = [resourceHash copy];
		if(![NSString isEmpty:_resourceHash])
			[[YTResourcesStorage shared] addReference:self];
		[self modifyVersion];
	}
}

- (void)setParentInfoRef:(YTResourceLoadingInfo *)parentInfoRef {
	if(_parentInfoRef != parentInfoRef) {
		if(_parentInfoRef) {
			
		}
		_parentInfoRef = parentInfoRef;
		if(_parentInfoRef) {
			
		}
	}
}

- (void)dealloc {
	[self setResourceHash:nil andType:nil categoryId:0];
	[_resourceHash release];
	[_resourceType release];
	self.parentInfoRef = nil;
	[super dealloc];
}

@end
