
#import "YTUiMediator.h"
#import "AppDelegate.h"

#define kSavedDataKey @"YTUiMediator"
#define kSavedDataVersion (kYTManagersBaseVersion + 4)

static YTUiMediator *_shared;

@implementation YTUiMediator

@synthesize msgrNoteAddedManually = _msgrNoteAddedManually;
@synthesize msgrFileCantBeViewedAlerted = _msgrFileCantBeViewedAlerted;
@synthesize msgrScrollingEnded = _msgrScrollingEnded;

+ (YTUiMediator *)shared {
	if(!_shared) {
		_shared = [VLObjectFileStorage loadRootObjectWithKey:kSavedDataKey version:kSavedDataVersion];
		if(!_shared)
			_shared = [[[YTUiMediator alloc] init] autorelease];
		[_shared retain];
	}
	return _shared;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
		_shared = self;
		
		if(aDecoder) {
			
		}
		
		_msgrNoteAddedManually = [[VLMessenger alloc] init];
		_msgrNoteAddedManually.owner = self;
		_msgrFileCantBeViewedAlerted = [[VLMessenger alloc] init];
		_msgrFileCantBeViewedAlerted.owner = self;
		_msgrScrollingEnded = [[VLMessenger alloc] init];
		_msgrScrollingEnded.owner = self;
		
		[[YTNotebooksEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNotebooksManagerChanged:)];
		[[YTNotesEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNotesManagerChanged:)];
		[[YTApiMediator shared].msgrVersionChanged addObserver:self selector:@selector(onApiMediatorChanged:)];
		
		[self.msgrVersionChanged addObserver:self selector:@selector(onVersionChanged:)];
		_savedDataVersion = self.version;
	}
	return self;
}

- (id)init {
	return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	
}

- (void)onVersionChanged:(id)sender {
	/*if(_savedDataVersion != self.version) {
		[VLObjectFileStorage saveDataWithRootObject:self key:kSavedDataKey version:kSavedDataVersion];
		_savedDataVersion = self.version;
	}*/
}

- (void)onNotebooksManagerChanged:(id)sender {
	[self modifyVersion];
}

- (void)onNotesManagerChanged:(id)sender {
	[self modifyVersion];
}

- (void)onApiMediatorChanged:(id)sender {
	[self modifyVersion];
}

- (YTNotebookInfo *)notebookForNewNotes {
	YTNotebookInfo *notebook = [YTNotebooksEnManager shared].defaultNotebook;
	return notebook;
}

- (YTStackInfo *)mainStack {
	NSArray *stacks = [[YTStacksEnManager shared] getStacks];
	if(stacks.count)
		return [stacks objectAtIndex:0];
	return nil;
}

- (void)deleteNoteWithNoteView:(YTNoteView *)noteView resultBlock:(VLBlockBool)resultBlock {
	YTNoteInfo *note = noteView.note;
	VLActionSheet *actions = [[[VLActionSheet alloc] init] autorelease];
	[actions addButtonWithTitle:NSLocalizedString(@"Delete {Button}", nil)];
	[actions addButtonWithTitle:NSLocalizedString(@"Cancel {Button}", nil)];
	actions.destructiveButtonIndex = 0;
	actions.cancelButtonIndex = 1;
	[actions showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle) {
		if(btnIndex == 0) {
			[[YTEntitiesManagersLister shared] deleteNote:note withResultBlock:^
			{
				resultBlock(YES);
			}];
		}
	}];
}

- (void)pushNewNoteEditView:(YTNoteEditView *)noteEditView {
	[[YTSlidingContainerView shared] showNoteEditView:noteEditView];
}

- (void)startAddNewNoteAsPhotoWithSource:(UIImagePickerControllerSourceType)sourceType
					 previousScreenTitle:(NSString *)previousScreenTitle{
	[[VLMessageCenter shared] performBlock:^{
		if(sourceType == UIImagePickerControllerSourceTypeCamera) {
			YTImagePickerController *picker = [[[YTImagePickerController alloc] init] autorelease];
			picker.canPickVideo = kYTResourceCanPickVideo;
			[picker showWithSource:sourceType
					fromParentView:nil
							  rect:CGRectZero
					   orBarButton:nil
					   resultBlock:^(UIImage *image)
			{
				if(!image)
					return;
				if(sourceType == UIImagePickerControllerSourceTypeCamera)
					[self saveTakenPhotoToCameraRoll:image];
				
				YTNoteInfo *newNote = [[[YTNoteInfo alloc] init] autorelease];
				newNote.noteGuid = [[VLGuid makeUnique] yoditoToString];
				newNote.createdDate = newNote.lastUpdateTS = [VLDate date];
				YTNotebookInfo *notebook = [[YTUiMediator shared] notebookForNewNotes];
				newNote.notebookGuid = notebook.notebookGuid;
				newNote.notebookId = notebook.notebookId;
				
				[[VLActivityScreen shared] startActivity];
				YTNoteEditInfo *noteEditInfo = [[[YTNoteEditInfo alloc] init] autorelease];
				[noteEditInfo initializeWithNoteOriginal:newNote isNewNote:YES resultBlock:^
				{
					[[VLActivityScreen shared] stopActivity];
					YTNoteEditView *noteEditView = [[[YTNoteEditView alloc] initWithFrame:CGRectZero] autorelease];
					noteEditView.isNewNote = YES;
					noteEditView.startEditTitleAfterOpen = YES;
					noteEditView.delegate = self;
					[noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
                    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                    {
                        [[AppDelegate instance]addSubviewToDetailView:noteEditView];
                        
                        
                    }
                    else{
                        [self pushNewNoteEditView:noteEditView];}
					[noteEditView addResourceWithImage:image orVideo:nil resultBlock:^{
					}];
				}];
			}];
		} else {
			YTELCImagePickerController *picker = [[[YTELCImagePickerController alloc] init] autorelease];
			[picker showWithResultBlock:^(NSArray *assets) {
				if(!assets.count)
					return;
				YTNoteInfo *newNote = [[[YTNoteInfo alloc] init] autorelease];
				newNote.noteGuid = [[VLGuid makeUnique] yoditoToString];
				newNote.createdDate = newNote.lastUpdateTS = [VLDate date];
				YTNotebookInfo *notebook = [[YTUiMediator shared] notebookForNewNotes];
				newNote.notebookGuid = notebook.notebookGuid;
				newNote.notebookId = notebook.notebookId;
				
				[[VLActivityScreen shared] startActivity];
				YTNoteEditInfo *noteEditInfo = [[[YTNoteEditInfo alloc] init] autorelease];
				[noteEditInfo initializeWithNoteOriginal:newNote isNewNote:YES resultBlock:^
				{
					[[VLActivityScreen shared] stopActivity];
					YTNoteEditView *noteEditView = [[[YTNoteEditView alloc] initWithFrame:CGRectZero] autorelease];
					noteEditView.isNewNote = YES;
					noteEditView.startEditTitleAfterOpen = YES;
					noteEditView.delegate = self;
					[noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
                    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                    {
                        [[AppDelegate instance]addSubviewToDetailView:noteEditView];
                        
                        
                    }
                    else{
                        [self pushNewNoteEditView:noteEditView];}
					[noteEditView addImagesFromAssets:assets];
				}];
			}];
		}
	} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
}

- (void)startAddNewNoteAsPhoto:(BOOL)asPhoto
				 notebookGuid:(NSString *)notebookGuid
					isStarred:(BOOL)isStarred
		  previousScreenTitle:(NSString *)previousScreenTitle {
    
	YTNotebooksEnManager *manrEnBooks = [YTNotebooksEnManager shared];
	YTNotebookInfo *notebook = nil;
	if(![NSString isEmpty:notebookGuid])
		notebook = [manrEnBooks getNotebookByGuid:notebookGuid];
	if(!notebook)
		notebook = [[YTUiMediator shared] notebookForNewNotes];
	if(asPhoto) {
		if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			[self startAddNewNoteAsPhotoWithSource:UIImagePickerControllerSourceTypeSavedPhotosAlbum
							   previousScreenTitle:previousScreenTitle];
			return;
		}
		NSString *actionTake = NSLocalizedString(@"Take Photo", nil);
		NSString *actionChoose = NSLocalizedString(@"Choose From Library", nil);
		NSString *actionCancel = NSLocalizedString(@"Cancel {Button}", nil);
		VLActionSheet *actionSheet = [[[VLActionSheet alloc] init] autorelease];
		[actionSheet addButtonWithTitle:actionTake];
		[actionSheet addButtonWithTitle:actionChoose];
		[actionSheet addButtonWithTitle:actionCancel];
		actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
		[actionSheet showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle) {
			if([NSString isEmpty:btnTitle])
				return;
			if([btnTitle isEqual:actionTake]) {
				[self startAddNewNoteAsPhotoWithSource:UIImagePickerControllerSourceTypeCamera
								   previousScreenTitle:previousScreenTitle];
			} else if([btnTitle isEqual:actionChoose]) {
				[self startAddNewNoteAsPhotoWithSource:UIImagePickerControllerSourceTypeSavedPhotosAlbum
								   previousScreenTitle:previousScreenTitle];
			}
		}];
	} else {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"add"];
        
		//NSTimeInterval tm1 = [VLTimer systemUptime];
		YTNoteInfo *newNote = [[[YTNoteInfo alloc] init] autorelease];
		newNote.noteGuid = [[VLGuid makeUnique] yoditoToString];
		newNote.createdDate = newNote.lastUpdateTS = [VLDate date];
		newNote.notebookGuid = notebook.notebookGuid;
		newNote.notebookId = notebook.notebookId;
		if(isStarred)
			newNote.priorityId = EYTPriorityTypeHigh;
		
		[[VLActivityScreen shared] startActivity];
		YTNoteEditInfo *noteEditInfo = [[[YTNoteEditInfo alloc] init] autorelease];
		[noteEditInfo initializeWithNoteOriginal:newNote isNewNote:YES resultBlock:^
		{
			[[VLActivityScreen shared] stopActivity];
			YTNoteEditView *noteEditView = [[[YTNoteEditView alloc] initWithFrame:CGRectZero] autorelease];
			noteEditView.isNewNote = YES;
			noteEditView.startEditTitleAfterOpen = NO;
			noteEditView.delegate = self;
			[noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
            
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
            {
                [[AppDelegate instance]addSubviewToDetailView:noteEditView];
                
            
            }
            else{
                [self pushNewNoteEditView:noteEditView];
            }
		}];
	}
}

- (void)startEditNote:(YTNoteInfo *)note previousScreenTitle:(NSString *)previousScreenTitle {
	[[VLActivityScreen shared] startActivity];
	YTNoteEditInfo *noteEditInfo = [[[YTNoteEditInfo alloc] init] autorelease];
	[noteEditInfo initializeWithNoteOriginal:note isNewNote:NO resultBlock:^
	{
		[[VLActivityScreen shared] stopActivity];
		YTNoteEditView *noteEditView = [[[YTNoteEditView alloc] initWithFrame:CGRectZero] autorelease];
		noteEditView.startEditTitleAfterOpen = YES;
		noteEditView.delegate = self;
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            NSLog(@"veceu");
            [noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
            [[AppDelegate instance]changeTo:noteEditView];
        }
        else{
		[noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
            [[YTSlidingContainerView shared] showNoteEditView:noteEditView];}
	}];
}

- (void)noteEditView:(YTNoteEditView *)noteEditView finishWithAction:(EYTUserActionType)action {
	if(action == EYTUserActionTypeDone) {
		YTNoteInfo *note = noteEditView.noteEditInfo.noteLast;
		//note .isTemporary = NO;
		//[[YTNotesManager shared] addEntity:newNote];
		YTNoteInfoArgs *args = [[[YTNoteInfoArgs alloc] init] autorelease];
		args.note = note;
		[[YTUiMediator shared].msgrNoteAddedManually postMessageWithArgs:args];
	} else {
		
	}
	[[YTSlidingContainerView shared] closeNoteEditView:noteEditView];
	[[YTDatabaseManager shared] cleanDatabaseWithResultBlock:nil];
}

- (void)showNoteView:(YTNoteView *)noteView
	optionalFromCellView:(YTNoteTableCellView *)noteCellView
	optionalOnThumbsView:(YTPhotosThumbsView *)thumbsView
	optionalFromThumbView:(YTPhotosThumbsView_ThumbView *)thumbView {
	
	YTNoteInfo *note = noteView.note;
	// Opening note:
	NSMutableArray *imagesToShowInList = [NSMutableArray array];
	[imagesToShowInList addObjectsFromArray:[[YTResourcesEnManager shared] getResourcesForNoteWithGuid:note.noteGuid].allValues];
	for(int i = (int)imagesToShowInList.count - 1; i >= 0; i--) {
		YTResourceInfo *res = [imagesToShowInList objectAtIndex:i];
		if(!res.isImage || res.isThumbnail) {
			[imagesToShowInList removeObjectAtIndex:i];
			continue;
		}
	}
	BOOL needWaitForShowImage = (imagesToShowInList.count == 1);
	NSTimeInterval uptimeStart = [VLTimer systemUptime];
	__block BOOL activityShown = NO;
	NSTimeInterval delayBeforeShowActivity = 0.5;
	NSTimeInterval maxWaitFroShowImage = 2.0;
	
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
		NSTimeInterval uptime = [VLTimer systemUptime];
		if([noteView isNoteLoaded]) {
			if(needWaitForShowImage) {
				if([noteView isAllImagesShown])
					return YES;
				if(uptime >= (uptimeStart + maxWaitFroShowImage))
					return YES;
			} else
				return YES;
		}
		if(!activityShown && uptime >= (uptimeStart + delayBeforeShowActivity)) {
			[[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Opening", nil)];
			activityShown = YES;
		}
		return NO;
	} ignoringTouches:YES completeBlock:^{
		// Wait a little, let new view be drawn:
		[[VLMessageCenter shared] performBlock:^{
			if(activityShown)
				[[VLActivityScreen shared] stopActivity];
			
			if(noteCellView) {
				[[YTSlidingContainerView shared] showNoteView:noteView fromCellView:noteCellView];
			} else if(thumbsView && thumbView) {
				[[YTSlidingContainerView shared] showNoteView:noteView fromThumbView:thumbView];
			}
		}
		 afterDelay:kDefaultAnimationDuration/4 ignoringTouches:YES];
	}];
}

- (void)saveTakenPhotoToCameraRoll:(UIImage *)image {
	if(!image)
		return;
	if(![YTSettingsManager shared].saveTakenPhotosToCameraRoll)
		return;
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if(error)
		VLLoggerError(@"%@", error);
}

- (void)beginIsScrolling {
	_isScrollingCounter++;
	if(_isScrollingCounter == 1) {
		//VLLoggerTrace(@"");
		[_msgrScrollingEnded cancelPostMessage];
	}
}

- (void)endIsScrolling {
	if(_isScrollingCounter > 0) {
		_isScrollingCounter--;
		if(_isScrollingCounter == 0) {
			//VLLoggerTrace(@"");
			[_msgrScrollingEnded postMessage];
		}
	}
}

- (BOOL)isScrolling {
	return (_isScrollingCounter > 0);
}

- (void)dealloc {
	[_msgrNoteAddedManually release];
	[_msgrFileCantBeViewedAlerted release];
	[_msgrScrollingEnded release];
	[super dealloc];
}

@end

