
#import "VLRotatableContentView.h"

@implementation VLRotatableContentView

@dynamic rotation;

- (id)initWithFrame:(CGRect)frame contentView:(UIView*)contentView
{
	self = [super initWithFrame:frame];
	if(self)
	{
		_contentView = [contentView retain];
		_contentView.backgroundColor = [UIColor clearColor];
		[self addSubview:_contentView];
	}
	return self;
}

- (float)rotation
{
	return _rotation;
}

- (void)setRotation:(float)newRotation
{
	newRotation -= ( (int) ( newRotation / (2 * M_PI) ) ) * (2 * M_PI);
	while(newRotation < 0)
		newRotation += (2 * M_PI);
	while(newRotation >= (2 * M_PI))
		newRotation -= (2 * M_PI);
	if(_rotation != newRotation)
	{
		_rotation = newRotation;
		[self layoutSubviews];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(!_contentView || rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	_contentView.bounds = rcBnds;
	CGAffineTransform transform = CGAffineTransformMakeRotation(_rotation);
	float dx = rcBnds.size.width/2;
	float dy = rcBnds.size.height/2;
	float radius = sqrtf( dx * dx + dy * dy );
	float angle = atan(dy / dx);
	angle -= _rotation;
	dx = radius * cos(angle);
	dy = radius * sin(angle);
	transform = CGAffineTransformTranslate(transform, dx, dy);
	_contentView.transform = transform;
}

- (void)dealloc
{
	[_contentView release];
    [super dealloc];
}

@end



