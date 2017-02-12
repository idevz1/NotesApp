
#import <Foundation/Foundation.h>
#import "YTResourceBaseView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YTResourceMediaView : YTResourceBaseView {
@private
	MPMoviePlayerController *_playerController;
}

@end

