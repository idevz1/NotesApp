
#import <Foundation/Foundation.h>
#import "../Entities/Classes.h"

@interface YTNoteEditInfo : VLLogicObject {
@private
	BOOL _isNewNote;
	YTNoteInfo *_noteLast;
	YTNoteContentInfo *_noteContentLast;
	NSMutableArray *_tagsLast;
	NSMutableArray *_resourcesLast;
	YTLocationInfo *_locationLast;
	
	YTNoteInfo *_noteNew;
	YTNoteContentInfo *_noteContentNew;
	NSMutableArray *_tagsNew;
	NSMutableArray *_resourcesNew;
	YTLocationInfo *_locationNew;
}

@property(nonatomic, readonly) BOOL isNewNote;
@property(nonatomic, readonly) YTNoteInfo *noteLast;
@property(nonatomic, readonly) YTNoteContentInfo *noteContentLast;
@property(nonatomic, readonly) NSArray *resourcesLast;
@property(nonatomic, readonly) NSArray *tagsLast;
@property(nonatomic, readonly) YTLocationInfo *locationLast;
@property(nonatomic, readonly) YTNoteInfo *noteNew;
@property(nonatomic, readonly) YTNoteContentInfo *noteContentNew;
@property(nonatomic, readonly) NSArray *resourcesNew;
@property(nonatomic, readonly) NSArray *tagsNew;
@property(nonatomic, assign) YTLocationInfo *locationNew;

- (void)initializeWithNoteOriginal:(YTNoteInfo *)noteOriginal isNewNote:(BOOL)isNewNote resultBlock:(VLBlockVoid)resultBlock;
- (void)transformToNotNewNote;
- (void)applyChanges;
- (void)addTagNew:(YTTagInfo *)tagNew;
- (void)removeTagNew:(YTTagInfo *)tagNew;
- (void)replaceTagNew:(YTTagInfo *)tagNew withTag:(YTTagInfo *)tagNewNew;
- (void)moveTagLastToEnd:(YTTagInfo *)tagLast;
- (void)addResourceNew:(YTResourceInfo *)resNew;
- (void)removeResourceNew:(YTResourceInfo *)resNew;

@end




