
#import "VLIapReceiptChecker.h"
#import "VLIapCommon.h"
#import "../../Web/Classes.h"
#import "VLIapStrings.h"

#define kJsonKeyReceipt @"receipt"
#define kJsonKeyStatus @"status"
#define kJsonKeyDebug @"debug"

#define kCheckCustomWebServerTimeout 30.0

@implementation VLIapReceiptChecker

- (NSString*)checkReceiptUrl
{
	if([VLIapCommon isSandbox])
		return kVLIapArsVerifyReceiptUrlSandbox;
	else
		return kVLIapArsVerifyReceiptUrl;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		_sharedSecret = [@"" retain];
	}
	return self;
}

- (NSError*)errorFromStatusCode:(int)status
{
	NSString* sStatusErr = nil;
	//BOOL isOutDate = NO;
	if(status != 0)
	{
		switch(status)
		{
			case 21000:
				sStatusErr = @"The App Store could not read the JSON object you provided.";
				break;
			case 21002:
				sStatusErr = @"The data in the receipt-data property was malformed.";
				break;
			case 21003:
				sStatusErr = @"The receipt could not be authenticated.";
				break;
			case 21004:
				sStatusErr = @"The shared secret you provided does not match the shared secret on file for your account.";
				break;
			case 21005:
				sStatusErr = @"The receipt server is not currently available.";
				break;
			case 21006:
				sStatusErr = @"This receipt is valid but the subscription has expired.";
				//isOutDate = YES;
				break;
			default:
				sStatusErr = [NSString stringWithFormat:@"The receipt is not valid - status code = %d ", status];
				break;
		}
	}
	if(sStatusErr)
		return [NSError makeWithText:sStatusErr];
	return nil;
}

- (void)startCheckReceipt:(NSString*)sReceipt
		viaWebServerWithWebApiUrl:(NSString*)webApiUrl
			 sharedSecret:(NSString*)sharedSecret
			  synchronous:(BOOL)synchronous
			 skipThisStep:(BOOL)skipThisStep
			  resultBlock:(void(^)(NSError *error, BOOL responseCorrect, int statusCode))resultBlock
{
	if(skipThisStep)
	{
		resultBlock(nil, NO, 0);
		return;
	}
	if(kVLIapLogEvents)
		VLLogEvent(@"start");
	NSString *sUrl = webApiUrl;
	if(![webApiUrl rangeOfString:@".php" options:NSCaseInsensitiveSearch].length)
		sUrl = [NSString stringWithFormat:@"%@/%@", webApiUrl, kVLIapCheckReceiptWebPage];
	NSMutableString *sPostData = [NSMutableString stringWithFormat:@"%@=%@&%@=%@",
						   kVLIapHttpParamSecret, sharedSecret,
						   kVLIapHttpParamReceipt, sReceipt];
	if([VLIapCommon isSandbox])
		[sPostData appendFormat:@"&%@=%@", kVLIapHttpParamDebug, @"true"];
	NSData *postData = [sPostData dataUsingEncoding:NSUTF8StringEncoding];
	VLHttpRequest *request = [[[VLHttpRequest alloc] init] autorelease];
	[request startWithUrl:sUrl
				   method:kVLHttpRequest_MethodPost
				 postData:postData
				  timeout:kVLIapWebBigDataTimeout
			   cachPolicy:NSURLRequestReloadIgnoringLocalCacheData
			 headerFields:nil
			  synchronous:synchronous
			  resultBlock:^(NSError *error, NSData *dataResponse, BOOL canceled)
	{
		if(error)
		{
			VLLogError(error);
			resultBlock(error, NO, 0);
			return;
		}
		NSString *sResponse = [[[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding] autorelease];
		sResponse = [sResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if(kVLIapLogEvents)
			VLLogEvent(sResponse);
		id jsonVal = [sResponse JSONValue];
		NSDictionary *jsonDict = ObjectCast(jsonVal, NSDictionary);
		if(!jsonDict
		   || ![jsonDict objectForKey:kVLIapJsonKeyCode]
		   || ![jsonDict objectForKey:kVLIapJsonKeyReceiptStatus]
		   )
		{
			resultBlock(nil, NO, 0);
			return;
		}
		int code = [jsonDict intValueForKey:kVLIapJsonKeyCode defaultVal:0];
		if(code == kVLIapJsonErrorWrongResponseFromITunesServer)
		{
			resultBlock(nil, NO, 0);
			return;
		}
		int status = [jsonDict intValueForKey:kVLIapJsonKeyReceiptStatus defaultVal:0];
		if(status == kJsonReceiptValidStatusValue)
			status = 0;
		resultBlock(nil, YES, status);
	}];
}

- (void)startCheckReceipt:(NSData*)receiptData
				webApiUrl:(NSString*)webApiUrl
			 sharedSecret:(NSString*)sharedSecret
			  synchronous:(BOOL)synchronous
			  resultBlock:(void(^)(NSError *error))resultBlock
{
	[_sharedSecret release];
	_sharedSecret = [sharedSecret copy];
	NSString *sReceiptData = [receiptData base64String];
	
	[self startCheckReceipt:sReceiptData
			viaWebServerWithWebApiUrl:webApiUrl
			   sharedSecret:sharedSecret
				synchronous:synchronous
			   skipThisStep:[NSString isEmpty:webApiUrl]
				resultBlock:^(NSError *error, BOOL responseCorrect, int statusCode)
	{
		if(responseCorrect)
		{
			NSError *errorFromStatus = [self errorFromStatusCode:statusCode];
			if(errorFromStatus)
			{
				if(kVLIapLogEvents)
					VLLogEvent(@"Got correct response from custom server - receipt is not valid");
				VLLogError(errorFromStatus);
				resultBlock(errorFromStatus);
				return;
			}
			if(kVLIapLogEvents)
				VLLogEvent(@"Got correct response from custom server - receipt is valid");
			resultBlock(nil);
			return;
		}
		else if(![NSString isEmpty:webApiUrl])
		{
			if(kVLIapLogEvents)
				VLLogEvent(@"Got incorrect response from custom server");
		}
		
		NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											   sReceiptData, @"receipt-data",
											   _sharedSecret, @"password",
											   nil];
		NSString *jsonString = [jsonDictionary JSONRepresentation];
		if(kVLIapLogEvents)
			VLLogEvent(([NSString stringWithFormat:@"sent to server: %@", jsonString]));
		NSData *postData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
		NSString *sUrl = [self checkReceiptUrl];
		VLHttpRequest *request = [[[VLHttpRequest alloc] init] autorelease];
		[request startWithUrl:sUrl
					   method:kVLHttpRequest_MethodPost
					 postData:postData
					  timeout:kVLIapWebBigDataTimeout
				   cachPolicy:NSURLRequestReloadIgnoringLocalCacheData
				 headerFields:[NSDictionary dictionaryWithObject:kVLHttpRequest_ContentType_JSON forKey:kVLHttpRequest_HeaderField_ContentType]
				  synchronous:synchronous
				  resultBlock:^(NSError *error, NSData *dataResponse, BOOL canceled)
		 {
			 if(error)
			 {
				 resultBlock(error);
				 return;
			 }
			 NSString *sResponse = [[[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding] autorelease];
			 sResponse = [sResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			 if(kVLIapLogEvents)
				 VLLogEvent(([NSString stringWithFormat:@"returnString: %@", sResponse]));
			 id jsonVal = [sResponse JSONValue];
			 NSDictionary *jsonDict = ObjectCast(jsonVal, NSDictionary);
			 NSNumber *numStatus = ObjectCast([jsonDict objectForKey:kJsonKeyStatus], NSNumber);
			 if(!numStatus)
			 {
				 resultBlock([NSError makeWithText:[VLIapStrings shared].errorCouldNotCheckReceiptInServer]);
				 return;
			 }
			 int status = [numStatus intValue];
			 NSError *errorFromStatus = [self errorFromStatusCode:status];
			 if(errorFromStatus)
			 {
				 VLLogError(errorFromStatus);
				 resultBlock(errorFromStatus);
				 return;
			 }
			 resultBlock(nil);
		 }];
	}];
}

- (void)dealloc
{
	[_sharedSecret release];
	[super dealloc];
}

@end

/*
 kInAppPurchaseSharedSecretVc @"66de9c35f4bb4ad99ec02b13835573ed"
 
 Printing description of jsonDict:
 {
 receipt =     {
 bid = "com.partyplanner.test";
 bvrs = 33;
 "item_id" = 539443682;
 "original_purchase_date" = "2012-06-25 16:31:07 Etc/GMT";
 "original_purchase_date_ms" = 1340641867082;
 "original_purchase_date_pst" = "2012-06-25 09:31:07 America/Los_Angeles";
 "original_transaction_id" = 1000000051761961;
 "product_id" = "partyplanner_3_months";
 "purchase_date" = "2012-06-25 16:31:07 Etc/GMT";
 "purchase_date_ms" = 1340641867082;
 "purchase_date_pst" = "2012-06-25 09:31:07 America/Los_Angeles";
 quantity = 1;
 "transaction_id" = 1000000051761961;
 };
 status = 0;
 } 
*/
