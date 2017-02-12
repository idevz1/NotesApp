
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "../../Logic/Classes.h"
#import "VLIapLogicObject.h"

typedef void (^VLBLock_VLIapTransactionsRestorer_Restored)(SKPaymentTransaction *transaction, NSError **pError);

@interface VLIapTransactionsRestorer : VLIapLogicObject <SKPaymentTransactionObserver>
{
	NSMutableArray *_restoredTransactions; // SKPaymentTransaction
	VLBLock_VLIapTransactionsRestorer_Restored _restoredBlock;
}

@property(nonatomic,readonly) NSArray *restoredTransactions;

+ (VLIapTransactionsRestorer*)shared;

- (void)restoreTransactionsWithSkipRestore:(BOOL)skipRestore
	  withRestoredBlockSync:(VLBLock_VLIapTransactionsRestorer_Restored)restoredBlockSync
				resultBlock:(VLBlockError)resultBlock;

@end
