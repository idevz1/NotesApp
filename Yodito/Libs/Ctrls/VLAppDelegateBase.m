
#import "VLAppDelegateBase.h"
#import "VLCtrlsUtils.h"
#import "../Common/Classes.h"
#import "../Logic/Classes.h"

@implementation VLAppDelegateBase

@synthesize rootViewController = _rootViewController;
@synthesize ntfrWillAnimateRotationToInterfaceOrientation = _ntfrWillAnimateRotationToInterfaceOrientation;
@synthesize msgrApplicationDidBecomeActive = _msgrApplicationDidBecomeActive;
@synthesize ntfrDidReceiveMemoryWarning = _ntfrDidReceiveMemoryWarning;
@synthesize msgrCurrentLocaleDidChange = _msgrCurrentLocaleDidChange;

+ (VLAppDelegateBase*)sharedAppDelegateBaseSet:(VLAppDelegateBase*)valueToSet
{
	static VLAppDelegateBase* _instance = nil;
	if(valueToSet)
		_instance = valueToSet;
	return _instance;
}

+ (VLAppDelegateBase*)sharedAppDelegateBase
{
	return [VLAppDelegateBase sharedAppDelegateBaseSet:nil];
}

- (id)init
{
	self = [super init];
	if(self)
	{
		[VLAppDelegateBase sharedAppDelegateBaseSet:self];
		_ntfrWillAnimateRotationToInterfaceOrientation = [[VLDelegate alloc] init];
		_ntfrWillAnimateRotationToInterfaceOrientation.owner = self;
		_msgrApplicationDidBecomeActive = [[VLMessenger alloc] init];
		_msgrApplicationDidBecomeActive.owner = self;
		_ntfrDidReceiveMemoryWarning = [[VLDelegate alloc] init];
		_ntfrDidReceiveMemoryWarning.owner = self;
		_msgrCurrentLocaleDidChange = [[VLMessenger alloc] init];
		_msgrCurrentLocaleDidChange.owner = self;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocaleDidChangeNotification:) name:NSCurrentLocaleDidChangeNotification object:nil];
	}
	return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
	return YES;
}

- (UIViewController*)topModalViewController
{
	UIViewController *vc = [self rootViewController];
	while(vc && vc.presentedViewController)
		vc = vc.presentedViewController;
	return vc;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[_msgrApplicationDidBecomeActive postMessage];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[VLCachedObjectsManager shared] freeUnusedMemory];
	[_ntfrDidReceiveMemoryWarning sendMessage:self];
}

- (void)dismissModalViewController:(UIViewController*)vc animated:(BOOL)animated
{
	UIViewController *parVC = [self rootViewController];
	UIViewController *curVC = parVC.presentedViewController;
	while(curVC)
	{
		if(curVC == vc || [VLCtrlsUtils viewController:curVC containsChild:vc])
		{
			[parVC dismissViewControllerAnimated:animated completion:^{
			}];
			return;
		}
		parVC = curVC;
		curVC = curVC.presentedViewController;
	}
	if(kVLLogWarnings)
		NSLog(@"WARNING: VLAppDelegateBase - dismissModalViewController - vc not found");
}

+ (NSString*)applicationInstanceIdentifier
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	static NSString *key = @"VLAppDelegateBase_applicationInstanceIdentifier";
	if([NSString isEmpty:[defs stringForKey:key]])
	{
		NSString *sGuid = nil;
		UIDevice *device = [UIDevice currentDevice];
		if([device respondsToSelector:@selector(identifierForVendor)]) {
			NSUUID *uuid = [device identifierForVendor];
			sGuid = [uuid UUIDString];
			sGuid = [sGuid lowercaseString];
		} else {
			VLGuid *guid = [VLGuid makeUnique];
			sGuid = [guid toString];
		}
		[defs setObject:sGuid forKey:key];
		[defs synchronize];
	}
	return [defs stringForKey:key];
}

- (void)raiseWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	[_ntfrWillAnimateRotationToInterfaceOrientation sendMessage:self];
}

- (void)startAnimateNetworkActivityIndicator
{
	if (++_networkActivityIndicatorLevel == 1)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)stopAnimateNetworkActivityIndicator
{
	if (_networkActivityIndicatorLevel == 0)
		return;
	if (--_networkActivityIndicatorLevel == 0)
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)currentLocaleDidChangeNotification:(NSNotification *)notification {
	[_msgrCurrentLocaleDidChange postMessage];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_rootViewController release];
	[_ntfrWillAnimateRotationToInterfaceOrientation release];
	[_msgrApplicationDidBecomeActive release];
	[_ntfrDidReceiveMemoryWarning release];
	[_msgrCurrentLocaleDidChange release];
	[super dealloc];
}

@end
