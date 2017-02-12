
#import "YTResourceLoadingInfo.h"

@implementation YTResourceLoadingInfo

@synthesize references = _references;
//@synthesize resource = _resource;
@synthesize resourceHash = _resourceHash;
@synthesize resourceType = _resourceType;
@synthesize resourceCategoryId = _resourceCategoryId;
@synthesize error = _error;
//@synthesize image = _image;
@synthesize resourceFilePath = _resourceFilePath;

- (id)init {
	self = [super init];
	if(self) {
		CFArrayCallBacks acb = { 0, NULL, NULL, CFCopyDescription, CFEqual };
		_references = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &acb);
		_resourceHash = [@"" retain];
		_resourceType = [@"" retain];
		_resourceFilePath = [@"" retain];
	}
	return self;
}

/*- (void)setResource:(YTResourceInfo *)resource {
	if(_resource != resource) {
		if(_resource) {
			[_resource release];
		}
		_resource = resource;
		if(_resource) {
			[_resource retain];
			[self modifyVersion];
		}
	}
}*/

- (void)setResourceHash:(NSString *)resourceHash {
	if(!resourceHash)
		resourceHash = @"";
	if(![_resourceHash isEqual:resourceHash]) {
		[_resourceHash release];
		_resourceHash = [resourceHash copy];
		[self modifyVersion];
	}
}

- (void)setResourceType:(NSString *)resourceType {
	if(!resourceType)
		resourceType = @"";
	if(![_resourceType isEqual:resourceType]) {
		[_resourceType release];
		_resourceType = [resourceType copy];
		[self modifyVersion];
	}
}

- (void)setError:(NSError *)error {
	if(_error != error) {
		if(_error) {
			[_error release];
		}
		_error = error;
		if(_error) {
			[_error retain];
			[self modifyVersion];
			[self notifyReferences];
		}
	}
}

/*- (void)setImage:(UIImage *)image {
	if(_image != image) {
		if(_image)
			[_image release];
		_image = image;
		if(_image)
			[_image retain];
		[self modifyVersion];
		[self notifyReferences];
	}
}*/

- (void)setResourceFilePath:(NSString *)resourceFilePath {
	if(!resourceFilePath)
		resourceFilePath = @"";
	if(![_resourceFilePath isEqual:resourceFilePath]) {
		[_resourceFilePath release];
		_resourceFilePath = [resourceFilePath copy];
		[self modifyVersion];
	}
}

- (void)notifyReferences {
	for(YTResourceLoadingReference *reference in _references)
		[reference modifyVersion];
}

- (void)addReference:(YTResourceLoadingReference *)reference {
	[_references addObject:reference];
	reference.parentInfoRef = self;
}

- (void)removeReference:(YTResourceLoadingReference *)reference {
	if(reference.parentInfoRef == self)
		reference.parentInfoRef = nil;
	[_references removeObject:reference];
}

- (void)dealloc {
	//self.resource = nil;
	[_resourceHash release];
	[_resourceType release];
	self.error = nil;
	[_references release];
	//[_image release];
	[_resourceFilePath release];
	[super dealloc];
}

@end
