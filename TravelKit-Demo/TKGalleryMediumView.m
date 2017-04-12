//
//  GalleryMediumView.m
//  Tripomatic
//
//  Created by Michal Zelinka on 17/4/14.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import "TKGalleryMediumView.h"
#import "TKPlaceImageView.h"

#import "UIKit+TravelKit.h"

#define LABEL_OFFSET 22.0


#pragma mark - Interfaces


@interface TKGalleryMediumView () <UIScrollViewDelegate>

@property (nonatomic, strong) TKPlaceImageView *fakishLoadingView;
@property (nonatomic, strong) TKMedium *medium;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *placeholderImageView;
@property (nonatomic, strong) UIScrollView *zoomView;

//@property (nonatomic, strong) SVIndefiniteAnimatedView *indicator;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *errorButton;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) AVPlayerViewController *videoPlayer;

@property (atomic, readonly) BOOL imageDisplayCheck;

@end


#pragma mark - Implementation


@implementation TKGalleryMediumView

- (id)initWithFrame:(CGRect)frame medium:(TKMedium *)medium
{
	if (self = [super initWithFrame:frame])
	{
		_medium = medium;

		_errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 56)];
		_errorLabel.font = [UIFont systemFontOfSize:16];
		_errorLabel.textColor = [UIColor colorWithWhite:.4 alpha:1];
		_errorLabel.textAlignment = NSTextAlignmentCenter;
		_errorLabel.text = NSLocalizedString(@"Error when loading image", @"View label");
		_errorLabel.hidden = YES;
		[self addCenteredSubview:_errorLabel];

		_zoomView = [[UIScrollView alloc] initWithFrame:self.bounds];
		_zoomView.scrollEnabled = YES;
		_zoomView.delegate = self;
		_zoomView.showsHorizontalScrollIndicator = _zoomView.showsVerticalScrollIndicator = NO;
		_zoomView.bounces = YES;
		_zoomView.bouncesZoom = YES;
		_zoomView.maximumZoomScale = 1.0;
		_zoomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_zoomView];

		_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[_zoomView addCenteredSubview:_imageView];

//		_indicator = [[SVIndefiniteAnimatedView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//		_indicator.strokeThickness = 2.5;
//		_indicator.strokeColor = [UIColor whiteColor];
//		_indicator.radius = 22.0f;
//		_indicator.autoresizingMask = UtilsViewFlexibleMargins;
//		[self addCenteredSubview:_indicator];

		_errorButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_errorButton setTitle:NSLocalizedString(@"Refresh", @"Button title") forState:UIControlStateNormal];
		[_errorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_errorButton.titleLabel.font = [UIFont systemFontOfSize:18];
		[_errorButton addTarget:self action:@selector(retryCheckImageDisplay) forControlEvents:UIControlEventTouchUpInside];
		[_errorButton sizeToFit];
		_errorButton.hidden = YES;
		[self addCenteredSubview:_errorButton];
		_errorButton.top = _errorLabel.bottom;

		_placeholderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityicon-360_promo"]];
		_placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
		_placeholderImageView.autoresizingMask = _imageView.autoresizingMask;
		[self addCenteredSubview:_placeholderImageView];
		_placeholderImageView.hidden = _medium.type != TKMediumTypeVideo360;

		if (_medium.type == TKMediumTypeVideo)
		{
			[_zoomView removeFromSuperview];
			_videoPlayer = [[AVPlayerViewController alloc] init];
			_videoPlayer.view.frame = self.bounds;
			_videoPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_videoPlayer.view.userInteractionEnabled = NO;
			_videoPlayer.showsPlaybackControls = NO;
			_videoPlayer.player.volume = 1.0;
			_videoPlayer.view.backgroundColor = [UIColor clearColor];
			[self addCenteredSubview:_videoPlayer.view];

//			_playButton = [UIButton buttonWithImageNamed:@"button-play"];
//			[_playButton addTarget:self action:@selector(playPauseVideo) forControlEvents:UIControlEventTouchUpInside];
//			_playButton.hidden = _medium.type != MediumTypeVideo;

			_videoPlayer.player = [[AVPlayer alloc] initWithURL: _medium.URL];
			_videoPlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
			[_videoPlayer.player pause];
			[self addCenteredSubview:_playButton];
		}

		_fakishLoadingView = [[TKPlaceImageView alloc] initWithFrame:self.bounds];
	}

	return self;
}

- (void)dealloc
{
	_zoomView.delegate = nil;
	_imageView = nil;
	_placeholderImageView = nil;
	_playButton = nil;
	_medium = nil;
	_videoPlayer.player = nil;
	_videoPlayer = nil;
}

#pragma mark -

- (void)checkImageDisplay
{
	if (!_imageDisplayCheck) {
		_imageDisplayCheck = YES;

//		UIImage *img = [[MediaManager defaultManager] imageFromCacheForMedium:_medium type:ImageTypeGalleryPreview];
//		if (img) _imageView.image = img;

		__weak typeof(self) self_ = self;

		[_fakishLoadingView setImageForMedium:_medium withSize:CGSizeMake(1280, 1280) completion:^{
			[self_ fakishImageViewUpdated];
		}];
	}
}

- (void)retryCheckImageDisplay
{
	_imageDisplayCheck = 0;
//	_indicator.hidden = NO;
	_errorLabel.hidden = YES;
	_errorButton.hidden = YES;

	[self checkImageDisplay];
}

- (void)resetImageDisplay
{
	if (_medium.type == TKMediumTypeVideo) {
		[_videoPlayer.player pause];
		_playButton.hidden = NO;
	}
	[_zoomView setZoomScale:1.0 animated:YES];
}


#pragma mark - Video stuff


- (void)playPauseVideo
{
	if (_medium.type != TKMediumTypeVideo) return;

	if (_videoPlayer.player.rate == 0.0) {
		[_videoPlayer.player play];
		_playButton.hidden = YES;
	} else {
		[_videoPlayer.player pause];
		_playButton.hidden = NO;
	}
}

- (void)playVideo
{
	if (_medium.type != TKMediumTypeVideo) return;

	if (_videoPlayer.player.rate == 0.0) {
		[_videoPlayer.player play];
		_playButton.hidden = YES;
	}
}


#pragma mark - Getters


- (UIImage *)image
{
	return _imageView.image;
}

- (CGFloat)zoomScale
{
	return _zoomView.zoomScale;
}


#pragma mark - Random stuff


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imageView;
}

- (void)fakishImageViewUpdated
{
	if (!_fakishLoadingView.image)
	{
//		_indicator.hidden = YES;
		_errorLabel.hidden = NO;
		_errorButton.hidden = NO;
		return;
	}

	_imageView.image = _fakishLoadingView.image;

	_imageView.contentMode =
	  (_imageView.image.size.width > _imageView.width ||
	   _imageView.image.size.height > _imageView.height) ?
		UIViewContentModeScaleAspectFit : UIViewContentModeCenter;

	_zoomView.minimumZoomScale = 1;
	_zoomView.maximumZoomScale = (_imageView.contentMode == UIViewContentModeCenter) ? 2 :
		MAX(_imageView.image.size.width/_imageView.width, _imageView.image.size.height/_imageView.height);

	CGFloat imageScale = 1.0 / _zoomView.maximumZoomScale;

	if (_imageView.contentMode == UIViewContentModeScaleAspectFit)
		_zoomView.contentSize = _imageView.size =
			CGSizeMake(imageScale*_imageView.image.size.width,
			           imageScale*_imageView.image.size.height);

//	[UIView animateWithDuration:0.3 animations:^{
//		_indicator.alpha = 0.0;
//	} completion:^(BOOL finished) {
//		_indicator.hidden = YES;
//	}];

	[self layoutSubviews];
}

- (void)layoutSubviews
{
	// Super
	[super layoutSubviews];

	// Center the image as it becomes smaller than the size of the screen
	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = _imageView.frame;

	// Horizontally
	if (frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0);
	else
		frameToCenter.origin.x = 0;

	// Vertically
	if (frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0);
	else
		frameToCenter.origin.y = 0;

	// Center
	if (!CGRectEqualToRect(_imageView.frame, frameToCenter))
		_imageView.frame = frameToCenter;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	scrollView.bouncesZoom = scrollView.zoomScale >= scrollView.maximumZoomScale * 0.8;

	[self layoutSubviews];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
	if (scale > 1 && scale < 1.3)
		[scrollView setZoomScale:1.0 animated:YES];
}

@end
