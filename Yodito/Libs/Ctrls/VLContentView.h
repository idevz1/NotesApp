
#import <Foundation/Foundation.h>
#import "VLBaseView.h"

@class VLTimer;

/**
 Helps keep controls properly aligned, especially on iOS7
 */
@interface VLContentView : VLBaseView {
@private
	CGRect _rectContent;
}

@property(nonatomic, readonly) CGRect rectContent;

@end



/**
 Fix tabbarcontroller 'more' tab on iOS7
 */
@interface VLTabBarControllerMoreTabFixer : NSObject {
@private
	UITabBarController *_tabBarControllerRef;
	UITableView *_tableViewRegisteredForFrameChange;
	VLTimer *_timer;
}

- (id)initWithTabBarController:(UITabBarController *)tabBarController;

@end



/**
 Fix UITableView on iOS7
 */
@interface VLTableViewFixer : NSObject {
@private
	UITableView *_tableView;
}

- (id)initWithTableView:(UITableView *)tableView;

@end


