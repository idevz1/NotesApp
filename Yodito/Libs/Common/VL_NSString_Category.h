
#import <Foundation/Foundation.h>

@interface NSString(VL_NSString_Category)

+ (BOOL)isEmpty:(NSString*)str;
- (BOOL)validateAsEmail;

- (NSString*)md5;
- (void)copyMD5toBuffer:(unsigned char*)buf16bytes;

- (NSString*)base64encode;
- (NSString*)base64decode;

- (NSString*)truncateToMaxLength:(int)maxLength addingEllipsis:(BOOL)addingEllipsis;

- (CGSize)vlSizeWithFont:(UIFont *)font;
- (CGSize)vlSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (void)vlDrawAtPoint:(CGPoint)point withFont:(UIFont *)font color:(UIColor *)color;
- (void)vlDrawInRect:(CGRect)rect withFont:(UIFont *)font color:(UIColor *)color;
- (void)vlDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment color:(UIColor *)color;

@end