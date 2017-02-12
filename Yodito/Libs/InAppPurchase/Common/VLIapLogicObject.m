
#import "VLIapLogicObject.h"

@implementation VLIapLogicObject

@synthesize lastError = _lastError;

- (void)setLastError:(NSError *)lastError {
	if(_lastError || lastError) {
		[_lastError release];
		_lastError = [lastError retain];
		[self modifyVersion];
	}
}

- (void)dealloc {
	[_lastError release];
	[super dealloc];
}

@end
