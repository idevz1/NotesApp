
#import <Foundation/Foundation.h>

#define VLLoggerTrace(args...) [[VLLogger shared] logWithLevel:EVLLoggerLevelTrace className:NSStringFromClass([self class]) selectorName:NSStringFromSelector(_cmd) line:__LINE__ message:args]
#define VLLoggerDebug(args...) [[VLLogger shared] logWithLevel:EVLLoggerLevelDebug className:NSStringFromClass([self class]) selectorName:NSStringFromSelector(_cmd) line:__LINE__ message:args]
#define VLLoggerWarn(args...) [[VLLogger shared] logWithLevel:EVLLoggerLevelWarn className:NSStringFromClass([self class]) selectorName:NSStringFromSelector(_cmd) line:__LINE__ message:args]
#define VLLoggerError(args...) [[VLLogger shared] logWithLevel:EVLLoggerLevelError className:NSStringFromClass([self class]) selectorName:NSStringFromSelector(_cmd) line:__LINE__ message:args]

typedef enum {
    EVLLoggerLevelTrace = 0,
	EVLLoggerLevelDebug = 1,
	EVLLoggerLevelInfo = 2,
	EVLLoggerLevelWarn = 3,
	EVLLoggerLevelError = 4,
	EVLLoggerLevelSilent = 5
} EVLLoggerLevel;

@interface VLLogger : NSObject {
@private
	int _logThreshold;
	BOOL _async;
	BOOL _logFileEnabled;
	int _curLogFileIndex;
	NSString *_curLogFilePath;
	NSFileHandle *_curLogFileHandle;
	NSMutableArray *_arrMsgToWriteToFile;
	NSTimer *_timer;
	int _maxLogFileSize;
	NSObject *_curLogFileLock;
	BOOL _loggingDisabled;
}

@property(nonatomic, readonly) BOOL logFileEnabled;
@property(nonatomic, assign) BOOL loggingDisabled;

+ (VLLogger *)shared;

- (void)enableLoggingToFile;
- (void)setMaxLogFileSizes:(int)maxLogFileSizes;

- (void)logWithLevel:(EVLLoggerLevel)level
		   className:(NSString *)className
		selectorName:(NSString *)selectorName
				line:(int)line
			 message:(NSString *)msg, ...;

- (NSData *)getSavedFileLogsData;

@end

