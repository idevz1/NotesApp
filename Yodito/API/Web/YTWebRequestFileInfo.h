
#import <Foundation/Foundation.h>

@interface YTWebRequestFileInfo : NSObject {
@private
	NSString *_filePath;
	NSString *_fileName;
	NSString *_contentType;
	NSString *_key;
}

@property(nonatomic, retain) NSString *filePath;
@property(nonatomic, retain) NSString *fileName;
@property(nonatomic, retain) NSString *contentType;
@property(nonatomic, retain) NSString *key;

@end

