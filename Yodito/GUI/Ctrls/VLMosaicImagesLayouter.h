
#import <Foundation/Foundation.h>

/**
 Source - https://github.com/betzerra/MosaicUI
 */

@class VLMosaicImagesLayouter_TwoDimentionalArray;


@interface VLMosaicImagesLayouter_MosaicData : NSObject {
@private
	NSInteger _size;
	CGSize _imageSize;
	CGRect _resultRect;
}

@property(nonatomic, assign) NSInteger size;
@property(nonatomic, assign) CGSize imageSize;
@property(nonatomic, assign) CGRect resultRect;

@end


@interface VLMosaicImagesLayouter : NSObject {
@private
	NSInteger _maxElementsX;
	NSInteger _maxElementsY;
	CGSize _frameSize;
	VLMosaicImagesLayouter_TwoDimentionalArray *_elements;
}

- (void)setupLayoutWithMosaicElements:(NSArray *)mosaicElements frameSize:(CGSize)frameSize;

@end



@interface VLMosaicImagesLayouter_TwoDimentionalArray : NSObject{
    NSMutableArray* elements;
    NSUInteger rows, columns;
}

-(id)initWithColumns:(NSUInteger)numberOfColumns andRows:(NSUInteger)numberOfRows;
-(id)objectAtColumn:(NSUInteger)xIndex andRow:(NSUInteger)yIndex;
-(void)setObject:(id)anObject atColumn:(NSUInteger)xIndex andRow:(NSUInteger)yIndex;

@end

