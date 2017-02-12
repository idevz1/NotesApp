
#import "VLHttpRequest.h"

@interface VLHttpRequest()

- (void)releaseConnection;
- (void)releaseBlocks;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

@end


@implementation VLHttpRequest

@synthesize response = _response;
@synthesize responseStatusCode = _responseStatusCode;
@synthesize receiveResponseAfterStatusCodeErrorReceived = _receiveResponseAfterStatusCodeErrorReceived;

- (id)init
{
	self = [super init];
	if(self)
	{
		_sUrl = [NSString new];
		_dataResponse = [NSMutableData new];
	}
	return self;
}

- (void)callResultBlockWithError:(NSError *)error dataResponse:(NSData *)dataResponse canceled:(BOOL)canceled
{
	if(!_resultBlock)
		return;
	_resultBlock(error, dataResponse, canceled);
	[self releaseConnection];
	[self releaseBlocks];
}

- (void)startWithUrl:(NSString *)sUrl
			  method:(NSString *)method
			postData:(NSData *)postData
			 timeout:(NSTimeInterval)timeout
		  cachPolicy:(NSURLRequestCachePolicy)cachPolicy
		headerFields:(NSDictionary*)headerFields
		 synchronous:(BOOL)synchronous
		 resultBlock:(VLHttpRequest_BlockResult)resultBlock
{
	[self cancel];
	[_sUrl release];
	_sUrl = [sUrl copy];
	_request = [NSMutableURLRequest new];
	NSURL *url = [NSURL URLWithString:_sUrl];
	if(!url)
		url = [NSURL URLWithString:[_sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	_request.URL = url;
	_request.cachePolicy = cachPolicy;
	if(timeout > 0)
		[_request setTimeoutInterval:timeout];
	BOOL isPost = [method isEqual:kVLHttpRequest_MethodPost];
	if(isPost)
	{
		[_request setHTTPMethod:kVLHttpRequest_MethodPost];
		if(!postData)
			postData = [NSData data];
		[_request setHTTPBody:postData];
	}
	if(headerFields)
	{
		for(id key in [headerFields allKeys])
			[_request addValue:[headerFields valueForKey:key] forHTTPHeaderField:key];
	}
	_responseStatusCode = 0;
	[_dataResponse setLength:0];
	_resultBlock = Block_copy(resultBlock);
	_processing = YES;
	if(synchronous)
    {
		NSError *error = nil;
		NSURLResponse *response = nil;
		NSData *responseData = [NSURLConnection sendSynchronousRequest:_request
													 returningResponse:&response
																 error:&error];
		if(error)
		{
			[self connection:nil didFailWithError:error];
			return;
		}
		if(response)
			[self connection:nil didReceiveResponse:response];
		if(responseData)
			[self connection:nil didReceiveData:responseData];
		[self connectionDidFinishLoading:nil];
    }
    else
    {
		_connection = [[NSURLConnection connectionWithRequest:_request delegate:self] retain];
		[_connection start];
    }
}

- (void)cancel
{
	if(!_processing)
		return;
	if(_resultBlock)
		[self callResultBlockWithError:nil dataResponse:nil canceled:YES];
	[self releaseConnection];
	[self releaseBlocks];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_dataResponse appendData:data];
}

- (NSError*)errorWithStatusCode:(int)statusCode
{
	NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
																  @"Server returned status code %d",
																  statusCode]
														  forKey:NSLocalizedDescriptionKey];
	NSError *statusError = [NSError errorWithDomain:@"HTTPPropertyStatusCode"
											   code:statusCode
										   userInfo:errorInfo];
	return statusError;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	_processing = NO;
	if(_receiveResponseAfterStatusCodeErrorReceived && _responseStatusCode >= 400)
	{
		NSError *statusError = [self errorWithStatusCode:_responseStatusCode];
		[self callResultBlockWithError:statusError dataResponse:_dataResponse canceled:NO];
	}
	else
	{
		[self callResultBlockWithError:nil dataResponse:_dataResponse canceled:NO];
	}
	[self releaseConnection];
	[self releaseBlocks];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if(connection && connection != _connection)
		return;
	_processing = NO;
	[self callResultBlockWithError:error dataResponse:nil canceled:NO];
	[self releaseConnection];
	[self releaseBlocks];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(connection && connection != _connection)
		return;
    [_dataResponse setLength:0];
    if([response isKindOfClass:[NSHTTPURLResponse class]])
    {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		[_response release];
		_response = [httpResponse retain];
		if ([response respondsToSelector:@selector(statusCode)])
		{
			_responseStatusCode = (int)[httpResponse statusCode];
			if(_responseStatusCode >= 400)
			{
				if(!_receiveResponseAfterStatusCodeErrorReceived)
				{
					if(_connection)
						[_connection cancel];  // stop connecting; no more delegate messages
				
					NSError *statusError = [self errorWithStatusCode:_responseStatusCode];
					[self connection:_connection didFailWithError:statusError];
					return;
				}
			}
		}
    }
}

- (void)releaseBlocks
{
	if(_resultBlock)
	{
		Block_release(_resultBlock);
		_resultBlock = nil;
	}
}

- (void)releaseConnection
{
	if(_request)
	{
		[_request release];
		_request = nil;
	}
	if(_connection)
	{
		[_connection release];
		_connection = nil;
	}
	if(_response)
	{
		[_response release];
		_response = nil;
	}
	_processing = NO;
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

- (NSString*)responseAsString
{
	return [VLHttpRequest responseStringFromData:_dataResponse];
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

- (void)dealloc
{
	[self releaseConnection];
	[self releaseBlocks];
	[_sUrl release];
	[_dataResponse release];
	[super dealloc];
}

@end
