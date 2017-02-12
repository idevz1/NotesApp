
#import <Foundation/Foundation.h>
#import "../../API/Classes.h"

@interface YTNotesDisplayParams : YTLogicObject {
@private
	NSString *_notebookGuid;
	EYTPriorityType _priorityType;
	NSString *_tagName;
}

@property(nonatomic, assign) NSString *notebookGuid;
@property(nonatomic, assign) EYTPriorityType priorityType;
@property(nonatomic, assign) NSString *tagName;

@end

