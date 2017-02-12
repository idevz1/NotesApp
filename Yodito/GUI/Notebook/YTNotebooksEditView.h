
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@interface YTNotebooksEditView : YTBaseView <UITableViewDataSource, UITableViewDelegate, VLKeyboardTableViewDelegate,
	UITextFieldDelegate> {
@private
	VLKeyboardTableView *_tableView;
	NSMutableArray *_cells;
	BOOL _tableReloaded;
	BOOL _editing;
}

@end





@interface YTNotebooksEditView_CellView : YTBaseView {
@private
	UITextField *_textField;
	UIButton *_btnDelete;
	YTNotebookInfo *_notebook;
	BOOL _editing;
}

@property(nonatomic, assign) YTNotebookInfo *notebook;
@property(nonatomic, assign) BOOL editing;
@property(nonatomic, readonly) UITextField *textField;
@property(nonatomic, readonly) UIButton *btnDelete;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)revertBookNameView;

@end


