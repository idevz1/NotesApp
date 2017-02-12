
#import "YTUserInfo.h"

@implementation YTUserInfo

@synthesize isDemo = _isDemo;
@synthesize hasDemoData = _hasDemoData;
@synthesize personId = _personId;
@synthesize lastUpdateTS = _lastUpdateTS;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize emailId1 = _emailId1;
@synthesize emailId2 = _emailId2;
@synthesize emailId3 = _emailId3;
@synthesize accountStatus = _accountStatus;
@synthesize diskSpaceUsed = _diskSpaceUsed;
@synthesize status = _status;
@synthesize createdDate = _createdDate;
@synthesize packageId = _packageId;

@synthesize authenticationToken = _authenticationToken;
@synthesize currentTime = _currentTime;
@synthesize expiration = _expiration;

- (id)init {
	self = [super init];
	if(self) {
		_isDemo = NO;
		_hasDemoData = NO;
		_personId = 0;
		_lastUpdateTS = [[VLDate date] retain];
		_firstName = [@"" retain];
		_lastName = [@"" retain];
		_emailId1 = [@"" retain];
		_emailId2 = [@"" retain];
		_emailId3 = [@"" retain];
		_accountStatus = [@"" retain];
		_diskSpaceUsed = 0;
		_status = [@"" retain];
		_createdDate = [[VLDate empty] retain];
		_packageId = 0;
		
		_authenticationToken = [@"" retain];
		_currentTime = [[VLDate empty] retain];
		_expiration = [[VLDate empty] retain];
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableUser;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"isDemo"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyIsDemo
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"hasDemoData"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyHasDemoData
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"personId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyPersonId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"lastUpdateTS"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyLastUpdateTS
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"firstName"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyFirstName
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"lastName"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyLastName
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"emailId1"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyEmailId1
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"emailId2"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyEmailId2
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"emailId3"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyEmailId3
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"accountStatus"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyAccountStatus
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"diskSpaceUsed"
																   attrType:EVLSqliteEntityAttrTypeFloat
																  fieldName:kYTJsonKeyDiskSpaceUsed
																 fieldFlags:EVLSqliteFieldTypeFlagReal] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"status"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyStatus
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"createdDate"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyCreatedDate
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"authenticationToken"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyAuthenticationToken
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"currentTime"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyCurrentTime
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"expiration"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyExpiration
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"packageId"
																   attrType:EVLSqliteEntityAttrTypeInt
																  fieldName:kYTJsonKeyPackageId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
}

- (void)setIsDemo:(BOOL)isDemo {
	if(_isDemo != isDemo) {
		_isDemo = isDemo;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setHasDemoData:(BOOL)hasDemoData {
	if(_hasDemoData != hasDemoData) {
		_hasDemoData = hasDemoData;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setPersonId:(int64_t)personId {
	if(_personId != personId) {
		_personId = personId;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setLastUpdateTS:(VLDate *)lastUpdateTS {
	if(!lastUpdateTS)
		lastUpdateTS = [VLDate empty];
	if(![_lastUpdateTS isEqual:lastUpdateTS]) {
		[_lastUpdateTS release];
		_lastUpdateTS = [lastUpdateTS retain];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setFirstName:(NSString *)firstName {
	if(!firstName)
		firstName = @"";
	if(![_firstName isEqual:firstName]) {
		[_firstName release];
		_firstName = [firstName copy];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setLastName:(NSString *)lastName {
	if(!lastName)
		lastName = @"";
	if(![_lastName isEqual:lastName]) {
		[_lastName release];
		_lastName = [lastName copy];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setEmailId1:(NSString *)emailId1 {
	if(!emailId1)
		emailId1 = @"";
	if(![_emailId1 isEqual:emailId1]) {
		[_emailId1 release];
		_emailId1 = [emailId1 copy];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setEmailId2:(NSString *)emailId2 {
	if(!emailId2)
		emailId2 = @"";
	if(![_emailId2 isEqual:emailId2]) {
		[_emailId2 release];
		_emailId2 = [emailId2 copy];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setEmailId3:(NSString *)emailId3 {
	if(!emailId3)
		emailId3 = @"";
	if(![_emailId3 isEqual:emailId3]) {
		[_emailId3 release];
		_emailId3 = [emailId3 copy];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setAccountStatus:(NSString *)accountStatus {
	if(!accountStatus)
		accountStatus = @"";
	if(![_accountStatus isEqual:accountStatus]) {
		[_accountStatus release];
		_accountStatus = [accountStatus copy];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setDiskSpaceUsed:(float)diskSpaceUsed {
	if(_diskSpaceUsed != diskSpaceUsed) {
		_diskSpaceUsed = diskSpaceUsed;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setStatus:(NSString *)status {
	if(!status)
		status = @"";
	if(![_status isEqual:status]) {
		[_status release];
		_status = [status copy];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setCreatedDate:(VLDate *)createdDate {
	if(!createdDate)
		createdDate = [VLDate empty];
	if(![_createdDate isEqual:createdDate]) {
		[_createdDate release];
		_createdDate = [createdDate retain];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setPackageId:(int)packageId {
	if(_packageId != packageId) {
		_packageId = packageId;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setAuthenticationToken:(NSString *)authenticationToken {
	if(!authenticationToken)
		authenticationToken = @"";
	if(![_authenticationToken isEqual:authenticationToken]) {
		[_authenticationToken release];
		_authenticationToken = [authenticationToken copy];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setCurrentTime:(VLDate *)currentTime {
	if(!currentTime)
		currentTime = [VLDate empty];
	if(![_currentTime isEqual:currentTime]) {
		[_currentTime release];
		_currentTime = [currentTime retain];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setExpiration:(VLDate *)expiration {
	if(!expiration)
		expiration = [VLDate empty];
	if(![_expiration isEqual:expiration]) {
		[_expiration release];
		_expiration = [expiration retain];
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)assignDataFrom:(YTUserInfo *)other {
	[super assignDataFrom:other];
	self.isDemo = other.isDemo;
	self.hasDemoData = other.hasDemoData;
	self.personId = other.personId;
	self.firstName = other.firstName;
	self.lastName = other.lastName;
	self.emailId1 = other.emailId1;
	self.emailId2 = other.emailId2;
	self.emailId3 = other.emailId3;
	self.accountStatus = other.accountStatus;
	self.diskSpaceUsed = other.diskSpaceUsed;
	self.status = other.status;
	self.createdDate = other.createdDate;
	self.packageId = other.packageId;
	
	self.authenticationToken = other.authenticationToken;
	self.currentTime = other.currentTime;
	self.expiration = other.expiration;
	
	self.lastUpdateTS = other.lastUpdateTS;
}

- (NSComparisonResult)compareIdentityTo:(YTUserInfo *)other {
	if(self.personId != other.personId)
		return (self.personId - other.personId < 0) ? -1 : 1;
	return 0;
}

- (NSComparisonResult)compareDataTo:(YTUserInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.isDemo != other.isDemo)
		return (int)self.isDemo - (int)other.isDemo;
	if(self.hasDemoData != other.hasDemoData)
		return (int)self.hasDemoData - (int)other.hasDemoData;
	if(self.personId != other.personId)
		return (self.personId - other.personId < 0) ? -1 : 1;
	if([self.lastUpdateTS compare:other.lastUpdateTS])
		return [self.lastUpdateTS compare:other.lastUpdateTS];
	if([self.firstName compare:other.firstName])
		return [self.firstName compare:other.firstName];
	if([self.lastName compare:other.lastName])
		return [self.lastName compare:other.lastName];
	if([self.emailId1 compare:other.emailId1])
		return [self.emailId1 compare:other.emailId1];
	if([self.emailId2 compare:other.emailId2])
		return [self.emailId2 compare:other.emailId2];
	if([self.emailId3 compare:other.emailId3])
		return [self.emailId3 compare:other.emailId3];
	if([self.accountStatus compare:other.accountStatus])
		return [self.accountStatus compare:other.accountStatus];
	if(self.diskSpaceUsed != other.diskSpaceUsed)
		return (self.diskSpaceUsed - other.diskSpaceUsed) > 0 ? 1 : -1;
	if([self.status compare:other.status])
		return [self.status compare:other.status];
	if([self.createdDate compare:other.createdDate])
		return [self.createdDate compare:other.createdDate];
	if(self.packageId != other.packageId)
		return self.packageId - other.packageId;
	
	if([self.authenticationToken compare:other.authenticationToken])
		return [self.authenticationToken compare:other.authenticationToken];
	if([self.currentTime compare:other.currentTime])
		return [self.currentTime compare:other.currentTime];
	if([self.expiration compare:other.expiration])
		return [self.expiration compare:other.expiration];
	return 0;
}

- (void)clear {
	self.isDemo = NO;
	self.hasDemoData = NO;
	self.personId = 0;
	self.lastUpdateTS = [VLDate empty];
	self.firstName = @"";
	self.lastName = @"";
	self.emailId1 = @"";
	self.emailId2 = @"";
	self.emailId3 = @"";
	self.accountStatus = @"";
	self.diskSpaceUsed = 0;
	self.status = @"";
	self.createdDate = [VLDate empty];
	self.packageId = 0;
	
	self.authenticationToken = @"";
	self.currentTime = [VLDate empty];
	self.expiration = [VLDate empty];
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.isDemo = [data boolValueForKey:kYTJsonKeyIsDemo defaultVal:NO];
	self.hasDemoData = [data boolValueForKey:kYTJsonKeyHasDemoData defaultVal:NO];
	self.personId = [data int64ValueForKey:kYTJsonKeyPersonId defaultVal:0];
	self.firstName = [data stringValueForKey:kYTJsonKeyFirstName defaultVal:@""];
	self.lastName = [data stringValueForKey:kYTJsonKeyLastName defaultVal:@""];
	self.emailId1 = [data stringValueForKey:kYTJsonKeyEmailId1 defaultVal:@""];
	self.emailId2 = [data stringValueForKey:kYTJsonKeyEmailId2 defaultVal:@""];
	self.emailId3 = [data stringValueForKey:kYTJsonKeyEmailId3 defaultVal:@""];
	self.accountStatus = [data stringValueForKey:kYTJsonKeyAccountStatus defaultVal:@""];
	self.diskSpaceUsed = [data floatValueForKey:kYTJsonKeyDiskSpaceUsed defaultVal:0];
	self.status = [data stringValueForKey:kYTJsonKeyStatus defaultVal:@""];
	NSString *sCreatedDate = [data stringValueForKey:kYTJsonKeyCreatedDate defaultVal:@""];
	self.createdDate = [VLDate yoditoDateWithString:sCreatedDate];
	self.packageId = (int)[data int64ValueForKey:kYTJsonKeyPackageId defaultVal:0];
	
	self.authenticationToken = [data stringValueForKey:kYTJsonKeyAuthenticationToken defaultVal:self.authenticationToken];
	self.currentTime = [data yoditoDateValueForKey:kYTJsonKeyCurrentTime defaultVal:self.currentTime];
	self.expiration = [data yoditoDateValueForKey:kYTJsonKeyExpiration defaultVal:self.expiration];
	
	NSString *sLastUpdateTS = [data stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""];
	self.lastUpdateTS = [VLDate yoditoDateWithString:sLastUpdateTS];
}

- (void)dealloc {
	[_lastUpdateTS release];
	[_firstName release];
	[_lastName release];
	[_emailId1 release];
	[_emailId2 release];
	[_emailId3 release];
	[_accountStatus release];
	[_status release];
	[_createdDate release];
	
	[_authenticationToken release];
	[_currentTime release];
	[_expiration release];
	[super dealloc];
}

@end
