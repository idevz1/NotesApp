
#define kVLLogEvents YES
#define kVLLogWarnings YES
#define kVLLogErrors YES

#define ObjectCast(Obj,ClassName) ( (Obj && [Obj isKindOfClass:[ClassName class]]) ? ((ClassName*)Obj) : nil )

#define kIosVersionStr [[UIDevice currentDevice] systemVersion]
#define kIosVersionFloat [kIosVersionStr floatValue]

#import "VLLogger.h"
#define VLLogEvent(sEvent) {if(kVLLogEvents) VLLoggerDebug(@"%@", sEvent);}
#define VLLogError(sEvent) {if(kVLLogErrors) VLLoggerError(@"%@", sEvent);}
#define VLLogWarning(sEvent) {if(kVLLogWarnings) VLLoggerWarn(@"%@", sEvent);}

#define kDefaultAnimationDuration 0.35

#define kVLCurManagersVersion 2

typedef void (^VLBlockVoid)();
typedef void (^VLBlockBool)(BOOL result);
typedef void (^VLBlockObject)(id object);
typedef BOOL (^VLBlockCheck)();
typedef void (^VLBlockInt)(int value);
typedef void (^VLBlockError)(NSError *error);
typedef void (^VLBlockPError)(NSError **pError);

typedef enum
{
	EVLOrientationHorizontal,
	EVLOrientationVertical
}
EVLOrientation;

@protocol VLCancelable <NSObject>
@required
- (void)cancel;

@end


#define VLStaticProperty(Name, ValueClass, ParentClass)						\
+ (ValueClass*)get##Name##OrSet:(BOOL)set value:(ValueClass*)valueToSet		\
{																			\
	static ValueClass *_shared = nil;										\
	if(set && _shared != valueToSet)										\
	{																		\
		if(_shared)															\
			[_shared release];												\
		_shared = valueToSet;												\
		if(_shared)															\
			[_shared retain];												\
	}																		\
	return _shared;															\
}																			\
+ (ValueClass*)get##Name													\
{																			\
	return [ParentClass get##Name##OrSet:NO value:nil];						\
}																			\
+ (void)set##Name:(ValueClass*)value										\
{																			\
	[ParentClass get##Name##OrSet:YES value:value];							\
}

#define VLSharedProperty(Name, ValueClass)						\
- (ValueClass*)get##Name##OrSet:(BOOL)set value:(ValueClass*)valueToSet		\
{																			\
	static ValueClass *_shared = nil;										\
	if(set && _shared != valueToSet)										\
	{																		\
		if(_shared)															\
			[_shared release];												\
		_shared = valueToSet;												\
		if(_shared)															\
			[_shared retain];												\
	}																		\
	return _shared;															\
}																			\
- (ValueClass*)get##Name													\
{																			\
	return [self get##Name##OrSet:NO value:nil];							\
}																			\
- (void)set##Name:(ValueClass*)value										\
{																			\
	[self get##Name##OrSet:YES value:value];								\
}


