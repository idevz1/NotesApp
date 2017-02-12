
#import <Foundation/Foundation.h>
#import "../Logic/Classes.h"

@interface VLPeriodicalReminderBaseArgs : VLCancelEventArgs {
@private
	VLBlockVoid _resultBlock;
}

@property(nonatomic, copy) VLBlockVoid resultBlock;

@end


@interface VLPeriodicalReminderBase : NSObject {
@private
	int _version;
	NSString *_sId;
	double _minDelay;
	double _askInterval;
	VLTimer *_timer;
	BOOL _remindering;
	VLDelegate *_dlgtRemindering;
}

@property(nonatomic, readonly) VLDelegate *dlgtRemindering;

- (id)initWithId:(NSString *)sId
		minDelay:(double)minDelay
	 askInterval:(double)askInterval
		 version:(int)version;

@end
