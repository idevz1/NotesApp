
#import "VL_NSString_Category.h"
#import <CommonCrypto/CommonDigest.h>
#import "VL_NSData_Category.h"
#import "VLCommon.h"

@implementation NSString(VL_NSString_Category)

+ (BOOL)isEmpty:(NSString*)str
{
	return !str || ([str length] == 0);
}

- (BOOL)validateAsEmail
{
	if([NSString isEmpty:self])
		return NO;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:self];
}

- (void)copyMD5toBuffer:(unsigned char*)buf16bytes
{
	const char *cStr = [self UTF8String];
	CC_MD5( cStr, (CC_LONG)strlen(cStr), buf16bytes );
}

- (NSString*)md5
{
	//const char *cStr = [self UTF8String];
	unsigned char result[16];
	[self copyMD5toBuffer:result];
	//CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			]; 
}

- (NSString*)base64encode
{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	NSString *result = [data base64String];
	return result;
}

- (NSString*)base64decode
{
	NSData *data = [NSData dataWithBase64String:self];
	NSString *result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	return result;
}

- (NSString*)truncateToMaxLength:(int)maxLength addingEllipsis:(BOOL)addingEllipsis
{
	if(self.length <= maxLength)
		return [self isKindOfClass:[NSMutableString class]] ? [[self copy] autorelease] : self;
	NSString *result = [NSString stringWithFormat:@"%@...", [self substringToIndex:maxLength]];
	return result;
}

- (CGSize)vlSizeWithFont:(UIFont *)font {
	CGSize result = CGSizeZero;
	if(kIosVersionFloat >= 7.0 && [self respondsToSelector:@selector(sizeWithAttributes:)]) {
		result = [self sizeWithAttributes:@{NSFontAttributeName:font}];
		result.width = ceil(result.width);
		result.height = ceil(result.height);
	} else {
		static NSInvocation *_invocation;
		if(!_invocation) {
			SEL selector = @selector(sizeWithFont:);
			NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
			_invocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
			_invocation.selector = selector;
		}
		_invocation.target = self;
		[_invocation setArgument:&font atIndex:2];
		[_invocation invoke];
		[_invocation getReturnValue:&result];
	}
	return result;
}

- (CGSize)vlSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
	CGSize result = CGSizeZero;
	if(kIosVersionFloat >= 7.0 && [self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
		CGRect rect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
		result = rect.size;
		result.width = ceil(result.width);
		result.height = ceil(result.height);
	} else {
		static NSInvocation *_invocation;
		if(!_invocation) {
			SEL selector = @selector(sizeWithFont:constrainedToSize:lineBreakMode:);
			NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
			_invocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
			_invocation.selector = selector;
		}
		_invocation.target = self;
		[_invocation setArgument:&font atIndex:2];
		[_invocation setArgument:&size atIndex:3];
		[_invocation setArgument:&lineBreakMode atIndex:4];
		[_invocation invoke];
		[_invocation getReturnValue:&result];
	}
	return result;
}

- (void)vlDrawAtPoint:(CGPoint)point withFont:(UIFont *)font color:(UIColor *)color {
	if(kIosVersionFloat >= 7.0 && [self respondsToSelector:@selector(drawAtPoint:withAttributes:)]) {
		[self drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
	} else {
		[color setFill];
		static NSInvocation *_invocation;
		if(!_invocation) {
			SEL selector = @selector(drawAtPoint:withFont:);
			NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
			_invocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
			_invocation.selector = selector;
		}
		_invocation.target = self;
		[_invocation setArgument:&point atIndex:2];
		[_invocation setArgument:&font atIndex:3];
		[_invocation invoke];
	}
}

- (void)vlDrawInRect:(CGRect)rect withFont:(UIFont *)font color:(UIColor *)color {
	if(kIosVersionFloat >= 7.0 && [self respondsToSelector:@selector(drawInRect:withAttributes:)]) {
		[self drawInRect:rect withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
	} else {
		[color setFill];
		static NSInvocation *_invocation;
		if(!_invocation) {
			SEL selector = @selector(drawInRect:withFont:);
			NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
			_invocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
			_invocation.selector = selector;
		}
		_invocation.target = self;
		[_invocation setArgument:&rect atIndex:2];
		[_invocation setArgument:&font atIndex:3];
		[_invocation invoke];
	}
}

- (void)vlDrawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment color:(UIColor *)color {
	if(kIosVersionFloat >= 7.0 && [self respondsToSelector:@selector(drawInRect:withAttributes:)]) {
		NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
		textStyle.lineBreakMode = lineBreakMode;
		textStyle.alignment = alignment;
		[self drawInRect:rect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyle, NSForegroundColorAttributeName:color}];
		[textStyle release];
	} else {
		[color setFill];
		static NSInvocation *_invocation;
		if(!_invocation) {
			SEL selector = @selector(drawInRect:withFont:lineBreakMode:alignment:);
			NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
			_invocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
			_invocation.selector = selector;
		}
		_invocation.target = self;
		[_invocation setArgument:&rect atIndex:2];
		[_invocation setArgument:&font atIndex:3];
		[_invocation setArgument:&lineBreakMode atIndex:4];
		[_invocation setArgument:&alignment atIndex:5];
		[_invocation invoke];
	}
}

@end


