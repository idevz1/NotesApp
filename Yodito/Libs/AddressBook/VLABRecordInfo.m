
#import "VLABRecordInfo.h"
#import "../Common/Classes.h"

@implementation VLABRecordInfo

@dynamic record;
@dynamic recordId;
@dynamic firstName;
@dynamic lastName;
@dynamic addresses;
@dynamic emails;
@dynamic phones;

- (id)init
{
    self = [super init];
	if(self)
	{
		_record = ABPersonCreate();
    }
    return self;
}

- (ABRecordRef)record
{
	return _record;
}

- (void)setRecord:(ABRecordRef)value
{
	if(_record != value)
	{
		if(_record)
			CFRelease(_record);
		_record = value;
		if(_record)
			CFRetain(_record);
	}
}

- (ABRecordID)recordId
{
	return _record ? ABRecordGetRecordID(_record) : 0;
}

- (void)setRecordId:(ABRecordID)value
{
	if(self.recordId != value)
	{
		NSError *error = nil;
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, (CFErrorRef *)&error);
		ABRecordRef record = value ? ABAddressBookGetPersonWithRecordID(addressBook, value) : NULL;
		self.record = record;
		CFRelease(addressBook); //TODO: check fro crash
	}
}

- (NSString*)firstName
{
	CFTypeRef val = ABRecordCopyValue(_record, kABPersonFirstNameProperty);
	if(!val)
		return @"";
	NSString *res = [NSString stringWithString:(NSString*)val];
	CFRelease(val);
	return res;
}

- (void)setFirstName:(NSString*)value
{
	if(!value)
		value = @"";
	CFErrorRef error = nil;
	ABRecordSetValue(_record, kABPersonFirstNameProperty, value, &error);
}

- (NSString*)lastName
{
	CFTypeRef val = ABRecordCopyValue(_record, kABPersonLastNameProperty);
	if(!val)
		return @"";
	NSString *res = [NSString stringWithString:(NSString*)val];
	CFRelease(val);
	return res;
}

- (void)setLastName:(NSString*)value
{
	if(!value)
		value = @"";
	CFErrorRef error = nil;
	ABRecordSetValue(_record, kABPersonLastNameProperty, value, &error);
}

- (NSArray*)addresses
{
	NSMutableArray *addrs = [NSMutableArray array];
	ABMultiValueRef multiValue = ABRecordCopyValue(_record, kABPersonAddressProperty);
	CFIndex count = multiValue ? ABMultiValueGetCount(multiValue) : 0;
	for(CFIndex i = 0; i < count; i++)
	{
		NSDictionary *theDict = (NSDictionary*)ABMultiValueCopyValueAtIndex(multiValue, i);
		VLABAddressInfo *addr = [[[VLABAddressInfo alloc] init] autorelease];
		[addr assignFromDictionary:theDict];
		NSString *label = (NSString*)ABMultiValueCopyLabelAtIndex(multiValue, i);
		addr.label = label;
		if(label)
			CFRelease(label);
		[addrs addObject:addr];
		CFRelease(theDict);
	}
	if(multiValue)
		CFRelease(multiValue);
	return addrs;
}
- (void)setAddresses:(NSArray*)addrs
{
	if(!addrs)
		addrs = [NSArray array];
	CFErrorRef error = nil;
	ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	for(int i = 0; i < [addrs count]; i++)
	{
		VLABAddressInfo *addr = [addrs objectAtIndex:i];
		NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
		if (![NSString isEmpty:[addr allStreetsAsLines]])
			[addressDictionary setObject:[addr allStreetsAsLines] forKey:(NSString *)kABPersonAddressStreetKey];
		if (![NSString isEmpty:addr.city])
			[addressDictionary setObject:addr.city forKey:(NSString *)kABPersonAddressCityKey];
		if (![NSString isEmpty:addr.state])
			[addressDictionary setObject:addr.state forKey:(NSString *)kABPersonAddressStateKey];
		if (![NSString isEmpty:addr.zip])
			[addressDictionary setObject:addr.zip forKey:(NSString *)kABPersonAddressZIPKey];
		if (![NSString isEmpty:addr.country])
			[addressDictionary setObject:addr.country forKey:(NSString *)kABPersonAddressCountryKey];
		if (![NSString isEmpty:addr.countryCode])
			[addressDictionary setObject:addr.countryCode forKey:(NSString *)kABPersonAddressCountryCodeKey];
		//kABOtherLabel
		ABMultiValueAddValueAndLabel(multiAddress, addressDictionary, (CFStringRef)addr.label, NULL);
	}
	ABRecordSetValue(_record, kABPersonAddressProperty, multiAddress, &error);
	CFRelease(multiAddress);
}

- (NSArray*)emails
{
	NSMutableArray *result = [NSMutableArray array];
	ABMultiValueRef multiValue = ABRecordCopyValue(_record, kABPersonEmailProperty);
	CFIndex count = multiValue ? ABMultiValueGetCount(multiValue) : 0;
	for(CFIndex i = 0; i < count; i++)
	{
		NSString *value = (NSString*)ABMultiValueCopyValueAtIndex(multiValue, i);
		NSString *label = (NSString*)ABMultiValueCopyLabelAtIndex(multiValue, i);
		VLABEmailInfo *email = [[[VLABEmailInfo alloc] init] autorelease];
		email.label = label;
		email.value = value;
		if(label)
			CFRelease(label);
		if(value)
			CFRelease(value);
		[result addObject:email];
	}
	if(multiValue)
		CFRelease(multiValue);
	return result;
}

- (void)setEmails:(NSArray *)emails {
	if(!emails)
		emails = [NSArray array];
	CFErrorRef error = nil;
	ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABPersonEmailProperty);
	for(int i = 0; i < [emails count]; i++)
	{
		VLABEmailInfo *email = [emails objectAtIndex:i];
		ABMultiValueAddValueAndLabel(multiEmail, (CFStringRef)email.value, (CFStringRef)email.label, NULL);
	}
	ABRecordSetValue(_record, kABPersonEmailProperty, multiEmail, &error);
	CFRelease(multiEmail);
}

- (NSArray*)phones
{
	NSMutableArray *result = [NSMutableArray array];
	ABMultiValueRef multiValue = ABRecordCopyValue(_record, kABPersonPhoneProperty);
	CFIndex count = multiValue ? ABMultiValueGetCount(multiValue) : 0;
	for(CFIndex i = 0; i < count; i++)
	{
		NSString *value = (NSString*)ABMultiValueCopyValueAtIndex(multiValue, i);
		NSString *label = (NSString*)ABMultiValueCopyLabelAtIndex(multiValue, i);
		VLABPhoneInfo *phone = [[[VLABPhoneInfo alloc] init] autorelease];
		phone.label = label;
		phone.value = value;
		if(label)
			CFRelease(label);
		if(value)
			CFRelease(value);
		[result addObject:phone];
	}
	if(multiValue)
		CFRelease(multiValue);
	return result;
}

- (NSString*)fullName
{
	NSString *firstName = self.firstName;
	NSString *lastName = self.lastName;
	if(![NSString isEmpty:firstName] && ![NSString isEmpty:lastName])
		return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
	else if(![NSString isEmpty:firstName])
		return firstName;
	else if(![NSString isEmpty:lastName])
		return lastName;
	return @"";
}

- (void)dealloc
{
	if(_record)
		CFRelease(_record);
	[super dealloc];
}

@end
