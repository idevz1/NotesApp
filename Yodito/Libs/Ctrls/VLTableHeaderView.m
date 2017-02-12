
#import "VLTableHeaderView.h"
#import "../Drawing/Classes.h"
#import "VLLabel.h"

@implementation VLTableColumnInfo

@synthesize title = _title;
@synthesize weight = _weight;
@synthesize textAlign = _textAlign;
@synthesize isTextUnderlined = _isTextUnderlined;

- (id)init
{
	self = [super init];
	if(self)
	{
		_title = [@"" retain];
	}
	return self;
}
- (id)initWithWeight:(float)weight title:(NSString*)title textAlign:(UITextAlignment)textAlign isTextUnderlined:(BOOL)isTextUnderlined
{
	self = [super init];
	if(self)
	{
		_weight = weight;
		_title = title ? [title copy] : [@"" retain];
		_textAlign = textAlign;
		_isTextUnderlined = isTextUnderlined;
	}
	return self;
}
- (id)initWithWeight:(float)weight title:(NSString*)title textAlign:(UITextAlignment)textAlign
{
	self = [self initWithWeight:weight title:title textAlign:textAlign isTextUnderlined:NO];
	if(self)
	{
	}
	return self;
}

- (void)setTitle:(NSString *)title
{
	if(!title)
		title = @"";
	if(![_title isEqual:title])
	{
		[_title release];
		_title = [title copy];
	}
}

- (void)dealloc
{
	[_title release];
	[super dealloc];
}

@end


#define kInsets UIEdgeInsetsMake(4, 0, 10, 0)

@implementation VLTableHeaderView

@synthesize textColor = _textColor;

- (void)initialize
{
	[super initialize];
	_columnsInfos = [[NSMutableArray alloc] init];
	_labels = [[NSMutableArray alloc] init];
	self.backgroundColor = [UIColor ColorsBlue].LightCyan.color;
	_textFont = [[UIFont systemFontOfSize:16.0] retain];
	_textColor = [[UIColor blackColor] retain];
}

- (void)refreshLabels
{
	NSMutableArray *newLabels = [NSMutableArray array];
	for(int i = 0; i < _columnsInfos.count; i++)
	{
		VLTableColumnInfo *columnInfo = [_columnsInfos objectAtIndex:i];
		VLLabel *label = nil;
		if(_labels.count)
		{
			label = [[[_labels lastObject] retain] autorelease];
			[_labels removeLastObject];
		}
		if(!label)
		{
			label = [[[VLLabel alloc] initWithFrame:CGRectZero] autorelease];
			label.backgroundColor = [UIColor clearColor];
			label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			label.numberOfLines = 1;
			label.adjustsFontSizeToFitWidth = YES;
			label.font = _textFont;
			label.textColor = _textColor;
			[self addSubview:label];
		}
		[newLabels addObject:label];
		label.textAlignment = columnInfo.textAlign;
		label.isUnderlined = columnInfo.isTextUnderlined;
		label.text = columnInfo.title;
	}
	for(VLLabel *label in _labels)
		[label removeFromSuperview];
	[_labels removeLastObject];
	[_labels addObjectsFromArray:newLabels];
	[self setNeedsLayout];
}

- (void)setColumnsInfos:(NSArray*)columnsInfos
		leftSpaceWeight:(float)leftSpaceWeight
	   rightSpaceWeight:(float)rightSpaceWeight
{
	_leftSpaceWeight = leftSpaceWeight;
	_rightSpaceWeight = rightSpaceWeight;
	[_columnsInfos removeAllObjects];
	for(int i = 0; i < columnsInfos.count; i++)
	{
		VLTableColumnInfo *columnInfo = [columnsInfos objectAtIndex:i];
		[_columnsInfos addObject:columnInfo];
	}
	[self refreshLabels];
}

- (float)optimalHeight
{
	CGSize szfont = [@"W0" vlSizeWithFont:_textFont];
	float result = kInsets.top + szfont.height + kInsets.bottom;
	return result;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	float allWeights = 0;
	allWeights += _leftSpaceWeight;
	for(int i = 0; i < _columnsInfos.count; i++)
	{
		VLTableColumnInfo *columnInfo = [_columnsInfos objectAtIndex:i];
		allWeights += columnInfo.weight;
	}
	allWeights += _rightSpaceWeight;
	if(allWeights <= 0)
		return;
	UIEdgeInsets insets = UIEdgeInsetsMake(0, kInsets.left, 0, kInsets.right);
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, insets);
	CGRect rcLabels = rcCtrls;
	float dw = rcCtrls.size.width * _leftSpaceWeight / allWeights;
	rcLabels.origin.x += dw;
	rcLabels.size.width -= dw;
	dw = rcCtrls.size.width * _rightSpaceWeight / allWeights;
	rcLabels.size.width -= dw;
	rcLabels = [VLGeometry roundRect:rcLabels];
	float curLeft = rcLabels.origin.x;
	for(int i = 0; i < _labels.count; i++)
	{
		VLLabel *label = [_labels objectAtIndex:i];
		VLTableColumnInfo *columnInfo = [_columnsInfos objectAtIndex:i];
		CGRect rcLabel = rcLabels;
		rcLabel.origin.x = curLeft;
		rcLabel.size.width = rcCtrls.size.width * columnInfo.weight / allWeights;
		rcLabel.size.width = round(rcLabel.size.width);
		if(i == _labels.count - 1)
			rcLabel.size.width = CGRectGetMaxX(rcLabels) - rcLabel.origin.x;
		curLeft = CGRectGetMaxX(rcLabel);
		label.frame = rcLabel;
	}
}

- (void)dealloc
{
	[_columnsInfos release];
	[_labels release];
	[_textFont release];
	[_textColor release];
	[super dealloc];
}

@end
