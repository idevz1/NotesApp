
#import <Foundation/Foundation.h>

@interface VLMultiParamArgs : NSObject {
@private
	NSObject *_objectParam1;
	NSObject *_objectParam2;
	BOOL _boolParam1;
	BOOL _boolParam2;
	int64_t _int64Param1;
	NSObject *_objectResult1;
}

@property(nonatomic, retain) NSObject *objectParam1;
@property(nonatomic, retain) NSObject *objectParam2;
@property(nonatomic, assign) BOOL boolParam1;
@property(nonatomic, assign) BOOL boolParam2;
@property(nonatomic, assign) int64_t int64Param1;
@property(nonatomic, retain) NSObject *objectResult1;

@end

