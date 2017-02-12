
#import "YTFontsManager.h"
#import "YTUiCommon.h"

#define kYTFontCondensedName @"HelveticaNeue"
#define kYTFontCondensedLightName @"HelveticaNeue-Light"
#define kYTFontCondensedMediumName @"HelveticaNeue-Medium"

static YTFontsManager *_shared;

@implementation YTFontsManager

@synthesize msgrFontsChanged = _msgrFontsChanged;

+ (YTFontsManager *)shared {
	if(!_shared)
		_shared = [[YTFontsManager alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_msgrFontsChanged = [[VLMessenger alloc] init];
		_msgrFontsChanged.owner = self;
		if(kIosVersionFloat >= 7.0) {
			_useDynamicFonts = YES;
			[self updateFonts];
			[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(preferredContentSizeChanged:)
													 name:UIContentSizeCategoryDidChangeNotification
												   object:nil];
		} else {
			_dynamicFontSizeMultiplier = 1.0;
		}
	}
	return self;
}

- (void)initialize {
	
}

- (void)updateFonts {
	UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
	UIFont *font = [UIFont fontWithDescriptor:descriptor size:0];
	float dynamicFontSizeMultiplier = font.pointSize / 17.0;
	if(_dynamicFontSizeMultiplier != dynamicFontSizeMultiplier) {
		float lastValue = _dynamicFontSizeMultiplier;
		_dynamicFontSizeMultiplier = dynamicFontSizeMultiplier;
		if(lastValue != 0) {
			[_msgrFontsChanged postMessage];
		}
	}
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
	[self updateFonts];
}

- (UIFont *)fontWithSize:(float)fontSize fixed:(BOOL)fixed {
	UIFont *font = nil;
	if(fixed) {
		font = [UIFont fontWithName:kYTFontCondensedName size:fontSize];
	} else {
		font = [UIFont fontWithName:kYTFontCondensedName size:fontSize*_dynamicFontSizeMultiplier];
	}
	return font;
}

- (UIFont *)fontWithSize:(float)fontSize {
	//UIFont *font = nil;
	////if(_useDynamicFonts) {
	////	UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIContentSizeCategoryMedium];
	////	font = [UIFont fontWithDescriptor:descriptor size:fontSize];
	////} else {
	//	font = [UIFont fontWithName:kYTFontCondensedName size:fontSize*_dynamicFontSizeMultiplier];
	////}
	return [self fontWithSize:fontSize fixed:NO];
}

- (UIFont *)boldFontWithSize:(float)fontSize fixed:(BOOL)fixed {
	UIFont *font = nil;
	if(fixed) {
		font = [UIFont fontWithName:kYTFontCondensedMediumName size:fontSize];
	} else {
		font = [UIFont fontWithName:kYTFontCondensedMediumName size:fontSize*_dynamicFontSizeMultiplier];
	}
	return font;
}

- (UIFont *)boldFontWithSize:(float)fontSize {
	return [self boldFontWithSize:fontSize fixed:NO];
}

- (UIFont *)lightFontWithSize:(float)fontSize fixed:(BOOL)fixed {
	UIFont *font = nil;
	if(fixed) {
		font = [UIFont fontWithName:kYTFontCondensedLightName size:fontSize];
	} else {
		font = [UIFont fontWithName:kYTFontCondensedLightName size:fontSize*_dynamicFontSizeMultiplier];
	}
	return font;
}

- (UIFont *)lightFontWithSize:(float)fontSize {
	return [self lightFontWithSize:fontSize fixed:NO];
}

- (UIFont *)fontTableCellLabel {
	return [self fontWithSize:16 fixed:YES];
}

- (UIFont *)fontTableCellLabelBig {
	return [self fontWithSize:17 fixed:YES];
}

- (UIFont *)fontTableCellLabelBold {
	return [self boldFontWithSize:15 fixed:YES];
}

- (UIFont *)fontNoteTextCapital {
	return [self boldFontWithSize:17];
}

- (UIFont *)fontNoteTextContent {
	return [self fontWithSize:16];
}

- (UIFont *)fontHeaderTitle {
	return [self boldFontWithSize:20 fixed:YES];
}

- (void)dealloc {
	[super dealloc];
}

@end

