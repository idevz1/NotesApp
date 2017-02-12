
#import <Foundation/Foundation.h>
#import "VLMessaging.h"

typedef enum
{
	EVLProcessingStateNone = 0,
	EVLProcessingStateProcessing,
	EVLProcessingStateCanceled,
	EVLProcessingStateSucceed,
	EVLProcessingStateFailed
}
EVLProcessingState;

@interface VLLogicObject : NSObject
{
	int64_t _version;
	VLMessenger *_msgrVersionChanged;
	VLLogicObject *_parent;
	EVLProcessingState _processingState;
}

@property(nonatomic, assign) int64_t version;
@property(nonatomic, readonly) VLMessenger* msgrVersionChanged;
@property(nonatomic, assign) VLLogicObject* parent;
@property(assign) EVLProcessingState processingState;
@property(readonly) BOOL processing;

- (void)modifyVersion;
- (void)onVersionChanged;
- (void)onParentChanged:(VLLogicObject*)lastParent;
- (void)resetParent:(VLLogicObject*)parent;

@end
