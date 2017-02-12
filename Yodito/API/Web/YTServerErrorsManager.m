
#import "YTServerErrorsManager.h"


@interface YTServerErrorInfo : NSObject {
@private
	int _code;
	NSString *_type;
	int _messageId;
	NSString *_message;
}

@property(nonatomic, assign) int code;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, assign) int messageId;
@property(nonatomic, retain) NSString *message;

@end

@implementation YTServerErrorInfo

@synthesize code = _code;
@synthesize type = _type;
@synthesize messageId = _messageId;
@synthesize message = _message;

@end



static YTServerErrorsManager *_shared;

@implementation YTServerErrorsManager

+ (YTServerErrorsManager *)shared {
	if(!_shared)
		_shared = [[YTServerErrorsManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_mapMessageInfoById = [[NSMutableDictionary alloc] init];
		
		[self addMessageInfoWithCode:201 type:@"user error" messageId:10 message:@"Authentication failure"];
		[self addMessageInfoWithCode:201 type:@"user error" messageId:11 message:@"Incorrect username or password"];
		[self addMessageInfoWithCode:201 type:@"user error" messageId:12 message:@"An account with this email address already exists."];
		[self addMessageInfoWithCode:202 type:@"system error" messageId:31 message:@"Synchronization failure. This may be due to a network problem or service maintenance."];
		[self addMessageInfoWithCode:203 type:@"not found exception" messageId:51 message:@"Synchronization failure. This may be due to a network problem or service maintenance."];
		[self addMessageInfoWithCode:204 type:@"unhandled error" messageId:71 message:@"Could not process your request. try again"];
		[self addMessageInfoWithCode:202 type:@"System error" messageId:1 message:@"Synchronization failure. This may be due to a network problem or service maintenance."];
		[self addMessageInfoWithCode:203 type:@"Not found exception" messageId:1 message:@"Synchronization failure. This may be due to a network problem or service maintenance."];
		[self addMessageInfoWithCode:204 type:@"Unhandled error" messageId:2 message:@"An account with this email address already exists."];
		[self addMessageInfoWithCode:204 type:@"Unhandled error" messageId:3 message:@"Invalid argument"];
		//1: system  - 202 - ; text as: "Synchronization failure. This may be due to a network problem or service maintenance."
		//2: resource not found - 203 - ;  text as: "Synchronization failure. This may be due to a network problem or service maintenance."
		//3: user related "sign in"  - 204 -; text as: "Incorrect username or password"
		//4: user related "create account"  - 205 ; text as: "An account with this email address already exists."

	}
	return self;
}

- (void)addMessageInfoWithCode:(int)code type:(NSString *)type messageId:(int)messageId message:(NSString *)message {
	YTServerErrorInfo *info = [[[YTServerErrorInfo alloc] init] autorelease];
	info.code = code;
	info.type = type;
	info.messageId = messageId;
	info.message = message;
	[_mapMessageInfoById setObject:info forKey:[NSNumber numberWithInt:info.messageId]];
}

- (NSString *)getMessageById:(int)messageId {
	YTServerErrorInfo *info = [_mapMessageInfoById objectForKey:[NSNumber numberWithInt:messageId]];
	if(info) {
		NSString *message = NSLocalizedString(info.message, nil);
		return message;
	} else
		return nil;
}

- (void)dealloc {
	[_mapMessageInfoById release];
	[super dealloc];
}

@end

