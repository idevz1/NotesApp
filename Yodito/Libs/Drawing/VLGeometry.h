
#import <Foundation/Foundation.h>
#import "../Common/Classes.h"

struct CGLine // y = tan(angle) * x + b
{
	float angle;
	float b;
};
typedef struct CGLine CGLine;


struct CGSegment
{
	CGPoint p1;
	CGPoint p2;
};
typedef struct CGSegment CGSegment;


struct CGTriangle
{
	CGPoint p1;
	CGPoint p2;
	CGPoint p3;
};
typedef struct CGTriangle CGTriangle;


struct CGPoints3
{
	CGPoint points[3];
};
typedef struct CGPoints3 CGPoints3;


struct CGPoints4
{
	CGPoint points[4];
};
typedef struct CGPoints4 CGPoints4;


struct CGCircle
{
	CGPoint center;
	float radius;
};
typedef struct CGCircle CGCircle;



@interface VLSize : NSObject <NSCopying>
{
@private
	float _width;
	float _height;
}

@property(nonatomic,assign) float width;
@property(nonatomic,assign) float height;

- (id)initWithWidth:(float)width height:(float)height;
- (id)initWithCGSize:(CGSize)size;
- (id)initWithString:(NSString*)str;
- (id)copyWithZone:(NSZone *)zone;
- (NSUInteger)hash;
- (NSComparisonResult)compare:(VLSize*)other;
- (BOOL)isEqual:(id)other;
- (NSString*)toString;
- (CGSize)toCGSize;
+ (VLSize*)sizeWithWidth:(float)width height:(float)height;

@end


@interface VLPoint : NSObject <NSCopying>
{
@private
	float _x;
	float _y;
}

@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;

- (id)initWithCGPoint:(CGPoint)point;
- (id)copyWithZone:(NSZone *)zone;
- (void)assignFrom:(VLPoint*)other;
- (NSUInteger)hash;
- (NSComparisonResult)compare:(VLPoint*)other;
- (BOOL)isEqual:(id)other;
- (CGPoint)toCGPoint;

@end


@interface VLRect : NSObject
{
@private
	float _left;
	float _top;
	float _width;
	float _height;
}

@property(nonatomic,assign) float left;
@property(nonatomic,assign) float top;
@property(nonatomic,assign) float width;
@property(nonatomic,assign) float height;
@property(nonatomic,assign) float right;
@property(nonatomic,assign) float bottom;
@property(nonatomic,readonly) float middleX;

- (CGRect)toCGRect;
+ (VLRect*)makeWithCGRect:(CGRect)rect;

@end



@interface VLPolygon : NSObject <NSCopying>
{
@private
	NSMutableArray *_points;
}

@property(nonatomic,readonly) NSMutableArray *points;

- (VLRect*)getBounds;
- (BOOL)containsPoint:(VLPoint*)pt;
- (void)assignFrom:(VLPolygon*)other;
- (id)copyWithZone:(NSZone*)zone;

@end




@interface VLGeometry : NSObject
{
@private
}

+ (double)correctAngle:(double)angle;
+ (double)roundAngleToQuadrant:(double)angle;
+ (CGPoint)nearestPointOfLineP1:(CGPoint)lineP1 lineP2:(CGPoint)lineP2 toPoint:(CGPoint)point;
+ (float)distanceFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2;
+ (float)getSegmentAngle:(CGSegment)segment;
+ (float)getSegmentAngleByPoint1:(CGPoint)p1 point2:(CGPoint)p2;
+ (CGSize)sizeOfRotatedRect:(CGRect)rect byAngle:(float)angle;
+ (CGRect)rectOfFitToRect:(CGRect)rect size:(CGSize)size;
+ (BOOL)isPoint:(CGPoint)pt inPolygon:(const CGPoint*)pPoints count:(int)pntCount;
+ (CGPoints4)pointsOfRect:(CGRect)rect;
+ (CGPoints4)rotateRect:(CGRect)rect byAngle:(float)angle;
+ (float)getDifferenceBetweenAngle1:(float)angle1 angle2:(float)angle2;
+ (CGRect)roundRect:(CGRect)rect;
+ (CGRect)insetRect:(CGRect)rect horzRatio:(float)horzRatio vertRatio:(float)vertRatio round:(BOOL)round;
+ (CGPoint)roundPoint:(CGPoint)point;
+ (CGRect)circleRectInsideRect:(CGRect)rect roundFloor:(BOOL)roundFloor;
+ (CGRect)insetRect:(CGRect)rect withRatioInsets:(UIEdgeInsets)insets rounded:(BOOL)rounded;
+ (CGRect)insetRect:(CGRect)rect withRatioInsets:(UIEdgeInsets)insets;
+ (float)partOfRectMinSide:(CGRect)rect withRatio:(float)ratio rounded:(BOOL)rounded;
+ (CGRect)insetRect:(CGRect)rect withRatio:(float)ratio rounded:(BOOL)rounded;
+ (CGRect)insetRect:(CGRect)rect withMinRatio:(float)minRatio rounded:(BOOL)rounded;
+ (CGRect)insetRect:(CGRect)rect horzRatio:(float)horzRatio vertRatio:(float)vertRatio rounded:(BOOL)rounded;
+ (CGRect)insetRect:(CGRect)rect horzRatio:(float)horzRatio rounded:(BOOL)rounded;
+ (CGRect)insetRect:(CGRect)rect vertRatio:(float)vertRatio rounded:(BOOL)rounded;
+ (CGRect)scaleRect:(CGRect)rect toFitWidth:(float)width;
+ (CGRect)rectInCenterOf:(CGRect)rect withSize:(CGSize)size rounded:(BOOL)rounded;

@end


