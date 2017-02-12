
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import <MapKit/MapKit.h>

@class YTLocationSuggestView;

@protocol YTLocationSuggestViewDelegate <NSObject>
@optional
- (void)locationSuggestView:(YTLocationSuggestView *)locationSuggestView placemarkSelected:(CLPlacemark *)placemark;
@end

@interface YTLocationSuggestView : YTBaseView <UITableViewDataSource, UITableViewDelegate> {
@private
	UITableView *_tableView;
	NSMutableArray *_placemarks;
	int _curSearchTicket;
	NSString *_searchText;
	NSObject<YTLocationSuggestViewDelegate> *_delegate;
}

@property(nonatomic, assign) NSObject<YTLocationSuggestViewDelegate> *delegate;

- (void)setSearchText:(NSString *)searchText;

@end

