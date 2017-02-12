
#import "VL_SKObjects_Categories.h"

@implementation SKProduct(VLCategory)

- (NSString *)localizedPriceAsString {
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setLocale:[self priceLocale]];
	NSString *str = [formatter stringFromNumber:[self price]];
	return str;
}

@end



