
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@class YTSearchTagView;

@protocol YTSearchTagViewDelegate <NSObject>
@required
- (void)searchTagView:(YTSearchTagView *)searchTagView finishWithAction:(EYTUserActionType)action;

@end

@interface YTSearchTagView : YTBaseView <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,
	VLKeyboardTableViewDelegate> {
@private
	NSMutableArray *_arrSuggestedTagsNames;
	NSMutableSet *_selectedTagNames;
	UISearchBar *_searchBar;
	UIView *_navigBar;
	UIButton *_btnSearchCancel;
	VLKeyboardTableView *_tableView;
	NSObject<YTSearchTagViewDelegate> *_delegate;
	BOOL _isSearching;
	BOOL _searchBarEditing;
	NSString *_searchText;
}

@property(nonatomic, assign) NSObject<YTSearchTagViewDelegate> *delegate;

- (NSArray *)getSelectedTags;

@end

