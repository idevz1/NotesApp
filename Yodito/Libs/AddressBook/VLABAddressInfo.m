
#import "VLABAddressInfo.h"
#import "../Common/Classes.h"
#import "../Ctrls/Classes.h"

@implementation VLABAddressInfo

@dynamic label;
@dynamic streets;
@dynamic allStreetsAsLines;
@dynamic city;
@dynamic state;
@dynamic zip;
@dynamic country;
@dynamic countryCode;

- (id)init
{
	self = [super init];
	if(self)
	{
		_label = [[NSString stringWithString:(NSString*)kABOtherLabel] retain];
		_streets = [[NSMutableArray alloc] init];
		_city = [@"" retain];
		_state = [@"" retain];
		_zip = [@"" retain];
		_country = [@"" retain];
		_countryCode = [@"" retain];
	}
	return self;
}

- (NSString*)label { return _label; }
- (void)setLabel:(NSString*)value
{
	if(!value) value = @"";
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![_label isEqual:value])
	{	[_label release];
		_label = [value copy];  }
}

- (NSArray*)streets
{
	return _streets;
}

- (void)setStreets:(NSArray*)values
{
	if(!values)
		values = [NSArray array];
	[_streets removeAllObjects];
	for(NSString *str in values)
	{
		str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if([NSString isEmpty:str])
			continue;
		[_streets addObject:str];
	}
}

- (NSString*)allStreetsAsLines
{
	NSMutableString *str = [NSMutableString string];
	for(NSString *s in _streets)
	{
		if([str length])
			[str appendString:@"\n"];
		[str appendString:s];
	}
	return str;
}

- (void)setAllStreetsAsLines:(NSString*)value
{
	if(!value)
		value = @"";
	NSArray *lines = [value componentsSeparatedByString:@"\n"];
	self.streets = lines;
}

- (NSString*)city { return _city; }
- (void)setCity:(NSString*)value
{
	if(!value) value = @"";
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![_city isEqual:value])
	{	[_city release];
		_city = [value copy];  }
}

- (NSString*)state { return _state; }
- (void)setState:(NSString*)value
{
	if(!value) value = @"";
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![_state isEqual:value])
	{	[_state release];
		_state = [value copy];  }
}

- (NSString*)zip { return _zip; }
- (void)setZip:(NSString*)value
{
	if(!value) value = @"";
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![_zip isEqual:value])
	{	[_zip release];
		_zip = [value copy];  }
}

- (NSString*)country { return _country; }
- (void)setCountry:(NSString*)value
{
	if(!value) value = @"";
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![_country isEqual:value])
	{	[_country release];
		_country = [value copy];  }
}

- (NSString*)countryCode { return _countryCode; }
- (void)setCountryCode:(NSString*)value
{
	if(!value) value = @"";
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![_countryCode isEqual:value])
	{	[_countryCode release];
		_countryCode = [value copy];  }
}

/*- (BOOL)validateWithAlert:(BOOL)withAlert
{
	[self retain];
	NSString *sError = nil;
	//if([NSString isEmpty:self.firstName])
	//	sError = @"Please enter First Name";
	//else if([NSString isEmpty:self.lastName])
	//	sError = @"Please enter Last Name";
	//else if([NSString isEmpty:self.email])
	//	sError = @"Please enter Email";
	//else if(![self.email validateAsEmail])
	//	sError = @"Please enter Email";
	//else if([NSString isEmpty:self.address1] && [NSString isEmpty:self.address2])
	//	sError = @"Please enter Address";
	//if([NSString isEmpty:self.street])
	if(![_streets count])
		sError = @"Please enter Street";
	else if([NSString isEmpty:self.city])
		sError = @"Please enter City";
	else if([NSString isEmpty:self.country])
		sError = @"Please enter Country";
	//else if([NSString isEmpty:self.country])
	//	sError = @"Please enter CountryCode";
	if(sError)
	{
		if(withAlert)
			[VLAlertView showWithOkAndTitle:sError message:@""];
		[self autorelease];
		return NO;
	}
	[self autorelease];
	return YES;
}*/

- (NSString*)allStreetsToString
{
	NSMutableString *str = [NSMutableString string];
	for(NSString *s in _streets)
	{
		if([str length])
			[str appendString:@", "];
		[str appendString:s];
	}
	return str;
}

- (NSString*)toString
{
	NSMutableString *str = [NSMutableString stringWithCapacity:250];
	[str appendFormat:@"Label: %@ \n", ![NSString isEmpty:self.label] ? self.label: @"{empty}"];
	[str appendFormat:@"Streets: %@ \n", ![NSString isEmpty:[self allStreetsToString]] ? [self allStreetsToString] : @"{empty}"];
	[str appendFormat:@"City: %@ \n", ![NSString isEmpty:self.city] ? self.city : @"{empty}"];
	[str appendFormat:@"State: %@ \n", ![NSString isEmpty:self.state] ? self.state : @"{empty}"];
	[str appendFormat:@"ZIP: %@", ![NSString isEmpty:self.zip] ? self.zip : @"{empty}"];
	[str appendFormat:@"Country Code: %@ \n", ![NSString isEmpty:self.countryCode] ? self.countryCode : @"{empty}"];
	return str;
}

- (void)assignFromDictionary:(NSDictionary*)theDict
{
	NSString *str = [theDict objectForKey:(NSString*)kABPersonAddressStreetKey];
	if(str)
		self.streets = [str componentsSeparatedByString:@"\n"];
	else
		self.streets = [NSArray array];
	str = [theDict objectForKey:(NSString*)kABPersonAddressCityKey];
	self.city = str ? str : @"";
	str = [theDict objectForKey:(NSString*)kABPersonAddressStateKey];
	self.state = str ? str : @"";
	str = [theDict objectForKey:(NSString*)kABPersonAddressZIPKey];
	self.zip = str ? str : @"";
	str = [theDict objectForKey:(NSString*)kABPersonAddressCountryKey];
	self.country = str ? str : @"";
	str = [theDict objectForKey:(NSString*)kABPersonAddressCountryCodeKey];
	self.countryCode = str ? str : @"";
}

- (BOOL)isEqual:(VLABAddressInfo*)other
{
	if(![self.city isEqual:other.city])
		return NO;
	if(![self.state isEqual:other.state])
		return NO;
	if(![self.zip isEqual:other.zip])
		return NO;
	if(![self.country isEqual:other.country])
		return NO;
	if(![self.countryCode isEqual:other.countryCode])
		return NO;
	if([self.streets count] != [other.streets count])
		return NO;
	for(int i = 0; i < [self.streets count]; i++)
	{
		NSString *str1 = [self.streets objectAtIndex:i];
		NSString *str2 = [other.streets objectAtIndex:i];
		if(![str1 isEqual:str2])
			return NO;
	}
	return YES;
}

- (void)dealloc
{
	[_label release];
	[_streets release];
	//[_street release];
	[_city release];
	[_state release];
	[_zip release];
	[_country release];
	[_countryCode release];
	[super dealloc];
}

@end

