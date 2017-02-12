
#import <Foundation/Foundation.h>

@interface VLColor : NSObject <NSCopying>
{
	float _red;
	float _green;
	float _blue;
	float _alpha;
}

@property(nonatomic,assign) float red;
@property(nonatomic,assign) float green;
@property(nonatomic,assign) float blue;
@property(nonatomic,assign) float alpha;

@property(nonatomic,assign) float lightness;
@property(nonatomic,assign) float saturation;
@property(nonatomic,assign) float hue;

- (id)initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
+ (VLColor*)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
+ (VLColor*)randomColor;

- (VLColor*)lightUp:(float)value;
- (VLColor*)darkOut:(float)value;

- (void)getHue:(float*)hue
	saturation:(float*)saturation
	lightness:(float*)lightness;

- (void)setHue:(float)hue
	saturation:(float)saturation
	lightness:(float)lightness;

- (UIColor*)toUIColor;
+ (VLColor*)fromUIColor:(UIColor*)other;

- (void)assignFrom:(VLColor*)other;
- (BOOL)isEqual:(id)object;
- (id)copyWithZone:(NSZone*)zone;

@end

