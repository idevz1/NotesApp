
#import "YTRegisterView.h"
#import "../Main/Classes.h"
#import "AppDelegate.h"
#define kCellValueWidthWeight 1.0;//0.675

@implementation YTRegisterView

- (VLSettingsTableCell *)newCell {
	VLSettingsTableCell *cell = [[VLSettingsTableCell alloc] initWithView:[[VLSettingsCellView new] autorelease] reuseIdentifier:nil];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.view.valueWidthWeight = kCellValueWidthWeight;
	return cell;
}

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTSettingsViewBackColor;
	_allCells = [[NSMutableArray alloc] init];
	_cellsSections = [[NSMutableArray alloc] init];
	
	_scrollableView = [[VLKeyboardScrollView alloc] initWithFrame:CGRectZero];
	[self addSubview:_scrollableView];
	_scrollableViewContainer = [[VLKeyboardScrollView_ContainerView alloc] initWithFrame:CGRectZero];
	_scrollableViewContainer.delegate = self;
	[_scrollableView addSubview:_scrollableViewContainer];
	
	_headerInfo = [[VLTableSectionHeader alloc] initWithFrame:CGRectZero];
	_headerInfo.label.numberOfLines = 0;
	_headerInfo.label.text = NSLocalizedString(@"An account lets you sync your notes across iPhone and Mac and provides secure cloud backup", nil);
	_headerInfo.label.textAlignment = NSTextAlignmentCenter;
	
	_cellFirstName = [self newCell];
	//_cellFirstName.view.label.text = NSLocalizedString(@"First Name", nil);
	_cellFirstName.view.textField.autocorrectionType = UITextAutocorrectionTypeNo;
	_cellFirstName.view.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	_cellFirstName.view.textField.placeholder = NSLocalizedString(@"First Name", nil);//@"John";
	_cellFirstName.view.textField.delegate = self;
	_cellFirstName.view.textField.returnKeyType = UIReturnKeyNext;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateView)
												 name:UITextFieldTextDidChangeNotification object:_cellFirstName.view.textField];
	[_allCells addObject:_cellFirstName];
	
	_cellLastName = [self newCell];
	//_cellLastName.view.label.text = NSLocalizedString(@"Last Name", nil);
	_cellLastName.view.textField.autocorrectionType = UITextAutocorrectionTypeNo;
	_cellLastName.view.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	_cellLastName.view.textField.placeholder = NSLocalizedString(@"Last Name", nil);//@"Smith";
	_cellLastName.view.textField.delegate = self;
	_cellLastName.view.textField.returnKeyType = UIReturnKeyNext;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateView)
												 name:UITextFieldTextDidChangeNotification object:_cellLastName.view.textField];
	[_allCells addObject:_cellLastName];
	
	_cellEmail = [self newCell];
	//_cellEmail.view.label.text = NSLocalizedString(@"Email", nil);
	_cellEmail.view.textField.autocorrectionType = UITextAutocorrectionTypeNo;
	_cellEmail.view.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_cellEmail.view.textField.keyboardType = UIKeyboardTypeEmailAddress;
	_cellEmail.view.textField.placeholder = NSLocalizedString(@"Email", nil);//@"john.smith@goodtimes.com";
	_cellEmail.view.textField.delegate = self;
	_cellEmail.view.textField.returnKeyType = UIReturnKeyNext;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateView)
												 name:UITextFieldTextDidChangeNotification object:_cellEmail.view.textField];
	[_allCells addObject:_cellEmail];
	
	_cellPassword = [self newCell];
	//_cellPassword.view.label.text = NSLocalizedString(@"Password", nil);
	_cellPassword.view.textField.secureTextEntry = YES;
	_cellPassword.view.textField.placeholder = NSLocalizedString(@"Password", nil);//@"********";
	_cellPassword.view.textField.delegate = self;
	_cellPassword.view.textField.returnKeyType = UIReturnKeyDone;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateView)
												 name:UITextFieldTextDidChangeNotification object:_cellPassword.view.textField];
	[_allCells addObject:_cellPassword];
	
	_cellFirstName.view.horizontalControlsDistance = _cellLastName.view.horizontalControlsDistance = 
		_cellEmail.view.horizontalControlsDistance = _cellPassword.view.horizontalControlsDistance = 4;
	
	_cellFirstName.view.textField.textColor = _cellLastName.view.textField.textColor =
		_cellEmail.view.textField.textColor = _cellPassword.view.textField.textColor = [UIColor colorWithRed:0x20/255.0 green:0x16/255.0 blue:0x20/255.0 alpha:1.0];
	
	_cellCreateAccount = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_cellCreateAccount.textLabel.text = NSLocalizedString(@"Create Account", nil);
	_cellCreateAccount.textLabel.textAlignment = NSTextAlignmentCenter;
	_cellCreateAccount.textLabel.textColor = kYTLabelsBlueTextColor;
	[_allCells addObject:_cellCreateAccount];
	
	NSMutableArray *curCellsSection = [NSMutableArray array];
	[curCellsSection addObject:_cellFirstName];
	[curCellsSection addObject:_cellLastName];
	[curCellsSection addObject:_cellEmail];
	[curCellsSection addObject:_cellPassword];
	[_cellsSections addObject:curCellsSection];
	
	curCellsSection = [NSMutableArray array];
	[curCellsSection addObject:_cellCreateAccount];
	[_cellsSections addObject:curCellsSection];
	
	UIColor *color = kYTSettingsCellBackColor;
	for(UITableViewCell *cell in _allCells) {
		cell.backgroundColor = color;
		if(cell.contentView) {
			cell.contentView.backgroundColor = color;
			for(UIView *view in cell.contentView.subviews)
				view.backgroundColor = color;
		}
		VLSettingsTableCell *settCell = ObjectCast(cell, VLSettingsTableCell);
		if(settCell) {
			if([settCell.view.textField respondsToSelector:@selector(setTintColor:)])
				settCell.view.textField.tintColor = kYTHeaderBackColor;
			UIEdgeInsets paddings = settCell.view.paddings;
			paddings.left += 8;
			settCell.view.paddings = paddings;
		}
	}
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[_tableView setTransparentBackground];
	_tableView.alwaysBounceVertical = NO;
	if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
		[_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	[_scrollableViewContainer addSubview:_tableView];
	
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Create Account", nil);
	self.customNavBar.btnBack.hidden = NO;
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnBackTap:) forControlEvents:UIControlEventTouchUpInside];
	
	[_scrollableView initializeScrollingFromNib:NO];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[[YTUsersEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	
	[self suspendSliding:YES];
	[self updateViewAsync];
}

- (void)updateFonts:(id)sender {
	self.customNavBar.titleLabel.font = [[YTFontsManager shared] boldFontWithSize:17 fixed:YES];
	_headerInfo.label.font = [[YTFontsManager shared] lightFontWithSize:15 fixed:YES];
	_cellFirstName.view.label.font = _cellLastName.view.label.font =
		_cellEmail.view.label.font = _cellPassword.view.label.font = [[YTFontsManager shared] fontTableCellLabelBold];
	_cellFirstName.view.textField.font = _cellLastName.view.textField.font =
		_cellEmail.view.textField.font = _cellPassword.view.textField.font = [[YTFontsManager shared] fontWithSize:18 fixed:YES];
	_cellCreateAccount.textLabel.font = [[YTFontsManager shared] fontTableCellLabelBig];
	[self setNeedsLayout];
}

- (void)onUpdateView {
	[super onUpdateView];
	YTUsersEnManager *manrUser = [YTUsersEnManager shared];
	if(manrUser.isLoggedIn && !manrUser.isDemo) { // Already logged in as nondemo user
		if(!_closed) {
			_closed = YES;
			[self suspendSliding:NO];
			[[self parentContentView] popView:self animated:YES];
		}
	}
	if(_cellFirstName.view.textField.text.length && _cellLastName.view.textField.text.length
	   && _cellEmail.view.textField.text.length && _cellPassword.view.textField.text.length) {
		_cellCreateAccount.userInteractionEnabled = YES;
		_cellCreateAccount.textLabel.textColor = kYTLabelsBlueTextColor;
		[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
	} else {
		_cellCreateAccount.userInteractionEnabled = NO;
		_cellCreateAccount.textLabel.textColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
		[_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO];
	}
}

- (void)onBtnBackTap:(id)sender {

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [[AppDelegate instance]settingsGoBack];
    }
    else{
	[self suspendSliding:NO];
        [[self parentContentView] popView:self animated:YES];}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	_scrollableView.frame = rcBnds;
}

- (void)VLKeyboardScrollView_ContainerView_layoutSubviews:(VLKeyboardScrollView_ContainerView*)view {
	CGRect rcBnds = view.bounds;
	CGRect rcTable = rcBnds;
	_tableView.frame = rcTable;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	scrollView.contentOffset = CGPointZero;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _cellsSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *cells = [_cellsSections objectAtIndex:section];
	return cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *cells = [_cellsSections objectAtIndex:indexPath.section];
	return [cells objectAtIndex:indexPath.row];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return _headerInfo;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	UIView *header = [self tableView:tableView viewForHeaderInSection:section];
	if(header) {
		return (int)([header sizeThatFits:_tableView.bounds.size].height * 1.5);
	}
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSArray *cells = [_cellsSections objectAtIndex:indexPath.section];
	UITableViewCell *cell = [cells objectAtIndex:indexPath.row];
	if(cell == _cellCreateAccount)
		[self performRegister];
}

- (void)performRegister {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	
	NSString *firstName = _cellFirstName.view.textField.text;
	NSString *lastName = _cellLastName.view.textField.text;
	NSString *email = _cellEmail.view.textField.text;
	NSString *password = _cellPassword.view.textField.text;
	NSString *error = nil;
	if([NSString isEmpty:firstName])
		error = NSLocalizedString(@"Please enter First Name.", nil);
	else if([NSString isEmpty:lastName])
		error = NSLocalizedString(@"Please enter Last Name.", nil);
	else if([NSString isEmpty:email] || ![email validateAsEmail])
		error = NSLocalizedString(@"Please enter a valid email address.", nil);
	else if([NSString isEmpty:password])
		error = NSLocalizedString(@"Please enter Password.", nil);
	if(![NSString isEmpty:error]) {
		[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil)
                                message:error];
		return;
    }
	[[YTUsersEnManager shared] registerWithFirstName:firstName
										  lastName:lastName
											 email:email
										  password:password
									   resultBlock:^(NSError *error)
	{
		if(error) {
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Registration Failed", nil)
									message:[error localizedDescription]];
			return;
		} else {
			[self onBtnBackTap:self];
		}
	}];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == _cellFirstName.view.textField) {
		[_cellLastName.view.textField becomeFirstResponder];
	} if(textField == _cellLastName.view.textField) {
		[_cellEmail.view.textField becomeFirstResponder];
	} if(textField == _cellEmail.view.textField) {
		[_cellPassword.view.textField becomeFirstResponder];
	} else if(textField == _cellPassword.view.textField) {
		[VLCtrlsUtils findAndResignFirstResponder:self];
	}
	return NO;
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTUsersEnManager shared].msgrVersionChanged removeObserver:self];
	[_scrollableView release];
	[_scrollableViewContainer release];
	[_tableView release];
	[_allCells release];
	[_cellsSections release];
	[_headerInfo release];
	[_cellFirstName release];
	[_cellLastName release];
	[_cellEmail release];
	[_cellPassword release];
	[_cellCreateAccount release];
	[super dealloc];
}

@end

