
#import <UIKit/UIKit.h>

@interface VLLabel : UILabel
{
	BOOL _isUnderlined;
	BOOL _adjustsFontSizeToFitWidthMultiLine;
}

@property(nonatomic,assign) BOOL isUnderlined;
@property(nonatomic,assign) BOOL adjustsFontSizeToFitWidthMultiLine;

@end

