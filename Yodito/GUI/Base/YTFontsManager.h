
#import <Foundation/Foundation.h>
#import "../../Libs/Classes.h"

@interface YTFontsManager : NSObject {
@private
	BOOL _useDynamicFonts;
	float _dynamicFontSizeMultiplier;
	VLMessenger *_msgrFontsChanged;
}

@property(nonatomic, readonly) VLMessenger *msgrFontsChanged;

+ (YTFontsManager *)shared;
- (void)initialize;

- (UIFont *)fontWithSize:(float)fontSize fixed:(BOOL)fixed;
- (UIFont *)fontWithSize:(float)fontSize;
- (UIFont *)boldFontWithSize:(float)fontSize fixed:(BOOL)fixed;
- (UIFont *)boldFontWithSize:(float)fontSize;
- (UIFont *)lightFontWithSize:(float)fontSize fixed:(BOOL)fixed;
- (UIFont *)lightFontWithSize:(float)fontSize;

- (UIFont *)fontTableCellLabel;
- (UIFont *)fontTableCellLabelBig;
- (UIFont *)fontTableCellLabelBold;
- (UIFont *)fontNoteTextCapital;
- (UIFont *)fontNoteTextContent;
- (UIFont *)fontHeaderTitle;

@end

