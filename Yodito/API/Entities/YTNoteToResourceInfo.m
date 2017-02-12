
#import "YTNoteToResourceInfo.h"

@implementation YTNoteToResourceInfo

@synthesize noteGuid = _noteGuid;
@synthesize resourceId = _resourceId;

- (id)init {
	self = [super init];
	if(self) {
		_noteGuid = [@"" retain];
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableNoteToResource;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"noteGuid"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyNoteGUID
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"resourceId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyResourceId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
}

- (void)setNoteGuid:(NSString *)noteGuid {
	if(!noteGuid)
		noteGuid = @"";
	if(![_noteGuid isEqual:noteGuid]) {
		[_noteGuid release];
		_noteGuid = [noteGuid copy];
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setResourceId:(int64_t)resourceId {
	if(_resourceId != resourceId) {
		_resourceId = resourceId;
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)assignDataFrom:(YTNoteToResourceInfo *)other {
	[super assignDataFrom:other];
	self.noteGuid = other.noteGuid;
	self.resourceId = other.resourceId;
}

- (NSComparisonResult)compareIdentityTo:(YTNoteToResourceInfo *)other {
	if(self.resourceId != other.resourceId)
		return (self.resourceId < other.resourceId) ? -1 : 1;
	if([self.noteGuid compare:other.noteGuid])
		return [self.noteGuid compare:other.noteGuid];
	return 0;
}

- (NSComparisonResult)compareDataTo:(YTNoteToResourceInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.resourceId != other.resourceId)
		return (self.resourceId < other.resourceId) ? -1 : 1;
	if([self.noteGuid compare:other.noteGuid])
		return [self.noteGuid compare:other.noteGuid];
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.noteGuid = [data stringValueForKey:kYTJsonKeyNoteGUID defaultVal:@""];
	self.resourceId = [data int64ValueForKey:kYTJsonKeyResourceId defaultVal:self.resourceId];
}

- (void)dealloc {
	[_noteGuid release];
	[super dealloc];
}

@end

