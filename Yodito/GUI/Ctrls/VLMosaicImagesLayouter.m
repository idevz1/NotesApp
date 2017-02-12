
#import "VLMosaicImagesLayouter.h"

#define kModuleSizeInPoints_iPhone 80
#define kModuleSizeInPoints_iPad 128
#define kMaxScrollPages_iPhone 400//4
#define kMaxScrollPages_iPad 400//4


@implementation VLMosaicImagesLayouter_MosaicData

@synthesize size = _size;
@synthesize imageSize = _imageSize;
@synthesize resultRect = _resultRect;

- (void)dealloc {
	[super dealloc];
}

@end



@implementation VLMosaicImagesLayouter

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)setupLayoutWithMosaicElements:(NSArray *)mosaicElements frameSize:(CGSize)frameSize {
	
	_frameSize = frameSize;
	NSInteger yOffset = 0;
	_maxElementsX = -1;
	_maxElementsY = -1;
	NSInteger maxHeight = 0;
	
	// Initial setup for the view
    NSUInteger maxElementsX = [self maxElementsX];
    NSUInteger maxElementsY = [self maxElementsY];
	
	[_elements release];
	
	_elements = [[VLMosaicImagesLayouter_TwoDimentionalArray alloc] initWithColumns:maxElementsX andRows:maxElementsY];
    
    CGPoint modulePoint = CGPointZero;
    
    //  Set modules in scrollView
    for (VLMosaicImagesLayouter_MosaicData *aModule in mosaicElements){
        CGSize aSize = [self sizeForModuleSize:aModule.size];
        NSArray *coordArray = [self coordArrayForCGSize:aSize];
        
        if (coordArray){
            NSInteger xIndex = [coordArray[0] integerValue];
            NSInteger yIndex = [coordArray[1] integerValue];
            
            modulePoint = CGPointMake(xIndex, yIndex);
            
            [self setModule:aModule withCGSize:aSize withCoord:modulePoint];
            
            CGRect mosaicModuleRect = CGRectMake(xIndex * [self moduleSizeInPoints],
                                                 yIndex * [self moduleSizeInPoints] + yOffset,
                                                 aSize.width * [self moduleSizeInPoints],
                                                 aSize.height * [self moduleSizeInPoints]);
			
			aModule.resultRect = mosaicModuleRect;
            
            maxHeight = MAX(maxHeight, CGRectGetMaxY(mosaicModuleRect));
        }
    }

	for(int i = 0; i < mosaicElements.count; i++) {
		VLMosaicImagesLayouter_MosaicData *item = [mosaicElements objectAtIndex:i];
		CGRect rect = item.resultRect;
		if(CGRectGetMaxX(rect) >= frameSize.width)
			continue;
		BOOL isOnRight = NO;
		for(int k = 0; k < mosaicElements.count; k++) {
			if(k == i)
				continue;
			VLMosaicImagesLayouter_MosaicData *item1 = [mosaicElements objectAtIndex:k];
			CGRect rect1 = item1.resultRect;
			if(rect.origin.y >= CGRectGetMaxY(rect1))
				continue;
			if(CGRectGetMaxY(rect) <= rect1.origin.y)
				continue;
			if(CGRectGetMaxX(rect1) > CGRectGetMaxX(rect))
				isOnRight = YES;
		}
		if(!isOnRight) {
			rect.size.width = frameSize.width - rect.origin.x;
			item.resultRect = rect;
		}
	}
	
	for(int i = 0; i < mosaicElements.count; i++) {
		VLMosaicImagesLayouter_MosaicData *item = [mosaicElements objectAtIndex:i];
		CGRect rect = item.resultRect;
		if(CGRectGetMaxY(rect) >= maxHeight)
			continue;
		BOOL isOnBottom = NO;
		for(int k = 0; k < mosaicElements.count; k++) {
			if(k == i)
				continue;
			VLMosaicImagesLayouter_MosaicData *item1 = [mosaicElements objectAtIndex:k];
			CGRect rect1 = item1.resultRect;
			if(rect.origin.x >= CGRectGetMaxX(rect1))
				continue;
			if(CGRectGetMaxX(rect) <= rect1.origin.x)
				continue;
			if(CGRectGetMaxY(rect1) > CGRectGetMaxY(rect))
				isOnBottom = YES;
		}
		if(!isOnBottom) {
			rect.size.height = maxHeight - rect.origin.y;
			item.resultRect = rect;
		}
	}
}

- (NSInteger)maxElementsX {
    NSInteger retVal = _maxElementsX;
    
    if (retVal == -1){
        retVal = _frameSize.width / [self moduleSizeInPoints];
    }
    
    return retVal;
}

- (NSInteger)maxElementsY {
    NSInteger retVal = _maxElementsY;
    
    if (retVal == -1){
        retVal = _frameSize.height / [self moduleSizeInPoints] * [self maxScrollPages];
    }
    
    return retVal;
}

- (NSInteger)moduleSizeInPoints {
    NSInteger retVal = kModuleSizeInPoints_iPhone;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        retVal = kModuleSizeInPoints_iPad;
    }
    return retVal;
}

- (NSInteger)maxScrollPages {
    NSInteger retVal = kMaxScrollPages_iPhone;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        retVal = kMaxScrollPages_iPad;
    }
    return retVal;
}

- (CGSize)sizeForModuleSize:(NSUInteger)aSize {
    CGSize retVal = CGSizeZero;
    
    switch (aSize) {
            
        case 0:
            retVal = CGSizeMake(4, 4);
            break;
        case 1:
            retVal = CGSizeMake(2, 2);
            break;
        case 2:
            retVal = CGSizeMake(2, 1);
            break;
        case 3:
            retVal = CGSizeMake(1, 1);
            break;
            
        default:
            break;
    }
    
    return retVal;
}

- (NSArray *)coordArrayForCGSize:(CGSize)aSize {
    NSArray *retVal = nil;
    BOOL hasFound = NO;
    
    NSInteger i=0;
    NSInteger j=0;
    
    while (j < [self maxElementsY] && !hasFound) {
        
        i = 0;
        
        while (i < [self maxElementsX] && !hasFound) {
            
            BOOL fitsInCoord = [self doesModuleWithCGSize:aSize fitsInCoord:CGPointMake(i, j)];
            if (fitsInCoord){
                hasFound = YES;
                
                NSNumber *xIndex = [NSNumber numberWithInteger:i];
                NSNumber *yIndex = [NSNumber numberWithInteger:j];
                retVal = @[xIndex, yIndex];
            }
            
            i++;
        }
        
        j++;
    }
    
    return retVal;
}

- (BOOL)doesModuleWithCGSize:(CGSize)aSize fitsInCoord:(CGPoint)aPoint {
    BOOL retVal = YES;
    
    NSInteger xOffset = 0;
    NSInteger yOffset = 0;
    
    while (retVal && yOffset < aSize.height){
        xOffset = 0;
        
        while (retVal && xOffset < aSize.width){
            NSInteger xIndex = aPoint.x + xOffset;
            NSInteger yIndex = aPoint.y + yOffset;
            
            //  Check if the coords are valid in the bidimensional array
            if (xIndex < [self maxElementsX] && yIndex < [self maxElementsY]){
                
                id anObject = [_elements objectAtColumn:xIndex andRow:yIndex];
                if (anObject != nil){
                    retVal = NO;
                }
                
                xOffset++;
            }else{
                retVal = NO;
            }
        }
        
        yOffset++;
    }
    
    return retVal;
}

- (void)setModule:(VLMosaicImagesLayouter_MosaicData *)aModule withCGSize:(CGSize)aSize withCoord:(CGPoint)aPoint {
    NSInteger xOffset = 0;
    NSInteger yOffset = 0;
    
    while (yOffset < aSize.height){
        xOffset = 0;
        
        while (xOffset < aSize.width){
            NSInteger xIndex = aPoint.x + xOffset;
            NSInteger yIndex = aPoint.y + yOffset;
            
            [_elements setObject:aModule atColumn:xIndex andRow:yIndex];
            
            xOffset++;
        }
        
        yOffset++;
    }
}

- (void)dealloc {
	[_elements release];
	[super dealloc];
}

@end






#define INVALID_ELEMENT_INDEX -1

@implementation VLMosaicImagesLayouter_TwoDimentionalArray

#pragma mark - Private

- (NSInteger)elementIndexWithColumn:(NSUInteger)xIndex andRow:(NSUInteger)yIndex {
    NSInteger retVal = 0;
	
    // Validating indexes are between columns / rows ranges
    if (xIndex >= columns || yIndex >= rows){
        retVal = INVALID_ELEMENT_INDEX;
    }else{
        retVal = xIndex + (yIndex * columns);
    }
    return retVal;
}

#pragma mark - Public

- (id)initWithColumns:(NSUInteger)numberOfColumns andRows:(NSUInteger)numberOfRows {
    self = [super init];
    if (self){
        NSUInteger capacity = numberOfColumns * numberOfRows;
        columns = numberOfColumns;
        rows = numberOfRows;
        elements = [[NSMutableArray alloc] initWithCapacity:capacity];
        
        for(NSInteger i=0; i<capacity; i++){
            [elements addObject:[NSNull null]];
        }
    }
    return self;
}

- (id)objectAtColumn:(NSUInteger)xIndex andRow:(NSUInteger)yIndex {
    id retVal = nil;
    
    NSInteger elementIndex = [self elementIndexWithColumn:xIndex andRow:yIndex];
	
    //  If the index is not invalid (ie xIndex greater than column quantity) then...
    if (elementIndex != INVALID_ELEMENT_INDEX){
        
        //  If the element in coord is not NULL then...
        if ([elements objectAtIndex:elementIndex] != [NSNull null]){
            retVal = [elements objectAtIndex:elementIndex];
        }
    }
	
    return retVal;
}

- (void)setObject:(id)anObject atColumn:(NSUInteger)xIndex andRow:(NSUInteger)yIndex {
    NSInteger elementIndex = [self elementIndexWithColumn:xIndex andRow:yIndex];
    
    [elements replaceObjectAtIndex:elementIndex withObject:anObject];
}

- (void)dealloc {
	[elements release];
	[super dealloc];
}

@end


