
#import "VLCommunicationManager.h"

@implementation VLCommunicationManager

+ (BOOL)isPhoneAvailable
{
	BOOL result = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"tel://5555555"]];
	return result;
}

+ (BOOL)isFacetimeAvailable
{
	BOOL result = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"facetime://5555555"]];
	return result;
}

+ (BOOL)isIMessageAvailable
{
	BOOL result = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"sms://5555555"]];
	return result;
}

+ (NSString*)correctPhoneNumber:(NSString*)sNumber
{
	for(int i = (int)[sNumber length]-1; i >= 0; i--)
	{
		unichar ch = [sNumber characterAtIndex:i];
		if(ch == '(' || ch == ')' || ch == ' ' || ch == '-')
			sNumber = [sNumber stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:@""];
	}
	sNumber = [sNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return sNumber;
}

+ (void)startPhoneCallWithNumber:(NSString*)sNumber
{
	if(![VLCommunicationManager isPhoneAvailable])
	{
		[[[[UIAlertView alloc] initWithTitle:@"Error"
									 message:@"Phone Calls unavailable"
									delegate:nil
						   cancelButtonTitle:nil
						   otherButtonTitles:@"OK", nil] autorelease] show];
		return;
	}
	sNumber = [VLCommunicationManager correctPhoneNumber:sNumber];
	NSString *sUrl = [NSString stringWithFormat:@"tel://%@", sNumber];
	NSURL *url = [NSURL URLWithString:sUrl];
	[[UIApplication sharedApplication] openURL:url];
}

+ (void)startFacetimeWithNumber:(NSString*)sNumber
{
	if(![VLCommunicationManager isFacetimeAvailable])
	{
		[[[[UIAlertView alloc] initWithTitle:@"Error"
								message:@"Facetime unavailable"
								delegate:nil
								cancelButtonTitle:nil
								otherButtonTitles:@"OK", nil] autorelease] show];
		return;
	}
	sNumber = [VLCommunicationManager correctPhoneNumber:sNumber];

	NSString *sUrl = [NSString stringWithFormat:@"facetime://%@", sNumber];
	NSURL *url = [NSURL URLWithString:sUrl];
	[[UIApplication sharedApplication] openURL:url];
}

+ (void)startMessageWithNumber:(NSString*)sNumber
{
	if(![VLCommunicationManager isIMessageAvailable])
	{
		[[[[UIAlertView alloc] initWithTitle:@"Error"
									 message:@"iMessage unavailable"
									delegate:nil
						   cancelButtonTitle:nil
						   otherButtonTitles:@"OK", nil] autorelease] show];
		return;
	}
	sNumber = [VLCommunicationManager correctPhoneNumber:sNumber];
	NSString *sUrl = [NSString stringWithFormat:@"sms://%@", sNumber];
	NSURL *url = [NSURL URLWithString:sUrl];
	[[UIApplication sharedApplication] openURL:url];
}

@end
