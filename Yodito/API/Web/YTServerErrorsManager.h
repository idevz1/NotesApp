
#import <Foundation/Foundation.h>

@interface YTServerErrorsManager : NSObject {
@private
	NSMutableDictionary *_mapMessageInfoById;
}

+ (YTServerErrorsManager *)shared;
- (NSString *)getMessageById:(int)messageId;

@end

