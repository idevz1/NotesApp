//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "VLRefreshTableHeaderView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

#define CY(value) (floor(value * _scaleY)) // Correct y, height
#define CYT(value) (value)//(floor(value * _scaleY)) // For text
#define kDefaultHeight 65.0

@interface VLRefreshTableHeaderView (Private)
- (void)setState:(VLPullRefreshState)aState;
@end

@implementation VLRefreshTableHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor height:(float)height
{
    if((self = [super initWithFrame:frame]))
	{
		_scaleY = height / kDefaultHeight;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];// [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - CY(30.0f), self.frame.size.width, CY(20.0f))];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:CYT(12.0f)];
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - CY(48.0f), self.frame.size.width, CY(20.0f))];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:CYT(13.0f)];
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(15.0f, frame.size.height - CY(65.0f), 30.0f, CY(55.0f)); // 25.0f -> 15.0f
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
		{
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		//view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		view.frame = CGRectMake(15.0f, frame.size.height - CY(38.0f), 20.0f, CY(20.0f));
		[self addSubview:view];
		_activityView = view;
		[view release];
		
		[self setState:VLPullRefreshNormal];
		
    }
	
    return self;
	
}

/*- (id)initWithFrame:(CGRect)frame 
{
	return [self initWithFrame:frame arrowImageName:@"pulltorefrest_blueArrow.png" textColor:TEXT_COLOR];
}*/

- (id)initWithFrame:(CGRect)frame style:(VLPullRefreshStyle)style height:(float)height
{
	NSString *imageName = @"pulltorefrest_blueArrow.png";
	UIColor *textColor = TEXT_COLOR;
	if(style == VLPullRefreshStyleWhite)
	{
		imageName = @"pulltorefrest_whiteArrow.png";
		textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	}
	else if(style == VLPullRefreshStyleGray)
	{
		imageName = @"pulltorefrest_grayArrow.png";
		textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
	}
	else if(style == VLPullRefreshStyleBlack)
	{
		imageName = @"pulltorefrest_blackArrow.png";
		textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	}
	self = [self initWithFrame:frame arrowImageName:imageName textColor:textColor height:height];
	_style = style;
	if(_style == VLPullRefreshStyleWhite)
	{
		_activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	}
	return self;
}

- (id)initWithStyle:(VLPullRefreshStyle)style height:(float)height
{
	CGRect rect = CGRectMake(0, 0 - height, 0, height);
	return [self initWithFrame:rect style:style height:height];
}

- (id)initWithStyle:(VLPullRefreshStyle)style
{
	return [self initWithStyle:style height:kDefaultHeight];
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate
{
	if ([_delegate respondsToSelector:@selector(pullRefreshTableHeaderDataSourceLastUpdated:)])
	{
		NSDate *date = [_delegate pullRefreshTableHeaderDataSourceLastUpdated:self];
		if(date)
		{
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			
			_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [dateFormatter stringFromDate:date]];
			[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		else
			_lastUpdatedLabel.text = nil;
	}
	else
	{
		_lastUpdatedLabel.text = nil;
	}
}

- (void)setState:(VLPullRefreshState)aState
{
	switch (aState)
	{
		case VLPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case VLPullRefreshNormal:
			
			if (_state == VLPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case VLPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)pullRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{	
	if (_state == VLPullRefreshLoading)
	{
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, CY(60));
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	}
	else if (scrollView.isDragging)
	{
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(pullRefreshTableHeaderDataSourceLastUpdated:)])
		{
			_loading = [_delegate pullRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == VLPullRefreshPulling && scrollView.contentOffset.y > -self.frame.size.height
			&& scrollView.contentOffset.y < 0.0f && !_loading)
		{
			[self setState:VLPullRefreshNormal];
		}
		else if (_state == VLPullRefreshNormal && scrollView.contentOffset.y < -self.frame.size.height && !_loading)
		{
			[self setState:VLPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0)
		{
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)pullRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(pullRefreshTableHeaderDataSourceLastUpdated:)])
	{
		_loading = [_delegate pullRefreshTableHeaderDataSourceIsLoading:self];
	}

	if (scrollView.contentOffset.y <= -self.frame.size.height && !_loading)
	{
		if ([_delegate respondsToSelector:@selector(pullRefreshTableHeaderDidTriggerRefresh:)])
		{
			[_delegate pullRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:VLPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(CY(60.0f), 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)pullRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:VLPullRefreshNormal];
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}

@end
