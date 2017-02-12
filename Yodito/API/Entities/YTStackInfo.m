
#import "YTStackInfo.h"

@implementation YTStackInfo

@synthesize stackId = _stackId;
@synthesize personId = _personId;
@synthesize stackName = _stackName;
@synthesize createdDate = _createdDate;
@synthesize isValid = _isValid;

- (id)iinit {
	self = [super init];
	if(self) {
		_stackId = 0;
		_personId = 0;
		_stackName = [@"" retain];
		_createdDate = [[VLDate date] retain];
		_isValid = 0;
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableStack;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"stackId"
																  attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyStackId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"personId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyPersonId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"stackName"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyStackName
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"createdDate"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyCreatedDate
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"isValid"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyIsValid
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
}

- (void)setStackId:(int64_t)stackId {
	if(_stackId != stackId) {
		_stackId = stackId;
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setPersonId:(int64_t)personId {
	if(_personId != personId) {
		_personId = personId;
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setStackName:(NSString *)stackName {
	if(!stackName)
		stackName = @"";
	if(![_stackName isEqual:stackName]) {
		[_stackName release];
		_stackName = [stackName copy];
		self.modified = YES;
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
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setIsValid:(BOOL)isValid {
	if(_isValid != isValid) {
		_isValid = isValid;
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)assignDataFrom:(YTStackInfo *)other {
	[super assignDataFrom:other];
	self.stackId = other.stackId;
	self.personId = other.personId;
	self.stackName = other.stackName;
	self.createdDate = other.createdDate;
	self.isValid = other.isValid;
}

- (NSComparisonResult)compareIdentityTo:(YTStackInfo *)other {
	if(self.stackId != other.stackId)
		return (self.stackId - other.stackId < 0) ? -1 : 1;
	return 0;
}

- (NSComparisonResult)compareDataTo:(YTStackInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.stackId != other.stackId)
		return self.stackId - other.stackId;
	if(self.personId != other.personId)
		return self.personId - other.personId;
	if([self.stackName compare:other.stackName])
		return [self.stackName compare:other.stackName];
	if([self.createdDate compare:other.createdDate])
		return [self.createdDate compare:other.createdDate];
	if(self.isValid != other.isValid)
		return (int)self.isValid - (int)other.isValid;
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.stackId = [data int64ValueForKey:kYTJsonKeyStackId defaultVal:0];
	self.personId = [data int64ValueForKey:kYTJsonKeyPersonId defaultVal:0];
	self.stackName = [data stringValueForKey:kYTJsonKeyStackName defaultVal:@""];
	NSString *sCreatedDate = [data stringValueForKey:kYTJsonKeyCreatedDate defaultVal:@""];
	self.createdDate = [VLDate yoditoDateWithString:sCreatedDate];
	self.isValid = [data yoditoBoolValueForKey:kYTJsonKeyIsValid defaultVal:NO];
}

- (void)dealloc {
	[_stackName release];
	[_createdDate release];
	[super dealloc];
}

@end

