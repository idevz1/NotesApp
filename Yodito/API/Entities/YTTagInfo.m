
#import "YTTagInfo.h"

@implementation YTTagInfo

@synthesize tagId = _tagId;
@synthesize name = _name;
@synthesize lastUpdateTS = _lastUpdateTS;

- (id)init {
	self = [super init];
	if(self) {
		_name = [@"" retain];
		_lastUpdateTS = [[VLDate date] retain];
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableTag;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"tagId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyTagId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"name"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyName
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"lastUpdateTS"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyLastUpdateTS
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
}

- (void)setTagId:(int64_t)tagId {
	if(_tagId != tagId) {
		_tagId = tagId;
		//self.modified = YES;
		self.needSave = YES;
		//self.lastUpdateTS = [VLDate date];
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

- (void)assignDataFrom:(YTTagInfo *)other {
	[super assignDataFrom:other];
	self.tagId = other.tagId;
	self.name = other.name;
	self.lastUpdateTS = other.lastUpdateTS;
}

- (NSComparisonResult)compareIdentityTo:(YTTagInfo *)other {
	if(self.tagId != other.tagId)
		return (self.tagId - other.tagId < 0) ? -1 : 1;
	int res = [super compareIdentityTo:other];
	if(res != 0)
		return res;
	return 0;
}

- (NSComparisonResult)compareDataTo:(YTTagInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.tagId != other.tagId)
		return self.tagId - other.tagId;
	if([self.name compare:other.name])
		return [self.name compare:other.name];
	if([self.lastUpdateTS compare:other.lastUpdateTS])
		return [self.lastUpdateTS compare:other.lastUpdateTS];
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.tagId = [data int64ValueForKey:kYTJsonKeyTagId defaultVal:0];
	self.name = [data stringValueForKey:kYTJsonKeyName defaultVal:@""];
	NSString *sLastUpdateTS = [data stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""];
	self.lastUpdateTS = [VLDate yoditoDateWithString:sLastUpdateTS];
}

- (void)dealloc {
	[_name release];
	[_lastUpdateTS release];
	[super dealloc];
}

@end

