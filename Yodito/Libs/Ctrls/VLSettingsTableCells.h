
#import <Foundation/Foundation.h>
#import "VLTableViewCell.h"
#import "VLBaseView.h"
#import "VLLabel.h"

@class VLSettingsCellView;

@interface VLSettingsTableCell : VLTableViewCell
{
@private
	VLSettingsCellView *_view;
	BOOL _wasSelectedOrHighlighted;
}

@property(nonatomic, readonly) VLSettingsCellView *view;

- (id)initWithView:(VLSettingsCellView*)view reuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end


@interface VLSettingsCellView_ColorBox : VLBaseView {
@private
	UIColor *_color;
}

@property(nonatomic, assign) UIColor *color;

@end


@interface VLSettingsCellView : VLBaseView <UITextFieldDelegate>
{
@private
	VLLabel *_label;
	UITextField *_textField;
	UISwitch *_switcher;
	VLLabel *_labelValue;
	VLSettingsCellView_ColorBox *_colorBox;
	VLMessenger *_msgrValueChanged;
	float _valueWidthWeight;
	float _horizontalControlsDistance;
	BOOL _changeLabelsColorsWhenSelectedOrHighlighted;
	UIColor *_lastLabelColor;
	UIColor *_lastLabelValueColor;
	UIEdgeInsets _paddings;
}

@property(nonatomic, readonly) VLLabel *label;
@property(nonatomic, readonly) UITextField *textField;
@property(nonatomic, readonly) BOOL hasTextField;
@property(nonatomic, readonly) UISwitch *switcher;
@property(nonatomic, readonly) VLLabel *labelValue;
@property(nonatomic, readonly) VLSettingsCellView_ColorBox *colorBox;
@property(nonatomic, readonly) VLMessenger *msgrValueChanged;
@property(nonatomic, assign) float valueWidthWeight;
@property(nonatomic, assign) float horizontalControlsDistance;
@property(nonatomic, assign) BOOL changeLabelsColorsWhenSelectedOrHighlighted;
@property(nonatomic, assign) UIEdgeInsets paddings;

@end
