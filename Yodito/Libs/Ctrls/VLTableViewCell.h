
#import <Foundation/Foundation.h>

@interface VLTableViewCell : UITableViewCell
{
@private
	UIView *_subView;
	BOOL _canSubViewIndentRight;
}

@property(nonatomic, readonly) UIView *subView;
@property(nonatomic, assign) BOOL canSubViewIndentRight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithSubView:(UIView*)subView reuseIdentifier:(NSString *)reuseIdentifier;

@end
