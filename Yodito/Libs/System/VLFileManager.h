
#import <Foundation/Foundation.h>

@interface VLFileManager : NSObject
{
	
}

+ (VLFileManager*)shared;

- (BOOL)dirExists:(NSString*)dirPath;
- (BOOL)fileExists:(NSString*)filePath;
- (BOOL)createDir:(NSString *)dirPath andAnySubDir:(BOOL)createSubDirs error:(NSError **)pError;
- (BOOL)forceDir:(NSString *)dirPath error:(NSError **)pError;
- (BOOL)deleteFileOrDir:(NSString *)filePath error:(NSError **)pError;
- (NSArray *)subItemsInDirectory:(NSString *)dirPath getFiles:(BOOL)getFiles getDirs:(BOOL)getDirs error:(NSError **)error;
- (NSArray *)filesInDirectory:(NSString *)dirPath error:(NSError **)error;
- (NSArray *)subDirsInDirectory:(NSString *)dirPath error:(NSError **)error;
- (NSDate *)modifiedDate:(NSString *)path;
- (void)setModifiedDate:(NSDate *)date toPath:(NSString *)path;
- (int)fileSize:(NSString *)filePath;

@end
