
#import "YTSyncManager.h"
#import "../Web/Classes.h"
#import "../Notes/Classes.h"
#import "../Storage/Classes.h"
#import "../Resources/Classes.h"
#import "../Settings/Classes.h"
#import "../YTApiMediator.h"
#import "../Misc/Classes.h"
#import "YTSyncChunkManager.h"
#import "YTSyncCommitManager.h"
#import "../Managers/Classes.h"

#define kSavedDataKey @"YTSyncManager"
#define kSavedDataVersion (kYTManagersBaseVersion + 2)

static YTSyncManager *_shared;

@implementation YTSyncManager

@synthesize wasSyncedOnceAfterLogin = _wasSyncedOnceAfterLogin;
@synthesize lastSyncTime = _lastSyncTime;
@synthesize lastSyncTimeForUser = _lastSyncTimeForUser;
@synthesize curSyncTicket = _curSyncTicket;

+ (YTSyncManager *)shared {
	if(!_shared) {
		_shared = [VLObjectFileStorage loadRootObjectWithKey:kSavedDataKey version:kSavedDataVersion];
		if(!_shared)
			_shared = [[[YTSyncManager alloc] init] autorelease];
		[_shared retain];
	}
	return _shared;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
		_shared = self;
		
		_startSyncTimeLocal = [[VLDate date] retain];
		
		if(aDecoder) {
			_wasSyncedOnceAfterLogin = [aDecoder decodeBoolForKey:@"_wasSyncedOnceAfterLogin"];
			_lastSyncTime = [aDecoder decodeObjectForKey:@"_lastSyncTime"];
			_lastSyncTimeForUser = [aDecoder decodeObjectForKey:@"_lastSyncTimeForUser"];
		}
		
		if(!_lastSyncTime)
			_lastSyncTime = [VLDate empty];
		if(!_lastSyncTimeForUser)
			_lastSyncTimeForUser = [VLDate empty];
		
		[_lastSyncTime retain];
		[_lastSyncTimeForUser retain];
		
		[[YTUsersEnManager shared].dlgtUserLoggedOut addObserver:self selector:@selector(onUserLoggedOut:)];
		[[YTUsersEnManager shared].dlgtUserLoggedIn addObserver:self selector:@selector(onUserLoggedIn:)];
		[[YTUsersEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onUsersManagerChanged:)];
		[[VLAppDelegateBase sharedAppDelegateBase].msgrApplicationDidBecomeActive addObserver:self selector:@selector(onAppActivated:)];
		
		_timer = [[VLTimer alloc] init];
		_timer.interval = 1.0;
		[_timer setObserver:self selector:@selector(onTimerEvent:)];
		[_timer start];
		_autoSyncAnyChangesNextStartUptime = DBL_MAX;
		
		[self.msgrVersionChanged addObserver:self selector:@selector(onVersionChanged:)];
		_savedDataVersion = self.version;
	}
	return self;
}

- (id)init {
	return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:_wasSyncedOnceAfterLogin forKey:@"_wasSyncedOnceAfterLogin"];
	[aCoder encodeObject:_lastSyncTime forKey:@"_lastSyncTime"];
	[aCoder encodeObject:_lastSyncTimeForUser forKey:@"_lastSyncTimeForUser"];
}

- (void)onVersionChanged:(id)sender {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(_savedDataVersion != self.version) {
		VLLogEvent(@"Saving");
		NSTimeInterval tm1 = [VLTimer systemUptime];
		[VLObjectFileStorage saveDataWithRootObject:self key:kSavedDataKey version:kSavedDataVersion];
		_savedDataVersion = self.version;
		NSTimeInterval tm2 = [VLTimer systemUptime];
		VLLogEvent(([NSString stringWithFormat:@"%0.4f s", tm2 - tm1]));
	}
}

- (void)setWasSyncedOnceAfterLogin:(BOOL)wasSyncedOnceAfterLogin {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(_wasSyncedOnceAfterLogin != wasSyncedOnceAfterLogin) {
		_wasSyncedOnceAfterLogin = wasSyncedOnceAfterLogin;
		[self modifyVersion];
	}
}

- (void)setLastSyncTime:(VLDate *)lastSyncTime {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(!lastSyncTime)
		lastSyncTime = [VLDate empty];
	if(![_lastSyncTime isEqual:lastSyncTime]) {
		[_lastSyncTime release];
		_lastSyncTime = [lastSyncTime retain];
		[self modifyVersion];
	}
}

- (VLDate *)lastSyncTimeForUser {
	if([VLDate isEmpty:_lastSyncTimeForUser] && ![VLDate isEmpty:_lastSyncTime])
		return _lastSyncTime;
	return _lastSyncTimeForUser;
}

- (void)setLastSyncTimeForUser:(VLDate *)lastSyncTimeForUser {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(!lastSyncTimeForUser)
		lastSyncTimeForUser = [VLDate empty];
	if(![_lastSyncTimeForUser isEqual:lastSyncTimeForUser]) {
		[_lastSyncTimeForUser release];
		_lastSyncTimeForUser = [lastSyncTimeForUser retain];
		[self modifyVersion];
	}
}

- (void)onUserLoggedOut:(id)sender {
	[[YTDatabaseManager shared] checkIsMainThread];
	_curSyncTicket++;
	[self setWasSyncedOnceAfterLogin:NO];
	self.lastSyncTime = [VLDate empty];
	self.lastSyncTimeForUser = [VLDate empty];
	self.processingState = EVLProcessingStateNone;
}

- (void)onUserLoggedIn:(id)sender {
	[[YTDatabaseManager shared] checkIsMainThread];
	_curSyncTicket++;
	if([YTUsersEnManager shared].userJustRegistered)
		[self setWasSyncedOnceAfterLogin:YES]; // Nothing to sync from server
	else
		[self setWasSyncedOnceAfterLogin:NO];
	self.lastSyncTime = [VLDate empty];
	self.lastSyncTimeForUser = [VLDate empty];
	self.processingState = EVLProcessingStateNone;
}

- (void)onUsersManagerChanged:(id)sender {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(![YTUsersEnManager shared].isLoggedIn || [YTUsersEnManager shared].isDemo)
		[self setWasSyncedOnceAfterLogin:NO];
}

- (void)checkWebServerReachableWithResultBlock:(void (^)(BOOL reachable))resultBlock {
	_timerEventProcessingCounter++;
	NSMutableString *sPositive = [NSMutableString string];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString *hostName = kYTUrlWebServerHostName;
		VLLoggerTrace(@"Start checking reachability %@", hostName);
		Reachability *r = [Reachability reachabilityWithHostName:hostName];
		NetworkStatus internetStatus = [r currentReachabilityStatus];
		if(internetStatus != NotReachable)
			[sPositive appendString:@"YES"];
		dispatch_async(dispatch_get_main_queue(), ^{
			_timerEventProcessingCounter--;
			if(sPositive.length > 0) {
				VLLoggerTrace(@"%@ reachable", hostName);
				resultBlock(YES);
			} else {
				VLLoggerTrace(@"%@ not reachable", hostName);
				resultBlock(NO);
			}
		});
	});
}

- (void)startGetSyncStateDTWithResultBlockDT:(void (^)(YTSyncState *syncState, NSError *error))resultBlockDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
					  kYTUrlParamOperation, kYTUrlValueOperationGetSyncState];
	NSMutableArray *postValues = [NSMutableArray array];
	[postValues addObject:[YTUsersEnManager shared].authenticationToken];
	YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
	[request postWithUrl:sUrl
				  values:postValues
			 resultBlock:^(NSDictionary *response, NSError *error)
	{
		if(error) {
			VLLogError(error);
			resultBlockDT(nil, error);
			return;
		}
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			YTSyncState *syncState = [[[YTSyncState alloc] init] autorelease];
			[syncState loadFromData:response urlDecode:YES];
			[self modifyVersion];
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
			{
				resultBlockDT(syncState, nil);
			}];
		}];
	}];
}

- (void)startCheckSyncStatDTeWithResultBlockDT:(void (^)(NSError *error))resultBlockDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	[[YTUsersEnManager shared] checkAndRefreshAuthenticationIfNeededDTWithResultBlockDT:^(NSError *error)
	{
		if(error) {
			VLLogError(error);
			resultBlockDT(error);
			return;
		}
		[self startGetSyncStateDTWithResultBlockDT:^(YTSyncState *syncState, NSError *error) {
			if(error) {
				VLLogError(error);
				resultBlockDT(error);
				return;
			}
			resultBlockDT(nil);
		}];
	}];
}

- (void)internalStartSyncDTWithResultBlockDT:(void (^)(NSError *error))resultBlockDT {
	
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	[[YTUsersEnManager shared] checkAndRefreshAuthenticationIfNeededDTWithResultBlockDT:^(NSError *error)
	{
		if(error) {
			VLLogError(error);
			resultBlockDT(error);
			return;
		}
		[[YTUsersEnManager shared] updateUserInfoDTWithResultBlockDT:^(NSError *error) {
			if(error) {
				VLLogError(error);
				resultBlockDT(error);
				return;
			}
			[self internalStartSyncDTWithResultBlock2DT:^(NSError *error) {
				resultBlockDT(error);
			}];
		}];
	}];
}

- (void)internalStartSyncDTWithResultBlock2DT:(void (^)(NSError *error))resultBlockDT {

	[[YTDatabaseManager shared] checkIsDatabaseThread];
	[self startGetSyncStateDTWithResultBlockDT:^(YTSyncState *syncState, NSError *error)
	{
		if(error) {
			VLLogError(error);
			resultBlockDT(error);
			return;
		}
		
		NSMutableArray *allErrors = [NSMutableArray array];
	
		int curSyncTicket = _curSyncTicket;
		
		[[YTSyncChunkManager shared] startCheckSyncChunkDTWithTicket:curSyncTicket resultBlockDT:^(NSArray *outErrors)
		{
			if(curSyncTicket != _curSyncTicket) {
				resultBlockDT([NSError makeCancel]);
				return;
			}
			[allErrors addObjectsFromArray:outErrors];
			
			[[YTDatabaseManager shared] checkIsDatabaseThread];
			NSMutableArray *managers = [NSMutableArray array];
			[managers addObject:[YTStacksDbManager shared]];
			[managers addObject:[YTNotebooksDbManager shared]];
			[managers addObject:[YTNotesDbManager shared]];
			[managers addObject:[YTResourcesDbManager shared]];
			//[managers addObject:[YTLocationsDbManager shared]];
			//[managers addObject:[YTTagsDbManager shared]];
			[managers addObject:[YTNoteToLocationDbManager shared]];
			[managers addObject:[YTNoteToTagDbManager shared]];
			
			//[[YTStorageManager shared] deleteUnusedEntitiesFromDb];
			
			//[[YTStorageManager shared] updateConsistencyWithAllowModify:YES];
			//[[YTStorageManager shared] updateConsistencyWithAllowModify:NO];
			
			BOOL needUpload = NO;
			for(YTDbEntitiesManager *manr in managers) {
				for(YTEntityBase *ent in [NSArray arrayWithArray:manr.entities]) {
					if(ent.isTemporary)
						continue;
					if(ent.added || ent.modified || ent.deleted) {
						needUpload = YES;
						break;
					}
				}
				if(needUpload)
					break;
			}
			
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^{
				BOOL needDownload = !(![VLDate isEmpty:_lastSyncTime] && ![VLDate isEmpty:syncState.chunkHighTS]
									  && [_lastSyncTime isEqual:syncState.chunkHighTS] && !kYTFullSyncEventIfTimeStampsEqual);
				[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
				{
					if(!needDownload && !needUpload) {
						//self.processingState = EVLProcessingStateNone;
						resultBlockDT(nil);
						return;
					}
					
					[[YTSyncCommitManager shared] startSyncDTWithTicket:curSyncTicket
															 managers:managers
					 syncExceptResourcesDoneBlockDT:^
					{
						[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
						{
							if(kYTUseChunkHighTSAsLastSyncTime)
								self.lastSyncTime = syncState.chunkHighTS;
							else if(kYTUseServerTimeAsLastSyncTime)
								self.lastSyncTime = syncState.currentTime;
							else
								self.lastSyncTime = _startSyncTimeLocal;
							self.lastSyncTimeForUser = [VLDate date];
						}];
					}
					 resultBlockDT:^(NSArray *outErrors)
					{
						// TODO: handle outErrors
						
						if(curSyncTicket != _curSyncTicket) {
							resultBlockDT([NSError makeCancel]);
							return;
						}
						NSError *error = nil;
						if(allErrors.count)
							error = [allErrors objectAtIndex:0];
						//[[YTStorageManager shared] deleteUnusedEntitiesFromDb];
						//[[YTStorageManager shared] updateConsistencyWithAllowModify:NO];
						if(error) {
							//self.processingState = EVLProcessingStateFailed;
							resultBlockDT(error);
							return;
						}
						[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
						{
							self.processingState = EVLProcessingStateSucceed;
							//self.lastSyncTime = syncState.currentTime;
							if([YTUsersEnManager shared].isLoggedIn)
								[self setWasSyncedOnceAfterLogin:YES];
							[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
							{
								resultBlockDT(nil);
							}];
						}];
					}];
				}];
			}];
		}];
	}];
}

- (void)internalStartSyncMTWithResultBlockMT:(void (^)(NSError *error))resultBlockMT {
	[[YTDatabaseManager shared] checkIsMainThread];
	YTUsersEnManager *manrUser = [YTUsersEnManager shared];
	if(!manrUser.isLoggedIn || manrUser.isDemo) {
		resultBlockMT(nil);
		return;
	}
	if(self.processing) {
		resultBlockMT([NSError makeCancel]);
		return;
	}
	_triedAutoSyncAfterActivated = YES;

	_curSyncTicket++;
	int curSyncTicket = _curSyncTicket;
	[_startSyncTimeLocal release];
	_startSyncTimeLocal = [[VLDate date] retain];
	[[VLAppDelegateBase sharedAppDelegateBase] startAnimateNetworkActivityIndicator];
	self.processingState = EVLProcessingStateProcessing;
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		[[YTDatabaseManager shared] cleanDatabase];
		[self internalStartSyncDTWithResultBlockDT:^(NSError *error) {
			[[YTDatabaseManager shared] cleanDatabase];
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
			{
				[[VLAppDelegateBase sharedAppDelegateBase] stopAnimateNetworkActivityIndicator];
				_triedAutoSyncAfterActivated = YES;
				if(self.processing && [self isSyncTicketValid:curSyncTicket])
					self.processingState = EVLProcessingStateNone;
				if(curSyncTicket == _curSyncTicket && manrUser.isLoggedIn && !manrUser.isDemo)
					self.lastSyncTimeForUser = [VLDate date];
				resultBlockMT(error);
			}];
		}];
	}];
}

- (void)startSyncMTWithResultBlockMT:(void (^)(NSError *error))resultBlockMT {
	[self checkWebServerReachableWithResultBlock:^(BOOL reachable) {
		if(reachable) {
			[self internalStartSyncMTWithResultBlockMT:^(NSError *error) {
				resultBlockMT(error);
			}];
		} else {
			resultBlockMT([YTWebRequest errorNoInternet]);
		}
	}];
}

- (void)onAppActivated:(id)sender {
	if(!kYTAutoSyncOnlyAppActivatedFirstTime) {
		_triedAutoSyncAfterActivated = NO;
	}
	_appActivatedUptime = [VLTimer systemUptime];
	_autosyncStoppedAfterError = NO;
}

- (void)onTimerEvent:(id)sender {
	if(![[YTApiMediator shared] isDataInitialized])
		return;
	if(_timerEventProcessingCounter > 0)
		return;
	YTUsersEnManager *manrUser = [YTUsersEnManager shared];
	if(manrUser.isDemo)
		return;
	
	_timerEventProcessingCounter++;
	[[YTDatabaseManager shared] checkHasAnyChangesForSyncWithResultBlock:^(BOOL result, NSString *changesInfo)
	{
		_timerEventProcessingCounter--;
		
		NSTimeInterval uptime = [VLTimer systemUptime];
		BOOL isAnyChanges = result;
		if(isAnyChanges) {
			int idebug=0;
			idebug++;
		}
		BOOL isShowingMainView = [YTApiMediator shared].isShowingMainView;
		if(_wasMainViewShown != isShowingMainView) {
			if(isShowingMainView) {
				if(isAnyChanges) {
					if(_autoSyncAnyChangesNextStartUptime == DBL_MAX)
						_autoSyncAnyChangesNextStartUptime = uptime + kYTAutoSyncWhenDataChangedDelay;
				}
			}
			_wasMainViewShown = isShowingMainView;
		}
		if(isAnyChanges && isShowingMainView && _autoSyncAnyChangesNextStartUptime == DBL_MAX) {
			_autoSyncAnyChangesNextStartUptime = uptime + kYTAutoSyncWhenDataChangedDelay;
		}
		
		BOOL isInternetAvailable = [VLDeviceManager isInternetAvailable];
		BOOL isWiFi = [VLDeviceManager isInternetAndWiFiAvailable];
		
		// Tests:
		//isInternetAvailable = YES;
		//isWiFi = YES;
		
		// Autosync after app activated
		if(!_triedAutoSyncAfterActivated && isShowingMainView && _appActivatedUptime && manrUser.isLoggedIn
		   && isInternetAvailable && !self.processing)
		{
			if(uptime - _appActivatedUptime >= kYTAutoSyncWhenActivatedDelay) {
				VLDate *now = [VLDate date];
				if([now timeIntervalSinceDate:_lastSyncTime] >= kYTAutoSyncWhenActivatedDelay || [now timeIntervalSinceDate:_lastSyncTime] < 0) {
					if(![YTSettingsManager shared].syncOnWiFiOnly || isWiFi) {
						if(!self.processing && isShowingMainView) {
							if(uptime >= _lastSyncEndUptime + kYTAutoSyncMinInterval) {
								_timerEventProcessingCounter++;
								[self checkWebServerReachableWithResultBlock:^(BOOL reachable) {
									_timerEventProcessingCounter--;
									_triedAutoSyncAfterActivated = YES;
									if(reachable) {
										//_triedAutoSyncAfterActivated = YES;
										VLLoggerTrace(@"changesInfo = %@", changesInfo);
										[self internalStartSyncMTWithResultBlockMT:^(NSError *error) {
											_lastSyncEndUptime = [VLTimer systemUptime];
											if(error)
												VLLogError(error);
										}];
									} else {
										_lastSyncEndUptime = [VLTimer systemUptime];
									}
								}];
							}
						}
					}
				}
			}
		}
		
		// Autosync after data changes waiting for a delay
		if(_triedAutoSyncAfterActivated && isShowingMainView && !_autosyncStoppedAfterError) {
			if(!self.processing && isAnyChanges && isInternetAvailable) {
				if(uptime >= _autoSyncAnyChangesNextStartUptime) {
					if(![YTSettingsManager shared].syncOnWiFiOnly || isWiFi) {
						if(uptime >= _lastSyncEndUptime + kYTAutoSyncMinInterval) {
							_timerEventProcessingCounter++;
							[self checkWebServerReachableWithResultBlock:^(BOOL reachable) {
								_timerEventProcessingCounter--;
								if(reachable) {
									_autoSyncAnyChangesNextStartUptime = DBL_MAX;
									VLLoggerTrace(@"changesInfo = %@", changesInfo);
									[self internalStartSyncMTWithResultBlockMT:^(NSError *error) {
										_lastSyncEndUptime = [VLTimer systemUptime];
										if(error) {
											_autosyncStoppedAfterError = YES;
											VLLogError(error);
											if(kYTAutoSyncOnlyAppActivatedFirstTime && !_autosyncStoppedAfterError && [VLDeviceManager isInternetAvailable] && !error.isCancel) {
												[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:[error localizedDescription]];
											}
										}
									}];
								} else {
									_lastSyncEndUptime = [VLTimer systemUptime];
								}
							}];
						}
					}
				}
			}
		}
		if(!isAnyChanges) {
			_autoSyncAnyChangesNextStartUptime = DBL_MAX;
		}
		_wasMainViewShown = isShowingMainView;
	}];
}

- (BOOL)isSyncTicketValid:(int)ticket {
	return (ticket == _curSyncTicket);
}

- (void)dealloc {
	[_startSyncTimeLocal release];
	[_lastSyncTime release];
	[_lastSyncTimeForUser release];
	[_timer release];
	[super dealloc];
}

@end



