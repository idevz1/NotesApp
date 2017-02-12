
#import "VLLayoutsParams.h"
#import "../Drawing/Classes.h"

@interface VLLayoutsParams_Item : NSObject
{
	float heightRatio;
	float heightRatioBefore;
	float heightRatioAfter;
	float widthRatio;
	float widthRatioBefore;
	float widthRatioAfter;
	NSObject *_obj;
}

@property(nonatomic, assign) float heightRatio;
@property(nonatomic, assign) float heightRatioBefore;
@property(nonatomic, assign) float heightRatioAfter;
@property(nonatomic, assign) float widthRatio;
@property(nonatomic, assign) float widthRatioBefore;
@property(nonatomic, assign) float widthRatioAfter;
@property(nonatomic, retain) NSObject *obj;

@end

@implementation VLLayoutsParams_Item

@synthesize heightRatio = _heightRatio;
@synthesize heightRatioBefore = _heightRatioBefore;
@synthesize heightRatioAfter = _heightRatioAfter;
@synthesize widthRatio = _widthRatio;
@synthesize widthRatioBefore = _widthRatioBefore;
@synthesize widthRatioAfter = _widthRatioAfter;
@synthesize obj = _obj;

- (void)dealloc
{
	[_obj release];
	[super dealloc];
}

@end



@implementation VLLayoutsParams

@synthesize orientation = _orientation;

- (id)init
{
	self = [super init];
	if(self)
	{
		_items = [[NSMutableArray alloc] init];
		_orientation = EVLOrientationVertical;
	}
	return self;
}

- (void)add:(NSObject*)obj
	heightRatio:(float)heightRatio
	heightRatioBefore:(float)heightRatioBefore
	heightRatioAfter:(float)heightRatioAfter
	 widthRatio:(float)widthRatio
	widthRatioBefore:(float)widthRatioBefore
	widthRatioAfter:(float)widthRatioAfter
{
	VLLayoutsParams_Item *item = [[VLLayoutsParams_Item new] autorelease];
	item.obj = obj;
	item.heightRatio = heightRatio;
	item.heightRatioBefore = heightRatioBefore;
	item.heightRatioAfter = heightRatioAfter;
	item.widthRatio = widthRatio;
	item.widthRatioBefore = widthRatioBefore;
	item.widthRatioAfter = widthRatioAfter;
	[_items addObject:item];
}

- (void)clear
{
	[_items removeAllObjects];
}

- (void)layoutVertInRect:(CGRect)rect
{
	if(!rect.size.width || !rect.size.height)
		return;
	float allRatio = 0;
	for(VLLayoutsParams_Item *item in _items)
	{
		allRatio += item.heightRatio;
		allRatio += item.heightRatioBefore;
		allRatio += item.heightRatioAfter;
	}
	if(!allRatio)
		return;
	float curRatioBefore = 0;
	for(VLLayoutsParams_Item *item in _items)
	{
		curRatioBefore += item.heightRatioBefore;
		CGRect rcView = rect;
		rcView.size.height = rect.size.height * (item.heightRatio / allRatio);
		rcView.origin.y = rect.origin.y + rect.size.height * (curRatioBefore / allRatio);
		curRatioBefore += item.heightRatio;
		curRatioBefore += item.heightRatioAfter;
		float allOtherRatio = item.widthRatioBefore + item.widthRatio + item.widthRatioAfter;
		rcView.size.width = rect.size.width * item.widthRatio / allOtherRatio;
		rcView.origin.x = rect.origin.x + rect.size.width * item.widthRatioBefore / allOtherRatio;
		UIView *view = ObjectCast(item.obj, UIView);
		if(view)
			view.frame = [VLGeometry roundRect:rcView];
		VLLayoutsParams *params = ObjectCast(item.obj, VLLayoutsParams);
		if(params)
			[params layoutInRect:rcView];
	}
}

- (void)layoutHorzInRect:(CGRect)rect
{
	if(!rect.size.width || !rect.size.height)
		return;
	float allRatio = 0;
	for(VLLayoutsParams_Item *item in _items)
	{
		allRatio += item.widthRatio;
		allRatio += item.widthRatioBefore;
		allRatio += item.widthRatioAfter;
	}
	if(!allRatio)
		return;
	float curRatioBefore = 0;
	for(VLLayoutsParams_Item *item in _items)
	{
		curRatioBefore += item.widthRatioBefore;
		CGRect rcView = rect;
		rcView.size.width = rect.size.width * (item.widthRatio / allRatio);
		rcView.origin.x = rect.origin.x + rect.size.width * (curRatioBefore / allRatio);
		curRatioBefore += item.widthRatio;
		curRatioBefore += item.widthRatioAfter;
		float allOtherRatio = item.heightRatioBefore + item.heightRatio + item.heightRatioAfter;
		rcView.size.height = rect.size.height * item.heightRatio / allOtherRatio;
		rcView.origin.y = rect.origin.y + rect.size.height * item.heightRatioBefore / allOtherRatio;
		UIView *view = ObjectCast(item.obj, UIView);
		if(view)
			view.frame = [VLGeometry roundRect:rcView];
		VLLayoutsParams *params = ObjectCast(item.obj, VLLayoutsParams);
		if(params)
			[params layoutInRect:rcView];
	}
}

- (void)layoutInRect:(CGRect)rect
{
	if(_orientation == EVLOrientationVertical)
		[self layoutVertInRect:rect];
	else if(_orientation == EVLOrientationHorizontal)
		[self layoutHorzInRect:rect];
}

- (void)add:(NSObject*)obj
	heightRatio:(float)heightRatio
	heightRatioBefore:(float)heightRatioBefore
	heightRatioAfter:(float)heightRatioAfter
{
	[self add:obj heightRatio:heightRatio heightRatioBefore:heightRatioBefore
		heightRatioAfter:heightRatioAfter widthRatio:1.0 widthRatioBefore:0 widthRatioAfter:0];
}

- (void)add:(NSObject*)obj
	 widthRatio:(float)widthRatio
	widthRatioBefore:(float)widthRatioBefore
	widthRatioAfter:(float)widthRatioAfter
{
	[self add:obj heightRatio:1.0 heightRatioBefore:0
		heightRatioAfter:0 widthRatio:widthRatio widthRatioBefore:widthRatioBefore widthRatioAfter:widthRatioAfter];
}

- (void)add:(NSObject*)obj widthRatio:(float)widthRatio
{
	[self add:obj widthRatio:widthRatio widthRatioBefore:0 widthRatioAfter:0];
}

- (void)addView:(UIView*)view
	heightRatio:(float)heightRatio
	heightRatioBefore:(float)heightRatioBefore
	heightRatioAfter:(float)heightRatioAfter
	 widthRatio:(float)widthRatio
	widthRatioBefore:(float)widthRatioBefore
	widthRatioAfter:(float)widthRatioAfter
{
	[self add:view heightRatio:heightRatio heightRatioBefore:heightRatioBefore heightRatioAfter:heightRatioAfter
		widthRatio:widthRatio widthRatioBefore:widthRatioBefore widthRatioAfter:widthRatioAfter];
}
- (void)addView:(UIView*)view
	heightRatio:(float)heightRatio
	heightRatioBefore:(float)heightRatioBefore
	heightRatioAfter:(float)heightRatioAfter
{
	[self add:view heightRatio:heightRatio heightRatioBefore:heightRatioBefore heightRatioAfter:heightRatioAfter];
}
- (void)addView:(UIView*)view
	 widthRatio:(float)widthRatio
	widthRatioBefore:(float)widthRatioBefore
	widthRatioAfter:(float)widthRatioAfter
{
	[self add:view widthRatio:widthRatio widthRatioBefore:widthRatioBefore widthRatioAfter:widthRatioAfter];
}
- (void)addView:(UIView*)view widthRatio:(float)widthRatio
{
	[self add:view widthRatio:widthRatio];
}

- (void)dealloc
{
	[_items release];
	[super dealloc];
}

@end

