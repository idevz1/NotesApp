
#import "YTTagsLineView.h"

#define kTagBackColor [UIColor colorWithRed:94/255.0 green:125/255.0 blue:154/255.0 alpha:1.0]
#define kTagTextColor [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0]
#define kBlankTagBackColor [UIColor colorWithRed:214/255.0 green:218/255.0 blue:222/255.0 alpha:1.0]
#define kBlankTagTextColor [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0]
//#define kTagMargin UIEdgeInsetsMake(3, 3.5, 4, 3.5)
#define kTagMargin UIEdgeInsetsMake(6, 3.5, 6, 3.5)
#define kTagPadding UIEdgeInsetsMake(13, 9.5, 13, 9.5)
//#define kTagDistFirstLeftX 2.5
#define kTagDistFirstLeftX (_allowEditing ? 18.0 : 2.5)
#define kTagDistLastRightX 2.5
#define kTagDistEditedX 0.0//26.0
#define kTagsContainerOffsetRight (_allowEditing ? 18.0 : 0.0)
#define kButtonAddAlwaysHidden YES//NO

// TODO: localize later
#define kActionEditTag NSLocalizedString(@"Edit Tag", nil)
#define kActionRemoveTag NSLocalizedString(@"Remove Tag", nil)


@implementation YTTagsLineView_TagView

@synthesize isEditing = _isEditing;
@synthesize textField = _textField;
@synthesize title = _title;
@synthesize editedTitle = _editedTitle;

+ (NSString *)titleForEmptyTag {
	// TODO: localize later
	//return @"Tag";
	return @"     ";
}

+ (UIFont *)labelFont {
	//return [[YTFontsManager shared] boldFontWithSize:11.6 fixed:YES];
	return [[YTFontsManager shared] boldFontWithSize:12.6 fixed:YES];
}

+ (float)minTagWidth {
	UIEdgeInsets margin = kTagMargin;
	UIEdgeInsets padding = kTagPadding;
	float tw = [[self titleForEmptyTag] vlSizeWithFont:[self labelFont]].width;
	float res = margin.left + padding.left + tw + padding.right + margin.right;
	res = ceil(res);
	return res;
}

- (id)initWithFrame:(CGRect)frame isBlank:(BOOL)isBlank {
	self = [super initWithFrame:frame];
	if(self) {
		_isBlank = isBlank;
		_labelTitle.textColor = _isBlank ? kBlankTagTextColor : kTagTextColor;
	}
	return self;
}

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	_labelTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_labelTitle.backgroundColor = [UIColor clearColor];
	_labelTitle.textAlignment = NSTextAlignmentCenter;
	_labelTitle.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelTitle.font = [[self class] labelFont];
	[self addSubview:_labelTitle];

	_labelTitle.text = [[self class] titleForEmptyTag];
	_textField = [[UITextField alloc] initWithFrame:CGRectZero];
	_textField.hidden = YES;
	_textField.backgroundColor = [UIColor clearColor];
	_textField.borderStyle = UITextBorderStyleNone;
	_textField.font = _labelTitle.font;
	_textField.textAlignment = NSTextAlignmentCenter;
	_textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_textField.textColor = kTagBackColor;
	_textField.autocorrectionType = UITextAutocorrectionTypeNo;
	_textField.returnKeyType = UIReturnKeyNext;
	if([_textField respondsToSelector:@selector(setTintColor:)])
		_textField.tintColor = kTagBackColor;//[UIColor colorWithRed:49/255.0 green:93/255.0 blue:239/255.0 alpha:1.0];
	[self addSubview:_textField];

	[self updateViewAsync];
}

- (NSString *)title {
	return _labelTitle.text;
}

- (void)setTitle:(NSString *)title {
	if(![_labelTitle.text isEqual:title]) {
		_labelTitle.text = title;
		[[VLCtrlsUtils getParentViewOfClass:[YTTagsLineView class] ofView:self] setNeedsLayout];
	}
}

- (void)setEditedTitle:(NSString *)editedTitle {
	if(![_textField.text isEqual:editedTitle]) {
		_textField.text = editedTitle;
		[[VLCtrlsUtils getParentViewOfClass:[YTTagsLineView class] ofView:self] setNeedsLayout];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	_labelTitle.hidden = _isEditing;
	_textField.hidden = !_isEditing;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcText = self.bounds;
	UIEdgeInsets margin = kTagMargin;
	rcText.origin.y += margin.top - margin.bottom;
	_labelTitle.frame = rcText;
	if(_textField)
		_textField.frame = rcText;
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize szText = [_labelTitle sizeOfText];
	if(_isEditing)
		szText = [_textField.text vlSizeWithFont:_textField.font];
	UIEdgeInsets margin = kTagMargin;
	UIEdgeInsets padding = kTagPadding;
	size.width = margin.left + padding.left + szText.width + padding.right + margin.right;
	size.height = margin.top + padding.top + padding.bottom + margin.bottom;
	float minTagWidth = [[self class] minTagWidth];
	if(size.width < minTagWidth)
		size.width = minTagWidth;
	return size;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect rcBnds = self.bounds;
	CGRect rcBack = UIEdgeInsetsInsetRect(rcBnds, kTagMargin);
	float minSide = MIN(rcBack.size.width, rcBack.size.height);
	float radius = minSide/2 * 0.95;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	UIColor *lineColor = nil;
	UIColor *fillColor = nil;
	if(_isBlank) {
		if(_isEditing) {
			lineColor = kTagBackColor;
			fillColor = [UIColor clearColor];
		} else {
			lineColor = kBlankTagBackColor;
			fillColor = kBlankTagBackColor;
		}
	} else {
		if(_isEditing) {
			lineColor = kTagBackColor;
			fillColor = [UIColor clearColor];
		} else {
			lineColor = kTagBackColor;
			fillColor = kTagBackColor;
		}
	}
	[VLGraphicsUtils context:ctx
			 drawRoundedRect:rcBack
			withCornerRadius:radius
				   lineWidth:1.0
				   lineColor:lineColor
				   fillColor:fillColor];
}

- (void)setIsEditing:(BOOL)isEditing {
	if(_isEditing != isEditing) {
		_isEditing = isEditing;
		[self updateViewNow];
		if(_isEditing) {
			[_textField becomeFirstResponder];
		} else {
			[_textField resignFirstResponder];
		}
		[self updateViewAsync];
		[self setNeedsDisplay];
	}
}

- (void)dealloc {
	[_labelTitle release];
	[_textField release];
	[super dealloc];
}

@end


@implementation YTTagsLineView_ContentView

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
	[super dealloc];
}

@end


@implementation YTTagsLineView

@synthesize allowEditing = _allowEditing;
@synthesize buttonAdd = _buttonAdd;
@dynamic popupMenuShown;
@synthesize delegate = _delegate;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	_scrollView.backgroundColor = [UIColor clearColor];
	_scrollView.delegate = self;
	_scrollView.alwaysBounceHorizontal = YES;
	[self addSubview:_scrollView];
	
	_contentView = [[YTTagsLineView_ContentView alloc] initWithFrame:CGRectZero];
	[_scrollView addSubview:_contentView];
	
	_buttonAdd = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	_buttonAdd.hidden = YES;
	[_buttonAdd setImage:[UIImage imageNamed:@"btn_add_circled_filled_blue.png"] forState:UIControlStateNormal];
	[self addSubview:_buttonAdd];
	
	_tagsViews = [[NSMutableArray alloc] init];
	
	_blankTagView = [[self makeTagView:YES] retain];
	
	UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease];
	[_contentView addGestureRecognizer:tap];
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 0.1;
	_timer.enabledAlwaysFiring = YES;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	[_timer start];
	
	[[YTTagsEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onTagsEnManagerChanged:)];
	
	[self updateViewAsync];
}

- (void)setAllowEditing:(BOOL)allowEditing {
	if(_allowEditing != allowEditing) {
		_allowEditing = allowEditing;
		[self showButtonAdd:_allowEditing];
		[self updateViewAsync];
	}
}

- (BOOL)popupMenuShown {
	return (_popupBubbleMenuView != nil);
}

- (YTTagsLineView_TagView *)makeTagView:(BOOL)isBlank {
	YTTagsLineView_TagView *tagView = [[[YTTagsLineView_TagView alloc] initWithFrame:CGRectZero isBlank:isBlank] autorelease];
	tagView.textField.delegate = self;
	UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTagTapped:)] autorelease];
	[tagView addGestureRecognizer:tap];
	return tagView;
}

- (NSArray *)getCurrentTags {
	NSMutableArray *tags = [NSMutableArray array];
	if(_allowEditing) {
		YTNoteEditInfo *noteEditInfo = self.noteEditInfo;
		if(noteEditInfo)
			[tags addObjectsFromArray:noteEditInfo.tagsNew];
	} else {
		YTNoteInfo *note = self.note;
		YTTagsEnManager *manrTags = [YTTagsEnManager shared];
		[tags addObjectsFromArray:[manrTags getTagsByNoteGuid:note.noteGuid].allValues];
	}
	return tags;
}

- (void)onUpdateView {
	[super onUpdateView];
	if(_allowEditing) {
		if(!self.noteEditInfo)
			return;
	} else {
		if(!self.note)
			return;
	}
	if(!_tagsListBuilt) {
		_tagsListBuilt = YES;
		NSMutableArray *tags = [NSMutableArray arrayWithArray:[self getCurrentTags]];
		[tags sortUsingComparator:^NSComparisonResult(YTTagInfo *obj1, YTTagInfo *obj2) {
			return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
		}];
		for(YTTagInfo *tag in tags) {
			YTTagsLineView_TagView *tagView = [self makeTagView:NO];
			tagView.noteTag = tag;
			[_tagsViews addObject:tagView];
			[_contentView addSubview:tagView];
		}
		[_tagsViews addObject:_blankTagView];
		[_contentView addSubview:_blankTagView];
	}
	if(_allowEditing) {
		if(![_tagsViews containsObject:_blankTagView])
			[_tagsViews addObject:_blankTagView];
		_blankTagView.hidden = NO;
	} else {
		if([_tagsViews containsObject:_blankTagView])
			[_tagsViews removeObject:_blankTagView];
		_blankTagView.hidden = YES;
	}
	NSMutableArray *tags = [NSMutableArray arrayWithArray:[self getCurrentTags]];
	BOOL viewsChanged = NO;
	// Remove
	for(int i = 0; i < (int)_tagsViews.count - ([_tagsViews containsObject:_blankTagView] ? 1 : 0); i++) {
		YTTagsLineView_TagView *tagView = [_tagsViews objectAtIndex:i];
		if(![tags containsObject:tagView.noteTag]) {
			[tagView removeFromSuperview];
			[_tagsViews removeObjectAtIndex:i];
			i--;
			viewsChanged = YES;
		}
	}
	// Insert
	for(YTTagInfo *tag in tags) {
		BOOL exists = NO;
		for(YTTagsLineView_TagView *tagView in _tagsViews)
			if(tagView.noteTag == tag)
				exists = YES;
		if(!exists) {
			YTTagsLineView_TagView *tagView = [self makeTagView:NO];
			tagView.noteTag = tag;
			[_tagsViews insertObject:tagView atIndex:_tagsViews.count - ([_tagsViews containsObject:_blankTagView] ? 1 : 0)];
			[_contentView addSubview:tagView];
			viewsChanged = YES;
		}
	}
	
	for(YTTagsLineView_TagView *tagView in _tagsViews)
		if(tagView.noteTag)
			tagView.title = tagView.noteTag.name;
	if(_editedTagView && ![_tagsViews containsObject:_editedTagView]) {
		[self setEditedTagView:nil];
	}
	if(_popupBubbleMenuView && ![_tagsViews containsObject:_editedTagView]) {
		[self hidePopupBubbleMenuView];
	}
	if(viewsChanged) {
		[self setNeedsLayout];
	}
}

- (void)onNoteEditInfoDataChanged {
	[super onNoteEditInfoDataChanged];
	[self updateViewAsync];
}

- (void)onNoteDataChanged {
	[super onNoteDataChanged];
	[self updateViewAsync];
}

- (void)onTagsEnManagerChanged:(id)sender {
	if(!_allowEditing)
		[self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	CGRect rcScroll = rcBnds;
	CGRect rcBtnAdd = rcBnds;
	rcBtnAdd.size.width = rcBtnAdd.size.height;
	rcBtnAdd.origin.x = CGRectGetMaxX(rcBnds) - rcBtnAdd.size.width;
	if(!_buttonAdd.hidden) {
		rcScroll.size.width = rcBtnAdd.origin.x - rcScroll.origin.x;
	} else {
		rcScroll.size.width -= kTagsContainerOffsetRight;
	}
	_scrollView.frame = rcScroll;
	_buttonAdd.frame = rcBtnAdd;
	float contentWidth = kTagDistFirstLeftX;
	for(int i = 0; i < _tagsViews.count; i++) {
		YTTagsLineView_TagView *tagView = [_tagsViews objectAtIndex:i];
		CGRect rcTag = rcScroll;
		rcTag.origin.x = contentWidth;
		rcTag.size.width = [tagView sizeThatFits:rcScroll.size].width;
		tagView.frame = rcTag;
		contentWidth += rcTag.size.width;
		if(_allowEditing && i == (_tagsViews.count - 2))
			contentWidth += kTagDistEditedX;
	}
	contentWidth += kTagDistLastRightX;
	CGSize szContent = rcScroll.size;
	szContent.width = contentWidth;
	if(szContent.width < rcScroll.size.width)
		szContent.width = rcScroll.size.width;
	CGRect rcContent = _contentView.frame;
	rcContent.size = szContent;
	_contentView.frame = rcContent;
	_scrollView.contentSize = szContent;
}

- (CGSize)sizeThatFits:(CGSize)size {
	UIEdgeInsets margin = kTagMargin;
	UIEdgeInsets padding = kTagPadding;
	size.height = margin.top + padding.top + padding.bottom + margin.bottom;
	return size;
}

- (void)onTagTapped:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized && _allowEditing) {
		YTTagsLineView_TagView *tagView = nil;
		for(YTTagsLineView_TagView *view in _tagsViews)
			if([view.gestureRecognizers containsObject:tap])
				tagView = view;
		if(tagView) {
			[self setEditedTagView:nil];
			if(tagView == _blankTagView) {
				[self setEditedTagView:_blankTagView];
			} else {
				[self showPopupBubbleMenuViewFromTag:tagView autosuggestMode:NO];
			}
		}
	}
}

- (void)setEditedTagView:(YTTagsLineView_TagView *)tagView {
	if(_editedTagView != tagView) {
		[self hidePopupBubbleMenuView];
		if(_editedTagView) {
			[_editedTagView setIsEditing:NO];
			[_editedTagView release];
			_editedTagView = nil;
		}
		if(tagView) {
			_editedTagView = [tagView retain];
			if(_editedTagView == _blankTagView) {
				_editedTagView.editedTitle = @"";
			} else {
				_editedTagView.editedTitle = _editedTagView.title;
			}
			[_editedTagView setIsEditing:YES];
		}
		[self setNeedsLayout];
	}
}

- (YTTagsLineView_TagView *)tagViewByTextField:(UITextField *)textField {
	for(YTTagsLineView_TagView *tagView in _tagsViews)
		if(tagView.textField == textField)
			return tagView;
	return nil;
}

- (void)addNewTagFromBlankTagViewWithName:(NSString *)tagName {
	YTNoteEditInfo *noteEditInfo = self.noteEditInfo;
	NSArray *curTags = [self getCurrentTags];
	for(YTTagInfo *tag in curTags) {
		if([tag.name isEqual:tagName]) {
			[self setEditedTagView:nil];
			return;
		}
	}
	
	YTTagInfo *tagLast = nil;
	// Look in last tags
	for(YTTagInfo *tag in noteEditInfo.tagsLast) {
		if([tag.name isEqual:tagName]) {
			tagLast = tag;
			break;
		}
	}
	if(tagLast) {
		YTTagInfo *tagNew = [[[YTTagInfo alloc] init] autorelease];
		[tagNew assignDataFrom:tagLast];
		tagNew.modified = NO;
		[noteEditInfo addTagNew:tagNew];
		[noteEditInfo moveTagLastToEnd:tagLast];
	} else {
		YTTagInfo *tagNew = [[[YTTagInfo alloc] init] autorelease];
		tagNew.tagId = [[YTDatabaseManager shared] makeNewTempId];
		tagNew.added = YES;
		tagNew.name = tagName;
		[noteEditInfo addTagNew:tagNew];
	}
	[self hidePopupBubbleMenuView];
	_blankTagView.editedTitle = @"";
}

- (void)modifyTagFromTagView:(YTTagsLineView_TagView *)tagView withName:(NSString *)tagName {
	VLLoggerWarn(@"Unused");
	return;
	
	YTTagInfo *tagLast = tagView.noteTag;
	[self.noteEditInfo removeTagNew:tagLast];
	YTTagInfo *tagNew = [[[YTTagInfo alloc] init] autorelease];
	tagNew.tagId = [[YTDatabaseManager shared] makeNewTempId];
	tagNew.added = YES;
	tagNew.name = tagName;
	[self.noteEditInfo addTagNew:tagNew];
	tagView.noteTag = tagNew;
	[self setEditedTagView:nil];
	tagView.title = tagNew.name;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	YTTagsLineView_TagView *tagView = [self tagViewByTextField:textField];
	if(tagView == _blankTagView) {
		NSString *tagName = textField.text;
		if(![NSString isEmpty:tagName] && ![NSString isEmpty:[tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
			[self addNewTagFromBlankTagViewWithName:tagName];
			[self setEditedTagView:nil];
			return;
		}
	}
	[self setEditedTagView:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[self setNeedsLayout];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSString *tagName = textField.text;
	YTTagsLineView_TagView *tagView = [self tagViewByTextField:textField];
	if(tagView) {
		if(tagView == _blankTagView) {
			if(![NSString isEmpty:tagName] && ![NSString isEmpty:[tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
				[self addNewTagFromBlankTagViewWithName:tagName];
				[self startEditNewTag];
				return NO;
			}
		} else if(tagView == _editedTagView) {
			if(![NSString isEmpty:tagName]) {
				[self modifyTagFromTagView:tagView withName:tagName];
			}
		}
	}
	[textField resignFirstResponder];
	[self hidePopupBubbleMenuView];
	return NO;
}

- (void)onTap:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized) {
		VLLoggerTrace(@"");
		CGPoint pt = [tap locationInView:self];
		YTTagsLineView_TagView *tagView = nil;
		for(YTTagsLineView_TagView *view in _tagsViews) {
			if(CGRectContainsPoint([view convertRect:view.bounds toView:self], pt)) {
				tagView = view;
				break;
			}
		}
		if(!tagView) {
			if(_blankTagView.isEditing) {
				NSString *tagName = _blankTagView.textField.text;
				if(![NSString isEmpty:tagName] && ![NSString isEmpty:[tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
					[self addNewTagFromBlankTagViewWithName:tagName];
				}
				[self setEditedTagView:nil];
			} else if(_editedTagView && _editedTagView.isEditing) {
				NSString *tagName = _blankTagView.textField.text;
				if(![NSString isEmpty:tagName]) {
					[self modifyTagFromTagView:_editedTagView withName:tagName];
				}
				[self setEditedTagView:nil];
			}
		}
	}
}

- (void)showPopupBubbleMenuViewFromTag:(YTTagsLineView_TagView *)tagView autosuggestMode:(BOOL)autosuggestMode {
	[self hidePopupBubbleMenuView];
	_popupTargetTagView = [tagView retain];
	_popupBubbleMenuView = [[VLPopupBubbleMenuView alloc] init];
	_popupBubbleMenuView.delegate = self;
	if(!autosuggestMode) {
		if(kYTAllowEditTag)
			[_popupBubbleMenuView addItemWithTitle:kActionEditTag objectTag:kActionEditTag];
		[_popupBubbleMenuView addItemWithTitle:kActionRemoveTag objectTag:kActionRemoveTag];
	}
	if(autosuggestMode) {
		[_popupBubbleMenuView setTextFont:[[YTFontsManager shared] boldFontWithSize:13 fixed:YES]
								textColor:[UIColor colorWithWhite:1.0 alpha:1.0]
								backColor:[UIColor colorWithRed:119/255.0 green:28/255.0 blue:178/255.0 alpha:1.0]
							 cornerRadius:13
								  padding:UIEdgeInsetsMake(5.75, 3, 5.75, 3)
							   itemSpaceX:8
								arrowSize:6.0];
	} else {
		[_popupBubbleMenuView setTextFont:[[YTFontsManager shared] boldFontWithSize:13 fixed:YES]
								textColor:[UIColor colorWithWhite:1.0 alpha:1.0]
								backColor:[UIColor colorWithRed:48/255.0 green:48/255.0 blue:48/255.0 alpha:1.0]
							 cornerRadius:7.0
								  padding:UIEdgeInsetsMake(10, 3, 10, 3)
							   itemSpaceX:8
								arrowSize:8.5];
	}
	UIView *parent = [VLAppDelegateBase sharedAppDelegateBase].rootViewController.view;
	[_popupBubbleMenuView showInParentView:parent fromView:tagView];
}

- (void)hidePopupBubbleMenuView {
	if(_popupBubbleMenuView) {
		_popupBubbleMenuView.delegate = nil;
		[_popupBubbleMenuView hide];
		[_popupBubbleMenuView release];
		_popupBubbleMenuView = nil;
	}
	if(_popupTargetTagView) {
		[_popupTargetTagView release];
		_popupTargetTagView = nil;
	}
}

- (void)popupBubbleMenuView:(VLPopupBubbleMenuView *)popupBubbleMenuView touchedOutside:(id)param {
	[self hidePopupBubbleMenuView];
}

- (void)popupBubbleMenuView:(VLPopupBubbleMenuView *)popupBubbleMenuView itemTapped:(VLPopupBubbleMenuViewItem *)item {
	YTTagsLineView_TagView *popupTargetTagView = [[_popupTargetTagView retain] autorelease];
	[self hidePopupBubbleMenuView];
	if(_editedTagView) {
		_editedTagView.textField.text = item.title;
		[self textFieldShouldReturn:_editedTagView.textField];
	} else {
		if([item.objectTag isEqual:kActionEditTag]) {
			[self setEditedTagView:popupTargetTagView];
		} else if([item.objectTag isEqual:kActionRemoveTag]) {
			YTTagInfo *tag = [[popupTargetTagView.noteTag retain] autorelease];
			[self.noteEditInfo removeTagNew:tag];
			if(_delegate && [_delegate respondsToSelector:@selector(tagsLineView:tagRemoved:)])
				[_delegate tagsLineView:self tagRemoved:tag];
		}
	}
}

- (void)updateAutosuggestion {
	if(_editedTagView) {
		NSArray *allTags = [[YTTagsEnManager shared] getAllTags];
		NSString *tagText = _editedTagView.textField.text;
		NSMutableSet *setExistedTagsNames = [NSMutableSet set];
		for(YTTagInfo *tag in self.noteEditInfo.tagsNew) {
			NSString *tagName = tag.name;
			if(![NSString isEmpty:tagName] && ![setExistedTagsNames containsObject:tagName])
				[setExistedTagsNames addObject:tagName];
		}
		NSMutableSet *setSuggestedTagsNames = [NSMutableSet set];
		for(YTTagInfo *tag in allTags) {
			NSString *tagName = tag.name;
			if([NSString isEmpty:tagName])
				continue;
			if(![setSuggestedTagsNames containsObject:tagName] && ![setExistedTagsNames containsObject:tagName])
				if([tagName rangeOfString:tagText options:NSCaseInsensitiveSearch].length)
					[setSuggestedTagsNames addObject:tagName];
		}
		NSMutableArray *arrSuggestedTagsNames = [NSMutableArray arrayWithArray:setSuggestedTagsNames.allObjects];
		[arrSuggestedTagsNames sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
			return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
		}];
		if(arrSuggestedTagsNames.count) {
			if(!_popupBubbleMenuView) {
				[self showPopupBubbleMenuViewFromTag:_editedTagView autosuggestMode:YES];
			}
			BOOL changed = NO;
			if(arrSuggestedTagsNames.count != _popupBubbleMenuView.items.count)
				changed = YES;
			else {
				for(int i = 0; i < _popupBubbleMenuView.items.count; i++) {
					VLPopupBubbleMenuViewItem *item = [_popupBubbleMenuView.items objectAtIndex:i];
					NSString *tagName = [arrSuggestedTagsNames objectAtIndex:i];
					if(![tagName isEqual:item.title])
						changed = YES;
				}
			}
			if(changed) {
				while(_popupBubbleMenuView.items.count)
					[_popupBubbleMenuView removeItemAtIndex:(int)_popupBubbleMenuView.items.count - 1];
				for(NSString *tagName in arrSuggestedTagsNames)
					[_popupBubbleMenuView addItemWithTitle:tagName objectTag:tagName];
			}
		} else {
			[self hidePopupBubbleMenuView];
		}
	}
}

- (void)onTimerEvent:(id)sender {
	[self updateAutosuggestion];
}

- (void)showButtonAdd:(BOOL)show {
	if(kButtonAddAlwaysHidden)
		show = NO;
	if(show != !_buttonAdd.hidden) {
		_buttonAdd.hidden = !show;
		[self setNeedsLayout];
	}
}

- (void)startEditNewTag {
	[self setEditedTagView:_blankTagView];
}

- (void)stopEditingTag {
	[self setEditedTagView:nil];
}

- (void)dealloc {
	_delegate = nil;
	[[YTTagsEnManager shared].msgrVersionChanged removeObserver:self];
	[self hidePopupBubbleMenuView];
	[_scrollView release];
	[_contentView release];
	[_buttonAdd release];
	[_tagsViews release];
	[_blankTagView release];
	[_editedTagView release];
	[_popupTargetTagView release];
	[_timer release];
	[super dealloc];
}

@end

