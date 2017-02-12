    
#import "VLLogger.h"

#define kDefaultMaxLogFileSizes (100*1024)
#define kMaxLogFilesCount 8
#define kLogFileNameFormat @"VLLogger%d.txt"
#define kPreserveLastSessionFiles YES//NO

#ifndef VLLOGGER_TRESHOLD_LEVEL
#define VLLOGGER_TRESHOLD_LEVEL 0
#endif

@implementation VLLogger

@synthesize logFileEnabled = _logFileEnabled;
@synthesize loggingDisabled = _loggingDisabled;

+ (VLLogger *)shared {
	static dispatch_once_t pred;
    static VLLogger *_shared = nil;
    dispatch_once(&pred, ^{
        _shared = [[VLLogger alloc] init];
    });
    return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_logThreshold = VLLOGGER_TRESHOLD_LEVEL;
        _async = FALSE;
		_curLogFileIndex = -1;
		_maxLogFileSize = ceil(kDefaultMaxLogFileSizes / (double)kMaxLogFilesCount);
		_arrMsgToWriteToFile = [[NSMutableArray alloc] init];
		_curLogFileLock = [[NSObject alloc] init];
	}
	return self;
}

- (id)retain {
	return self;
}

- (oneway void)release {
	
}

- (id)autorelease {
	return self;
}

- (void)enableLoggingToFile {
	if(_logFileEnabled)
		return;
	_logFileEnabled = YES;
	_timer = [[NSTimer scheduledTimerWithTimeInterval:0.5
											   target:self
											 selector:@selector(timerEvent:)
											 userInfo:nil
											  repeats:YES] retain];
	NSString *tempDir = NSTemporaryDirectory();
	if(kPreserveLastSessionFiles) {
		NSArray *allFiles = [self subItemsInDirectory:tempDir getFiles:YES getDirs:NO error:nil];
		NSMutableSet *setAllFiles = [NSMutableSet setWithArray:allFiles];
		NSMutableArray *arrFiles = [NSMutableArray array];
		for(int i = 0; i < kMaxLogFilesCount; i++) {
			NSString *path = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:kLogFileNameFormat, i]];
			if([setAllFiles containsObject:path])
				[arrFiles addObject:path];
		}
		[arrFiles sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
			NSDate *date1 = [self modifiedDate:obj1];
			NSDate *date2 = [self modifiedDate:obj2];
			return [date1 compare:date2];
		}];
		NSString *lastPath = arrFiles.lastObject;
		if(lastPath) {
			NSString *str = [[lastPath lastPathComponent] stringByDeletingPathExtension];
			str = [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:kLogFileNameFormat]];
			NSScanner *scan = [[[NSScanner alloc] initWithString:str] autorelease];
			int lastLogFileIndex = -1;
			if([scan scanInt:&lastLogFileIndex] && lastLogFileIndex >= 0) {
				_curLogFileIndex = lastLogFileIndex;
			}
		}
		
	} else {
		for(int i = 0; i < kMaxLogFilesCount; i++) {
			NSString *path = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:kLogFileNameFormat, i]];
			if([self fileExists:path]) {
				[self deleteFileOrDir:path error:nil];
			}
		}
	}
	[self openNextFile];
}

- (void)setMaxLogFileSizes:(int)maxLogFileSizes {
	if(maxLogFileSizes > 0)
		_maxLogFileSize = ceil(maxLogFileSizes / (double)kMaxLogFilesCount);
}

- (void)openNextFile {
	if(_curLogFileHandle) {
		[_curLogFileHandle closeFile];
		[_curLogFileHandle release];
		_curLogFileHandle = nil;
	}
	int newLogFileIndex = _curLogFileIndex + 1;
	if(newLogFileIndex >= kMaxLogFilesCount)
		newLogFileIndex = 0;
	_curLogFileIndex = newLogFileIndex;
	NSString *tempDir = NSTemporaryDirectory();
	[_curLogFilePath release];
	_curLogFilePath = [[tempDir stringByAppendingPathComponent:[NSString stringWithFormat:kLogFileNameFormat, _curLogFileIndex]] retain];
	if([self fileExists:_curLogFilePath]) {
		[self deleteFileOrDir:_curLogFilePath error:nil];
	}
	if(![self fileExists:_curLogFilePath]) {
		[@"" writeToFile:_curLogFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
	_curLogFileHandle = [[NSFileHandle fileHandleForWritingAtPath:_curLogFilePath] retain];
}

- (BOOL)fileExists:(NSString*)filePath {
	BOOL isDir = false;
	BOOL bRes = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
	return bRes && !isDir;
}

- (BOOL)deleteFileOrDir:(NSString *)filePath error:(NSError **)pError {
	NSError *err = nil;
	BOOL bRes = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
	if(err && pError)
		*pError = err;
	return bRes;
}

- (int)fileSize:(NSString *)filePath {
	NSError *errAttrs = nil;
	NSDictionary* fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&errAttrs];
	if (fileAttr && !errAttrs) {
		id objFileType = [fileAttr objectForKey:NSFileType];
		if(objFileType) {
			if(objFileType == NSFileTypeDirectory) {
			} else {
				NSNumber *objFileSize = [fileAttr objectForKey:NSFileSize];
				if(objFileSize)
					return [objFileSize intValue];
			}
		}
	}
	return 0;
}

- (void)timerEvent:(id)sender {
	if(_logFileEnabled && _arrMsgToWriteToFile.count) {
		NSMutableArray *arrMsgToWriteToFile = [NSMutableArray array];
		@synchronized(_arrMsgToWriteToFile) {
			[arrMsgToWriteToFile addObjectsFromArray:_arrMsgToWriteToFile];
			[_arrMsgToWriteToFile removeAllObjects];
		}
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			@synchronized(_curLogFileLock) {
				int fileSize = (int)[_curLogFileHandle offsetInFile];
				if(fileSize >= _maxLogFileSize) {
					[self openNextFile];
				}
				for(NSString *msg in arrMsgToWriteToFile) {
					[_curLogFileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
				}
			}
		});
	}
}

- (void)writeLogMessageToFileQueue:(NSString *)msg {
	if(!_logFileEnabled)
		return;
	static NSDateFormatter *_dateFormatter;
	if(!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		_dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
	}
	NSString *msgWithTime = [NSString stringWithFormat:@"%@ %@\n", [_dateFormatter stringFromDate:[NSDate date]], msg];
	if([NSThread isMainThread]) {
		[_arrMsgToWriteToFile addObject:msgWithTime];
	} else {
		@synchronized(_arrMsgToWriteToFile) {
			[_arrMsgToWriteToFile addObject:msgWithTime];
		}
	}
}

- (void)writeLogMessage:(NSString *)msg {
	NSLog(@"%@", msg);
	if(_logFileEnabled) {
		[self writeLogMessageToFileQueue:msg];
	}
}

- (void)logWithLevel:(EVLLoggerLevel)level
		   className:(NSString *)className
		selectorName:(NSString *)selectorName
				line:(int)line
			 message:(NSString *)msg, ... {
	
	if(_loggingDisabled)
		return;
	const char* const levelName[6] = { "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "SILENT" };
	if((int)level < 0)
		level = 0;
	if(level > 5)
		level = 5;
	
	if(level >= _logThreshold) {
		va_list ap;
		va_start (ap, msg);
		NSString *msg1 = [[NSString alloc] initWithFormat:msg arguments:ap];
		va_end (ap);
		
		NSString *msg2 = [[NSString alloc] initWithFormat:@"%s: %@: %@: ln%d: %@", levelName[level], className, selectorName, line, msg1];
		
		if(_async) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				dispatch_async(dispatch_get_main_queue(), ^{
					[self writeLogMessage:msg2];
				});
			});
		} else {
			[self writeLogMessage:msg2];
		}
		
		[msg1 release];
		[msg2 release];
	}
}

- (NSData *)getSavedFileLogsData {
	NSMutableData *resultData = nil;
	@synchronized(_curLogFileLock) {
		int startFileIndex = _curLogFileIndex + 1;
		if(startFileIndex >= kMaxLogFilesCount)
			startFileIndex = 0;
		int allFilesSize = 0;
		for(int iStep = 0; iStep < 2; iStep++) {
			for(int i = 0; i < kMaxLogFilesCount; i++) {
				int fileIndex = startFileIndex + i;
				if(fileIndex >= kMaxLogFilesCount)
					fileIndex -= kMaxLogFilesCount;
				NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:kLogFileNameFormat, fileIndex]];
				if([self fileExists:path]) {
					if(iStep == 0) {
						if(fileIndex == _curLogFileIndex)
							[_curLogFileHandle synchronizeFile];
						int fileSize = [self fileSize:path];
						allFilesSize += fileSize;
					} else {
						if(!resultData)
							resultData = [[[NSMutableData alloc] initWithCapacity:allFilesSize + 10] autorelease];
						NSData *data = [[NSData alloc] initWithContentsOfFile:path];
						if(data) {
							[resultData appendData:data];
							[data release];
						}
					}
				}
			}
		}
	}
	if(!resultData)
		resultData = [NSMutableData data];
	return resultData;
}

- (NSArray *)subItemsInDirectory:(NSString *)dirPath getFiles:(BOOL)getFiles getDirs:(BOOL)getDirs error:(NSError **)error {
	NSMutableArray *filesResult = [NSMutableArray array];
	NSError *errorInt = nil;
	NSArray *allItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&errorInt];
	if(errorInt || !allItems) {
		if(error)
			*error = errorInt;
		return filesResult;
	}
	for(NSString *sName in allItems) {
		NSString *sFilePath = [dirPath stringByAppendingPathComponent:sName];
		NSError *errAttrs = nil;
		NSDictionary* fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:sFilePath error:&errAttrs];
		if (fileAttr && !errAttrs) {
			id objFileType = [fileAttr objectForKey:NSFileType];
			if(objFileType) {
				if(objFileType == NSFileTypeDirectory && getDirs)
					[filesResult addObject:sFilePath];
				else if(getFiles)
					[filesResult addObject:sFilePath];
			}
		}
	}
	return filesResult;
}

- (NSDate *)modifiedDate:(NSString *)path {
	if(!path || !path.length)
		return nil;
	NSError *errAttrs = nil;
	NSDictionary* fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&errAttrs];
	if (fileAttr && !errAttrs) {
		NSDate *date = [fileAttr objectForKey:NSFileModificationDate];
		return date;
	}
	return nil;
}

- (void)dealloc {
	[_arrMsgToWriteToFile release];
	[_curLogFileLock release];
	[super dealloc];
}

@end

