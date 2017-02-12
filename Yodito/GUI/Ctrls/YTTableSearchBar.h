
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTTableSearchBar;

@protocol YTTableSearchBarDelegate <NSObject>
@optional
- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchStarted:(id)param;
- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchEnded:(id)param;
- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchTextChanged:(NSString *)searchText;
- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchButtonTapped:(id)param;
- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar cancelButtonTapped:(id)param;
@end


@interface YTTableSearchBar : YTBaseView <UITextFieldDelegate> {
@private
	UIImageView *_imageMagnifier;
	UITextField *_textField;
	UIButton *_btnCancel;
	UIActivityIndicatorView *_activityView;
	BOOL _isEditing;
	NSObject<YTTableSearchBarDelegate> *_delegate;
	NSString *_searchText;
	BOOL _alwaysShowPlaceholder;
}

@property(nonatomic, assign) NSObject<YTTableSearchBarDelegate> *delegate;
@property(nonatomic, readonly) NSString *searchText;
@property(nonatomic, readonly) UITextField *textField;
@property(nonatomic, assign) NSString *placeholder;
@property(nonatomic, assign) BOOL alwaysShowPlaceholder;

+ (float)optimalHeight;
- (void)showActivity:(BOOL)show;
- (void)cancelSearching;
- (void)setEditing:(BOOL)isEditing;

@end




