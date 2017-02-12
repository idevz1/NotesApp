
#import "VLTableViewCell.h"

@implementation VLTableViewCell

@synthesize subView = _subView;
@synthesize canSubViewIndentRight = _canSubViewIndentRight;

- (id)init
{
	self = [super init];
	if(self)
	{
		_canSubViewIndentRight = YES;
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if(self)
	{
		_canSubViewIndentRight = YES;
	}
	return self;
}

- (id)initWithSubView:(UIView*)subView reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if(self)
	{
		_canSubViewIndentRight = YES;
		_subView = [subView retain];
		[self.contentView addSubview:_subView];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if(_subView)
	{
		CGRect rcSub = self.contentView.bounds;
		if(!_canSubViewIndentRight)
		{
			CGRect rcBnds = self.bounds;
			rcBnds = [self convertRect:rcBnds toView:self.contentView];
			rcSub.size.width = CGRectGetMaxX(rcBnds) - rcSub.origin.x;
		}
		_subView.frame = rcSub;
	}
}

- (void)dealloc
{
	[_subView release];
	[super dealloc];
}

@end
