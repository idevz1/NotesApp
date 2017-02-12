
#import "YTNotebookSelectView.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "AppDelegate.h"
#define kCellTextColor [UIColor colorWithWhite:24/255.0 alpha:1.0]
#define kCellSeparatorHeight 10.0

@interface YTNotebookSelectView_Cell : VLTableViewCell {
@private
}

@property(nonatomic, retain) YTNotebookInfo *notebook;

@end

@implementation YTNotebookSelectView_Cell

@synthesize notebook;

- (id)init {
	self = [super init];
	if(self) {
		[self makeTransparent];
	}
	return self;
}

@end




@interface YTNotebookSelectView_CellSeparator : YTNotebookSelectView_Cell {
@private
}

@end

@implementation YTNotebookSelectView_CellSeparator

- (id)init {
	self = [super init];
	if(self) {
		self.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
		if(self.contentView)
			self.contentView.backgroundColor = self.backgroundColor;
		if(self.backgroundView)
			self.backgroundView.backgroundColor = self.backgroundColor;
		if(self.selectedBackgroundView)
			self.selectedBackgroundView.backgroundColor = self.backgroundColor;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return self;
}

@end




@interface YTNotebookSelectView_SearchOverlayView : YTBaseView {
@private
}

@end

@implementation YTNotebookSelectView_SearchOverlayView

- (void)initialize {
	[super initialize];
	self.opaque = NO;
	//self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
	//self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return nil;
}

@end




@implementation YTNotebookSelectView

@synthesize curNotebookGuid = _curNotebookGuid;
@synthesize delegate = _delegate;

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTViewBackColor;
	
	_curNotebookGuid = [@"" retain];
	
	_tableSearchBar = [[YTTableSearchBar alloc] initWithFrame:CGRectZero];
	_tableSearchBar.delegate = self;
	_tableSearchBar.placeholder = NSLocalizedString(@"Find or create notebook", nil);
	_tableSearchBar.alwaysShowPlaceholder = YES;
	[self addSubview:_tableSearchBar];
	
	_rowsNotebooks = [[NSMutableArray alloc] init];
	
	_cellNewNotebook = [[YTNotebookSelectView_Cell alloc] init];
	_cellNewNotebook.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_add_circled_filled_blue.png"]] autorelease];
	
	_cellSeparator = [[YTNotebookSelectView_CellSeparator alloc] init];
	
	_searchOverlayView = [[YTNotebookSelectView_SearchOverlayView alloc] initWithFrame:CGRectZero];
	_searchOverlayView.alpha = 0.0;
	[self addSubview:_searchOverlayView];
	
	_tableView = [[VLKeyboardTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain dataSource:self delegate:self];
	_tableView.keyboardTableViewDelegate = self;
	[_tableView setTransparentBackground];
	//_tableView.editing = YES;
	_tableView.allowsSelectionDuringEditing = YES;
	//_tableView.separatorColor = kYTTableSeparatorColor;
	[self addSubview:_tableView];
	if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
		[_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	
	_searchText = [@"" retain];
	
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Notebooks {Title}", nil);
	self.customNavBar.btnBack.hidden = NO;
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[[YTUiMediator shared].msgrVersionChanged addObserver:self selector:@selector(onUiMediatorChanged:)];
	[self updateViewAsync];
}

- (void)updateFonts:(id)sender {
	NSMutableArray *allCells = [NSMutableArray array];
	[allCells addObjectsFromArray:_rowsNotebooks];
	[allCells addObject:_cellNewNotebook];
	for(YTNotebookSelectView_Cell *cell in allCells) {
		cell.textLabel.font = [[YTFontsManager shared] fontWithSize:16 fixed:YES];
	}
	[self setNeedsLayout];
}

- (void)updateTable {
	NSMutableArray *curNotebooks = [NSMutableArray array];
	NSMutableArray *notebooks = [NSMutableArray arrayWithArray:[[YTNotebooksEnManager shared] getNotebooks]];
	YTNotebookInfo *mainNotebook = [YTNotebooksEnManager shared].defaultNotebook;
	if(kYTHideDefaultNotebook && mainNotebook)
		[notebooks removeObject:mainNotebook];
	[notebooks sortUsingComparator:^NSComparisonResult(YTNotebookInfo *obj1, YTNotebookInfo *obj2) {
		if([obj1.notebookGuid isEqual:_curNotebookGuid])
			return -1;
		if([obj2.notebookGuid isEqual:_curNotebookGuid])
			return 1;
		return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
	}];
	for(YTNotebookInfo *notebook in notebooks) {
		if([NSString isEmpty:_searchText])
			[curNotebooks addObject:notebook];
		else if([notebook.name rangeOfString:_searchText options:NSCaseInsensitiveSearch].length)
			[curNotebooks addObject:notebook];
	}
	NSMutableArray *rowsNotebooks = [NSMutableArray array];
	if(_isSearching && ![NSString isEmpty:_searchText]) {
		[rowsNotebooks addObject:_cellNewNotebook];
		[rowsNotebooks addObject:_cellSeparator];
	}
	for(YTNotebookInfo *notebook in curNotebooks) {
		YTNotebookSelectView_Cell *cell = nil;
		for(YTNotebookSelectView_Cell *obj in _rowsNotebooks)
			if(obj.notebook == notebook)
				cell = obj;
		if(!cell) {
			cell = [[[YTNotebookSelectView_Cell alloc] init] autorelease];
			cell.notebook = notebook;
			cell.textLabel.textColor = kCellTextColor;
		}
		[rowsNotebooks addObject:cell];
	}
	for(YTNotebookSelectView_Cell *cell in rowsNotebooks)
		if(cell.notebook)
			cell.textLabel.text = cell.notebook.name;
	_cellNewNotebook.textLabel.text = _searchText;
	
	if(![_rowsNotebooks isEqualToArray:rowsNotebooks] && !_closing) {
		[_tableView updateRowsWithLastObjects:_rowsNotebooks
								   newObjects:rowsNotebooks
								resultObjects:_rowsNotebooks
									 animated:_cellsLoaded];
		_cellsLoaded = YES;
		[self updateFonts:self];
	}
	NSMutableArray *allCellsBooks = [NSMutableArray array];
	[allCellsBooks addObjectsFromArray:rowsNotebooks];
	for(YTNotebookSelectView_Cell *cell in allCellsBooks) {
		if(cell.notebook) {
			if([cell.notebook.notebookGuid isEqual:_curNotebookGuid]) {
				if(!cell.accessoryView)
					cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_check_mark.png"]] autorelease];
			} else {
				cell.accessoryView = nil;
			}
		}
		cell.editingAccessoryView = cell.accessoryView;
	}
	BOOL needShowTable = !_isSearching || (_rowsNotebooks.count > 0);
	BOOL tableShown = (_tableView.alpha == 1.0);
	if(needShowTable != tableShown) {
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			_tableView.alpha = needShowTable ? 1.0 : 0.0;
		}];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	[self updateTable];
}

- (void)setCurNotebookGuid:(NSString *)curNotebookGuid {
	if(!curNotebookGuid)
		curNotebookGuid = @"";
	if(![_curNotebookGuid isEqual:curNotebookGuid]) {
		[_curNotebookGuid release];
		_curNotebookGuid = [curNotebookGuid copy];
		[self updateViewAsync];
	}
}

- (void)onUiMediatorChanged:(id)sender {
	[self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	CGRect rcSearch = rcBnds;
	rcSearch.size.height = [_tableSearchBar sizeThatFits:rcSearch.size].height;
	if(_tableSearchBar.hidden)
		rcSearch.size.height = 0;
	
	CGRect rcTable = rcBnds;
	rcTable.origin.y = CGRectGetMaxY(rcSearch);
	rcTable.size.height = CGRectGetMaxY(rcBnds) - rcTable.origin.y;
	_tableSearchBar.frame = [UIScreen roundRect:rcSearch];
	_tableView.frame = [UIScreen roundRect:rcTable];
	CGRect rcSerOver = _tableView.frame;
	_searchOverlayView.frame = rcSerOver;
}

- (void)setSearchText:(NSString *)searchText {
	if(!searchText)
		searchText = @"";
	if(![_searchText isEqual:searchText]) {
		[_searchText release];
		_searchText = [searchText copy];
		[self updateIsSearching];
		[self updateViewAsync];
	}
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchButtonTapped:(id)param {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	[self setSearchText:_tableSearchBar.searchText];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar cancelButtonTapped:(id)param {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	[_tableSearchBar cancelSearching];
	[self setSearchText:@""];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchTextChanged:(NSString *)searchText {
	[self setSearchText:searchText];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchStarted:(id)param {
	_searchBarEditing = YES;
	[self updateIsSearching];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchEnded:(id)param {
	_searchBarEditing = NO;
	[self updateIsSearching];
}

- (NSIndexPath *)cellIndexPathByNotebook:(YTNotebookInfo *)notebook {
	if(!notebook)
		return nil;
	for(YTNotebookSelectView_Cell *cell in _rowsNotebooks)
		if(cell.notebook == notebook)
			return [NSIndexPath indexPathForRow:[_rowsNotebooks indexOfObject:cell] inSection:1];
	return nil;
}

- (YTNotebookSelectView_Cell *)cellByNotebook:(YTNotebookInfo *)notebook {
	if(!notebook)
		return nil;
	for(YTNotebookSelectView_Cell *cell in _rowsNotebooks)
		if(cell.notebook == notebook)
			return cell;
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _rowsNotebooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	YTNotebookSelectView_Cell *cell = [_rowsNotebooks objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	YTNotebookSelectView_Cell *cell = [_rowsNotebooks objectAtIndex:indexPath.row];
	if(cell == _cellNewNotebook) {
		NSString *newBookName = [_searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if([NSString isEmpty:newBookName]) {
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:NSLocalizedString(@"Please enter notebook name.", nil)];
			return;
		}
		YTNotebookInfo *newNotebook = [[[YTNotebookInfo alloc] init] autorelease];
		newNotebook.name = newBookName;
		newNotebook.notebookGuid = [[VLGuid makeUnique] yoditoToString];
		newNotebook.stackId = [[YTUiMediator shared] mainStack].stackId;
		// Find Color ID
		int64_t colorId = 0;
		for(YTNotebookInfo *obj in [[YTNotebooksEnManager shared] getNotebooks]) {
			if(obj.colorId) {
				colorId = obj.colorId;
				break;
			}
		}
		newNotebook.colorId = colorId;
		[self setIsSearching:NO];
		[self setSearchText:@""];
		[[VLActivityScreen shared] startActivity];
		[[YTEntitiesManagersLister shared] addNewNotebook:newNotebook resultBlock:^
		{
			[[VLActivityScreen shared] stopActivity];
			[self updateViewNow];
			NSIndexPath *path = [self cellIndexPathByNotebook:newNotebook];
			if(path)
				[_tableView flashRow:path];
			_closing = YES;
			[self selectNotebook:newNotebook];
			[[VLMessageCenter shared] performBlock:^{
				[self onBtnDoneTap:self];
			} afterDelay:kDefaultAnimationDuration*2 ignoringTouches:YES];
		}];
	} else if(cell.notebook) {
		if(kYTHideDefaultNotebook && cell.accessoryView) {
			YTNotebookInfo *mainNotebook = [YTNotebooksEnManager shared].defaultNotebook;
			if(mainNotebook) {
				_closing = YES;
				[self selectNotebook:mainNotebook];
				[[VLMessageCenter shared] performBlock:^{
					[self onBtnDoneTap:self];
				} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
			}
		} else {
			_closing = YES;
			[self selectNotebook:cell.notebook];
			[[VLMessageCenter shared] performBlock:^{
				[self onBtnDoneTap:self];
			} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
		}
	}

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([self tableView:tableView editingStyleForRowAtIndexPath:indexPath] != UITableViewCellEditingStyleNone);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
			forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [_rowsNotebooks objectAtIndex:indexPath.row];
	if(cell == _cellSeparator)
		return kCellSeparatorHeight;
	return _tableView.rowHeight;
}

- (void)selectNotebook:(YTNotebookInfo *)notebook {
	self.curNotebookGuid = notebook.notebookGuid;
}

- (void)onBtnCancelTap:(id)sender {
	if(_delegate)
		[_delegate notebookSelectView:self finishWithAction:EYTUserActionTypeCancel];
	else
		[[self parentContentView] popView:self animated:YES];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [[AppDelegate instance]dismissPopUpView];
    }

}

- (void)onBtnDoneTap:(id)sender {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        YTNotebookInfo *notebook = [[YTNotebooksEnManager shared] getNotebookByGuid:self.curNotebookGuid];
	
			self.noteEditInfo.noteNew.notebookGuid = notebook.notebookGuid;
        [[AppDelegate instance]dismissPopUpView];
    
    }
    else{
	if(_delegate)
		[_delegate notebookSelectView:self finishWithAction:EYTUserActionTypeDone];
	else
		[[self parentContentView] popView:self animated:YES];
    }
}

- (UIView *)keyboardTableView:(VLKeyboardTableView *)keyboardTableView getFirstResponder:(id)param {
	return [VLCtrlsUtils findFirstResponder:self];
}

- (void)setIsSearching:(BOOL)isSearching {
	if(_isSearching != isSearching) {
		if(!isSearching)
			[VLCtrlsUtils findAndResignFirstResponder:self];
		_searchOverlayView.alpha = _isSearching ? 1 : 0;
		[_tableSearchBar setEditing:isSearching];
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			_isSearching = isSearching;
			_searchOverlayView.alpha = _isSearching ? 1 : 0;
			[self layoutSubviews];
		} completion:^(BOOL finished) {
			if(finished) {
				
			}
		}];
		[self setNavigationBarHidden:_isSearching withStatusBarBackColor:_tableSearchBar.backgroundColor animated:YES];
		[[YTSlidingContainerView shared] suspendSliding:_isSearching];
	}
}

- (void)updateIsSearching {
	[self setIsSearching:_searchBarEditing || ![NSString isEmpty:_searchText]];
}

- (void)beginSearching {
	[_tableSearchBar setEditing:YES];
}

- (void)dealloc {
	_delegate = nil;
	[self setIsSearching:NO];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTUiMediator shared].msgrVersionChanged removeObserver:self];
	[_tableSearchBar release];
	[_searchOverlayView release];
	[_tableView release];
	[_cellNewNotebook release];
	[_cellSeparator release];
	[_rowsNotebooks release];
	[_searchText release];
	[_curNotebookGuid release];
	[super dealloc];
}

@end


