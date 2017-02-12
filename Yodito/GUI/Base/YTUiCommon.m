
#import "YTUiCommon.h"

@implementation YTUiCommon

+ (NSString *)extractFirstNoteTextLine:(NSString *)noteText {
	NSString *firstLine = @"";
	int firstWordMaxChars = kYTFirstNoteTextLineMaxChars;
	static NSCharacterSet *_chars;
	if(!_chars) {
		//_chars = [[NSCharacterSet characterSetWithCharactersInString:@" \n`~!@#$%^&*()_+{}:\"|<>?\t\r,./[];'\\-="] retain];
		_chars = [[NSCharacterSet characterSetWithCharactersInString:@"\n"] retain];
	}
	BOOL wordStarted = NO;
	int wordStartedAtindex = -1;
	BOOL wordEnded = NO;
	int wordEndedAtIndex = -1;
	unichar chDelimiter = 0;
	for(int i = 0; i < noteText.length; i++) {
		if(i > firstWordMaxChars)
			break;
		unichar ch = [noteText characterAtIndex:i];
		if([_chars characterIsMember:ch]) {
			if(wordStarted) {
				wordEndedAtIndex = i;
				wordEnded = YES;
				chDelimiter = ch;
				break;
			}
		} else {
			if(!wordStarted) {
				wordStartedAtindex = i;
				wordStarted = YES;
			}
		}
	}
	if(wordStarted && wordEnded && wordStartedAtindex == 0) {
		firstLine = [noteText substringToIndex:wordEndedAtIndex];
		int indexFrom = wordEndedAtIndex;
		if(chDelimiter == ' ' || chDelimiter == '\n' || chDelimiter == '\t')
			indexFrom++;
	}
	return firstLine;
}

@end

