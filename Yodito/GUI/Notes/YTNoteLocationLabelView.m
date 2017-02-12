
#import "YTNoteLocationLabelView.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kPadding UIEdgeInsetsMake(8, 8, 8, 2)

@implementation YTNoteLocationLabelView

- (void)initialize {
	[super initialize];
	self.clipsToBounds = YES;
	self.backgroundColor = [UIColor clearColor];
	
	_label = [VLLabel new];
	_label.backgroundColor = [UIColor clearColor];
	_label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_label.textColor = kYTLabelsBlueTextColor;//kLinkColor;
	[self addSubview:_label];
	
	_label.hidden = YES;
	
	_labelLink = [VLLinkLabel new];
	_labelLink.backgroundColor = [UIColor clearColor];
	_labelLink.label.backgroundColor = [UIColor clearColor];
	_labelLink.label.isUnderlined = NO;
	_labelLink.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	_labelLink.label.textColor = kYTLabelsBlueTextColor;//kLinkColor;
	[self addSubview:_labelLink];
	[_labelLink.msgrTapped addObserver:self selector:@selector(onLinkTapped:)];
	_labelLink.userInteractionEnabled = NO;
	_labelLink.label.textAlignment = NSTextAlignmentLeft;
	_labelLink.label.adjustsFontSizeToFitWidth = NO;
	_labelLink.label.lineBreakMode = NSLineBreakByTruncatingTail;
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
}

- (void)updateFonts:(id)sender {
	_label.font = _labelLink.label.font = [[YTFontsManager shared] fontWithSize:10 fixed:YES];
}

- (void)onUpdateView {
	[super onUpdateView];
	YTNoteInfo *note = self.note;
	if(!note)
		return;
	NSString *text = @"";
	YTLocationInfo *location = [[YTLocationsEnManager shared] getLocationByNoteGuid:note.noteGuid];
	if(location) {
		text = [location.name uppercaseString];
	} else {
		text = @"-";
	}
	if(![_label.text isEqual:text]) {
		_label.text = _labelLink.label.text = text;
		[self setNeedsLayout];
	}
}

- (void)onNoteDataChanged {
	[super onNoteDataChanged];
	[self updateViewAsync];
}

- (void)onLocationsManagerChanged {
	[super onLocationsManagerChanged];
	[self updateViewAsync];
	if(self.superview)
		[self.superview setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
	//size.height = kPadding.top + [_label sizeOfText].height + 4 + kPadding.bottom;
	size.height = 30.0;
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	CGRect rcCtrls = UIEdgeInsetsInsetRect(rcBnds, kPadding);
	_label.frame = rcCtrls;
	CGRect rcLink = rcCtrls;
	rcLink.size.width = [_labelLink.label sizeOfText].width + 1;
	_labelLink.frame = rcLink;
}

- (void)onLinkTapped:(id)sender {
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	YTNoteInfo *note = self.note;
	if(!note)
		return;
	YTLocationInfo *location = [[YTLocationsEnManager shared] getLocationByNoteGuid:note.noteGuid];
	if(location && location.latitude && location.longitude) {
		if(kIosVersionFloat >= 6.0) {
			Class mapItemClass = [MKMapItem class];
			if(mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
				// Create an MKMapItem to pass to the Maps app
				CLLocationCoordinate2D coordinate =
                CLLocationCoordinate2DMake(location.latitude, location.longitude);
				MKPlacemark *placemark = [[[MKPlacemark alloc] initWithCoordinate:coordinate
															   addressDictionary:nil] autorelease];
				MKMapItem *mapItem = [[[MKMapItem alloc] initWithPlacemark:placemark] autorelease];
				[mapItem setName:location.name];
				
				// Set the directions mode to "Walking"
				// Can use MKLaunchOptionsDirectionsModeDriving instead
				NSDictionary *launchOptions = [NSDictionary dictionary];//@{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
				// Get the "Current User Location" MKMapItem
				//MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
				// Pass the current location and destination map items to the Maps app
				// Set the direction mode in the launchOptions dictionary
				[MKMapItem openMapsWithItems:[NSArray arrayWithObjects:mapItem, nil]//@[currentLocationMapItem, mapItem]
							   launchOptions:launchOptions];
			}
		} else {
			NSString *sUrl = [NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f", location.latitude, location.longitude];
			NSString *sUrlEscaped = [sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if(!sUrlEscaped)
				sUrlEscaped = @"";
			NSURL *url = [NSURL URLWithString:sUrlEscaped];
			if(url) {
				[[UIApplication sharedApplication] openURL:url];
			}
		}
	}
}

- (void)dealloc {
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[_label release];
	[_labelLink release];
	[super dealloc];
}

@end
