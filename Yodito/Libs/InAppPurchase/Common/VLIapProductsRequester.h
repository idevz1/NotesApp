
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "../../Common/Classes.h"
#import "../../Logic/Classes.h"
#import "VLIapLogicObject.h"

/** Requests products information */
@interface VLIapProductsRequester : VLIapLogicObject <SKProductsRequestDelegate>
{
@private
	NSMutableSet *_productsIds;
	SKProductsRequest *_request;
	NSMutableArray *_products;
	NSMutableArray *_inavidPruductsIdsResponse;
}

/** Current list of SKProduct */
@property(nonatomic, readonly) NSArray *products;

- (void)requestProducts:(NSSet*)productsIds
			resultBlock:(void(^)(NSDictionary *mapProductById, NSError *error))resultBlock;

@end
