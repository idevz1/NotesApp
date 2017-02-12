
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"

@interface YTSyncManager : YTLogicObject <NSCoding> {
@private
	int64_t _savedDataVersion;
	int _curSyncTicket;
	BOOL _wasSyncedOnceAfterLogin;
	VLDate *_startSyncTimeLocal;
	VLDate *_lastSyncTime;
	VLDate *_lastSyncTimeForUser;
	VLTimer *_timer;
	NSTimeInterval _appActivatedUptime;
	BOOL _triedAutoSyncAfterActivated;
	NSTimeInterval _autoSyncAnyChangesNextStartUptime;
	int _timerEventProcessingCounter;
	BOOL _wasMainViewShown;
	BOOL _autosyncStoppedAfterError;
	NSTimeInterval _lastSyncEndUptime;
}

@property(nonatomic, readonly) BOOL wasSyncedOnceAfterLogin;
@property(nonatomic, assign) VLDate *lastSyncTime;
@property(nonatomic, assign) VLDate *lastSyncTimeForUser;
@property(nonatomic, readonly) int curSyncTicket;

+ (YTSyncManager *)shared;
- (void)startSyncMTWithResultBlockMT:(void (^)(NSError *error))resultBlockMT;
- (BOOL)isSyncTicketValid:(int)ticket;

@end

