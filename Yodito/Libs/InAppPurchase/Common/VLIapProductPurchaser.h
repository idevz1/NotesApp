
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "../../Common/Classes.h"
#import "../../Logic/Classes.h"
#import "VLIapLogicObject.h"

typedef void (^VLIapProductPurchaser_BlockPurchased)(SKPaymentTransaction *transaction, NSError **error);

/** Purchased product */
@interface VLIapProductPurchaser : VLIapLogicObject <SKPaymentTransactionObserver>
{
@private
	VLIapProductPurchaser_BlockPurchased _purchasedBlock;
	SKMutablePayment *_curPayment;
	BOOL _addedTransactionObserver;
}

- (void)purchaseProduct:(NSString*)productId
			   quantity:(int)quantity
		 purchasedBlock:(VLIapProductPurchaser_BlockPurchased)purchasedBlock
			resultBlock:(void(^)(NSError *error))resultBlock;

@end
