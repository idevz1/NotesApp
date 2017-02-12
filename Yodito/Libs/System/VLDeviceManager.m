
#import "VLDeviceManager.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "Reachability.h"

@implementation VLDeviceManager

+ (NSString *) platform
{
    int mib[2];
	size_t len;
	char *machine;
	
	mib[0] = CTL_HW;
	mib[1] = HW_MACHINE;
	sysctl(mib, 2, NULL, &len, NULL, 0);
	machine = malloc(len);
	sysctl(mib, 2, machine, &len, NULL, 0);
	
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
	return platform;
}

+ (BOOL)isUiIPhone
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}
+ (BOOL)isUiIPad
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

+ (BOOL)isMacDevice
{
	Class class = NSClassFromString(@"NSApplication");
	if(class != nil)
		return YES;
	else
		return NO;
}

+ (BOOL)isIPhoneDevice
{
	UIDevice *device = [UIDevice currentDevice];
	NSString *sPlatform = [VLDeviceManager platform];
	NSString *sInfo = [NSString stringWithFormat:@"%@ %@ %@", device.name, device.model, sPlatform];
	if(sInfo && [sInfo rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].length)
		return YES;
	return NO;
}
+ (BOOL)isIPodDevice
{
	UIDevice *device = [UIDevice currentDevice];
	NSString *sPlatform = [VLDeviceManager platform];
	NSString *sInfo = [NSString stringWithFormat:@"%@ %@ %@", device.name, device.model, sPlatform];
	if(sInfo && [sInfo rangeOfString:@"iPod" options:NSCaseInsensitiveSearch].length)
		return YES;
	return NO;
}
+ (BOOL)isIPadDevice
{
	UIDevice *device = [UIDevice currentDevice];
	NSString *sPlatform = [VLDeviceManager platform];
	NSString *sInfo = [NSString stringWithFormat:@"%@ %@ %@", device.name, device.model, sPlatform];
	if(sInfo && [sInfo rangeOfString:@"iPad" options:NSCaseInsensitiveSearch].length)
		return YES;
	return NO;
}

+ (BOOL)isSimulator
{
#if !(TARGET_IPHONE_SIMULATOR)
	return NO;
#endif
	return YES;
}

+ (BOOL)isInternetAvailable
{
	Reachability *r = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	if((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
		return NO;
	else
		return YES;
}

+ (BOOL)isInternetAndWiFiAvailable {
	Reachability *r = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	if(internetStatus == ReachableViaWiFi)
		return YES;
	else
		return NO;
}

+ (BOOL)checkIfUrlReachable:(NSString*)sUrl
{
	Reachability *r = [Reachability reachabilityWithHostName:sUrl];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
		return NO;
	else
		return YES;
}

+ (BOOL)canRotateProgrammatically
{
	UIDevice *device = [UIDevice currentDevice];
	if([device respondsToSelector:@selector(setOrientation:)])
		return YES;
	else
		return NO;
}

+ (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
	UIDevice *device = [UIDevice currentDevice];
	if([device respondsToSelector:@selector(setOrientation:)])
	{
		NSMethodSignature * mySignature = [UIDevice
										   instanceMethodSignatureForSelector:@selector(setOrientation:)];
		NSInvocation * myInvocation = [NSInvocation
									   invocationWithMethodSignature:mySignature];
		[myInvocation setTarget:device];
		[myInvocation setSelector:@selector(setOrientation:)];
		UIInterfaceOrientation orient = orientation;
		[myInvocation setArgument:&orient atIndex:2];
		[myInvocation invoke];
		//[[UIDevice currentDevice] setOrientation:orientation];
	}
}

@end

