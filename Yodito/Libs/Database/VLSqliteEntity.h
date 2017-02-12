
#import <Foundation/Foundation.h>
#import "../Logic/Classes.h"
#import "VLSqliteEntityField.h"

@class VLSqliteEntity;

@interface VLSqliteEntityArgs : VLCancelEventArgs {
@private
	VLSqliteEntity *_entity;
}

@property(nonatomic, retain) VLSqliteEntity *entity;

@end


@interface VLSqliteEntity : VLLogicObject {
@private
	int64_t _nId;
	BOOL _modified;
	BOOL _added;
	BOOL _deleted;
	BOOL _needSave;
}

@property(nonatomic, assign) int64_t nId;
@property(nonatomic, assign) BOOL modified;
@property(nonatomic, assign) BOOL added;
@property(nonatomic, assign) BOOL deleted;
@property(nonatomic, assign) BOOL needSave;

- (NSString *)dbTableName;
- (NSArray *)dbFields; // Array of VLSqliteEntityField
- (void)onCreateFieldsList:(NSMutableArray *)fields;
- (void)loadFromData:(NSDictionary *)data;
- (void)getData:(NSMutableDictionary *)data;
- (void)assignDataFrom:(VLSqliteEntity *)other;
- (NSComparisonResult)compareIdentityTo:(VLSqliteEntity *)other;
- (NSComparisonResult)compareDataTo:(VLSqliteEntity *)other;

@end
