
#import <Foundation/Foundation.h>

@interface VLDeviceManager : NSObject
{
	
}

+ (BOOL)isUiIPhone;
+ (BOOL)isUiIPad;

+ (BOOL)isMacDevice;
+ (BOOL)isIPhoneDevice;
+ (BOOL)isIPodDevice;
+ (BOOL)isIPadDevice;

+ (BOOL)isSimulator;

+ (BOOL)isInternetAvailable;
+ (BOOL)isInternetAndWiFiAvailable;
+ (BOOL)checkIfUrlReachable:(NSString*)sUrl;

+ (BOOL)canRotateProgrammatically;
+ (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

@end
