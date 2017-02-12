
#import "VLFileManager.h"
#import "../Common/Classes.h"

@implementation VLFileManager

+ (VLFileManager*)shared
{
	static VLFileManager *_shared = nil;
	if(!_shared)
		_shared = [[VLFileManager alloc] init];
	return _shared;
}

- (id)init
{
	self = [super init];
	if(self)
	{
		
	}
	return self;
}

- (BOOL)dirExists:(NSString*)dirPath
{
	BOOL isDir = false;
	BOOL bRes = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
	return bRes && isDir;
}

- (BOOL)fileExists:(NSString*)filePath
{
	BOOL isDir = false;
	BOOL bRes = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
	return bRes && !isDir;
}

- (BOOL)createDir:(NSString *)dirPath andAnySubDir:(BOOL)createSubDirs error:(NSError **)pError
{
	NSError *err = nil;
	BOOL bRes = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
						  withIntermediateDirectories:createSubDirs
										   attributes:nil
												error:&err];
	if(err && pError)
		*pError = err;
	return bRes;
}

- (BOOL)forceDir:(NSString *)dirPath error:(NSError **)pError
{
	if([self dirExists:dirPath])
		return YES;
	return [self createDir:dirPath andAnySubDir:YES error:pError];
}

- (BOOL)deleteFileOrDir:(NSString *)filePath error:(NSError **)pError
{
	NSError *err = nil;
	BOOL bRes = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
	if(err && pError)
		*pError = err;
	return bRes;
}

- (NSArray *)subItemsInDirectory:(NSString *)dirPath getFiles:(BOOL)getFiles getDirs:(BOOL)getDirs error:(NSError **)error
{
	NSMutableArray *filesResult = [NSMutableArray array];
	NSError *errorInt = nil;
	NSArray *allItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&errorInt];
	if(errorInt || !allItems)
	{
		if(errorInt && kVLLogErrors)
			NSLog(@"ERROR: VLFileManager: subItemsInDirectory: \"%@\" - %@", dirPath, [errorInt localizedDescription]);
		if(error)
			*error = errorInt;
		return filesResult;
	}
	for(NSString *sName in allItems)
	{
		NSString *sFilePath = [dirPath stringByAppendingPathComponent:sName];
		NSError *errAttrs = nil;
		NSDictionary* fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:sFilePath error:&errAttrs];
		if (fileAttr && !errAttrs)
		{
			id objFileType = [fileAttr objectForKey:NSFileType];
			if(objFileType)
			{
				if(objFileType == NSFileTypeDirectory && getDirs)
					[filesResult addObject:sFilePath];
				else if(getFiles)
					[filesResult addObject:sFilePath];
			}
		}
	}
	return filesResult;
}

- (NSArray *)filesInDirectory:(NSString *)dirPath error:(NSError **)error
{
	return [self subItemsInDirectory:dirPath getFiles:YES getDirs:NO error:error];
}

- (NSArray *)subDirsInDirectory:(NSString *)dirPath error:(NSError **)error
{
	return [self subItemsInDirectory:dirPath getFiles:NO getDirs:YES error:error];
}

- (NSDate *)modifiedDate:(NSString *)path
{
	if([NSString isEmpty:path])
		return nil;
	NSError *errAttrs = nil;
	NSDictionary* fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&errAttrs];
	if (fileAttr && !errAttrs)
	{
		NSDate *date = [fileAttr objectForKey:NSFileModificationDate];
		return date;
	}
	return nil;
}

- (void)setModifiedDate:(NSDate *)date toPath:(NSString *)path
{
	if(!date || [NSString isEmpty:path])
		return;
	NSError *err = nil;
	NSDictionary *attrs = [NSDictionary dictionaryWithObject:date forKey:NSFileModificationDate];
	[[NSFileManager defaultManager] setAttributes:attrs ofItemAtPath:path error:&err];
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

- (void)dealloc
{
	[super dealloc];
}

@end
