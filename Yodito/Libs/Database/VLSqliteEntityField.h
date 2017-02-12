
#import <Foundation/Foundation.h>
#import "VLDbCommon.h"
#import "../Common/Classes.h"

@interface VLSqliteEntityField : NSObject {
@private
	NSString *_selectorGetName;
	SEL _selectorGet;
	SEL _selectorSet;
	EVLSqliteEntityAttrType _attrType;
	NSString *_fieldName;
	EVLSqliteFieldTypeFlag _fieldFlags;
}

@property(nonatomic, readonly) NSString *selectorGetName;
@property(nonatomic, readonly) SEL selectorGet;
@property(nonatomic, readonly) SEL selectorSet;
@property(nonatomic, readonly) EVLSqliteEntityAttrType attrType;
@property(nonatomic, readonly) NSString *fieldName;
@property(nonatomic, readonly) EVLSqliteFieldTypeFlag fieldFlags;

- (id)initWithSelectorGetName:(NSString *)getName
					 attrType:(EVLSqliteEntityAttrType)attrType
					fieldName:(NSString *)fieldName
				   fieldFlags:(EVLSqliteFieldTypeFlag)fieldFlags;

@end
