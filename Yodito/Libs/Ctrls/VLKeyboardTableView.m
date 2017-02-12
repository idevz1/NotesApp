
#import "VLKeyboardTableView.h"
#import "../Common/Classes.h"
#import "VLCtrlsUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "../Logic/Classes.h"

#define kLogKeyboardEvents NO

@implementation VLKeyboardTableView

@synthesize pullToRefreshDelegate = _pullToRefreshDelegate;
@synthesize pullToRefresHeaderView = _refreshHeaderView;
@synthesize keyboardTableViewDelegate = _keyboardTableViewDelegate;

- (void)initialize
{
	if(_initialized)
		return;
	_initialized = YES;
	
	NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
	[notifCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[notifCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[notifCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[notifCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	[notifCenter addObserver:self selector:@selector(keyboardFrameBeginUserInfoKey:) name:UIKeyboardFrameBeginUserInfoKey object:nil];
	[notifCenter addObserver:self selector:@selector(keyboardFrameEndUserInfoKey:) name:UIKeyboardFrameEndUserInfoKey object:nil];
	if(kIosVersionFloat >= 5.0)
	{
		[notifCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
		[notifCenter addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
	}
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 0.05;
	[_timer setObserver:self selector:@selector(onTimer:)];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:frame style:style];
	if(self)
	{
		[self initialize];
	}
	return self;
}
- (id)initWithFrame:(CGRect)frame
			  style:(UITableViewStyle)style
		 dataSource:(id<UITableViewDataSource>)dataSource
		   delegate:(id<UITableViewDelegate>)delegate
{
	self = [super initWithFrame:frame style:style];
	if(self)
	{
		[self initialize];
		_dataSourceInt = dataSource;
		_delegateInt = delegate;
		self.dataSource = self;
		self.delegate = self;
	}
	return self;
}
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		[self initialize];
	}
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if(self)
	{
		[self initialize];
	}
	return self;
}
- (id)init
{
	self = [super init];
	if(self)
	{
		[self initialize];
	}
	return self;
}

- (void)resetDataSourceAndDelegate
{
	_dataSourceInt = nil;
	_delegateInt = nil;
}

- (CGRect)sharedRectWithKeyboard
{
	CGRect rcBnds = [self convertRect:self.bounds toView:nil];
	CGRect rcKeyboard = _frameOfKeyboard;
	if(!_keyboardShown || !CGRectIntersectsRect(rcBnds, rcKeyboard))
		return CGRectMake(rcBnds.origin.x, CGRectGetMaxY(rcBnds), rcBnds.size.width, 0);
	CGRect rcShared = CGRectIntersection(rcBnds, rcKeyboard);
	rcShared = [self convertRect:rcShared fromView:nil];
	return rcShared;
}

- (void)procesKeyboardEvent:(id)obj
{
	if(!obj || ![obj isKindOfClass:[NSNotification class]])
		return;
	NSNotification *notify = (NSNotification*)obj;
	CGRect keybBounds;
	id idVal = [notify.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
	if(!idVal || ![idVal isKindOfClass:[NSValue class]])
		return;
	NSValue *val = (NSValue*)idVal;
	[val getValue: &keybBounds];
	_frameOfKeyboard = keybBounds;
}

- (UITableViewCell*)additionTableCell
{
	if(!_keyboardShown)
		return nil;
	if(!_additionTableCell)
	{
		_additionTableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		UIView *clearView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		clearView.backgroundColor = [UIColor clearColor];
		_additionTableCell.backgroundView = clearView;
		clearView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		clearView.backgroundColor = [UIColor clearColor];
		_additionTableCell.selectedBackgroundView = clearView;
		_additionTableCell.backgroundColor = _additionTableCell.contentView.backgroundColor = [UIColor clearColor];
		_additionTableCell.layer.borderWidth = _additionTableCell.contentView.layer.borderWidth = 0;
		_additionTableCell.layer.shadowColor = _additionTableCell.contentView.layer.shadowColor = [UIColor clearColor].CGColor;
	}
	return _additionTableCell;
}

- (float)additionTableCellHeight
{
	if(!_keyboardShown)
		return 0;
	CGRect rcBnds = self.bounds;
	CGRect rcKeyb = [self sharedRectWithKeyboard];
	float height = CGRectGetMaxY(rcBnds) - rcKeyb.origin.y;
	if(height < 0)
		height = 0;
	return height;
}

- (UIView *)findFirstResponder {
	UIView *firstResponder = [VLCtrlsUtils findFirstResponder:self];
	if(!firstResponder && _keyboardTableViewDelegate && [_keyboardTableViewDelegate respondsToSelector:@selector(keyboardTableView:getFirstResponder:)])
		firstResponder = [_keyboardTableViewDelegate keyboardTableView:self getFirstResponder:nil];
	return firstResponder;
}

- (void)correctScrollableControls:(BOOL)force
{
	BOOL hasFirstResponder = NO;
	UIView *firstResponder = nil;
	if(_keyboardShown)
	{
		firstResponder = [self findFirstResponder];
		if(firstResponder)
			hasFirstResponder = YES;
	}
	if(hasFirstResponder == _hasFirstResponder && !force)
		return;
	if(hasFirstResponder != _hasFirstResponder)
	{
		int rows = 0;
		int numberOfSections = (int)[self numberOfSectionsInTableView:self];
		int section = numberOfSections - 1;
		if(section == -1)
			section = 0;
		else
			rows = (int)[self numberOfRowsInSection:section];
		[self beginUpdates];
		_hasFirstResponder = hasFirstResponder;
		if(numberOfSections > 0 ) {
			if(_hasFirstResponder)
			{
				NSIndexPath *newRowPath = [NSIndexPath indexPathForRow:rows inSection:section];
				[self insertRowsAtIndexPaths:[NSArray arrayWithObject:newRowPath] withRowAnimation:UITableViewRowAnimationTop];
			}
			else
			{
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows-1 inSection:section];
				[self deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			}
		}
		[self endUpdates];
	}
	if(_hasFirstResponder && firstResponder)
	{
		CGRect rcKeyboard = [self sharedRectWithKeyboard];
		CGRect rcResponder = firstResponder.bounds;
		rcResponder = [firstResponder convertRect:rcResponder toView:self];
		CGPoint lastOffset = self.contentOffset;
		float dh = CGRectGetMaxY(rcResponder) - rcKeyboard.origin.y;
		if(dh > 0)
		{
			CGPoint offset = CGPointMake(0, lastOffset.y + dh);
			[UIView beginAnimations:nil context:self];
			[UIView setAnimationDelay:0.05];
			[UIView setAnimationDuration:0.3];
			self.contentOffset = offset;
			[UIView commitAnimations];
		}
		else
		{
			float dh = rcResponder.origin.y - self.bounds.origin.y;
			if(dh < 0)
			{
				CGPoint offset = CGPointMake(0, MAX(lastOffset.y + dh, 0));
				[UIView beginAnimations:nil context:self];
				[UIView setAnimationDelay:0.05];
				[UIView setAnimationDuration:0.3];
				self.contentOffset = offset;
				[UIView commitAnimations];
			}
		}
	}
}

- (void)onTimer:(id)sender
{
	// Check if first responder was changed
	if(!_keyboardShown)
	{
		[_lastFirstResponder release];
		_lastFirstResponder = nil;
		[_timer stop];
		return;
	}
	UIView* firstResponder = [self findFirstResponder];
	if(firstResponder)
	{
		if(_lastFirstResponder && _lastFirstResponder != firstResponder)
			[self correctScrollableControls:YES];
		[_lastFirstResponder release];
		_lastFirstResponder = [firstResponder retain];
	}
}

- (void)setKeyboardShown:(BOOL)keyboardShown
{
	if(_keyboardShown != keyboardShown)
	{
		_keyboardShown = keyboardShown;
		[self correctScrollableControls:NO];
	}
}

- (void)keyboardWillShow:(id)obj
{
	if(kLogKeyboardEvents)
		NSLog(@"keyboardWillShow");
	[self procesKeyboardEvent:obj];
	[self setKeyboardShown:YES];
}
- (void)keyboardDidShow:(id)obj
{
	if(kLogKeyboardEvents)
		NSLog(@"keyboardDidShow");
	[_timer start];
}
- (void)keyboardWillHide:(id)obj
{
	if(kLogKeyboardEvents)
		NSLog(@"keyboardWillHide");
	[self procesKeyboardEvent:obj];
	[self setKeyboardShown:NO];
}
- (void)keyboardDidHide:(id)obj
{
	if(kLogKeyboardEvents)
		NSLog(@"keyboardDidHide");
	[self procesKeyboardEvent:obj];
}
- (void)keyboardFrameBeginUserInfoKey:(id)obj
{
	if(kLogKeyboardEvents)
		NSLog(@"keyboardFrameBeginUserInfoKey");
	[self procesKeyboardEvent:obj];
}
- (void)keyboardFrameEndUserInfoKey:(id)obj
{
	if(kLogKeyboardEvents)
		NSLog(@"keyboardFrameEndUserInfoKey");
	[self procesKeyboardEvent:obj];
}
- (void)keyboardWillChangeFrame:(id)obj
{
	if(kLogKeyboardEvents)
		NSLog(@"keyboardWillChangeFrame");
	[self procesKeyboardEvent:obj];
}
- (void)keyboardDidChangeFrame:(id)obj
{
	if(kLogKeyboardEvents)
		NSLog(@"keyboardDidChangeFrame");
	[self procesKeyboardEvent:obj];
}

- (BOOL)isAdditionalIndexPath:(NSIndexPath*)indexPath
{
	if(!indexPath || !_hasFirstResponder)
		return NO;
	int section = (int)indexPath.section;
	int row = (int)indexPath.row;
	int sections = 1;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(numberOfSectionsInTableView:)])
		sections = (int)[_dataSourceInt numberOfSectionsInTableView:self];
	if(section != sections - 1)
		return NO;
	int rows = 0;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
		rows = (int)[_dataSourceInt tableView:self numberOfRowsInSection:sections - 1];
	if(row == rows - 1 + (+1))
		return YES;
	return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger result = 0;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
	   result = [_dataSourceInt tableView:tableView numberOfRowsInSection:section];
	if(_hasFirstResponder && section == [self numberOfSectionsInTableView:self] - 1)
		result++;
	return result;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return [self additionTableCell];
	UITableViewCell *result = nil;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)])
		result = [_dataSourceInt tableView:tableView cellForRowAtIndexPath:indexPath];
	if(!result)
	{
		VLLogError(@"Could not get cell from datasource, returned fake cell.");
		static NSString *_sFakeCellReuseId = @"VLKeyboardTableView_sFakeCellReuseId";
		result = [tableView dequeueReusableCellWithIdentifier:_sFakeCellReuseId];
		if(!result)
			result = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_sFakeCellReuseId] autorelease];
	}
	return result;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger result = 1;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(numberOfSectionsInTableView:)])
		result = [_dataSourceInt numberOfSectionsInTableView:tableView];
	return result;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *result = nil;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
		result = [_dataSourceInt tableView:tableView titleForHeaderInSection:section];
	return result;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *result = nil;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:titleForFooterInSection:)])
		result = [_dataSourceInt tableView:tableView titleForFooterInSection:section];
	return result;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return NO;
	BOOL result = tableView.editing;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
		result = [_dataSourceInt tableView:tableView canEditRowAtIndexPath:indexPath];
	return result;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return NO;
	BOOL result = tableView.editing;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
		result = [_dataSourceInt tableView:tableView canMoveRowAtIndexPath:indexPath];
	return result;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	NSArray *result = nil;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(sectionIndexTitlesForTableView:)])
		result = [_dataSourceInt sectionIndexTitlesForTableView:tableView];
	return result;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	NSInteger result = NSIntegerMax;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)])
		result = [_dataSourceInt tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
	return result;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
		forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
		[_dataSourceInt tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	  toIndexPath:(NSIndexPath *)destinationIndexPath
{
	if([self isAdditionalIndexPath:sourceIndexPath] || [self isAdditionalIndexPath:destinationIndexPath])
		return;
	if(_dataSourceInt && [_dataSourceInt respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
		[_dataSourceInt tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return [self additionTableCellHeight];
	CGFloat result = self.rowHeight;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
		result = [_delegateInt tableView:tableView heightForRowAtIndexPath:indexPath];
	return result;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	CGFloat result = 0;
	if(_delegateInt
	   && ( [_delegateInt respondsToSelector:@selector(tableView:titleForHeaderInSection:)]
		   || [_delegateInt respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
	   )
		result = tableView.sectionHeaderHeight;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
		result = [_delegateInt tableView:tableView heightForHeaderInSection:section];
	return result;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	CGFloat result = 0;
	if(_delegateInt
	   && ( [_delegateInt respondsToSelector:@selector(tableView:titleForFooterInSection:)]
		   || [_delegateInt respondsToSelector:@selector(tableView:viewForFooterInSection:)])
	   )
		result = tableView.sectionFooterHeight;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:heightForFooterInSection:)])
		result = [_delegateInt tableView:tableView heightForFooterInSection:section];
	return result;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *result = nil;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
		result = [_delegateInt tableView:tableView viewForHeaderInSection:section];
	return result;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *result = nil;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:viewForFooterInSection:)])
		result = [_delegateInt tableView:tableView viewForFooterInSection:section];
	return result;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
		[_delegateInt tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return nil;
	NSIndexPath *result = indexPath;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
		result = [_delegateInt tableView:tableView willSelectRowAtIndexPath:indexPath];
	return result;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
		[_delegateInt tableView:tableView didSelectRowAtIndexPath:indexPath];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([self isAdditionalIndexPath:indexPath])
		return UITableViewCellEditingStyleNone;
	UITableViewCellEditingStyle result = tableView.editing ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)])
		result = [_delegateInt tableView:tableView editingStyleForRowAtIndexPath:indexPath];
	return result;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL result = YES;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)])
		result = [_delegateInt tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
	return result;
}
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)])
		[_delegateInt tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)])
		[_delegateInt tableView:tableView didEndEditingRowAtIndexPath:indexPath];
}
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if([self isAdditionalIndexPath:sourceIndexPath] || [self isAdditionalIndexPath:proposedDestinationIndexPath])
		return nil;
	NSIndexPath *result = nil;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)])
		result = [_delegateInt tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
	return result;
}
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	BOOL result = NO;
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)])
		result = [_delegateInt tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
	return result;
}
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)])
		[_delegateInt tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
}


#pragma mark VLRefreshTableHeaderView

- (void)addPullToRefreshViewWithStyle:(VLPullRefreshStyle)style height:(float)height
{
	if(!_refreshHeaderView)
	{
		_refreshHeaderView = [[VLRefreshTableHeaderView alloc] initWithStyle:style height:height];
		_refreshHeaderView.backgroundColor = [UIColor clearColor];
		_refreshHeaderView.delegate = self;
		[self addSubview:_refreshHeaderView];
	}
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)pullToRefreshViewDoneLoading
{
	_pullToRefreshViewDoneLoadingCalled = YES;
	if(!_refreshHeaderReloading)
		return;
	_refreshHeaderReloading = NO;
	_emulateDragging = NO;
	[_refreshHeaderView pullRefreshScrollViewDataSourceDidFinishedLoading:self];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[_refreshHeaderView pullRefreshScrollViewDidScroll:scrollView];
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(scrollViewDidScroll:)])
		[_delegateInt scrollViewDidScroll:scrollView];
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(scrollViewWillBeginDragging:)])
		[_delegateInt scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView pullRefreshScrollViewDidEndDragging:scrollView];
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
		[_delegateInt scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
		[_delegateInt scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if(_delegateInt && [_delegateInt respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
		[_delegateInt scrollViewDidEndDecelerating:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)pullRefreshTableHeaderDidTriggerRefresh:(VLRefreshTableHeaderView*)view
{
	if(_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefreshHeaderPulledAndShouldStartUpdating:)])
	{
		_pullToRefreshViewDoneLoadingCalled = NO;
		if([_pullToRefreshDelegate pullToRefreshHeaderPulledAndShouldStartUpdating:self])
		{
			if(!_pullToRefreshViewDoneLoadingCalled)
				_refreshHeaderReloading = YES;
		}
	}
	if(!_refreshHeaderReloading)
	{
		_emulateDragging = NO;
		[[VLMessageCenter shared] performBlock:^{
			[_refreshHeaderView pullRefreshScrollViewDataSourceDidFinishedLoading:self];
		} afterDelay:0.05 ignoringTouches:YES];
	}
}

- (BOOL)pullRefreshTableHeaderDataSourceIsLoading:(VLRefreshTableHeaderView*)view
{
	return _refreshHeaderReloading;
}

- (NSDate*)pullRefreshTableHeaderDataSourceLastUpdated:(VLRefreshTableHeaderView*)view
{
	if(_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefreshLastUpdatedDate:)])
		return [_pullToRefreshDelegate pullToRefreshLastUpdatedDate:self];
	return nil;
}

- (void)pullToRefreshViewDownStep3
{
	_emulateDragging = NO;
	[_refreshHeaderView pullRefreshScrollViewDidEndDragging:self];
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}
- (void)pullToRefreshViewDownStep2
{
	CGPoint offset = self.contentOffset;
	offset.y -= 2;
	self.contentOffset = offset;
	[_refreshHeaderView pullRefreshScrollViewDidScroll:self];
	[self performSelector:@selector(pullToRefreshViewDownStep3) withObject:nil afterDelay:0.01];
}
- (void)pullToRefreshPullDown
{
	if(!_refreshHeaderView || _refreshHeaderReloading)
		return;
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	CGPoint offset = self.contentOffset;
	_emulateDragging = YES;
	[_refreshHeaderView pullRefreshScrollViewDidScroll:self];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kDefaultAnimationDuration];
	offset.y -= _refreshHeaderView.frame.size.height - 1;
	self.contentOffset = offset;
	[UIView commitAnimations];
	[self performSelector:@selector(pullToRefreshViewDownStep2) withObject:nil afterDelay:kDefaultAnimationDuration * 1.01];
}

- (BOOL)isDragging
{
	if(_emulateDragging)
		return YES;
	return [super isDragging];
}
#pragma mark -


- (void)dealloc
{
	NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
	[notifCenter removeObserver:self];
	[_additionTableCell release];
	[_timer release];
	[_lastFirstResponder release];
	[_refreshHeaderView release];
	[super dealloc];
}

@end
