
#import "YTNotebookInfo.h"
#import "../Notes/Classes.h"

@implementation YTNotebookInfo

@synthesize notebookId = _notebookId;
@synthesize notebookGuid = _notebookGuid;
@synthesize stackId = _stackId;
@synthesize colorId = _colorId;
@synthesize name = _name;
@synthesize visibility = _visibility;
@synthesize isDefault = _isDefault;
@synthesize lastUpdateTS = _lastUpdateTS;

- (id)init {
	self = [super init];
	if(self) {
		_notebookGuid = [@"" retain];
		_visibility = YES;
		_colorId = 1;
		_lastUpdateTS = [[VLDate date] retain];
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableNotebook;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"notebookId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyNotebookId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"notebookGuid"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyNotebookGUID
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"stackId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyStackId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"colorId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyColorId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"lastUpdateTS"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyLastUpdateTS
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"name"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyName
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"visibility"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyVisibility
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"isDefault"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyIsDefault
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
}

- (void)setNotebookId:(int64_t)notebookId {
	if(_notebookId != notebookId) {
		_notebookId = notebookId;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setNotebookGuid:(NSString *)notebookGuid {
	if(!notebookGuid)
		notebookGuid = @"";
	if(![_notebookGuid isEqual:notebookGuid]) {
		[_notebookGuid release];
		_notebookGuid = [notebookGuid copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setStackId:(int64_t)stackId {
	if(_stackId != stackId) {
		_stackId = stackId;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setColorId:(int64_t)colorId {
	if(_colorId != colorId) {
		_colorId = colorId;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setName:(NSString *)name {
	if(!name)
		name = @"";
	if(![_name isEqual:name]) {
		[_name release];
		_name = [name copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setVisibility:(BOOL)visibility {
	if(_visibility != visibility) {
		_visibility = visibility;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setIsDefault:(BOOL)isDefault {
	if(_isDefault != isDefault) {
		_isDefault = isDefault;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setLastUpdateTS:(VLDate *)lastUpdateTS {
	if(!lastUpdateTS)
		lastUpdateTS = [VLDate empty];
	if(![_lastUpdateTS isEqual:lastUpdateTS]) {
		[_lastUpdateTS release];
		_lastUpdateTS = [lastUpdateTS retain];
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)assignDataFrom:(YTNotebookInfo *)other {
	[super assignDataFrom:other];
	self.notebookId = other.notebookId;
	self.notebookGuid = other.notebookGuid;
	self.stackId = other.stackId;
	self.colorId = other.colorId;
	self.name = other.name;
	self.visibility = other.visibility;
	self.isDefault = other.isDefault;
	self.lastUpdateTS = other.lastUpdateTS;
}

- (NSComparisonResult)compareIdentityTo:(YTNotebookInfo *)other {
	if(self.notebookId != other.notebookId)
		return (self.notebookId < other.notebookId) ? -1 : 1;
	return [self.notebookGuid compare:other.notebookGuid];
}

- (NSComparisonResult)compareDataTo:(YTNotebookInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.notebookId != other.notebookId)
		return (self.notebookId < other.notebookId) ? -1 : 1;
	if([self.notebookGuid compare:other.notebookGuid])
		return [self.notebookGuid compare:other.notebookGuid];
	if(self.stackId != other.stackId)
		return (self.stackId < other.stackId) ? -1 : 1;
	if(self.colorId != other.colorId)
		return (self.colorId < other.colorId) ? -1 : 1;
	if([self.lastUpdateTS compare:other.lastUpdateTS])
		return [self.lastUpdateTS compare:other.lastUpdateTS];
	if([self.name compare:other.name])
		return [self.name compare:other.name];
	if(self.visibility != other.visibility)
		return (int)self.visibility - (int)other.visibility;
	if(self.isDefault != other.isDefault)
		return (int)self.isDefault - (int)other.isDefault;
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.notebookId = [data int64ValueForKey:kYTJsonKeyNotebookId defaultVal:self.notebookId];
	self.notebookGuid = [data stringValueForKey:kYTJsonKeyNotebookGUID defaultVal:@""];
	self.stackId = [data int64ValueForKey:kYTJsonKeyStackId defaultVal:0];
	self.colorId = [data int64ValueForKey:kYTJsonKeyColorId defaultVal:self.colorId];
	NSString *sName = [data stringValueForKey:kYTJsonKeyName defaultVal:@""];
	if(urlDecode)
		sName = [[YTNoteHtmlParser shared] urlDecode:sName];
	self.name = sName;
	self.visibility = [data yoditoBoolValueForKey:kYTJsonKeyVisibility defaultVal:self.visibility];
	self.isDefault = [data yoditoBoolValueForKey:kYTJsonKeyIsDefault defaultVal:self.isDefault];
	NSString *sLastUpdateTS = [data stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""];
	self.lastUpdateTS = [VLDate yoditoDateWithString:sLastUpdateTS];
}

- (void)dealloc {
	[_notebookGuid release];
	[_lastUpdateTS release];
	[_name release];
	[super dealloc];
}

@end

