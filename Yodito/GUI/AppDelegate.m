
#import "AppDelegate.h"
#import "YTUiMediator.h"
#import "TestFlight.h"
#import "YTCommon.h"
#import "Classes.h"
#import "iPadDetailViewController.h"
#import "RootViewController.h"
#import "YTNotesContentView.h"
#import "NSOBjects+ytCategories.h"
@implementation AppDelegate

@synthesize rootNavigationVC = _rootNavigationVC;
@synthesize window = _window;
@synthesize detailViewController;
+(AppDelegate*)instance{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (AppDelegate*)sharedAppDelegate
{
	return ObjectCast([VLAppDelegateBase sharedAppDelegateBase], AppDelegate);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"edit"];

    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"add"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"settings"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"settings2"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"first"];
	[VLTimer setTimerIntervalMultiplier:kYTTimerIntervalMultiplier];
	
	[VLLogger shared].loggingDisabled = !kYTLoggingEnabled;
	if(kYTLogToFile) {
		[[VLLogger shared] setMaxLogFileSizes:kYTMaxLogFileSizes];
		[[VLLogger shared] enableLoggingToFile];
	}
	
#ifdef kYTIsBeta
	// !!!: Use the next line only during beta:
	//[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
	//[TestFlight setDeviceIdentifier:[VLAppDelegateBase applicationInstanceIdentifier]];
	[TestFlight takeOff:kYTTestFlightAppToken];
#else
#endif
	
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	if(kIosVersionFloat >= 7.0)
		[application setStatusBarStyle:UIStatusBarStyleLightContent];
    [application setStatusBarHidden:NO];
	application.applicationSupportsShakeToEdit = NO;
	_backgroundTaskId = UIBackgroundTaskInvalid;
	application.applicationIconBadgeNumber = 0;
	
	[VLActivityView setDefaultBackgroundcolor:kYTProgressIndicatorBackColor];
	[VLActivityView setDefaultCenterBackcolor:kYTProgressIndicatorCenterBackColorTransparent];
	[VLActivityView setDefaultDimBackground:NO];
	
	[[VLMessageCenter shared] setTimerInterval:kYTMessageCenterTimerInterval];
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	[VLIapCommon initializeWithIsSandbox:kYTDebugMode];
	//[[YTStorageManager shared] initialize];
	//[[YTResourcesStorage shared] initialize];
	[VLImageCache shared].maxAllPixelsAmount = kYTImageCachMaxAllPixelsAmount;
	//[YTCachedImageStore shared];
	[[YTDatabaseManager shared] initializeMT];
	[[YTEntitiesManagersLister shared] initializeMT];
	
	NSTimeInterval tm1 = [[NSProcessInfo processInfo] systemUptime];
	[[VLMessageCenter shared] performBlock:^{
		[[YTDatabaseManager shared] initializeWithResultBlockMT:^{
			[[YTEntitiesManagersLister shared] initializeWithResultBlockMT:^{
				NSTimeInterval tm2 = [[NSProcessInfo processInfo] systemUptime];
				VLLoggerTrace(@"DB initialization %0.4f s", tm2 - tm1);
			}];
		}];
	} afterDelay:0.01 ignoringTouches:YES];
    
	[YTPhotoPreviewMaker shared];
	[[YTFontsManager shared] initialize];
	[[YTNoteTableCellViewManager shared] initialize];
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *curAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *lastAppVersion = [defs objectForKey:kYTCurrentAppVersionKey];
	if(!lastAppVersion)
		lastAppVersion = @"0.0";
	if(![lastAppVersion isEqual:curAppVersion]) {
		[defs setObject:curAppVersion forKey:kYTCurrentAppVersionKey];
		[defs synchronize];
	}
	NSString *curAppBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *lastAppBuild = [defs objectForKey:kYTCurrentAppBuildKey];
	if(!lastAppBuild)
		lastAppBuild = @"0";
	if(![lastAppBuild isEqual:curAppBuild]) {
		[defs setObject:curAppBuild forKey:kYTCurrentAppBuildKey];
		[defs synchronize];
	}
	
	//[[YTDatabaseManager shared] waitingUntilDone:YES performBlockOnDT:^{
	//	[[YTDatabaseManager shared] cleanDatabase];
	//}];
	
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        _rootNavigationVC = [[YTRootNavigationController alloc] init];
        _rootNavigationVC.navigationBarHidden = YES;
        
 
        // RootViewController* firstVC = [[RootViewController alloc] init];
        
        detailViewController= [[iPadDetailViewController alloc]init];
        YTNoteView *view = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class] parentView:[UIApplication sharedApplication].keyWindow];
        detailViewController.view = view;
        YTRootNavigationController *navC = [[YTRootNavigationController alloc]init];
        navC.navigationBarHidden = YES;
        [navC pushViewController:detailViewController animated:NO];
        _slidingVC = [[YTBaseViewController alloc] initWithViewClass:[YTSlidingContainerView class]];
        
        [_rootNavigationVC pushViewController:_slidingVC animated:NO];
        
        
        
        UISplitViewController* splitVC = [[UISplitViewController alloc] init];
        splitVC.viewControllers = [NSArray arrayWithObjects:_rootNavigationVC, navC, nil];

        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.rootViewController = splitVC;
        
        
    }
    else{
        
        _rootNavigationVC = [[YTRootNavigationController alloc] init];
        _rootNavigationVC.navigationBarHidden = YES;
        
        _slidingVC = [[YTBaseViewController alloc] initWithViewClass:[YTSlidingContainerView class]];
        [_rootNavigationVC pushViewController:_slidingVC animated:NO];
    
        _window.rootViewController = _rootNavigationVC;
        super.rootViewController = _rootNavigationVC;
        
	}
    [_window makeKeyAndVisible];
    
	_timer = [[VLTimer alloc] init];
	_timer.interval = 1.0;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	[_timer start];
	
	return YES;
}
-(void)changeNote:(YTNoteInfo*)info{
 /*  // [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"first"];
    NSArray* myArray = [ [info.createdDate yoditoToString]  componentsSeparatedByString:@" "];
    
    NSString* firstString = [myArray objectAtIndex:0];
    NSLog(@"lol %@",info.noteGuid);
    detailViewController.note = info;
    //detailViewController.lbl.text = firstString;
    [detailViewController setTitle:firstString]; */
}
-(void)showImagePicker:(ELCImagePickerController*)picker{
    bool edit = [[NSUserDefaults standardUserDefaults]boolForKey:@"edit"];
    if (edit==YES)
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"edit"];
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
            detailViewController.popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
            [detailViewController.popOver presentPopoverFromRect:CGRectMake(350, 720, 1, 1) inView:detailViewController.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
        
        else{
            detailViewController.popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
            [detailViewController.popOver presentPopoverFromRect:CGRectMake(385, 980, 1, 1) inView:detailViewController.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

        }

    }
        
        else{
            
        
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
    detailViewController.popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
    [detailViewController.popOver presentPopoverFromRect:CGRectMake(-35, 80, 1, 1) inView:detailViewController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    else{
        detailViewController.popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
        [detailViewController.popOver presentPopoverFromRect:CGRectMake(290, 80, 1, 1) inView:detailViewController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

    }
        }
  //  [detailViewController presentViewController:picker animated:YES completion:^{
	//}];

    
}
-(void)showSettingsImagePicker:(UIImagePickerController *)pC{
    [detailViewController.popUpNav presentViewController:pC animated:YES completion:nil];

}

-(void)showSettings:(YTSettingsView *)settings{
    
    /*
    detailViewController.popUpView.view = settings;
    [detailViewController.popUpView setModalPresentationStyle:UIModalPresentationFormSheet];
    [_rootNavigationVC presentViewController:detailViewController.popUpView animated:YES completion:nil];*/
    
    detailViewController.popUpView.view= settings;
    
    [detailViewController.popUpNav setModalPresentationStyle:UIModalPresentationFormSheet];    detailViewController.popUpView.view.superview.bounds = CGRectMake(0, 0, 100, 100);

    [_rootNavigationVC presentViewController:detailViewController.popUpNav animated:YES completion:nil];
    detailViewController.popUpView.view.superview.bounds = CGRectMake(0, 0, 100, 100);

    

}
-(void)settingsChangeTo:(YTBaseView *)neww{
    /*
    detailViewController.auxView = detailViewController.popUpView.view;
    detailViewController.popUpView.view = neww;*/
    detailViewController.popUpDetailView.view = neww;
    [detailViewController.popUpNav pushViewController:detailViewController.popUpDetailView animated:YES];
    
    
}
-(void)settingsGoBack{
    [detailViewController.popUpNav popViewControllerAnimated:YES];
}
-(void)settingsDismiss{
    [detailViewController.popUpNav dismissViewControllerAnimated:YES completion:nil];
}
-(void)showMap:(YTMapSearchView *)mapView{

    detailViewController.popUpView.view = mapView;
    [detailViewController.popUpNav setModalPresentationStyle:UIModalPresentationFormSheet];
    [_rootNavigationVC presentViewController:detailViewController.popUpNav animated:YES completion:nil];
}
-(void)notebookShow:(YTNotebookSelectView*)plm fromNote:(YTNoteEditInfo*)jeg{
    //detailViewController.delegate = self;
    
    plm.noteEditInfo= jeg;
    detailViewController.popUpView.view = plm;
    [detailViewController.popUpNav setModalPresentationStyle:UIModalPresentationFormSheet];
    [_rootNavigationVC presentViewController:detailViewController.popUpNav animated:YES completion:nil];
    //[authentication release];

}
-(void)dismissPopUpView{
    [detailViewController.popUpView dismissViewControllerAnimated:YES completion:nil];
}
-(void)showMailPicker:(MFMailComposeViewController*)picker{
    BOOL settings = [[NSUserDefaults standardUserDefaults]boolForKey:@"settings"];
    if (settings){
        [detailViewController.popUpNav presentViewController:picker animated:YES completion:^{
        }];
    }
  
    else
    [detailViewController presentViewController:picker animated:YES completion:^{
	}];

}
-(void)dismissImagePicker:(ELCImagePickerController *)picker{
    
    [detailViewController.popOver dismissPopoverAnimated:TRUE];

  //  [detailViewController dismissViewControllerAnimated:picker completion:nil];

}
-(void)dismissMailPicker:(MFMessageComposeViewController*)picker{
    BOOL settings = [[NSUserDefaults standardUserDefaults]boolForKey:@"settings"];
    if (settings==YES){
        [detailViewController.popUpNav dismissViewControllerAnimated:picker completion:nil];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"settings"];

    }
    else
    [detailViewController dismissViewControllerAnimated:picker completion:nil];
}
////***********************////////////////////////&&/////////
-(void)changeTo:(UIView*)first{
    NSLog(@"chanteo");
    CGRect newFrame = first.frame;
    newFrame.size.height -=10;
    newFrame.origin.y +=10;
    first.frame = newFrame;
    if (detailViewController.firstView==nil)
        detailViewController.firstView = detailViewController.view;
    detailViewController.auxView = detailViewController.view;
    [detailViewController setView:first];
    [detailViewController setSwipe];
    
}
-(void)changeBackTo{
    [detailViewController setView:detailViewController.auxView];
    [detailViewController setSwipe];
}
-(void)changeBackToI{
    [detailViewController setView:detailViewController.firstView];
    [detailViewController setSwipe];
}
-(void)addSubviewToDetailView:(YTNoteView*)sView{
    CGRect newFrame = sView.frame;
    newFrame.size.height -=10;
    newFrame.origin.y +=10;
    sView.frame = newFrame;
    
    [detailViewController setView:sView];


    [detailViewController setSwipe];
}
- (void)onTimerEvent:(id)sender
{
	if(_backgroundTaskId != UIBackgroundTaskInvalid) {
		UIApplication *app = [UIApplication sharedApplication];
		NSTimeInterval timeRemaining = [app backgroundTimeRemaining];
		if(timeRemaining < 30.0) { // Stop app before it is terminated
			VLLogEvent(@"Ending background task (timeRemaining < 30.0)");
			[app endBackgroundTask:_backgroundTaskId];
			_backgroundTaskId = UIBackgroundTaskInvalid;
			return;
		}
	}
	YTNoteEditView *noteEditView = (YTNoteEditView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteEditView class] parentView:self.rootViewController.view];
	[YTApiMediator shared].isShowingMainView = (noteEditView == nil);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSString *sAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *sBuildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	VLLoggerTrace(@"Version - %@, Build - %@", sAppVersion, sBuildNumber);
	[super applicationDidBecomeActive:application];
	if(_backgroundTaskId != UIBackgroundTaskInvalid) {
		VLLogEvent(@"Ending background task");
		[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
		_backgroundTaskId = UIBackgroundTaskInvalid;
	}
	NSTimeZone *timezone = [NSTimeZone defaultTimeZone];
	VLLoggerTrace(@"Current timezone - %@", timezone);
	if(kYTDisableUploadChangesToServer) {
		[[VLToastView makeText:@"DEBUG! DOWNLOADING ONLY"] show];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[super applicationWillResignActive:application];
	BOOL isBackgroundSupported = NO;
	UIDevice* device = [UIDevice currentDevice];
	if([device respondsToSelector:@selector(isMultitaskingSupported)])
		isBackgroundSupported = [device isMultitaskingSupported];
	if(   isBackgroundSupported
	   && kYTAllowSyncInBackground
	   && [YTSyncManager shared].processing
	   && [VLDeviceManager isInternetAvailable]
	   ) {
		VLLogEvent(@"Try begin background task");
		UIApplication *app = [UIApplication sharedApplication];
		_backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^(void) {
			if(_backgroundTaskId != UIBackgroundTaskInvalid) {
				VLLogEvent(@"BackgroundTaskWithExpirationHandler called. Ending background task.");
				[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
				_backgroundTaskId = UIBackgroundTaskInvalid;
			}
		}];
		if(_backgroundTaskId != UIBackgroundTaskInvalid) {
			VLLogEvent(@"Succeed begin background task");
			NSTimeInterval time = [app backgroundTimeRemaining];
			VLLogEvent(([NSString stringWithFormat:@"Background task: %f seconds remaining", time]));
		} else {
			VLLogEvent(@"Failed begin background task");
		}
	}
	if([application respondsToSelector:@selector(setMinimumBackgroundFetchInterval:)]) {
		YTUsersEnManager *manrUser = [YTUsersEnManager shared];
		if(manrUser.isLoggedIn && !manrUser.isDemo) {
			NSTimeInterval minimumBackgroundFetchInterval = UIApplicationBackgroundFetchIntervalMinimum;
			//NSTimeInterval minimumBackgroundFetchInterval = kYTMinimumBackgroundFetchInterval;
			[application setMinimumBackgroundFetchInterval:minimumBackgroundFetchInterval];
			VLLoggerTrace(@"setMinimumBackgroundFetchInterval: %f", minimumBackgroundFetchInterval);
		} else {
			[application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
		}
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	NSDictionary *userInfo = notification.userInfo ? notification.userInfo : [NSDictionary dictionary];
	NSString *noteGuid = [userInfo stringValueForKey:kYTJsonKeyNoteGUID defaultVal:@""];
	if(![NSString isEmpty:noteGuid]) {
		YTNoteInfo *note = [[YTNotesEnManager shared] getNoteByGuid:noteGuid];
		if(note) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kDefaultAnimationDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				if([YTNotesTableView currentInstance])
					[[YTNotesTableView currentInstance] showNote:note animated:YES];
			});
		}
	}
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	YTUsersEnManager *manrUser = [YTUsersEnManager shared];
	if(!manrUser.isLoggedIn || manrUser.isDemo) {
		[application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
		completionHandler(UIBackgroundFetchResultNoData);
		return;
	}
	YTSyncManager *manrSync = [YTSyncManager shared];
	[manrSync startSyncMTWithResultBlockMT:^(NSError *error) {
		if(error) {
			VLLoggerError(@"%@", error);
		}
		completionHandler(UIBackgroundFetchResultNewData);
	}];
}

- (void)dealloc
{
	[_window release];
	[_rootNavigationVC release];
	[_slidingVC release];
	[_timer release];
	[super dealloc];
}
@end

