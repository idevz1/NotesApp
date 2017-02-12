
#import "VLIapProductsRequester.h"
#import "VLIapCommon.h"


@interface SKProduct(VLSortByPrice)

- (NSComparisonResult)compareByPrice:(SKProduct*)other;

@end

@implementation SKProduct(VLSortByPrice)

- (NSComparisonResult)compareByPrice:(SKProduct*)other
{
	return [self.price compare:other.price];
}

@end


@implementation VLIapProductsRequester

@synthesize products = _products;

- (id)init
{
	self = [super init];
	if(self)
	{
		_productsIds = [[NSMutableSet alloc] init];
		_products = [[NSMutableArray alloc] init];
		_inavidPruductsIdsResponse = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)requestProducts:(NSSet*)productsIds resultBlock:(void(^)(NSDictionary *mapProductById, NSError *error))resultBlock
{
	if(self.processing)
	{
		resultBlock(nil, [VLIapCommon errorStillProcessing]);
		return;
	}
	if(![SKPaymentQueue canMakePayments])
	{
		resultBlock(nil, [VLIapCommon errorStoreUnavailable]);
		return;
	}
	if(kVLIapLogEvents)
		VLLogEvent(([NSString stringWithFormat:@"products ids: %@", productsIds]));
	[_productsIds removeAllObjects];
	[_productsIds addObjectsFromArray:[productsIds allObjects]];
	[_products removeAllObjects];
	[_inavidPruductsIdsResponse removeAllObjects];
	_request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productsIds];
	_request.delegate = self;
	self.lastError = nil;
	self.processingState = EVLProcessingStateProcessing;
	[_request start];
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL
	{
		return !self.processing;
	}
	ignoringTouches:YES completeBlock:^
	{
		[_request release];
		_request = nil;
		if(self.processingState == EVLProcessingStateFailed)
		{
			resultBlock(nil, self.lastError);
			return;
		}
		NSMutableDictionary *mapProductById = [NSMutableDictionary dictionary];
		for(SKProduct *prod in _products)
			[mapProductById setObject:prod forKey:prod.productIdentifier];
		resultBlock(mapProductById, nil);
	}];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	if(request == _request)
	{
		[_products addObjectsFromArray:response.products];
		[_inavidPruductsIdsResponse addObjectsFromArray:response.invalidProductIdentifiers];
		if(kVLIapLogEvents)
			VLLogEvent(([NSString stringWithFormat:@"VLIapProductsRequester: request:didReceiveResponse: products = %@, \n invalidProductIdentifiers = %@",
						 [VLIapCommon stringFromSKProductsList:_products], _inavidPruductsIdsResponse]));
		self.processingState = EVLProcessingStateSucceed;
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	if(request == _request)
	{
		VLLogError(([NSString stringWithFormat:@"%@", error]));
		self.lastError = error;
		self.processingState = EVLProcessingStateFailed;
	}
}

- (void)dealloc
{
	[_productsIds release];
	[_products release];
	[_request release];
	[_inavidPruductsIdsResponse release];
	[super dealloc];
}

@end


