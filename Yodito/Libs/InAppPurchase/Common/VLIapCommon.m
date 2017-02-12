
#import "VLIapCommon.h"
#import "VLIapStrings.h"

static BOOL _isSandbox = NO;

@implementation VLIapCommon

+ (void)initializeWithIsSandbox:(BOOL)isSandbox {
	_isSandbox = isSandbox;
}

+ (BOOL)isSandbox {
	return _isSandbox;
}

+ (NSError*)errorStillProcessing
{
	return [NSError makeWithText:[VLIapStrings shared].errorPreviousRequestProcessing];
}

+ (NSError*)errorStoreUnavailable
{
	return [NSError makeWithText:[VLIapStrings shared].errorAppStoreUnavailable];
}

+ (NSError*)errorWebServer
{
	return [NSError makeWithText:[VLIapStrings shared].errorWebServerError];
}

+ (NSError*)errorUndefined
{
	return [NSError makeWithText:[VLIapStrings shared].errorUndefinedError];
}

+ (NSString*)stringFromSKProduct:(SKProduct*)product
{
	NSString *res = [NSString stringWithFormat:@"SKProduct: %@, localizedDescription = %@, localizedTitle = %@, price = %@, priceLocale = %@, productIdentifier = %@",
					 product,
					 product.localizedDescription,
					 product.localizedTitle,
					 product.price,
					 product.priceLocale,
					 product.productIdentifier];
	return res;
}
+ (NSString*)stringFromSKProductsList:(NSArray*)products
{
	NSMutableString *res = [NSMutableString string];
	[res appendString:@"SKProduct list: "];
	for(SKProduct *obj in products)
		[res appendFormat:@"\n%@", [VLIapCommon stringFromSKProduct:obj]];
	return res;
}

+ (NSString*)stringFromSKProductsPrice:(SKProduct*)product
{
	NSNumberFormatter *nf = [[NSNumberFormatter new] autorelease];
	[nf setLocale:product.priceLocale];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSString *sPrice = [nf stringFromNumber:product.price];
	return sPrice;
}

+ (NSString*)transactionToString:(SKPaymentTransaction*)transaction
{
	NSMutableString *res = [[NSMutableString new] autorelease];
	[res appendString:@"[SKPaymentTransaction "];
	[res appendFormat:@"transactionState: %d ", (int)transaction.transactionState];
	[res appendFormat:@"transactionDate: %@ ", transaction.transactionDate.description];
	[res appendFormat:@"transactionIdentifier: %@ ", transaction.transactionIdentifier];
	[res appendFormat:@"transactionReceipt: %@ bytes ", transaction.transactionReceipt ? [[NSNumber numberWithInt:(int)[transaction.transactionReceipt length]] stringValue] : @"nil"];
	//[res appendFormat:@"transactionReceipt: %@", transaction.transactionReceipt ? [transaction.transactionReceipt base64String] : @"nil"];
	[res appendFormat:@"payment: %@ ", [VLIapCommon paymentToString:transaction.payment]];
	if(transaction.error)
	{
		[res appendString:@"{error: "];
		[res appendString:[transaction.error localizedDescription]];
		[res appendString:@"} "];
	}
	if(transaction.originalTransaction)
	{
		[res appendString:@"{originalTransaction: "];
		[res appendString:[VLIapCommon transactionToString:transaction.originalTransaction]];
		[res appendString:@"} "];
	}
	[res appendString:@"]"];
	return res;
}

+ (NSString*)paymentToString:(SKPayment*)payment
{
	NSMutableString *res = [[NSMutableString new] autorelease];
	[res appendString:@"[SKPayment "];
	[res appendFormat:@"productIdentifier: %@ ", payment.productIdentifier];
	[res appendString:@"]"];
	return res;
}

+ (NSString*)transactionStateToString:(SKPaymentTransactionState)transactionState
{
	switch (transactionState)
	{
		case SKPaymentTransactionStatePurchasing:
			return @"Purchasing";
		case SKPaymentTransactionStatePurchased:
			return @"Purchased";
		case SKPaymentTransactionStateFailed:
			return @"Failed";
		case SKPaymentTransactionStateRestored:
			return @"Restored";
		default:
			return @"";
	}
}

@end


