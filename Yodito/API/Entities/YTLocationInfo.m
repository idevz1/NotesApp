
#import "YTLocationInfo.h"

@implementation YTLocationInfo

@synthesize locationId = _locationId;
@synthesize name = _name;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
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
	return kYTDbTableLocation;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"locationId"
																   attrType:EVLSqliteEntityAttrTypeInt64
																  fieldName:kYTJsonKeyLocationId
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"name"
																   attrType:EVLSqliteEntityAttrTypeString
																  fieldName:kYTJsonKeyName
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"latitude"
																   attrType:EVLSqliteEntityAttrTypeDouble
																  fieldName:kYTJsonKeyLatitude
																 fieldFlags:EVLSqliteFieldTypeFlagReal] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"longitude"
																   attrType:EVLSqliteEntityAttrTypeDouble
																  fieldName:kYTJsonKeyLongitude
																 fieldFlags:EVLSqliteFieldTypeFlagReal] autorelease]];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"lastUpdateTS"
																   attrType:EVLSqliteEntityAttrTypeDate
																  fieldName:kYTJsonKeyLastUpdateTS
																 fieldFlags:EVLSqliteFieldTypeFlagText] autorelease]];
}

- (void)setLocationId:(int64_t)locationId {
	if(_locationId != locationId) {
		_locationId = locationId;
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

- (void)setLatitude:(double)latitude {
	if(_latitude != latitude) {
		_latitude = latitude;
		self.modified = YES;
		self.needSave = YES;
		self.lastUpdateTS = [VLDate date];
		[self modifyVersion];
	}
}

- (void)setLongitude:(double)longitude {
	if(_longitude != longitude) {
		_longitude = longitude;
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

- (void)assignDataFrom:(YTLocationInfo *)other {
	[super assignDataFrom:other];
	self.locationId = other.locationId;
	self.name = other.name;
	self.latitude = other.latitude;
	self.longitude = other.longitude;
	self.lastUpdateTS = other.lastUpdateTS;
}

- (NSComparisonResult)compareIdentityTo:(YTLocationInfo *)other {
	if(self.locationId != other.locationId)
		return (self.locationId - other.locationId < 0) ? -1 : 1;
	return 0;
}

- (NSComparisonResult)compareDataTo:(YTLocationInfo *)other {
	if([super compareDataTo:other])
		return [super compareDataTo:other];
	if(self.locationId != other.locationId) {
		if(self.locationId < other.locationId)
			return -1;
		else if(self.locationId > other.locationId)
			return 1;
	}
	if([self.name compare:other.name])
		return [self.name compare:other.name];
	if(self.latitude != other.latitude)
		return (self.latitude - other.latitude > 0) ? 1 : -1;
	if(self.longitude != other.longitude)
		return (self.longitude - other.longitude > 0) ? 1 : -1;
	if([self.lastUpdateTS compare:other.lastUpdateTS])
		return [self.lastUpdateTS compare:other.lastUpdateTS];
	return 0;
}

- (NSComparisonResult)compareValuesTo:(YTLocationInfo *)other {
	if([self.name compare:other.name])
		return [self.name compare:other.name];
	if(self.latitude != other.latitude)
		return (self.latitude - other.latitude > 0) ? 1 : -1;
	if(self.longitude != other.longitude)
		return (self.longitude - other.longitude > 0) ? 1 : -1;
	return 0;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	[super loadFromData:data urlDecode:urlDecode];
	self.locationId = [data int64ValueForKey:kYTJsonKeyLocationId defaultVal:0];
	self.name = [data stringValueForKey:kYTJsonKeyName defaultVal:@""];
	self.latitude = [data doubleValueForKey:kYTJsonKeyLatitude defaultVal:0];
	self.longitude = [data doubleValueForKey:kYTJsonKeyLongitude defaultVal:0];
	NSString *sLastUpdateTS = [data stringValueForKey:kYTJsonKeyLastUpdateTS defaultVal:@""];
	self.lastUpdateTS = [VLDate yoditoDateWithString:sLastUpdateTS];
}

- (void)dealloc {
	[_name release];
	[_lastUpdateTS release];
	[super dealloc];
}

@end

