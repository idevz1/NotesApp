
#import "VLSqliteEntityField.h"

@implementation VLSqliteEntityField

@synthesize selectorGetName = _selectorGetName;
@synthesize selectorGet = _selectorGet;
@synthesize selectorSet = _selectorSet;
@synthesize attrType = _attrType;
@synthesize fieldName = _fieldName;
@synthesize fieldFlags = _fieldFlags;

- (id)initWithSelectorGetName:(NSString *)getName
					 attrType:(EVLSqliteEntityAttrType)attrType
					fieldName:(NSString *)fieldName
				   fieldFlags:(EVLSqliteFieldTypeFlag)fieldFlags {
	self = [super init];
	if(self) {
		_selectorGetName = [getName copy];
		_selectorGet = NSSelectorFromString(_selectorGetName);
		_selectorSet = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",
											 [[_selectorGetName substringToIndex:1] uppercaseString],
											 [_selectorGetName substringFromIndex:1]]);
		_attrType = attrType;
		_fieldName = [fieldName copy];
		_fieldFlags = fieldFlags;
	}
	return self;
}

- (void)dealloc {
	[_selectorGetName release];
	[_fieldName release];
	[super dealloc];
}

@end
