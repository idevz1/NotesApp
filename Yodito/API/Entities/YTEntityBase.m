
#import "YTEntityBase.h"
#import "../Database/Classes.h"

static int _modifyingBreakpointDisabled = 0;

@implementation YTEntityBase

@synthesize isTemporary = _isTemporary;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

+ (void)setModifyingBreakpointDisabled {
	_modifyingBreakpointDisabled++;
}

+ (void)resetModifyingBreakpointDisabled {
	if(_modifyingBreakpointDisabled > 0)
		_modifyingBreakpointDisabled--;
}

- (void)onCreateFieldsList:(NSMutableArray *)fields {
	[super onCreateFieldsList:fields];
	[fields addObject:[[[VLSqliteEntityField alloc] initWithSelectorGetName:@"isTemporary"
																   attrType:EVLSqliteEntityAttrTypeBool
																  fieldName:kYTJsonKeyIsTemporary
																 fieldFlags:EVLSqliteFieldTypeFlagInteger] autorelease]];
}

- (void)setIsTemporary:(BOOL)isTemporary {
	if(self.isInDb)
		[[YTDatabaseManager shared] checkIsDatabaseThread];
	if(_isTemporary != isTemporary) {
		_isTemporary = isTemporary;
		self.needSave = YES;
		[self modifyVersion];
	}
}

- (void)setAdded:(BOOL)added {
	if(self.isInDb)
		[[YTDatabaseManager shared] checkIsDatabaseThread];
	if(added != self.added) {
		int idebug = 0;
		idebug++;
	}
	[super setAdded:added];
}

- (void)setModified:(BOOL)modified {
	if(self.isInDb)
		[[YTDatabaseManager shared] checkIsDatabaseThread];
	if(self.modified != modified && modified && self.parent && (_modifyingBreakpointDisabled == 0)) {
		int debug = 0;
		debug++;
	}
	[super setModified:modified];
}

- (void)setDeleted:(BOOL)deleted {
	if(self.isInDb)
		[[YTDatabaseManager shared] checkIsDatabaseThread];
	if(deleted != self.deleted) {
		int idebug = 0;
		idebug++;
	}
	[super setDeleted:deleted];
}

- (void)setNeedSave:(BOOL)needSave {
	if(self.isInDb)
		[[YTDatabaseManager shared] checkIsDatabaseThread];
	[super setNeedSave:needSave];
}

- (void)assignDataFrom:(YTEntityBase *)other {
	if(self.isInDb)
		[[YTDatabaseManager shared] checkIsDatabaseThread];
	[super assignDataFrom:other];
	self.isTemporary = other.isTemporary;
}

- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode {
	if(self.isInDb)
		[[YTDatabaseManager shared] checkIsDatabaseThread];
	[super loadFromData:data];
	self.isTemporary = [data yoditoBoolValueForKey:kYTJsonKeyIsTemporary defaultVal:NO];
}

- (void)loadFromData:(NSDictionary *)data {
	[self loadFromData:data urlDecode:NO];
}

- (NSComparisonResult)compareIdentityTo:(YTEntityBase *)other {
	return 0;
}

- (NSComparisonResult)compareValuesTo:(YTEntityBase *)other {
	return [self compareDataTo:other];
}

- (void)getData:(NSMutableDictionary *)data {
	[super getData:data];
	NSArray *fileds = [self dbFields];
	for(VLSqliteEntityField *field in fileds) {
		NSString *fieldName = field.fieldName;
		if([fieldName isEqual:kVLSqliteFieldKeyId])
			continue;
		EVLSqliteEntityAttrType attrType = field.attrType;
		id val = nil;
		if(attrType == EVLSqliteEntityAttrTypeString) {
			val = [self performSelector:field.selectorGet];
		} else if(attrType == EVLSqliteEntityAttrTypeInt) {
			val = [NSNumber numberWithInt:(int)[self performSelector:field.selectorGet]];
		} else if(attrType == EVLSqliteEntityAttrTypeDouble) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
										[[self class] instanceMethodSignatureForSelector:field.selectorGet]];
			[invocation setTarget:self];
			[invocation setSelector:field.selectorGet];
			[invocation invoke];
			double dblVal = 0;
			[invocation getReturnValue:&dblVal];
			val = [NSNumber numberWithDouble:dblVal];
		} else if(attrType == EVLSqliteEntityAttrTypeFloat) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
										[[self class] instanceMethodSignatureForSelector:field.selectorGet]];
			[invocation setTarget:self];
			[invocation setSelector:field.selectorGet];
			[invocation invoke];
			float fltVal = 0;
			[invocation getReturnValue:&fltVal];
			val = [NSNumber numberWithFloat:fltVal];
		} else if(attrType == EVLSqliteEntityAttrTypeInt64) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
										[[self class] instanceMethodSignatureForSelector:field.selectorGet]];
			[invocation setTarget:self];
			[invocation setSelector:field.selectorGet];
			[invocation invoke];
			int64_t retVal = 0;
			[invocation getReturnValue:&retVal];
			val = [NSNumber numberWithLongLong:retVal];
		} else if(attrType == EVLSqliteEntityAttrTypeBool) {
			val = [NSNumber numberWithInt:(int)[self performSelector:field.selectorGet]];
		} else if(attrType == EVLSqliteEntityAttrTypeDate) {
			VLDate *date = [self performSelector:field.selectorGet];
			val = [VLDbCommon stringFromDate:date];
		} else if(attrType == EVLSqliteEntityAttrTypeDateNoTime) {
			VLDateNoTime *date = [self performSelector:field.selectorGet];
			val = [VLDbCommon stringFromDateNoTime:date];
		} else if(attrType == EVLSqliteEntityAttrTypeTime) {
			VLTime *time = [self performSelector:field.selectorGet];
			val = [VLDbCommon stringFromTime:time];
		}
		if(val) {
			[data setObject:val forKey:fieldName];
		}
	}
}

- (NSString *)description {
	NSMutableString *descr = [NSMutableString string];
	[descr appendString:NSStringFromClass([self class])];
	[descr appendFormat:@" %ld", (unsigned long)self];
	NSMutableDictionary *data = [NSMutableDictionary dictionary];
	[self getData:data];
	[descr appendString:[[data JSONRepresentation] stringByReplacingOccurrencesOfString:@"\n" withString:@" "]];
	return descr;
}

+ (NSString *)entityName {
	return @"";
}

- (BOOL)isInDb {
	return (ObjectCast(self.parent, VLSqliteEntitiesManager) != nil);
}

- (void)setParent:(VLLogicObject *)parent {
	if(self.parent && !parent) {
		int idebug = 0;
		idebug++;
	}
	[super setParent:parent];
}

- (void)dealloc {
	[super dealloc];
}

@end

