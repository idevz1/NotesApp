
#import "VLTargetSelectorReference.h"

@implementation VLTargetSelectorReference

@synthesize target = _target;
@synthesize selector = _selector;

- (id)initWithTarget:(id)target selector:(SEL)selector
{
	if(self = [super init])
	{
		_target = target;
		_selector = selector;
	}
	return self;
}

@end
