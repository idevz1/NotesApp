
#import "YTNotesTableView.h"
#import "../Notes/Classes.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "iPadDetailViewController.h"
#import "AppDelegate.h"
#define kMinUpdateInterval 1.0
#define kTableHeaderSize 27.0
#define kShowHeaderBottomSeparator YES//NO


@implementation YTHomeFeedView_TableHeaderViewBase

@synthesize ivBack = _ivBack;
@synthesize lbTitle = _lbTitle;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.backgroundColor = kYTNoteCellBackColor;
	
	_ivBack = [[UIImageView alloc] initWithFrame:CGRectZero];
	_ivBack.backgroundColor = kYTNoteCellBackColor;//[UIColor clearColor];
	_ivBack.contentMode = UIViewContentModeScaleToFill;
	UIImage *image = [UIImage imageNamed:@"header_reminders_for_today.png"];
	_ivBack.image = image;
	[self addSubview:_ivBack];
	_ivBack.hidden = YES; // Hidden by default
	
	_lbTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_lbTitle.backgroundColor = [UIColor clearColor];
	[_lbTitle centerText];
	_lbTitle.textColor = kYTTableHeaderTextColor;
	[self addSubview:_lbTitle];
	
	if(kShowHeaderBottomSeparator) {
		_separator = [[YTNoteTableCellView_Separator alloc] initWithFrame:CGRectZero];
		[self addSubview:_separator];
	}
	
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange addObserver:self selector:@selector(updateViewAsync)];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
}

- (void)updateFonts:(id)sender {
	_lbTitle.font = [[YTFontsManager shared] fontWithSize:16 fixed:YES];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	CGRect rcSep = rcBnds;
	rcSep.size.height = 0;
	if(_separator && !_separator.hidden)
		rcSep.size.height = [_separator optimalHeight];
	rcSep.origin.y = CGRectGetMaxY(rcBnds) - rcSep.size.height;
	if(_separator)
		_separator.frame = rcSep;
	CGRect rcCont = rcBnds;
	rcCont.size.height = rcSep.origin.y - rcBnds.origin.y;
	if(_ivBack)
		_ivBack.frame = rcCont;
	_lbTitle.frame = rcCont;
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = kTableHeaderSize;
	if(_separator && !_separator.hidden)
		size.height += [_separator optimalHeight];
	return size;
}

- (void)dealloc {
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange removeObserver:self];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[_ivBack release];
	[_lbTitle release];
	[_separator release];
	[super dealloc];
}

@end


@implementation YTHomeFeedView_RemindersHeaderView

- (void)initialize {
	[super initialize];
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
}

- (void)dealloc {
	[super dealloc];
}

@end


@implementation YTHomeFeedView_RecentlyCompletedHeaderView

- (void)initialize {
	[super initialize];
	self.ivBack.image = [UIImage imageNamed:@"cal_recently_completed.png"];
	self.lbTitle.textColor = kYTHeaderButtonTitleColor;
}

- (void)dealloc {
	[super dealloc];
}

@end


@implementation YTHomeFeedView_AllNotesHeaderView

- (void)initialize {
	[super initialize];
	self.lbTitle.text = @"";
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 10.0; // Update header title (date)
	[_timer setObserver:self selector:@selector(updateViewAsync)];
	[_timer start];
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	NSDateFormatter *frm = [[[NSDateFormatter alloc] init] autorelease];
	frm.timeZone = [NSTimeZone defaultTimeZone];
	frm.timeStyle = NSDateFormatterNoStyle;
	frm.dateFormat = @"MMMM yyyy";
	NSString *sDate = [frm stringFromDate:[NSDate date]];
	self.lbTitle.text = sDate;
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)dealloc {
	[_timer release];
	[super dealloc];
}

@end


@implementation YTHomeFeedView_MonthHeaderView

@synthesize dateMonth = _dateMonth;

- (id)init {
	self = [super init];
	if(self) {
		_dateMonth = [[NSDate empty] retain];
	}
	return self;
}

- (void)setDateMonth:(NSDate *)dateMonth {
	if(!dateMonth)
		dateMonth = [NSDate empty];
	if(![_dateMonth isEqual:dateMonth]) {
		[_dateMonth release];
		_dateMonth = [dateMonth retain];
		[self updateViewAsync];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	NSString *sTitle = @"";
	if(![NSDate isEmpty:_dateMonth]) {
		sTitle = [YTHomeFeedView_MonthSectionInfo stringFromDateMonth:_dateMonth timezone:[NSTimeZone defaultTimeZone]];
	}
	self.lbTitle.text = sTitle;
}

- (void)dealloc {
	[_dateMonth release];
	[super dealloc];
}

@end


@implementation YTHomeFeedView_MonthSectionInfo

@synthesize dateMonth = _dateMonth;
@synthesize absoluteMonth = _absoluteMonth;
@synthesize notes = _notes;

- (id)init {
	self = [super init];
	if(self) {
		_dateMonth = [[NSDate empty] retain];
		_notes = [[NSMutableArray alloc] init];
	}
	return self;
}

+ (NSString *)stringFromDateMonth:(NSDate *)dateMonth timezone:(NSTimeZone *)timezone {
	NSDateFormatter *frmMonth = [[[NSDateFormatter alloc] init] autorelease];
	frmMonth.timeZone = timezone;
	frmMonth.dateFormat = @"MMMM yyyy";
	NSString *sMonth = [frmMonth stringFromDate:dateMonth];
	return sMonth;
}

+ (int)absoluteMonthFromDateMonth:(NSDate *)dateMonth timezone:(NSTimeZone *)timezone {
	//return [dateMonth timeIntervalSince1970] / (3600*24*30);
	//int res = [dateMonth diffMonthsFrom:[NSDate dateWithTimeIntervalSinceReferenceDate:0] timezone:timezone];
	int year = [dateMonth gregorianYearWithTimezone:timezone];
	int mon = [dateMonth gregorianMonthWithTimezone:timezone];
	int res = year * 12 + mon;
	return res;
}

- (void)dealloc {
	[_dateMonth release];
	[_notes release];
	[super dealloc];
}

@end


@implementation YTNotesTableView

@synthesize hasNotesLoadedOnce = _hasNotesLoadedOnce;
@synthesize detailViewController = _detailViewController;
+ (YTNotesTableView *)currentInstance {
	NSMutableArray *arrViews = [NSMutableArray arrayWithArray:
								[VLCtrlsUtils getSubViewsOfClass:[YTNotesTableView class] parentView:[UIApplication sharedApplication].keyWindow]];
	for(int i = (int)arrViews.count - 1; i >= 0; i--) {
		YTNotesTableView *view = [arrViews objectAtIndex:i];
		if(view.hidden) {
			[arrViews removeObjectAtIndex:i];
			continue;
		}
	}
	return arrViews.count ? [arrViews objectAtIndex:0] : nil;
}

- (id)initWithNotesDisplayParams:(YTNotesDisplayParams *)notesDisplayParams {
	_notesDisplayParams = [notesDisplayParams retain];
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)initialize {
	[super initialize];
    
	_arrMonthsSectionsNew = [[NSMutableArray alloc] init];
	_notesSections = [[NSMutableArray alloc] init];
	_notesSectionsNew = [[NSMutableArray alloc] init];
	_dictCellInfoByNoteGuid = [[NSMutableDictionary alloc] init];
	_sectionsHeaders = [[NSMutableArray alloc] init];
	_sectionsHeadersNew = [[NSMutableArray alloc] init];
	_searchText = [@"" retain];
	_lastSearchText = [@"" retain];
	_filteredNoteGuids = [[NSMutableSet alloc] init];
	
	_headerToDo = [[YTHomeFeedView_RemindersHeaderView alloc] initWithFrame:CGRectZero];
	_headerToDo.lbTitle.text = NSLocalizedString(@"Reminders for Today", nil);
	_headerToDoDone = [[YTHomeFeedView_RecentlyCompletedHeaderView alloc] initWithFrame:CGRectZero];
	_headerToDoDone.lbTitle.text = NSLocalizedString(@"Recently Completed", nil);
	
	_headerAllNotes = [[YTHomeFeedView_AllNotesHeaderView alloc] initWithFrame:CGRectZero];
	
	_tableView = [[VLKeyboardTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain
												 dataSource:self delegate:self];
	[_tableView setTransparentBackground];
	_tableView.separatorColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delaysContentTouches = NO;
	if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
		[_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	[self addSubview:_tableView];
	
	float headerHeight = [YTTableSearchBar optimalHeight];
	_tableSearchBar = [[YTTableSearchBar alloc] initWithFrame:CGRectMake(0, -headerHeight, 0, headerHeight)];
	_tableSearchBar.delegate = self;
	if([_tableSearchBar.textField respondsToSelector:@selector(setTintColor:)])
		_tableSearchBar.textField.tintColor = [UIColor colorWithRed:0x5E/255.0 green:0x7D/255.0 blue:0x9A/255.0 alpha:1.0];
	[_tableView addSubview:_tableSearchBar];
	
	_searchOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
	_searchOverlayView.hidden = YES;
	_searchOverlayView.opaque = NO;
	_searchOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
	[self addSubview:_searchOverlayView];
	[_searchOverlayView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSearchOverlayViewTap:)] autorelease]];
	
	_timer = [[VLTimer alloc] init];
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	_timer.interval = kMinUpdateInterval / 4;
	_timer.enabledAlwaysFiring = YES;
	[_timer start];
	[self performSelector:@selector(onTimerEvent:) withObject:nil afterDelay:0.001];
	
	[[YTUiMediator shared].msgrNoteAddedManually addObserver:self selector:@selector(onNoteAddedManually:args:)];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(onFontsChanged:)];
	[self updateFonts:self];
    
    
}

- (void)updateFonts:(id)sender {
	[self setNeedsLayout];
	if(sender != self)
		[_tableView reloadData];
}

- (void)onFontsChanged:(id)sender {
	[self updateFonts:self];
	[_tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if(_tableSearchBar) {
		float headerHeight = [YTTableSearchBar optimalHeight];
		CGPoint contentOffset = _tableView.contentOffset;
		if(!_searchBarPulled) {
			float pullDY = -contentOffset.y;
			if(pullDY >= headerHeight * 0.67) {
				_searchBarPulled = YES;
				[_tableSearchBar removeFromSuperview];
				contentOffset.y += headerHeight;
				_tableView.tableHeaderView = _tableSearchBar;
				[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
					_tableView.contentOffset = contentOffset;
				}];
			}
		} else {
			float pullDY = contentOffset.y;
			if(pullDY >= headerHeight * 0.5) {
				_searchBarPulled = NO;
				_tableView.tableHeaderView = nil;
				[_tableView addSubview:_tableSearchBar];
				CGRect rcSearch = _tableSearchBar.frame;
				rcSearch.origin.y = -rcSearch.size.height;
				_tableSearchBar.frame = rcSearch;
				CGPoint contentOffsetNew = contentOffset;
				contentOffsetNew.y -= rcSearch.size.height;
				[self layoutSubviews];
				_tableView.contentOffset = contentOffsetNew;
				[_tableSearchBar cancelSearching];
				[self setIsSearching:NO];
				[self setSearchText:@""];
			}
		}
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self beginIsScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if(!decelerate)
		[self endIsScrolling];
	if(_searchBarPulled) {
		float headerHeight = [YTTableSearchBar optimalHeight];
		CGPoint contentOffset = _tableView.contentOffset;
		if(contentOffset.y > 0 && contentOffset.y < headerHeight * 0.5) {
			[_tableView setContentOffset:CGPointZero animated:YES];
            return;
			[_tableView setContentOffset:CGPointMake(0, headerHeight) animated:YES];
			//[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			[[VLMessageCenter shared] performBlock:^{
				_searchBarPulled = NO;
				_tableView.tableHeaderView = nil;
				[_tableView addSubview:_tableSearchBar];
				CGRect rcSearch = _tableSearchBar.frame;
				rcSearch.origin.y = -rcSearch.size.height;
				_tableSearchBar.frame = rcSearch;
				[self layoutSubviews];
				_tableView.contentOffset = CGPointZero;
				[_tableSearchBar cancelSearching];
				[self setIsSearching:NO];
				[self setSearchText:@""];
			} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
			//}];
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self endIsScrolling];
}

- (void)onSearchOverlayViewTap:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized) {
		[_tableSearchBar cancelSearching];
		[self setIsSearching:NO];
		[self setSearchText:@""];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_tableView.frame = rcBnds;
	if(_tableSearchBar) {
		CGRect rcSearch = _tableSearchBar.frame;
		rcSearch.origin.x = _tableView.bounds.origin.x;
		rcSearch.size.width = _tableView.bounds.size.width;
		_tableSearchBar.frame = rcSearch;
	}
	[self updateSearchOverlayViewFrame];
}

- (int64_t)currentManagersVersion {
	int64_t managersVersion = [YTNotesEnManager shared].version
    + [YTResourcesEnManager shared].version
    + [YTLocationsEnManager shared].version
    + [YTNotebooksEnManager shared].version
    + [YTNoteToResourceEnManager shared].version
    + [YTNoteToLocationEnManager shared].version;
	return managersVersion;
}

- (void)onTimerEvent:(id)sender {
	if([[YTApiMediator shared] isDataInitialized]) {
		if(!_updatingInBackground) {
			if(!_isSearching && ![NSString isEmpty:_lastSearchText]) {
				[_lastSearchText release];
				_lastSearchText = [@"" retain];
			}
			//if(_isSearching && ![NSString isEmpty:_searchText]) {
			if(_isSearching) {
				if(![_lastSearchText isEqual:_searchText]) {
					int curSearchingTicket = ++_curSearchingTicket;
					NSString *lastSearchText = [[_lastSearchText copy] autorelease];
					[_lastSearchText release];
					_lastSearchText = [_searchText copy];
					_isSearchingInBackgroundCounter++;
					[[YTDatabaseManager shared] searchNotesWithText:_searchText resultBlock:^(NSArray *notes)
                     {
                         _isSearchingInBackgroundCounter--;
                         if(curSearchingTicket != _curSearchingTicket)
                             return;
                         NSMutableSet *filteredNoteGuids = [NSMutableSet setWithCapacity:notes.count];
                         for(YTNoteInfo *note in notes)
                             [filteredNoteGuids addObject:note.noteGuid];
                         if(![_filteredNoteGuids isEqualToSet:filteredNoteGuids] || [NSString isEmpty:lastSearchText]) {
                             [_filteredNoteGuids removeAllObjects];
                             if(_isSearching) {
                                 [_filteredNoteGuids addObjectsFromArray:filteredNoteGuids.allObjects];
                                 [self startUpdateNotesInBackgroundWithResultBlock:^{
                                 }];
                             }
                         }
                     }];
				}
			} else {
				[_filteredNoteGuids removeAllObjects];
				int64_t managersVersion = [self currentManagersVersion];
				if(managersVersion != _lastManagersVersion) {
					NSTimeInterval uptime = [VLTimer systemUptime];
					if(uptime >= _lastUpdateUptime + kMinUpdateInterval) {
						_lastManagersVersion = managersVersion;
						[self startUpdateNotesInBackgroundWithResultBlock:^{
						}];
					}
				}
			}
		}
		if(_isSearching && (_isSearchingInBackgroundCounter > 0 || _updatingInBackground)) {
			if(kYTShowActivityOnBarWhenSearching)
				[_tableSearchBar showActivity:YES];
		} else {
			if(kYTShowActivityOnBarWhenSearching)
				[_tableSearchBar showActivity:NO];
		}
		if(_isSearching && [NSString isEmpty:_tableSearchBar.searchText]) {
			[self updateSearchOverlayViewFrame];
			_searchOverlayView.hidden = NO;
		} else {
			_searchOverlayView.hidden = YES;
		}
	}
}

- (void)updateSearchOverlayViewFrame {
	CGRect rcTable = _tableView.frame;
	CGRect rcBar = [self convertRect:_tableSearchBar.bounds fromView:_tableSearchBar];
	CGRect rcOverlay = rcTable;
	rcOverlay.origin.y = CGRectGetMaxY(rcBar);
	rcOverlay.size.height = CGRectGetMaxY(rcTable) - rcOverlay.origin.y;
	_searchOverlayView.frame = rcOverlay;
}

- (void)startUpdateNotesInBackgroundWithResultBlock:(VLBlockVoid)resultBlock {
	if(_updatingInBackground) {
		int lastUpdatingInBackgroundTicket = _updatingInBackgroundTicket;
		[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
			return !(_updatingInBackgroundTicket == lastUpdatingInBackgroundTicket);
		} ignoringTouches:NO completeBlock:^{
			resultBlock();
		}];
		return;
	}
	_updatingInBackground = YES;
	_updatingInBackgroundTicket++;
	
	NSString *notebookGuid = _notesDisplayParams.notebookGuid;
	EYTPriorityType priorityType = _notesDisplayParams.priorityType;
	NSString *tagName = _notesDisplayParams.tagName;
	
	YTNotesEnManager *manrEnNotes = [YTNotesEnManager shared];
	YTResourcesEnManager *manrEnResources = [YTResourcesEnManager shared];
	YTTagsEnManager *manrEnTags = [YTTagsEnManager shared];
	
	NSDictionary *mapResourcesByNoteGuid = [NSDictionary dictionaryWithDictionary:[manrEnResources getMapResourcesByNoteGuid]];
	NSMutableArray *arrNotes = nil;
	if(![NSString isEmpty:notebookGuid]) {
		arrNotes = [NSMutableArray arrayWithArray:[manrEnNotes getNotesInNotebookWithGuid:notebookGuid]];
	} else {
		arrNotes = [NSMutableArray arrayWithArray:[manrEnNotes getNotes]];
	}
	
	NSArray *arrNotesStarred = nil;
	if(priorityType) {
		arrNotesStarred = [NSArray arrayWithArray:[manrEnNotes getNotesStarred]];
	}
	
	NSDictionary *mapTagsByNote = [NSDictionary dictionary];
	if(![NSString isEmpty:tagName])
		mapTagsByNote = [manrEnTags getMapTagsByNoteGuid];
	
	NSMutableSet *filteredNoteGuids = [NSMutableSet setWithSet:_filteredNoteGuids];
	
	NSMutableArray *arrCellInfoForModifyVersion = [NSMutableArray array];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
		
		if(_isSearching) {
			for(int i = (int)arrNotes.count - 1; i >= 0; i--) {
				YTNoteInfo *note = [arrNotes objectAtIndex:i];
				if(![filteredNoteGuids containsObject:note.noteGuid])
					[arrNotes removeObjectAtIndex:i];
			}
		}
		
		[_arrMonthsSectionsNew removeAllObjects];
		[_notesSectionsNew removeAllObjects];
		[_sectionsHeadersNew removeAllObjects];
		
		NSMutableArray *notesSections = [NSMutableArray array];
		NSMutableArray *sectionsHeaders = [NSMutableArray array];
		
		NSMutableArray *notesSectionAll = [NSMutableArray array];
		
		NSMutableDictionary *dictCellInfoByNoteGuid = [[[NSMutableDictionary alloc] init] autorelease];
		
		if(priorityType) {
			[notesSectionAll addObjectsFromArray:arrNotesStarred];
		} else if(![NSString isEmpty:notebookGuid]) {
			[notesSectionAll addObjectsFromArray:arrNotes];
		} else if(![NSString isEmpty:tagName]) {
			[notesSectionAll addObjectsFromArray:arrNotes];
			NSArray *arrNotesArr = [NSArray arrayWithObjects:notesSectionAll, nil];
			for(NSMutableArray *arrNotes in arrNotesArr) {
				for(int i = (int)arrNotes.count - 1; i >= 0; i--) {
					YTNoteInfo *note = [arrNotes objectAtIndex:i];
					NSDictionary *tags = [mapTagsByNote objectForKey:note.noteGuid];
					if(tags.count) {
						BOOL exists = NO;
						for(YTTagInfo *tag in tags.allValues) {
							if([tag.name isEqual:tagName]) {
								exists = YES;
								break;
							}
						}
						if(exists)
							continue;
					}
					[arrNotes removeObjectAtIndex:i];
				}
			}
		} else {
			[notesSectionAll addObjectsFromArray:arrNotes];
		}
		
		[notesSectionAll sortUsingComparator:^NSComparisonResult(YTNoteInfo *obj1, YTNoteInfo *obj2) {
			int res = [self compareNote:obj1 toNote:obj2];
			return res;
		}];
		
		NSMutableArray *arrMonthsSections = [NSMutableArray array];
		NSMutableDictionary *mapMonthsSections = [NSMutableDictionary dictionary];
		NSTimeZone *tzDef = [NSTimeZone defaultTimeZone];
		for(int i = 0; i < notesSectionAll.count; i++) {
			YTNoteInfo *note = [notesSectionAll objectAtIndex:i];
			VLDate *date = [[note.createdDate retain] autorelease];
			int nAbsMonth = [YTHomeFeedView_MonthSectionInfo absoluteMonthFromDateMonth:[date toNSDate] timezone:tzDef];
			NSNumber *numAbsMonth = [NSNumber numberWithInt:nAbsMonth];
			YTHomeFeedView_MonthSectionInfo *sectionInfo = [mapMonthsSections objectForKey:numAbsMonth];
			if(!sectionInfo) {
				sectionInfo = [[[YTHomeFeedView_MonthSectionInfo alloc] init] autorelease];
				sectionInfo.dateMonth = [date toNSDate];
				sectionInfo.absoluteMonth = nAbsMonth;
				[mapMonthsSections setObject:sectionInfo forKey:numAbsMonth];
				[arrMonthsSections addObject:sectionInfo];
			}
			[sectionInfo.notes addObject:note];
			[notesSectionAll removeObjectAtIndex:i];
			i--;
		}
		for(YTHomeFeedView_MonthSectionInfo *sectionInfo in arrMonthsSections) {
			[sectionInfo.notes sortUsingComparator:^NSComparisonResult(YTNoteInfo *obj1, YTNoteInfo *obj2) {
				int res = [self compareNote:obj1 toNote:obj2];
				return res;
			}];
		}
		[arrMonthsSections sortUsingComparator:^NSComparisonResult(YTHomeFeedView_MonthSectionInfo *obj1, YTHomeFeedView_MonthSectionInfo *obj2) {
			int res = obj1.absoluteMonth - obj2.absoluteMonth;
			return -res;
		}];
		for(YTHomeFeedView_MonthSectionInfo *sectionInfo in arrMonthsSections) {
			[notesSections addObject:sectionInfo.notes];
		}
		NSMutableArray *arrHeaderToDoMonthsAvailable = [NSMutableArray array];
		for(YTHomeFeedView_TableHeaderViewBase *headerBase in _sectionsHeaders) {
			YTHomeFeedView_MonthHeaderView *headerMonth = ObjectCast(headerBase, YTHomeFeedView_MonthHeaderView);
			if(headerMonth)
				[arrHeaderToDoMonthsAvailable addObject:headerMonth];
		}
		for(int i = 0; i < arrMonthsSections.count; i++) {
			YTHomeFeedView_MonthSectionInfo *sectionInfo = [arrMonthsSections objectAtIndex:i];
			YTHomeFeedView_MonthHeaderView *header = nil;
			if(arrHeaderToDoMonthsAvailable.count) {
				header = [arrHeaderToDoMonthsAvailable objectAtIndex:0];
				[[header retain] autorelease];
				[arrHeaderToDoMonthsAvailable removeObjectAtIndex:0];
				header.dateMonth = sectionInfo.dateMonth;
				[sectionsHeaders addObject:header];
			} else {
				[sectionsHeaders addObject:[NSNull null]]; // Create view in the main thread
			}
		}
		
		// Replace notes by cellInfos
		BOOL notesChanged = NO;
		BOOL needChangeAnyCell = NO;
		int64_t resourcesManagerVersion = manrEnResources.version;
		for(int iSec = 0; iSec < notesSections.count; iSec++) {
			NSMutableArray *notes = [notesSections objectAtIndex:iSec];
			for(int iNote = 0; iNote < notes.count; iNote++) {
				YTNoteInfo *note = [notes objectAtIndex:iNote];
				int64_t noteVersion = note.version;
				NSString *noteGuid = [[note.noteGuid retain] autorelease];
				YTNoteTableCellInfo *cellInfo = nil;
				YTNoteTableCellInfo *existedCellInfo = [_dictCellInfoByNoteGuid objectForKey:noteGuid];
				YTNoteTableCellInfo *existedCellInfoBackup = nil;
				if(existedCellInfo) {
					existedCellInfoBackup = [[existedCellInfo copy] autorelease];
				}
				cellInfo = existedCellInfo;
				if(!cellInfo) {// || cellInfo.lastNoteVersion != noteVersion) {
					cellInfo = [[[YTNoteTableCellInfo alloc] init] autorelease];
					cellInfo.note = note;
				}
				BOOL noteDataChanged = NO;
				BOOL noteChanged = NO;
				BOOL needChangeCell = NO;
				if(!existedCellInfo)
					noteChanged = YES;
				else if(noteVersion != existedCellInfo.lastNoteVersion)
					noteChanged = YES;
				if(noteChanged) {
					noteDataChanged = YES;
					NSString *noteTitle = note.contentLimited;
					if([NSString isEmpty:noteTitle])
						noteTitle = [note titlePlaceholder];
					cellInfo.title = noteTitle;
					BOOL showDateLabels = YES;
					if(existedCellInfo && existedCellInfo.showDateLabels != showDateLabels)
						needChangeCell = YES;
					cellInfo.showDateLabels = showDateLabels;
					if(showDateLabels) {
						NSDate *date = [note.createdDate toNSDate];
						NSDateFormatter *frm = [[NSDateFormatter alloc] init];
						frm.timeStyle = NSDateFormatterShortStyle;
						frm.dateStyle = NSDateFormatterNoStyle;
						NSString *sTime = [frm stringFromDate:date];
						cellInfo.strTime = sTime;
						[frm release];
						frm = [[NSDateFormatter alloc] init];
						frm.dateFormat = @"dd";
						NSString *sDay = [frm stringFromDate:date];
						if(sDay.length < 2)
							sDay = [NSString stringWithFormat:@"0%@", sDay];
						cellInfo.strDay = sDay;
						[frm release];
						frm = [[NSDateFormatter alloc] init];
						frm.dateFormat = @"EEEE";
						NSString *sWeekday = [frm stringFromDate:date];
						cellInfo.strWeekday = [sWeekday uppercaseString];
						[frm release];
					} else {
						cellInfo.strTime = nil;
						cellInfo.strDay = nil;
						cellInfo.strWeekday = nil;
					}
				}
				BOOL reassignResource = NO;
				if(resourcesManagerVersion != _lastResourcesManagerVersion || !existedCellInfo)
					reassignResource = YES;
				if(reassignResource) {
					YTResourceInfo *resourceImage = nil;
					NSDictionary *resources = [mapResourcesByNoteGuid objectForKey:noteGuid];
					BOOL hasNonImageResource = NO;
					if(resources) {
						for(YTResourceInfo *res in resources.allValues) {
							if([res isImage]) {
								if(![res isThumbnail]
                                   && [[YTResourcesStorage shared] isResourceDownloadedWithHash:res.attachmenthash]) {
									resourceImage = res;
									break;
								}
							} else {
								hasNonImageResource = YES;
							}
						}
					}
					BOOL showThumbnail = !!resourceImage;
					if(cellInfo.showThumbnail != showThumbnail)
						noteDataChanged = YES;
					if(existedCellInfo && existedCellInfo.showThumbnail != showThumbnail)
						needChangeCell = YES;
					cellInfo.showThumbnail = showThumbnail;
					BOOL showAttachmentIcon = hasNonImageResource && !showThumbnail;
					if(cellInfo.showAttachmentIcon != showAttachmentIcon)
						noteDataChanged = YES;
					if(existedCellInfo && existedCellInfo.showAttachmentIcon != showAttachmentIcon)
						needChangeCell = YES;
					cellInfo.showAttachmentIcon = showAttachmentIcon;
					cellInfo.resourceImage = resourceImage;
					if(resourceImage) {
						cellInfo.thumbnailHash = resourceImage.attachmenthash;
					} else {
						cellInfo.thumbnailHash = nil;
					}
				}
				cellInfo.lastNoteVersion = noteVersion;
				if(noteDataChanged)
					notesChanged = YES;
				if(needChangeCell)
					needChangeAnyCell = YES;
				if(existedCellInfo && existedCellInfo == cellInfo && needChangeCell && existedCellInfoBackup) { // Replace with new object, so table cell will be updated
					//cellInfo = [[cellInfo copy] autorelease];
					YTNoteTableCellInfo *cellInfoNew = [[cellInfo copy] autorelease];
					[cellInfo assignFrom:existedCellInfoBackup];
					cellInfo = cellInfoNew;
				} else if(cellInfo == existedCellInfo && noteDataChanged) {
					[arrCellInfoForModifyVersion addObject:cellInfo];
				}
				[notes replaceObjectAtIndex:iNote withObject:cellInfo];
				[dictCellInfoByNoteGuid setObject:cellInfo forKey:note.noteGuid];
			}
		}
		_lastResourcesManagerVersion = resourcesManagerVersion;
		
		[_arrMonthsSectionsNew addObjectsFromArray:arrMonthsSections];
		[_notesSectionsNew addObjectsFromArray:notesSections];
		[_sectionsHeadersNew addObjectsFromArray:sectionsHeaders];
		[_dictCellInfoByNoteGuid removeAllObjects];
		[_dictCellInfoByNoteGuid addEntriesFromDictionary:dictCellInfoByNoteGuid];
		
		BOOL headersChanged = ![_sectionsHeaders isEqualToArray:_sectionsHeadersNew];
		BOOL needUpdateTable = notesChanged || headersChanged;
		
		if(!needUpdateTable) {
			if(!_notesSectionsNew.count != _notesSections.count) {
				needUpdateTable = YES;
			} else {
				for(int iSec = 0; iSec < _notesSections.count; iSec++) {
					NSArray *cells = [_notesSections objectAtIndex:iSec];
					NSArray *cellsNew = [_notesSectionsNew objectAtIndex:iSec];
					if(!cells.count != cellsNew.count) {
						needUpdateTable = YES;
						break;
					}
					if([cells isEqualToArray:cellsNew]) {
						needUpdateTable = YES;
						break;
					}
				}
			}
		}
		
		int allNotesVisible = 0;
		for(NSArray *notes in notesSections) {
			allNotesVisible += notes.count;
		}
		
		BOOL needShowEmptyNotesView = NO;
		if(kYTShowEmptyNotesView && allNotesVisible == 0 && !_isSearching && !_notesDisplayParams.priorityType
		   && [NSString isEmpty:_notesDisplayParams.notebookGuid] && [NSString isEmpty:_notesDisplayParams.tagName])
			needShowEmptyNotesView = YES;
		
		[arpool drain];
		
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
         {
             for(int i = 0; i < _arrMonthsSectionsNew.count; i++) {
                 YTHomeFeedView_MonthSectionInfo *sectionInfo = [_arrMonthsSectionsNew objectAtIndex:i];
                 YTHomeFeedView_MonthHeaderView *header = ObjectCast([_sectionsHeadersNew objectAtIndex:i], YTHomeFeedView_MonthHeaderView);
                 if(!header) {
                     header = [[[YTHomeFeedView_MonthHeaderView alloc] initWithFrame:CGRectZero] autorelease];
                     [_sectionsHeadersNew replaceObjectAtIndex:i withObject:header];
                     header.dateMonth = sectionInfo.dateMonth;
                 }
             }
             
             if(needUpdateTable) {
                 if(headersChanged) {
                     [_sectionsHeaders removeAllObjects];
                     [_sectionsHeaders addObjectsFromArray:_sectionsHeadersNew];
                     
                     [_notesSections removeAllObjects];
                     [_notesSections addObjectsFromArray:_notesSectionsNew];
                     [_tableView reloadData];
                 } else {
                     [_tableView updateRowsWithLastSections:_notesSections
                                                newSections:_notesSectionsNew
                                             resultSections:_notesSections
                                allowMoveRowBetweenSections:YES
                                                   animated:YES
                                               animatedRows:!needChangeAnyCell];
                 }
             }
             _hasNotesLoadedOnce = YES;
             
             YTApiMediator *apiMediator = [YTApiMediator shared];
             if([apiMediator isDataInitialized])
                 [apiMediator setNotesTableWasLoadadOnce:YES];
             
             if(needShowEmptyNotesView) {
                 BOOL wasEmptyNotesView = (_emptyNotesView != nil);
                 if(!_emptyNotesView) {
                     _emptyNotesView = [[YTEmptyNotesView alloc] initWithFrame:CGRectZero];
                 }
                 if(_emptyNotesView) {
                     float topIndent = 5;//_emptyNotesView.topIndent;
                     if(_isSearching)
                         topIndent += 32;
                     if(_emptyNotesView.topIndent != topIndent) {
                         [_emptyNotesView setTopIndent:topIndent animated:wasEmptyNotesView];
                     }
                 }
                 if(_tableView.backgroundView != _emptyNotesView) {
                     [_lastTableBackView release];
                     _lastTableBackView = nil;
                     if(_tableView.backgroundView)
                         _lastTableBackView = [_tableView.backgroundView retain];
                     _tableView.backgroundView = _emptyNotesView;
                 }
             } else {
                 if(_emptyNotesView && (_tableView.backgroundView == _emptyNotesView)) {
                     _tableView.backgroundView = _lastTableBackView;
                     [_lastTableBackView release];
                     _lastTableBackView = nil;
                 }
             }
             
             for(YTNoteTableCellInfo *cellInfo in arrCellInfoForModifyVersion)
                 [cellInfo modifyVersion];
             
             _lastUpdateUptime = [VLTimer systemUptime];
             _updatingInBackground = NO;
             _updatingInBackgroundTicket++;
             
             resultBlock();
         }];
	});
}

- (NSComparisonResult)compareNote:(YTNoteInfo *)note1 toNote:(YTNoteInfo *)note2 {
	int res = -[note1.createdDate compare:note2.createdDate];
	if(res == 0)
		res = [note1.contentLimited compare:note2.contentLimited options:NSCaseInsensitiveSearch];
	if(res == 0)
		res = [note1.noteGuid compare:note2.noteGuid];
	return res;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _notesSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *cellsInfos = [_notesSections objectAtIndex:section];
	return cellsInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *_reuseIdNoThumbNoDate = @"_reuseIdNoThumbNoDate";
	static NSString *_reuseIdThumbNoDate = @"_reuseIdThumbNoDate";
	static NSString *_reuseIdNoThumbDate = @"_reuseIdNoThumbDate";
	static NSString *_reuseIdThumbDate = @"_reuseIdThumbDate";
	static NSString *_reuseIdAttachmentIconDate = @"_reuseIdAttachmentIconDate";
	NSArray *cellsInfos = [_notesSections objectAtIndex:indexPath.section];
	id cellObj = [cellsInfos objectAtIndex:indexPath.row];

    YTNoteTableCellInfo *cellInfo = ObjectCast(cellObj, YTNoteTableCellInfo);
	NSString *reuseId = _reuseIdNoThumbNoDate;
	if(cellInfo.showThumbnail && cellInfo.showDateLabels)
		reuseId = _reuseIdThumbDate;
	else if(cellInfo.showThumbnail && !cellInfo.showDateLabels)
		reuseId = _reuseIdThumbNoDate;
	else if(!cellInfo.showThumbnail && cellInfo.showDateLabels && cellInfo.showAttachmentIcon)
		reuseId = _reuseIdAttachmentIconDate;
	else if(!cellInfo.showThumbnail && cellInfo.showDateLabels)
		reuseId = _reuseIdNoThumbDate;
	VLTableViewCell *cell = (VLTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:reuseId];
	if(!cell) {
		YTNoteTableCellView *view = [[[YTNoteTableCellView alloc] initWithFrame:CGRectZero
                                                                       showDate:cellInfo.showDateLabels showThumbnail:cellInfo.showThumbnail showAttachmentIcon:cellInfo.showAttachmentIcon] autorelease];
		cell = [[[YTNotesTableViewCell alloc] initWithSubView:view reuseIdentifier:reuseId] autorelease];
		cell.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	YTNoteTableCellView *view = (YTNoteTableCellView *)cell.subView;
	[view prepareForAddToTable];
	if(view.cellInfo != cellInfo) {
		[view prepareForAddToTable];
		[view applyCellInfo:cellInfo];
	}
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {

            VLTableViewCell *cell = (VLTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
            YTNoteInfo *note = cellInfo.note;
            BOOL x = [[NSUserDefaults standardUserDefaults]boolForKey:@"first"];
            if (x){
             //   [[AppDelegate instance]changeNote:note];
                [[NSUserDefaults standardUserDefaults]setBool:@"NO" forKey:@"first"];
                
                YTNoteTableCellView *cellView = ObjectCast(cell.subView, YTNoteTableCellView);

                YTNoteView *view = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class] parentView:[UIApplication sharedApplication].keyWindow];
                view = [[[YTNoteView alloc] initWithFrame:CGRectZero] autorelease];
                view.delegate = self;
                view.note = note;
                view.mainResource = cellView.cellInfo.resourceImage;
                BOOL y = [[NSUserDefaults standardUserDefaults]boolForKey:@"add"];
                if (y==NO)
                [[AppDelegate instance]addSubviewToDetailView:view];

            
            
        }
        
    }
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [YTNoteTableCellView optimalHeight];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	YTNotesTableViewCell *cell = (YTNotesTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	if(cell) {
		YTNoteTableCellView *view = (YTNoteTableCellView *)cell.subView;
		if(![view canBeSelected])
			return nil;
	}
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	VLTableViewCell *cell = (VLTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	YTNoteTableCellView *cellView = ObjectCast(cell.subView, YTNoteTableCellView);
	if(cellView) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            YTNoteInfo *note = cellView.cellInfo.note;
           // [[AppDelegate instance]changeNote:note];
            /* unselect Cell
            double delayInSeconds = 0.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [_tableView deselectRowAtIndexPath:indexPath animated:YES];
            });
             */
            
            YTNoteView *view = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class] parentView:[UIApplication sharedApplication].keyWindow];
            if(view && view.note == note)
                return;
            view = [[[YTNoteView alloc] initWithFrame:CGRectZero] autorelease];
            view.delegate = self;
            view.note = note;
            view.mainResource = cellView.cellInfo.resourceImage;
            
            [[AppDelegate instance]addSubviewToDetailView:view];

            
        }
        
        else{
            [VLCtrlsUtils findAndResignFirstResponder:self];
            YTNoteInfo *note = cellView.cellInfo.note;
            YTNoteView *view = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class] parentView:[UIApplication sharedApplication].keyWindow];
            if(view && view.note == note)
                return;
            view = [[[YTNoteView alloc] initWithFrame:CGRectZero] autorelease];
            view.delegate = self;
            view.note = note;
            view.mainResource = cellView.cellInfo.resourceImage;
            [[YTUiMediator shared] showNoteView:view optionalFromCellView:cellView optionalOnThumbsView:nil optionalFromThumbView:nil];
            [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
	} else {
		[_tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(section < _sectionsHeaders.count) {
		YTHomeFeedView_TableHeaderViewBase *header = ObjectCast([_sectionsHeaders objectAtIndex:section], YTHomeFeedView_TableHeaderViewBase);
		if(header) {
			return header;
		}
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if(section < _sectionsHeaders.count) {
		YTHomeFeedView_TableHeaderViewBase *header = ObjectCast([_sectionsHeaders objectAtIndex:section], YTHomeFeedView_TableHeaderViewBase);
		if(header) {
			float height = [header sizeThatFits:self.bounds.size].height;
			return height;
		}
	}
	return 0;
}

- (void)noteView:(YTNoteView *)noteView finishWithAction:(EYTUserActionType)action {
	if(action == EYTUserActionTypeDelete) {
		[[YTUiMediator shared] deleteNoteWithNoteView:noteView resultBlock:^(BOOL result) {
			if(result) {
				[[YTSlidingContainerView shared] closeNoteView:noteView toCellView:nil];
              
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                {
                    YTNoteView *view = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class] parentView:[UIApplication sharedApplication].keyWindow];
                    view = [[[YTNoteView alloc] initWithFrame:CGRectZero] autorelease];
                    view.delegate = self;
                    [[AppDelegate instance]addSubviewToDetailView:view];
                }

			}
		}];
        
    
        
		return;
	}
	[_tableView deselectAllRowsAnimated:YES];
	YTNoteInfo *note = noteView.note;
	YTNoteTableCellView *cellView = [self getCellViewByNote:note];
	[[YTSlidingContainerView shared] closeNoteView:noteView toCellView:cellView];
    
    
}

- (YTNoteTableCellView *)getCellViewByNote:(YTNoteInfo *)note {
	NSArray *visibleCells = [_tableView visibleCells];
	for(UITableViewCell *cell in visibleCells) {
		YTNotesTableViewCell *noteCell = ObjectCast(cell, YTNotesTableViewCell);
		if(noteCell) {
			YTNoteTableCellView *view = ObjectCast(noteCell.subView, YTNoteTableCellView);
			if(view && view.cellInfo && view.cellInfo.note == note)
				return view;
		}
	}
	return nil;
}

- (NSIndexPath *)indexPathForNote:(YTNoteInfo *)note {
	for(NSArray *cellsInfos in _notesSections) {
		for(id obj in cellsInfos) {
			YTNoteTableCellInfo *cellInfo = ObjectCast(obj, YTNoteTableCellInfo);
			if(cellInfo && cellInfo.note == note)
				return [NSIndexPath indexPathForRow:[cellsInfos indexOfObject:cellInfo] inSection:[_notesSections indexOfObject:cellsInfos]];
		}
	}
	return nil;
}

- (void)showNote:(YTNoteInfo *)note animated:(BOOL)animated {
	[_tableView deselectAllRowsAnimated:YES];
	NSIndexPath *indexPath = [self indexPathForNote:note];
	if(indexPath) {
		/*[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
         [_tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
         [[VLMessageCenter shared] performBlock:^{
         [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
         } afterDelay:kDefaultAnimationDuration ignoringTouches:YES];*/
	} else {
		YTNoteView *view = [[[YTNoteView alloc] initWithFrame:CGRectZero] autorelease];
		view.delegate = self;
		view.note = note;
		[[self parentContentView] pushView:view animated:YES];
	}
}

- (void)onNoteAddedManually:(id)sender args:(YTNoteInfoArgs *)args {
	[[VLMessageCenter shared] performBlock:^{
		NSIndexPath *indexPath = [self indexPathForNote:args.note];
		if(indexPath) {
			[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
			[_tableView flashRow:indexPath];
		}
	} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
}

- (void)setIsSearching:(BOOL)isSearching {
	if(_isSearching != isSearching) {
		_isSearching = isSearching;
		[self suspendSliding:_isSearching];
		if(!_isSearching) {
			[self setSearchText:@""];
			_lastManagersVersion = 0;
		}
		YTMainNotesView *parent = (YTMainNotesView *)[VLCtrlsUtils getParentViewOfClass:[YTMainNotesView class] ofView:self];
		[parent setNavigationBarHidden:_isSearching withStatusBarBackColor:_tableSearchBar.backgroundColor animated:YES];
	}
}

- (void)setSearchText:(NSString *)searchText {
	if(!searchText)
		searchText = @"";
	if(!_isSearching)
		searchText = @"";
	if(![_searchText isEqual:searchText]) {
		[_searchText release];
		_searchText = [searchText retain];
		if([NSString isEmpty:_searchText])
			_lastManagersVersion = 0;
	}
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchStarted:(id)param {
	[self setIsSearching:YES];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchEnded:(id)param {
	[self setIsSearching:NO];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchTextChanged:(NSString *)searchText {
	[self setSearchText:searchText];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchButtonTapped:(id)param {
	[VLCtrlsUtils findAndResignFirstResponder:self];
}

- (void)dealloc {
	[self setIsSearching:NO];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTUiMediator shared].msgrNoteAddedManually removeObserver:self];
	[_tableView resetDataSourceAndDelegate];
	_tableSearchBar.delegate = nil;
	[_notesDisplayParams release];
	[_tableView release];
	[_tableSearchBar release];
	[_arrMonthsSectionsNew release];
	[_notesSections release];
	[_notesSectionsNew release];
	[_dictCellInfoByNoteGuid release];
	[_sectionsHeaders release];
	[_sectionsHeadersNew release];
	[_timer release];
	[_headerToDo release];
	[_headerToDoDone release];
	[_headerAllNotes release];
	[_emptyNotesView release];
	[_lastTableBackView release];
	[_searchText release];
	[_lastSearchText release];
	[_filteredNoteGuids release];
	[_searchOverlayView release];
	[super dealloc];
}

@end



