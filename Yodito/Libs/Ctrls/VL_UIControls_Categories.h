
#import <UIKit/UIKit.h>


@interface UIView(VL_UIView_Category)

@property(assign) BOOL visible;

- (void)roundCorners:(float)cornerRadius;

@end



@interface UIButton(VL_UIButton_Category)

- (void)setTitleForAllStates:(NSString*)title;
- (void)setImageForAllStates:(UIImage*)image;

@end



@interface UILabel(VL_UILabel_Category)

- (void)centerText;
- (CGSize)sizeOfText;
- (float)heightOfText;

@end



@interface UITableView(VL_UITableView_Category)

- (NSString*)emptyTableMessage;
- (void)setEmptyTableMessage: (NSString*) message;

- (void)setTransparentBackground;
- (void)deselectAllRowsAnimated:(BOOL)animated;
- (int)totalNumberOfRows;
- (void)flashRow:(NSIndexPath*)rowPath;

+ (NSArray*)lettersIndex_sectionIndexLetters;
+ (NSArray*)lettersIndex_splitObjects:(NSArray*)objects toLetterSectionsWithTitles:(NSArray*)titles resultLetters:(NSMutableArray*)resultLetters;
+ (NSInteger)lettersIndex_sectionIndexByLetter:(NSString*)letter sectionsTitles:(NSArray*)sectionsTitles;

- (void)updateRowsWithLastSections:(NSArray*)lastSections
					   newSections:(NSArray*)newSections
					resultSections:(NSMutableArray*)resultSections
	   allowMoveRowBetweenSections:(BOOL)allowMoveRowBetweenSections
						  animated:(BOOL)animated
					  animatedRows:(BOOL)animatedRows;

- (void)updateRowsWithLastSections:(NSArray*)lastSections
					   newSections:(NSArray*)newSections
					resultSections:(NSMutableArray*)resultSections
	   allowMoveRowBetweenSections:(BOOL)allowMoveRowBetweenSections
						  animated:(BOOL)animated;

- (void)updateRowsWithLastSections:(NSArray*)lastSections
					   newSections:(NSArray*)newSections
					resultSections:(NSMutableArray*)resultSections
						  animated:(BOOL)animated;

- (void)updateRowsWithLastObjects:(NSArray*)lastObjects
					   newObjects:(NSArray*)newObjects
					resultObjects:(NSMutableArray*)resultObjects
						 animated:(BOOL)animated;

- (BOOL)isRowVisibleWithIndexPath:(NSIndexPath *)indexPath;

@end



@interface UITextView(VL_UITextView_Placeholder)

- (void)setPlaceholderText:(NSString*)text;
- (void)setPlaceholderFont:(UIFont*)font;

@end




@interface UITableViewCell(VL_UITableViewCell_Category)

- (void)makeTransparent;

@end



@interface UISearchBar(VL_UISearchBar_Category)

- (void)makeTransparent;

@end



@interface UIScreen(VLCategory)

// Round values to fit pixels
+ (CGPoint)roundPoint:(CGPoint)point;
+ (CGSize)roundSize:(CGSize)size;
+ (CGRect)roundRect:(CGRect)rect;

@end



@interface UIBarButtonItem(VL_UIBarButtonItem_Category)

- (id)initWithImage:(UIImage *)image title:(NSString*)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;

@end



@interface UIWebView(VL_UIWebView_Category)

- (void)makeTransparent;

@end





