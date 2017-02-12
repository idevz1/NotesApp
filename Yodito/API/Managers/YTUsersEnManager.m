
#import "YTUsersEnManager.h"
#import "../Web/Classes.h"
#import "../YTApiMediator.h"
#import "../Sync/Classes.h"

static YTUsersEnManager *_shared;

@implementation YTUsersEnManager

@dynamic isLoggedIn;
@dynamic isDemo;
@synthesize userInfo = _userInfo;
@dynamic authenticationToken;
@synthesize dlgtUserBeforeLoggedOut = _dlgtUserBeforeLoggedOut;
@synthesize dlgtUserLoggedOut = _dlgtUserLoggedOut;
@synthesize dlgtUserLoggedIn = _dlgtUserLoggedIn;
@synthesize userJustRegistered = _userJustRegistered;

+ (YTUsersEnManager *)shared {
	if(!_shared)
		_shared = [[YTUsersEnManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		_dlgtUserBeforeLoggedOut = [[VLDelegate alloc] init];
		_dlgtUserBeforeLoggedOut.owner = self;
		_dlgtUserLoggedOut = [[VLDelegate alloc] init];
		_dlgtUserLoggedOut.owner = self;
		_dlgtUserLoggedIn = [[VLDelegate alloc] init];
		_dlgtUserLoggedIn.owner = self;
	}
	return self;
}

- (YTDbEntitiesManager *)dbEntitiesManager {
	return [YTUsersDbManager shared];
}

- (void)initialize {
	[super initialize];
}

- (void)initializeDT {
	[super initializeDT];
	YTUsersDbManager *manrDb = [YTUsersDbManager shared];
	[manrDb loadEntitiesFromDb];
	
	if(manrDb.entities.count) {
		_userInfoST = [[manrDb.entities objectAtIndex:0] retain];
	} else {
		_userInfoST = [[YTUserInfo alloc] init];
		[manrDb addEntity:_userInfoST];
	}
	_userInfoST.added = _userInfoST.deleted = _userInfoST.modified = _userInfoST.isTemporary = NO;
	
	_userInfo = [[YTUserInfo alloc] init];
	_userInfo.parent = self;
	[_userInfo assignDataFrom:_userInfoST];
	_userInfo.added = _userInfo.deleted = _userInfo.modified = _userInfo.isTemporary = NO;
}

- (BOOL)isDemo {
	return _userInfo.isDemo;
}

- (BOOL)isLoggedIn {
	return (_userInfo.personId != 0);
}

- (NSString *)authenticationToken {
	return _userInfo.authenticationToken;
}

- (void)updateOnDT {
	[super updateOnDT];
}

- (void)updateOnMT {
	[super updateOnMT];
}

- (void)startDemoUser {
	[[YTDatabaseManager shared] checkIsMainThread];
	YTUsersDbManager *manrDbUsers = [YTUsersDbManager shared];
	YTStacksDbManager *manrDbStacks = [YTStacksDbManager shared];
	YTNotebooksDbManager *manrDbBooks = [YTNotebooksDbManager shared];
	[[YTDatabaseManager shared] waitingUntilDone:YES performBlockOnDT:^
	{
		_userInfoST.isDemo = YES;
		_userInfoST.personId = kYTUserInfoDemoPersonId;
		_userInfoST.emailId1 = @"Demo";
		_userInfoST.added = _userInfoST.deleted = _userInfoST.modified = _userInfoST.isTemporary = NO;
		[manrDbUsers saveChangesToDb];
		YTStackInfo *newStack = [[[YTStackInfo alloc] init] autorelease];
		newStack.stackId = kYTStackIdDemo;
		[manrDbStacks addEntity:newStack];
		YTNotebookInfo *newNotebook = [[[YTNotebookInfo alloc] init] autorelease];
		newNotebook.name = @"Demo";
		newNotebook.notebookGuid = [[VLGuid makeUnique] yoditoToString];
		newNotebook.stackId = newStack.stackId;
		newNotebook.notebookId = kYTNotebookIdDemo;
		[manrDbBooks addEntity:newNotebook];
	}];
	[_userInfo assignDataFrom:_userInfoST];
	[_dlgtUserLoggedIn sendMessage:self];
}

- (void)loginWithEmail:email password:password resultBlock:(void (^)(NSError *error))resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	[[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Signing In {Title}", nil)];
	YTUsersDbManager *manrDbUsers = [YTUsersDbManager shared];
	BOOL wasDemo = self.isDemo;
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
						  kYTUrlParamOperation, kYTUrlValueOperationAuthenticate];
		
		NSMutableArray *postValues = [NSMutableArray array];
		[postValues addObject:email];
		[postValues addObject:password];
		[postValues addObject:@"iphone"];
		
		YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
		request.dontLogPostData = YES;
		[request postWithUrl:sUrl
					  values:postValues
				 resultBlock:^(NSDictionary *response, NSError *error)
		{
			NSDictionary *dictUser = nil;
			if(!error) {
				dictUser = [response dictionaryValueForKey:kYTJsonKeyUser defaultIsEmpty:NO];
				if(!dictUser) {
					error = [YTWebRequest errorWrongResponse];
				}
			}
			if(error) {
				VLLogError(error);
				[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
				{
					[[VLActivityScreen shared] stopActivity];
					resultBlock(error);
				}];
				return;
			}
			
			YTUserInfo *newUserInfo = [[YTUserInfo new] autorelease];
			[newUserInfo loadFromData:dictUser urlDecode:YES];
			newUserInfo.authenticationToken = [response stringValueForKey:kYTJsonKeyAuthenticationToken defaultVal:@""];
			newUserInfo.currentTime = [response yoditoDateValueForKey:kYTJsonKeyCurrentTime defaultVal:[VLDate empty]];
			newUserInfo.expiration = [response yoditoDateValueForKey:kYTJsonKeyExpiration defaultVal:[VLDate empty]];
			
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
			{
				[_userInfoST assignDataFrom:newUserInfo];
				if(wasDemo) {
					_userInfoST.hasDemoData = YES;
				} else {
					[[YTDatabaseManager shared] deleteAllUserEntities];
				}
				_userInfoST.added = _userInfoST.deleted = _userInfoST.modified = _userInfoST.isTemporary = NO;
				[manrDbUsers saveChangesToDb];
				
				[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
				{
					[[VLActivityScreen shared] stopActivity];
					[_dlgtUserBeforeLoggedOut sendMessage:self];
					[_userInfo assignDataFrom:_userInfoST];
					[_dlgtUserLoggedIn sendMessage:self];
					[self modifyVersion];
					[[YTSyncManager shared] startSyncMTWithResultBlockMT:^(NSError *error) {
						resultBlock(nil);
					}];
				}];
			}];
		}];
	}];
}

- (void)firstLoginWithResultBlock:(void (^)(NSError *error))resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	if(!self.isLoggedIn) {
		resultBlock([YTWebRequest errorNotLoggedIn]);
		return;
	}
	NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
					  kYTUrlParamOperation, kYTUrlValueOperationFirstLogin];
	
	NSMutableArray *postValues = [NSMutableArray array];
	[postValues addObject:[self authenticationToken]];
	
	YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
	[request postWithUrl:sUrl
				  values:postValues
			 resultBlock:^(NSDictionary *response, NSError *error)
	{
		if(error) {
			VLLogError(error);
			resultBlock(error);
			return;
		}
		// {"currentTime":"2012-12-31 11:06:59","authenticationToken":"0b0a986fce40b2b74e0961ec8c272f3d","expiration":"2013-03-31 11:06:24",
		// "stackId":"98","notebookGuid":"D5BECC48-5F86-B4C5-FE58-52DF23B3888F","notebookName":"T Notes","noteGuid":null}
		NSString *sMainNotebookGuid = [response stringValueForKey:kYTJsonKeynotebookGuid defaultVal:@""];
		if(![NSString isEmpty:sMainNotebookGuid]) {
			//[[YTApiMediator shared] setMainNotebookGuid:sMainNotebookGuid];
		}
		resultBlock(nil);
	}];
}

- (void)registerWithFirstName:(NSString *)firstName
					 lastName:(NSString *)lastName
						email:(NSString *)email
					 password:(NSString *)password
				  resultBlock:(void (^)(NSError *error))resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	YTUsersDbManager *manrDbUsers = [YTUsersDbManager shared];
	BOOL wasDemo = self.isDemo;
	[[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Registration in process {Title}", nil)];
	[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
	{
		YTUserInfo *newUser = [[[YTUserInfo alloc] init] autorelease];
		newUser.firstName = firstName;
		newUser.lastName = lastName;
		newUser.emailId1 = email;
		NSMutableDictionary *userData = [NSMutableDictionary dictionary];
		[newUser getData:userData];
		NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
						  kYTUrlParamOperation, kYTUrlValueOperationRegisterUser];
		NSString *sFormat = @"{\n\
\"LastUpdateTS\":null,\n\
\"FirstName\":\"%@\",\n\
\"LastName\":\"%@\",\n\
\"EmailId1\":\"%@\",\n\
\"EmailId2\":null,\n\
\"EmailId3\":null,\n\
\"PackageId\":null\n\
}";
		NSString *sData = [NSString stringWithFormat:sFormat,
						   firstName,
						   lastName,
						   email
						   ];
		//sData = [sData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSMutableArray *postValues = [NSMutableArray array];
		//[postValues addObject:[userData JSONRepresentation]];
		[postValues addObject:sData];
		[postValues addObject:password];
		//[postValues addObject:@"dzxfgvbbgrfbfx"];
		YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
		request.dontLogPostData = YES;
		[request postWithUrl:sUrl
					  values:postValues
				 resultBlock:^(NSDictionary *response, NSError *error)
		{
			NSDictionary *dictUser = nil;
			if(!error) {
				dictUser = [response dictionaryValueForKey:kYTJsonKeyUser defaultIsEmpty:NO];
				if(!dictUser) {
					error = [YTWebRequest errorWrongResponse];
				}
			}
			if(error) {
				VLLogError(error);
				[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
				{
					[[VLActivityScreen shared] stopActivity];
					resultBlock(error);
				}];
				return;
			}
			YTUserInfo *newUserInfo = [[YTUserInfo new] autorelease];
			[newUserInfo loadFromData:dictUser urlDecode:YES];
			newUserInfo.authenticationToken = [response stringValueForKey:kYTJsonKeyAuthenticationToken defaultVal:@""];
			newUserInfo.currentTime = [response yoditoDateValueForKey:kYTJsonKeyCurrentTime defaultVal:[VLDate empty]];
			newUserInfo.expiration = [response yoditoDateValueForKey:kYTJsonKeyExpiration defaultVal:[VLDate empty]];
			
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
			{
				[_userInfoST assignDataFrom:newUserInfo];
				if(wasDemo) {
					_userInfoST.hasDemoData = YES;
				} else {
					[[YTDatabaseManager shared] deleteAllUserEntities];
				}
				_userInfoST.added = _userInfoST.deleted = _userInfoST.modified = _userInfoST.isTemporary = NO;
				[manrDbUsers saveChangesToDb];
				
				[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
				{
					[[VLActivityScreen shared] stopActivity];
					[_dlgtUserBeforeLoggedOut sendMessage:self];
					[_userInfo assignDataFrom:_userInfoST];
					_userJustRegistered = YES;
					[_dlgtUserLoggedIn sendMessage:self];
					[self modifyVersion];
					[self firstLoginWithResultBlock:^(NSError *error) {
						[[YTSyncManager shared] startSyncMTWithResultBlockMT:^(NSError *error) {
							resultBlock(nil);
						}];
					}];
				}];
			}];
		}];
	}];
}

- (void)internalLogoutWithResultBlock:(void (^)(NSError *error))resultBlock {
	YTUsersDbManager *manrDbUsers = [YTUsersDbManager shared];
	[_dlgtUserBeforeLoggedOut sendMessage:self];
	[[YTDatabaseManager shared] waitingUntilDone:YES performBlockOnDT:^
	 {
		 [_userInfoST clear];
		 _userInfoST.added = _userInfoST.deleted = _userInfoST.modified = _userInfoST.isTemporary = NO;
		 [manrDbUsers saveChangesToDb];
		 [[YTDatabaseManager shared] deleteAllUserEntities];
	 }];
	[_userInfo assignDataFrom:_userInfoST];
	[_dlgtUserLoggedOut sendMessage:self];
	resultBlock(nil);
}

- (void)logoutWithResultBlock:(void (^)(NSError *error))resultBlock {
	[[YTDatabaseManager shared] checkIsMainThread];
	BOOL wasDemo = _userInfo.isDemo;
	if(wasDemo) {
		[self internalLogoutWithResultBlock:^(NSError *error) {
			resultBlock(error);
		}];
	} else {
		NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
						  kYTUrlParamOperation, kYTUrlValueOperationLogout];
		NSMutableArray *postValues = [NSMutableArray array];
		[postValues addObject:_userInfo.authenticationToken];
		[[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Signing out {Title}", nil)];
		YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
		[request postWithUrl:sUrl
					  values:postValues
					 timeout:30.0
		 resultBlock:^(NSDictionary *response, NSError *error)
		{
			[[VLActivityScreen shared] stopActivity];
			VLLogEvent(response);
			if(error) {
				VLLogError(error);
				/*VLAlertView *alert = [[[VLAlertView alloc] init] autorelease];
				alert.title = NSLocalizedString(@"Error {Title}", nil);
				alert.message = [NSString stringWithFormat:NSLocalizedString(@"Received an error %@ from server while logging out. Remove the account from this device anyway?", nil), @""];
				[alert addButtonWithTitle:NSLocalizedString(@"Yes {Button}", nil)];
				[alert addButtonWithTitle:NSLocalizedString(@"Cancel {Button}", nil)];
				alert.cancelButtonIndex = alert.numberOfButtons - 1;
				[alert showWithResultBlock:^(int btnIndex, NSString *btnTitle) {
					if(btnIndex == 0) {*/
						[self internalLogoutWithResultBlock:^(NSError *error) {
							[self modifyVersion];
							resultBlock(error);
						}];
					/*} else {
						[self modifyVersion];
						resultBlock(nil);
					}
				}];*/
				return;
			}
			[self internalLogoutWithResultBlock:^(NSError *error) {
				[self modifyVersion];
				resultBlock(error);
			}];
		}];
	}
}

- (void)checkAndRefreshAuthenticationIfNeededDTWithResultBlockDT:(void (^)(NSError *error))resultBlockDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	if(!self.isLoggedIn || _refreshingAuthenticate) {
		resultBlockDT(nil);
		return;
	}
	VLDate *now = [VLDate date];
	VLDate *expiration = _userInfoST.expiration;
	if([VLDate isEmpty:expiration]) {
		resultBlockDT(nil);
		return;
	}
	if([now timeIntervalSinceDate:expiration] >= 0) {
		_refreshingAuthenticate = YES;
		[self refreshAuthenticationDTWithToken:_userInfo.authenticationToken resultBlockDT:^(NSError *error)
		{
			_refreshingAuthenticate = NO;
			if(error) {
				VLLogError(error);
				resultBlockDT(error);
				return;
			}
			resultBlockDT(nil);
		}];
		return;
	}
	resultBlockDT(nil);
}

- (void)refreshAuthenticationDTWithToken:(NSString *)lastAuthToken
						   resultBlockDT:(void (^)(NSError *error))resultBlockDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	YTUsersDbManager *manrDbUsers = [YTUsersDbManager shared];
	if(!self.isLoggedIn) {
		resultBlockDT([YTWebRequest errorNotLoggedIn]);
		return;
	}
	NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
					  kYTUrlParamOperation, kYTUrlValueOperationRefreshAuthentication];
	
	NSMutableArray *postValues = [NSMutableArray array];
	[postValues addObject:lastAuthToken];
	
	YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
	[request postWithUrl:sUrl
				  values:postValues
				 timeout:kYTDefaultWebTimeoutShort
			 resultBlock:^(NSDictionary *response, NSError *error)
	{
		NSDictionary *dictUser = nil;
		if(!error) {
			dictUser = [response dictionaryValueForKey:kYTJsonKeyUser defaultIsEmpty:NO];
			if(!dictUser) {
				error = [YTWebRequest errorWrongResponse];
			}
		}
		if(error) {
			VLLogError(error);
			//[[VLActivityScreen shared] stopActivity];
			resultBlockDT(error);
			return;
		}
		
		if([dictUser stringValueForKey:kYTJsonKeyPersonId defaultVal:nil])
			_userInfoST.personId = [dictUser int64ValueForKey:kYTJsonKeyPersonId defaultVal:0];
		if([dictUser stringValueForKey:kYTJsonKeyFirstName defaultVal:nil])
			_userInfoST.firstName = [dictUser stringValueForKey:kYTJsonKeyFirstName defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyLastName defaultVal:nil])
			_userInfoST.lastName = [dictUser stringValueForKey:kYTJsonKeyLastName defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyEmailId1 defaultVal:nil])
			_userInfoST.emailId1 = [dictUser stringValueForKey:kYTJsonKeyEmailId1 defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyEmailId2 defaultVal:nil])
			_userInfoST.emailId2 = [dictUser stringValueForKey:kYTJsonKeyEmailId2 defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyEmailId3 defaultVal:nil])
			_userInfoST.emailId3 = [dictUser stringValueForKey:kYTJsonKeyEmailId3 defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyAccountStatus defaultVal:nil])
			_userInfoST.accountStatus = [dictUser stringValueForKey:kYTJsonKeyAccountStatus defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyDiskSpaceUsed defaultVal:nil])
			_userInfoST.diskSpaceUsed = [dictUser floatValueForKey:kYTJsonKeyDiskSpaceUsed defaultVal:0];
		if([dictUser stringValueForKey:kYTJsonKeyStatus defaultVal:nil])
			_userInfoST.status = [dictUser stringValueForKey:kYTJsonKeyStatus defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyCreatedDate defaultVal:nil])
			_userInfoST.createdDate = [VLDate yoditoDateWithString:[dictUser stringValueForKey:kYTJsonKeyCreatedDate defaultVal:@""]];
		if([dictUser stringValueForKey:kYTJsonKeyPackageId defaultVal:nil])
			_userInfoST.packageId = (int)[dictUser int64ValueForKey:kYTJsonKeyPackageId defaultVal:0];
		
		if([response stringValueForKey:kYTJsonKeyAuthenticationToken defaultVal:nil])
			_userInfoST.authenticationToken = [response stringValueForKey:kYTJsonKeyAuthenticationToken defaultVal:@""];
		if([response stringValueForKey:kYTJsonKeyCurrentTime defaultVal:nil])
			_userInfoST.currentTime = [response yoditoDateValueForKey:kYTJsonKeyCurrentTime defaultVal:[VLDate empty]];
		if([response stringValueForKey:kYTJsonKeyExpiration defaultVal:nil])
			_userInfoST.expiration = [response yoditoDateValueForKey:kYTJsonKeyExpiration defaultVal:[VLDate empty]];
		
		if([dictUser stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:nil])
			_userInfoST.lastUpdateTS = [VLDate yoditoDateWithString:[dictUser stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""]];
		
		_userInfoST.added = _userInfoST.deleted = _userInfoST.modified = _userInfoST.isTemporary = NO;
		[manrDbUsers saveChangesToDb];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			[_userInfo assignDataFrom:_userInfoST];
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
			{
				resultBlockDT(nil);
			}];
		}];
	}];
}

- (void)updateUserInfoDTWithResultBlockDT:(void (^)(NSError *error))resultBlockDT {
	[[YTDatabaseManager shared] checkIsDatabaseThread];
	YTUsersDbManager *manrDbUsers = [YTUsersDbManager shared];
	if(!self.isLoggedIn) {
		resultBlockDT([YTWebRequest errorNotLoggedIn]);
		return;
	}
	if(self.isDemo) {
		resultBlockDT([NSError makeCancel]);
		return;
	}
	NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
					  kYTUrlParamOperation, kYTUrlValueOperationGetUser];
	
	NSMutableArray *postValues = [NSMutableArray array];
	[postValues addObject:[self authenticationToken]];
	
	YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
	[request postWithUrl:sUrl
				  values:postValues
				 timeout:kYTDefaultWebTimeoutShort
			 resultBlock:^(NSDictionary *response, NSError *error)
	{
		if(error) {
			VLLogError(error);
			//[[VLActivityScreen shared] stopActivity];
			resultBlockDT(error);
			return;
		}
		
		NSDictionary *dictUser = response;
		if([dictUser stringValueForKey:kYTJsonKeyPersonId defaultVal:nil])
			_userInfoST.personId = [dictUser int64ValueForKey:kYTJsonKeyPersonId defaultVal:0];
		if([dictUser stringValueForKey:kYTJsonKeyFirstName defaultVal:nil])
			_userInfoST.firstName = [dictUser stringValueForKey:kYTJsonKeyFirstName defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyLastName defaultVal:nil])
			_userInfoST.lastName = [dictUser stringValueForKey:kYTJsonKeyLastName defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyEmailId1 defaultVal:nil])
			_userInfoST.emailId1 = [dictUser stringValueForKey:kYTJsonKeyEmailId1 defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyEmailId2 defaultVal:nil])
			_userInfoST.emailId2 = [dictUser stringValueForKey:kYTJsonKeyEmailId2 defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyEmailId3 defaultVal:nil])
			_userInfoST.emailId3 = [dictUser stringValueForKey:kYTJsonKeyEmailId3 defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyAccountStatus defaultVal:nil])
			_userInfoST.accountStatus = [dictUser stringValueForKey:kYTJsonKeyAccountStatus defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyDiskSpaceUsed defaultVal:nil])
			_userInfoST.diskSpaceUsed = [dictUser floatValueForKey:kYTJsonKeyDiskSpaceUsed defaultVal:0];
		if([dictUser stringValueForKey:kYTJsonKeyStatus defaultVal:nil])
			_userInfoST.status = [dictUser stringValueForKey:kYTJsonKeyStatus defaultVal:@""];
		if([dictUser stringValueForKey:kYTJsonKeyCreatedDate defaultVal:nil])
			_userInfoST.createdDate = [VLDate yoditoDateWithString:[dictUser stringValueForKey:kYTJsonKeyCreatedDate defaultVal:@""]];
		if([dictUser stringValueForKey:kYTJsonKeyPackageId defaultVal:nil])
			_userInfoST.packageId = (int)[dictUser int64ValueForKey:kYTJsonKeyPackageId defaultVal:0];
		
		if([dictUser stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:nil])
			_userInfoST.lastUpdateTS = [VLDate yoditoDateWithString:[dictUser stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""]];
		
		_userInfoST.added = _userInfoST.deleted = _userInfoST.modified = _userInfoST.isTemporary = NO;
		[manrDbUsers saveChangesToDb];
		[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnMT:^
		{
			[_userInfo assignDataFrom:_userInfoST];
			[[YTDatabaseManager shared] waitingUntilDone:NO performBlockOnDT:^
			{
				resultBlockDT(nil);
			}];
		}];
	}];
}

- (void)startRestoreForgottenPasswordWithEmail:(NSString *)email resultBlock:(void (^)(NSError *error))resultBlock {
	/*NSString *msg = NSLocalizedString(@"An email with instructions will be sent to your registered email address.", nil);
	VLAlertView *alertView = [[[VLAlertView alloc] init] autorelease];
	alertView.title = msg;
	[alertView addButtonWithTitle:NSLocalizedString(@"OK {Button}", nil)];
	[alertView addButtonWithTitle:NSLocalizedString(@"Cancel {Button}", nil)];
	alertView.cancelButtonIndex = alertView.numberOfButtons - 1;
	[alertView showWithResultBlock:^(int btnIndex, NSString *btnTitle) {
		if(btnIndex != 0)
			return;*/
		NSString *sUrl = [NSString stringWithFormat:@"%@?%@=%@", kYTUrlApi,
						  kYTUrlParamOperation, kYTUrlValueOperationForgotPassword];
		NSMutableArray *postValues = [NSMutableArray array];
		[postValues addObject:email];
		
		YTWebRequest *request = [[[YTWebRequest alloc] init] autorelease];
		[request postWithUrl:sUrl
					  values:postValues
				 resultBlock:^(NSDictionary *response, NSError *error)
		{
			if(error) {
				VLLogError(error);
				[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:[error localizedDescription]];
				resultBlock(error);
				return;
			}
			// {"status":"success","message":"Reset password has been sent."}
			// { message = "Email not exist"; status = fail; }
			NSString *status = [response stringValueForKey:@"status" defaultVal:@""];
			NSString *message = [response stringValueForKey:@"message" defaultVal:@""];
			message = [[YTNoteHtmlParser shared] urlDecode:message];
			if([status compare:@"success" options:NSCaseInsensitiveSearch] == 0) {
				//[VLAlertView showWithOkAndTitle:message message:nil];
				[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Reset password instructions sent", nil) message:nil];
				resultBlock(nil);
				return;
			}
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:message];
			resultBlock([NSError makeWithText:message]);
		}];
	/*}];*/
}

- (void)dealloc {
	[super dealloc];
}

@end

