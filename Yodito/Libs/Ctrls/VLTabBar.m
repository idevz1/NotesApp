
#import "VLTabBar.h"

#define kDefaultHeight 64.0

@implementation VLTabBarItem

@synthesize title = _title;
@synthesize image = _image;
@dynamic isSelected;

- (void)initialize
{
	[super initialize];
	_title = [@"" retain];
	self.contentMode = UIViewContentModeRedraw;
}

- (void)setTitle:(NSString *)title
{
	if(!title)
		title = @"";
	if(![_title isEqual:title])
	{
		[_title release];
		_title = [title copy];
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

- (void)setImage:(UIImage *)image
{
	if(_image != image)
	{
		[_image release];
		_image = [image retain];
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

- (VLTabBar*)parent
{
	return ObjectCast(self.superview, VLTabBar);
}

- (BOOL)isSelected
{
	return [self parent] && [self parent].selectedItem == self;
}

- (void)setIsSelected:(BOOL)isSelected
{
	if(self.isSelected != isSelected)
	{
		VLTabBar *parent = [self parent];
		if(parent)
		{
			if(isSelected)
			{
				parent.selectedItem = self;
			}
			else
			{
				if(parent.selectedItem == self)
					parent.selectedItem = nil;
			}
		}
	}
}

- (void)dealloc
{
	[_title release];
	[_image release];
	[super dealloc];
}

@end



@implementation VLTabBar

@synthesize selectedItem = _selectedItem;
@dynamic selectedItemIndex;
@synthesize msgrSelectedItemChanged = _msgrSelectedItemChanged;

- (void)initialize
{
	[super initialize];
	_items = [[NSMutableArray alloc] init];
	self.contentMode = UIViewContentModeRedraw;
	_msgrSelectedItemChanged = [[VLMessenger alloc] init];
	_msgrSelectedItemChanged.owner = self;
}

- (void)setSelectedItem:(VLTabBarItem *)selectedItem
{
	if(selectedItem && ![_items containsObject:selectedItem])
		selectedItem = nil;
	if(_selectedItem != selectedItem)
	{
		if(_selectedItem)
		{
			[_selectedItem setNeedsLayout];
			[_selectedItem setNeedsDisplay];
			[_selectedItem release];
		}
		_selectedItem = selectedItem;
		if(_selectedItem)
		{
			[_selectedItem retain];
			[_selectedItem setNeedsLayout];
			[_selectedItem setNeedsDisplay];
		}
		[_msgrSelectedItemChanged postMessage];
	}
}

- (int)selectedItemIndex
{
	if(_selectedItem)
		return (int)[_items indexOfObject:_selectedItem];
	return -1;
}

- (void)setSelectedItemIndex:(int)selectedItemIndex
{
	if(!_items.count)
		return;
	VLTabBarItem *item = nil;
	if(selectedItemIndex >= 0 && selectedItemIndex < _items.count)
		item = [_items objectAtIndex:selectedItemIndex];
	if(self.selectedItem != item)
		self.selectedItem = item;
}

- (CGRect)rectOfItem:(int)index
{
	CGRect rcBnds = self.bounds;
	CGRect rcItem = rcBnds;
	int itemWidthFloor = floor(rcBnds.size.width / _items.count);
	int reminder = rcBnds.size.width - itemWidthFloor * _items.count;
	rcItem.size.width = itemWidthFloor;
	rcItem.origin.x += index * itemWidthFloor;
	if(index < reminder)
		rcItem.size.width += 1;
	if(index <= reminder)
		rcItem.origin.x += MIN(index, reminder);
	return rcItem;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	for(int i = 0; i < _items.count; i++)
	{
		VLTabBarItem *item = [_items objectAtIndex:i];
		CGRect rcItem = [self rectOfItem:i];
		item.frame = rcItem;
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
	size.height = kDefaultHeight;
	return size;
}

- (VLTabBarItem*)addItem:(VLTabBarItem*)item
{
	[_items addObject:item];
	[self addSubview:item];
	[self setNeedsLayout];
	return item;
}

- (int)itemIndexByPoint:(CGPoint)pt
{
	for(int i = 0; i < _items.count; i++)
		if(CGRectContainsPoint([self rectOfItem:i], pt))
			return i;
	return -1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	CGPoint pt = [[touches anyObject] locationInView:self];
	int itemIndex = [self itemIndexByPoint:pt];
	if(itemIndex >= 0)
	{
		VLTabBarItem *item = [_items objectAtIndex:itemIndex];
		if(self.selectedItem != item)
			self.selectedItem = item;
	}
}

- (void)dealloc
{
	[_items release];
	[_selectedItem release];
	[_msgrSelectedItemChanged release];
	[super dealloc];
}

@end
