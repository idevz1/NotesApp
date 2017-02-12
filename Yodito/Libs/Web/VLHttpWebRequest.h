
#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "../Common/Classes.h"

#define kVLHttpWebRequest_MethodGet @"GET"
#define kVLHttpWebRequest_MethodPost @"POST"
#define kVLHttpWebRequest_DefaultTimeout 120.0

typedef void (^VLHttpWebRequest_BlockResult)(NSError *error, NSData *dataResponse);
typedef void (^VLHttpWebRequest_BlockRequestCreated)();

@interface VLHttpWebRequest : NSObject <VLCancelable>
{
@private
	ASIHTTPRequest *_request;
	int _responseStatusCode;
	BOOL _canceled;
	NSString *_downloadDestinationPath;
}

- (void)startWithUrl:(NSString *)sUrl
			  method:(NSString *)method
			postData:(id)postData // NSData, NSDictionary
			 timeout:(NSTimeInterval)timeout
		  cachPolicy:(NSURLRequestCachePolicy)cachPolicy
		headerFields:(NSDictionary *)headerFields
		 synchronous:(BOOL)synchronous
callHandlersOnlyOnMainThread:(BOOL)callHandlersOnlyOnMainThread
 requestCreatedBlock:(VLHttpWebRequest_BlockRequestCreated)requestCreatedBlock
		 resultBlock:(VLHttpWebRequest_BlockResult)resultBlock;

- (void)startWithUrl:(NSString *)sUrl
			  method:(NSString *)method
			postData:(id)postData // NSData, NSDictionary
			 timeout:(NSTimeInterval)timeout
		  cachPolicy:(NSURLRequestCachePolicy)cachPolicy
		headerFields:(NSDictionary *)headerFields
		 synchronous:(BOOL)synchronous
 requestCreatedBlock:(VLHttpWebRequest_BlockRequestCreated)requestCreatedBlock
		 resultBlock:(VLHttpWebRequest_BlockResult)resultBlock;

- (void)startWithUrl:(NSString *)sUrl
			  method:(NSString *)method
			postData:(id)postData // NSData, NSDictionary
			 timeout:(NSTimeInterval)timeout
		  cachPolicy:(NSURLRequestCachePolicy)cachPolicy
		headerFields:(NSDictionary *)headerFields
		 synchronous:(BOOL)synchronous
		 resultBlock:(VLHttpWebRequest_BlockResult)resultBlock;

+ (NSString*)responseStringFromData:(NSData*)dataResponse;
+ (NSDictionary*)parseGetParameters:(NSString*)sUrlRequest;

@property(nonatomic, readonly) int responseStatusCode;
@property(nonatomic, readonly) ASIHTTPRequest *baseRequest;
@property(nonatomic, retain) NSString *downloadDestinationPath;

- (void)cancel;

@end
