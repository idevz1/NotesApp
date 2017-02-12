
#import <Foundation/Foundation.h>

@interface VLTargetSelectorReference : NSObject
{
	id _target;
	SEL _selector;
}

@property(nonatomic, assign) id target;
@property(nonatomic, assign) SEL selector;

- (id)initWithTarget:(id)target selector:(SEL)selector;

@end
