
#import <UIKit/UIKit.h>
#import "../Libs/Classes.h"
#import "../API/Classes.h"
#import "Main/Classes.h"
#import "User/Classes.h"
#import "Settings/Classes.h"

@class iPadDetailViewController;


@interface AppDelegate : VLAppDelegateBase
{
@private
	UIWindow *_window;
	YTRootNavigationController *_rootNavigationVC;
	YTBaseViewController *_slidingVC;
	UIBackgroundTaskIdentifier _backgroundTaskId;
	VLTimer *_timer;
    iPadDetailViewController *detailViewController;
    
}
+(AppDelegate*)instance;
-(void)showMailPicker:(MFMailComposeViewController*)picker;
-(void)changeNote:(YTNoteInfo*)info;
-(void)dismissMailPicker:(MFMessageComposeViewController*)picker;
-(void)changeTo:(UIView*)first;
-(void)changeBackTo;
-(void)changeBackToI;
-(void)addSubviewToDetailView:(YTNoteView*)sView;
-(void)showImagePicker:(ELCImagePickerController*)picker;
-(void)dismissImagePicker:(ELCImagePickerController*)picker;
@property(nonatomic, readonly) YTRootNavigationController *rootNavigationVC;
@property(nonatomic, readonly) UIWindow *window;
@property (nonatomic, retain) IBOutlet iPadDetailViewController *detailViewController;
-(void)notebookShow:(YTNotebookSelectView*)plm fromNote:(YTNoteEditInfo*)jeg;
-(void)showSettings:(YTSettingsView*)settings;
-(void)showMap:(YTMapSearchView*)mapView;
-(void)settingsChangeTo:(YTBaseView *)neww;
-(void)settingsGoBack;
-(void)dismissPopUpView;
-(void)settingsDismiss;
-(void)showSettingsImagePicker:(UIImagePickerController*)pC;

+ (AppDelegate *)sharedAppDelegate;

@end
