
#import <Foundation/Foundation.h>
#import "VLActivityView.h"

@interface VLActivityScreen : NSObject
{
	int _activitylevel;
	VLActivityView *_activityView;
	NSMutableArray *_arrTitles;
	NSMutableArray *_arrYOffsets;
}

+ (VLActivityScreen*)shared;

- (void)startActivityWithTitle:(NSString *)title yOffset:(float)yOffset;
- (void)startActivityWithTitle:(NSString *)title;
- (void)startActivity;
- (void)stopActivity;

@end
