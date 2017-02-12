
#import "VLGeometry.h"

@implementation VLSize

@synthesize width = _width;
@synthesize height = _height;

- (id)initWithWidth:(float)width height:(float)height
{
	self = [super init];
	if(self)
	{
		_width = width;
		_height = height;
	}
	return self;
}

- (id)initWithCGSize:(CGSize)size
{
	self = [super init];
	if(self)
	{
		_width = size.width;
		_height = size.height;
	}
	return self;
}

- (id)initWithString:(NSString*)str
{
	self = [super init];
	if(self)
	{
		CGSize sz = CGSizeFromString(str);
		_width = sz.width;
		_height = sz.height;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	VLSize *res = [[VLSize allocWithZone:zone] init];
	res.width = self.width;
	res.height = self.height;
	return res;
}

- (NSUInteger)hash
{
	NSUInteger res = 0;
	res = _width + _height;
	return res;
}

- (NSComparisonResult)compare:(VLSize*)other
{
	if(_width > other.width)
		return 1;
	else if(_width < other.width)
		return -1;
	if(_height > other.height)
		return 1;
	else if(_height < other.height)
		return -1;
	return 0;
}

- (BOOL)isEqual:(id)other
{
	VLSize *otherSize = ObjectCast(other, VLSize);
	if(!otherSize)
		return NO;
	return [self compare:otherSize] == NSOrderedSame;
}

- (NSString*)toString
{
	return NSStringFromCGSize([self toCGSize]);
}

- (CGSize)toCGSize
{
	return CGSizeMake(_width, _height);
}

+ (VLSize*)sizeWithWidth:(float)width height:(float)height
{
	return [[[VLSize alloc] initWithWidth:width height:height] autorelease];
}

@end



@implementation VLPoint

@synthesize x = _x;
@synthesize y = _y;

- (id)initWithCGPoint:(CGPoint)point
{
	self = [super init];
	if(self)
	{
		_x = point.x;
		_y = point.y;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	VLPoint *res = [[VLPoint allocWithZone:zone] init];
	[res assignFrom:self];
	return res;
}

- (void)assignFrom:(VLPoint*)other
{
	self.x = other.x;
	self.y = other.y;
}

- (NSUInteger)hash
{
	NSUInteger res = 0;
	res = _x + _y;
	return res;
}

- (NSComparisonResult)compare:(VLPoint*)other
{
	if(_x > other.x)
		return 1;
	else if(_x < other.x)
		return -1;
	if(_y > other.y)
		return 1;
	else if(_y < other.y)
		return -1;
	return 0;
}

- (BOOL)isEqual:(id)other
{
	VLPoint *otherPoint = ObjectCast(other, VLPoint);
	if(!otherPoint)
		return NO;
	return [self compare:otherPoint] == NSOrderedSame;
}

- (CGPoint)toCGPoint
{
	return CGPointMake(_x, _y);
}

@end



@implementation VLRect

@synthesize left = _left;
@synthesize top = _top;
@synthesize width = _width;
@synthesize height = _height;
@dynamic right;
@dynamic bottom;
@dynamic middleX;

- (CGRect)toCGRect
{
	return CGRectMake(_left, _top, _width, _height);
}

+ (VLRect*)makeWithCGRect:(CGRect)rect
{
	VLRect *res = [[[VLRect alloc] init] autorelease];
	res.left = rect.origin.x;
	res.top = rect.origin.y;
	res.width = rect.size.width;
	res.height = rect.size.height;
	return res;
}

- (float)right
{
	return _left + _width;
}

- (void)setRight:(float)right
{
	_width = right - _left;
}

- (float)bottom
{
	return _top + _height;
}

- (void)setBottom:(float)bottom
{
	_height = bottom - _top;
}

- (float)middleX
{
	return _left + _width/2;
}

@end




@implementation VLPolygon

@synthesize points = _points;

- (id)init
{
	if(self = [super init])
	{
		_points = [[NSMutableArray alloc] init];
	}
	return self;
}

- (VLRect*)getBounds
{
	VLRect *res = [[[VLRect alloc] init] autorelease];
	int pntCount = (int)_points.count;
	for(int i = 0; i < pntCount; i++)
	{
		VLPoint *pt = [_points objectAtIndex:i];
		if(i == 0)
		{
			res.left = pt.x;
			res.top = pt.y;
			res.width = 0;
			res.height = 0;
		}
		if(pt.x < res.left)
			res.left = pt.x;
		if(pt.x > res.right)
			res.right = pt.x;
		if(pt.y < res.top)
			res.top = pt.y;
		if(pt.y > res.bottom)
			res.bottom = pt.y;
	}
	return res;
}

- (BOOL)containsPoint:(VLPoint*)pt
{
	int pntCount = (int)_points.count;
	if(pntCount <= 2)
		return NO;
	int i, j = pntCount-1;
	BOOL oddNodes = NO;
	for(i = 0; i < pntCount; i++)
	{
		VLPoint *p1 = [_points objectAtIndex:i];
		VLPoint *p2 = [_points objectAtIndex:j];
		
		if( p2.y == p1.y )
		{
			if(		pt.y == p1.y
			   &&	pt.x >= MIN( p1.x, p2.x )
			   &&	pt.x < MAX( p1.x, p2.x )
			   )
				oddNodes =! oddNodes;
		}
		else if (	((p1.y < pt.y) && (p2.y >= pt.y))
				 ||  ((p2.y < pt.y) && (p1.y >= pt.y))
				 )
		{
			if ( p1.x + ( pt.y - p1.y ) / ( p2.y - p1.y ) * ( p2.x - p1.x ) < pt.x )
				oddNodes =! oddNodes;
		}
		j = i;
	}
	return oddNodes;
}

- (void)assignFrom:(VLPolygon*)other
{
	[_points removeAllObjects];
	for(VLPoint *pt in other.points)
		[_points addObject:[[pt copy] autorelease]];
}

- (id)copyWithZone:(NSZone*)zone
{
	VLPolygon *copy = [[VLPolygon allocWithZone:zone] init];
	[copy assignFrom:self];
	return copy;
}

- (void)dealloc
{
	[_points release];
	[super dealloc];
}

@end





@implementation VLGeometry

+ (double)correctAngle:(double)angle
{
	angle = angle - (long)(angle / (M_PI*2)) * (M_PI*2);
	if(angle < 0)
		angle += M_PI*2;
	return angle;
}

+ (double)roundAngleToQuadrant:(double)angle
{
	angle = [VLGeometry correctAngle:angle];
	if(angle < M_PI/4)
		angle = 0.0;
	else if(angle < M_PI/2)
		angle = M_PI/2;
	else if(angle < M_PI*3/4)
		angle = M_PI/2;
	else if(angle < M_PI)
		angle = M_PI;
	else if(angle < M_PI*5/4)
		angle = M_PI;
	else if(angle < M_PI*3/2)
		angle = M_PI*3/2;
	else if(angle < M_PI*7/4)
		angle = M_PI*3/2;
	else if(angle < M_PI*2)
		angle = M_PI*2;
	return angle;
}

+ (CGPoint)nearestPointOfLineP1:(CGPoint)lineP1 lineP2:(CGPoint)lineP2 toPoint:(CGPoint)point
{
	//var x0,y0,x1,y1,x2,y2,x3,y3,dx,dy,t,segment;
    float x1 = lineP1.x;
    float y1 = lineP1.y;
    float x2 = lineP2.x;
    float y2 = lineP2.y;
    float x3 = point.x;
    float y3 = point.y;
    //segment = argument6;
    float dx = x2 - x1;
    float dy = y2 - y1;
	float x0, y0, t;
    if ((dx == 0) && (dy == 0))
	{
        x0 = x1;
        y0 = y1;
    }
	else
	{
        t = ((x3 - x1) * dx + (y3 - y1) * dy) / (dx * dx + dy * dy);
        //if (segment) t = min(max(0,t),1);
        x0 = x1 + t * dx;
        y0 = y1 + t * dy;
    }
	return CGPointMake(x0, y0);
}

+ (float)distanceFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
	float dx = p1.x - p2.x;
	float dy = p1.y - p2.y;
	float res = sqrt(dx*dx + dy*dy);
	return res;
}

+ (float)getSegmentAngle:(CGSegment)segment
{
	float angle = 0;
	float dx = segment.p2.x - segment.p1.x;
	float dy = segment.p2.y - segment.p1.y;
	if(dx > 0 && dy > 0)
		angle = atan(dy/dx);
	else if(dx < 0 && dy > 0)
		angle = M_PI - atan(ABS(dy/dx));
	else if(dx < 0 && dy < 0)
		angle = atan(dy/dx) + M_PI;
	else if(dx > 0 && dy < 0)
		angle = -atan(ABS(dy/dx));
	if(angle < 0)
		angle += 2*M_PI;
	return angle;
}

+ (float)getSegmentAngleByPoint1:(CGPoint)p1 point2:(CGPoint)p2
{
	CGSegment seg;
	seg.p1 = p1;
	seg.p2 = p2;
	return [VLGeometry getSegmentAngle:seg];
}

+ (CGSize)sizeOfRotatedRect:(CGRect)rect byAngle:(float)angle
{
	angle = [VLGeometry correctAngle:angle];
	CGSize res = rect.size;
	CGPoint ptCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	float halfDiagonal = sqrt(rect.size.width*rect.size.width + rect.size.height*rect.size.height)/2;
	float diagAngles[4];
	CGPoint ptCorners[4];
	ptCorners[0] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	ptCorners[1] = CGPointMake(rect.origin.x, CGRectGetMaxY(rect));
	ptCorners[2] = CGPointMake(rect.origin.x, rect.origin.y);
	ptCorners[3] = CGPointMake(CGRectGetMaxX(rect), rect.origin.y);
	for(int i=0; i<4; i++)
	{
		CGSegment seg;
		seg.p1 = ptCenter;
		seg.p2 = ptCorners[i];
		diagAngles[i] = [VLGeometry getSegmentAngle:seg];
		diagAngles[i] += angle;
		diagAngles[i] = [VLGeometry correctAngle:diagAngles[i]];
	}
	float minX = ptCenter.x, minY = ptCenter.y, maxX = ptCenter.x, maxY = ptCenter.y;
	for(int i=0; i<4; i++)
	{
		float ang = diagAngles[i];
		float dx = halfDiagonal * cos(ang);
		float dy = halfDiagonal * sin(ang);
		CGPoint pt = ptCenter;
		pt.x += dx;
		pt.y += dy;
		if(pt.x < minX)
			minX = pt.x;
		if(pt.x > maxX)
			maxX = pt.x;
		if(pt.y < minY)
			minY = pt.y;
		if(pt.y > maxY)
			maxY = pt.y;
	}
	res.width = maxX - minX;
	res.height = maxY - minY;
	return res;
}

+ (CGRect)rectOfFitToRect:(CGRect)rect size:(CGSize)size
{
	CGRect res = rect;
	if(rect.size.width < 1 || rect.size.height < 1 || size.width < 1 || size.height < 1)
		return res;
	float rectScale = rect.size.width / rect.size.height;
	float sizeScale = size.width / size.height;
	if(sizeScale > rectScale)
	{
		res.size.height = rect.size.width / sizeScale;
		res.origin.y = rect.origin.y + rect.size.height/2 - res.size.height/2;
	}
	else if(sizeScale < rectScale)
	{
		res.size.width = rect.size.height * sizeScale;
		res.origin.x = rect.origin.x + rect.size.width/2 - res.size.width/2;
	}
	return res;
}

+ (BOOL)isPoint:(CGPoint)pt inPolygon:(const CGPoint*)pPoints count:(int)pntCount
{
	if(!pPoints || pntCount <= 2)
		return NO;
	int i, j = pntCount-1;
	BOOL oddNodes = NO;
	for ( i = 0; i < pntCount; i++ )
	{
		CGPoint p1 = *(pPoints + i);
		CGPoint p2 = *(pPoints + j);
		
		if( p2.y == p1.y )
		{
			if(		pt.y == p1.y
			   &&	pt.x >= MIN( p1.x, p2.x )
			   &&	pt.x < MAX( p1.x, p2.x )
			   )
				oddNodes =! oddNodes;
		}
		else if (	((p1.y < pt.y) && (p2.y >= pt.y))
				 ||  ((p2.y < pt.y) && (p1.y >= pt.y))
				 )
		{
			if ( p1.x + ( pt.y - p1.y ) / ( p2.y - p1.y ) * ( p2.x - p1.x ) < pt.x )
				oddNodes =! oddNodes;
		}
		j = i;
	}
	return oddNodes;
	return NO;
}

+ (CGPoints4)pointsOfRect:(CGRect)rect
{
	CGPoints4 res;
	res.points[0].x = rect.origin.x; res.points[0].y = rect.origin.y;
	res.points[1].x = CGRectGetMaxX(rect); res.points[1].y = rect.origin.y;
	res.points[2].x = CGRectGetMaxX(rect); res.points[2].y = CGRectGetMaxY(rect);
	res.points[3].x = rect.origin.x; res.points[3].y = CGRectGetMaxY(rect);
	return res;
}

+ (CGPoints4)rotateRect:(CGRect)rect byAngle:(float)angle
{
	CGPoints4 res = [VLGeometry pointsOfRect:rect];;
	angle = [VLGeometry correctAngle:angle];
	CGPoint cp = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	float radius = sqrt((cp.x - rect.origin.x)*(cp.x - rect.origin.x)+(cp.y - rect.origin.y)*(cp.y - rect.origin.y));
	for(int i=0; i<4; i++)
	{
		float lastAngle = [VLGeometry getSegmentAngleByPoint1:cp point2:res.points[i]];
		float newAngle = lastAngle + angle;
		float dx = radius * cos(newAngle);
		float dy = radius * sin(newAngle);
		res.points[i].x = cp.x + dx;
		res.points[i].y = cp.y + dy;
	}
	return res;
}

+ (float)getDifferenceBetweenAngle1:(float)angle1 angle2:(float)angle2
{
	angle1 = [VLGeometry correctAngle:angle1];
	angle2 = [VLGeometry correctAngle:angle2];
	float result = angle1 - angle2;
	result = [VLGeometry correctAngle:result];
	return result;
}

+ (CGRect)insetRect:(CGRect)rect horzRatio:(float)horzRatio vertRatio:(float)vertRatio round:(BOOL)round
{
	float horzVal = rect.size.width * horzRatio;
	float vertVal = rect.size.height * vertRatio;
	rect = CGRectInset(rect, horzVal, vertVal);
	if(round)
		rect = [VLGeometry roundRect:rect];
	return rect;
}

+ (CGPoint)roundPoint:(CGPoint)point
{
	point.x = round(point.x);
	point.y = round(point.y);
	return point;
}

+ (CGRect)circleRectInsideRect:(CGRect)rect roundFloor:(BOOL)roundFloor
{
	float radius = MIN(rect.size.width, rect.size.height)/2;
	if(roundFloor)
		radius = floor(radius);
	CGPoint ptCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	if(roundFloor)
		ptCenter = [VLGeometry roundPoint:ptCenter];
	CGRect result = CGRectMake(ptCenter.x - radius, ptCenter.y - radius, radius * 2, radius * 2);
	return result;
}

+ (CGRect)roundRect:(CGRect)rect
{
	CGRect res = CGRectMake(round(rect.origin.x), round(rect.origin.y), round(rect.size.width), round(rect.size.height));
	return res;
}

+ (CGRect)insetRect:(CGRect)rect withRatioInsets:(UIEdgeInsets)insets rounded:(BOOL)rounded
{
	float dLeft = rect.size.width * insets.left;
	float dTop = rect.size.height * insets.top;
	float dRight = rect.size.width * insets.right;
	float dBottom = rect.size.height * insets.bottom;
	CGRect res = CGRectMake(rect.origin.x + dLeft, rect.origin.y + dTop,
							rect.size.width - dLeft - dRight, rect.size.height - dTop - dBottom);
	if(rounded)
		res = [VLGeometry roundRect:res];
	return res;
}
+ (CGRect)insetRect:(CGRect)rect withRatioInsets:(UIEdgeInsets)insets
{
	return [VLGeometry insetRect:rect withRatioInsets:insets rounded:NO];
}

+ (float)partOfRectMinSide:(CGRect)rect withRatio:(float)ratio rounded:(BOOL)rounded
{
	float minSide = MIN(rect.size.width, rect.size.height);
	float res = minSide * ratio;
	if(rounded)
		res = roundf(res);
	return res;
}

+ (CGRect)insetRect:(CGRect)rect withRatio:(float)ratio rounded:(BOOL)rounded
{
	return [VLGeometry insetRect:rect withRatioInsets:UIEdgeInsetsMake(ratio, ratio, ratio, ratio) rounded:rounded];
}

+ (CGRect)insetRect:(CGRect)rect withMinRatio:(float)minRatio rounded:(BOOL)rounded
{
	float dSide = [VLGeometry partOfRectMinSide:rect withRatio:minRatio rounded:rounded];
	CGRect res = CGRectMake(rect.origin.x + dSide, rect.origin.y + dSide,
							rect.size.width - dSide - dSide, rect.size.height - dSide - dSide);
	return res;
}

+ (CGRect)insetRect:(CGRect)rect horzRatio:(float)horzRatio vertRatio:(float)vertRatio rounded:(BOOL)rounded
{
	return [VLGeometry insetRect:rect withRatioInsets:UIEdgeInsetsMake(vertRatio, horzRatio, vertRatio, horzRatio) rounded:rounded];
}

+ (CGRect)insetRect:(CGRect)rect horzRatio:(float)horzRatio rounded:(BOOL)rounded
{
	return [VLGeometry insetRect:rect horzRatio:horzRatio vertRatio:0 rounded:rounded];
}

+ (CGRect)insetRect:(CGRect)rect vertRatio:(float)vertRatio rounded:(BOOL)rounded
{
	return [VLGeometry insetRect:rect horzRatio:0 vertRatio:vertRatio rounded:rounded];
}

+ (CGRect)scaleRect:(CGRect)rect toFitWidth:(float)width
{
	CGRect result = rect;
	if(result.size.width == 0)
		return result;
	float scale = width / result.size.width;
	result.size.width = width;
	result.size.height = result.size.height * scale;
	return result;
}

+ (CGRect)rectInCenterOf:(CGRect)rect withSize:(CGSize)size rounded:(BOOL)rounded
{
	CGRect result = rect;
	result.size = size;
	result.origin.x = CGRectGetMidX(rect) - result.size.width/2;
	result.origin.y = CGRectGetMidY(rect) - result.size.height/2;
	if(rounded)
		result = [VLGeometry roundRect:result];
	return result;
}

@end


