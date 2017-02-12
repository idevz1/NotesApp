
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

#define kYTNotebookIdDemo (-1)

@interface YTNotebookInfo : YTEntityBase {
@private
	int64_t _notebookId;
	NSString *_notebookGuid;
	int64_t _stackId;
	int64_t _colorId;
	NSString *_name; // urlencoded
	BOOL _visibility;
	BOOL _isDefault;
	VLDate *_lastUpdateTS;
}

@property(nonatomic, assign) int64_t notebookId;
@property(nonatomic, assign) NSString *notebookGuid;
@property(nonatomic, assign) int64_t stackId;
@property(nonatomic, assign) int64_t colorId;
@property(nonatomic, assign) NSString *name;
@property(nonatomic, assign) BOOL visibility;
@property(nonatomic, assign) BOOL isDefault;
@property(nonatomic, assign) VLDate *lastUpdateTS;

- (NSString *)dbTableName;
- (void)onCreateFieldsList:(NSMutableArray *)fields;

- (void)assignDataFrom:(YTNotebookInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTNotebookInfo *)other;
- (NSComparisonResult)compareDataTo:(YTNotebookInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

@end

/*
 Data Structure Name: 		Notebook
 Field Structure:
 
 NotebookGUID		String
 StackId			Int
 ColourId		Int
 LastUpdateTS		Timestamp
 Name			String

*/

