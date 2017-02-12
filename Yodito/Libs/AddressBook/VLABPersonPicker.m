
#import "VLABPersonPicker.h"
#import "../Logic/Classes.h"
#import "../System/Classes.h"
#import "../Ctrls/Classes.h"

@implementation VLABPersonPicker

@synthesize mode = _mode;

+ (VLABPersonPicker*)shared
{
	static VLABPersonPicker *_shared = nil;
	if(!_shared)
		_shared = [[VLABPersonPicker alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
	}
	return self;
}

- (void)selectPersonFromVC:(UIViewController*)parentVC
			   resultBlock:(VLABPersonPicker_ResultBlock)resultBlock
{
	_parentVC = parentVC;
	if(_resultBlock)
		Block_release(_resultBlock);
	_resultBlock = Block_copy(resultBlock);
	if(_recordInfo)
	{
		[_recordInfo release];
		_recordInfo = nil;
	}
	_peoplePicker = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
	_peoplePicker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonAddressProperty]];
	if(_mode == EVLABPersonPickerModeAddress)
		_peoplePicker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonAddressProperty]];
	else if(_mode == EVLABPersonPickerModeEmail)
		_peoplePicker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
	_peoplePicker.peoplePickerDelegate = self;
	
	if(IsUiIPad)
		[_peoplePicker setModalPresentationStyle:UIModalPresentationPageSheet];//UIModalTransitionStyleCrossDissolve
	[_parentVC presentViewController:_peoplePicker animated:YES completion:^{
	}];
}

- (void)dismiss
{
	[self retain];
	VLABPersonPicker_ResultBlock resultBlock = nil;
	if(_resultBlock)
	{
		resultBlock = Block_copy(_resultBlock);
		Block_release(_resultBlock);
		_resultBlock = nil;
	}
	VLABRecordInfo *recordInfo = nil;
	if(_recordInfo)
	{
		recordInfo = [_recordInfo retain];
		[_recordInfo release];
		_recordInfo = nil;
	}
	if(resultBlock)
		resultBlock(recordInfo);
	if(_parentVC && _parentVC.presentedViewController == _peoplePicker)
		[_parentVC dismissViewControllerAnimated:YES completion:^{
		}];
	[[VLAppDelegateBase sharedAppDelegateBase] dismissModalViewController:_peoplePicker animated:YES];
	if(resultBlock)
		Block_release(resultBlock);
	if(recordInfo)
		[recordInfo release];
	[self autorelease];
}

#pragma mark AddressBook

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[self dismiss];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	if(_mode == EVLABPersonPickerModeAddress)
		return YES;
	if(_mode == EVLABPersonPickerModeEmail)
		return YES;
	[_recordInfo release];
	_recordInfo = [[VLABRecordInfo alloc] init];
	_recordInfo.record = person;
	[self dismiss];
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
								property:(ABPropertyID)property
							  identifier:(ABMultiValueIdentifier)identifier
{
	if(_mode == EVLABPersonPickerModeAddress) {
		if (property == kABPersonAddressProperty) {
			VLABRecordInfo *recordInfo = [[[VLABRecordInfo alloc] init] autorelease];
			CFTypeRef firstNameVal = ABRecordCopyValue(person, kABPersonFirstNameProperty);
			if(firstNameVal)
			{
				recordInfo.firstName = [NSString stringWithFormat:@"%@", firstNameVal ? (NSString*)firstNameVal : @""];
				CFRelease(firstNameVal);
			}
			CFTypeRef lastNameVal = ABRecordCopyValue(person, kABPersonLastNameProperty);
			if(lastNameVal)
			{
				recordInfo.lastName = [NSString stringWithFormat:@"%@", lastNameVal ? (NSString*)lastNameVal : @""];
				CFRelease(lastNameVal);
			}
			
			VLABAddressInfo *addrInfo = [[[VLABAddressInfo alloc] init] autorelease];
			
			ABMultiValueRef addresses = ABRecordCopyValue(person, kABPersonAddressProperty);
			CFIndex idx = ABMultiValueGetIndexForIdentifier(addresses, identifier);
			CFDictionaryRef address = ABMultiValueCopyValueAtIndex(addresses, idx);
			CFTypeRef streetVal = (NSString *)CFDictionaryGetValue(address, kABPersonAddressStreetKey);
			NSString *street = [NSString stringWithFormat:@"%@", streetVal ? (NSString*)streetVal : @""];
			NSArray *streets = [street componentsSeparatedByString:@"\n"];
			addrInfo.streets = streets;
			//args.address2 = ([streets count] > 1) ? [streets objectAtIndex:1] : @"";
			addrInfo.city = (NSString *)CFDictionaryGetValue(address, kABPersonAddressCityKey);
			addrInfo.state = (NSString *)CFDictionaryGetValue(address, kABPersonAddressStateKey);
			addrInfo.zip = (NSString *)CFDictionaryGetValue(address, kABPersonAddressZIPKey);
			addrInfo.country = (NSString *)CFDictionaryGetValue(address, kABPersonAddressCountryKey);
			addrInfo.countryCode = (NSString *)CFDictionaryGetValue(address, kABPersonAddressCountryCodeKey);
			CFRelease(address);
			CFRelease(addresses);
			recordInfo.addresses = [NSArray arrayWithObject:addrInfo];
			[_recordInfo release];
			_recordInfo = [recordInfo retain];
			[self dismiss];
			return NO;
		}
		return YES;
	} else if(_mode == EVLABPersonPickerModeEmail) {
		if (property == kABPersonEmailProperty) {
			VLABRecordInfo *recordInfo = [[[VLABRecordInfo alloc] init] autorelease];
			CFTypeRef firstNameVal = ABRecordCopyValue(person, kABPersonFirstNameProperty);
			if(firstNameVal)
			{
				recordInfo.firstName = [NSString stringWithFormat:@"%@", firstNameVal ? (NSString*)firstNameVal : @""];
				CFRelease(firstNameVal);
			}
			CFTypeRef lastNameVal = ABRecordCopyValue(person, kABPersonLastNameProperty);
			if(lastNameVal)
			{
				recordInfo.lastName = [NSString stringWithFormat:@"%@", lastNameVal ? (NSString*)lastNameVal : @""];
				CFRelease(lastNameVal);
			}
			
			ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
			CFIndex idx = ABMultiValueGetIndexForIdentifier(emails, identifier);
			CFTypeRef value = ABMultiValueCopyValueAtIndex(emails, idx);
			CFTypeRef label = ABMultiValueCopyLabelAtIndex(emails, idx);
			VLABEmailInfo *emailInfo = [[[VLABEmailInfo alloc] init] autorelease];
			emailInfo.label = label;
			emailInfo.value = value;
			if(label)
				CFRelease(label);
			if(value)
				CFRelease(value);
			if(emails)
				CFRelease(emails);
			recordInfo.emails = [NSArray arrayWithObject:emailInfo];
			[_recordInfo release];
			_recordInfo = [recordInfo retain];
			[self dismiss];
			return NO;
		}
		return YES;
	}
	return NO;
}

- (void)dealloc
{
	if(_resultBlock)
		Block_release(_resultBlock);
	[_recordInfo release];
    [super dealloc];
}

@end
