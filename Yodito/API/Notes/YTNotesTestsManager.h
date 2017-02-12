
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"

@interface YTNotesTestsManager : YTLogicObject {
@private
}

+ (YTNotesTestsManager *)shared;

- (void)performTest;

@end

