
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@interface YTForgotPasswordView : YTBaseView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
@private
	UITableView *_tableView;
	NSMutableArray *_allCells;
	VLTableSectionHeader *_headerInfo;
	VLSettingsTableCell *_cellEmail;
	BOOL _done;
	VLTableSectionHeader *_headerInfoDone1;
	VLTableSectionHeader *_headerInfoDone2;
}

@end

