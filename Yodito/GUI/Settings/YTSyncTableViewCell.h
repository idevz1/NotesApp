
#import <Foundation/Foundation.h>
#import "../Ctrls/Classes.h"

@interface YTSyncTableViewCell : VLTableViewCell {
@private
	YTSyncButton *_syncButton;
	BOOL _wasSyncing;
}

@end

