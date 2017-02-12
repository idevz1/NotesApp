
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import <MapKit/MapKit.h>
#import "../Ctrls/Classes.h"
#import "YTLocationSuggestView.h"

@class YTMapSearchView;

@protocol YTMapSearchViewDelegate <NSObject>
@required
- (void)mapSearchView:(YTMapSearchView *)mapSearchView finishWithAction:(EYTUserActionType)action;

@end

@interface YTMapSearchView_OverlayView : YTBaseView {
@private
}

@end

@interface YTMapSearchView : YTBaseView <MKMapViewDelegate, UISearchBarDelegate, YTLocationSuggestViewDelegate> {
@private
	MKMapView *_mapView;
	UISearchBar *_searchBar;
	UIToolbar *_toolbar;
	UIBarButtonItem *_bbiUseThisLoc;
	NSObject<YTMapSearchViewDelegate> *_delegate;
	int _curSearchTicket;
	BOOL _updatedOnce;
	BOOL _curLocationShownOnce;
	VLTimer *_timer;
	VLLabel *_lbAddressText;
	BOOL _isSearching;
	YTMapSearchView_OverlayView *_overlayView;
	YTLocationSuggestView *_locationSuggestView;
}

@property(nonatomic, assign) NSObject<YTMapSearchViewDelegate> *delegate;

+ (void)getAddressFromCurrentLocationWithResultBlock:(void (^)(YTLocationInfo *resultLocation, NSError *error))resultBlock;
- (void)startGettingSuggestedLocation;

@end
