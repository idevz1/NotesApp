
#import <Foundation/Foundation.h>
#import "../Common/Classes.h"

@interface VLLayoutsParams : NSObject
{
	NSMutableArray *_items;
	EVLOrientation _orientation;
}

@property(nonatomic, assign) EVLOrientation orientation;

- (void)add:(NSObject*)obj
	heightRatio:(float)heightRatio
	heightRatioBefore:(float)heightRatioBefore
	heightRatioAfter:(float)heightRatioAfter
	 widthRatio:(float)widthRatio
	widthRatioBefore:(float)widthRatioBefore
	widthRatioAfter:(float)widthRatioAfter;

- (void)add:(NSObject*)obj
	heightRatio:(float)heightRatio
	heightRatioBefore:(float)heightRatioBefore
	heightRatioAfter:(float)heightRatioAfter;

- (void)add:(NSObject*)obj
	 widthRatio:(float)widthRatio
	widthRatioBefore:(float)widthRatioBefore
	widthRatioAfter:(float)widthRatioAfter;

- (void)add:(NSObject*)obj widthRatio:(float)widthRatio;


- (void)addView:(UIView*)view
	heightRatio:(float)heightRatio
	heightRatioBefore:(float)heightRatioBefore
	heightRatioAfter:(float)heightRatioAfter
	 widthRatio:(float)widthRatio
	widthRatioBefore:(float)widthRatioBefore
	widthRatioAfter:(float)widthRatioAfter;
- (void)addView:(UIView*)view
	heightRatio:(float)heightRatio
	heightRatioBefore:(float)heightRatioBefore
	heightRatioAfter:(float)heightRatioAfter;
- (void)addView:(UIView*)view
	 widthRatio:(float)widthRatio
	widthRatioBefore:(float)widthRatioBefore
	widthRatioAfter:(float)widthRatioAfter;
- (void)addView:(UIView*)view widthRatio:(float)widthRatio;


- (void)clear;
- (void)layoutVertInRect:(CGRect)rect;
- (void)layoutHorzInRect:(CGRect)rect;
- (void)layoutInRect:(CGRect)rect;

@end

