
#import <Foundation/Foundation.h>
#import "YTDbEntitiesManager.h"

@interface YTUsersDbManager : YTDbEntitiesManager {
@private
}

+ (YTUsersDbManager *)shared;
- (YTUserInfo *)getUserInfo;

@end

