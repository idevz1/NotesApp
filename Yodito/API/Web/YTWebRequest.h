
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"
#import "YTWebRequestFileInfo.h"

typedef void (^YTWebRequest_ResultBlock)(NSDictionary *response, NSError *error);
typedef void (^YTWebRequest_RequestCreatedBlock)();

/**
 Simplifies requests to YT server.
 */
@interface YTWebRequest : NSObject
{
@private
	NSString *_sRequestUrl;
	NSThread *_refCallerThread;
	NSString *_responseAsString;
	VLHttpWebRequest *_request;
	BOOL _dontLogPostData;
}

@property(nonatomic, readonly) NSString *responseAsString;
@property(nonatomic, assign) BOOL dontLogPostData;

- (void)postWithUrl:(NSString*)sUrl
			 values:(NSArray *)values
			  files:(NSArray *)files
			timeout:(NSTimeInterval)timeout
		resultBlock:(YTWebRequest_ResultBlock)resultBlock;

- (void)postWithUrl:(NSString*)sUrl
			 values:(NSArray *)values
			  files:(NSArray *)files
		resultBlock:(YTWebRequest_ResultBlock)resultBlock;

- (void)postWithUrl:(NSString*)sUrl
			 values:(NSArray *)values
			timeout:(NSTimeInterval)timeout
		resultBlock:(YTWebRequest_ResultBlock)resultBlock;

- (void)postWithUrl:(NSString*)sUrl
			 values:(NSArray *)values
		resultBlock:(YTWebRequest_ResultBlock)resultBlock;

+ (NSError *)errorNoInternet;
+ (NSError *)errorNotLoggedIn;
+ (NSError *)errorWrongResponse;
+ (NSString *)escapeJsonText:(NSString *)sSource;

@end
