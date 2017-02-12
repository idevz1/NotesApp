
#import "YTLoginView.h"
#import "../Main/Classes.h"
#import "YTForgotPasswordView.h"
#import "AppDelegate.h"
#define kCellValueWidthWeight 1.0//0.7
#define kCellForgotPasswordHeight 24.0

@implementation YTLoginView

- (VLSettingsTableCell *)newCellToSection:(int)section {
	VLSettingsTableCell *cell = [[VLSettingsTableCell alloc] initWithView:[[[VLSettingsCellView alloc] initWithFrame:CGRectZero] autorelease] reuseIdentifier:nil];
	cell.view.valueWidthWeight = kCellValueWidthWeight;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	NSMutableArray *cells = nil;
	if(section < _cellsSections.count)
		cells = [_cellsSections objectAtIndex:section];
	else {
		cells = [[[NSMutableArray alloc] init] autorelease];
		[_cellsSections addObject:cells];
	}
	[cells addObject:cell];
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
	
	_cellEmail = [self newCellToSection:0];
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
	
	_cellPassword = [self newCellToSection:0];
	//_cellPassword.view.label.text = NSLocalizedString(@"Password", nil);
	_cellPassword.view.textField.secureTextEntry = YES;
	_cellPassword.view.textField.placeholder = NSLocalizedString(@"Password", nil);//@"********";
	_cellPassword.view.textField.delegate = self;
	_cellPassword.view.textField.returnKeyType = UIReturnKeyDone;
	_cellPassword.view.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateView)
			name:UITextFieldTextDidChangeNotification object:_cellPassword.view.textField];
	[_allCells addObject:_cellPassword];
	
	_cellForgotPassword = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	[_cellForgotPassword makeTransparent];
	_cellForgotPassword.textLabel.text = NSLocalizedString(@"Forgot Password", nil);
	_cellForgotPassword.textLabel.textAlignment = NSTextAlignmentRight;
	_cellForgotPassword.textLabel.textColor = kYTLabelsBlueTextColor;
	NSMutableArray *cells = [_cellsSections lastObject];
	[cells addObject:_cellForgotPassword];
	
	_cellEmail.view.horizontalControlsDistance = _cellPassword.view.horizontalControlsDistance = 4;
	
	_cellEmail.view.textField.textColor = _cellPassword.view.textField.textColor = [UIColor colorWithRed:0x20/255.0 green:0x16/255.0 blue:0x20/255.0 alpha:1.0];
	
	{
		NSMutableArray *cells = nil;
		int section = 1;
		if(section < _cellsSections.count)
			cells = [_cellsSections objectAtIndex:section];
		else {
			cells = [[[NSMutableArray alloc] init] autorelease];
			[_cellsSections addObject:cells];
		}
		_cellLogin = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		[_cellLogin.textLabel centerText];
		_cellLogin.textLabel.text = NSLocalizedString(@"Sign In", nil);
		[cells addObject:_cellLogin];
		[_allCells addObject:_cellLogin];
	}
	
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
	
	_overlaySepForgPass = [[UIView alloc] initWithFrame:CGRectZero];
	_overlaySepForgPass.backgroundColor = self.backgroundColor;
	[_tableView addSubview:_overlaySepForgPass];
	
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Sign In", nil);
	self.customNavBar.btnBack.hidden = NO;
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnBackTap:) forControlEvents:UIControlEventTouchUpInside];
	
	[_scrollableView initializeScrollingFromNib:NO];
	
	[[YTUsersEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[self suspendSliding:YES];
	[self updateViewAsync];
}

- (void)updateFonts:(id)sender {
	self.customNavBar.titleLabel.font = [[YTFontsManager shared] boldFontWithSize:17 fixed:YES];
	_cellEmail.view.label.font = _cellPassword.view.label.font = [[YTFontsManager shared] fontTableCellLabelBold];
	_cellEmail.view.textField.font = _cellPassword.view.textField.font = [[YTFontsManager shared] fontWithSize:18 fixed:YES];
	_cellForgotPassword.textLabel.font = [[YTFontsManager shared] boldFontWithSize:13 fixed:YES];
	_cellLogin.textLabel.font = [[YTFontsManager shared] fontTableCellLabelBig];
	[self setNeedsLayout];
}

- (void)onBtnBackTap:(id)sender {
	[self suspendSliding:NO];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [[AppDelegate instance]settingsGoBack];
    }
    else

	[[self parentContentView] popView:self animated:YES];
}

- (void)onUpdateView {
	[super onUpdateView];
	if(_cellEmail.view.textField.text.length && _cellPassword.view.textField.text.length) {
		_cellLogin.userInteractionEnabled = YES;
		//_cellLogin.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
		//_cellLogin.textLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
		_cellLogin.textLabel.textColor = kYTLabelsBlueTextColor;
		[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
	} else {
		_cellLogin.userInteractionEnabled = NO;
		//_cellLogin.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
		_cellLogin.textLabel.textColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
		[_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO];
	}
	YTUsersEnManager *manrUser = [YTUsersEnManager shared];
	if(manrUser.isLoggedIn && !manrUser.isDemo) {
		if(!_closed) {
			_closed = YES;
			[[self parentContentView] popView:self animated:YES];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == _cellEmail.view.textField) {
		[_cellPassword.view.textField becomeFirstResponder];
	} else if(textField == _cellPassword.view.textField) {
		[VLCtrlsUtils findAndResignFirstResponder:self];
	}
	return NO;
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
	CGRect rcOver = [_cellForgotPassword convertRect:_cellForgotPassword.bounds toView:_overlaySepForgPass.superview];
	rcOver.origin.y = CGRectGetMaxY(rcOver) - 2;
	rcOver.size.height = 4;
	_overlaySepForgPass.frame = rcOver;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	scrollView.contentOffset = CGPointZero;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _cellsSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSMutableArray *cells = [_cellsSections objectAtIndex:section];
	return cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableArray *cells = [_cellsSections objectAtIndex:indexPath.section];
	return [cells objectAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableArray *cells = [_cellsSections objectAtIndex:indexPath.section];
	VLTableViewCell *cell = [cells objectAtIndex:indexPath.row];
	if(cell == _cellForgotPassword) {
		float res = kCellForgotPasswordHeight;
		return res;
	}
	return _tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	VLTableViewCell *cell = (VLTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	if(cell == _cellLogin) {
		[self performLogin];
	} else if(cell == _cellForgotPassword) {
		[_tableView deselectRowAtIndexPath:indexPath animated:YES];
		YTForgotPasswordView *view = [[[YTForgotPasswordView alloc] init] autorelease];
		[[self parentContentView] pushView:view animated:YES];
	} else {
		[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (BOOL)validateInput {
	NSString *email = _cellEmail.view.textField.text;
	NSString *password = _cellPassword.view.textField.text;
	NSString *error = nil;
	if([NSString isEmpty:email] || [NSString isEmpty:password])
		error = NSLocalizedString(@"Please enter your email and password.", nil);
	else if([NSString isEmpty:email] || ![email validateAsEmail])
		error = NSLocalizedString(@"Please enter a valid email address.", nil);
	else if([NSString isEmpty:password])
		error = NSLocalizedString(@"Please enter password.", nil);
	if(![NSString isEmpty:error]) {
		[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Sign In Failed", nil)
                                message:error];
		return NO;
    }
	return YES;
}

- (void)performLogin
{
	[VLCtrlsUtils findAndResignFirstResponder:self];
	if(![self validateInput])
		return;
	NSString *email = _cellEmail.view.textField.text;
	NSString *password = _cellPassword.view.textField.text;
	[[YTUsersEnManager shared] loginWithEmail:email password:password resultBlock:^(NSError *error)
	{
		if(error) {
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Sign In Failed", nil)
									 message:[error localizedDescription]];
			return;
		} else {
			[self onBtnBackTap:self];
		}
	}];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTUsersEnManager shared].msgrVersionChanged removeObserver:self];
	[_scrollableView release];
	[_scrollableViewContainer release];
	[_tableView release];
	[_allCells release];
	[_cellsSections release];
	[_cellEmail release];
	[_cellPassword release];
	[_cellForgotPassword release];
	[_overlaySepForgPass release];
	[_cellLogin release];
	[super dealloc];
}

@end

