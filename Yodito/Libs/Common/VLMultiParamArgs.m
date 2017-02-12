
#import "VLMultiParamArgs.h"

@implementation VLMultiParamArgs

@synthesize objectParam1 = _objectParam1;
@synthesize objectParam2 = _objectParam2;
@synthesize boolParam1 = _boolParam1;
@synthesize boolParam2 = _boolParam2;
@synthesize int64Param1 = _int64Param1;
@synthesize objectResult1 = _objectResult1;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)dealloc {
	[_objectParam1 release];
	[_objectParam2 release];
	[_objectResult1 release];
	[super dealloc];
}

@end

