
#import "YTForgotPasswordView.h"

#define kCellValueWidthWeight 1.0//0.7

@implementation YTForgotPasswordView

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTSettingsViewBackColor;
	_allCells = [[NSMutableArray alloc] init];
	
	_headerInfo = [[VLTableSectionHeader alloc] initWithFrame:CGRectZero];
	// TODO: localize later
	//_headerInfo.label.text = NSLocalizedString(@"Enter your email address and we'll send you instructions to reset your password", nil);
	_headerInfo.label.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Reset Password", nil)];
	
	_headerInfoDone1 = [[VLTableSectionHeader alloc] initWithFrame:CGRectZero];
	_headerInfoDone1.label.text = NSLocalizedString(@"Reset password instructions sent", nil);
	
	_headerInfoDone2 = [[VLTableSectionHeader alloc] initWithFrame:CGRectZero];
	_headerInfoDone2.label.text = NSLocalizedString(@"Please check your email and follow the instructions to reset your password", nil);
	
	for(VLTableSectionHeader *header in [NSArray arrayWithObjects:_headerInfo, _headerInfoDone1, _headerInfoDone2, nil]) {
		header.label.numberOfLines = 0;
		header.label.textAlignment = NSTextAlignmentCenter;
		header.label.font = [[YTFontsManager shared] lightFontWithSize:16 fixed:YES];
	}
	_headerInfoDone1.label.font = _headerInfoDone2.label.font = [[YTFontsManager shared] lightFontWithSize:16 fixed:YES];
	
	_cellEmail = [[VLSettingsTableCell alloc] initWithView:[[[VLSettingsCellView alloc] initWithFrame:CGRectZero] autorelease] reuseIdentifier:nil];
	_cellEmail.view.valueWidthWeight = kCellValueWidthWeight;
	_cellEmail.selectionStyle = UITableViewCellSelectionStyleNone;
	//_cellEmail.view.label.text = NSLocalizedString(@"Email", nil);
	_cellEmail.view.textField.autocorrectionType = UITextAutocorrectionTypeNo;
	_cellEmail.view.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_cellEmail.view.textField.keyboardType = UIKeyboardTypeEmailAddress;
	_cellEmail.view.textField.placeholder = NSLocalizedString(@"Email", nil);
	_cellEmail.view.textField.delegate = self;
	_cellEmail.view.textField.returnKeyType = UIReturnKeySend;
	if([_cellEmail.view.textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
		UIColor *color = [UIColor colorWithRed:89/255.0 green:121/255.0 blue:151/255.0 alpha:1.0];
		_cellEmail.view.textField.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:_cellEmail.view.textField.placeholder
					attributes:@{NSForegroundColorAttributeName: color}] autorelease];
	}
	if([_cellEmail.view.textField respondsToSelector:@selector(setTintColor:)])
		_cellEmail.view.textField.tintColor = kYTHeaderBackColor;
	UIEdgeInsets paddings = _cellEmail.view.paddings;
	paddings.left += 8;
	_cellEmail.view.paddings = paddings;
	[_allCells addObject:_cellEmail];
	
	UIColor *color = kYTSettingsCellBackColor;
	for(UITableViewCell *cell in _allCells) {
		cell.backgroundColor = color;
		if(cell.contentView) {
			cell.contentView.backgroundColor = color;
			for(UIView *view in cell.contentView.subviews)
				view.backgroundColor = color;
		}
	}
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[_tableView setTransparentBackground];
	_tableView.alwaysBounceVertical = NO;
	if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
		[_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	[self addSubview:_tableView];
	
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Forgot Password", nil);
	self.customNavBar.btnBack.hidden = NO;
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnBackTap:) forControlEvents:UIControlEventTouchUpInside];
	self.customNavBar.titleLabel.font = [[YTFontsManager shared] boldFontWithSize:17 fixed:YES];
	
	[self suspendSliding:YES];
	[self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	_tableView.frame = rcBnds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return _cellEmail;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(_done)
		return _headerInfoDone1;
	return _headerInfo;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	UIView *header = [self tableView:tableView viewForHeaderInSection:section];
	if(header)
		return (int)([header sizeThatFits:_tableView.bounds.size].height * (_done ? 1.75 : 1.5));
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if(_done)
		return _headerInfoDone2;
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	UIView *header = [self tableView:tableView viewForFooterInSection:section];
	if(header)
		return (int)([header sizeThatFits:_tableView.bounds.size].height * (_done ? 1.4 : 1.5));
	return 0;
}

- (BOOL)validateInput {
	NSString *email = _cellEmail.view.textField.text;
	NSString *error = nil;
	if([NSString isEmpty:email] || ![email validateAsEmail])
		error = NSLocalizedString(@"Please enter a valid email address.", nil);
	if(![NSString isEmpty:error]) {
		[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil)
                                message:error];
		return NO;
    }
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(![self validateInput])
		return NO;
	NSString *email = _cellEmail.view.textField.text;
	[VLCtrlsUtils findAndResignFirstResponder:self];
	[[VLActivityScreen shared] startActivityWithTitle:nil];
	[[YTUsersEnManager shared] startRestoreForgottenPasswordWithEmail:email resultBlock:^(NSError *error) {
		[[VLActivityScreen shared] stopActivity];
		if(!error) {
			//[self onBtnBackTap:self];
			[self setDone];
			return;
		}
	}];
	return NO;
}

- (void)setDone {
	if(!_done) {
		_done = YES;
		_cellEmail.userInteractionEnabled = NO;
		[_tableView reloadData];
	}
}

- (void)onBtnBackTap:(id)sender {
	[self suspendSliding:NO];
	[[self parentContentView] popView:self animated:YES];
}

- (void)dealloc {
	[_tableView release];
	[_allCells release];
	[_headerInfo release];
	[_cellEmail release];
	[_headerInfoDone1 release];
	[_headerInfoDone2 release];
	[super dealloc];
}

@end

