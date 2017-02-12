
#import "YTNoteResourcesListView.h"
#import "YTNoteContentSeparator.h"

//#define kPaletteDistanceX 4.0
#define kSeparatorColor [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1.0]
#define kSeparatorWidth 1.0

#define kShowDicsSeparators YES
#define kDocsSeparatorInset 0.0

@implementation YTNoteResourcesListView

@synthesize delegate = _delegate;
@synthesize resources = _resources;
@synthesize rowsViews = _rowsViews;
@synthesize mainResource = _mainResource;

- (void)initialize {
	[super initialize];
	self.backgroundColor = [UIColor clearColor];
	
	_backViewSep = [[UIView alloc] initWithFrame:CGRectZero];
	_backViewSep.backgroundColor = kSeparatorColor;
	[self addSubview:_backViewSep];
	
	_rowsViews = [[NSMutableArray alloc] init];
	_docsSepars = [[NSMutableArray alloc] init];
	_resources = [[NSMutableArray alloc] init];
	_maxPhotosToShow = INT_MAX;//kYTMaxPhotosToShowOnNoteView;
}

- (void)setResources:(NSArray *)resources {
	if(!resources)
		resources = [NSArray array];
	BOOL changed = NO;
	if(_resources.count != resources.count)
		changed = YES;
	else {
		if(![_resources isEqualToArray:resources])
			changed = YES;
	}
	if(changed) {
		[_resources removeAllObjects];
		[_resources addObjectsFromArray:resources];
		[self updateViewAsync];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	[[self class] sortResources:_resources optionalMainResource:_mainResource];
	NSMutableArray *newRowsViews = [NSMutableArray array];
	for(YTResourceInfo *res in _resources) {
		if(newRowsViews.count >= _maxPhotosToShow)
			break;
		YTNoteResourceRowView *view = nil;
		for(YTNoteResourceRowView *obj in _rowsViews)
			if(obj.resource == res)
				view = obj;
		if(!view) {
			view = [[YTNoteResourceRowView new] autorelease];
			view.resource = res;
			[self addSubview:view];
		}
		[newRowsViews addObject:view];
	}
	if(![_rowsViews isEqualToArray:newRowsViews]) {
		for(int i = (int)_rowsViews.count - 1; i >= 0; i--) {
			YTNoteResourceRowView *view = [_rowsViews objectAtIndex:i];
			if(![newRowsViews containsObject:view]) {
				[view removeFromSuperview];
			}
		}
		[_rowsViews removeAllObjects];
		[_rowsViews addObjectsFromArray:newRowsViews];
		[self setNeedsLayout];
	}
	if(_mainResource) {
		for(YTNoteResourceRowView *view in _rowsViews)
			if(view.resource == _mainResource)
				[self bringSubviewToFront:view];
	}
}

- (BOOL)isAllImagesLoaded {
	for(YTNoteResourceRowView *view in _rowsViews) {
		if(![view.resource isImage])
			continue;
		if(![view isImageLoaded])
			return NO;
	}
	return YES;
}

- (BOOL)isAllImagesShown {
	for(YTNoteResourceRowView *view in _rowsViews) {
		if(![view.resource isImage])
			continue;
		if(![view isImageShown])
			return NO;
	}
	return YES;
}

- (void)setMaxPhotosToShow:(int)maxPhotosToShow {
	if(_maxPhotosToShow != maxPhotosToShow) {
		_maxPhotosToShow = maxPhotosToShow;
		[self updateViewNow];
	}
}

- (NSArray *)getFramesForImageView:(NSArray *)views boundsWidth:(float)boundsWidth allHeight:(float *)allHeight {

	NSMutableArray *resultFrames = [NSMutableArray array];
	if(allHeight)
		*allHeight = 0;
	int viewsCount = (int)views.count;
	if(viewsCount == 0)
		return resultFrames;
	NSMutableArray *arrSizes = [NSMutableArray array];
	NSMutableArray *arrSides = [NSMutableArray array];
	int totalSides = 0;
	int minSides = 0;
	int maxSides = 0;
	for(YTNoteResourceRowView *view in views) {
		CGSize size = [view sizeOfLoadedImage];
		[arrSizes addObject:[NSValue valueWithCGSize:size]];
		int sides = (int)(size.width + size.height);
		[arrSides addObject:[NSNumber numberWithInt:sides]];
		totalSides += sides;
		maxSides = MAX(maxSides, sides);
		if(!minSides)
			minSides = sides;
		else
			minSides = MIN(minSides, sides);
	}
	NSMutableArray *mosaicItems = [NSMutableArray array];
	for(int i = 0; i < views.count; i++) {
		VLMosaicImagesLayouter_MosaicData *item = [[[VLMosaicImagesLayouter_MosaicData alloc] init] autorelease];
		int sides = [[arrSides objectAtIndex:i] intValue];
		int nMinSize = 1;
		int nMaxSize = 2;
		int nSize = nMinSize + round((((maxSides - minSides) - (sides - minSides)) / (double)(maxSides - minSides)) * (nMaxSize - nMinSize));
		nSize = MAX(MIN(nSize, nMaxSize), nMinSize);
		item.size = nSize;
		[mosaicItems addObject:item];
	}
	VLMosaicImagesLayouter *layouter = [[[VLMosaicImagesLayouter alloc] init] autorelease];
	CGSize frameSize = CGSizeMake(boundsWidth, 240);
	[layouter setupLayoutWithMosaicElements:mosaicItems frameSize:frameSize];
	float maxY = 0;
	for(VLMosaicImagesLayouter_MosaicData *item in mosaicItems)
		maxY = MAX(maxY, CGRectGetMaxY(item.resultRect));
	if(allHeight)
		*allHeight = maxY;
	for(int i = 0; i < views.count; i++) {
		VLMosaicImagesLayouter_MosaicData *item = [mosaicItems objectAtIndex:i];
		[resultFrames addObject:[NSValue valueWithCGRect:item.resultRect]];
	}
	return resultFrames;
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = 0;
	NSMutableArray *viewsImages = [NSMutableArray array];
	NSMutableArray *viewsNonImages = [NSMutableArray array];
	for(YTNoteResourceRowView *view in _rowsViews) {
		if([view.resource isImage])
			[viewsImages addObject:view];
		else
			[viewsNonImages addObject:view];
	}
	BOOL isAllImagesLoaded = [self isAllImagesLoaded];
	if(isAllImagesLoaded && viewsImages.count > 1) {
		float allHeight = 0;
		[self getFramesForImageView:viewsImages boundsWidth:size.width allHeight:&allHeight];
		size.height += allHeight;
		for(YTNoteResourceRowView *view in viewsNonImages) {
			CGSize szView = [view sizeThatFits:CGSizeMake(size.width, 0)];
			szView.width = size.width;
			if(szView.height > szView.width)
				szView.height = szView.width;
			size.height += szView.height;
		}
	} else {
		for(YTNoteResourceRowView *view in _rowsViews) {
			CGSize szView = [view sizeThatFits:CGSizeMake(size.width, 0)];
			szView.width = size.width;
			if(szView.height > szView.width)
				szView.height = szView.width;
			size.height += szView.height;
			if(kShowDicsSeparators)
				size.height += kSeparatorWidth;
		}
	}
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	NSMutableArray *viewsImages = [NSMutableArray array];
	NSMutableArray *viewsNonImages = [NSMutableArray array];
	for(YTNoteResourceRowView *view in _rowsViews) {
		if([view.resource isImage])
			[viewsImages addObject:view];
		else
			[viewsNonImages addObject:view];
	}
	BOOL isAllImagesLoaded = [self isAllImagesLoaded];
	if(isAllImagesLoaded && viewsImages.count > 1) {
		float allHeight = 0;
		NSArray *frames = [self getFramesForImageView:viewsImages boundsWidth:rcBnds.size.width allHeight:&allHeight];
		for(int i = 0; i < viewsImages.count; i++) {
			YTNoteResourceRowView *view = [viewsImages objectAtIndex:i];
			if(i >= frames.count) {
				VLLoggerError(@"(i >= frames.count)");
				continue;
			}
			NSValue *valFrame = [frames objectAtIndex:i];
			CGRect rcFrameRef = [valFrame CGRectValue];
			CGRect rect = rcFrameRef;
			rect.origin.x += rcBnds.origin.x;
			rect.origin.y += rcBnds.origin.y;
			if(CGRectGetMaxX(rect) < CGRectGetMaxX(rcBnds))
				rect.size.width -= kSeparatorWidth;
			if(CGRectGetMaxY(rect) < allHeight)
				rect.size.height -= kSeparatorWidth;
			view.frame = rect;
		}
		float curTop = rcBnds.origin.y + allHeight;
		for(int i = 0; i < viewsNonImages.count; i++) {
			YTNoteResourceRowView *view = [viewsNonImages objectAtIndex:i];
			CGRect rect = rcBnds;
			rect.origin.y = curTop;
			rect.size = [view sizeThatFits:rect.size];
			if(rect.size.height > rect.size.width)
				rect.size.height = rect.size.width;
			curTop = CGRectGetMaxY(rect);
			if(CGRectGetMaxX(rect) < CGRectGetMaxX(rcBnds))
				rect.size.width -= kSeparatorWidth;
			if(CGRectGetMaxY(rect) < allHeight)
				rect.size.height -= kSeparatorWidth;
			view.frame = rect;
		}
		for(UIView *view in _docsSepars)
			[view removeFromSuperview];
		[_docsSepars removeAllObjects];
	} else {
		float curTop = rcBnds.origin.y;
		for(int i = 0; i < _rowsViews.count; i++) {
			YTNoteResourceRowView *view = [_rowsViews objectAtIndex:i];
			CGRect rect = rcBnds;
			rect.origin.y = curTop;
			rect.size = [view sizeThatFits:rect.size];
			if(rect.size.height > rect.size.width)
				rect.size.height = rect.size.width;
			curTop = CGRectGetMaxY(rect);
			if(CGRectGetMaxX(rect) < CGRectGetMaxX(rcBnds))
				rect.size.width -= kSeparatorWidth;
			if(CGRectGetMaxY(rect) < CGRectGetMaxY(rcBnds))
				rect.size.height -= kSeparatorWidth;
			view.frame = rect;
			if(kShowDicsSeparators && i < _rowsViews.count) {
				YTNoteContentSeparator *sep = nil;
				if(i < _docsSepars.count)
					sep = [_docsSepars objectAtIndex:i];
				if(!sep) {
					sep = [[[YTNoteContentSeparator alloc] initWithFrame:CGRectZero] autorelease];
					sep.style = EYTNoteContentSeparatorStyleOneLine;
					[_docsSepars addObject:sep];
					[self addSubview:sep];
				}
				[self bringSubviewToFront:sep];
				CGRect rcSep = rcBnds;
				rcSep.origin.y = curTop;
				rcSep.size.height = 0.5;
				rcSep.origin.x += kDocsSeparatorInset;
				rcSep.size.width -= kDocsSeparatorInset * 2;
				sep.frame = [UIScreen roundRect:rcSep];
				curTop += kSeparatorWidth;
			}
		}
		while(_docsSepars.count > _rowsViews.count - 1) {
			UIView *view = [_docsSepars lastObject];
			[view removeFromSuperview];
			[_docsSepars removeLastObject];
		}
	}
	_backViewSep.frame = rcBnds;
}

- (void)onRowTapped:(YTNoteResourceRowView *)rowView {
	if(_delegate)
		[_delegate noteResourcesListView:self rowTapped:rowView];
}

+ (void)sortResources:(NSMutableArray *)arrYTResourceInfo optionalMainResource:(YTResourceInfo *)optionalMainResource {
	[arrYTResourceInfo sortUsingComparator:^NSComparisonResult(YTResourceInfo *obj1, YTResourceInfo *obj2) {
		if(optionalMainResource) {
			if(obj1 == optionalMainResource)
				return -1;
			else if(obj2 == optionalMainResource)
				return 1;
		}
		BOOL isImage1 = [obj1 isImage];
		BOOL isImage2 = [obj2 isImage];
		if(isImage1 != isImage2)
			return -((int)isImage1 - (int)isImage2);
		if(obj1.attachmentCategoryId != obj2.attachmentCategoryId)
			return obj1.attachmentCategoryId - obj2.attachmentCategoryId;
		int result = -[obj1.lastUpdateTS compare:obj2.lastUpdateTS];
		if(result)
			return result;
		return [obj1 compareDataTo:obj2];
	}];
}

- (void)dealloc {
	[_backViewSep release];
	[_rowsViews release];
	[_docsSepars release];
	[_resources release];
	[_mainResource release];
	[super dealloc];
}

@end

