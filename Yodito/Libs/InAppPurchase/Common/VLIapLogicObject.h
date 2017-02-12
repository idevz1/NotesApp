
#import <Foundation/Foundation.h>
#import "../../Logic/Classes.h"

@interface VLIapLogicObject : VLLogicObject {
@private
	NSError *_lastError;
}

@property(nonatomic, assign) NSError *lastError;

@end
