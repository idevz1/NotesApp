
#import "VLDeviceManager.h"

#define IsUiIPad ([VLDeviceManager isUiIPad])
#define IsUiIPhone ([VLDeviceManager isUiIPhone])
#define IsUiIPhone5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define iUiChoice(forIPhone, forIPad) ([VLDeviceManager isUiIPhone] ? (forIPhone) : (forIPad))
#define IsPortrait (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
#define IsLandscape (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))