
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"
#import "YTSyncTableViewCell.h"

@class YTSettingsView_HeaderCopyright;

@interface YTSettingsView : YTBaseView <UITableViewDataSource, UITableViewDelegate> {
@private
	UITableView *_tableView;
	NSMutableArray *_allCells;
	NSMutableArray *_cellsSections;
	VLTableSectionHeader *_headerSync;
	VLTableViewCell *_cellAccountInfo;
	VLTableViewCell *_cellLogin;
	VLTableViewCell *_cellRegister;
	VLTableViewCell *_cellLastSyncDate;
	BOOL _show_cellLastSyncDate;
	UIView *_overlaySepLSD1;
	UIView *_overlaySepLSD2;
	YTSyncTableViewCell *_cellSync;
	VLTableViewCell *_cellNotebooks;
	VLSettingsTableCell *_cellAutoAddNoteLocation;
	VLSettingsTableCell *_cellSaveToCameraRoll;
	VLSettingsTableCell *_cellSyncOnWiFiOnly;
	VLTableViewCell *_cellChooseWallpaper;
	VLSettingsTableCell *_cellRateApp;
	VLSettingsTableCell *_cellReportProblem;
	YTSettingsView_HeaderCopyright *_headerCopyright;
}

@end


@interface YTSettingsView_HeaderCopyright : VLTableSectionHeader {
@private
	NSString *_textCopyright1;
	NSString *_textCopyright2;
	UIView *_overlaySepCopyright;
}

- (CGSize)sizeThatFits:(CGSize)size;

@end


