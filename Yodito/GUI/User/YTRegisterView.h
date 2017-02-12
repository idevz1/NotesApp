
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@interface YTRegisterView : YTBaseView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,
	VLKeyboardScrollView_ContainerViewDelegate> {
@private
	VLKeyboardScrollView *_scrollableView;
	VLKeyboardScrollView_ContainerView *_scrollableViewContainer;
	UITableView *_tableView;
	NSMutableArray *_allCells;
	NSMutableArray *_cellsSections;
	VLTableSectionHeader *_headerInfo;
	VLSettingsTableCell *_cellFirstName;
	VLSettingsTableCell *_cellLastName;
	VLSettingsTableCell *_cellEmail;
	VLSettingsTableCell *_cellPassword;
	VLTableViewCell *_cellCreateAccount;
	BOOL _closed;
}

@end

