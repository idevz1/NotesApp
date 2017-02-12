
#import "VLIapProductPurchaser.h"
#import "VLIapCommon.h"
#import "VLIapStrings.h"

@implementation VLIapProductPurchaser

- (id)init
{
	self = [super init];
	if(self)
	{
		
	}
	return self;
}

- (void)purchaseProduct:(NSString*)productId
			   quantity:(int)quantity
		 purchasedBlock:(VLIapProductPurchaser_BlockPurchased)purchasedBlock
			resultBlock:(void(^)(NSError *error))resultBlock
{
	if(self.processing)
	{
		resultBlock([VLIapCommon errorStillProcessing]);
		return;
	}
	if(_purchasedBlock)
	{
		Block_release(_purchasedBlock);
		_purchasedBlock = nil;
	}
	if(_curPayment)
	{
		[_curPayment release];
		_curPayment = nil;
	}
	if(![SKPaymentQueue canMakePayments])
	{
		resultBlock([VLIapCommon errorStoreUnavailable]);
		return;
	}
	if(kVLIapLogEvents)
		VLLogEvent(([NSString stringWithFormat:@"product id: %@, quantity = %d", productId, quantity]));
	_curPayment = [[SKMutablePayment alloc] init];
	_curPayment.productIdentifier = productId;
	_curPayment.quantity = quantity;
	self.lastError = nil;
	_purchasedBlock = Block_copy(purchasedBlock);
	self.processingState = EVLProcessingStateProcessing;
	if(!_addedTransactionObserver)
	{
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		_addedTransactionObserver = YES;
	}
	[[SKPaymentQueue defaultQueue] addPayment:_curPayment];
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL
	{
		return !self.processing;
	}
	  ignoringTouches:YES completeBlock:^
	{
		[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
		if(_purchasedBlock)
		{
			Block_release(_purchasedBlock);
			_purchasedBlock = nil;
		}
		if(self.processingState == EVLProcessingStateFailed)
		{
			resultBlock(self.lastError);
			return;
		}
		resultBlock(nil);
	}];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	if(!self.processing)
		return;
	SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
	for(SKPaymentTransaction *transaction in transactions)
	{
		if(kVLIapLogEvents)
			VLLogEvent(([NSString stringWithFormat:@"transaction.transactionState - %@",
						 [VLIapCommon transactionStateToString:transaction.transactionState]]));
		//if(transaction.error)
        {
        }
        switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchasing:
				if(kVLIapLogEvents)
					VLLogEvent(([NSString stringWithFormat:@"SKPaymentTransactionStatePurchasing: %@",
								[VLIapCommon transactionToString:transaction]]));
				break;
			case SKPaymentTransactionStatePurchased:
				if(kVLIapLogEvents)
					VLLogEvent(([NSString stringWithFormat:@"SKPaymentTransactionStatePurchased: %@",
								 [VLIapCommon transactionToString:transaction]]));
				NSError *error = nil;
				_purchasedBlock(transaction, &error);
				if(error)
				{
					self.lastError = error;
					self.processingState = EVLProcessingStateFailed;
					return;
				}
				[paymentQueue finishTransaction:transaction];
				self.processingState = EVLProcessingStateSucceed;
				break;
			case SKPaymentTransactionStateFailed:
				VLLogError(([NSString stringWithFormat:@"SKPaymentTransactionStateFailed: %@",
							[VLIapCommon transactionToString:transaction]]));
				[paymentQueue finishTransaction:transaction];
				if(transaction.error)
				{
					VLLogError(([NSString stringWithFormat:@"SKPaymentTransactionStateFailed: %@", transaction.error]));
					NSError *error = transaction.error;
					if(transaction.error.code == SKErrorPaymentCancelled)
					{
						NSString *descr = [NSString stringWithFormat:@"%@. \n%@",
										   [VLIapStrings shared].errorPaymentCancelled,
										   [transaction.error localizedDescription]];
						error = [NSError errorWithDomain:transaction.error.domain code:transaction.error.code
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:descr, NSLocalizedDescriptionKey, nil]];
					}
					self.lastError = error;
				}
				self.processingState = EVLProcessingStateFailed;
				break;
			case SKPaymentTransactionStateRestored:
				if(kVLIapLogEvents)
					VLLogEvent(([NSString stringWithFormat:@"SKPaymentTransactionStateRestored: %@",
								 [VLIapCommon transactionToString:transaction]]));
				[paymentQueue finishTransaction:transaction];
				self.processingState = EVLProcessingStateSucceed;
				break;
			default:
				break;
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
	if(!self.processing)
		return;
	for(SKPaymentTransaction *transaction in transactions)
	{
		if(kVLIapLogEvents)
			VLLogEvent(([NSString stringWithFormat:@"%@",
						 [VLIapCommon transactionToString:transaction]]));
	}
}

- (void)dealloc
{
	if(_addedTransactionObserver)
		[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	if(_purchasedBlock)
		Block_release(_purchasedBlock);
	[_curPayment release];
	[super dealloc];
}

@end


