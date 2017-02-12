
#import <Foundation/Foundation.h>
#import "../../Logic/Classes.h"
#import "VLIapLogicObject.h"

#define kVLIapArsVerifyReceiptUrl @"https://buy.itunes.apple.com/verifyReceipt"
#define kVLIapArsVerifyReceiptUrlSandbox @"https://sandbox.itunes.apple.com/verifyReceipt"

@interface VLIapReceiptChecker : VLIapLogicObject
{
@private
	NSString *_sharedSecret;
}

- (void)startCheckReceipt:(NSData*)receiptData
				webApiUrl:(NSString*)webApiUrl
			 sharedSecret:(NSString*)sharedSecret
			  synchronous:(BOOL)synchronous
			  resultBlock:(void(^)(NSError *error))resultBlock;

@end
