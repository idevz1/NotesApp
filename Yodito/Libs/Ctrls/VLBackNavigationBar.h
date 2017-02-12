
#import <Foundation/Foundation.h>

@interface VLBackNavigationBar : UINavigationBar <UINavigationBarDelegate>
{
@private
	UINavigationItem *_navItem1;
	UINavigationItem *_navItem2;
	id _target;
	SEL _action;
}

@property(nonatomic, assign) NSString *title;

- (id)initWithTarget:(id)target action:(SEL)action;

@end
