
#import "YTNoteView.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "AppDelegate.h"
#define kMaxTitleHeight 100.0
#define kBorderY 5.0//2.0
#define kBorderX 7.0//3.0
#define kEdgeTop 0.0
#define kEdgeBottom 8.0//5.0
#define kEdgeX 15.0//7.0
#define kDividerHeight 4.0
#define kToolbarHeight 44.0
#define kToolButtonImageInsets UIEdgeInsetsMake(4, 4, 4, 4)
#define kBtnHeight 40.0 // Image - 32
#define kToolbarItemsDistance 8.0
#define kMaxWebViewHeight 2000

#define kAllowEmbedOwnPhotoToHtml YES
#define kAllowEmbedOwnVideoToHtml YES//NO

#define kLoadWebViewSyncroniously NO//YES//NO

#define kWebContentTouchBorders NO//YES

@interface YTNoteView()

@end



@implementation YTNoteView_SeeMorePhotosView_ShadowView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = YES;
	self.contentMode = UIViewContentModeRedraw;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGPoint pt1 = CGPointMake(CGRectGetMidX(rcBnds), CGRectGetMidY(rcBnds));
	CGPoint pt2 = CGPointMake(CGRectGetMaxX(rcBnds), CGRectGetMaxY(rcBnds));
	UIColor *col1 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
	UIColor *col2 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[VLGraphicsUtils context:ctx drawLinearGradientWithColor1:col1 color2:col2 point1:pt1 point2:pt2];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return nil;
}

@end

@implementation YTNoteView_SeeMorePhotosView

@synthesize delegate = _delegate;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	
	_shadowView = [[YTNoteView_SeeMorePhotosView_ShadowView alloc] initWithFrame:CGRectZero];
	[self addSubview:_shadowView];
	
	_iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
	_iconView.backgroundColor = [UIColor clearColor];
	_iconView.contentMode = UIViewContentModeCenter;
	_iconView.image = [UIImage imageNamed:@"more_photos.png"];
	[self addSubview:_iconView];
	
	_lbTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_lbTitle.backgroundColor = [UIColor clearColor];
	_lbTitle.textAlignment = NSTextAlignmentRight;
	_lbTitle.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_lbTitle.textColor = [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0];
	[self addSubview:_lbTitle];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
}

- (void)updateFonts:(id)sender {
	_lbTitle.font = [[YTFontsManager shared] fontWithSize:15];
	[self setNeedsLayout];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	CGPoint pt = [[touches anyObject] locationInView:self];
	CGRect rect = self.bounds;
	if(CGRectContainsPoint(rect, pt)) {
		if(_delegate && [_delegate respondsToSelector:@selector(seeMorePhotosView:tapped:)])
			[_delegate seeMorePhotosView:self tapped:nil];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	float spaceX = 8.0;
	CGRect rcTitle = rcBnds;
	rcTitle.size.width = [_lbTitle.text vlSizeWithFont:_lbTitle.font].width;
	rcTitle.origin.x = CGRectGetMaxX(rcBnds) - spaceX - rcTitle.size.width;
	rcTitle.origin.y += 0;
	_lbTitle.frame = [UIScreen roundRect:rcTitle];
	CGRect rcIcon = rcBnds;
	rcIcon.size.width = rcIcon.size.height;
	rcIcon.origin.x = rcTitle.origin.x - spaceX * 0.0 - rcIcon.size.width;
	rcIcon.origin.y += 2;
	_iconView.frame = [UIScreen roundRect:rcIcon];
	CGRect rcShadow = rcBnds;
	rcShadow.size.width = CGRectGetMaxX(rcBnds) - rcIcon.origin.x + rcBnds.size.height;
	rcShadow.size.height = rcShadow.size.width;
	rcShadow.origin.x = CGRectGetMaxX(rcBnds) - rcShadow.size.width;
	rcShadow.origin.y = CGRectGetMaxY(rcBnds) - rcShadow.size.height;
	_shadowView.frame = [UIScreen roundRect:rcShadow];
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = MAX((int)([_lbTitle sizeOfText].height), _iconView.image.size.height);
	return size;
}


- (void)setTitle:(NSString *)title {
	if(!title)
		title = @"";
	if(![_lbTitle.text isEqual:title]) {
		_lbTitle.text = title;
		[self setNeedsLayout];
	}
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[_lbTitle release];
	[_iconView release];
	[_shadowView release];
	[super dealloc];
}

@end






@implementation YTNoteView_ContentView

@synthesize text = _lastText;
@synthesize textView = _textView;
@synthesize resourcesListView = _resourcesListViewImages;

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTViewBackColor;
	_resourcesReferences = [[NSMutableArray alloc] init];
	_resourcesToShowInList = [[NSMutableArray alloc] init];
	//_resourcesToShowInListNotDownloaded = [[NSMutableArray alloc] init];
	
	_resourcesListViewImages = [[YTNoteResourcesListView alloc] initWithFrame:CGRectZero];
	_resourcesListViewImages.delegate = self;
	[self addSubview:_resourcesListViewImages];
	
	_seeMorePhotosView = [[YTNoteView_SeeMorePhotosView alloc] initWithFrame:CGRectZero];
	_seeMorePhotosView.hidden = YES;
	_seeMorePhotosView.delegate = self;
	[self addSubview:_seeMorePhotosView];

	_textView = [[UITextView alloc] initWithFrame:CGRectZero];
	_textView.backgroundColor = [UIColor clearColor];
	//_textView.numberOfLines = 0;
	//_textView.lineBreakMode = NSLineBreakByWordWrapping;
	_textView.hidden = YES;
	_textView.userInteractionEnabled = NO;
	[self addSubview:_textView];
	if(kIosVersionFloat >= 7.0) {
		NSLayoutManager *layoutManr = _textView.layoutManager;
		layoutManr.delegate = self;
	}
	_lastText = [@"" retain];
	
	_sepDateTop = [[YTNoteContentSeparator alloc] initWithFrame:CGRectZero];
	[self addSubview:_sepDateTop];
	
	_dateLabelView = [[YTNoteDateLabelView alloc] initWithFrame:CGRectZero];
	[self addSubview:_dateLabelView];
	
	_sepDateBot = [[YTNoteContentSeparator alloc] initWithFrame:CGRectZero];
	[self addSubview:_sepDateBot];
	
	_tagsLineView = [[YTTagsLineView alloc] initWithFrame:CGRectZero];
	_tagsLineView.hidden = YES;
	[self addSubview:_tagsLineView];
	
	_locationLabelView = [[YTNoteLocationLabelView alloc] initWithFrame:CGRectZero];
	_locationLabelView.hidden = YES;
	[self addSubview:_locationLabelView];
	
	_sepLocBot = [[YTNoteContentSeparator alloc] initWithFrame:CGRectZero];
	_sepLocBot.hidden = YES;
	[self addSubview:_sepLocBot];
	
	_resourcesListViewDocs = [[YTNoteResourcesListView alloc] initWithFrame:CGRectZero];
	_resourcesListViewDocs.delegate = self;
	_resourcesListViewDocs.hidden = YES;
	[self addSubview:_resourcesListViewDocs];
	
	_sepDocsBot = [[YTNoteContentSeparator alloc] initWithFrame:CGRectZero];
	_sepDocsBot.hidden = YES;
	[self addSubview:_sepDocsBot];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[[YTLocationsEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTTagsEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[[YTResourcesEnManager shared].msgrVersionChanged addObserver:self selector:@selector(updateViewAsync)];
	[self updateFonts:self];
	
	[self updateViewAsync];
}

- (UIFont *)fontForText {
	return [[YTFontsManager shared] fontWithSize:16];
}

- (UIFont *)fontForTextBold {
	return [[YTFontsManager shared] boldFontWithSize:16];
}

- (void)updateFonts:(id)sender {
	_textView.font = [self fontForText];
	[self setNeedsLayout];
}

- (void)waitForLoadNoteWithResultBlock:(VLBlockVoid)resultBlock {
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
		return _contentWasLoaded;
	} ignoringTouches:NO completeBlock:^{
		resultBlock();
	}];
}

- (BOOL)isNoteLoaded {
	return _contentWasLoaded;
}

- (BOOL)isAllImagesShown {
	return [_resourcesListViewImages isAllImagesShown];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	/*CGPoint curOffset = scrollView.contentOffset;
	CGPoint newOffset = curOffset;
	newOffset.y = 0;
	if(!CGPointEqualToPoint(curOffset, newOffset))
		scrollView.contentOffset = newOffset;*/
}

- (YTNoteView *)parentNoteView {
	YTNoteView *res = (YTNoteView *)[VLCtrlsUtils getParentViewOfClass:[YTNoteView class] ofView:self];
	return res;
}

- (void)onUpdateView {
	[super onUpdateView];
	YTNoteInfo *note = self.note;
	if(!note)
		return;
	YTNoteView *parentNoteView = [self parentNoteView];
	if(!parentNoteView)
		return;
	
	YTLocationInfo *location = [[YTLocationsEnManager shared] getLocationByNoteGuid:note.noteGuid];
	_locationLabelView.visible = (location != nil);
	_sepLocBot.visible = _locationLabelView.visible;
	
	if(_tagsLineView)
		_tagsLineView.visible = [[YTTagsEnManager shared] hasTagsByNoteGuid:note.noteGuid];
	
	//BOOL needUpdateEmbeddedResources = NO;
	//for(YTResourceInfo *res in _resourcesToShowInListNotDownloaded)
	//	if([[YTResourcesStorage shared] isResourceDownloadedWithHash:res.attachmenthash])
	//		needUpdateEmbeddedResources = YES;
	
	if(_textView)
		_textView.hidden = NO;

	//NSString *noteContentHash = note.contentHash;
	//if(![_lastNoteContentHash isEqual:noteContentHash] || needUpdateEmbeddedResources) {
	//	[_lastNoteContentHash release];
	//	_lastNoteContentHash = [noteContentHash retain];
		
		[[YTNotesContentEnManager shared] readNoteContentForNoteWithGuid:note.noteGuid waitingUntilDone:NO resultBlock:^(YTNoteContentInfo *entity)
		{
			NSString *contentTextOrig = entity ? entity.content : @"";
			NSString *text1 = contentTextOrig;
			if([[YTNoteHtmlParser shared] isNoteTextHtml:text1])
				text1 = [[YTNoteHtmlParser shared] plainTextFromHtml:contentTextOrig];
			if([NSString isEmpty:text1])
				text1 = note.titlePlaceholder;
			if(![_lastText isEqual:text1]) {
				[_lastText release];
				_lastText = [text1 retain];
				//_textView.text = text1;
				NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:_lastText] autorelease];
				if(_lastText.length) {
					NSString *firstLine = [YTUiCommon extractFirstNoteTextLine:_lastText];
					if(![NSString isEmpty:firstLine]) {
						NSDictionary *attrsNorm = @{NSFontAttributeName : _textView.font,
													NSForegroundColorAttributeName : kYTNoteTitleColor};
						NSMutableParagraphStyle *style  = [[[NSMutableParagraphStyle alloc] init] autorelease];
						style.paragraphSpacing = kYTNoteTitleLineSpacingCapitalLineAddition;
						NSDictionary *attrsBold = @{NSFontAttributeName : [self fontForTextBold],
													NSForegroundColorAttributeName : kYTNoteCapitalTitleColor,
													NSParagraphStyleAttributeName : style};
						[str setAttributes:attrsBold range:NSMakeRange(0, firstLine.length)];
						[str setAttributes:attrsNorm range:NSMakeRange(firstLine.length, _lastText.length - firstLine.length)];
						_hasCapitalLine = YES;
					} else {
						NSDictionary *attrs = @{NSFontAttributeName : _textView.font, NSForegroundColorAttributeName : kYTNoteTitleColor};
						[str setAttributes:attrs range:NSMakeRange(0, _lastText.length)];
						_hasCapitalLine = NO;
					}
				}
				[_textView setAttributedText:str];
				[parentNoteView setNeedsLayout];
				[self setNeedsLayout];
			}
			_contentWasLoaded = YES;
		}];
	//}
	
	NSMutableArray *resourcesToShowInList = [NSMutableArray array];
	[resourcesToShowInList addObjectsFromArray:[[YTResourcesEnManager shared] getResourcesForNoteWithGuid:note.noteGuid].allValues];
	[resourcesToShowInList sortUsingComparator:^NSComparisonResult(YTResourceInfo *obj1, YTResourceInfo *obj2) {
		if(obj1.isImage && !obj2.isImage)
			return -1;
		if(!obj1.isImage && obj2.isImage)
			return 1;
		return -[obj1.lastUpdateTS compare:obj2.lastUpdateTS];
	}];
	for(int i = (int)resourcesToShowInList.count - 1; i >= 0; i--) {
		YTResourceInfo *res = [resourcesToShowInList objectAtIndex:i];
		if(res.isTemporary) {
			[resourcesToShowInList removeObjectAtIndex:i];
			continue;
		}
		if(![[YTResourcesStorage shared] isResourceDownloadedWithHash:res.attachmenthash]) {
			[resourcesToShowInList removeObjectAtIndex:i];
			continue;
		}
		if(res.isThumbnail) {
			[resourcesToShowInList removeObjectAtIndex:i];
			continue;
		}
	}
	NSMutableArray *resourcesReferences = [NSMutableArray array];
	for(YTResourceInfo *res in resourcesToShowInList) {
		NSString *resourceHash = res.attachmenthash;
		YTResourceLoadingReference *ref = nil;
		for(YTResourceLoadingReference *obj in _resourcesReferences)
			if([obj.resourceHash isEqual:resourceHash])
				ref = obj;
		if(!ref) {
			ref = [[[YTResourceLoadingReference alloc] init] autorelease];
			if([res isImage])
				[ref setResourceHash:resourceHash andType:res.attachmentTypeName categoryId:(int)res.attachmentCategoryId];
		}
		[resourcesReferences addObject:ref];
	}
	if(![_resourcesReferences isEqualToArray:resourcesReferences]) {
		[_resourcesReferences removeAllObjects];
		[_resourcesReferences addObjectsFromArray:resourcesReferences];
	}
	
	if(![_resourcesToShowInList isEqual:resourcesToShowInList]) {
		[_resourcesToShowInList removeAllObjects];
		[_resourcesToShowInList addObjectsFromArray:resourcesToShowInList];
		NSMutableArray *arrResImages = [NSMutableArray array];
		NSMutableArray *arrResNonImages = [NSMutableArray array];
		for(YTResourceInfo *res in _resourcesToShowInList) {
			if(res.isImage && res.isThumbnail)
				continue;
			if(res.isTemporary)
				continue;
			if(![[YTResourcesStorage shared] isResourceDownloadedWithHash:res.attachmenthash])
				continue;
			if([NSString isEmpty:res.filename])
				continue;
			if(res.isImage) {
				[arrResImages addObject:res];
			} else {
				[arrResNonImages addObject:res];
			}
		}
		_resourcesListViewImages.resources = arrResImages;
		_resourcesListViewDocs.resources = arrResNonImages;
		_resourcesListViewDocs.visible = arrResNonImages.count > 0;
		_sepDocsBot.visible = _resourcesListViewDocs.visible;
		[parentNoteView setNeedsLayout];
	}
	//[_resourcesToShowInListNotDownloaded removeAllObjects];
	//for(YTResourceInfo *res in _resourcesToShowInList)
	//	if(![[YTResourcesStorage shared] isResourceDownloadedWithHash:res.attachmenthash])
	//		[_resourcesToShowInListNotDownloaded addObject:res];
	
	int curImagesCount = 0;
	for(YTResourceInfo *res in resourcesToShowInList) {
		if(res.isThumbnail)
			continue;
		if(res.isImage) {
			curImagesCount++;
		} else {
			break;
		}
	}
    int mx;
    if (IsUiIPad)
        mx = kYTMaxPhotosToShowOnNoteView;
        else
            mx = 4;
	int maxPhotosToShow = _showAllPhotos ? 999999 : mx;
	[_resourcesListViewImages setMaxPhotosToShow:maxPhotosToShow];
	_seeMorePhotosView.hidden = !(curImagesCount > maxPhotosToShow);
	if(!_seeMorePhotosView.hidden) {
		NSString *sTitle = [NSString stringWithFormat:@"+%d", curImagesCount - maxPhotosToShow];
		[_seeMorePhotosView setTitle:sTitle];
	}
	
	[parentNoteView setNeedsLayout];
	[self setNeedsLayout];
}

- (void)onNoteDataChanged {
	[super onNoteDataChanged];
	_dateLabelView.note = self.note;
	_locationLabelView.note = self.note;
	if(_tagsLineView)
		_tagsLineView.note = self.note;
	[self updateViewAsync];
}

- (void)onNotesContentManagerChanged {
	[super onNotesContentManagerChanged];
	[self updateViewAsync];
	[self setNeedsLayout];
}

- (void)onResourcesManagerChanged {
	[super onResourcesManagerChanged];
	[self updateViewAsync];
}

- (void)checkTextViewHeightForWidth:(float)width {
	/*CGSize szText = [_textView.text vlSizeWithFont:_textView.font
							   constrainedToSize:CGSizeMake(width, 1000)
								   lineBreakMode:NSLineBreakByWordWrapping];*/
	//CGSize szText = [_textView sizeThatFits:CGSizeMake(width, INT_MAX)];
	CGSize szText = [_lastText vlSizeWithFont:_textView.font
								 constrainedToSize:CGSizeMake(width, 10000)
									 lineBreakMode:NSLineBreakByWordWrapping];
	// Adjustment for kYTNoteTitleLineSpacing:
	float nLines = ceil(szText.height / [@"A" vlSizeWithFont:_textView.font].height);
	szText.height += nLines * kYTNoteTitleLineSpacing;
	if(_hasCapitalLine)
		szText.height += kYTNoteTitleLineSpacingCapitalLineAddition;
	_heightOfTextView = szText.height;
}

- (float)heightForTextView {
	float res = _heightOfTextView + 30;
	return res;
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = 0;
	YTNoteInfo *note = self.note;
	if(!note)
		return size;
	
	size.height += kEdgeTop;
	
	CGSize szCtrls = size;
	szCtrls.width = size.width - kEdgeX * 2;
	
	size.height += kDividerHeight + kBorderY;
	
	if(_dateLabelView.visible) {
		size.height += [_sepDateTop sizeThatFits:szCtrls].height;
		size.height += [_dateLabelView sizeThatFits:szCtrls].height + kBorderY;
		size.height += [_sepDateBot sizeThatFits:szCtrls].height;
	}
	
	if(_tagsLineView && _tagsLineView.visible)
		size.height += [_tagsLineView sizeThatFits:szCtrls].height + kBorderY;
	
	if(_locationLabelView.visible) {
		size.height += [_locationLabelView sizeThatFits:szCtrls].height + kBorderY;
		size.height += [_sepLocBot sizeThatFits:szCtrls].height;
	}
	
	[self checkTextViewHeightForWidth:szCtrls.width];
	
	size.height += [self heightForTextView];
	
	size.height += ceil([_resourcesListViewImages sizeThatFits:size].height);
	
	if(_resourcesListViewDocs.visible) {
		size.height += [_resourcesListViewDocs sizeThatFits:szCtrls].height + kBorderY;
		size.height += [_sepDocsBot sizeThatFits:szCtrls].height;
	}
	
	size.height += kEdgeBottom;
	
	// Add spare size:
	size.height += kBorderY * 5;
	
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	YTNoteInfo *note = self.note;
	if(!note)
		return;
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, UIEdgeInsetsMake(kEdgeTop, kEdgeX, kEdgeBottom, kEdgeX));
	
	CGRect rcResListImages = rcCtrls;
	rcResListImages.origin.x = rcBnds.origin.x;
	rcResListImages.size.width = rcBnds.size.width;
	rcResListImages.size.height = ceil([_resourcesListViewImages sizeThatFits:CGSizeMake(rcResListImages.size.width, INT_MAX/2)].height);
		
	CGRect rcSeeMorePhotos = rcResListImages;
	rcSeeMorePhotos.size.height = [_seeMorePhotosView sizeThatFits:rcSeeMorePhotos.size].height;
	rcSeeMorePhotos.origin.y = CGRectGetMaxY(rcResListImages) - rcSeeMorePhotos.size.height;
	_seeMorePhotosView.frame = rcSeeMorePhotos;
	
	CGRect rcTextViewAll = rcCtrls;
	rcTextViewAll.origin.y = CGRectGetMaxY(rcResListImages) + kBorderY;
	rcTextViewAll.size.height = [self heightForTextView];
	rcTextViewAll.origin.x = rcBnds.origin.x;
	rcTextViewAll.size.width = rcBnds.size.width;
	
	CGRect rcSepDateTop = rcCtrls;
	rcSepDateTop.origin.y = CGRectGetMaxY(rcTextViewAll) + kBorderY;
	rcSepDateTop.size.height = 0;
	CGRect rcDate = rcCtrls;
	rcDate.origin.y = CGRectGetMaxY(rcSepDateTop);
	rcDate.size.height = 0;
	CGRect rcSetDateBot = rcCtrls;
	rcSetDateBot.origin.y = CGRectGetMaxY(rcDate);
	rcSetDateBot.size.height = 0;
	if(_dateLabelView.visible) {
		rcSepDateTop.size.height = [_sepDateTop sizeThatFits:rcSepDateTop.size].height;
		rcDate.origin.y = CGRectGetMaxY(rcSepDateTop);
		rcDate.size.height = [_dateLabelView sizeThatFits:rcDate.size].height;
		rcSetDateBot.origin.y = CGRectGetMaxY(rcDate);
		rcSetDateBot.size.height = [_sepDateBot sizeThatFits:rcSetDateBot.size].height;
	}
	
	CGRect rcLocation = rcCtrls;
	rcLocation.origin.y = CGRectGetMaxY(rcSetDateBot);
	rcLocation.size.height = 0;
	CGRect rcSepLoc = rcCtrls;
	rcSepLoc.origin.y = CGRectGetMaxY(rcLocation);
	rcSepLoc.size.height = 0;
	if(_locationLabelView.visible) {
		rcLocation.size.height = [_locationLabelView sizeThatFits:rcLocation.size].height;
		rcSepLoc.origin.y = CGRectGetMaxY(rcLocation);
		rcSepLoc.size.height = [_sepLocBot sizeThatFits:rcSepLoc.size].height;
	}
	
	CGRect rcResListDocs = rcCtrls;
	rcResListDocs.origin.y = CGRectGetMaxY(rcSepLoc);
	//rcResListDocs.origin.x = rcBnds.origin.x;
	//rcResListDocs.size.width = rcBnds.size.width;
	rcResListDocs.size.height = 0;
	CGRect rcSepDocs = rcCtrls;
	rcSepDocs.origin.y = CGRectGetMaxY(rcResListDocs);
	rcSepDocs.size.height = 0;
	if(_resourcesListViewDocs.visible) {
		rcResListDocs.size.height = ceil([_resourcesListViewDocs sizeThatFits:CGSizeMake(rcResListDocs.size.width, INT_MAX/2)].height);
		rcSepDocs.origin.y = CGRectGetMaxY(rcResListDocs);
		rcSepDocs.size.height = [_sepDocsBot sizeThatFits:rcSepDocs.size].height;
	}
	
	CGRect rcTags = rcCtrls;
	rcTags.origin.y = CGRectGetMaxY(rcSepDocs);
	rcTags.size.height = 0;
	if(_tagsLineView && _tagsLineView.visible)
		rcTags.size.height = [_tagsLineView sizeThatFits:rcTags.size].height;
	
	_resourcesListViewImages.frame = rcResListImages;
	_sepDateTop.frame = rcSepDateTop;
	_dateLabelView.frame = rcDate;
	_sepDateBot.frame = rcSetDateBot;
	_locationLabelView.frame = rcLocation;
	_sepLocBot.frame = rcSepLoc;
	_resourcesListViewDocs.frame = rcResListDocs;
	_sepDocsBot.frame = rcSepDocs;
	if(_tagsLineView)
		_tagsLineView.frame = rcTags;
	
	/*CGRect rcTextViewAll = rcCtrls;
	rcTextViewAll.origin.y = CGRectGetMaxY(rcTags) + kBorderY;
	rcTextViewAll.size.height = [self heightForTextView];
	rcTextViewAll.origin.x = rcBnds.origin.x;
	rcTextViewAll.size.width = rcBnds.size.width;*/
	
	if(_textView) {
		CGRect rcTextView = rcTextViewAll;
		rcTextView.origin.x += kEdgeX;
		rcTextView.size.width -= kEdgeX * 2;
		// Corrections:
		float dy = -5;
		rcTextView.origin.y += dy;
		rcTextView.size.height -= dy;
		float dx = -1;
		rcTextView.origin.x += dx;
		rcTextView.size.width -= dx;
		if(_textView.superview == self)
			_textView.frame = rcTextView;
	}
}

- (void)showAttachmentsWithCurrentResource:(YTResourceInfo *)resource {
	YTNoteAttachmentsView *view = [[[YTNoteAttachmentsView alloc] initWithFrame:self.bounds] autorelease];
	view.note = self.note;
	if(resource)
		[view setCurrentResource:resource];
	// Prepare for push, set frame:
	CGRect rcView = self.frame;
	rcView.origin.x += rcView.size.width;
	view.frame = rcView;
	VLDelayedScreenActivity *activity = [[VLDelayedScreenActivity alloc] init];
	[activity startActivityWithTitle:NSLocalizedString(@"Opening", nil) delay:kDefaultAnimationDuration
						 maxDuration:0.01//1.0
				 checkForCancelBlock:^BOOL
	{
		if(!resource || ![resource isImage] || ([resource isImage] && [view isCurrentImageResourceShown]) || [activity isMaxDurationExceeded]) {
			[[self parentContentView] pushView:view animated:YES];
			[activity cancelActivity];
			[activity release];
			return YES;
		}
		return NO;
	}];
    [[AppDelegate instance]changeTo:view];
}

- (void)noteResourcesListView:(YTNoteResourcesListView *)noteResourcesListView rowTapped:(YTNoteResourceRowView *)rowView {
	if(noteResourcesListView == _resourcesListViewImages || kYTAllowOpenNonImageResources) {
		YTResourceInfo *resource = rowView.resource;
		[self showAttachmentsWithCurrentResource:resource];
	}
}

- (void)seeMorePhotosView:(YTNoteView_SeeMorePhotosView *)view tapped:(id)param {
	/*if(!_showAllPhotos) {
		_showAllPhotos = YES;
		[self updateViewAsync];
	}*/
	[self showAttachmentsWithCurrentResource:nil];
}

- (BOOL)isImageExtention:(NSString*)sExt {
	YTResourceTypeInfo *info = [YTResourceTypeInfo infoByFileExt:sExt];
	if(info && info.categoryType == EYTResourceCategoryTypeImage)
		return YES;
	return NO;
}

- (BOOL)isVideoExtention:(NSString*)sExt {
	YTResourceTypeInfo *info = [YTResourceTypeInfo infoByFileExt:sExt];
	if(info && info.categoryType == EYTResourceCategoryTypeVideo)
		return YES;
	return NO;
}

#pragma mark NSLayoutManagerDelegate Delegate

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
	return kYTNoteTitleLineSpacing;
}

#pragma mark -

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTLocationsEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTTagsEnManager shared].msgrVersionChanged removeObserver:self];
	[[YTResourcesEnManager shared].msgrVersionChanged removeObserver:self];
	[_sepDateTop release];
	[_dateLabelView release];
	[_sepDateBot release];
	[_locationLabelView release];
	[_sepLocBot release];
	[_tagsLineView release];
	[_textView release];
	[_lastText release];
	[_resourcesListViewImages release];
	[_seeMorePhotosView release];
	[_resourcesListViewDocs release];
	[_sepDocsBot release];
	[_resourcesReferences release];
	[_resourcesToShowInList release];
	//[_resourcesToShowInListNotDownloaded release];
	[super dealloc];
}

@end




@implementation YTNoteView

@synthesize delegate = _delegate;
@synthesize contentView = _contentView;
@dynamic mainResource;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];// kYTViewBackColor;
	_backView = [[UIView alloc] initWithFrame:CGRectZero];
	_backView.backgroundColor = kYTViewBackColor;
	[self addSubview:_backView];
	CGRect rcBar = self.bounds;
	rcBar.size.height = 0;
    self.customNavBar.btnBack.hidden = NO;
	self.customNavBar.btnRight.hidden = NO;
    
    [self.customNavBar.btnBack addTarget:self action:@selector(onBtnBackTap:) forControlEvents:UIControlEventTouchUpInside];
	[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Edit {Button}", nil) forState:UIControlStateNormal];
	[self.customNavBar.btnRight addTarget:self action:@selector(onBtnEditTap:) forControlEvents:UIControlEventTouchUpInside];
	self.customNavBar.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    if (IsUiIPad)
        self.customNavBar.btnBack.hidden=YES;
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	_toolbar = [[UIView alloc] initWithFrame:CGRectZero];
	_toolbar.backgroundColor = kYTViewBackColor;
	[self addSubview:_toolbar];
	_toolbarShown = YES;
	
	_btnDelete = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_btnDelete setImage:[UIImage imageNamed:@"button_toolbar_trash.png"] forState:UIControlStateNormal];
	[_btnDelete addTarget:self action:@selector(onBtnDeleteTap:) forControlEvents:UIControlEventTouchUpInside];
	[_btnDelete setImageEdgeInsets:kToolButtonImageInsets];
	_btnDelete.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[_toolbar addSubview:_btnDelete];
	
	_btnAdd = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_btnAdd setImage:[UIImage imageNamed:@"button_toolbar_add.png"] forState:UIControlStateNormal];
	[_btnAdd addTarget:self action:@selector(onBtnAddTap:) forControlEvents:UIControlEventTouchUpInside];
	[_btnAdd setImageEdgeInsets:kToolButtonImageInsets];
	_btnAdd.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[_toolbar addSubview:_btnAdd];
	
	_btnAction = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_btnAction setImage:[UIImage imageNamed:@"button_toolbar_action.png"] forState:UIControlStateNormal];
	[_btnAction addTarget:self action:@selector(onBtnActionTap:) forControlEvents:UIControlEventTouchUpInside];
	[_btnAction setImageEdgeInsets:kToolButtonImageInsets];
	_btnAction.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[_toolbar addSubview:_btnAction];
	
	_contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	_contentScrollView.delegate = self;
	_contentScrollView.alwaysBounceHorizontal = NO;
	_contentScrollView.alwaysBounceVertical = YES;
	[self addSubview:_contentScrollView];
	
	_contentView = [[YTNoteView_ContentView alloc] initWithFrame:CGRectZero];
	[_contentScrollView addSubview:_contentView];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	
	[self updateViewAsync];
}

- (void)updateFonts:(id)sender {
	[self setNeedsLayout];
}

- (YTResourceInfo *)mainResource {
	return _contentView.resourcesListView.mainResource;
}

- (void)setMainResource:(YTResourceInfo *)mainResource {
	_contentView.resourcesListView.mainResource = mainResource;
}

- (void)waitForLoadNoteWithResultBlock:(VLBlockVoid)resultBlock {
	[_contentView waitForLoadNoteWithResultBlock:^{
		resultBlock();
	}];
}

- (BOOL)isNoteLoaded {
	return [_contentView isNoteLoaded];
}

- (BOOL)isAllImagesShown {
	return [_contentView isAllImagesShown];
}

- (void)onUpdateView {
	[super onUpdateView];
	YTNoteInfo *note = self.note;
	if(note) {
		VLDate *createdDate = note.createdDate;
		NSDateFormatter *frm = [[[NSDateFormatter alloc] init] autorelease];
		frm.timeStyle = NSDateFormatterNoStyle;
		frm.dateStyle = NSDateFormatterMediumStyle;
		self.customNavBar.titleLabel.text = [frm stringFromDate:[createdDate toNSDate]];
		/*NSDateFormatter *frmTime = [[[NSDateFormatter alloc] init] autorelease];
		frmTime.dateStyle = NSDateFormatterNoStyle;
		frmTime.timeStyle = NSDateFormatterShortStyle;
		NSString *sTime = [frmTime stringFromDate:[createdDate toNSDate]];
		NSDateFormatter *frmDate = [[[NSDateFormatter alloc] init] autorelease];
		frmDate.timeStyle = NSDateFormatterNoStyle;
		frmDate.dateFormat = @"EEEE, MMMM dd, yyyy";
		NSString *sDate = [frmDate stringFromDate:[createdDate toNSDate]];
		NSString *sTitle = [NSString stringWithFormat:@"%@ %@", sTime, sDate];
		sTitle = [sTitle uppercaseString];
		self.customNavBar.titleLabel.text = sTitle;*/
	}
	[self setNeedsLayout];
}

- (void)onNoteDataChanged {
	[super onNoteDataChanged];
	[self updateViewAsync];
	_contentView.note = self.note;
	[self setNeedsLayout];
}

/*- (void)onManagerChanged:(id)sender {
	[self updateViewAsync];
	[self setNeedsLayout];
}*/

- (void)onNotesContentManagerChanged {
	[super onNotesContentManagerChanged];
	[self updateViewAsync];
	[self setNeedsLayout];
}

- (void)onResourcesManagerChanged {
	[super onResourcesManagerChanged];
	[self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = [self boundsNoBars];
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	_backView.frame = rcBnds;
	CGRect rcToolbar = rcBnds;
	rcToolbar.size.height = kToolbarHeight;
	rcToolbar.origin.y = CGRectGetMaxY(rcBnds) - rcToolbar.size.height;
	//CGRect frameToolbar = rcToolbar;
	//UIView *toolbarSuperview = _toolbar.superview;
	//if(toolbarSuperview != self && toolbarSuperview) {
	//	frameToolbar = [self convertRect:rcToolbar toView:toolbarSuperview];
	//	//frameToolbar.origin.y += 20;
	//}
	
	if(!_toolbarShown)
		rcToolbar.origin.y += rcToolbar.size.height;
	
	_toolbar.frame = [UIScreen roundRect:rcToolbar];
	
	CGRect rcToolBtns = rcToolbar;
	rcToolBtns.origin.x += kToolbarItemsDistance;
	rcToolBtns.size.width -= kToolbarItemsDistance * 2;
	
	CGRect rcBtn = rcToolBtns;
	rcBtn.size.height = rcBtn.size.width = kBtnHeight;
	rcBtn.origin.y = CGRectGetMidY(rcToolbar) - rcBtn.size.height/2;
	_btnDelete.frame = [UIScreen roundRect:[self convertRect:rcBtn toView:_toolbar]];
	
	rcBtn.origin.x = CGRectGetMidX(rcToolBtns) - rcBtn.size.width/2;
	_btnAdd.frame = [UIScreen roundRect:[self convertRect:rcBtn toView:_toolbar]];
	
	rcBtn.origin.x = CGRectGetMaxX(rcToolBtns) - rcBtn.size.width;
	_btnAction.frame = [UIScreen roundRect:[self convertRect:rcBtn toView:_toolbar]];
	
	CGRect rcCtrls = rcBnds;
	rcCtrls.size.height = rcToolbar.origin.y - rcCtrls.origin.y;
	rcCtrls = CGRectInset(rcCtrls, 0, 0);
	
	CGRect rcContentScroll = rcCtrls;
	CGSize szContent = rcContentScroll.size;
	szContent = [_contentView sizeThatFits:szContent];
	szContent.width = round(szContent.width);
	szContent.height = round(szContent.height);

	if(!CGRectEqualToRect(_contentScrollView.frame, rcContentScroll))
		_contentScrollView.frame = rcContentScroll;
	_contentView.frame = CGRectMake(_contentView.frame.origin.x, _contentView.frame.origin.y, szContent.width, szContent.height);
	_contentScrollView.contentSize = szContent;
	
	if(_statusBarBackViewMNV) {
		float statusBarHeight = MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
		if(statusBarHeight == 0)
			statusBarHeight = 20.0;
		UIView *homeView = [VLAppDelegateBase sharedAppDelegateBase].rootViewController.view;
		CGRect rect = self.bounds;
		rect.size.height = statusBarHeight;
		rect.origin.y -= rect.size.height;
		rect = [self convertRect:rect toView:homeView];
		_statusBarBackViewMNV.frame = rect;
		if(_statusBarBackViewMNV.superview != homeView)
			[homeView addSubview:_statusBarBackViewMNV];
	}
}

/*- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(self.customNavBarCreated && self.customNavBar.alpha == 0.0)
		return nil;
	return [super hitTest:point withEvent:event];
}*/

- (void)onBecomeTopAgainInNavigation {
	[super onBecomeTopAgainInNavigation];
	//if(_noteEditView)
	//	[_noteEditView onBecomeTopAgainInNavigation];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _contentView;
}

- (void)closeWithAction:(EYTUserActionType)action {
	if(_delegate)
		[_delegate noteView:self finishWithAction:action];
}

- (void)onBtnBackTap:(id)sender {
	[self closeWithAction:EYTUserActionTypeDone];
    NSLog(@"pizda");
}

- (void)close {
	[self onBtnBackTap:self];
}

- (void)onBtnEditTap:(id)sender {
	YTNoteInfo *note = self.note;
	[[YTUiMediator shared] startEditNote:note
					 previousScreenTitle:self.customNavBar.titleLabel.text];
}

- (void)onBtnDeleteTap:(id)sender {
	
	if(_delegate)
		[_delegate noteView:self finishWithAction:EYTUserActionTypeDelete];
}

- (void)onBtnAddTap:(id)sender {
	[[YTUiMediator shared] startAddNewNoteAsPhoto:NO
									 notebookGuid:self.note.notebookGuid
										isStarred:NO
							  previousScreenTitle:self.customNavBar.titleLabel.text];
}

- (void)onBtnActionTap:(id)sender {
	YTNoteInfo *note = self.note;
	
	NSMutableString *sSubject = [NSMutableString string];
	[sSubject appendString:kYTAppName];
	[sSubject appendString:@" "];
	[sSubject appendString:NSLocalizedString(@"Note", nil)];
	[sSubject appendString:@": "];
	NSDateFormatter *frm = [[[NSDateFormatter alloc] init] autorelease];
	frm.dateStyle = NSDateFormatterMediumStyle;
	frm.timeStyle = NSDateFormatterNoStyle;
	[sSubject appendString:[frm stringFromDate:[note.createdDate toNSDate]]];
	
	NSMutableString *sBody = [NSMutableString stringWithString:_contentView.text];
	YTLocationInfo *location = [[YTLocationsEnManager shared] getLocationByNoteGuid:note.noteGuid];
	if(location) {
		[sBody appendString:@"<br><br>"];
		[sBody appendString:location.name];
	}
	
	int maxImages = 999;
	
	NSMutableArray *attachments = [NSMutableArray array];
	NSMutableArray *attachmentMimeTypes = [NSMutableArray array];
	NSMutableArray *attachmentFileNames = [NSMutableArray array];
	NSArray *resources = [NSArray arrayWithArray:[[YTResourcesEnManager shared] getResourcesForNoteWithGuid:note.noteGuid].allValues];
	for(YTResourceInfo *resource in resources) {
		if(![resource isImage] || [resource isThumbnail])
			continue;
		if([[YTResourcesStorage shared] isResourceDownloadedWithHash:resource.attachmenthash]) {
			NSString *filePath = [[YTResourcesStorage shared] filePathToDownloadedResourceWithHash:resource.attachmenthash];
			if(![[VLFileManager shared] fileExists:filePath])
				continue;
			NSData *attachmentData = nil;
			NSString *attachmentMimeType = nil;
			NSString *attachmentFileName = nil;
			NSError *error = nil;
			attachmentData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedAlways error:&error];
			if(error)
				VLLoggerError(@"%@", error);
			if(!attachmentData)
				continue;
			attachmentMimeType = [NSString stringWithFormat:@"image/%@", resource.attachmentTypeName];
			attachmentFileName = resource.filename;
			[attachments addObject:attachmentData];
			[attachmentMimeTypes addObject:attachmentMimeType];
			[attachmentFileNames addObject:attachmentFileName];
			if(attachments.count >= maxImages)
				break;
		}
	}
	if(attachments.count) {
		
	} else {
		//[attachments addObject:[sBody dataUsingEncoding:NSUTF8StringEncoding]];
		//[attachmentMimeTypes addObject:@"text/plain"];
		//[attachmentFileNames addObject:[NSString stringWithFormat:@"%@.txt", @"ATT00001"]];
	}
	[[VLMailComposeManager shared] sendMailWithSubject:sSubject
												  body:sBody
											 addresses:nil
										   attachments:attachments
								   attachmentMimeTypes:attachmentMimeTypes
								   attachmentFileNames:attachmentFileNames
										   resultBlock:^(MFMailComposeResult result, NSError *error) {
											   
	}];
}

- (void)noteEditView:(YTNoteEditView *)noteEditView finishWithAction:(EYTUserActionType)action {
	if(action == EYTUserActionTypeDone) {
		
	}
	[[self parentContentView] popView:noteEditView animated:YES];
}

- (UIView *)getContentTextView {
	return _contentView.textView;
}

- (void)onShowAnimationBefore {
	_toolbarShown = _wasShown;
	if(kIosVersionFloat >= 7.0) {
		_statusBarStyleNeededMNV = UIStatusBarStyleLightContent;
		_lastStatusBarStyleMNV = [UIApplication sharedApplication].statusBarStyle;
		if(_lastStatusBarStyleMNV != _statusBarStyleNeededMNV && !_statusBarBackViewMNV) {
			[[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyleNeededMNV animated:YES];
			_statusBarBackViewMNV = [[UIView alloc] initWithFrame:CGRectZero];
			_statusBarBackViewMNV.backgroundColor = self.customNavBar.backgroundColor;
			_statusBarBackViewMNV.alpha = 0.0;
			[self layoutSubviews];
		}
	}
}

- (void)onShowAnimationDuring {
	_toolbarShown = !_wasShown;
	[self layoutSubviews];
	if(_statusBarBackViewMNV) {
		if(_statusBarBackViewMNV.alpha == 0.0)
			_statusBarBackViewMNV.alpha = 1.0;
	}
}

- (void)onShowAnimationAfter {
	_wasShown = YES;
}

- (void)onCloseAnimationBefore {
	
}

- (void)onCloseAnimationDuring {
	if(_statusBarBackViewMNV && _statusBarBackViewMNV.alpha == 1.0) {
		_statusBarBackViewMNV.alpha = 0.0;
		[[UIApplication sharedApplication] setStatusBarStyle:_lastStatusBarStyleMNV animated:YES];
	}
}

- (void)onCloseAnimationAfter {
	if(_statusBarBackViewMNV) {
		if(_statusBarBackViewMNV.superview)
			[_statusBarBackViewMNV removeFromSuperview];
	}
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	if(_statusBarBackViewMNV) {
		if(_statusBarBackViewMNV.superview)
			[_statusBarBackViewMNV removeFromSuperview];
		[_statusBarBackViewMNV release];
	}
	[_backView release];
	[_toolbar release];
	[_btnDelete release];
	[_btnAdd release];
	[_btnAction release];
	[_contentScrollView release];
	[_contentView release];
	[super dealloc];
}

@end
