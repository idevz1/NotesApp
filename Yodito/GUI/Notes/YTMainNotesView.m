
#import "YTMainNotesView.h"
#import "../Settings/Classes.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "../Notebook/Classes.h"

#define kFixedTabbarHeight (88.0/2.0)
#define kHeaderHeightAll 58.0
#define kHeaderHeightOpaque 46.0

@interface YTMainNotesView()

@end


@interface YTMainNotesView_HeaderImageView : UIImageView
@end
@implementation YTMainNotesView_HeaderImageView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return nil;
}
@end


@interface YTMainNotesView_HeaderImageClipView : UIView
@end
@implementation YTMainNotesView_HeaderImageClipView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return nil;
}
@end



@implementation YTMainNotesView

@synthesize menuShown = _menuShown;
@dynamic hasNotesLoadedOnce;
@synthesize notesDisplayParams = _notesDisplayParams;

+ (YTMainNotesView *)currentInstance {
	NSMutableArray *arrViews = [NSMutableArray arrayWithArray:
								[VLCtrlsUtils getSubViewsOfClass:[YTMainNotesView class] parentView:[UIApplication sharedApplication].keyWindow]];
	for(int i = (int)arrViews.count - 1; i >= 0; i--) {
		YTMainNotesView *view = [arrViews objectAtIndex:i];
		if(view.hidden) {
			[arrViews removeObjectAtIndex:i];
			continue;
		}
	}
	return arrViews.count ? [arrViews objectAtIndex:0] : nil;
}

- (id)initWithFrame:(CGRect)frame  notesDisplayParams:(YTNotesDisplayParams *)notesDisplayParams {
	_notesDisplayParams = [notesDisplayParams retain];
	self = [super initWithFrame:frame];
	if(self) {
		
	}
	return self;
}

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTNoteCellBackColor;

	_notesTableView = [[YTNotesTableView alloc] initWithNotesDisplayParams:_notesDisplayParams];
	[self addSubview:_notesTableView];
	
	_barBackView = [[UIView alloc] initWithFrame:CGRectZero];
	_barBackView.backgroundColor = kYTHeaderBackColor;
	[self addSubview:_barBackView];
	
	self.customNavBar.btnBack.hidden = NO;
	
	NSString *title = @"";
	UIImage *titleImage = nil;
	YTNotebookInfo *notebook = [[YTNotebooksEnManager shared] getNotebookByGuid:_notesDisplayParams.notebookGuid];
	if(_notesDisplayParams.priorityType > EYTPriorityTypeNone) {
		title = NSLocalizedString(@"Starred {Title}", nil);
	} else if(notebook) {
		title = notebook.name;
	} else if(![NSString isEmpty:_notesDisplayParams.tagName]) {
		title = _notesDisplayParams.tagName;
	} else {
		titleImage = [UIImage imageNamed:@"title_all_notes.png" scale:2];
		if(!titleImage)
			title = NSLocalizedString(@"AZ Notes {Title}", nil);
	}
	if(titleImage)
		[self.customNavBar setTitleImage:titleImage];
	else
		self.customNavBar.titleLabel.text = title;
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnBackTap:) forControlEvents:UIControlEventTouchUpInside];
	
	self.customNavBar.btnRight.hidden = NO;
	[self.customNavBar.btnRight setImage:[UIImage imageNamed:@"bbi_plus.png"] forState:UIControlStateNormal];
	[self.customNavBar.btnRight addTarget:self action:@selector(onBtnAddNoteTap:) forControlEvents:UIControlEventTouchUpInside];
	
	[[YTUiMediator shared].msgrVersionChanged addObserver:self selector:@selector(onManagerChanged:)];
	[[YTSyncManager shared].msgrVersionChanged addObserver:self selector:@selector(onManagerChanged:)];
	[[YTUsersEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onManagerChanged:)];
	
	[self updateViewAsync];
}

- (BOOL)hasNotesLoadedOnce {
	return _notesTableView.hasNotesLoadedOnce;
}

- (void)onUpdateView {
	[super onUpdateView];
	BOOL processing = [YTSyncManager shared].processing;
	BOOL wasSyncedOnce = [YTSyncManager shared].wasSyncedOnceAfterLogin;
	BOOL showActivity = processing && !wasSyncedOnce;
	if(showActivity != !!_activityView) {
		if(showActivity) {
			if(!_activityView) {
				_activityView = [[YTTransparentActivityView alloc] initWithFrame:CGRectZero];
				_activityView.title = NSLocalizedString(@"Loading...", nil);
				[self addSubview:_activityView];
				[self setNeedsLayout];
				[_activityView startActivity];
			}
		} else {
			if(_activityView) {
				[_activityView stopActivity];
				[_activityView removeFromSuperview];
				[_activityView release];
				_activityView = nil;
			}
		}
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBar = self.frameOfBar;
	_barBackView.frame = rcBar;
	CGRect rcBnds = self.boundsNoBars;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	CGRect rcViews = rcBnds;
	
	CGRect rcHomeFeed = rcViews;
	_notesTableView.frame = rcHomeFeed;
	
	if(_activityView)
		_activityView.frame = rcBnds;
}

- (void)onBecomeTopAgainInNavigation {
	[super onBecomeTopAgainInNavigation];
	//if(_noteView)
	//	[_noteView onBecomeTopAgainInNavigation];
}

- (void)onManagerChanged:(id)sender {
	[self updateViewAsync];
}

- (void)onBtnBackTap:(id)sender {
	if(self.navigatingViewDelegate && [self.navigatingViewDelegate respondsToSelector:@selector(navigatingView:handleGoBack:)])
		[self.navigatingViewDelegate navigatingView:self handleGoBack:nil];
}

- (void)onBtnHeaderReloadTap:(id)sender {
	if([YTSyncManager shared].processing)
		return;
	[[YTSyncManager shared] startSyncMTWithResultBlockMT:^(NSError *error) {
		if(error && !error.isCancel) {
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:[error localizedDescription]];
		}
	}];
}

- (void)onBtnAddNoteTap:(id)sender {
	[[YTUiMediator shared] startAddNewNoteAsPhoto:NO
									 notebookGuid:_notesDisplayParams.notebookGuid
										isStarred:(_notesDisplayParams.priorityType > EYTPriorityTypeNone)
							  previousScreenTitle:self.customNavBar.titleLabel.text];
}

- (void)dealloc {
	[[YTUiMediator shared].msgrVersionChanged removeObserver:self];
	[[YTSyncManager shared].msgrVersionChanged removeObserver:self];
	[[YTUsersEnManager shared].msgrVersionChanged removeObserver:self];
	[_notesDisplayParams release];
	[_barBackView release];
	[_notesTableView release];
	[_activityView release];
	[super dealloc];
}

@end

