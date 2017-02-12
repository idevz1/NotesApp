
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

typedef enum
{
	EYTFigureViewTypeNone,
	EYTFigureViewTypeRoundedRect,
	EYTFigureViewTypeRoundedFilledRect
}
EYTFigureViewType;

@interface YTFigureView : VLBaseView {
@private
	EYTFigureViewType _type;
	UIColor *_lineColor;
	UIColor *_fillColor;
	float _lineWidth;
	float _cornerRadius;
	UIEdgeInsets _padding;
}

@property(nonatomic, assign) EYTFigureViewType type;
@property(nonatomic, assign) UIColor *lineColor;
@property(nonatomic, assign) UIColor *fillColor;
@property(nonatomic, assign) float lineWidth;
@property(nonatomic, assign) float cornerRadius;
@property(nonatomic, assign) UIEdgeInsets padding;

@end

