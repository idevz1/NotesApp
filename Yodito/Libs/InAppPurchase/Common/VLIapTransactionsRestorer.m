
#import "VLIapTransactionsRestorer.h"
#import "VLIapCommon.h"

@implementation VLIapTransactionsRestorer

@synthesize restoredTransactions = _restoredTransactions;

+ (VLIapTransactionsRestorer*)shared
{
	static VLIapTransactionsRestorer *_shared = nil;
	if (!_shared)
		_shared = [[VLIapTransactionsRestorer alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_restoredTransactions = [NSMutableArray new];
	}
	return self;
}

- (void)restoreTransactionsWithSkipRestore:(BOOL)skipRestore
	  withRestoredBlockSync:(VLBLock_VLIapTransactionsRestorer_Restored)restoredBlockSync
				resultBlock:(VLBlockError)resultBlock;
{
	if(skipRestore)
	{
		resultBlock(nil);
		return;
	}
	if(self.processing)
	{
		resultBlock([VLIapCommon errorStillProcessing]);
		return;
	}
	if(_restoredBlock)
	{
		Block_release(_restoredBlock);
		_restoredBlock = nil;
	}
	if(![SKPaymentQueue canMakePayments])
	{
		resultBlock([VLIapCommon errorStoreUnavailable]);
		return;
	}
	if(kVLIapLogEvents)
		NSLog(@"VLIapTransactionsRestorer: restoreTransactionsWithResultBlock");
	[_restoredTransactions removeAllObjects];
	self.lastError = nil;
	_restoredBlock = Block_copy(restoredBlockSync);
	self.processingState = EVLProcessingStateProcessing;
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL
	{
		return !self.processing;
	}
	ignoringTouches:YES completeBlock:^
	{
		[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
		if(_restoredBlock)
		{
			Block_release(_restoredBlock);
			_restoredBlock = nil;
		}
		if(self.processingState == EVLProcessingStateFailed)
		{
			resultBlock(self.lastError);
			return;
		}
		resultBlock(nil);
	}];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	if(!self.processing)
		return;
	self.processingState = EVLProcessingStateSucceed;
	if(kVLIapLogEvents)
		NSLog(@"VLIapTransactionsRestorer: paymentQueueRestoreCompletedTransactionsFinished %@", @"");
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	if(!self.processing)
		return;
	if(kVLIapLogEvents || kVLLogErrors)
		NSLog(@"VLIapTransactionsRestorer: restoreCompletedTransactionsFailedWithError: %@", [error localizedDescription]);
	self.lastError = error;
	self.processingState = EVLProcessingStateFailed;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	if(!self.processing)
		return;
	SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
	for(SKPaymentTransaction *transaction in transactions)
	{
		if(transaction.error)
        {
			if(kVLLogErrors)
				NSLog(@"ERROR: VLIapTransactionsRestorer: updatedTransactions: %@", [transaction.error localizedDescription]);
        }
        switch (transaction.transactionState)
		{
			case SKPaymentTransactionStateFailed:
				if(kVLIapLogEvents || kVLLogErrors)
					NSLog(@"VLIapTransactionsRestorer: updatedTransactions: SKPaymentTransactionStateFailed: %@", [VLIapCommon transactionToString:transaction]);
				//[paymentQueue finishTransaction:transaction];
				break;
			case SKPaymentTransactionStatePurchasing:
				if(kVLIapLogEvents)
					NSLog(@"VLIapTransactionsRestorer: updatedTransactions: SKPaymentTransactionStatePurchasing: %@", [VLIapCommon transactionToString:transaction]);
				break;
			//case SKPaymentTransactionStatePurchased:
			//	if(kLogIapEvents)
			//	{
			//		NSLog(@"VLIapTransactionsRestorer: updatedTransactions: SKPaymentTransactionStatePurchased: %@", [VLIapCommon transactionToString:transaction]);
			//		//NSLog(@"Receipt - %@", transaction.transactionReceipt ? [transaction.transactionReceipt base64String] : @"");
			//	}
			//	//[paymentQueue finishTransaction:transaction];
			//	break;
			case SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:
				if(kVLIapLogEvents)
				{
					if(transaction.transactionState == SKPaymentTransactionStatePurchased)
						NSLog(@"VLIapTransactionsRestorer: updatedTransactions: SKPaymentTransactionStatePurchased: %@", [VLIapCommon transactionToString:transaction]);
					else if(transaction.transactionState == SKPaymentTransactionStateRestored)
						NSLog(@"VLIapTransactionsRestorer: updatedTransactions: SKPaymentTransactionStateRestored: %@", [VLIapCommon transactionToString:transaction]);
				}
				[_restoredTransactions addObject:transaction];
				NSError *error = nil;
				_restoredBlock(transaction, &error);
				if(error)
				{
					self.lastError = error;
					self.processingState = EVLProcessingStateFailed;
					return;
				}
				[paymentQueue finishTransaction:transaction];
				break;
			default:
				break;
		}
	}
}

- (void)dealloc
{
	if(_restoredBlock)
		Block_release(_restoredBlock);
	[_restoredTransactions release];
	[super dealloc];
}

@end


