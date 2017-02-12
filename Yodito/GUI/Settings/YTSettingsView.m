
#import "YTSettingsView.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "AppDelegate.h"
#define kShowClearDataButton NO//YES

@implementation YTSettingsView

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTSettingsViewBackColor;
	
	_allCells = [[NSMutableArray alloc] init];
	
	_cellsSections = [[NSMutableArray alloc] init];
	
	_headerSync = [[VLTableSectionHeader alloc] initWithFrame:CGRectZero];
	UIEdgeInsets insets = _headerSync.insets;
	insets.left = 16;
	insets.top = 4;
	_headerSync.insets = insets;
	
	_cellAccountInfo = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_cellAccountInfo.textLabel.text = NSLocalizedString(@"An account lets you sync your notes across iPhone and Mac and provides secure cloud backup", nil);
	_cellAccountInfo.textLabel.textAlignment = NSTextAlignmentCenter;
	_cellAccountInfo.textLabel.numberOfLines = 0;
	_cellAccountInfo.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	_cellAccountInfo.textLabel.textColor = _headerSync.label.textColor;//[UIColor colorWithRed:177/255.0 green:177/255.0 blue:177/255.0 alpha:1.0];
	[_cellAccountInfo makeTransparent];
	[_allCells addObject:_cellAccountInfo];
	
	_cellLogin = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_cellLogin.textLabel.text = NSLocalizedString(@"Sign In - Available Soon", nil);
    _cellLogin.textLabel.textColor = [UIColor grayColor];
	_cellLogin.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[_allCells addObject:_cellLogin];
    _cellLogin.userInteractionEnabled = NO;
	
	_cellRegister = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_cellRegister.textLabel.text = NSLocalizedString(@"Create Account - Available Soon", nil);
    _cellRegister.textLabel.textColor = [UIColor grayColor];
	_cellRegister.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[_allCells addObject:_cellRegister];
    _cellRegister.userInteractionEnabled = NO;
	
	_cellLastSyncDate = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	[_cellLastSyncDate.textLabel centerText];
	_cellLastSyncDate.textLabel.textColor = [UIColor grayColor];
	[_allCells addObject:_cellLastSyncDate];
	
	_cellSync = [[YTSyncTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	[_allCells addObject:_cellSync];
	
	_cellNotebooks = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	_cellNotebooks.textLabel.text = NSLocalizedString(@"Notebooks {Title}", nil);
	_cellNotebooks.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[_allCells addObject:_cellNotebooks];
	
	_cellAutoAddNoteLocation = [VLSettingsTableCell new];
	_cellAutoAddNoteLocation.view.changeLabelsColorsWhenSelectedOrHighlighted = YES;
	_cellAutoAddNoteLocation.view.label.text = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Auto add location", nil)];
	_cellAutoAddNoteLocation.view.switcher.on = NO;
	[_cellAutoAddNoteLocation.view.msgrValueChanged addObserver:self selector:@selector(onCellAutoAddNoteLocationValueChanged:)];
	[_allCells addObject:_cellAutoAddNoteLocation];
	
	_cellSaveToCameraRoll = [VLSettingsTableCell new];
	_cellSaveToCameraRoll.view.changeLabelsColorsWhenSelectedOrHighlighted = YES;
	// TODO: localize later
	_cellSaveToCameraRoll.view.label.text = NSLocalizedString(@"Save to Camera Roll", nil);
	_cellSaveToCameraRoll.view.switcher.on = NO;
	[_cellSaveToCameraRoll.view.msgrValueChanged addObserver:self selector:@selector(onSaveToCameraRollValueChanged:)];
	[_allCells addObject:_cellSaveToCameraRoll];
	
	_cellSyncOnWiFiOnly = [VLSettingsTableCell new];
	_cellSyncOnWiFiOnly.view.changeLabelsColorsWhenSelectedOrHighlighted = YES;
	_cellSyncOnWiFiOnly.view.label.text = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Sync on WiFi only", nil)];
	_cellSyncOnWiFiOnly.view.switcher.on = NO;
	[_cellSyncOnWiFiOnly.view.msgrValueChanged addObserver:self selector:@selector(onSyncOnWiFiOnlyValueChanged:)];
	[_allCells addObject:_cellSyncOnWiFiOnly];
	
	_cellChooseWallpaper = [VLTableViewCell new];
	_cellChooseWallpaper.textLabel.text = NSLocalizedString(@"Choose Wallpaper", nil);
	_cellChooseWallpaper.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[_allCells addObject:_cellChooseWallpaper];
	
	_cellRateApp = [VLSettingsTableCell new];
	_cellRateApp.view.changeLabelsColorsWhenSelectedOrHighlighted = YES;
	_cellRateApp.view.label.text = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Rate on App Store", nil)];
	_cellRateApp.selectionStyle = UITableViewCellSelectionStyleBlue;
	[_allCells addObject:_cellRateApp];
	
	_cellReportProblem = [VLSettingsTableCell new];
	_cellReportProblem.view.changeLabelsColorsWhenSelectedOrHighlighted = YES;
	_cellReportProblem.view.label.text = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Report a problem", nil)];
	_cellReportProblem.selectionStyle = UITableViewCellSelectionStyleBlue;
	[_allCells addObject:_cellReportProblem];
	
	UIColor *color = kYTSettingsCellBackColor;
	for(UITableViewCell *cell in _allCells) {
		if(cell == _cellAccountInfo)
			continue;
		cell.backgroundColor = color;
		if(cell.contentView) {
			cell.contentView.backgroundColor = color;
			for(UIView *view in cell.contentView.subviews)
				view.backgroundColor = color;
		}
	}
	
	_headerCopyright = [[YTSettingsView_HeaderCopyright alloc] initWithFrame:CGRectZero];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[_tableView setTransparentBackground];
	_tableView.alwaysBounceVertical = NO;
	if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
		[_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	_tableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 0.01)] autorelease];
	[self addSubview:_tableView];
	
	_overlaySepLSD1 = [[UIView alloc] initWithFrame:CGRectZero];
	_overlaySepLSD1.backgroundColor = kYTSettingsCellBackColor;
	[_tableView addSubview:_overlaySepLSD1];
	
	_overlaySepLSD2 = [[UIView alloc] initWithFrame:CGRectZero];
	_overlaySepLSD2.backgroundColor = _tableView.separatorColor;
	[_tableView addSubview:_overlaySepLSD2];
	
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Settings {Title}", nil);
	self.customNavBar.btnBack.hidden = NO;
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnBackTap:) forControlEvents:UIControlEventTouchUpInside];
	[self.customNavBar.btnRight addTarget:self action:@selector(onBtnRightTap:) forControlEvents:UIControlEventTouchUpInside];
	self.customNavBar.btnRight.hidden = NO;
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	[[YTSettingsManager shared].msgrVersionChanged addObserver:self selector:@selector(onSettingsManagerChanged:)];
	[[YTUsersEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTSyncManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTNotebooksEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange addObserver:self selector:@selector(updateViewAsync)];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[self updateViewAsync];
	
	[self onSettingsManagerChanged:self];
}

- (void)updateFonts:(id)sender {
	_headerSync.label.font = [[YTFontsManager shared] boldFontWithSize:16 fixed:YES];
	_cellAccountInfo.textLabel.font = [[YTFontsManager shared] lightFontWithSize:15 fixed:YES];
	_cellLogin.textLabel.font = [[YTFontsManager shared] fontTableCellLabel];
	_cellRegister.textLabel.font = [[YTFontsManager shared] fontTableCellLabel];
	_cellLastSyncDate.textLabel.font = [[YTFontsManager shared] fontWithSize:11 fixed:YES];
	_cellSync.textLabel.font = [[YTFontsManager shared] boldFontWithSize:16 fixed:YES];
	_cellNotebooks.textLabel.font = [[YTFontsManager shared] fontTableCellLabel];
	_cellAutoAddNoteLocation.view.label.font = [[YTFontsManager shared] fontTableCellLabel];
	_cellSaveToCameraRoll.view.label.font = [[YTFontsManager shared] fontTableCellLabel];
	_cellSyncOnWiFiOnly.view.label.font = [[YTFontsManager shared] fontTableCellLabel];
	_cellChooseWallpaper.textLabel.font = [[YTFontsManager shared] fontTableCellLabel];
	_cellRateApp.view.label.font = [[YTFontsManager shared] fontTableCellLabel];
	_cellReportProblem.view.label.font = [[YTFontsManager shared] fontTableCellLabel];
	_headerCopyright.label.font = [[YTFontsManager shared] lightFontWithSize:12 fixed:YES];
	self.customNavBar.btnRight.titleLabel.font = [[YTFontsManager shared] lightFontWithSize:18 fixed:YES];
	[self setNeedsLayout];
}

- (void)onUpdateView {
	[super onUpdateView];
	
	YTUsersEnManager *manrUsers = [YTUsersEnManager shared];
	YTSyncManager *manrSync = [YTSyncManager shared];
	YTNotebooksEnManager *manrBooks = [YTNotebooksEnManager shared];
	
	NSString *headerSyncTitle = @"";
	if(manrUsers.isLoggedIn && !manrUsers.isDemo) {
		headerSyncTitle = [NSString stringWithFormat:@"%@ %@", manrUsers.userInfo.firstName, manrUsers.userInfo.lastName];
	} else {
		// TODO: localize later
		//_headerSync.label.text = @"Sync";
		headerSyncTitle = @"";
	}
	if(![_headerSync.label.text isEqual:headerSyncTitle]) {
		_headerSync.label.text = headerSyncTitle;
		[_tableView reloadData];
	}
	
	if(manrUsers.isDemo) {
		if(kShowClearDataButton)
			// TODO: localize later
			[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Clear Data", nil) forState:UIControlStateNormal];
		else
			[self.customNavBar.btnRight setTitle:@"" forState:UIControlStateNormal];
	} else if(manrUsers.isLoggedIn && kYTAllowSignOut) {
		[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Sign out", nil) forState:UIControlStateNormal];
	} else {
		[self.customNavBar.btnRight setTitle:@"" forState:UIControlStateNormal];
	}
	[self.customNavBar setNeedsLayout];
	
	NSString *sDate = @"-";
	if(![VLDate isEmpty:manrSync.lastSyncTimeForUser]) {
		NSDate *date = [manrSync.lastSyncTimeForUser toNSDate];
		NSDateFormatter *frm = [[NSDateFormatter new] autorelease];
		frm.timeZone = [NSTimeZone defaultTimeZone];
		frm.timeStyle = NSDateFormatterShortStyle;
		frm.dateStyle = NSDateFormatterShortStyle;
		sDate = [frm stringFromDate:date];
	}
	NSString *sText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Last Synchronized:", nil), sDate];
	_cellLastSyncDate.textLabel.text = sText;
	
	NSMutableArray *newCellsSections = [NSMutableArray array];
	// Update cells structure:
	{
		NSMutableArray *curCellsSection = [NSMutableArray array];
		[newCellsSections addObject:curCellsSection];
		
		if(manrUsers.isDemo) {
			[curCellsSection addObject:_cellAccountInfo];
			[curCellsSection addObject:_cellLogin];
			[curCellsSection addObject:_cellRegister];
		}
		
		curCellsSection = [NSMutableArray array];
		[newCellsSections addObject:curCellsSection];
		
		_show_cellLastSyncDate = (manrUsers.isLoggedIn && !manrUsers.isDemo && ![VLDate isEmpty:manrSync.lastSyncTimeForUser]);
		if(_show_cellLastSyncDate)
			[curCellsSection addObject:_cellLastSyncDate];
		if(!manrUsers.isDemo)
			[curCellsSection addObject:_cellSync];
		
		curCellsSection = [NSMutableArray array];
		[newCellsSections addObject:curCellsSection];
		[curCellsSection addObject:_cellNotebooks];
		if(kYTHideDefaultNotebook && [manrBooks getNotebooks].count <= 1)
			[curCellsSection removeObject:_cellNotebooks];
		
		curCellsSection = [NSMutableArray array];
		[newCellsSections addObject:curCellsSection];
		
		[curCellsSection addObject:_cellAutoAddNoteLocation];
		// TODO: hide, because not localized yet
		//[curCellsSection addObject:_cellSaveToCameraRoll];
		//if(!manrUsers.isDemo)
		[curCellsSection addObject:_cellSyncOnWiFiOnly];
		[curCellsSection addObject:_cellChooseWallpaper];
		
		curCellsSection = [NSMutableArray array];
		[newCellsSections addObject:curCellsSection];
		
		[curCellsSection addObject:_cellRateApp];
		[curCellsSection addObject:_cellReportProblem];
		
		for(int i = (int)newCellsSections.count - 1; i >= 0; i--) {
			NSArray *cells = [newCellsSections objectAtIndex:i];
			if(!cells.count)
				[newCellsSections removeObjectAtIndex:i];
		}
	}
	
	[_tableView updateRowsWithLastSections:_cellsSections
							   newSections:newCellsSections
							resultSections:_cellsSections
			   allowMoveRowBetweenSections:NO
								  animated:NO];
	
	[self setNeedsLayout];
	[[VLMessageCenter shared] performBlock:^{
		[self setNeedsLayout];
	} afterDelay:0.02 ignoringTouches:NO];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	CGRect rcTable = rcBnds;
	float dy = 0.0;
	rcTable.origin.y += dy;
	rcTable.size.height -= dy;
	_tableView.frame = rcTable;
	if(!_show_cellLastSyncDate) {
		_overlaySepLSD1.hidden = _overlaySepLSD2.hidden = YES;
	} else {
		CGRect rcOver = [_cellLastSyncDate convertRect:_cellLastSyncDate.bounds toView:_tableView];
		rcOver.origin.y = CGRectGetMaxY(rcOver) - 1;
		rcOver.size.height = 2;
		_overlaySepLSD1.frame = rcOver;
		rcOver.size.height = 0.5;
		float dx = 14.0;
		rcOver.origin.x += dx;
		rcOver.size.width -= dx * 2;
		_overlaySepLSD2.frame = rcOver;
		_overlaySepLSD1.hidden = _overlaySepLSD2.hidden = NO;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _cellsSections.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSArray *cells = [_cellsSections objectAtIndex:section];
	if([cells containsObject:_cellSync] || [cells containsObject:_cellLogin]) {
		if(![NSString isEmpty:_headerSync.label.text])
			return _headerSync;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	NSArray *cells = [_cellsSections objectAtIndex:section];
	if([cells containsObject:_cellSync] || [cells containsObject:_cellLogin]) {
		if([NSString isEmpty:_headerSync.label.text])
			return 0;
	}
	UIView *header = [self tableView:tableView viewForHeaderInSection:section];
	if(header) {
		return (int)([header sizeThatFits:_tableView.bounds.size].height * 1.5);
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if(section == _cellsSections.count - 1) {
		return _headerCopyright;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	UIView *header = [self tableView:tableView viewForFooterInSection:section];
	if(header) {
		return (int)([header sizeThatFits:_tableView.bounds.size].height * 1.75);
	}
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *cells = [_cellsSections objectAtIndex:section];
	return cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *cells = [_cellsSections objectAtIndex:indexPath.section];
	return [cells objectAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *cells = [_cellsSections objectAtIndex:indexPath.section];
	UITableViewCell *cell = [cells objectAtIndex:indexPath.row];
	if(cell == _cellLastSyncDate) {
		float res = 24;
		return res;
	} else if(cell == _cellAccountInfo) {
		CGRect rcBnds = self.bounds;
		NSString *text = _cellAccountInfo.textLabel.text;
		UIFont *font = _cellAccountInfo.textLabel.font;
		CGSize szText = [text vlSizeWithFont:font constrainedToSize:CGSizeMake(rcBnds.size.width - 40, rcBnds.size.height)
							   lineBreakMode:NSLineBreakByWordWrapping];
		return szText.height + 10;
	}
	return _tableView.rowHeight;
}

- (void)onSettingsManagerChanged:(id)sender {
	YTSettingsManager *manrSett = [YTSettingsManager shared];
	_cellAutoAddNoteLocation.view.switcher.on = manrSett.autoAddNoteLocation;
	_cellSaveToCameraRoll.view.switcher.on = manrSett.saveTakenPhotosToCameraRoll;
	_cellSyncOnWiFiOnly.view.switcher.on = manrSett.syncOnWiFiOnly;
}

- (void)onCellAutoAddNoteLocationValueChanged:(id)sender {
	BOOL isOn = _cellAutoAddNoteLocation.view.switcher.on;
	YTSettingsManager *manrSett = [YTSettingsManager shared];
	manrSett.autoAddNoteLocation = isOn;
	[self updateViewNow];
}

- (void)onSaveToCameraRollValueChanged:(id)sender {
	BOOL isOn = _cellSaveToCameraRoll.view.switcher.on;
	YTSettingsManager *manrSett = [YTSettingsManager shared];
	manrSett.saveTakenPhotosToCameraRoll = isOn;
	[self updateViewNow];
}

- (void)onSyncOnWiFiOnlyValueChanged:(id)sender {
	BOOL isOn = _cellSyncOnWiFiOnly.view.switcher.on;
	YTSettingsManager *manrSett = [YTSettingsManager shared];
	manrSett.syncOnWiFiOnly = isOn;
	[self updateViewNow];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
	if(cell == _cellLogin) {
		YTLoginView *loginView = [[[YTLoginView alloc] init] autorelease];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [[AppDelegate instance]settingsChangeTo:loginView];
        }
        else
		[[self parentContentView] pushView:loginView animated:YES];
	} else if(cell == _cellRegister) {
		YTRegisterView *registerView = [[[YTRegisterView alloc] init] autorelease];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [[AppDelegate instance]settingsChangeTo:registerView];
        }
        else

		[[self parentContentView] pushView:registerView animated:YES];
	} else if(cell == _cellSync) {
		if(![YTSyncManager shared].processing) {
			[[YTSyncManager shared] startSyncMTWithResultBlockMT:^(NSError *error) {
				if(error && !error.isCancel) {
					[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:[error localizedDescription]];
				}
			}];
		}
	} else if(cell == _cellNotebooks) {
		YTNotebooksEditView *notebooksEditView = [[[YTNotebooksEditView alloc] init] autorelease];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [[AppDelegate instance]settingsChangeTo:notebooksEditView];
        }
        else

		[[self parentContentView] pushView:notebooksEditView animated:YES];
	} else if(cell == _cellChooseWallpaper) {
		[[YTWallpapersManager shared] startChooseWalpaper];
	} else if(cell == _cellRateApp) {
		[self rateApp];
	} else if(cell == _cellReportProblem) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"settings"];
		NSString *sAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSString *sBuildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
		NSData *logData = nil;
		if([VLLogger shared].logFileEnabled) {
			logData = [[VLLogger shared] getSavedFileLogsData];
			if(logData && !logData.length)
				logData = nil;
		}
		if(kYTDebugMode) {
			if(logData) {
				NSString *str = [[[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding] autorelease];
				str = str;
				int idebug = 0;
				idebug++;
			}
		}
		[[VLMailComposeManager shared] sendMailWithSubject:[NSString stringWithFormat:NSLocalizedString(@"Report a problem: iOS v.%@ b.%@", nil), sAppVersion, sBuildNumber]
													  body:@""//NSLocalizedString(@"We are very sorry that you experienced a problem.\n A log file attached.\n Sending us a log may help us to investigate the cause of the problem, so thank you in advance for sending it.", nil)
												   address:@"support@allnotes.co"
												attachment:logData
										attachmentMimeType:logData ? @"text/plain" : nil
										attachmentFileName:logData ? @"log.txt" : nil];
	}
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
	if(cell == _cellLastSyncDate)
		return NO;
	return YES;
}

- (UITableViewHeaderFooterView *)headerViewForSection:(NSInteger)section {
	return nil;
}

- (void)rateApp {
	NSString *templateReviewURL = (kIosVersionFloat >= 7.0)
		? @"http://itunes.apple.com/app/idAPP_ID"
		: @"http://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
		//: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
	NSString *reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:[NSString stringWithFormat:@"%@", kYTAppId]];
	NSURL *url = [NSURL URLWithString:reviewURL];
	if(url)
		[[UIApplication sharedApplication] openURL:url];
}


- (void)onBecomeTopAgainInNavigation {
	[super onBecomeTopAgainInNavigation];
	[_tableView deselectAllRowsAnimated:YES];
}

- (void)onBtnBackTap:(id)sender {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [[AppDelegate instance]settingsDismiss];
    }
    else
	if(self.navigatingViewDelegate && [self.navigatingViewDelegate respondsToSelector:@selector(navigatingView:handleGoBack:)])
		[self.navigatingViewDelegate navigatingView:self handleGoBack:nil];
    
    
}

- (void)onBtnRightTap:(id)sender {
	YTUsersEnManager *manUsers = [YTUsersEnManager shared];
	if(manUsers.isDemo && kShowClearDataButton) {
		// TODO: localize later
		[VLAlertView showWithYesNoTitle:NSLocalizedString(@"Clear Data", nil)
							message:NSLocalizedString(@"Do you want to remove all data?", nil)
						resultBlock:^(BOOL yesTapped)
		{
			if(yesTapped) {
				[manUsers logoutWithResultBlock:^(NSError *error) {
					if(!error)
						[[VLToastView makeText:NSLocalizedString(@"All data cleared", nil)] show];
				}];
			}
		}];
	} else if(manUsers.isLoggedIn && kYTAllowSignOut) {
		[VLAlertView showWithYesNoTitle:NSLocalizedString(@"Signing out {Title}", nil)
								message:NSLocalizedString(@"Are you sure you want to sign out?", nil)
							resultBlock:^(BOOL yesTapped)
		{
			if(yesTapped) {
				[manUsers logoutWithResultBlock:^(NSError *error) {
					if(error) {
						VLLoggerError(@"%@", error);
						[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:[error localizedDescription]];
					}
				}];
			}
		}];
	}
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTSettingsManager shared].msgrVersionChanged removeObserver:self];
	[[YTUsersEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTSyncManager shared].msgrVersionChanged removeObserver:self];
	[[YTNotebooksEnManager shared].msgrVersionChanged removeObserver:self];
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange removeObserver:self];
	[_allCells release];
	[_cellsSections release];
	[_headerSync release];
	[_cellAccountInfo release];
	[_cellLogin release];
	[_cellRegister release];
	[_cellLastSyncDate release];
	[_overlaySepLSD1 release];
	[_overlaySepLSD2 release];
	[_cellSync release];
	[_cellNotebooks release];
	[_cellAutoAddNoteLocation release];
	[_cellSaveToCameraRoll release];
	[_cellSyncOnWiFiOnly release];
	[_cellChooseWallpaper release];
	[_cellRateApp release];
	[_cellReportProblem release];
	[_headerCopyright release];
	[_tableView release];
	[super dealloc];
}

@end



@implementation YTSettingsView_HeaderCopyright

- (void)initialize {
	[super initialize];
	_textCopyright1 = [NSLocalizedString(@"", nil) retain];
	// TODO: localize
	_textCopyright2 = [@"Copyright @ 2014 iDevz Inc" retain];
	NSString *text = [NSString stringWithFormat:@"%@\n\n%@\n", _textCopyright1, _textCopyright2];
	self.label.text = text;
	self.label.numberOfLines = 0;
	self.label.textAlignment = NSTextAlignmentCenter;
	
	_overlaySepCopyright = [[UIView alloc] initWithFrame:CGRectZero];
	_overlaySepCopyright.backgroundColor = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease].separatorColor;
	[self addSubview:_overlaySepCopyright];
	
	UIEdgeInsets insets = self.insets;
	//insets.top = -9.0;
	self.insets = insets;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcOver = CGRectMake(0, 0, rcBnds.size.width, 0.5);
	float widthForText = rcBnds.size.width - self.insets.left - self.insets.right;
	CGSize szText = [self.label.text vlSizeWithFont:self.label.font
									   constrainedToSize:CGSizeMake(widthForText, 1000) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize szTextPart1 = [_textCopyright1 vlSizeWithFont:self.label.font
								constrainedToSize:CGSizeMake(widthForText, 1000) lineBreakMode:NSLineBreakByWordWrapping];
	float lnHeight = [@"A" vlSizeWithFont:self.label.font].height;
	rcOver.origin.y = CGRectGetMidY(rcBnds) + self.insets.top - self.insets.bottom;
	rcOver.origin.y -= szText.height/2;
	rcOver.origin.y += szTextPart1.height + lnHeight/2;
	CGSize szTextPart2 = [_textCopyright2 vlSizeWithFont:self.label.font
								constrainedToSize:CGSizeMake(widthForText, 1000) lineBreakMode:NSLineBreakByWordWrapping];
	rcOver.size.width = szTextPart2.width + 30;
	rcOver.origin.x = CGRectGetMidX(rcBnds) - rcOver.size.width/2;
	_overlaySepCopyright.frame = [UIScreen roundRect:rcOver];
}

- (CGSize)sizeThatFits:(CGSize)size {
	size = [super sizeThatFits:size];
	return size;
}

- (void)dealloc {
	[_textCopyright1 release];
	[_textCopyright2 release];
	[_overlaySepCopyright release];
	[super dealloc];
}

@end


