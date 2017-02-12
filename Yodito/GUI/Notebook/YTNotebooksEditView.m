
#import "YTNotebooksEditView.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "AppDelegate.h"

@implementation YTNotebooksEditView

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTViewBackColor;
	
	_cells = [[NSMutableArray alloc] init];
	
	_tableView = [[VLKeyboardTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain dataSource:self delegate:self];
	_tableView.keyboardTableViewDelegate = self;
	[_tableView setTransparentBackground];
	_tableView.allowsSelectionDuringEditing = YES;
	//_tableView.separatorColor = kYTTableSeparatorColor;
	[self addSubview:_tableView];
	if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
		[_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Notebooks {Title}", nil);
	self.customNavBar.btnBack.hidden = NO;
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	self.customNavBar.btnRight.hidden = NO;
	[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Edit {Button}", nil) forState:UIControlStateNormal];
	[self.customNavBar.btnRight addTarget:self action:@selector(onBtnEditTap:) forControlEvents:UIControlEventTouchUpInside];
	//self.customNavBar.btnLeft.hidden = YES;
	//[self.customNavBar.btnLeft setTitle:NSLocalizedString(@"Cancel {Button}", nil) forState:UIControlStateNormal];
	//[self.customNavBar.btnLeft addTarget:self action:@selector(onBtnEditCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	[[YTNotebooksEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	
	[self suspendSliding:YES];
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	YTNotebooksEnManager *manrBooks = [YTNotebooksEnManager shared];
	NSMutableArray *notebooks = [NSMutableArray arrayWithArray:[manrBooks getNotebooks]];
	for(int i = (int)notebooks.count - 1; i >= 0; i--) {
		YTNotebookInfo *notebook = [notebooks objectAtIndex:i];
		if(notebook.deleted)
			[notebooks removeObjectAtIndex:i];
	}
	YTNotebookInfo *mainNotebook = [YTNotebooksEnManager shared].defaultNotebook;
	if(kYTHideDefaultNotebook && mainNotebook)
		[notebooks removeObject:mainNotebook];
	[notebooks sortUsingComparator:^NSComparisonResult(YTNotebookInfo *obj1, YTNotebookInfo *obj2) {
		return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
	}];
	NSMutableArray *newCells = [NSMutableArray array];
	for(int i = 0; i < notebooks.count; i++) {
		YTNotebookInfo *notebook = [notebooks objectAtIndex:i];
		VLTableViewCell *cell = nil;
		for(VLTableViewCell *obj in _cells) {
			YTNotebooksEditView_CellView *view = (YTNotebooksEditView_CellView *)obj.subView;
			if(view.notebook == notebook) {
				cell = obj;
				break;
			}
		}
		if(!cell) {
			YTNotebooksEditView_CellView *view = [[[YTNotebooksEditView_CellView alloc] initWithFrame:CGRectZero] autorelease];
			cell = [[[VLTableViewCell alloc] initWithSubView:view reuseIdentifier:nil] autorelease];
			[cell makeTransparent];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			view.notebook = notebook;
			view.editing = _editing;
			view.textField.delegate = self;
			[view.btnDelete addTarget:self action:@selector(onBtnDeleteTap:) forControlEvents:UIControlEventTouchUpInside];
		}
		[newCells addObject:cell];
	}
	if(![_cells isEqualToArray:newCells]) {
		[_tableView updateRowsWithLastObjects:_cells
								   newObjects:newCells
								resultObjects:_cells
									 animated:_tableReloaded];
		_tableReloaded = YES;
	}
}

- (void)setEditing:(BOOL)editing {
	if(_editing != editing) {
		_editing = editing;
		[VLCtrlsUtils findAndResignFirstResponder:self];
		self.customNavBar.btnRight.alpha = 1.0;
		//self.customNavBar.btnLeft.alpha = _editing ? 0.0 : 1.0;
		//self.customNavBar.btnLeft.hidden = NO;
		//self.customNavBar.btnBack.alpha = _editing ? 1.0 : 0.0;
		//self.customNavBar.btnBack.hidden = NO;
		[UIView animateWithDuration:kDefaultAnimationDuration/4 animations:^{
			self.customNavBar.btnRight.alpha = 0.0;
			//self.customNavBar.btnLeft.alpha = _editing ? 1.0 : 0.0;
			//self.customNavBar.btnBack.alpha = _editing ? 0.0 : 1.0;
		} completion:^(BOOL finished) {
			if(finished) {
				if(!_editing) {
					[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Edit {Button}", nil) forState:UIControlStateNormal];
				} else {
					[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Done {Button}", nil) forState:UIControlStateNormal];
				}
				//self.customNavBar.btnLeft.hidden = !_editing;
				//self.customNavBar.btnBack.hidden = _editing;
				[self.customNavBar layoutSubviews];
				[UIView animateWithDuration:kDefaultAnimationDuration/4 animations:^{
					self.customNavBar.btnRight.alpha = 1.0;
				} completion:^(BOOL finished) {
					if(finished) {
						
					}
				}];
			}
		}];
		for(VLTableViewCell *cell in _cells) {
			YTNotebooksEditView_CellView *view = (YTNotebooksEditView_CellView *)cell.subView;
			[view setEditing:_editing animated:YES];
		}
		[self.customNavBar setNeedsLayout];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	_tableView.frame = rcBnds;
}

- (UIView *)keyboardTableView:(VLKeyboardTableView *)keyboardTableView getFirstResponder:(id)param {
	return [VLCtrlsUtils findFirstResponder:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [_cells objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)onBtnEditTap:(id)sender {
	if(!_editing) {
		[self setEditing:YES];
	} else {
		[self commitBookNamesViewsWithResultBlock:^(BOOL result) {
			if(result) {
				[self setEditing:NO];
			}
		}];
	}
}

- (void)onBtnEditCancelTap:(id)sender {
	if(_editing) {
		[self setEditing:NO];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	YTNotebooksEditView_CellView *view = nil;
	for(VLTableViewCell *cell in _cells) {
		YTNotebooksEditView_CellView *obj = (YTNotebooksEditView_CellView *)cell.subView;
		if(obj.textField == textField) {
			view = obj;
			break;
		}
	}
	if(view) {
		YTNotebookInfo *notebook = view.notebook;
		NSString *newBookName = [view.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if([NSString isEmpty:newBookName]) {
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:NSLocalizedString(@"Please enter notebook name.", nil)];
			view.textField.text = notebook.name;
			return YES;
		}
		if(![newBookName isEqual:notebook.name]) {
			[VLCtrlsUtils findAndResignFirstResponder:self];
			[[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Saving", nil)];
			[[VLMessageCenter shared] performBlock:^{
				[[YTEntitiesManagersLister shared] renameNotebook:notebook withNewName:newBookName resultBlock:^{
					[[VLActivityScreen shared] stopActivity];
				}];
			} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
		}
	}
	return YES;
}

- (void)commitBookNamesViewsWithResultBlock:(VLBlockBool)resultBlock {
	for(VLTableViewCell *cell in _cells) {
		YTNotebooksEditView_CellView *view = (YTNotebooksEditView_CellView *)cell.subView;
		YTNotebookInfo *notebook = view.notebook;
		NSString *newBookName = [view.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if([NSString isEmpty:newBookName]) {
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:NSLocalizedString(@"Please enter notebook name.", nil)];
			view.textField.text = notebook.name;
			[view.textField becomeFirstResponder];
			resultBlock(NO);
			return;
		}
	}
	NSMutableArray *cells = [NSMutableArray arrayWithArray:_cells];
	[[VLMessageCenter shared] performBlock:^{
		[self commitBookNamesViewsWithCells:cells resultBlock:resultBlock];
	} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
}
- (void)commitBookNamesViewsWithCells:(NSMutableArray *)cells resultBlock:(VLBlockBool)resultBlock {
	if(!cells.count) {
		resultBlock(YES);
		return;
	}
	VLTableViewCell *cell = [cells objectAtIndex:0];
	YTNotebooksEditView_CellView *view = (YTNotebooksEditView_CellView *)cell.subView;
	YTNotebookInfo *notebook = view.notebook;
	NSString *newBookName = [view.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if(![newBookName isEqual:notebook.name]) {
		[VLCtrlsUtils findAndResignFirstResponder:self];
		[[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Saving", nil)];
		[[YTEntitiesManagersLister shared] renameNotebook:notebook withNewName:newBookName resultBlock:^{
			[[VLActivityScreen shared] stopActivity];
			[cells removeObjectAtIndex:0];
			[self commitBookNamesViewsWithCells:cells resultBlock:resultBlock];
		}];
	} else {
		[cells removeObjectAtIndex:0];
		[self commitBookNamesViewsWithCells:cells resultBlock:resultBlock];
	}
}

- (void)revertBookNamesViews {
	for(VLTableViewCell *cell in _cells) {
		YTNotebooksEditView_CellView *view = (YTNotebooksEditView_CellView *)cell.subView;
		[view revertBookNameView];
	}
}

- (void)onBtnDeleteTap:(UIButton *)sender {
	YTNotebooksEditView_CellView *view = nil;
	for(VLTableViewCell *cell in _cells) {
		YTNotebooksEditView_CellView *obj = (YTNotebooksEditView_CellView *)cell.subView;
		if(obj.btnDelete == sender) {
			view = obj;
			break;
		}
	}
	if(view) {
		YTNotebookInfo *notebook = view.notebook;
		VLActionSheet *actions = [[[VLActionSheet alloc] init] autorelease];
		[actions addButtonWithTitle:NSLocalizedString(@"Delete {Button}", nil)];
		[actions addButtonWithTitle:NSLocalizedString(@"Cancel {Button}", nil)];
		actions.destructiveButtonIndex = 0;
		actions.cancelButtonIndex = 1;
		[actions showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle) {
			if(btnIndex == 0) {
				[[YTEntitiesManagersLister shared] deleteNotebook:notebook resultBlock:^{
				}];
			}
		}];
	}
}

- (void)onBtnCancelTap:(id)sender {
	if(!_editing) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [[AppDelegate instance]settingsGoBack];
        }
		[self suspendSliding:NO];
		[[self parentContentView] popView:self animated:YES];
		return;
	}
	if([VLCtrlsUtils findFirstResponder:self] || _editing) {
		[VLCtrlsUtils findAndResignFirstResponder:self];
		
		[[VLMessageCenter shared] performBlock:^{
			[self revertBookNamesViews];
			[self setEditing:NO];
			
			[[VLMessageCenter shared] performBlock:^{
				[self suspendSliding:NO];
				[[self parentContentView] popView:self animated:YES];
			} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
			
		} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
		
	} else {
		[self suspendSliding:NO];
		[[self parentContentView] popView:self animated:YES];
	}
}

- (void)dealloc {
	[[YTNotebooksEnManager shared].msgrVersionChanged removeObserver:self];
	[_tableView release];
	[_cells release];
	[super dealloc];
}

@end








@implementation YTNotebooksEditView_CellView

@synthesize notebook = _notebook;
@synthesize editing = _editing;
@synthesize textField = _textField;
@synthesize btnDelete = _btnDelete;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	
	_textField = [[UITextField alloc] initWithFrame:CGRectZero];
	_textField.borderStyle = UITextBorderStyleNone;
	_textField.userInteractionEnabled = NO;
	_textField.font = [[YTFontsManager shared] boldFontWithSize:16 fixed:YES];
	_textField.returnKeyType = UIReturnKeyDone;
	[self addSubview:_textField];
	
	_btnDelete = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_btnDelete setImage:[UIImage imageNamed:@"btn_delete_circled_black.png"] forState:UIControlStateNormal];
	_btnDelete.hidden = YES;
	[self addSubview:_btnDelete];
}

- (void)setNotebook:(YTNotebookInfo *)notebook {
	if(_notebook != notebook) {
		if(_notebook) {
			[_notebook release];
			_notebook = nil;
		}
		if(notebook) {
			_notebook = [notebook retain];
			_textField.text = _notebook.name;
		}
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	if(_editing != editing) {
		_editing = editing;
		_textField.userInteractionEnabled = _editing;
		if(animated) {
			_btnDelete.alpha = _editing ? 0.0 : 1.0;
			_btnDelete.hidden = NO || !kYTAllowDeleteNotebook;
			[UIView animateWithDuration:kDefaultAnimationDuration/2 animations:^{
				_btnDelete.alpha = _editing ? 1.0 : 0.0;
				_textField.borderStyle = _editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
			} completion:^(BOOL finished) {
				if(finished) {
					_btnDelete.hidden = !_editing || !kYTAllowDeleteNotebook;
				}
			}];
		} else {
			_btnDelete.hidden = !_editing || !kYTAllowDeleteNotebook;
			_btnDelete.alpha = 1.0;
			_textField.borderStyle = _editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
		}
	}
}

- (void)setEditing:(BOOL)editing {
	[self setEditing:editing animated:NO];
}

- (void)revertBookNameView {
	if(_notebook) {
		_textField.text = _notebook.name;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	float padX = 18.0;
	float padY = 4.0;
	CGRect rcBtn = rcBnds;
	rcBtn.size.width = (kYTAllowDeleteNotebook ? rcBtn.size.height : 0);
	rcBtn.origin.x = CGRectGetMaxX(rcBnds) - rcBtn.size.width;
	CGRect rcText = rcBnds;
	rcText.origin.x += padX;
	rcText.size.width = rcBtn.origin.x - padX - rcText.origin.x;
	rcText.origin.y += padY;
	rcText.size.height -= padY * 2;
	_textField.frame = rcText;
	_btnDelete.frame = rcBtn;
}

- (void)dealloc {
	[_textField release];
	[_btnDelete release];
	[_notebook release];
	[super dealloc];
}

@end



