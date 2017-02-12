
#import <Foundation/Foundation.h>

#define kVLHttpRequest_MethodGet @"GET"
#define kVLHttpRequest_MethodPost @"POST"
#define kVLHttpRequest_DefaultTimeout 120.0

#define kVLHttpRequest_HeaderField_ContentType @"Content-Type"
#define kVLHttpRequest_ContentType_JSON @"application/json"

typedef void (^VLHttpRequest_BlockResult)(NSError *error, NSData *dataResponse, BOOL canceled);

@interface VLHttpRequest : NSObject
{
	NSMutableURLRequest *_request;
	NSURLConnection *_connection;
	BOOL _processing;
	NSString *_sUrl;
	VLHttpRequest_BlockResult _resultBlock;
	int _responseStatusCode;
	NSMutableData *_dataResponse;
	NSHTTPURLResponse *_response;
	BOOL _receiveResponseAfterStatusCodeErrorReceived;
}

@property(nonatomic, readonly) NSHTTPURLResponse *response;
@property(nonatomic, readonly) int responseStatusCode;
/** After error status code received - 500 etc, read response anyway */
@property(nonatomic, assign) BOOL receiveResponseAfterStatusCodeErrorReceived;

- (void)startWithUrl:(NSString *)sUrl
			  method:(NSString *)method
			postData:(NSData *)postData
			 timeout:(NSTimeInterval)timeout
		  cachPolicy:(NSURLRequestCachePolicy)cachPolicy
		headerFields:(NSDictionary*)headerFields
		 synchronous:(BOOL)synchronous
		 resultBlock:(VLHttpRequest_BlockResult)resultBlock;

- (void)cancel;
+ (NSString*)responseStringFromData:(NSData*)dataResponse;
- (NSString*)responseAsString;
+ (NSDictionary*)parseGetParameters:(NSString*)sUrlRequest;

@end
