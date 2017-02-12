
#import "VLSqliteEntity.h"

@implementation VLSqliteEntityArgs

@synthesize entity = _entity;

- (void)dealloc {
	[_entity release];
	[super dealloc];
}

@end


@implementation VLSqliteEntity

@synthesize nId = _nId;
@synthesize modified = _modified;
@synthesize added = _added;
@synthesize deleted = _deleted;
@synthesize needSave = _needSave;

- (NSString *)dbTableName {
	return @"";
}

- (void)setNId:(int64_t)nId {
	if(_nId != nId) {
		_nId = nId;
		[self modifyVersion];
	}
}

- (void)setModified:(BOOL)modified {
	if(_modified != modified) {
		_modified = modified;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setAdded:(BOOL)added {
	if(_added != added) {
		_added = added;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setDeleted:(BOOL)deleted {
	if(_deleted != deleted) {
		_deleted = deleted;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setNeedSave:(BOOL)needSave {
	if(_needSave != needSave) {
		_needSave = needSave;
		[self modifyVersion];
	}
}

- (NSArray *)dbFields {
	static NSMutableDictionary *_cache = nil;
	if(!_cache)
		_cache = [[NSMutableDictionary alloc] init];
	NSString *key = NSStringFromClass([self class]);
	NSMutableArray *fields = [_cache objectForKey:key];
	if(fields)
		return fields;
	fields = [[[NSMutableArray alloc] init] autorelease];
	[self onCreateFieldsList:fields];
	[_cache setObject:fields forKey:key];
	return fields;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"nId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kVLSqliteFieldKeyId
																  fieldFlags:EVLSqliteFieldTypeFlagInteger|EVLSqliteFieldTypeFlagPrimaryKey] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"modified"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kVLSqliteFieldKeyModified
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"added"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kVLSqliteFieldKeyAdded
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"deleted"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kVLSqliteFieldKeyDeleted
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
}

- (void)loadFromData:(NSDictionary *)data {
	self.nId = [data int64ValueForKey:kVLSqliteFieldKeyId defaultVal:self.nId];
	self.modified = [data boolValueForKey:kVLSqliteFieldKeyModified defaultVal:self.modified];
	self.added = [data boolValueForKey:kVLSqliteFieldKeyAdded defaultVal:self.added];
	self.deleted = [data boolValueForKey:kVLSqliteFieldKeyDeleted defaultVal:self.deleted];
}

- (void)getData:(NSMutableDictionary *)data {
	
}

- (void)assignDataFrom:(VLSqliteEntity *)other {
	self.added = other.added;
	self.modified = other.modified;
	self.deleted = other.deleted;
}

- (NSComparisonResult)compareIdentityTo:(VLSqliteEntity *)other {
	return 0;
}

- (NSComparisonResult)compareDataTo:(VLSqliteEntity *)other {
	return 0;
}

@end

