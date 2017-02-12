
#import "VLABPhoneInfo.h"

@implementation VLABPhoneInfo

@dynamic label;
@dynamic value;

- (id)init
{
	self = [super init];
	if(self)
	{
		_label = [[NSString stringWithString:(NSString*)kABOtherLabel] retain];
		_value = [@"" retain];
	}
	return self;
}

- (NSString*)label
{
	return _label;
}
- (void)setLabel:(NSString*)value
{
	if(!value)
		value = @"";
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![_label isEqual:value])
	{
		[_label release];
		_label = [value copy];
	}
}

- (NSString*)value
{
	return _value;
}
- (void)setValue:(NSString*)value
{
	if(!value)
		value = @"";
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![_value isEqual:value])
	{
		[_value release];
		_value = [value copy]; 
	}
}

- (void)dealloc
{
	[_label release];
	[_value release];
	[super dealloc];
}

@end

