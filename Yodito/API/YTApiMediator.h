
#import <Foundation/Foundation.h>
#import "Base/Classes.h"
#import "Entities/Classes.h"

@interface YTApiMediator : YTLogicObject <NSCoding> {
@private
	int64_t _savedDataVersion;
	
	VLTimer *_timer;
	BOOL _isShowingMainView;
	BOOL _wasDataInitialized;
	BOOL _notesTableWasLoadadOnce;
}

@property(nonatomic, assign) BOOL isShowingMainView;
@property(nonatomic, assign) BOOL notesTableWasLoadadOnce;

+ (YTApiMediator *)shared;

- (BOOL)isDataInitialized;

@end
