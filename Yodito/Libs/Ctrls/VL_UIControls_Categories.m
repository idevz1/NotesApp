
#import "VL_UIControls_Categories.h"
#import <QuartzCore/QuartzCore.h>
#import "../Logic/Classes.h"
#import "../Drawing/Classes.h"


@implementation UIView(VL_UIView_Category)

@dynamic visible;

- (BOOL)visible
{
	return !self.hidden;
}
- (void)setVisible:(BOOL)visible
{
	self.hidden = !visible;
}

- (void)roundCorners:(float)cornerRadius
{
	self.layer.cornerRadius = cornerRadius;
	self.clipsToBounds = YES;
}

@end




@implementation UIButton(VL_UIButton_Category)

- (void)setTitleForAllStates:(NSString*)title
{
	[self setTitle:title forState:UIControlStateNormal];
	[self setTitle:title forState:UIControlStateHighlighted];
	[self setTitle:title forState:UIControlStateDisabled];
	[self setTitle:title forState:UIControlStateSelected];
	[self setTitle:title forState:UIControlStateApplication];
}

- (void)setImageForAllStates:(UIImage*)image
{
	[self setImage:image forState:UIControlStateNormal];
	[self setImage:image forState:UIControlStateHighlighted];
	[self setImage:image forState:UIControlStateDisabled];
	[self setImage:image forState:UIControlStateSelected];
	[self setImage:image forState:UIControlStateApplication];
}

@end




@implementation UILabel(UILabelCategory)

- (void)centerText
{
	self.textAlignment = NSTextAlignmentCenter;
	self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
}

- (CGSize)sizeOfText
{
	CGSize res;
	NSString *text = self.text;
	if(!text || !text.length)
		text = @"0";
	res = [text vlSizeWithFont:self.font];
	return res;
}

- (float)heightOfText
{
	return [self sizeOfText].height;
}

@end




#define kTableViewCustom_MsgTag 324652467
#define kEmptyTableMessageFont [UIFont boldSystemFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 28 : 20)]
#define kEmptyTableMessageSpacing ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 24 : 16)
@interface UITableView_EmptyMessageView : UIView
{
@private
    NSString *_text;
	VLTimer *_timer;
}
@property(nonatomic,assign) NSString *text;
@end

@implementation UITableView_EmptyMessageView
@dynamic text;
- (id)init
{
    self = [super init];
	if(self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
        _text = [@"" retain];
		_timer = [[VLTimer alloc] init];
		[_timer setObserver:self selector:@selector(onTimerEvent:)];
		_timer.interval = 0.2;
		[_timer start];
    }
    return self;
}

- (NSString*)text
{
    return _text;
}
- (void)setText:(NSString*)value
{
	if(!value)
		value = @"";
	if(![_text isEqual:value])
	{
		[_text release];
		_text = [value copy];
		[self setNeedsDisplay];
	}
}
- (UITableView*)parentTable
{
	return ObjectCast(self.superview, UITableView);
}
- (void)addRoundedRectToContext:(CGContextRef)c rect:(CGRect)rect corner_radius:(float)corner_radius
{
    CGFloat x_left = rect.origin.x;
    CGFloat x_left_center = rect.origin.x + corner_radius;
    CGFloat x_right_center = rect.origin.x + rect.size.width - corner_radius;
    CGFloat x_right = rect.origin.x + rect.size.width;
    CGFloat y_top = rect.origin.y;
    CGFloat y_top_center = rect.origin.y + corner_radius;
    CGFloat y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
    CGFloat y_bottom = rect.origin.y + rect.size.height;
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x_left, y_top_center);
    CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, corner_radius);
    CGContextAddLineToPoint(c, x_right_center, y_top);
    CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, corner_radius);
    CGContextAddLineToPoint(c, x_right, y_bottom_center);
    CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
    CGContextAddLineToPoint(c, x_left_center, y_bottom);
    CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
    CGContextAddLineToPoint(c, x_left, y_top_center);
    CGContextClosePath(c);
}
- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	UITableView *table = [self parentTable];
	if((_text && _text.length) && table)
	{
		BOOL hasRows = ([table totalNumberOfRows] > 0);
		if(!hasRows)
		{
			CGRect rc = self.bounds;
			float dy = MIN(5, rc.size.height/10);
			float topIndent = rc.size.height/5;
			if(table.tableHeaderView)
				topIndent = MAX(rc.origin.y + table.tableHeaderView.frame.size.height + dy, topIndent);
			CGRect boxRect = CGRectMake(rc.size.width/16,
										topIndent,
										rc.size.width/16*14,
										MIN(rc.size.height/2, CGRectGetMaxY(rc) - topIndent - dy));
			CGRect textRect = boxRect;
			textRect.origin.x += kEmptyTableMessageSpacing;
			textRect.origin.y += kEmptyTableMessageSpacing;
			textRect.size.width -= 2*kEmptyTableMessageSpacing;
			textRect.size.height -= 2*kEmptyTableMessageSpacing;
			
			CGSize msgSize = [_text vlSizeWithFont:kEmptyTableMessageFont
							   constrainedToSize:CGSizeMake(textRect.size.width, CGFLOAT_MAX / 2)
								   lineBreakMode:NSLineBreakByTruncatingTail];
			
			boxRect.size.height = msgSize.height + 4*kEmptyTableMessageSpacing;
			
			CGContextRef ctx = UIGraphicsGetCurrentContext();
			[self addRoundedRectToContext:ctx rect:boxRect corner_radius:16];
			[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] setFill];
			CGContextFillPath(ctx);
			[self addRoundedRectToContext:ctx rect:boxRect corner_radius:16];
			[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] setStroke];
			CGContextStrokePath(ctx);
			
			textRect.origin.y = boxRect.origin.y + 2*kEmptyTableMessageSpacing;
			textRect.size.height = textRect.size.height;
			
			UIColor *color = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
			[color set];
			[_text vlDrawInRect:textRect withFont:kEmptyTableMessageFont
				  lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft color:color];
		}
	}
}
- (void)onTimerEvent:(id)sender
{
	UITableView *table = [self parentTable];
	if(!table)
	{
		[_timer stop];
		return;
	}
	BOOL hasRows = ([table totalNumberOfRows] > 0);
	if(hasRows)
	{
		_timer.interval = 0.5;
		if(!self.hidden)
			self.hidden = YES;
	}
	else
	{
		_timer.interval = 0.2;
		if(self.hidden)
			self.hidden = NO;
	}
	int sc = (int)[table.subviews count];
	if(!self.hidden && [table.subviews objectAtIndex:sc-1] != self)
		[table bringSubviewToFront:self];
}
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	return nil;
}
- (void)dealloc
{
    [_text release];
	[_timer release];
    [super dealloc];
}
@end


@implementation UITableView (VL_UITableView_Category)

-(NSString*) emptyTableMessage
{
	UITableView_EmptyMessageView* lb = (UITableView_EmptyMessageView*)[self viewWithTag:kTableViewCustom_MsgTag];
	return lb ? lb.text : @"";
}

-(void)setEmptyTableMessage:(NSString*) message
{
	if(!message)
		message = @"";
	NSString* curMsg = [self emptyTableMessage];
	if(!curMsg || ![curMsg isEqual:message])
	{
		UITableView_EmptyMessageView* lb = (UITableView_EmptyMessageView*)[self viewWithTag:kTableViewCustom_MsgTag];
		if(!message || !message.length)
		{
			if(lb)
			{
				[lb removeFromSuperview];
			}
		}
		else
		{
			if(!lb)
			{
				BOOL hasRows = ([self totalNumberOfRows] > 0);
				lb = [UITableView_EmptyMessageView new];
				lb.tag = kTableViewCustom_MsgTag;
				lb.hidden = hasRows;
				[self addSubview:lb];
				[self sendSubviewToBack:lb];
				[lb release];
				lb.frame = self.bounds;
			}
			lb.text = message;
		}
		[self setNeedsDisplay];
		[self setNeedsLayout];
	}
}

- (int)totalNumberOfRows
{
	int result = 0;
	int sections = 1;
	if(self.delegate &&[self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)])
		sections = (int)[self.dataSource numberOfSectionsInTableView:self];
	if(self.delegate &&[self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
	{
		for(int i = 0; i < sections; i++)
			result += [self.dataSource tableView:self numberOfRowsInSection:0];
	}
	return result;
}

- (void)setTransparentBackground
{
	[self setBackgroundView:nil];
	[self setBackgroundView:[[[UIView alloc] init] autorelease]];
	[self setBackgroundColor:[UIColor clearColor]];
}

- (void)deselectAllRowsAnimated:(BOOL)animated
{
	NSIndexPath *path = [self indexPathForSelectedRow];
	if(path)
		[self deselectRowAtIndexPath:path animated:animated];
}

- (void)deselectRowInt:(NSIndexPath*)rowPath
{
	if([self numberOfSections] > rowPath.section && [self numberOfRowsInSection:rowPath.section] > rowPath.row)
		[self deselectRowAtIndexPath:rowPath animated:YES];
}
- (void)flashRow:(NSIndexPath*)rowPath
{
	[self selectRowAtIndexPath:rowPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self performSelector:@selector(deselectRowInt:) withObject:rowPath afterDelay:0.3];
}

+ (NSString*)lettersIndex_allLettersString
{
	static NSString *chars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ ";
	return chars;
}

+ (NSArray*)lettersIndex_sectionIndexLetters
{
	static NSMutableArray *letters = nil;
	if(!letters)
	{
		letters = [[NSMutableArray alloc] init];
		NSString *chars = [UITableView lettersIndex_allLettersString];
		for(int i = 0; i < chars.length; i++)
			[letters addObject:[chars substringWithRange:NSMakeRange(i, 1)]];
	}
	return letters;
}

+ (NSArray*)lettersIndex_splitObjects:(NSArray*)objects toLetterSectionsWithTitles:(NSArray*)titles resultLetters:(NSMutableArray*)resultLetters
{
	NSArray *letters = [UITableView lettersIndex_sectionIndexLetters];
	NSMutableArray *sections = [NSMutableArray array];
	[resultLetters removeAllObjects];
	NSMutableArray *section = nil;
	NSMutableArray *sectionLast = nil;
	NSMutableArray *addedObjects = [NSMutableArray array];
	NSMutableArray *titlesFirstLetters = [NSMutableArray array];
	for(int n = 0; n < titles.count; n++)
	{
		NSString *title = [titles objectAtIndex:n];
		if(!title.length)
			[titlesFirstLetters addObject:@" "];
		else
			[titlesFirstLetters addObject:[title substringToIndex:1]];
	}
	for(int i = 0; i < letters.count; i++)
	{
		NSString *letter = [letters objectAtIndex:i];
		if([letter isEqual:@" "])
			continue;
		for(int n = 0; n < titlesFirstLetters.count; n++)
		{
			NSString *titleFirstLetter = [titlesFirstLetters objectAtIndex:n];
			if([letter compare:titleFirstLetter options:NSCaseInsensitiveSearch] == 0)
			{
				id obj = [objects objectAtIndex:n];
				if(!section)
				{
					section = [NSMutableArray array];
					[sections addObject:section];
					[resultLetters addObject:letter];
				}
				[section addObject:obj];
				[addedObjects addObject:obj];
			}
		}
		section = nil;
	}
	for(int n = 0; n < objects.count; n++)
	{
		id obj = [objects objectAtIndex:n];
		if(![addedObjects containsObject:obj])
		{
			if(!sectionLast)
			{
				sectionLast = [NSMutableArray array];
				[sections addObject:sectionLast];
				[resultLetters addObject:@" "];
			}
			[sectionLast addObject:obj];
			[addedObjects addObject:[objects objectAtIndex:n]];
		}
	}
	return sections;
}

+ (NSInteger)lettersIndex_sectionIndexByLetter:(NSString*)letter sectionsTitles:(NSArray*)sectionsTitles
{
	if(!sectionsTitles.count)
		return 0;
	NSString *allLettersString = [UITableView lettersIndex_allLettersString];
	NSInteger letterIndex = [allLettersString rangeOfString:letter].location;
	if(letterIndex == NSNotFound)
		return 0;
	for(int i = (int)sectionsTitles.count - 1; i >= 0; i--)
	{
		NSString *title = [sectionsTitles objectAtIndex:i];
		NSInteger titleIndexOfAll = [allLettersString rangeOfString:title].location;
		if(titleIndexOfAll != NSNotFound && titleIndexOfAll <= letterIndex)
			return i;
	}
	return 0;
}

- (void)updateRowsWithLastSections:(NSArray*)lastSections
					   newSections:(NSArray*)newSections
					resultSections:(NSMutableArray*)resultSections
	   allowMoveRowBetweenSections:(BOOL)allowMoveRowBetweenSections
						  animated:(BOOL)animated
					  animatedRows:(BOOL)animatedRows
{
	if(lastSections.count != newSections.count || newSections.count != resultSections.count)
	{
		NSLog(@"WARNING: updateRowsWithLastSections: changing sections number is not supported with animation yet");
		[resultSections removeAllObjects];
		[resultSections addObjectsFromArray:newSections];
		[self reloadData];
		return;
	}
	NSMutableArray *resultSectionsNew = [NSMutableArray array];
	NSMutableArray *allRemovedPaths = [NSMutableArray array];
	NSMutableArray *allAddedPaths = [NSMutableArray array];
	NSMutableArray *allMovedPathsLast = [NSMutableArray array];
	NSMutableArray *allMovedPathsNew = [NSMutableArray array];
	for(int nSection = 0; nSection < lastSections.count; nSection++)
	{
		NSArray *lastObjects = [lastSections objectAtIndex:nSection];
		for(int nRow = 0; nRow < lastObjects.count; nRow++)
		{
			NSObject *objLast = [lastObjects objectAtIndex:nRow];
			NSIndexPath *pathLast = [NSIndexPath indexPathForRow:nRow inSection:nSection];
			BOOL newFound = NO;
			for(int nSectionNew = 0; nSectionNew < newSections.count; nSectionNew++)
			{
				if(!allowMoveRowBetweenSections && nSectionNew != nSection)
					continue;
				NSArray *newObjects = [newSections objectAtIndex:nSectionNew];
				for(int nRowNew = 0; nRowNew < newObjects.count; nRowNew++)
				{
					NSObject *objNew = [newObjects objectAtIndex:nRowNew];
					NSIndexPath *pathNew = [NSIndexPath indexPathForRow:nRowNew inSection:nSectionNew];
					if([objNew isEqual:objLast])
					{
						if(![allMovedPathsLast containsObject:pathLast] && ![allMovedPathsNew containsObject:pathNew])
						{
							newFound = YES;
							[allMovedPathsLast addObject:pathLast];
							[allMovedPathsNew addObject:pathNew];
						}
					}
				}
			}
			if(!newFound)
				[allRemovedPaths addObject:pathLast];
		}
	}
	
	for(int nSectionNew = 0; nSectionNew < newSections.count; nSectionNew++)
	{
		NSArray *newObjects = [newSections objectAtIndex:nSectionNew];
		for(int nRowNew = 0; nRowNew < newObjects.count; nRowNew++)
		{
			NSIndexPath *pathNew = [NSIndexPath indexPathForRow:nRowNew inSection:nSectionNew];
			if(![allMovedPathsNew containsObject:pathNew])
				[allAddedPaths addObject:pathNew];
		}
		[resultSectionsNew addObject:newObjects];
	}
	
	for(int i = (int)allMovedPathsLast.count - 1; allMovedPathsLast.count && i >= 0; i--)
	{
		NSIndexPath *pathLast = [allMovedPathsLast objectAtIndex:i];
		NSIndexPath *pathNew = [allMovedPathsNew objectAtIndex:i];
		if([pathLast isEqual:pathNew])
		{
			[allMovedPathsLast removeObjectAtIndex:i];
			[allMovedPathsNew removeObjectAtIndex:i];
		}
	}

	BOOL changed = (allRemovedPaths.count || allAddedPaths.count || allMovedPathsLast.count);
	if(changed && animated)
	{
		[self beginUpdates];
		if(allRemovedPaths.count)
			[self deleteRowsAtIndexPaths:allRemovedPaths withRowAnimation:
								animatedRows ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
		if(allAddedPaths.count)
			[self insertRowsAtIndexPaths:allAddedPaths withRowAnimation:
								animatedRows ? UITableViewRowAnimationTop : UITableViewRowAnimationNone];
		if(allMovedPathsLast.count)
		{
			for(int i = 0; i < allMovedPathsLast.count; i++)
			{
				NSIndexPath *pathLast = [allMovedPathsLast objectAtIndex:i];
				NSIndexPath *pathNew = [allMovedPathsNew objectAtIndex:i];
				[self moveRowAtIndexPath:pathLast toIndexPath:pathNew];
			}
		}
	}
	if(changed)
	{
		for(int nSection = 0; nSection < lastSections.count; nSection++)
		{
			NSMutableArray *resultObjects = [resultSections objectAtIndex:nSection];
			NSMutableArray *resultObjectsNew = [resultSectionsNew objectAtIndex:nSection];
			[resultObjects removeAllObjects];
			[resultObjects addObjectsFromArray:resultObjectsNew];
		}
		if(animated)
			[self endUpdates];
		else
			[self reloadData];
	}
}

- (void)updateRowsWithLastSections:(NSArray*)lastSections
					   newSections:(NSArray*)newSections
					resultSections:(NSMutableArray*)resultSections
	   allowMoveRowBetweenSections:(BOOL)allowMoveRowBetweenSections
						  animated:(BOOL)animated {
	
	[self updateRowsWithLastSections:lastSections
						 newSections:newSections
					  resultSections:resultSections
		 allowMoveRowBetweenSections:allowMoveRowBetweenSections
							animated:animated
						animatedRows:YES];
}

- (void)updateRowsWithLastSections:(NSArray*)lastSections
					   newSections:(NSArray*)newSections
					resultSections:(NSMutableArray*)resultSections
						  animated:(BOOL)animated {
	[self updateRowsWithLastSections:lastSections
						 newSections:newSections
					  resultSections:resultSections
		 allowMoveRowBetweenSections:YES
							animated:animated];
}

- (void)updateRowsWithLastObjects:(NSArray*)lastObjects
					   newObjects:(NSArray*)newObjects
					resultObjects:(NSMutableArray*)resultObjects
						 animated:(BOOL)animated
{
	NSArray *lastSections = [NSArray arrayWithObject:lastObjects];
	NSArray *newSections = [NSArray arrayWithObject:newObjects];
	NSMutableArray *resultSections = [NSMutableArray arrayWithObject:resultObjects];
	[self updateRowsWithLastSections:lastSections
						 newSections:newSections
					  resultSections:resultSections
							animated:animated];
}

- (BOOL)isRowVisibleWithIndexPath:(NSIndexPath *)indexPath
{
	NSArray *indexes = [self indexPathsForVisibleRows];
	for(NSIndexPath *path in indexes)
		if([path isEqual:indexes])
			return YES;
	return NO;
}

@end



#define kUITextView_PlaceholderView_Tag 43654645
@interface UITextView(UITextView_PlaceholderView_Superview)
- (void)checkPlaceholder;
@end
@interface UITextView_PlaceholderView : UIView
{
	NSString *_text;
	UIFont *_font;
	VLTimer *_timer;
}
@property(nonatomic, assign) NSString *text;
@property(nonatomic, assign) UIFont *font;
@end
@implementation UITextView_PlaceholderView
@synthesize text = _text;
@synthesize font = _font;
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		_text = [@"" retain];
		_font = [[UIFont systemFontOfSize:[UIFont systemFontSize]] retain];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];
		self.hidden = YES;
		self.tag = kUITextView_PlaceholderView_Tag;
		_timer = [[VLTimer alloc] init];
		[_timer setObserver:self selector:@selector(onTimerEvent:)];
		_timer.interval = 0.2;
		[_timer start];
	}
	return self;
}
- (void)setText:(NSString *)text
{
	if(!text)
		text = @"";
	if(![_text isEqual:text])
	{
		[_text release];
		_text = [text copy];
		[self setNeedsDisplay];
	}
}
- (void)setFont:(UIFont *)font
{
	[_font release];
	_font = [font retain];
	[self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
	CGRect rcBnds = self.bounds;
	if(_text.length)
	{
		float border = 8;
		CGRect rcText = CGRectInset(rcBnds, border, border);
		[_text vlDrawInRect:rcText withFont:_font color:[UIColor lightGrayColor]];
	}
}
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	return nil;
}
- (void)onTimerEvent:(id)sender
{
	if(self.superview)
	{
		CGRect rect = self.superview.bounds;
		if(!CGRectEqualToRect(rect, self.frame))
			self.frame = rect;
		UITextView *textView = (UITextView*)self.superview;
		[textView checkPlaceholder];
	}
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	[self setNeedsDisplay];
}
- (void)dealloc
{
	[_text release];
	[_timer release];
	[super dealloc];
}
@end

@implementation UITextView(VL_UITextView_Placeholder)

- (BOOL)hasUITextView_PlaceholderView
{
	UITextView_PlaceholderView *view = (UITextView_PlaceholderView*)[self viewWithTag:kUITextView_PlaceholderView_Tag];
	return (view != nil);
}
- (UITextView_PlaceholderView*)getUITextView_PlaceholderView
{
	UITextView_PlaceholderView *view = (UITextView_PlaceholderView*)[self viewWithTag:kUITextView_PlaceholderView_Tag];
	if(!view)
	{
		self.autoresizesSubviews = YES;
		self.contentMode = UIViewContentModeScaleToFill;
		view = [[[UITextView_PlaceholderView alloc] initWithFrame:CGRectZero] autorelease];
		[self addSubview:view];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
	}
	return view;
}

- (void)checkPlaceholder
{
	if(![self hasUITextView_PlaceholderView])
		return;
	UITextView_PlaceholderView *view = [self getUITextView_PlaceholderView];
	view.hidden = self.text.length > 0;
}

- (void)setPlaceholderText:(NSString*)text
{
	UITextView_PlaceholderView *view = [self getUITextView_PlaceholderView];
	view.text = text;
	[self setNeedsLayout];
	[self checkPlaceholder];
}

- (void)setPlaceholderFont:(UIFont*)font
{
	UITextView_PlaceholderView *view = [self getUITextView_PlaceholderView];
	view.font = font;
	[self setNeedsLayout];
	[self checkPlaceholder];
}

- (void)textChanged:(id)sender
{
	[self checkPlaceholder];
}

@end





@implementation UITableViewCell(VL_UITableViewCell_Category)

- (void)makeTransparent
{
	UIView *clearView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	clearView.backgroundColor = [UIColor clearColor];
	self.backgroundView = clearView;
	
	clearView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	clearView.backgroundColor = [UIColor clearColor];
	self.selectedBackgroundView = clearView;
	
	self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
	self.layer.borderWidth = self.contentView.layer.borderWidth = 0;
	self.layer.shadowColor = self.contentView.layer.shadowColor = [UIColor clearColor].CGColor;
}

@end





@implementation UISearchBar(VL_UISearchBar_Category)

- (void)makeTransparent
{
	self.backgroundColor = [UIColor clearColor];
	self.translucent = YES;
	self.tintColor = [UIColor clearColor];
	//if([self respondsToSelector:@selector(setBackgroundImage:)])
	//	[self performSelector:@selector(setBackgroundImage:) withObject:[UIImage imageNamed:@"clear.png"]];
	//else
	{
		for(UIView *subView in self.subviews)
		{
			if([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
			{
				[subView removeFromSuperview];
				break;
			}
		}
	}
}

@end







@implementation UIScreen(VLCategory)

+ (CGPoint)roundPoint:(CGPoint)point
{
	float scale = (kIosVersionFloat >= 4.0) ? [[UIScreen mainScreen] scale] : 1.0;
	point.x = round( point.x * scale ) / scale;
	point.y = round( point.y * scale ) / scale;
	return point;
}

+ (CGSize)roundSize:(CGSize)size
{
	float scale = (kIosVersionFloat >= 4.0) ? [[UIScreen mainScreen] scale] : 1.0;
	size.width = round( size.width * scale ) / scale;
	size.height = round( size.height * scale ) / scale;
	return size;
}

+ (CGRect)roundRect:(CGRect)rect
{
	float scale = (kIosVersionFloat >= 4.0) ? [[UIScreen mainScreen] scale] : 1.0;
	rect.origin.x = round( rect.origin.x * scale ) / scale;
	rect.origin.y = round( rect.origin.y * scale ) / scale;
	rect.size.width = round( rect.size.width * scale ) / scale;
	rect.size.height = round( rect.size.height * scale ) / scale;
	return rect;
}

@end





@implementation UIBarButtonItem(VL_UIBarButtonItem_Category)

+ (UIImage*)makeBarButtomImageWithImage:(UIImage*)image title:(NSString*)title
{
	float border = 2;
	float height = 20;
	
	CGSize szImage;
	szImage.height = height;
	szImage.width = szImage.height * image.size.width / image.size.height;
	
	VLBitmap *bmp = [[[VLBitmap alloc] init] autorelease];
	UIFont *font = [UIFont systemFontOfSize:14];
	CGSize szText = [title vlSizeWithFont:font];
	CGSize szBtn = CGSizeMake(border + szImage.width + 2*border + szText.width + border,
							  border + MAX(szImage.height, szText.height) + border);
	[bmp createWithWidth:szBtn.width height:szBtn.height];
	
	CGRect rcImage = CGRectZero;
	rcImage.size = szImage;
	rcImage.origin.x = border;
	rcImage.origin.y = szBtn.height/2 - rcImage.size.height/2;
	
	CGRect rcText = CGRectZero;
	rcText.size = szText;
	rcText.origin.y = szBtn.height/2 - rcText.size.height/2;
	rcText.origin.x = CGRectGetMaxX(rcImage) + 2*border;
	
	VLColor *colClear = [[[VLColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] autorelease];
	for(int y = 0; y < bmp.height; y++)
	{
		for(int x = 0; x < bmp.width; x++)
		{
			[bmp setPixel:colClear x:x y:y];
		}
	}
	
	CGContextDrawImage(bmp.context, rcImage, image.CGImage);
	
	UIGraphicsPushContext(bmp.context);
	CGContextSaveGState(bmp.context);
	
	CGAffineTransform transform = CGAffineTransformMakeTranslation(0, szBtn.height);
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	CGContextConcatCTM(bmp.context, transform);
	
	[title vlDrawInRect:rcText withFont:font color:[UIColor blackColor]];
	
	CGContextRestoreGState(bmp.context);
	UIGraphicsPopContext();
	
	return [bmp getCachedImage];
}

- (id)initWithImage:(UIImage *)image title:(NSString*)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
	UIImage *imageWithText = [UIBarButtonItem makeBarButtomImageWithImage:image title:title];
	self = [self initWithImage:imageWithText style:style target:target action:action];
	if(self)
	{
	}
	return self;
}

@end



@implementation UIWebView(VL_UIWebView_Category)

- (void)makeTransparent {
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
	for(UIView *view in self.subviews){
		if([view isKindOfClass:[UIImageView class]]) {
			// to transparent
			[view removeFromSuperview];
		}
		if([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView *sView = (UIScrollView *)view;
			//to hide Scroller bar
			//sView.showsVerticalScrollIndicator = NO;
			//sView.showsHorizontalScrollIndicator = NO;
			for(UIView* shadowView in [sView subviews]){
				//to remove shadow
				if([shadowView isKindOfClass:[UIImageView class]]) {
                    [shadowView setHidden:YES];
				}
			}
		}
	}
}

@end





