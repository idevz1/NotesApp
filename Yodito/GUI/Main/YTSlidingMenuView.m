
#import "YTSlidingMenuView.h"

@implementation YTSlidingMenuActionArgs

@synthesize action = _action;
@synthesize param = _param;

- (id)initWithAction:(EYTSlidingMenuViewAction)action param:(NSObject *)param {
	self = [super init];
	_action = action;
	_param = [param retain];
	return self;
}

- (void)dealloc {
	[_param release];
	[super dealloc];
}

@end


@interface YTSlidingMenuView_CellSelBackView : YTBaseView {
@private
}

@end

@implementation YTSlidingMenuView_CellSelBackView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.7];
}

@end


#define kTableHeaderHeight 14.0

@implementation YTSlidingMenuView

@synthesize delegate = _delegate;

- (void)initialize {
	[super initialize];
	//self.backgroundColor = [UIColor redColor];
	
	if(kIosVersionFloat >= 7.0) {
		_statusBarBack = [[UIImageView alloc] initWithFrame:CGRectZero];
		_statusBarBack.backgroundColor = [UIColor blackColor];
		_statusBarBack.contentMode = UIViewContentModeScaleToFill;
		_statusBarBack.hidden = YES;
		[self addSubview:_statusBarBack];
	}
	
	_imageViewBack = [[UIImageView alloc] initWithFrame:CGRectZero];
	_imageViewBack.contentMode = UIViewContentModeScaleAspectFill;
	[self addSubview:_imageViewBack];
	
	_overlayView = [[UIView alloc] initWithFrame:CGRectZero];
	_overlayView.backgroundColor = [UIColor blackColor];
	_overlayView.alpha = 0.7;
	[self addSubview:_overlayView];
	
	_cellsSections = [[NSMutableArray alloc] init];
	
	_viewTimeline = [[YTMenuTableCellView alloc] initWithFrame:CGRectZero];
 
	VLTableViewCell *cellTimeline = [[[VLTableViewCell alloc] initWithSubView:_viewTimeline reuseIdentifier:nil] autorelease];
	_viewTimeline.title = NSLocalizedString(@"All Notes {Title}", nil);
	_viewTimeline.icon = [UIImage imageNamed:@"homemenu_icon_timeline.png" scale:2];
	
	_viewStarred = [[YTMenuTableCellView alloc] initWithFrame:CGRectZero];
	VLTableViewCell *cellStarred = [[[VLTableViewCell alloc] initWithSubView:_viewStarred reuseIdentifier:nil] autorelease];
	_viewStarred.title = NSLocalizedString(@"Starred {Title}", nil);
	_viewStarred.icon = [UIImage imageNamed:@"homemenu_icon_star.png" scale:2];
	
	_viewPhotos = [[YTMenuTableCellView alloc] initWithFrame:CGRectZero];
	VLTableViewCell *cellPhotos = [[[VLTableViewCell alloc] initWithSubView:_viewPhotos reuseIdentifier:nil] autorelease];
	_viewPhotos.title = NSLocalizedString(@"Photos {Title}", nil);
	_viewPhotos.icon = [UIImage imageNamed:@"homemenu_icon_camera.png" scale:2];
	_viewPhotos.enableIconTouches = YES;
	
	_viewSettings = [[YTMenuTableCellView alloc] initWithFrame:CGRectZero];
	VLTableViewCell *cellSettings = [[[VLTableViewCell alloc] initWithSubView:_viewSettings reuseIdentifier:nil] autorelease];
	_viewSettings.title = NSLocalizedString(@"Settings {Title}", nil);
	_viewSettings.icon = [UIImage imageNamed:@"homemenu_icon_settings.png" scale:2];
	
	NSArray *views = [NSArray arrayWithObjects:_viewTimeline, _viewStarred, _viewPhotos, _viewSettings, nil];
	for(YTMenuTableCellView *view in views) {
		[self configureCellView:view];
	}
	
	NSMutableArray *cellsSection = [NSMutableArray array];
	[cellsSection addObject:cellTimeline];
	[cellsSection addObject:cellStarred];
	[cellsSection addObject:cellPhotos];
	[_cellsSections addObject:cellsSection];
	
	_cellsNotebooks = [[NSMutableArray alloc] init];
	[_cellsSections addObject:_cellsNotebooks];
	
	_cellsTags = [[NSMutableArray alloc] init];
	[_cellsSections addObject:_cellsTags];
	
	_cellsBottom = [[NSMutableArray alloc] init];
	[_cellsBottom addObject:cellSettings];
	[_cellsSections addObject:_cellsBottom];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[_tableView setTransparentBackground];
	_tableView.rowHeight = 40;
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.alwaysBounceVertical = YES;
	[self addSubview:_tableView];
	
	_wasRegistered = [YTUsersEnManager shared].isLoggedIn && ![YTUsersEnManager shared].isDemo;
	
	[[YTNotebooksEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTNotesEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTResourcesEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTTagsEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTNoteToTagEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTSettingsManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTWallpapersManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTUsersEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[[VLMessageCenter shared] performBlock:^{
		[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
	} afterDelay:0.001 ignoringTouches:YES];
	
	[self updateViewAsync];
}

- (void)updateFonts:(id)sender {
	NSMutableArray *allCells = [NSMutableArray array];
	[allCells addObject:[VLCtrlsUtils getParentViewOfClass:[VLTableViewCell class] ofView:_viewSettings]];
	for(NSArray *cells in _cellsSections)
		[allCells addObjectsFromArray:cells];
	for(VLTableViewCell *cell in allCells) {
		YTMenuTableCellView *view = (YTMenuTableCellView *)cell.subView;
		view.labelTitle.font = [[YTFontsManager shared] fontWithSize:19 fixed:YES];
		view.labelTitleRight.font = [[YTFontsManager shared] lightFontWithSize:19 fixed:YES];
	}
	if(sender != self) {
		[self setNeedsLayout];
		[_tableView reloadData];
	}
}

- (void)configureCellView:(YTMenuTableCellView *)view {
	view.backgroundColor = [UIColor clearColor];
	UIEdgeInsets insets = view.contentInsets;
	insets.left = 8.0;
	view.contentInsets = insets;
	view.labelTitle.textColor =[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
	view.labelTitleRight.textColor = [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1.0];
	VLTableViewCell *cell = (VLTableViewCell *)[VLCtrlsUtils getParentViewOfClass:[VLTableViewCell class] ofView:view];
	cell.selectedBackgroundView = [[[YTSlidingMenuView_CellSelBackView alloc] initWithFrame:CGRectZero] autorelease];
	cell.backgroundColor = cell.contentView.backgroundColor = [UIColor clearColor];
	view.delegate = self;
	view.separatorBottomHidden = YES;
}

- (void)updateWallpaper {
	YTWallpapersManager *manrWall = [YTWallpapersManager shared];
	BOOL needChange = NO;
	if(!_imageViewBack.image)
		needChange = YES;
	if(!needChange) {
		if( _lastCustomWallpaperVersion != manrWall.customWallpaperVersion)
			needChange = YES;
	}
	if(needChange) {
		if([manrWall customWallpaperExists]) {
			_imageViewBack.image = [manrWall getCustomWallpaper];
			if(!_imageViewBack.image)
				_imageViewBack.image = [manrWall getDefaultWallpaper];
		} else {
			_imageViewBack.image = [manrWall getDefaultWallpaper];
		}
	}
	_lastCustomWallpaperVersion = manrWall.customWallpaperVersion;
}

- (void)onUpdateView {
	[super onUpdateView];
	YTNotebooksEnManager *manrBooks = [YTNotebooksEnManager shared];
	YTNotesEnManager *manrNotes = [YTNotesEnManager shared];
	//YTResourcesEnManager *manrRes = [YTResourcesEnManager shared];
	//YTUsersEnManager *manrUsers = [YTUsersEnManager shared];
	YTTagsEnManager *manrTags = [YTTagsEnManager shared];
	YTNoteToTagEnManager *manrNoteTags = [YTNoteToTagEnManager shared];
	
	// Update notebooks
	NSMutableArray *cellsNotebooks = [NSMutableArray array];
	NSMutableArray *notebooks = [NSMutableArray arrayWithArray:[manrBooks getNotebooks]];
	YTNotebookInfo *mainNotebook = [YTNotebooksEnManager shared].defaultNotebook;
	if(kYTHideDefaultNotebook && mainNotebook)
		[notebooks removeObject:mainNotebook];
	// Remove empty:
	for(int i = (int)notebooks.count - 1; i >= 0; i--) {
		YTNotebookInfo *notebook = [notebooks objectAtIndex:i];
		int nNotes = [manrNotes getNotesCountInNotebookWithGuid:notebook.notebookGuid];
		if(nNotes == 0)
			[notebooks removeObjectAtIndex:i];
	}
	[notebooks sortUsingComparator:^NSComparisonResult(YTNotebookInfo *obj1, YTNotebookInfo *obj2) {
		return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
	}];
	for(int i = 0; i < notebooks.count; i++) {
		YTNotebookInfo *notebook = [notebooks objectAtIndex:i];
		// Skip 'Demo' notebook
		//if(notebook.notebookId == kYTNotebookIdDemo && manrUsers.isDemo)
		//	continue;
		VLTableViewCell *cell = nil;
		if(i < _cellsNotebooks.count)
			cell = [_cellsNotebooks objectAtIndex:i];
		else {
			YTMenuTableCellView *view = [[[YTMenuTableCellView alloc] initWithFrame:CGRectZero] autorelease];
			cell = [[[VLTableViewCell alloc] initWithSubView:view reuseIdentifier:nil] autorelease];
			[self configureCellView:view];
			view.icon = [UIImage imageNamed:@"homemenu_icon_book.png" scale:2];
		}
		YTMenuTableCellView *view = (YTMenuTableCellView *)cell.subView;
		view.labelTitle.text = notebook.name;
		view.objectTag = notebook;
		[cellsNotebooks addObject:cell];
	}
	
	// Update tags
	NSMutableArray *cellsTags = [NSMutableArray array];
	NSMutableArray *tags = [NSMutableArray arrayWithArray:[manrTags getAllTags]];
	NSMutableDictionary *mapTagByName = [NSMutableDictionary dictionaryWithCapacity:tags.count];
	for(YTTagInfo *tag in tags) {
		if([manrNoteTags hasNoteTagsById:tag.tagId] && ![mapTagByName objectForKey:tag.name]) {
			[mapTagByName setObject:tag forKey:tag.name];
		}
	}
	tags = [NSMutableArray arrayWithArray:mapTagByName.allValues];
	[tags sortUsingComparator:^NSComparisonResult(YTTagInfo *obj1, YTTagInfo *obj2) {
		return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
	}];
	for(int i = 0; i < tags.count; i++) {
		YTTagInfo *tag = [tags objectAtIndex:i];
		VLTableViewCell *cell = nil;
		if(i < _cellsTags.count)
			cell = [_cellsTags objectAtIndex:i];
		else {
			YTMenuTableCellView *view = [[[YTMenuTableCellView alloc] initWithFrame:CGRectZero] autorelease];
			cell = [[[VLTableViewCell alloc] initWithSubView:view reuseIdentifier:nil] autorelease];
			[self configureCellView:view];
			view.icon = [UIImage imageNamed:@"homemenu_icon_tag.png" scale:2];
		}
		YTMenuTableCellView *view = (YTMenuTableCellView *)cell.subView;
		view.labelTitle.text = tag.name;
		view.objectTag = tag;
		[cellsTags addObject:cell];
	}
	
	BOOL needReload = NO;
	if(![_cellsNotebooks isEqualToArray:cellsNotebooks] || ![_cellsTags isEqualToArray:cellsTags]) {
		[_cellsNotebooks removeAllObjects];
		[_cellsNotebooks addObjectsFromArray:cellsNotebooks];
		[_cellsTags removeAllObjects];
		[_cellsTags addObjectsFromArray:cellsTags];
		needReload = YES;
	}
	if(needReload)
		[_tableView reloadData];
	
	[self updateFonts:self];
	[self updateWallpaper];
	
	BOOL isRegistered = [YTUsersEnManager shared].isLoggedIn && ![YTUsersEnManager shared].isDemo;
	if(!_wasRegistered && isRegistered) {
		// Show Notes view after user registered
		[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		YTSlidingMenuActionArgs *actionArgs = [[[YTSlidingMenuActionArgs alloc] initWithAction:EYTSlidingMenuViewActionShowTimeline param:nil] autorelease];
		if(_delegate && [_delegate respondsToSelector:@selector(slidingMenuView:actionSelected:)])
			[_delegate slidingMenuView:self actionSelected:actionArgs];
	}
	_wasRegistered = isRegistered;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = [self boundsNoBars];
	CGRect rcContent = rcBnds;
	float topIndent = 0;
	if(kIosVersionFloat >= 7.0 && ![UIApplication sharedApplication].statusBarHidden) {
		topIndent = [self convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil].size.height;
		CGRect rcBar = rcBnds;
		rcBar.size.height = topIndent;
		_statusBarBack.frame = rcBar;
	}
	rcContent.origin.y += topIndent;
	rcContent.size.height -= topIndent;
	CGRect rcImage = (_statusBarBack && !_statusBarBack.hidden) ? rcContent : rcBnds;
	_imageViewBack.frame = rcImage;
	_overlayView.frame = rcImage;
	CGRect rcTbl = rcContent;
	rcTbl.size.height = CGRectGetMaxY(rcContent) - rcTbl.origin.y;
	_tableView.frame = rcTbl;
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
	UITableViewCell *cell = [cells objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	VLTableViewCell *cell = (VLTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	YTMenuTableCellView *view = (YTMenuTableCellView *)cell.subView;
	YTSlidingMenuActionArgs *actionArgs = nil;
	if(view == _viewTimeline)
		actionArgs = [[[YTSlidingMenuActionArgs alloc] initWithAction:EYTSlidingMenuViewActionShowTimeline param:nil] autorelease];
	else if(view == _viewStarred)
		actionArgs = [[[YTSlidingMenuActionArgs alloc] initWithAction:EYTSlidingMenuViewActionShowStarred param:nil] autorelease];
	else if(view == _viewPhotos)
		actionArgs = [[[YTSlidingMenuActionArgs alloc] initWithAction:EYTSlidingMenuViewActionShowPhotos param:nil] autorelease];
	else if(view == _viewSettings) //SettingsPopUp
		actionArgs = [[[YTSlidingMenuActionArgs alloc] initWithAction:EYTSlidingMenuViewActionShowSettings param:nil] autorelease];
	else if([_cellsNotebooks containsObject:cell]) {
		YTNotebookInfo *notebook = ObjectCast(view.objectTag, YTNotebookInfo);
		if(notebook) {
			actionArgs = [[[YTSlidingMenuActionArgs alloc] initWithAction:EYTSlidingMenuViewActionShowNotebook param:notebook] autorelease];
		}
	} else if([_cellsTags containsObject:cell]) {
		YTTagInfo *tag = ObjectCast(view.objectTag, YTTagInfo);
		if(tag) {
			actionArgs = [[[YTSlidingMenuActionArgs alloc] initWithAction:EYTSlidingMenuViewActionShowTag param:tag] autorelease];
		}
	}
	if(actionArgs) {
		if(_delegate && [_delegate respondsToSelector:@selector(slidingMenuView:actionSelected:)])
			[_delegate slidingMenuView:self actionSelected:actionArgs];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if(tableView == _tableView) {
		if(section == [_cellsSections indexOfObject:_cellsNotebooks] || section == [_cellsSections indexOfObject:_cellsTags]
		    || section == [_cellsSections indexOfObject:_cellsBottom])
			return kTableHeaderHeight;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(tableView == _tableView) {
		if(section == [_cellsSections indexOfObject:_cellsNotebooks] || section == [_cellsSections indexOfObject:_cellsTags]
		    || section == [_cellsSections indexOfObject:_cellsBottom]) {
			UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, kTableHeaderHeight)] autorelease];
			header.backgroundColor = [UIColor clearColor];
			return header;
		}
	}
	return nil;
}

- (void)dealloc {
	_delegate = nil;
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTNotebooksEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTNotesEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTResourcesEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTTagsEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTNoteToTagEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTSettingsManager shared].msgrVersionChanged removeObserver:self];
	[[YTWallpapersManager shared].msgrVersionChanged removeObserver:self];
	[[YTUsersEnManager shared].msgrVersionChanged removeObserver:self];
	
	[_statusBarBack release];
	[_imageViewBack release];
	[_overlayView release];
	
	[_tableView release];
	[_cellsSections release];
	[_viewTimeline release];
	[_viewStarred release];
	[_viewPhotos release];
	[_cellsNotebooks release];
	[_cellsTags release];
	[_cellsBottom release];
	[_viewSettings release];
	
	[super dealloc];
}

@end

