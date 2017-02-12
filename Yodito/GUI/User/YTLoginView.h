
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@interface YTLoginView : YTBaseView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,
	VLKeyboardScrollView_ContainerViewDelegate> {
@private
	VLKeyboardScrollView *_scrollableView;
	VLKeyboardScrollView_ContainerView *_scrollableViewContainer;
	UITableView *_tableView;
	NSMutableArray *_allCells;
	NSMutableArray *_cellsSections;
	VLSettingsTableCell *_cellEmail;
	VLSettingsTableCell *_cellPassword;
	VLTableViewCell *_cellForgotPassword;
	UIView *_overlaySepForgPass;
	VLTableViewCell *_cellLogin;
	BOOL _closed;
}

@end

