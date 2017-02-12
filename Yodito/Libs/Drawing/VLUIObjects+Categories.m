
#import "VLUIObjects+Categories.h"

#define CIM(colname,num) [arr addObject:[[[VLUIColorInfo alloc] initWithNumber:num name:colname] autorelease]]

@implementation VLUIColorArgs

@synthesize color = _color;

- (void)dealloc
{
	[_color release];
	[super dealloc];
}

@end


@implementation VLUIColorInfo

@synthesize color = _color;
@synthesize name = _name;

- (id)initWithNumber:(unsigned int)num name:(NSString*)name
{
	self = [super init];
	if(self)
	{
		_color = [[UIColor colorWithNumber:num] retain];
		_name = [name copy];
	}
	return self;
}

- (void)dealloc
{
	[_color release];
	[_name release];
	[super dealloc];
}

@end


#define CIM2(colname,num)		\
@dynamic colname;					\
- (VLUIColorInfo*)colname			\
{												\
static VLUIColorInfo *colname = nil;			\
if(!colname)									\
colname = [[VLUIColorInfo alloc] initWithNumber:num name:@#colname];	\
return colname;		\
}

@implementation VLUIColorInfoListBase
@end

@implementation VLUIColorInfoListCommon
CIM2(White, 0xFFFFFF)
CIM2(Silver, 0xC0C0C0);
CIM2(Gray, 0x808080);
CIM2(Black, 0x000000);
CIM2(Red, 0xFF0000);
CIM2(Maroon, 0x800000);
CIM2(Yellow, 0xFFFF00);
CIM2(Olive, 0x808000);
CIM2(Lime, 0x00FF00);
CIM2(Green, 0x008000);
CIM2(Aqua, 0x00FFFF);
CIM2(Teal, 0x008080);
CIM2(Blue, 0x0000FF);
CIM2(Navy, 0x000080);
CIM2(Fuchsia, 0xFF00FF);
CIM2(Purple, 0x800080);
@end
@implementation VLUIColorInfoListRed
CIM2(IndianRed, 0xCD5C5C);
CIM2(LightCoral, 0xF08080);
CIM2(Salmon, 0xFA8072);
CIM2(DarkSalmon, 0xE9967A);
CIM2(LightSalmon, 0xFFA07A);
CIM2(Crimson, 0xDC143C);
CIM2(Red, 0xFF0000);
CIM2(FireBrick, 0xB22222);
CIM2(DarkRed, 0x8B0000);
@end
@implementation VLUIColorInfoListPink
CIM2(Pink, 0xFFC0CB);
CIM2(LightPink, 0xFFB6C1);
CIM2(HotPink, 0xFF69B4);
CIM2(DeepPink, 0xFF1493);
CIM2(MediumVioletRed, 0xC71585);
CIM2(PaleVioletRed, 0xDB7093);
@end
@implementation VLUIColorInfoListOrange
CIM2(LightSalmon, 0xFFA07A);
CIM2(Coral, 0xFF7F50);
CIM2(Tomato, 0xFF6347);
CIM2(OrangeRed, 0xFF4500);
CIM2(DarkOrange, 0xFF8C00);
CIM2(Orange, 0xFFA500);
@end
@implementation VLUIColorInfoListYellow
CIM2(Gold, 0xFFD700);
CIM2(Yellow, 0xFFFF00);
CIM2(LightYellow, 0xFFFFE0);
CIM2(LemonChiffon, 0xFFFACD);
CIM2(LightGoldenrodYellow, 0xFAFAD2);
CIM2(PapayaWhip, 0xFFEFD5);
CIM2(Moccasin, 0xFFE4B5);
CIM2(PeachPuff, 0xFFDAB9);
CIM2(PaleGoldenrod, 0xEEE8AA);
CIM2(Khaki, 0xF0E68C);
CIM2(DarkKhaki, 0xBDB76B);
@end
@implementation VLUIColorInfoListPurple
CIM2(Lavender, 0xE6E6FA);
CIM2(Thistle, 0xD8BFD8);
CIM2(Plum, 0xDDA0DD);
CIM2(Violet, 0xEE82EE);
CIM2(Orchid, 0xDA70D6);
CIM2(Fuchsia, 0xFF00FF);
CIM2(Magenta, 0xFF00FF);
CIM2(MediumOrchid, 0xBA55D3);
CIM2(MediumPurple, 0x9370DB);
CIM2(Amethyst, 0x9966CC);
CIM2(BlueViolet, 0x8A2BE2);
CIM2(DarkViolet, 0x9400D3);
CIM2(DarkOrchid, 0x9932CC);
CIM2(DarkMagenta, 0x8B008B);
CIM2(Purple, 0x800080);
CIM2(Indigo, 0x4B0082);
CIM2(SlateBlue, 0x6A5ACD);
CIM2(DarkSlateBlue, 0x483D8B);
CIM2(MediumSlateBlue, 0x7B68EE);
@end
@implementation VLUIColorInfoListGreen
CIM2(GreenYellow, 0xADFF2F);
CIM2(Chartreuse, 0x7FFF00);
CIM2(LawnGreen, 0x7CFC00);
CIM2(Lime, 0x00FF00);
CIM2(LimeGreen, 0x32CD32);
CIM2(PaleGreen, 0x98FB98);
CIM2(LightGreen, 0x90EE90);
CIM2(MediumSpringGreen, 0x00FA9A);
CIM2(SpringGreen, 0x00FF7F);
CIM2(MediumSeaGreen, 0x3CB371);
CIM2(SeaGreen, 0x2E8B57);
CIM2(ForestGreen, 0x228B22);
CIM2(Green, 0x008000);
CIM2(DarkGreen, 0x006400);
CIM2(YellowGreen, 0x9ACD32);
CIM2(OliveDrab, 0x6B8E23);
CIM2(Olive, 0x808000);
CIM2(DarkOliveGreen, 0x556B2F);
CIM2(MediumAquamarine, 0x66CDAA);
CIM2(DarkSeaGreen, 0x8FBC8F);
CIM2(LightSeaGreen, 0x20B2AA);
CIM2(DarkCyan, 0x008B8B);
CIM2(Teal, 0x008080);
@end
@implementation VLUIColorInfoListBlue
CIM2(Aqua, 0x00FFFF);
CIM2(Cyan, 0x00FFFF);
CIM2(LightCyan, 0xE0FFFF);
CIM2(PaleTurquoise, 0xAFEEEE);
CIM2(Aquamarine, 0x7FFFD4);
CIM2(Turquoise, 0x40E0D0);
CIM2(MediumTurquoise, 0x48D1CC);
CIM2(DarkTurquoise, 0x00CED1);
CIM2(CadetBlue, 0x5F9EA0);
CIM2(SteelBlue, 0x4682B4);
CIM2(LightSteelBlue, 0xB0C4DE);
CIM2(PowderBlue, 0xB0E0E6);
CIM2(LightBlue, 0xADD8E6);
CIM2(SkyBlue, 0x87CEEB);
CIM2(LightSkyBlue, 0x87CEFA);
CIM2(DeepSkyBlue, 0x00BFFF);
CIM2(DodgerBlue, 0x1E90FF);
CIM2(CornflowerBlue, 0x6495ED);
CIM2(MediumSlateBlue, 0x7B68EE);
CIM2(RoyalBlue, 0x4169E1);
CIM2(Blue, 0x0000FF);
CIM2(MediumBlue, 0x0000CD);
CIM2(DarkBlue, 0x00008B);
CIM2(Navy, 0x000080);
CIM2(MidnightBlue, 0x191970);
@end
@implementation VLUIColorInfoListBrown
CIM2(Cornsilk, 0xFFF8DC);
CIM2(BlanchedAlmond, 0xFFEBCD);
CIM2(Bisque, 0xFFE4C4);
CIM2(NavajoWhite, 0xFFDEAD);
CIM2(Wheat, 0xF5DEB3);
CIM2(BurlyWood, 0xDEB887);
CIM2(Tan, 0xD2B48C);
CIM2(RosyBrown, 0xBC8F8F);
CIM2(SandyBrown, 0xF4A460);
CIM2(Goldenrod, 0xDAA520);
CIM2(DarkGoldenrod, 0xB8860B);
CIM2(Peru, 0xCD853F);
CIM2(Chocolate, 0xD2691E);
CIM2(SaddleBrown, 0x8B4513);
CIM2(Sienna, 0xA0522D);
CIM2(Brown, 0xA52A2A);
CIM2(Maroon, 0x800000);
@end
@implementation VLUIColorInfoListWhite
CIM2(White, 0xFFFFFF);
CIM2(Snow, 0xFFFAFA);
CIM2(Honeydew, 0xF0FFF0);
CIM2(MintCream, 0xF5FFFA);
CIM2(Azure, 0xF0FFFF);
CIM2(AliceBlue, 0xF0F8FF);
CIM2(GhostWhite, 0xF8F8FF);
CIM2(WhiteSmoke, 0xF5F5F5);
CIM2(Seashell, 0xFFF5EE);
CIM2(Beige, 0xF5F5DC);
CIM2(OldLace, 0xFDF5E6);
CIM2(FloralWhite, 0xFFFAF0);
CIM2(Ivory, 0xFFFFF0);
CIM2(AntiqueWhite, 0xFAEBD7);
CIM2(Linen, 0xFAF0E6);
CIM2(LavenderBlush, 0xFFF0F5);
CIM2(MistyRose, 0xFFE4E1);
@end
@implementation VLUIColorInfoListGray
CIM2(Gainsboro, 0xDCDCDC);
CIM2(LightGrey, 0xD3D3D3);
CIM2(Silver, 0xC0C0C0);
CIM2(DarkGray, 0xA9A9A9);
CIM2(Gray, 0x808080);
CIM2(DimGray, 0x696969);
CIM2(LightSlateGray, 0x778899);
CIM2(SlateGray, 0x708090);
CIM2(DarkSlateGray, 0x2F4F4F);
CIM2(Black, 0x000000);
@end



@implementation UIColor(VL_UIColor_Category)

- (void)getRGBAComponents:(CGFloat*)pcomponents
{
	CGColorRef colCG = self.CGColor;
	int num = (int)CGColorGetNumberOfComponents(colCG);
	if(num == 4)
	{
		const CGFloat *pcurcomponents = CGColorGetComponents(colCG);
		for (int component = 0; component < 4; component++)
			*(pcomponents + component) = *(pcurcomponents + component);
		return;
	}
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big
                                                 //kCGImageAlphaLast
												 );
    CGContextSetFillColorWithColor(context, colCG);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
	
    for (int component = 0; component < 4; component++)
        *(pcomponents + component) = resultingPixel[component] / 255.0f;
}

- (NSString*)toString
{
	//CGColorRef c = self.CGColor;
	//const CGFloat *components = CGColorGetComponents(c);
	CGFloat components[4];
	[self getRGBAComponents:&components[0]];
    size_t numberOfComponents = 4;//CGColorGetNumberOfComponents(c);
    NSMutableString *s = [[[NSMutableString alloc] init] autorelease];
    [s appendString:@"{"];
    for (size_t i = 0; i < numberOfComponents; ++i) {
        if (i > 0) {
            [s appendString:@","];
        }
        [s appendString:[NSString stringWithFormat:@"%f", components[i]]];
    }
    [s appendString:@"}"];
    return s;
}

+ (UIColor*)fromString:(NSString*)str
{
	str = [str stringByReplacingOccurrencesOfString:@"{" withString:@""];
	str = [str stringByReplacingOccurrencesOfString:@"}" withString:@""];
	str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSArray *components = [str componentsSeparatedByString:@","];
	CGFloat r = ([components count] > 0) ? [[components objectAtIndex:0] floatValue] : 0.0;
	CGFloat g = ([components count] > 1) ? [[components objectAtIndex:1] floatValue] : 0.0;
	CGFloat b = ([components count] > 2) ? [[components objectAtIndex:2] floatValue] : 0.0;
	CGFloat a = ([components count] > 3) ? [[components objectAtIndex:3] floatValue] : 0.0;
	UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
	return color;
}

+ (UIColor*)colorWithNumber:(unsigned int)num
{
	int r = (num >> 16) & 0xFF;
	int g = (num >> 8) & 0xFF;
	int b = (num >> 0) & 0xFF;
	return [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
}

+ (UIColor*)makeGray:(float)lightness
{
	return [UIColor colorWithRed:lightness green:lightness blue:lightness alpha:1.0];
}

+ (VLUIColorInfoListCommon*)ColorsCommon
{
	static VLUIColorInfoListCommon *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListCommon new];
	return _result;
}
+ (VLUIColorInfoListRed*)ColorsRed
{
	static VLUIColorInfoListRed *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListRed new];
	return _result;
}
+ (VLUIColorInfoListPink*)ColorsPink
{
	static VLUIColorInfoListPink *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListPink new];
	return _result;
}
+ (VLUIColorInfoListOrange*)ColorsOrange
{
	static VLUIColorInfoListOrange *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListOrange new];
	return _result;
}
+ (VLUIColorInfoListYellow*)ColorsYellow
{
	static VLUIColorInfoListYellow *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListYellow new];
	return _result;
}
+ (VLUIColorInfoListPurple*)ColorsPurple
{
	static VLUIColorInfoListPurple *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListPurple new];
	return _result;
}
+ (VLUIColorInfoListGreen*)ColorsGreen
{
	static VLUIColorInfoListGreen *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListGreen new];
	return _result;
}
+ (VLUIColorInfoListBlue*)ColorsBlue
{
	static VLUIColorInfoListBlue *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListBlue new];
	return _result;
}
+ (VLUIColorInfoListBrown*)ColorsBrown
{
	static VLUIColorInfoListBrown *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListBrown new];
	return _result;
}
+ (VLUIColorInfoListWhite*)ColorsWhite
{
	static VLUIColorInfoListWhite *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListWhite new];
	return _result;
}
+ (VLUIColorInfoListGray*)ColorsGray
{
	static VLUIColorInfoListGray *_result = nil;
	if(!_result)
		_result = [VLUIColorInfoListGray new];
	return _result;
}

+ (NSArray*)commonColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		
		CIM(@"White", 0xFFFFFF);
		CIM(@"Silver", 0xC0C0C0);
		CIM(@"Gray", 0x808080);
		CIM(@"Black", 0x000000);
		CIM(@"Red", 0xFF0000);
		CIM(@"Maroon", 0x800000);
		CIM(@"Yellow", 0xFFFF00);
		CIM(@"Olive", 0x808000);
		CIM(@"Lime", 0x00FF00);
		CIM(@"Green", 0x008000);
		CIM(@"Aqua", 0x00FFFF);
		CIM(@"Teal", 0x008080);
		CIM(@"Blue", 0x0000FF);
		CIM(@"Navy", 0x000080);
		CIM(@"Fuchsia", 0xFF00FF);
		CIM(@"Purple", 0x800080);
	}
	return arr;
}

+ (NSArray*)redColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"IndianRed", 0xCD5C5C);
		CIM(@"LightCoral", 0xF08080);
		CIM(@"Salmon", 0xFA8072);
		CIM(@"DarkSalmon", 0xE9967A);
		CIM(@"LightSalmon", 0xFFA07A);
		CIM(@"Crimson", 0xDC143C);
		CIM(@"Red", 0xFF0000);
		CIM(@"FireBrick", 0xB22222);
		CIM(@"DarkRed", 0x8B0000);
	}
	return arr;
}

+ (NSArray*)pinkColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"Pink", 0xFFC0CB);
		CIM(@"LightPink", 0xFFB6C1);
		CIM(@"HotPink", 0xFF69B4);
		CIM(@"DeepPink", 0xFF1493);
		CIM(@"MediumVioletRed", 0xC71585);
		CIM(@"PaleVioletRed", 0xDB7093);
	}
	return arr;
}

+ (NSArray*)orangeColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"LightSalmon", 0xFFA07A);
		CIM(@"Coral", 0xFF7F50);
		CIM(@"Tomato", 0xFF6347);
		CIM(@"OrangeRed", 0xFF4500);
		CIM(@"DarkOrange", 0xFF8C00);
		CIM(@"Orange", 0xFFA500);
	}
	return arr;
}

+ (NSArray*)yellowColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"Gold", 0xFFD700);
		CIM(@"Yellow", 0xFFFF00);
		CIM(@"LightYellow", 0xFFFFE0);
		CIM(@"LemonChiffon", 0xFFFACD);
		CIM(@"LightGoldenrodYellow", 0xFAFAD2);
		CIM(@"PapayaWhip", 0xFFEFD5);
		CIM(@"Moccasin", 0xFFE4B5);
		CIM(@"PeachPuff", 0xFFDAB9);
		CIM(@"PaleGoldenrod", 0xEEE8AA);
		CIM(@"Khaki", 0xF0E68C);
		CIM(@"DarkKhaki", 0xBDB76B);
	}
	return arr;
}

+ (NSArray*)purpleColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"Lavender", 0xE6E6FA);
		CIM(@"Thistle", 0xD8BFD8);
		CIM(@"Plum", 0xDDA0DD);
		CIM(@"Violet", 0xEE82EE);
		CIM(@"Orchid", 0xDA70D6);
		CIM(@"Fuchsia", 0xFF00FF);
		CIM(@"Magenta", 0xFF00FF);
		CIM(@"MediumOrchid", 0xBA55D3);
		CIM(@"MediumPurple", 0x9370DB);
		CIM(@"Amethyst", 0x9966CC);
		CIM(@"BlueViolet", 0x8A2BE2);
		CIM(@"DarkViolet", 0x9400D3);
		CIM(@"DarkOrchid", 0x9932CC);
		CIM(@"DarkMagenta", 0x8B008B);
		CIM(@"Purple", 0x800080);
		CIM(@"Indigo", 0x4B0082);
		CIM(@"SlateBlue", 0x6A5ACD);
		CIM(@"DarkSlateBlue", 0x483D8B);
		CIM(@"MediumSlateBlue", 0x7B68EE);
	}
	return arr;
}

+ (NSArray*)greenColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"GreenYellow", 0xADFF2F);
		CIM(@"Chartreuse", 0x7FFF00);
		CIM(@"LawnGreen", 0x7CFC00);
		CIM(@"Lime", 0x00FF00);
		CIM(@"LimeGreen", 0x32CD32);
		CIM(@"PaleGreen", 0x98FB98);
		CIM(@"LightGreen", 0x90EE90);
		CIM(@"MediumSpringGreen", 0x00FA9A);
		CIM(@"SpringGreen", 0x00FF7F);
		CIM(@"MediumSeaGreen", 0x3CB371);
		CIM(@"SeaGreen", 0x2E8B57);
		CIM(@"ForestGreen", 0x228B22);
		CIM(@"Green", 0x008000);
		CIM(@"DarkGreen", 0x006400);
		CIM(@"YellowGreen", 0x9ACD32);
		CIM(@"OliveDrab", 0x6B8E23);
		CIM(@"Olive", 0x808000);
		CIM(@"DarkOliveGreen", 0x556B2F);
		CIM(@"MediumAquamarine", 0x66CDAA);
		CIM(@"DarkSeaGreen", 0x8FBC8F);
		CIM(@"LightSeaGreen", 0x20B2AA);
		CIM(@"DarkCyan", 0x008B8B);
		CIM(@"Teal", 0x008080);
	}
	return arr;
}

+ (NSArray*)blueCyanColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"Aqua", 0x00FFFF);
		CIM(@"Cyan", 0x00FFFF);
		CIM(@"LightCyan", 0xE0FFFF);
		CIM(@"PaleTurquoise", 0xAFEEEE);
		CIM(@"Aquamarine", 0x7FFFD4);
		CIM(@"Turquoise", 0x40E0D0);
		CIM(@"MediumTurquoise", 0x48D1CC);
		CIM(@"DarkTurquoise", 0x00CED1);
		CIM(@"CadetBlue", 0x5F9EA0);
		CIM(@"SteelBlue", 0x4682B4);
		CIM(@"LightSteelBlue", 0xB0C4DE);
		CIM(@"PowderBlue", 0xB0E0E6);
		CIM(@"LightBlue", 0xADD8E6);
		CIM(@"SkyBlue", 0x87CEEB);
		CIM(@"LightSkyBlue", 0x87CEFA);
		CIM(@"DeepSkyBlue", 0x00BFFF);
		CIM(@"DodgerBlue", 0x1E90FF);
		CIM(@"CornflowerBlue", 0x6495ED);
		CIM(@"MediumSlateBlue", 0x7B68EE);
		CIM(@"RoyalBlue", 0x4169E1);
		CIM(@"Blue", 0x0000FF);
		CIM(@"MediumBlue", 0x0000CD);
		CIM(@"DarkBlue", 0x00008B);
		CIM(@"Navy", 0x000080);
		CIM(@"MidnightBlue", 0x191970);
	}
	return arr;
}

+ (NSArray*)brownColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"Cornsilk", 0xFFF8DC);
		CIM(@"BlanchedAlmond", 0xFFEBCD);
		CIM(@"Bisque", 0xFFE4C4);
		CIM(@"NavajoWhite", 0xFFDEAD);
		CIM(@"Wheat", 0xF5DEB3);
		CIM(@"BurlyWood", 0xDEB887);
		CIM(@"Tan", 0xD2B48C);
		CIM(@"RosyBrown", 0xBC8F8F);
		CIM(@"SandyBrown", 0xF4A460);
		CIM(@"Goldenrod", 0xDAA520);
		CIM(@"DarkGoldenrod", 0xB8860B);
		CIM(@"Peru", 0xCD853F);
		CIM(@"Chocolate", 0xD2691E);
		CIM(@"SaddleBrown", 0x8B4513);
		CIM(@"Sienna", 0xA0522D);
		CIM(@"Brown", 0xA52A2A);
		CIM(@"Maroon", 0x800000);
	}
	return arr;
}

+ (NSArray*)whiteColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"White", 0xFFFFFF);
		CIM(@"Snow", 0xFFFAFA);
		CIM(@"Honeydew", 0xF0FFF0);
		CIM(@"MintCream", 0xF5FFFA);
		CIM(@"Azure", 0xF0FFFF);
		CIM(@"AliceBlue", 0xF0F8FF);
		CIM(@"GhostWhite", 0xF8F8FF);
		CIM(@"WhiteSmoke", 0xF5F5F5);
		CIM(@"Seashell", 0xFFF5EE);
		CIM(@"Beige", 0xF5F5DC);
		CIM(@"OldLace", 0xFDF5E6);
		CIM(@"FloralWhite", 0xFFFAF0);
		CIM(@"Ivory", 0xFFFFF0);
		CIM(@"AntiqueWhite", 0xFAEBD7);
		CIM(@"Linen", 0xFAF0E6);
		CIM(@"LavenderBlush", 0xFFF0F5);
		CIM(@"MistyRose", 0xFFE4E1);
	}
	return arr;
}

+ (NSArray*)grayColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		CIM(@"Gainsboro", 0xDCDCDC);
		CIM(@"LightGrey", 0xD3D3D3);
		CIM(@"Silver", 0xC0C0C0);
		CIM(@"DarkGray", 0xA9A9A9);
		CIM(@"Gray", 0x808080);
		CIM(@"DimGray", 0x696969);
		CIM(@"LightSlateGray", 0x778899);
		CIM(@"SlateGray", 0x708090);
		CIM(@"DarkSlateGray", 0x2F4F4F);
		CIM(@"Black", 0x000000);
	}
	return arr;
}

+ (NSArray*)allNamedColors
{
	static NSMutableArray *arr = nil;
	if(!arr)
	{
		arr = [NSMutableArray new];
		[arr addObjectsFromArray:[UIColor commonColors]];
		[arr addObjectsFromArray:[UIColor redColors]];
		[arr addObjectsFromArray:[UIColor pinkColors]];
		[arr addObjectsFromArray:[UIColor orangeColors]];
		[arr addObjectsFromArray:[UIColor yellowColors]];
		[arr addObjectsFromArray:[UIColor purpleColors]];
		[arr addObjectsFromArray:[UIColor greenColors]];
		[arr addObjectsFromArray:[UIColor blueCyanColors]];
		[arr addObjectsFromArray:[UIColor brownColors]];
		[arr addObjectsFromArray:[UIColor whiteColors]];
		[arr addObjectsFromArray:[UIColor grayColors]];
	}
	return arr;
}

- (UIColor*)toRGBA
{
	CGFloat comps[4];
	[self getRGBAComponents:&comps[0]];
	UIColor *res = [UIColor colorWithRed:comps[0] green:comps[1] blue:comps[2] alpha:comps[3]];
	return res;
}

+ (UIColor*)random
{
	return [UIColor colorWithRed:((rand()%256)/255.0) green:((rand()%256)/255.0) blue:((rand()%256)/255.0) alpha:1.0];
}

@end










@implementation UIImage(VL_UIImage_Category)

- (UIImage*)limitSizeAndRotate:(int)maxSideSize
{
	NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
    CGImageRef imgRef = self.CGImage;  
	
	CGSize sizeImageOrig = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGSize sizeImageNew = sizeImageOrig;  
	
    CGAffineTransform transform = CGAffineTransformIdentity;  
    CGRect bounds = CGRectMake(0, 0, sizeImageOrig.width, sizeImageOrig.height);  
    if (sizeImageOrig.width > maxSideSize || sizeImageOrig.height > maxSideSize)
	{  
        CGFloat ratio = sizeImageOrig.width / sizeImageOrig.height;  
        if (ratio > 1)
		{  
            bounds.size.width = maxSideSize;  
            bounds.size.height = bounds.size.width / ratio;  
        }  
        else
		{  
            bounds.size.height = maxSideSize;  
            bounds.size.width = bounds.size.height * ratio;  
        }  
    }
	
	bounds.size.height = round(bounds.size.height);
	if(bounds.size.height < 1)
		bounds.size.height = 1;
	bounds.size.width = round(bounds.size.width);
	if(bounds.size.width < 1)
		bounds.size.width = 1;
	
    CGFloat scaleRatio = bounds.size.width / sizeImageOrig.width;  
    //CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
    CGFloat boundHeight;  
    UIImageOrientation orient = self.imageOrientation;  
    switch(orient)
	{  
			
        case UIImageOrientationUp: //EXIF = 1  
            transform = CGAffineTransformIdentity;  
            break;  
			
        case UIImageOrientationUpMirrored: //EXIF = 2  
            transform = CGAffineTransformMakeTranslation(sizeImageNew.width, 0.0);  
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            break;  
			
        case UIImageOrientationDown: //EXIF = 3  
            transform = CGAffineTransformMakeTranslation(sizeImageNew.width, sizeImageNew.height);  
            transform = CGAffineTransformRotate(transform, M_PI);  
            break;  
			
        case UIImageOrientationDownMirrored: //EXIF = 4  
            transform = CGAffineTransformMakeTranslation(0.0, sizeImageNew.height);  
            transform = CGAffineTransformScale(transform, 1.0, -1.0);  
            break;  
			
        case UIImageOrientationLeftMirrored: //EXIF = 5  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeTranslation(sizeImageNew.height, sizeImageNew.height);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
			
        case UIImageOrientationLeft: //EXIF = 6  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(0.0, sizeImageNew.width);  
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            break;  
			
        case UIImageOrientationRightMirrored: //EXIF = 7  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformTranslate(transform, 0, sizeImageNew.height - sizeImageNew.width);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break; 
			
        case UIImageOrientationRight: //EXIF = 8  
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(sizeImageNew.height, 0.0);  
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            break;  
			
        default:  
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
			
    }  
	
    UIGraphicsBeginImageContext(bounds.size);  
	
    CGContextRef context = UIGraphicsGetCurrentContext();  
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
	{  
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);  
        CGContextTranslateCTM(context, -sizeImageNew.height, 0);  
    }  
    else
	{  
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);  
        CGContextTranslateCTM(context, 0, -sizeImageNew.height);  
    }  
	
    CGContextConcatCTM(context, transform);  
	
    CGContextDrawImage(context, CGRectMake(0, 0, sizeImageNew.width, sizeImageNew.height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext(); 
	[imageCopy retain];
	[arpool drain];
	[imageCopy autorelease];
    return imageCopy;  
}

+ (UIImage *)imageNamed:(NSString *)name scale:(float)scale {
	UIImage *image = [UIImage imageNamed:name];
	if(image) {
		float imageScale = image.scale;
		if(imageScale != scale && imageScale == 1 && scale == 2) {
			image = [[[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation] autorelease];
		}
	}
	return image;
}

@end















@implementation UIFont(VL_UIFont_Category)

- (UIFont*)fontWithChangedSize:(float)ratio
{
	UIFont *result = [UIFont fontWithName:self.fontName size:self.pointSize * ratio];
	return result;
}

@end











