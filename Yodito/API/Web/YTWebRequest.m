
#import "YTWebRequest.h"
#import "../YTCommon.h"
#import "../Base/Classes.h"
#import "../Notes/Classes.h"
#import "YTServerErrorsManager.h"

@interface YTWebRequest_ThreadArgs : NSObject {
@private
	NSError *_error;
	NSString *_sResponse;
	VLHttpWebRequest *_request;
	YTWebRequest_ResultBlock _resultBlock;
}

@property(nonatomic, readonly) NSError *error;
@property(nonatomic, readonly) NSString *sResponse;
@property(nonatomic, readonly) VLHttpWebRequest *request;
@property(nonatomic, readonly) YTWebRequest_ResultBlock resultBlock;

@end


@implementation YTWebRequest_ThreadArgs

@synthesize error = _error;
@synthesize sResponse = _sResponse;
@synthesize request = _request;
@synthesize resultBlock = _resultBlock;

- (id)initWithError:(NSError *)error sResponse:(NSString *)sResponse
			request:(VLHttpWebRequest *)request resultBlock:(YTWebRequest_ResultBlock)resultBlock {
	self = [super init];
	if(self) {
		_error = [error retain];
		_sResponse = [sResponse retain];
		_request = [request retain];
		_resultBlock = Block_copy(resultBlock);
	}
	return self;
}

- (void)dealloc {
	[_error release];
	[_sResponse release];
	[_request release];
	Block_release(_resultBlock);
	[super dealloc];
}

@end

// - (void)responseFinishedWithError:(NSError *)error dataResponse:(NSData *)dataResponse
// request:(VLHttpWebRequest *)request resultBlock:(YTWebRequest_ResultBlock)resultBlock {



@implementation YTWebRequest

@synthesize responseAsString = _responseAsString;
@synthesize dontLogPostData = _dontLogPostData;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

+ (NSError *)errorNotLoggedIn {
	return [NSError makeWithText:@"Not logged in"];
}

+ (NSError *)errorWrongResponse {
	return [NSError makeWithText:@"Incorrect response from server"];
}
 
- (NSError *)errorWrongResponse:(NSError *)error
            request:(VLHttpWebRequest *)request {
    int errorCode = request ? request.responseStatusCode : 0;

    NSError *standardError = [self checkIfStandardError:errorCode];
    
    if(standardError)
        return standardError;
    else
        return [NSError makeWithText:[NSString stringWithFormat:NSLocalizedString(@"An unknown error happened.\nError code %d.", nil), errorCode]];
    
}

- (NSError *)errorWrongResponseWithDetails:(NSString *)details
                                    error:(NSError *)error
                                  request:(VLHttpWebRequest *)request {
    int errorCode = request.responseStatusCode;
    
    NSError *standardError = [self checkIfStandardError:errorCode];
    
    if(standardError)
        return standardError;
    else
        return [NSError makeWithText:[NSString stringWithFormat:NSLocalizedString(@"An unknown error happened.\nError code %d.\nDetails:\n%@", nil), errorCode, details]];
}

- (NSError *)checkIfStandardError:(int)errorCode {
    if(errorCode == 403 || errorCode == 401) {
        return [NSError makeWithText:[NSString stringWithFormat:NSLocalizedString(@"The server returned permission error %d. Please try to logout and login again.", nil), errorCode]];
    } else if(errorCode == 502) {
        return [NSError makeWithText:[NSString stringWithFormat:NSLocalizedString(@"The sever seems to be down with error code %d.\nPlease try again later.", nil), errorCode]];
    } else {
        return nil;
    }
}

+ (NSError *)errorNoInternet {
	//return [NSError makeWithText:NSLocalizedString(@"The internet connection appears to be offline.", nil)];
	return [NSError makeWithText:NSLocalizedString(@"Synchronization failure. This may be due to a network problem or service maintenance.", nil)];
}

- (NSError *)checkForError:(NSDictionary *)response {
	return nil;
}

- (NSError *)checkForErrorInTextResponse:(NSString *)sResponse {
	// <h4>User Error.</h4>Authenticate result is empty.
	NSRegularExpression *regEx = [[[NSRegularExpression alloc]
								   initWithPattern:
							@"<h[\\d]+>(.+er.*)</h[\\d]+>(.+)"
									options:NSRegularExpressionCaseInsensitive
										error:nil] autorelease];
	NSTextCheckingResult *res = [regEx firstMatchInString:sResponse options:0 range:NSMakeRange(0, sResponse.length)];
	if(res) {
		NSString *sErrType = [sResponse substringWithRange:[res rangeAtIndex:1]];
		NSString *sErrMsg = [sResponse substringWithRange:[res rangeAtIndex:2]];
		NSError *err = [NSError makeWithText:[NSString stringWithFormat:@"%@\n%@", sErrType, sErrMsg]];
		return err;
	}
	
	return nil;
}

- (NSDictionary*)jsonResponseFromData:(NSString*)sJson
                               pError:(NSError **)pError
                              request:(VLHttpWebRequest*)request {
	NSString *sToLog = (sJson.length < kYTMaxCharsInLogItem) ? sJson : [NSString stringWithFormat:@"%@...", [sJson substringToIndex:kYTMaxCharsInLogItem]];
	VLLogEvent(sToLog);
	id valJson = [sJson JSONValue];
	NSDictionary *dict = ObjectCast(valJson, NSDictionary);
	if(!dict) {
		NSArray *array = ObjectCast(valJson, NSArray);
		if(array)
			dict = [NSDictionary dictionaryWithObject:array forKey:@""];
	}
	if(!dict) {
		if(pError)
			*pError = [self errorWrongResponseWithDetails:sJson error:*pError request:request];
		return nil;
	}
	if(pError)
		*pError = [self checkForError:dict];
	return dict;
}

- (void)postWithUrl:(NSString*)sUrl
			 values:(NSArray *)values
			  files:(NSArray *)files
			timeout:(NSTimeInterval)timeout
		resultBlock:(YTWebRequest_ResultBlock)resultBlock {
	
	if(![VLDeviceManager isInternetAvailable]) {
		resultBlock(nil, [[self class] errorNoInternet]);
		return;
	}
	
	_refCallerThread = [NSThread currentThread];
	[_sRequestUrl release];
	_sRequestUrl = [sUrl copy];
	if(!files)
		files = [NSArray array];
	
	NSMutableDictionary *valuesToPost = [NSMutableDictionary dictionary];
	NSMutableDictionary *valuesToPostToLog = [NSMutableDictionary dictionary];
	if(values) {
		for(int i = 0; i < values.count; i++) {
			NSString *sKey = [NSString stringWithFormat:@"arg%d", i];
			id val = [values objectAtIndex:i];
			NSData *dataVal = ObjectCast(val, NSData);
			if(dataVal) {
				[valuesToPost setValue:dataVal forKey:sKey];
				[valuesToPostToLog setObject:[NSString stringWithFormat:@"{data %d bytes}", (int)dataVal.length] forKey:sKey];
				continue;
			}
			NSURL *url = ObjectCast(val, NSURL);
			if(url) {
				sKey = [NSString stringWithFormat:@"file_%d[]", i];
				[valuesToPost setValue:url forKey:sKey];
				[valuesToPostToLog setObject:url forKey:sKey];
				continue;
			}
			NSString *sVal = nil;
			NSDictionary *dictVal = ObjectCast(val, NSDictionary);
			if(dictVal) {
				sVal = [dictVal JSONRepresentation];
			}
			if(!sVal)
				sVal = [values stringValueAtIndex:i defaultVal:@""];
			[valuesToPost setValue:sVal forKey:sKey];
			int maxChars = kYTMaxCharsInLogItem;
			if(_dontLogPostData)
				maxChars = 0;
			[valuesToPostToLog setObject:((sVal.length < maxChars) ? sVal : [NSString stringWithFormat:@"%@...", [sVal substringToIndex:maxChars]]) forKey:sKey];
		}
	}
	
	VLLogEvent(([NSString stringWithFormat:@"url = %@; post = %@", [sUrl yoditoCutServerUrl], valuesToPostToLog]));
	
	VLHttpWebRequest *request = [[[VLHttpWebRequest alloc] init] autorelease];
	[_request release];
	_request = [request retain];
	[[VLAppDelegateBase sharedAppDelegateBase] startAnimateNetworkActivityIndicator];
	
	[request startWithUrl:sUrl
				   method:kVLHttpWebRequest_MethodPost
				 postData:valuesToPost
				  timeout:timeout
			   cachPolicy:NSURLRequestReloadIgnoringCacheData
			 headerFields:nil
			  synchronous:NO
callHandlersOnlyOnMainThread:NO
	  requestCreatedBlock:^{
		  if(files.count) {
			  ASIFormDataRequest *formRequest = ObjectCast(_request.baseRequest, ASIFormDataRequest);
			  for(int i = 0; i < files.count; i++) {
				  YTWebRequestFileInfo *fileInfo = [files objectAtIndex:i];
				  [formRequest setFile:fileInfo.filePath
						  withFileName:fileInfo.fileName
						andContentType:fileInfo.contentType
								forKey:fileInfo.key];
			  }
		  }
		}
		resultBlock:^(NSError *error, NSData *dataResponse)
	{
		if(error) {
			NSString *sError = [error localizedDescription];
			if([sError isEqual:@"A connection failure occurred"])
				error = [NSError errorWithDomain:error.domain code:error.code
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Synchronization failure. This may be due to a network problem or service maintenance.", nil), NSLocalizedDescriptionKey, nil]];
		}
		NSString *sResponse = @"";
		if(dataResponse) {
			sResponse = [[[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding] autorelease];
			if(!sResponse)
				sResponse = [[[NSString alloc] initWithData:dataResponse encoding:NSASCIIStringEncoding] autorelease];
			if(!sResponse)
				sResponse = @"";
		}
		
		if([NSThread currentThread] == _refCallerThread) {
			[self responseFinishedWithError:error sResponse:sResponse request:request resultBlock:resultBlock];
		} else {
			YTWebRequest_ThreadArgs *args = [[[YTWebRequest_ThreadArgs alloc] initWithError:error sResponse:sResponse
								request:request resultBlock:resultBlock] autorelease];
			[self performSelector:@selector(responseFinishedWithArgs:) onThread:_refCallerThread withObject:args waitUntilDone:NO];
		}
	}];
}

- (void)responseFinishedWithArgs:(YTWebRequest_ThreadArgs *)args {
	[self responseFinishedWithError:args.error sResponse:args.sResponse request:args.request resultBlock:args.resultBlock];
}

- (void)responseFinishedWithError:(NSError *)error sResponse:(NSString *)sResponse
						  request:(VLHttpWebRequest *)request resultBlock:(YTWebRequest_ResultBlock)resultBlock {
	
	[[VLAppDelegateBase sharedAppDelegateBase] stopAnimateNetworkActivityIndicator];
	if(error) {
		resultBlock(nil, error);
		[_request release];
		_request = nil;
		return;
	}

	if([NSString isEmpty:sResponse]) {
		resultBlock(nil, [self errorWrongResponse:error request:request]);
		[_request release];
		_request = nil;
		return;
	}
	
	[_responseAsString release];
	_responseAsString = [sResponse retain];
	
	NSDictionary *response = nil;
	
	if(!response)
		response = [self jsonResponseFromData:sResponse pError:&error request:request];
	if(!response && request.responseStatusCode == 200) {
		VLLogEvent(([NSString stringWithFormat:@"Could not parse response: sUrl = %@", [_sRequestUrl yoditoCutServerUrl]]));
		if(!error)
			error = [NSError makeWithText:@"Could not parse date from server."];
		
		int64_t valInt64 = [sResponse longLongValue];
		NSNumber *numInt64 = [NSNumber numberWithLongLong:valInt64];
		NSString *sValInt64 = [numInt64 stringValue];
		if([sValInt64 isEqual:sResponse]) {
			response = [NSDictionary dictionaryWithObject:numInt64 forKey:kYTJsonKeyResultCode];
			error = nil;
		}
		
		if(error) {
			// Error code 200. Details: <h4>Not found exception.</h4><h4>The resource could not be found.</h4>}
			if([sResponse rangeOfString:@"Not found" options:NSCaseInsensitiveSearch].length) {
				response = [NSDictionary dictionary];
				error = nil;
			}
		}
		if(error) {
			if( [sResponse rangeOfString:@"No " options:NSCaseInsensitiveSearch].length
			   && [sResponse rangeOfString:@" exist" options:NSCaseInsensitiveSearch].length ) {
				response = [NSDictionary dictionary];
				error = nil;
			}
		}
		if(error) {
			if([sResponse rangeOfString:@"update CheckList set" options:NSCaseInsensitiveSearch].length) {
				response = [NSDictionary dictionary];
				error = nil;
			}
		}
		if(error) {
			NSString *sResponseTrim = [sResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if([sResponseTrim compare:@"true" options:NSCaseInsensitiveSearch] == 0
			   || [sResponseTrim compare:@"success" options:NSCaseInsensitiveSearch] == 0
			   || [sResponseTrim compare:@"1" options:NSCaseInsensitiveSearch] == 0) {
				response = [NSDictionary dictionary];
				error = nil;
			}
			if([sResponseTrim compare:@"false" options:NSCaseInsensitiveSearch] == 0
			   || [sResponseTrim compare:@"failure" options:NSCaseInsensitiveSearch] == 0
			   || [sResponseTrim compare:@"0" options:NSCaseInsensitiveSearch] == 0) {
				response = [NSDictionary dictionary];
				error = [NSError makeWithText:@"Failure"];
			}
		}
	}
	if(!response) {
		if([self checkForErrorInTextResponse:sResponse])
			error = [self checkForErrorInTextResponse:sResponse];
	}
	if(!error && response) {
		// {"error":"201","type":"user error","message_id":"11","message":"incorrect+username+or+password"}
		if([response objectForKey:@"error"] && [response objectForKey:@"message_id"]) {
			int errorCode = [response intValueForKey:@"error" defaultVal:0];
			int messageId = [response intValueForKey:@"message_id" defaultVal:0];
			NSString *sError = [[YTServerErrorsManager shared] getMessageById:messageId];
			if([NSString isEmpty:sError]) {
				sError = [response stringValueForKey:@"message" defaultVal:@""];
				sError = [[YTNoteHtmlParser shared] urlDecode:sError];
			}
			if(!sError)
				sError = @"";
			error = [NSError makeWithText:sError code:errorCode];
		}
	}
	if(error) {
		resultBlock(response, error);
		[_request release];
		_request = nil;
		return;
	}
	if(!response) {
		error = [self errorWrongResponse:error request:request];
		resultBlock(nil, error);
		[_request release];
		_request = nil;
		return;
	}
	error = [self checkForError:response];
	if(error) {
		resultBlock(response, error);
		[_request release];
		_request = nil;
		return;
	}
	resultBlock(response, nil);
	[_request release];
	_request = nil;
}

- (void)postWithUrl:(NSString*)sUrl
			 values:(NSArray *)values
			  files:(NSArray *)files
		resultBlock:(YTWebRequest_ResultBlock)resultBlock {
	
	[self postWithUrl:sUrl
			   values:values
				files:files
			  timeout:kYTDefaultWebTimeout
		  resultBlock:resultBlock];
}

- (void)postWithUrl:(NSString*)sUrl
			 values:(NSArray *)values
			timeout:(NSTimeInterval)timeout
		resultBlock:(YTWebRequest_ResultBlock)resultBlock {
	
	[self postWithUrl:sUrl
			   values:values
				files:nil
			  timeout:timeout
		  resultBlock:resultBlock];
}

- (void)postWithUrl:(NSString*)sUrl
			 values:(NSArray *)values
		resultBlock:(YTWebRequest_ResultBlock)resultBlock {
	
	[self postWithUrl:sUrl
			   values:values
				files:nil
			  timeout:kYTDefaultWebTimeout
		  resultBlock:resultBlock];
}

+ (NSString *)escapeJsonText:(NSString *)sSource {
	
	/*{
		NSString *sResult = [sSource stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		return sResult;
	}*/
	
	/*
	 \"
	 \\
	 \/
	 \b
	 \f
	 \n
	 \r
	 \t
	 
	 0 (null, NUL, \0, ^@), originally intended to be an ignored character, but now used by many programming languages to mark the end of a string.
	 7 (bell, BEL, \a, ^G), which may cause the device receiving it to emit a warning of some kind (usually audible).
	 8 (backspace, BS, \b, ^H), used either to erase the last character printed or to overprint it.
	 9 (horizontal tab, HT, \t, ^I), moves the printing position some spaces to the right.
	 10 (line feed, LF, \n, ^J), used as the end of line marker in most UNIX systems and variants.
	 12 (form feed, FF, \f, ^L), to cause a printer to eject paper to the top of the next page, or a video terminal to clear the screen.
	 13 (carriage return, CR, \r, ^M), used as the end of line marker in Mac OS, OS-9, FLEX (and variants). A carriage return/line feed pair is used by CP/M-80 and its derivatives including DOS and Windows, and by Application Layer protocols such as HTTP.
	 
	 */
	static NSMutableArray *_specialChars;
	static NSMutableArray *_specialCharsReplace;
	static NSMutableCharacterSet *_specialCharsSet;
	if(!_specialCharsSet) {
		_specialChars = [[NSMutableArray alloc] init];
		_specialCharsReplace = [[NSMutableArray alloc] init];
		_specialCharsSet = [[NSMutableCharacterSet alloc] init];
		NSMutableString *sChars = [NSMutableString string];
		[sChars appendFormat:@"%@", @"\""];
		[sChars appendFormat:@"%@", @"\\"];
		[sChars appendFormat:@"%@", @"/"];
		[sChars appendFormat:@"%C", (unichar)8];
		[sChars appendFormat:@"%C", (unichar)12];
		[sChars appendFormat:@"%C", (unichar)10];
		[sChars appendFormat:@"%C", (unichar)13];
		[sChars appendFormat:@"%C", (unichar)9];
		[_specialCharsReplace addObject:@"\\\""];
		[_specialCharsReplace addObject:@"\\\\"];
		[_specialCharsReplace addObject:@"\\/"];
		[_specialCharsReplace addObject:@"\\b"];
		[_specialCharsReplace addObject:@"\\f"];
		[_specialCharsReplace addObject:@"\\n"];
		[_specialCharsReplace addObject:@"\\r"];
		[_specialCharsReplace addObject:@"\\t"];
		for(int i = 0; i < sChars.length; i++) {
			NSString *sChar = [sChars substringWithRange:NSMakeRange(i, 1)];
			[_specialChars addObject:sChar];
			[_specialCharsSet addCharactersInString:sChar];
		}
	}
	//if(![sSource rangeOfCharacterFromSet:_specialCharsSet].length)
	//	return sSource;
	NSMutableString *sResult = [NSMutableString stringWithCapacity:MAX(sSource.length * 1.25, 1)];
	[sResult appendString:sSource ? sSource : @""];
	for(int i = 0; i < sResult.length; i++) {
		unichar ch = [sResult characterAtIndex:i];
		if([_specialCharsSet characterIsMember:ch]) {
			for(int k = 0; k < _specialChars.count; k++) {
				NSString *sChar = [_specialChars objectAtIndex:k];
				if(ch == [sChar characterAtIndex:0]) {
					NSString *sCharReplace = [_specialCharsReplace objectAtIndex:k];
					[sResult replaceCharactersInRange:NSMakeRange(i, 1) withString:sCharReplace];
					i += (sCharReplace.length - 1);
					break;
				}
			}
		}
	}
	//NSString *sResult1 = [sResult stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return sResult;
}

- (void)dealloc {
	[_sRequestUrl release];
	[_request release];
	[super dealloc];
}

@end
