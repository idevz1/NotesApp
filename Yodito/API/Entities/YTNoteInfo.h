
#import <Foundation/Foundation.h>
#import "YTEntityBase.h"

@interface YTNoteInfo : YTEntityBase {
@private
	NSString *_noteGuid;
	int64_t _notebookId;
	NSString *_notebookGuid;
	int _priorityId;
	int64_t _createdAt;
	NSString *_title; // urlencoded
	NSString *_contentLimited; // Local
	NSString *_contentToUpdateFromIPhone; // Local // urlencoded
	int _characters;
	int _words;
	VLDate *_createdDate;
	VLDate *_dueDate;
	VLDate *_endDate;
	BOOL _isValid;
	BOOL _hasAttachment;
	BOOL _hasTag;
	BOOL _hasLocation;
	VLDate *_lastUpdateTS;
	
	NSMutableDictionary *_mapNoteChanges; // Local in entity
}

@property(nonatomic, assign) NSString *noteGuid;
@property(nonatomic, assign) int64_t notebookId;
@property(nonatomic, assign) NSString *notebookGuid;
@property(nonatomic, assign) int priorityId;
@property(nonatomic, assign) int64_t createdAt;
@property(nonatomic, assign) NSString *title;
@property(nonatomic, assign) NSString *contentLimited;
@property(nonatomic, assign) NSString *contentToUpdateFromIPhone;
@property(nonatomic, assign) int characters;
@property(nonatomic, assign) int words;
@property(nonatomic, assign) VLDate *createdDate;
@property(nonatomic, assign) VLDate *dueDate;
@property(nonatomic, assign) VLDate *endDate;
@property(nonatomic, assign) BOOL isValid;
@property(nonatomic, assign) BOOL hasAttachment;
@property(nonatomic, assign) BOOL hasTag;
@property(nonatomic, assign) BOOL hasLocation;
@property(nonatomic, assign) VLDate *lastUpdateTS;
@property(nonatomic, readonly) NSDictionary *mapNoteChanges; // Local in entity

+ (void)startDebugIgnoreDetectTimestampChanges;
+ (void)stopDebugIgnoreDetectTimestampChanges;

- (NSString *)dbTableName;
- (void)onCreateFieldsList:(NSMutableArray *)fields;

- (void)assignDataFrom:(YTNoteInfo *)other;
- (NSComparisonResult)compareIdentityTo:(YTNoteInfo *)other;
- (NSComparisonResult)compareDataTo:(YTNoteInfo *)other;
- (void)loadFromData:(NSDictionary *)data urlDecode:(BOOL)urlDecode;

- (BOOL)hasEndDate;
- (void)getDueDate:(VLDateNoTime **)ppDueDateNoTime dueTime:(VLTime **)ppDueTime endDate:(VLDate **)ppEndDate;
- (void)setDueDate:(VLDateNoTime *)dueDateNoTime dueTime:(VLTime *)dueTime endDate:(VLDate *)endDate;

- (NSString *)titlePlaceholder;

+ (NSString *)getContentLimitedWithContent:(NSString *)content wordsCount:(int *)pWordsCount charsCount:(int *)pCharsCount;

@end


@interface YTNoteInfoArgs : VLCancelEventArgs {
@private
}

@property(nonatomic, retain) YTNoteInfo *note;

@end



