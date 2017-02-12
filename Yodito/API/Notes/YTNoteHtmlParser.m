
#import "YTNoteHtmlParser.h"
#import "NSString+HTML.h"
#import "GTMNSString+HTML.h"
#import "../Resources/Classes.h"

static YTNoteHtmlParser *_shared;

@implementation YTNoteHtmlParser

+ (YTNoteHtmlParser *)shared {
	if(!_shared)
		_shared = [YTNoteHtmlParser new];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_cacheHtmlToText = [NSMutableDictionary new];
		_cacheNotesTitles = [NSMutableDictionary new];
		_cacheIsNoteTextHtml = [NSMutableDictionary new];
		[[VLAppDelegateBase sharedAppDelegateBase].ntfrDidReceiveMemoryWarning addObserver:self selector:@selector(onReceiveMemoryWarning:)];
		[[VLAppDelegateBase sharedAppDelegateBase].msgrApplicationDidBecomeActive addObserver:self selector:@selector(onApplicationDidBecomeActive:)];
		
		_timerClearCache = [[VLTimer alloc] init];
		_timerClearCache.interval = 5.0;
		[_timerClearCache setObserver:self selector:@selector(onTimerClearCache:)];
		[_timerClearCache start];
	}
	return self;
}

- (NSString *)correctHtmlText:(NSString *)sourceText {
	
	NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
	
	if(!sourceText)
		sourceText = @"";
	sourceText = [[YTNoteHtmlParser shared] urlDecode:sourceText];
	if(!sourceText)
		sourceText = @"";
	NSMutableString *resultText = [NSMutableString stringWithCapacity:sourceText.length * 1.1];
	[resultText appendString:sourceText];
	BOOL inBracket = NO;
	BOOL inQuote = NO;
	int len = (int)resultText.length;
	for(int i = 0; i < len; i++) {
		unichar ch = [resultText characterAtIndex:i];
		if(ch == '<') {
			inBracket = YES;
			inQuote = NO;
		}
		else if(ch == '>') {
			inBracket = NO;
			inQuote = NO;
		}
		else if(ch == '\"')
			inQuote = !inQuote;
		if(ch == '+' && inBracket && !inQuote) {
			[resultText replaceCharactersInRange:NSMakeRange(i, 1) withString:@" "];
		}
	}
	[resultText replaceOccurrencesOfString:@"+" withString:@" " options:0 range:NSMakeRange(0, resultText.length)];
	//[self plainTextFromHtml:resultText];
	
	//[resultText replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, resultText.length)];
	//[resultText replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, resultText.length)];
	resultText = [NSMutableString stringWithString:[resultText gtm_stringByUnescapingFromHTML]];
	
	[resultText retain];
	[arpool drain];
	[resultText autorelease];
	
	return resultText;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
}
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {
}
- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName {
}
- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {
}
- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {
}
- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value {
}
- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID
	  systemID:(NSString *)systemID {
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
}
- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
}
- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s {
	[_resultString appendString:s];
}
- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
}
- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data {
}
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
}
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
}
//- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID {
//	return nil;
//}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
}
- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
}

- (void)convertEntiesInString:(NSString *)s {
	NSString *xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
	//NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
	NSXMLParser *xmlParse = [[[NSXMLParser alloc] initWithData:data] autorelease];
	[xmlParse setDelegate:self];
	[xmlParse parse];
}

- (NSString *)plainTextFromHtml:(NSString *)htmlText {
	/*htmlText = [htmlText stringByReplacingOccurrencesOfString:@"+" withString:@" "];
	[_resultString release];
	_resultString = [NSMutableString stringWithCapacity:htmlText.length * 1.1];
	[self convertEntiesInString:htmlText];
	return _resultString;*/
	NSString *result = [_cacheHtmlToText objectForKey:htmlText];
	if(result)
		return result;
	NSString *htmlText1 = [[YTNoteHtmlParser shared] urlDecode:htmlText];
	if(!htmlText1)
		htmlText1 = @"";
	NSString *htmlText2 = [self correctHtmlText:htmlText1];
	result = [htmlText2 stringByConvertingHTMLToPlainText];
	[_cacheHtmlToText setObject:result forKey:htmlText];
	return result;
}

- (NSString *)correctNoteTitle:(NSString *)noteTitle {
	NSString *result = [_cacheHtmlToText objectForKey:noteTitle];
	if(result)
		return result;
	//result = [self urlDecode:noteTitle];
	result = noteTitle;
	if(!result)
		result = @"";
	//result = [result stringByReplacingOccurrencesOfString:@"+" withString:@" "];
	if(noteTitle)
		[_cacheNotesTitles setObject:result forKey:noteTitle];
	return result;
}

- (BOOL)isNoteTextHtml:(NSString *)noteText {
	NSNumber *num = [_cacheIsNoteTextHtml objectForKey:noteText];
	if(num)
		return num.boolValue;
	BOOL isHtml = NO;
	if([noteText rangeOfString:@"<p>" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	else if([noteText rangeOfString:@"%3Cp%3E" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	else if([noteText rangeOfString:@"<body" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	else if([noteText rangeOfString:@"%3Cbody" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	else if([noteText rangeOfString:@"<img" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	else if([noteText rangeOfString:@"%3Cimg" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	else if([noteText rangeOfString:@"ydt-id" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	else if([noteText rangeOfString:@"<br>" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	else if([noteText rangeOfString:@"<div>" options:NSCaseInsensitiveSearch].length)
		isHtml = YES;
	[_cacheIsNoteTextHtml setObject:[NSNumber numberWithBool:isHtml] forKey:noteText];
	return isHtml;
}

- (NSString *)urlEncode:(NSString *)str {
	if(!str)
		str = @"";
	NSMutableString *resMut = [[NSMutableString alloc] initWithCapacity:str.length * 1.1];
	[resMut appendString:str];
	[resMut replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, resMut.length)];
	NSString *res = [resMut stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if(!res)
		res = resMut;
	[resMut release];
	return res;
}

- (NSString *)urlDecode:(NSString *)str {
	if(!str)
		str = @"";
	NSMutableString *resMut = [[NSMutableString alloc] initWithCapacity:str.length * 1.1];
	NSString *strEscaped = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[resMut appendString:strEscaped ? strEscaped : str];
	[resMut replaceOccurrencesOfString:@"+" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, resMut.length)];
	NSString *res = [[resMut retain] autorelease];
	[resMut release];
	return res;
}

// Replace substring
- (NSString*)replaceInText:(NSString*)text substring:(NSString*)substring with:(NSString*)with {
	NSRange range = [text rangeOfString:substring options:NSCaseInsensitiveSearch];
	if(range.length) {
		text = [text stringByReplacingOccurrencesOfString:substring withString:with options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.length)];
		return [self replaceInText:text substring:substring with:with];
	}
	return text;
}
// Replace substring with regular expression pattern
- (NSString*)replaceInText:(NSString*)text substringWithRegex:(NSString*)sRegex withTemplate:(NSString*)template {
	NSRegularExpression *regex = [[[NSRegularExpression alloc] initWithPattern:sRegex
																	   options:NSRegularExpressionCaseInsensitive
																		 error:nil] autorelease];
	if(!regex)
		return text;
	text = [regex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:template];
	return text;
}
- (NSString *)correctHtmlWithOwnResources:(NSString *)noteString {
	NSString *noteStringOriginal = noteString; noteStringOriginal = noteStringOriginal; // debug
	
	//noteString = [noteString stringByReplacingOccurrencesOfString:@"e0b96f0cb439d13591e41c8c8d379c79" withString:@"---"];
	//noteString = [noteString stringByAppendingString:@"<br><img alt=\"Facebook-dislike-button-blue1\" height=\"300\" src=\"\" ydt-id=\"e0b96f0cb439d13591e41c8c8d379c79\" ydt-class=\"ydt_media_resource\" width=\"500\" />"];
	
	NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
	
	// Replace src="" with src="..."
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(src[\\s\\+]*=[\\s\\+]*['\"]{1})(['\"]{1})"
						withTemplate:@"$1null_image.png$2"];
	// Replace "width=..." with "width='...'"
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"width[\\s\\+]*=[\\s\\+]*(\\d+)"
						withTemplate:@"width=\"$1\""];
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"height[\\s\\+]*=[\\s\\+]*(\\d+)"
						withTemplate:@"height=\"$1\""];
	// Replace {height= ... ydt-class=} with {... ydt-class= height=}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(height[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(ydt-class[\\s\\+]*=[\\s\\+]*['\"]{1}\\w+['\"]{1})"
						withTemplate:@"$2 $3 $1"];
	// Replace {width= ... ydt-class=} with {... ydt-class= width=}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(width[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(ydt-class[\\s\\+]*=[\\s\\+]*['\"]{1}\\w+['\"]{1})"
						withTemplate:@"$2 $3 $1"];
	// Replace {height= ... ydt-id=} with {... ydt-id= height=}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(height[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(ydt-id[\\s\\+]*=[\\s\\+]*['\"]{1}\\w+['\"]{1})"
						withTemplate:@"$2 $3 $1"];
	// Replace {width= ... ydt-id=} with {... ydt-id= width=}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(width[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(ydt-id[\\s\\+]*=[\\s\\+]*['\"]{1}\\w+['\"]{1})"
						withTemplate:@"$2 $3 $1"];
	// Exchange places 'ydt-id' and 'ydt-class'
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(ydt-id[\\s\\+]*=[\\s\\+]*['\"]{1}[\\d\\w]+['\"]{1})[\\s\\+]+(ydt-class[\\s\\+]*=[\\s\\+]*['\"]{1}ydt_media_resource['\"]{1})"
						withTemplate:@"$2 $1"];
	// Replace {height= ... ydt-id=} with {... ydt-id= height=}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(height[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(ydt-id[\\s\\+]*=[\\s\\+]*['\"]{1}\\w+['\"]{1})"
						withTemplate:@"$2 $3 $1"];
	// Replace {width= ... ydt-id=} with {... ydt-id= width=}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(width[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(ydt-id[\\s\\+]*=[\\s\\+]*['\"]{1}\\w+['\"]{1})"
						withTemplate:@"$2 $3 $1"];
	// Replace "width = '...'" with "width='...'"
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"width[\\s\\+]*=[\\s\\+]*['\"]{1}(\\d+)['\"]{1}"
						withTemplate:@"width=\"$1\""];
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"height[\\s\\+]*=[\\s\\+]*['\"]{1}(\\d+)['\"]{1}"
						withTemplate:@"height=\"$1\""];
	// Replace {height= ... width=} with {width= ... height=}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(height[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(width[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})"
						withTemplate:@"$3 $1 $2"];
	// Replace {width= ... height=} with {width= height= ...}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(width[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(height[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})"
						withTemplate:@"$1 $3 $2"];
	// Replace {src= ... width= height=} with {src= width= height= ...}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(src[\\s\\+]*=[\\s\\+]*['\"]{1}[^'\"<>]*['\"]{1})([^<>]*)(width[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(height[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})"
						withTemplate:@"$1 $3 $5 $2 $4"];
	// Replace {width= height= ... src=} with {src= width= height= ...}
	noteString = [self replaceInText:noteString
				  substringWithRegex:@"(width[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(height[\\s\\+]*=[\\s\\+]*['\"]{1}\\d+['\"]{1})([^<>]*)(src[\\s\\+]*=[\\s\\+]*['\"]{1}[^'\"<>]*['\"]{1})"
						withTemplate:@"$5 $1 $2 $3 $4"];
	
	[noteString retain];
	[arpool drain];
	[noteString autorelease];
	
	return noteString;
}

- (NSString *)removeOwnResourceWithHash:(NSString *)sResHash noteString:(NSString *)noteString {
	NSRange range = [noteString rangeOfString:sResHash];
	if(!range.length)
		return noteString;
	int pos1 = (int)range.location;
	int pos2 = (int)NSMaxRange(range) - 1;
	BOOL inQuotes = YES;
	for(int i = pos1; i >= 0; i--) {
		pos1 = i;
		unichar ch = [noteString characterAtIndex:i];
		if(ch == '\"')
			inQuotes = !inQuotes;
		if(ch == '<') {
			if(!inQuotes)
				break;
		}
	}
	inQuotes = YES;
	for(int i = pos2; i < noteString.length; i++) {
		pos2 = i;
		unichar ch = [noteString characterAtIndex:i];
		if(ch == '\"')
			inQuotes = !inQuotes;
		if(ch == '>') {
			if(!inQuotes)
				break;
		}
	}
	noteString = [noteString stringByReplacingCharactersInRange:NSMakeRange(pos1, pos2 - pos1 + 1) withString:@""];
	return noteString;
}

- (NSString *)addOwnResource:(YTResourceInfo *)resource noteString:(NSString *)noteString {
	NSString *sResHash = resource.attachmenthash;
	NSString *sExt = resource.attachmentTypeName;
	if([resource isThumbnail])
		return noteString;
	if(![resource isImage])
		return noteString;
	CGSize szImage = CGSizeZero;
	NSString *filePath = [[YTResourcesStorage shared] filePathToDownloadedResourceWithHash:sResHash];
	if(![NSString isEmpty:filePath]) {
		szImage = [YTImageUtilities getImageSizeWithFilePath:filePath imageOrientation:nil fileExt:sExt];
	}
	NSString *sToAdd = [NSString stringWithFormat:
						@"<br><br><img src=\"null_image.png\" ydt-class=\"ydt_media_resource\" ydt-id=\"%@\"><br><br>",
						sResHash];
	if(szImage.width > 0 && szImage.height > 0) {
		sToAdd = [NSString stringWithFormat:
				  @"<br><br><img src=\"null_image.png\" ydt-class=\"ydt_media_resource\" ydt-id=\"%@\" width=\"%d\" height=\"%d\"><br><br>",
				  sResHash, (int)ceil(szImage.width), (int)ceil(szImage.height)];
	}
	noteString = [noteString stringByAppendingString:sToAdd];
	return noteString;
}

- (void)clearCache {
	[_cacheHtmlToText removeAllObjects];
	[_cacheNotesTitles removeAllObjects];
	[_cacheIsNoteTextHtml removeAllObjects];
}

- (void)onReceiveMemoryWarning:(id)sender {
	[self clearCache];
}

- (void)onApplicationDidBecomeActive:(id)sender {
	[self clearCache];
}

- (void)onTimerClearCache:(id)sender {
	[self clearCache];
}

- (void)dealloc {
	[_timerClearCache release];
	[_resultString release];
	[_cacheHtmlToText release];
	[_cacheNotesTitles release];
	[_cacheIsNoteTextHtml release];
	[super dealloc];
}

@end

