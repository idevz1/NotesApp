
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"

@interface YTNoteHtmlParser : YTLogicObject <NSXMLParserDelegate> {
@private
	NSMutableString *_resultString;
	NSMutableDictionary *_cacheHtmlToText;
	NSMutableDictionary *_cacheNotesTitles;
	NSMutableDictionary *_cacheIsNoteTextHtml;
	VLTimer *_timerClearCache;
}

+ (YTNoteHtmlParser *)shared;

- (NSString *)correctHtmlText:(NSString *)sourceText;
- (NSString *)plainTextFromHtml:(NSString *)htmlText;
- (NSString *)correctNoteTitle:(NSString *)noteTitle;
- (BOOL)isNoteTextHtml:(NSString *)noteText;
- (NSString *)urlEncode:(NSString *)str;
- (NSString *)urlDecode:(NSString *)str;

- (NSString *)correctHtmlWithOwnResources:(NSString *)noteString;

- (NSString *)removeOwnResourceWithHash:(NSString *)sResHash noteString:(NSString *)noteString;
- (NSString *)addOwnResource:(YTResourceInfo *)resource noteString:(NSString *)noteString;

@end
