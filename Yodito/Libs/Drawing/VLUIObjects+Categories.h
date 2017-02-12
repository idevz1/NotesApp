
#import <Foundation/Foundation.h>


// http://en.wikipedia.org/wiki/Web_colors

@interface VLUIColorArgs : NSObject
{
	UIColor *_color;
}

@property(nonatomic,retain) UIColor *color;

@end


@interface VLUIColorInfo : NSObject
{
	UIColor *_color;
	NSString *_name;
}

@property(nonatomic,readonly) UIColor *color;
@property(nonatomic,readonly) NSString *name;

- (id)initWithNumber:(unsigned int)num name:(NSString*)name;

@end


#define CIM1(colname,num) @property(nonatomic,readonly) VLUIColorInfo *colname

@interface VLUIColorInfoListBase : NSObject
{
}
@end

@interface VLUIColorInfoListCommon : VLUIColorInfoListBase
CIM1(White, 0xFFFFFF);
CIM1(Silver, 0xC0C0C0);
CIM1(Gray, 0x808080);
CIM1(Black, 0x000000);
CIM1(Red, 0xFF0000);
CIM1(Maroon, 0x800000);
CIM1(Yellow, 0xFFFF00);
CIM1(Olive, 0x808000);
CIM1(Lime, 0x00FF00);
CIM1(Green, 0x008000);
CIM1(Aqua, 0x00FFFF);
CIM1(Teal, 0x008080);
CIM1(Blue, 0x0000FF);
CIM1(Navy, 0x000080);
CIM1(Fuchsia, 0xFF00FF);
CIM1(Purple, 0x800080);
@end
@interface VLUIColorInfoListRed : VLUIColorInfoListBase
CIM1(IndianRed, 0xCD5C5C);
CIM1(LightCoral, 0xF08080);
CIM1(Salmon, 0xFA8072);
CIM1(DarkSalmon, 0xE9967A);
CIM1(LightSalmon, 0xFFA07A);
CIM1(Crimson, 0xDC143C);
CIM1(Red, 0xFF0000);
CIM1(FireBrick, 0xB22222);
CIM1(DarkRed, 0x8B0000);
@end
@interface VLUIColorInfoListPink : VLUIColorInfoListBase
CIM1(Pink, 0xFFC0CB);
CIM1(LightPink, 0xFFB6C1);
CIM1(HotPink, 0xFF69B4);
CIM1(DeepPink, 0xFF1493);
CIM1(MediumVioletRed, 0xC71585);
CIM1(PaleVioletRed, 0xDB7093);
@end
@interface VLUIColorInfoListOrange : VLUIColorInfoListBase
CIM1(LightSalmon, 0xFFA07A);
CIM1(Coral, 0xFF7F50);
CIM1(Tomato, 0xFF6347);
CIM1(OrangeRed, 0xFF4500);
CIM1(DarkOrange, 0xFF8C00);
CIM1(Orange, 0xFFA500);
@end
@interface VLUIColorInfoListYellow : VLUIColorInfoListBase
CIM1(Gold, 0xFFD700);
CIM1(Yellow, 0xFFFF00);
CIM1(LightYellow, 0xFFFFE0);
CIM1(LemonChiffon, 0xFFFACD);
CIM1(LightGoldenrodYellow, 0xFAFAD2);
CIM1(PapayaWhip, 0xFFEFD5);
CIM1(Moccasin, 0xFFE4B5);
CIM1(PeachPuff, 0xFFDAB9);
CIM1(PaleGoldenrod, 0xEEE8AA);
CIM1(Khaki, 0xF0E68C);
CIM1(DarkKhaki, 0xBDB76B);
@end
@interface VLUIColorInfoListPurple : VLUIColorInfoListBase
CIM1(Lavender, 0xE6E6FA);
CIM1(Thistle, 0xD8BFD8);
CIM1(Plum, 0xDDA0DD);
CIM1(Violet, 0xEE82EE);
CIM1(Orchid, 0xDA70D6);
CIM1(Fuchsia, 0xFF00FF);
CIM1(Magenta, 0xFF00FF);
CIM1(MediumOrchid, 0xBA55D3);
CIM1(MediumPurple, 0x9370DB);
CIM1(Amethyst, 0x9966CC);
CIM1(BlueViolet, 0x8A2BE2);
CIM1(DarkViolet, 0x9400D3);
CIM1(DarkOrchid, 0x9932CC);
CIM1(DarkMagenta, 0x8B008B);
CIM1(Purple, 0x800080);
CIM1(Indigo, 0x4B0082);
CIM1(SlateBlue, 0x6A5ACD);
CIM1(DarkSlateBlue, 0x483D8B);
CIM1(MediumSlateBlue, 0x7B68EE);
@end
@interface VLUIColorInfoListGreen : VLUIColorInfoListBase
CIM1(GreenYellow, 0xADFF2F);
CIM1(Chartreuse, 0x7FFF00);
CIM1(LawnGreen, 0x7CFC00);
CIM1(Lime, 0x00FF00);
CIM1(LimeGreen, 0x32CD32);
CIM1(PaleGreen, 0x98FB98);
CIM1(LightGreen, 0x90EE90);
CIM1(MediumSpringGreen, 0x00FA9A);
CIM1(SpringGreen, 0x00FF7F);
CIM1(MediumSeaGreen, 0x3CB371);
CIM1(SeaGreen, 0x2E8B57);
CIM1(ForestGreen, 0x228B22);
CIM1(Green, 0x008000);
CIM1(DarkGreen, 0x006400);
CIM1(YellowGreen, 0x9ACD32);
CIM1(OliveDrab, 0x6B8E23);
CIM1(Olive, 0x808000);
CIM1(DarkOliveGreen, 0x556B2F);
CIM1(MediumAquamarine, 0x66CDAA);
CIM1(DarkSeaGreen, 0x8FBC8F);
CIM1(LightSeaGreen, 0x20B2AA);
CIM1(DarkCyan, 0x008B8B);
CIM1(Teal, 0x008080);
@end
@interface VLUIColorInfoListBlue : VLUIColorInfoListBase
CIM1(Aqua, 0x00FFFF);
CIM1(Cyan, 0x00FFFF);
CIM1(LightCyan, 0xE0FFFF);
CIM1(PaleTurquoise, 0xAFEEEE);
CIM1(Aquamarine, 0x7FFFD4);
CIM1(Turquoise, 0x40E0D0);
CIM1(MediumTurquoise, 0x48D1CC);
CIM1(DarkTurquoise, 0x00CED1);
CIM1(CadetBlue, 0x5F9EA0);
CIM1(SteelBlue, 0x4682B4);
CIM1(LightSteelBlue, 0xB0C4DE);
CIM1(PowderBlue, 0xB0E0E6);
CIM1(LightBlue, 0xADD8E6);
CIM1(SkyBlue, 0x87CEEB);
CIM1(LightSkyBlue, 0x87CEFA);
CIM1(DeepSkyBlue, 0x00BFFF);
CIM1(DodgerBlue, 0x1E90FF);
CIM1(CornflowerBlue, 0x6495ED);
CIM1(MediumSlateBlue, 0x7B68EE);
CIM1(RoyalBlue, 0x4169E1);
CIM1(Blue, 0x0000FF);
CIM1(MediumBlue, 0x0000CD);
CIM1(DarkBlue, 0x00008B);
CIM1(Navy, 0x000080);
CIM1(MidnightBlue, 0x191970);
@end
@interface VLUIColorInfoListBrown : VLUIColorInfoListBase
CIM1(Cornsilk, 0xFFF8DC);
CIM1(BlanchedAlmond, 0xFFEBCD);
CIM1(Bisque, 0xFFE4C4);
CIM1(NavajoWhite, 0xFFDEAD);
CIM1(Wheat, 0xF5DEB3);
CIM1(BurlyWood, 0xDEB887);
CIM1(Tan, 0xD2B48C);
CIM1(RosyBrown, 0xBC8F8F);
CIM1(SandyBrown, 0xF4A460);
CIM1(Goldenrod, 0xDAA520);
CIM1(DarkGoldenrod, 0xB8860B);
CIM1(Peru, 0xCD853F);
CIM1(Chocolate, 0xD2691E);
CIM1(SaddleBrown, 0x8B4513);
CIM1(Sienna, 0xA0522D);
CIM1(Brown, 0xA52A2A);
CIM1(Maroon, 0x800000);
@end
@interface VLUIColorInfoListWhite : VLUIColorInfoListBase
CIM1(White, 0xFFFFFF);
CIM1(Snow, 0xFFFAFA);
CIM1(Honeydew, 0xF0FFF0);
CIM1(MintCream, 0xF5FFFA);
CIM1(Azure, 0xF0FFFF);
CIM1(AliceBlue, 0xF0F8FF);
CIM1(GhostWhite, 0xF8F8FF);
CIM1(WhiteSmoke, 0xF5F5F5);
CIM1(Seashell, 0xFFF5EE);
CIM1(Beige, 0xF5F5DC);
CIM1(OldLace, 0xFDF5E6);
CIM1(FloralWhite, 0xFFFAF0);
CIM1(Ivory, 0xFFFFF0);
CIM1(AntiqueWhite, 0xFAEBD7);
CIM1(Linen, 0xFAF0E6);
CIM1(LavenderBlush, 0xFFF0F5);
CIM1(MistyRose, 0xFFE4E1);
@end
@interface VLUIColorInfoListGray : VLUIColorInfoListBase
CIM1(Gainsboro, 0xDCDCDC);
CIM1(LightGrey, 0xD3D3D3);
CIM1(Silver, 0xC0C0C0);
CIM1(DarkGray, 0xA9A9A9);
CIM1(Gray, 0x808080);
CIM1(DimGray, 0x696969);
CIM1(LightSlateGray, 0x778899);
CIM1(SlateGray, 0x708090);
CIM1(DarkSlateGray, 0x2F4F4F);
CIM1(Black, 0x000000);
@end


@interface UIColor(VL_UIColor_Category)

- (void)getRGBAComponents:(CGFloat*)pcomponents;
- (NSString*)toString;
+ (UIColor*)fromString:(NSString*)str;

+ (UIColor*)colorWithNumber:(unsigned int)num;
+ (UIColor*)makeGray:(float)lightness;

+ (VLUIColorInfoListCommon*)ColorsCommon;
+ (VLUIColorInfoListRed*)ColorsRed;
+ (VLUIColorInfoListPink*)ColorsPink;
+ (VLUIColorInfoListOrange*)ColorsOrange;
+ (VLUIColorInfoListYellow*)ColorsYellow;
+ (VLUIColorInfoListPurple*)ColorsPurple;
+ (VLUIColorInfoListGreen*)ColorsGreen;
+ (VLUIColorInfoListBlue*)ColorsBlue;
+ (VLUIColorInfoListBrown*)ColorsBrown;
+ (VLUIColorInfoListWhite*)ColorsWhite;
+ (VLUIColorInfoListGray*)ColorsGray;

+ (NSArray*)commonColors;
+ (NSArray*)redColors;
+ (NSArray*)pinkColors;
+ (NSArray*)orangeColors;
+ (NSArray*)yellowColors;
+ (NSArray*)purpleColors;
+ (NSArray*)greenColors;
+ (NSArray*)blueCyanColors;
+ (NSArray*)brownColors;
+ (NSArray*)whiteColors;
+ (NSArray*)grayColors;

+ (NSArray*)allNamedColors;
- (UIColor*)toRGBA;
+ (UIColor*)random;

@end







@interface UIImage(VL_UIImage_Category)

- (UIImage*)limitSizeAndRotate:(int)maxSideSize;
+ (UIImage *)imageNamed:(NSString *)name scale:(float)scale;

@end





@interface UIFont(VL_UIFont_Category)

- (UIFont*)fontWithChangedSize:(float)ratio;

@end




