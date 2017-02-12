
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNoteResourceRowView.h"

@class YTNoteResourcesListView;


@protocol YTNoteResourcesListViewDelegate <NSObject>
@required
- (void)noteResourcesListView:(YTNoteResourcesListView *)noteResourcesListView rowTapped:(YTNoteResourceRowView *)rowView;

@end


@interface YTNoteResourcesListView : YTBaseView {
@private
	UIView *_backViewSep;
	NSMutableArray *_rowsViews;
	NSMutableArray *_docsSepars;
	NSObject<YTNoteResourcesListViewDelegate> *_delegate;
	NSMutableArray *_resources;
	YTResourceInfo *_mainResource;
	int _maxPhotosToShow;
}

@property(nonatomic, assign) NSObject<YTNoteResourcesListViewDelegate> *delegate;
@property(nonatomic, assign) NSArray *resources;
@property(nonatomic, readonly) NSArray *rowsViews; // Array of YTNoteResourceRowView
@property(nonatomic, retain) YTResourceInfo *mainResource;

- (CGSize)sizeThatFits:(CGSize)size;
- (void)onRowTapped:(YTNoteResourceRowView *)rowView;
+ (void)sortResources:(NSMutableArray *)arrYTResourceInfo optionalMainResource:(YTResourceInfo *)optionalMainResource;
- (BOOL)isAllImagesShown;
- (void)setMaxPhotosToShow:(int)maxPhotosToShow;

@end

