
#import "YTNoteToLocationInfo.h"

@implementation YTNoteToLocationInfo

@synthesize noteGuid = _noteGuid;
@synthesize locationId = _locationId;

- (id)init {
	self = [super init];
	if(self) {
		_noteGuid = [@"" retain];
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableNoteToLocation;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"noteGuid"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyNoteGUID
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"locationId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyLocationId
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

- (void)setLocationId:(int64_t)locationId {
	if(_locationId != locationId) {
		_locationId = locationId;
		self.modified = YES;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)assignDataFrom:(YTNoteToLocationInfo *)other {
	[super assignDataFrom:other];
	self.noteGuid = other.noteGuid;
	self.locationId = other.locationId;
}

- (NSComparisonResult)compareIdentityTo:(YTNoteToLocationInfo *)other {
	if(self.locationId != other.locationId)
		return (self.locationId < other.locationId) ? -1 : 1;
	if([self.noteGuid compare:other.noteGuid])
		return [self.noteGuid compare:other.noteGuid];
	return 0;
}

- (NSComparisonResult)compareDataTo:(YTNoteToLocationInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.locationId != other.locationId)
		return (self.locationId < other.locationId) ? -1 : 1;
	if([self.noteGuid compare:other.noteGuid])
		return [self.noteGuid compare:other.noteGuid];
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.noteGuid = [data stringValueForKey:kYTJsonKeyNoteGUID defaultVal:@""];
	self.locationId = [data int64ValueForKey:kYTJsonKeyLocationId defaultVal:self.locationId];
}

+ (NSString *)entityName {
	return @"NOTELOCATION";
}

- (void)dealloc {
	[_noteGuid release];
	[super dealloc];
}

@end

