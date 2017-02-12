
#import <Foundation/Foundation.h>

@class VLPopupTipView;
@class VLPopupTipsManager;


@protocol VLPopupTipsManagerDelegate <NSObject>
@optional
- (void)popupTipsManager:(VLPopupTipsManager *)popupTipsManager shouldSkipAllTipsWithResultBlock:(void(^)(BOOL cancel))resultBlock;

@end


@interface VLPopupTipsManager : NSObject {
@private
	NSMutableDictionary *_dictInfoById;
	NSMutableDictionary *_dictInfoByViewKey;
	VLPopupTipView *_visibleTipView;
	CGRect _lastAppFrame;
	BOOL _needsSave;
	int _timerCounter;
	NSObject<VLPopupTipsManagerDelegate> *_delegate;
	int _curNewTipOrderIndex;
}

@property(nonatomic, assign) NSObject<VLPopupTipsManagerDelegate> *delegate;

+ (VLPopupTipsManager *)shared;

+ (void)setVersion:(int)version;

- (void)setTipWithIdentifier:(NSString *)identifier title:(NSString *)title text:(NSString *)text targetView:(UIView *)targetView;
- (void)setTipWithIdentifier:(NSString *)identifier title:(NSString *)title text:(NSString *)text targetBarItem:(UIBarItem *)targetBarItem;

@end

