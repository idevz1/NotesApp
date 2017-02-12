
#import "VLHttpWebRequest.h"

@implementation VLHttpWebRequest

@synthesize responseStatusCode = _responseStatusCode;
@synthesize baseRequest = _request;
@synthesize downloadDestinationPath = _downloadDestinationPath;

- (void)initialize
{
    _responseStatusCode = 0;
}

- (void)startWithUrl:(NSString *)sUrl
			  method:(NSString *)method
			postData:(id)postData
			 timeout:(NSTimeInterval)timeout
		  cachPolicy:(NSURLRequestCachePolicy)cachPolicy
		headerFields:(NSDictionary *)headerFields
		 synchronous:(BOOL)synchronous
callHandlersOnlyOnMainThread:(BOOL)callHandlersOnlyOnMainThread
 requestCreatedBlock:(VLHttpWebRequest_BlockRequestCreated)requestCreatedBlock
		 resultBlock:(VLHttpWebRequest_BlockResult)resultBlock
{
	NSURL *url = [NSURL URLWithString:sUrl];
	if(!url)
		url = [NSURL URLWithString:[sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSData *postNSData = ObjectCast(postData, NSData);
	NSDictionary *postValues = ObjectCast(postData, NSDictionary);
	// http://allseeing-i.com/ASIHTTPRequest/How-to-use#using_blocks
	__block ASIHTTPRequest *request = nil;
	__block ASIFormDataRequest *formRequest = nil;
	if(postValues)
	{
		formRequest = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
		request = formRequest;
	}
	else
	{
		request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	}
	[request setRequestMethod:method];
	request.timeOutSeconds = (timeout > 0) ? timeout : kVLHttpWebRequest_DefaultTimeout;
	request.cachePolicy = cachPolicy;
	request.allowCallExternalHandlersNotOnMainThread = !callHandlersOnlyOnMainThread;
	
	if(![NSString isEmpty:_downloadDestinationPath]) {
		request.downloadDestinationPath = _downloadDestinationPath;
	}
	
	[_request release];
	_request = [request retain];
	
	if(requestCreatedBlock)
		requestCreatedBlock();
	
	if(postValues)
	{
		for(id key in postValues.allKeys)
		{
			NSString *sKey = ObjectCast(key, NSString);
			if(!sKey)
				continue;
			id val = [postValues objectForKey:sKey];
			NSData *data = ObjectCast(val, NSData);
			if(data) {
				[formRequest setData:data forKey:sKey];
				continue;
			}
			NSURL *url = ObjectCast(val, NSURL);
			if(url && [url isFileURL]) {
				[formRequest setFile:[url path] forKey:sKey];
				continue;
			}
			NSString *sVal = ObjectCast(val, NSString);
			if(!sVal)
				continue;
			[formRequest addPostValue:sVal forKey:sKey];
		}
	}
	else if(postNSData)
	{
		[request appendPostData:postNSData];
	}
	
	if(headerFields)
	{
		for(id key in [headerFields allKeys])
			[request addRequestHeader:[headerFields valueForKey:key] value:key];
	}

	_canceled = NO;
	
	[request setHeadersReceivedBlock:^(NSDictionary *responseHeaders)
	{
		
	}];
	[request setCompletionBlock:^
	{
		 _responseStatusCode = request.responseStatusCode;
		NSData *dataResponse = nil;
		if([NSString isEmpty:_downloadDestinationPath]) {
			dataResponse = request.responseData;
			if(!dataResponse)
				dataResponse = [NSData data];
		}
		resultBlock(nil, dataResponse);
		[_request release];
		_request = nil;
	}];
	[request setFailedBlock:^
	{
		 _responseStatusCode = request.responseStatusCode;
		NSError *error = request.error;
		if(!error)
			error = [NSError makeWithText:@""];
		if(_canceled)
			error = [NSError makeCancel];
		resultBlock(error, nil);
		[_request release];
		_request = nil;
	}];
	
	if(synchronous)
		[request startSynchronous];
	else
		[request startAsynchronous];
}

- (void)startWithUrl:(NSString *)sUrl
			  method:(NSString *)method
			postData:(id)postData
			 timeout:(NSTimeInterval)timeout
		  cachPolicy:(NSURLRequestCachePolicy)cachPolicy
		headerFields:(NSDictionary *)headerFields
		 synchronous:(BOOL)synchronous
 requestCreatedBlock:(VLHttpWebRequest_BlockRequestCreated)requestCreatedBlock
		 resultBlock:(VLHttpWebRequest_BlockResult)resultBlock
{
	[self startWithUrl:sUrl
				method:method
			  postData:postData
			   timeout:timeout
			cachPolicy:cachPolicy
		  headerFields:headerFields
		   synchronous:synchronous
callHandlersOnlyOnMainThread:YES
   requestCreatedBlock:requestCreatedBlock
		   resultBlock:^(NSError *error, NSData *dataResponse)
	{
		resultBlock(error, dataResponse);
	}];
}

- (void)startWithUrl:(NSString *)sUrl
			  method:(NSString *)method
			postData:(id)postData
			 timeout:(NSTimeInterval)timeout
		  cachPolicy:(NSURLRequestCachePolicy)cachPolicy
		headerFields:(NSDictionary *)headerFields
		 synchronous:(BOOL)synchronous
		 resultBlock:(VLHttpWebRequest_BlockResult)resultBlock {
	
	[self startWithUrl:sUrl
				method:method
			  postData:postData
			   timeout:timeout
			cachPolicy:cachPolicy
		  headerFields:headerFields
		   synchronous:synchronous
   requestCreatedBlock:nil
		   resultBlock:^(NSError *error, NSData *dataResponse)
	{
		resultBlock(error, dataResponse);
	}];
}

- (void)cancel {
	if(!_request)
		return;
	_canceled = YES;
	[_request cancel];
}

+ (NSString*)responseStringFromData:(NSData*)dataResponse
{
	if(!dataResponse)
		return @"";
	NSString *sResponse = [[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding];
	if(!sResponse)
		sResponse = [[NSString alloc] initWithData:dataResponse encoding:NSASCIIStringEncoding];
	if(sResponse)
		[sResponse autorelease];
	if(!sResponse)
		return @"";
	return sResponse;
}

+ (NSDictionary*)parseGetParameters:(NSString*)sUrlRequest
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSArray *comp1 = [sUrlRequest componentsSeparatedByString:@"?"];
	NSString *query = [comp1 lastObject];
	NSArray *queryElements = [query componentsSeparatedByString:@"&"];
	for(NSString *element in queryElements)
	{
		NSArray *keyVal = [element componentsSeparatedByString:@"="];
		if(keyVal.count > 0)
		{
			NSString *variableKey = [keyVal objectAtIndex:0];
			NSString *value = (keyVal.count == 2) ? [keyVal lastObject] : @"";
			[result setObject:value forKey:variableKey];
		}
	}
	return result;
}

- (void)dealloc {
	[self cancel];
	[_request release];
	[_downloadDestinationPath release];
	[super dealloc];
}

@end
