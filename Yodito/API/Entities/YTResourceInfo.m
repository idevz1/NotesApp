
#import "YTResourceInfo.h"
#import "YTResourceTypeInfo.h"
#import "../Notes/Classes.h"

@implementation YTResourceInfo

@synthesize attachmentId = _attachmentId;
@synthesize attachmentCategoryId = _attachmentCategoryId;
@synthesize attachmentTypeName = _attachmentTypeName;
@synthesize s3StorageUUID = _s3StorageUUID;
@synthesize filename = _filename;
@synthesize descr = _descr;
@synthesize isThumbnail = _isThumbnail;
@synthesize parentAttachmentId = _parentAttachmentId;
@synthesize attachmenthash = _attachmenthash;
@synthesize lastUpdateTS = _lastUpdateTS;

- (id)init {
	self = [super init];
	if(self) {
		_attachmentTypeName = [@"" retain];
		_s3StorageUUID = [@"" retain];
		_filename = [@"" retain];
		_descr = [@"" retain];
		_attachmenthash = [@"" retain];
		_lastUpdateTS = [[VLDate date] retain];
	}
	return self;
}

- (NSString *)dbTableName {
	return kYTDbTableResource;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"attachmentId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyAttachmentId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"attachmentCategoryId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyAttachmentCategoryId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"attachmentTypeName"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyAttachmentTypeName
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"s3StorageUUID"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyS3StorageUUID
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"filename"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyFilename
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"descr"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyDescription
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"isThumbnail"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyIsThumbnail
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"parentAttachmentId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyParentAttachmentId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"attachmenthash"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyAttachmenthash
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"lastUpdateTS"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyLastUpdateTS
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
}

- (void)setModified:(BOOL)modified {
	if(self.modified != modified && modified) {
		int idebug=0;
		idebug++;
	}
	[super setModified:modified];
}

- (void)setAttachmentId:(int64_t)attachmentId {
	if(_attachmentId != attachmentId) {
		_attachmentId = attachmentId;
		//self.modified = YES;
		self.needSave = YES;
		//self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setAttachmentCategoryId:(int64_t)attachmentCategoryId {
	if(_attachmentCategoryId != attachmentCategoryId) {
		_attachmentCategoryId = attachmentCategoryId;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setAttachmentTypeName:(NSString *)attachmentTypeName {
	if(!attachmentTypeName)
		attachmentTypeName = @"";
	if(![_attachmentTypeName isEqual:attachmentTypeName]) {
		[_attachmentTypeName release];
		_attachmentTypeName = [attachmentTypeName copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setS3StorageUUID:(NSString *)s3StorageUUID {
	if(!s3StorageUUID)
		s3StorageUUID = @"";
	if(![_s3StorageUUID isEqual:s3StorageUUID]) {
		[_s3StorageUUID release];
		_s3StorageUUID = [s3StorageUUID copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setFilename:(NSString *)filename {
	if(!filename)
		filename = @"";
	if(![_filename isEqual:filename]) {
		[_filename release];
		_filename = [filename copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setDescr:(NSString *)descr {
	if(!descr)
		descr = @"";
	if(![_descr isEqual:descr]) {
		[_descr release];
		_descr = [descr copy];
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setIsThumbnail:(BOOL)isThumbnail {
	if(_isThumbnail != isThumbnail) {
		_isThumbnail = isThumbnail;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setParentAttachmentId:(int64_t)parentAttachmentId {
	if(_parentAttachmentId != parentAttachmentId) {
		_parentAttachmentId = parentAttachmentId;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setAttachmenthash:(NSString *)attachmenthash {
	if(!attachmenthash)
		attachmenthash = @"";
	if(![_attachmenthash isEqual:attachmenthash]) {
		[_attachmenthash release];
		_attachmenthash = [attachmenthash copy];
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

- (void)assignDataFrom:(YTResourceInfo *)other {
	[super assignDataFrom:other];
	self.attachmentId = other.attachmentId;
	self.attachmentCategoryId = other.attachmentCategoryId;
	self.attachmentTypeName = other.attachmentTypeName;
	self.s3StorageUUID = other.s3StorageUUID;
	self.filename = other.filename;
	self.descr = other.descr;
	self.isThumbnail = other.isThumbnail;
	self.parentAttachmentId = other.parentAttachmentId;
	self.attachmenthash = other.attachmenthash;
	self.lastUpdateTS = other.lastUpdateTS;
}

- (NSComparisonResult)compareIdentityTo:(YTResourceInfo *)other {
	if(self.attachmentId != other.attachmentId)
		return (self.attachmentId - other.attachmentId < 0) ? -1 : 1;
	return 0;
}

- (NSComparisonResult)compareDataTo:(YTResourceInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.attachmentId != other.attachmentId)
		return (self.attachmentId < other.attachmentId) ? -1 : 1;
	if(self.attachmentCategoryId != other.attachmentCategoryId)
		return self.attachmentCategoryId - other.attachmentCategoryId;
	if([self.attachmentTypeName compare:other.attachmentTypeName])
		return [self.attachmentTypeName compare:other.attachmentTypeName];
	if([self.s3StorageUUID compare:other.s3StorageUUID])
		return [self.s3StorageUUID compare:other.s3StorageUUID];
	if([self.filename compare:other.filename])
		return [self.filename compare:other.filename];
	if([self.descr compare:other.descr])
		return [self.descr compare:other.descr];
	if(self.isThumbnail != other.isThumbnail)
		return (int)self.isThumbnail - (int)other.isThumbnail;
	if(self.parentAttachmentId != other.parentAttachmentId)
		return (self.parentAttachmentId - other.parentAttachmentId) ? -1 : 1;
	if([self.attachmenthash compare:other.attachmenthash])
		return [self.attachmenthash compare:other.attachmenthash];
	if([self.lastUpdateTS compare:other.lastUpdateTS])
		return [self.lastUpdateTS compare:other.lastUpdateTS];
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.attachmentId = [data int64ValueForKey:kYTJsonKeyAttachmentId defaultVal:0];
	self.attachmentCategoryId = [data int64ValueForKey:kYTJsonKeyAttachmentCategoryId defaultVal:0];
	self.attachmentTypeName = [data stringValueForKey:kYTJsonKeyAttachmentTypeName defaultVal:@""];
	self.s3StorageUUID = [data stringValueForKey:kYTJsonKeyS3StorageUUID defaultVal:@""];
	NSString *filename = [data stringValueForKey:kYTJsonKeyFilename defaultVal:@""];
	if(urlDecode)
		filename = [[YTNoteHtmlParser shared] urlDecode:filename];
	self.filename = filename;
	NSString *descr = [data stringValueForKey:kYTJsonKeyDescription defaultVal:@""];
	if(urlDecode)
		descr = [[YTNoteHtmlParser shared] urlDecode:descr];
	self.descr = descr;
	self.isThumbnail = [data yoditoBoolValueForKey:kYTJsonKeyIsThumbnail defaultVal:NO];
	self.parentAttachmentId = [data int64ValueForKey:kYTJsonKeyParentAttachmentId defaultVal:0];
	self.attachmenthash = [data stringValueForKey:kYTJsonKeyAttachmenthash defaultVal:@""];
	NSString *sLastUpdateTS = [data stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""];
	self.lastUpdateTS = [VLDate yoditoDateWithString:sLastUpdateTS];
}

- (BOOL)isImage {
	if([YTResourceTypeInfo infoByFileExt:_attachmentTypeName].categoryType == EYTResourceCategoryTypeImage)
		return YES;
	return NO;
}

- (BOOL)isVideo {
	if([YTResourceTypeInfo infoByFileExt:_attachmentTypeName].categoryType == EYTResourceCategoryTypeVideo)
		return YES;
	return NO;
}

- (BOOL)isAudio {
	if([YTResourceTypeInfo infoByFileExt:_attachmentTypeName].categoryType == EYTResourceCategoryTypeAudio)
		return YES;
	return NO;
}

- (BOOL)isWebDocViewable {
	BOOL bRes = [YTResourceTypeInfo isWebDocViewable:_attachmentTypeName];
	return bRes;
}

- (BOOL)isOtherType {
	BOOL bRes = [YTResourceTypeInfo isOtherType:_attachmentTypeName];
	return bRes;
}

+ (NSString *)entityName {
	return @"ATTACHMENT";
}

- (void)dealloc {
	[_attachmentTypeName release];
	[_s3StorageUUID release];
	[_filename release];
	[_descr release];
	[_attachmenthash release];
	[_lastUpdateTS release];
	[super dealloc];
}

@end

/*
 [{"AttachmentId":"3774","AttachmentCategoryId":"1","AttachmentTypeName":"png","LastUpdateTS":"2012-11-12 18:03:02",
 "S3StorageUUID":"57\/resources\/885D43B1-F4BC-68E7-79C2-62FCB0137DCD\/app_background_image.png",
 "Filename":"app_background_image.png","Description":"","IsThumbnail":0,"ParentAttachmentId":"",
 "Attachmenthash":"70359e81d2200e104c84284347786538"},
 {"AttachmentId":"3775","AttachmentCategoryId":"1",
 "AttachmentTypeName":"jpg","LastUpdateTS":"2012-11-12 18:03:03",
 "S3StorageUUID":"57\/thumb\/885D43B1-F4BC-68E7-79C2-62FCB0137DCD\/tmb.app_background_image.jpg",
 "Filename":"tmb.app_background_image.jpg","Description":"","IsThumbnail":"1","ParentAttachmentId":"3774",
 "Attachmenthash":"thm-70359e81d2200e104c84284347786538"}]
 */


