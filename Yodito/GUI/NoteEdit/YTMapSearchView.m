
#import "YTMapSearchView.h"
#import "../Main/Classes.h"
#import "AppDelegate.h"
#define kBarBackColor [UIColor colorWithRed:201/255.0 green:201/255.0 blue:206/255.0 alpha:1.0]


@interface YTMapSearchView_Annotation : NSObject <MKAnnotation> {
@private
	YTLocationInfo *_locationInfo;
	CLLocationCoordinate2D _lastCoord;
}

@property(nonatomic, assign) YTLocationInfo *locationInfo;

@end

@implementation YTMapSearchView_Annotation

- (void)setLocationInfo:(YTLocationInfo *)locationInfo {
	if(_locationInfo != locationInfo) {
		if(_locationInfo) {
			[_locationInfo.msgrVersionChanged removeObserver:self];
			[_locationInfo release];
		}
		_locationInfo = locationInfo;
		if(_locationInfo) {
			[_locationInfo retain];
			[_locationInfo.msgrVersionChanged addObserver:self selector:@selector(onLocationInfoDataChanged:)];
			[self onLocationInfoDataChanged];
		}
	}
}

- (void)onLocationInfoDataChanged:(id)sender {
	[self onLocationInfoDataChanged];
}

- (void)onLocationInfoDataChanged {
	if(_locationInfo) {
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(_locationInfo.latitude, _locationInfo.longitude);
		if(coord.latitude != _lastCoord.latitude || coord.longitude != _lastCoord.longitude) {
			_lastCoord = coord;
			[self setCoordinate:_lastCoord];
		}
	}
}

- (NSString *)title {
	if(_locationInfo)
		return _locationInfo.name;
	return @"";
}

- (NSString *)subtitle {
	return nil;
}

- (CLLocationCoordinate2D)coordinate {
	return _lastCoord;
}
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	
}

- (void)dealloc {
	self.locationInfo = nil;
	[super dealloc];
}

@end




@implementation YTMapSearchView_OverlayView

- (void)initialize {
	[super initialize];
	self.opaque = NO;
	self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(self.alpha == 0)
		return nil;
	return [super hitTest:point withEvent:event];
}

@end





@implementation YTMapSearchView

@synthesize delegate = _delegate;

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTViewBackColor;
	
	_mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
	_mapView.delegate = self;
	_mapView.showsUserLocation = YES;
	[self addSubview:_mapView];
	
	_searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
	_searchBar.delegate = self;
	_searchBar.placeholder = NSLocalizedString(@"Search {Button}", nil);
	//_searchBar.showsCancelButton = YES;
	[self addSubview:_searchBar];
	
	_bbiUseThisLoc = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Use this location", nil) style:UIBarButtonItemStyleBordered
													 target:self action:@selector(onBtnUseThisLocationTap:)];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	[self addSubview:_toolbar];
	_toolbar.items = [NSArray arrayWithObjects:
					  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																	 target:nil action:nil] autorelease],
					  _bbiUseThisLoc,
					  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																	 target:nil action:nil] autorelease],
					  nil];
	
	_lbAddressText = [[VLLabel alloc] initWithFrame:CGRectZero];
	_lbAddressText.hidden = YES;
	[_lbAddressText centerText];
	_lbAddressText.numberOfLines = 0;
	_lbAddressText.adjustsFontSizeToFitWidthMultiLine = YES;
	_lbAddressText.backgroundColor = [UIColor colorWithRed:50/255.0 green:49/255.0 blue:45/255.0 alpha:1.0];
	_lbAddressText.textColor = [UIColor colorWithWhite:0xF8/255.0 alpha:1.0];
	[self addSubview:_lbAddressText];
	
	_overlayView = [[YTMapSearchView_OverlayView alloc] initWithFrame:CGRectZero];
	_overlayView.alpha = 0;
	[self addSubview:_overlayView];
	[_overlayView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSearchOverlayViewTap:)] autorelease]];
	
	_locationSuggestView = [[YTLocationSuggestView alloc] initWithFrame:CGRectZero];
	_locationSuggestView.hidden = YES;
	_locationSuggestView.delegate = self;
	[self addSubview:_locationSuggestView];
	
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Location", nil);
	self.customNavBar.btnBack.hidden = NO;
	//[self.customNavBar.btnBack setTitle:NSLocalizedString(@"Cancel {Button}", nil) forState:UIControlStateNormal];
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[self updateViewAsync];
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 1.0;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	[_timer start];
}

- (void)updateFonts:(id)sender {
	_lbAddressText.font = [[YTFontsManager shared] fontWithSize:15 fixed:YES];
	[self setNeedsLayout];
}

- (YTMapSearchView_Annotation *)curAnnotation {
	NSArray *annotations = [NSArray arrayWithArray:[_mapView annotations]];
	YTMapSearchView_Annotation *curAnnot = nil;
	for(NSObject *obj in annotations) {
		curAnnot = ObjectCast(obj, YTMapSearchView_Annotation);
		if(curAnnot)
			break;
	}
	return curAnnot;
}

- (void)onUpdateView {
	[super onUpdateView];
	YTLocationInfo *location = self.locationInfo;
	YTMapSearchView_Annotation *curAnnot = [self curAnnotation];
	if(location && location.latitude && location.longitude) {
		if(!curAnnot) {
			curAnnot = [[[YTMapSearchView_Annotation alloc] init] autorelease];
			curAnnot.locationInfo = location;
			[_mapView addAnnotation:curAnnot];
		}
		curAnnot.locationInfo = location;
	} else {
		if(curAnnot)
			[_mapView removeAnnotation:curAnnot];
	}
	if(!_updatedOnce) {
		_updatedOnce = YES;
		//_searchBar.text = self.locationInfo ? self.locationInfo.name : @"";
		[[VLMessageCenter shared] performBlock:^{
			[self showFoundPin];
		} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
	}
	
	if(!_curLocationShownOnce) {
		if(!location || !location.latitude || !location.longitude) {
			if(_mapView.userLocation && _mapView.userLocation.coordinate.latitude && _mapView.userLocation.coordinate.longitude) {
				MKCoordinateRegion region;
				region.center = _mapView.userLocation.coordinate;
				MKCoordinateSpan span;
				span.latitudeDelta = span.longitudeDelta = 0.01;
				region.span = span;
				[_mapView setRegion:region animated:YES];
				_curLocationShownOnce = YES;
			}
		}
	}
	
	if(self.locationInfo && ![NSString isEmpty:self.locationInfo.name]) {
		_lbAddressText.hidden = NO;
		_lbAddressText.text = self.locationInfo.name;
	} else {
		_lbAddressText.hidden = YES;
		_lbAddressText.text = @"";
	}
	
	_bbiUseThisLoc.enabled = self.locationInfo && self.locationInfo.latitude;
	
	[self setNeedsLayout];
}

- (void)onTimerEvent:(id)sender {
	[self updateViewAsync];
}

- (void)showFoundPin {
	YTMapSearchView_Annotation *curAnnot = [self curAnnotation];
	if(curAnnot) {
		YTLocationInfo *location = curAnnot.locationInfo;
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(location.latitude, location.longitude);
		MKCoordinateRegion region;
		region.center = coord;
		CLLocationDegrees delta = 0.01;
		region.span = MKCoordinateSpanMake(delta, delta);
		[_mapView setRegion:region animated:YES];
	}
}

- (void)onLocationInfoDataChanged {
	[super onLocationInfoDataChanged];
	[self updateViewAsync];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	CGRect rcSearch = rcBnds;
	rcSearch.origin.y -= 1; // Hide top separator.
	rcSearch.size.height = [_searchBar sizeThatFits:rcSearch.size].height;
	CGRect rcTB = rcBnds;
	rcTB.size.height = [_toolbar sizeThatFits:rcTB.size].height;
	rcTB.origin.y = CGRectGetMaxY(rcBnds) - rcTB.size.height;
	_toolbar.frame = rcTB;
	
	_lbAddressText.visible = self.locationInfo && ![NSString isEmpty:self.locationInfo.name];
	CGRect rcAddrText = rcBnds;
	if(!_lbAddressText.hidden)
		rcAddrText.size.height = 50;
	else
		rcAddrText.size.height = 0;
	rcAddrText.origin.y = rcTB.origin.y - rcAddrText.size.height;
	_lbAddressText.frame = rcAddrText;
	
	CGRect rcMap = rcBnds;
	rcMap.origin.y = CGRectGetMaxY(rcSearch);
	rcMap.size.height = rcAddrText.origin.y - rcMap.origin.y;
	_searchBar.frame = rcSearch;
	_mapView.frame = rcMap;
	_overlayView.frame = rcMap;
	_locationSuggestView.frame = rcMap;
}

- (void)startSearchWithText:(NSString *)searchText {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	int curSearchTicket = ++_curSearchTicket;
	
	YTLocationInfo *location = self.locationInfo;
	if(!location) {
		location = [[[YTLocationInfo alloc] init] autorelease];
		self.locationInfo = location;
	}
	location.name = searchText;
	location.latitude = 0;
	location.longitude = 0;
	[self updateViewAsync];
	
	NSString *searchTextEscaped = searchText;//[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if(!searchTextEscaped)
		searchTextEscaped = @"";
	
	[[VLAppDelegateBase sharedAppDelegateBase] startAnimateNetworkActivityIndicator];
	CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
	[geocoder geocodeAddressString:searchTextEscaped completionHandler:^(NSArray *placemarks, NSError *error)
	{
		[[VLAppDelegateBase sharedAppDelegateBase] stopAnimateNetworkActivityIndicator];
		if(curSearchTicket != _curSearchTicket)
			return;
		if(error) {
			VLLogError(error);
			NSInteger errorCode = error.code;
			BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
			CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
			if(!locationServicesEnabled)
				error = [NSError makeWithText:NSLocalizedString(@"Location services have not been enabled! Update your settings.", nil)];
			else if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted)
				error = [NSError makeWithText:NSLocalizedString(@"Location services have not been authorized for this app! Update your privacy settings.", nil)];
			else if(errorCode == kCLErrorNetwork)
				error = [NSError makeWithText:NSLocalizedString(@"GPS Location Services are Unavailable", nil)];
			else
				error = [NSError makeWithText:NSLocalizedString(@"Could not find location.", nil)];
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:[error localizedDescription]];
			return;
		}
		CLPlacemark *placemark = placemarks.count ? ObjectCast([placemarks objectAtIndex:0], CLPlacemark) : nil;
		if(!placemark) {
			[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:NSLocalizedString(@"Could not find location.", nil)];
			return;
		}
		[self applySearchPlacemark:placemark];
	}];
}

- (void)applySearchPlacemark:(CLPlacemark *)placemark {
	_curSearchTicket++;
	
	YTLocationInfo *location = self.locationInfo;
	if(!location) {
		location = [[[YTLocationInfo alloc] init] autorelease];
		self.locationInfo = location;
	}
	location.latitude = 0;
	location.longitude = 0;
	[self updateViewAsync];
	
	NSString *sAddr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
	if(!sAddr)
		sAddr = [@"" retain];
	[sAddr autorelease];
	sAddr = [sAddr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
	location.name = sAddr;
	CLLocation *loc = placemark.location;
	if(loc) {
		location.latitude = loc.coordinate.latitude;
		location.longitude = loc.coordinate.longitude;
	}
	[VLCtrlsUtils findAndResignFirstResponder:self];
	[self updateViewNow];
	[self showFoundPin];
	_searchBar.text = @"";
}

+ (void)getAddressFromLocation:(CLLocation *)loc resultBlock:(void (^)(YTLocationInfo *resultLocation, NSError *error))resultBlock {

	[[VLAppDelegateBase sharedAppDelegateBase] startAnimateNetworkActivityIndicator];
	CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
	[geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error)
	{
		[[VLAppDelegateBase sharedAppDelegateBase] stopAnimateNetworkActivityIndicator];
		if(error) {
			VLLogError(error);
			NSInteger errorCode = error.code;
			BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
			CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
			if(!locationServicesEnabled)
				error = [NSError makeWithText:NSLocalizedString(@"Location services have not been enabled! Update your settings.", nil)];
			else if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted)
				error = [NSError makeWithText:NSLocalizedString(@"Location services have not been authorized for this app! Update your privacy settings.", nil)];
			else if(errorCode == kCLErrorNetwork)
				error = [NSError makeWithText:NSLocalizedString(@"GPS Location Services are Unavailable", nil)];
			// kCLErrorDenied,                       // Access to location or ranging has been denied by the user
			// kCLErrorNetwork,                      // general, network-related error
			resultBlock(nil, error);
			return;
		}
		CLPlacemark *placemark = placemarks.count ? ObjectCast([placemarks objectAtIndex:0], CLPlacemark) : nil;
		if(!placemark) {
			NSError *error = [NSError makeWithText:NSLocalizedString(@"Could not find address.", nil)];
			resultBlock(nil, error);
			return;
		}
		YTLocationInfo *resultLocation = [[[YTLocationInfo alloc] init] autorelease];
		NSString *sAddr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
		if(!sAddr)
			sAddr = [@"" retain];
		[sAddr autorelease];
		sAddr = [sAddr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
		resultLocation.name = sAddr;
		CLLocation *loc = placemark.location;
		if(loc) {
			resultLocation.latitude = loc.coordinate.latitude;
			resultLocation.longitude = loc.coordinate.longitude;
		}
		resultBlock(resultLocation, nil);
	}];
	
	/*//NSString *sUrl = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",
	NSString *sUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%f,%f&output=csv",
					  loc.coordinate.latitude, loc.coordinate.longitude];
	VLHttpWebRequest *request = [[[VLHttpWebRequest alloc] init] autorelease];
	[[VLAppDelegateBase sharedAppDelegateBase] startAnimateNetworkActivityIndicator];
	[request startWithUrl:sUrl
				   method:kVLHttpWebRequest_MethodGet
				 postData:nil
				  timeout:30
			   cachPolicy:NSURLRequestReloadIgnoringCacheData
			 headerFields:nil
			  synchronous:NO
			  resultBlock:^(NSError *error, NSData *dataResponse)
	 {
		 [[VLAppDelegateBase sharedAppDelegateBase] stopAnimateNetworkActivityIndicator];
		 if(error) {
			 VLLogError(error);
			 resultBlock(nil, error);
			 return;
		 }
		 NSString *sResponse = [VLHttpWebRequest responseStringFromData:dataResponse];
		 VLLogEvent(sResponse);
		 NSMutableArray *parts = [NSMutableArray array];
		 BOOL inQuotes = NO;
		 int lastPos = 0;
		 for(int i = 0; i < sResponse.length; i++) {
			 unichar ch = [sResponse characterAtIndex:i];
			 if(ch == '\"') {
				 inQuotes = !inQuotes;
			 } else if(ch == ',' && !inQuotes) {
				 [parts addObject:[sResponse substringWithRange:NSMakeRange(lastPos, i - lastPos)]];
				 lastPos = i + 1;
			 }
		 }
		 if(lastPos < sResponse.length)
			 [parts addObject:[sResponse substringWithRange:NSMakeRange(lastPos, sResponse.length - lastPos)]];
		 if(parts.count < 3) {
			 NSError *error = [NSError makeWithText:@"Could not find address."];
			 resultBlock(nil, error);
			 return;
		 }
		 NSString *sCode = [parts objectAtIndex:0];
		 if(sCode.intValue != 200) {
			 NSError *error = [NSError makeWithText:@"Could not find address."];
			 resultBlock(nil, error);
			 return;
		 }
		 NSString *sAddr = [parts objectAtIndex:2];
		 sAddr = [sAddr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
		 YTLocationInfo *resultLocation = [[[YTLocationInfo alloc] init] autorelease];
		 resultLocation.latitude = loc.coordinate.latitude;
		 resultLocation.longitude = loc.coordinate.longitude;
		 resultLocation.name = sAddr;
		 resultBlock(resultLocation, nil);
	 }];*/
}

+ (void)getAddressFromCurrentLocationWithResultBlock:(void (^)(YTLocationInfo *resultLocation, NSError *error))resultBlock {
	CLLocation *locExisted = [[VLLocationManager shared] getLocation];
	if(locExisted) {
		[self getAddressFromLocation:locExisted resultBlock:^(YTLocationInfo *resultLocation, NSError *error) {
			if(!error && resultLocation) {
				resultLocation.latitude = locExisted.coordinate.latitude;
				resultLocation.longitude = locExisted.coordinate.longitude;
			}
			resultBlock(resultLocation, error);
		}];
		return;
	}
	[[VLLocationManager shared] startUpdatingLocationWithResultBlock:^{
		CLLocation *loc = [[VLLocationManager shared] getLocation];
		if(!loc) {
			NSError *error = [NSError makeWithText:NSLocalizedString(@"GPS Location Services are Unavailable", nil)];
			BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
			CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
			if(!locationServicesEnabled)
				error = [NSError makeWithText:NSLocalizedString(@"Location services have not been enabled! Update your settings.", nil)];
			else if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted)
				error = [NSError makeWithText:NSLocalizedString(@"Location services have not been authorized for this app! Update your privacy settings.", nil)];
			resultBlock(nil, error);
			return;
		}
		[self getAddressFromLocation:loc resultBlock:^(YTLocationInfo *resultLocation, NSError *error) {
			if(!error && resultLocation) {
				resultLocation.latitude = loc.coordinate.latitude;
				resultLocation.longitude = loc.coordinate.longitude;
			}
			resultBlock(resultLocation, error);
		}];
	}];
}

- (void)startGettingSuggestedLocation {
	[[self class] getAddressFromCurrentLocationWithResultBlock:^(YTLocationInfo *resultLocation, NSError *error) {
		if(resultLocation && !self.locationInfo) {
			self.locationInfo = resultLocation;
		}
	}];
}

- (void)setIsSearching:(BOOL)isSearching {
	if(_isSearching != isSearching) {
		_isSearching = isSearching;
		_searchBar.showsCancelButton = _isSearching;
		[self setNavigationBarHidden:_isSearching withStatusBarBackColor:kBarBackColor animated:YES];
		[[YTSlidingContainerView shared] suspendSliding:_isSearching];
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			_overlayView.alpha = _isSearching ? 1.0 : 0.0;
		}];
		[self updateSearchText];
	}
}

- (void)updateSearchText {
	NSString *searchText = @"";
	if(_isSearching) {
		searchText = [_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}
	if(![NSString isEmpty:searchText]) {
		if(_locationSuggestView.hidden) {
			[_locationSuggestView setSearchText:@""];
			_locationSuggestView.hidden = NO;
		}
		[_locationSuggestView setSearchText:searchText];
	} else {
		_locationSuggestView.hidden = YES;
	}
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[self setIsSearching:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[self setIsSearching:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	[self startSearchWithText:_searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	_searchBar.text = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self updateSearchText];
}

- (void)locationSuggestView:(YTLocationSuggestView *)locationSuggestView placemarkSelected:(CLPlacemark *)placemark {
	[self applySearchPlacemark:placemark];
	[self setIsSearching:NO];
	[self updateSearchText];
}

- (void)onSearchOverlayViewTap:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized) {
		[self searchBarCancelButtonClicked:_searchBar];
	}
}

- (void)onBtnUseThisLocationTap:(id)sender {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        YTLocationInfo *objTemp = self.locationInfo;
		if(!!objTemp != !!self.noteEditInfo.locationNew) {
			self.noteEditInfo.locationNew = objTemp;
		} else if(objTemp) {
			//objTemp.noteGuid = self.noteEditInfo.noteNew.noteGuid;
			//int64_t nLastId = self.noteEditInfo.locationNew.locationId;
			[self.noteEditInfo.locationNew assignDataFrom:objTemp];
			self.noteEditInfo.noteNew.lastUpdateTS = [VLDate date];
			//self.noteEditInfo.locationNew.locationId = nLastId;
		}
        [[AppDelegate instance]settingsDismiss];
    }
    else{

    _curSearchTicket++;
	if(_delegate)
		[_delegate mapSearchView:self finishWithAction:EYTUserActionTypeDone];
    
    }
}

- (void)onBtnCancelTap:(id)sender {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [[AppDelegate instance]settingsDismiss];
    }
    else{
	_curSearchTicket++;
	if(_delegate)
		[_delegate mapSearchView:self finishWithAction:EYTUserActionTypeCancel];
    
    }
}

- (void)dealloc {
	[self setIsSearching:NO];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[_mapView release];
	[_searchBar release];
	[_toolbar release];
	[_timer release];
	[_bbiUseThisLoc release];
	[_lbAddressText release];
	[_overlayView release];
	[_locationSuggestView release];
	[super dealloc];
}

@end

