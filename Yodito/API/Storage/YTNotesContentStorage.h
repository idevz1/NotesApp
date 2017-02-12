
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"

#define kYTNotesContentStorage_LastAppBuild @"196"

@interface YTNotesContentStorage : VLLogicObject {
@private
	NSString *_dirPath;
}

+ (YTNotesContentStorage *)shared;

@end

