
#import <Foundation/Foundation.h>
#import "VLBaseView.h"

@interface VLTableColumnInfo : NSObject
{
@private
	NSString *_title;
	float _weight;
	UITextAlignment _textAlign;
	BOOL _isTextUnderlined;
}

@property(nonatomic, assign, setter = setTitle:) NSString *title;
@property(nonatomic, assign) float weight;
@property(nonatomic, assign) UITextAlignment textAlign;
@property(nonatomic, assign) BOOL isTextUnderlined;

- (id)initWithWeight:(float)weight title:(NSString*)title textAlign:(UITextAlignment)textAlign isTextUnderlined:(BOOL)isTextUnderlined;
- (id)initWithWeight:(float)weight title:(NSString*)title textAlign:(UITextAlignment)textAlign;

@end


@interface VLTableHeaderView : VLBaseView
{
	float _leftSpaceWeight;
	float _rightSpaceWeight;
	NSMutableArray *_columnsInfos;
	NSMutableArray *_labels;
	UIFont *_textFont;
	UIColor *_textColor;
}

@property(nonatomic, retain) UIColor *textColor;

- (void)setColumnsInfos:(NSArray*)columnsInfos
		leftSpaceWeight:(float)leftSpaceWeight
	   rightSpaceWeight:(float)rightSpaceWeight; // NSNumber, NSString
- (float)optimalHeight;

@end
