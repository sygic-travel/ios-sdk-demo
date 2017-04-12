//
//  GalleryTransitions.m
//  Travel
//
//  Created by Marek Stana on 11/9/16.
//  Copyright © 2016 Tripomatic. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MHUIImageViewContentViewAnimation.h"
#import "TKGalleryCollectionViewController.h"
#import "TKGalleryViewController.h"
#import "TKGalleryTransitions.h"
#import "UIKit+TravelKit.h"


@interface TKGalleryPresentTransition ()

@property (nonatomic, strong) UIView *backView;
@property (atomic) CGRect startFrame;

@end


@implementation TKGalleryPresentTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	if (!_fromImageView) return;

	UIView *containerView = [transitionContext containerView];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

	UIView *backgroundView = [[UIView alloc] initWithFrame:containerView.frame];
	backgroundView.backgroundColor = [UIColor colorFromRGB:0x131313];
	backgroundView.alpha = 0;
	[containerView addSubview:backgroundView];

	MHUIImageViewContentViewAnimation *snapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:
		[containerView convertRect:_fromImageView.frame fromView:_fromImageView.superview]];

	snapshot.backgroundColor = [UIColor clearColor];
	snapshot.image = _fromImageView.image;
	snapshot.contentMode = UIViewContentModeScaleAspectFill;
	[containerView addSubview:snapshot];

	toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
	toViewController.view.alpha = 0;

	[containerView addSubview:toViewController.view];

	[snapshot animateToViewMode:UIViewContentModeScaleAspectFit
		forFrame:toViewController.view.bounds withDuration:0.3 afterDelay:0 finished:nil];

	snapshot.alpha = 0.2;
	snapshot.contentMode = UIViewContentModeScaleAspectFit;

	[UIView animateWithDuration:0.3 animations:^{
		snapshot.alpha = 1;
		snapshot.frame = toViewController.view.frame;
		backgroundView.alpha = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.1 animations:^{
			snapshot.transform = CGAffineTransformMakeScale(1.015, 1.015);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.1 animations:^{
				snapshot.transform = CGAffineTransformMakeScale(1.0, 1.0);
			} completion:^(BOOL finished) {
				toViewController.view.alpha = 1;
				[snapshot removeFromSuperview];
				[backgroundView removeFromSuperview];
				[transitionContext completeTransition:![transitionContext transitionWasCancelled]];
			}];
		}];
	}];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
	return 0.8;
}

@end


@interface TKGalleryDismissTransition ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIViewController *fromViewController;
@property (nonatomic, strong) MHUIImageViewContentViewAnimation *fromImageView;
@property (nonatomic, strong) TKPlaceImageView *toImageView;
@property (atomic) CGRect initialFromImageViewFrame;

@end


@implementation TKGalleryDismissTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	_context = transitionContext;
	_containerView = [_context containerView];

	UIViewController *toViewController = [_context viewControllerForKey:UITransitionContextToViewControllerKey];
	toViewController.view.alpha = 1;
	[_containerView addSubview:toViewController.view];

	UIViewController *fromViewController = [_context viewControllerForKey:UITransitionContextFromViewControllerKey];
	fromViewController.view.alpha = 0;
	[_containerView addSubview:fromViewController.view];

	TKGalleryViewController *galleryVC = fromViewController.childViewControllers.firstObject;

	_backgroundView = [[UIView alloc] initWithFrame:galleryVC.view.frame];
	_backgroundView.backgroundColor = galleryVC.view.backgroundColor;
	[_containerView addSubview:_backgroundView];

	TKGalleryCollectionViewController *galleryCollectionVC = toViewController.childViewControllers.firstObject;

	UIImage *image = [galleryVC currentImage];
	if (!image) return;

	NSIndexPath *indexPathOfCurrentImage =  [NSIndexPath indexPathForItem:[galleryVC currentPage] inSection:0];

	TKGalleryCollectionViewCell *cell = (TKGalleryCollectionViewCell *)[galleryCollectionVC.collectionView cellForItemAtIndexPath:indexPathOfCurrentImage];
	_toImageView = cell.imageView;

	_fromImageView = [MHUIImageViewContentViewAnimation.alloc initWithFrame:fromViewController.view.frame];

	_fromImageView.image = image;
	_fromImageView.frame = AVMakeRectWithAspectRatioInsideRect( _fromImageView.imageMH.size, fromViewController.view.frame);
	_fromImageView.contentMode = UIViewContentModeScaleAspectFill;
	[_containerView addSubview:_fromImageView];

	[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
		_fromImageView.frame = [_containerView convertRect:_toImageView.frame fromView:_toImageView.superview];
		_fromImageView.contentMode = UIViewContentModeScaleAspectFill;
		_backgroundView.alpha = 0;
	} completion:^(BOOL finished) {
		[_backgroundView removeFromSuperview];
		[_context completeTransition:!_context.transitionWasCancelled];
	}];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
	return 0.25;
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	_context = transitionContext;
	_containerView = [transitionContext containerView];

	UIViewController *toViewController = [_context viewControllerForKey:UITransitionContextToViewControllerKey];
	_fromViewController = [_context viewControllerForKey:UITransitionContextFromViewControllerKey];

	[_containerView addSubview:toViewController.view];
	[_containerView addSubview:_fromViewController.view];
	_fromViewController.view.alpha = 0;

	TKGalleryViewController *galleryVC =
	((TKGalleryViewController *)_fromViewController.childViewControllers.firstObject);

	_backgroundView = [UIView.alloc initWithFrame:galleryVC.view.frame];
	_backgroundView.backgroundColor = galleryVC.view.backgroundColor;
	[_containerView addSubview:_backgroundView];

	TKGalleryCollectionViewController* galleryCollectionVC =
	((TKGalleryCollectionViewController *)toViewController.childViewControllers.firstObject);

	NSIndexPath *indexPathOfCurrentImage = [NSIndexPath indexPathForItem:[galleryVC currentPage] inSection:0];
	[galleryCollectionVC.collectionView scrollToItemAtIndexPath:indexPathOfCurrentImage atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];

	TKGalleryCollectionViewCell *cell = (TKGalleryCollectionViewCell *)[galleryCollectionVC.collectionView cellForItemAtIndexPath:indexPathOfCurrentImage];
	_toImageView = cell.imageView;
	_toImageView.alpha = 0;

	UIImage *image;
	image = [galleryVC currentImage];
	if (!image) return;

	_fromImageView = [MHUIImageViewContentViewAnimation.alloc initWithFrame:_fromViewController.view.frame];
	_fromImageView.image = image;

	_fromImageView.frame = AVMakeRectWithAspectRatioInsideRect(_fromImageView.imageMH.size, _fromViewController.view.frame);
	_fromImageView.contentMode = UIViewContentModeScaleAspectFill;
	[_containerView addSubview:_fromImageView];

	_initialFromImageViewFrame = _fromImageView.frame;
}

-(void)updateInteractiveTransition:(CGFloat)percentComplete
{
	[super updateInteractiveTransition:percentComplete];

	CGPoint initialCenter = CGPointMake(_initialFromImageViewFrame.origin.x + _initialFromImageViewFrame.size.width/2,
	                                    _initialFromImageViewFrame.origin.y + _initialFromImageViewFrame.size.height/2);

	if (percentComplete < 0.5) {
		if (_backgroundView.alpha > (1-percentComplete)) {
			_backgroundView.alpha = 1- percentComplete;
		}
		_fromImageView.frame = CGRectMake(_fromImageView.frame.origin.x,
		                                  _fromImageView.frame.origin.y,
		       _initialFromImageViewFrame.size.width * (1 - percentComplete),
		       _initialFromImageViewFrame.size.height * (1 - percentComplete));
		_fromImageView.center = CGPointMake(initialCenter.x + _movedCenterPoint.x, initialCenter.y + _movedCenterPoint.y);
		_fromImageView.contentMode = UIViewContentModeScaleAspectFill;
	} else {
		_backgroundView.alpha = 0.5;
		_fromImageView.center = CGPointMake(initialCenter.x + _movedCenterPoint.x, initialCenter.y + _movedCenterPoint.y);
	}
}

-(void)finishInteractiveTransition
{
	[super finishInteractiveTransition];

	[UIView animateWithDuration:0.3 animations:^{
		_fromImageView.frame = [_containerView convertRect:_toImageView.frame fromView:_toImageView.superview];
		_fromImageView.contentMode = UIViewContentModeScaleAspectFill;
		_backgroundView.alpha = 0;
	} completion:^(BOOL finished) {
		_toImageView.alpha = 1;
		[_backgroundView removeFromSuperview];
		[_fromImageView removeFromSuperview];
		[_context completeTransition:!_context.transitionWasCancelled];
		_context = nil;
	}];
}

-(void)cancelInteractiveTransition
{
	[super cancelInteractiveTransition];

	UINavigationController *fromViewController = (UINavigationController*)[self.context viewControllerForKey:UITransitionContextFromViewControllerKey];
	TKGalleryViewController *galleryController = (TKGalleryViewController *)[fromViewController.viewControllers firstObject];

	TKGalleryMediumView *image = [galleryController.mediumViews objectAtIndex:[galleryController currentPage]];

	image.alpha = 0;
	[UIView animateWithDuration:0.3 animations:^{
		_fromImageView.frame = _initialFromImageViewFrame;
		_fromImageView.contentMode = UIViewContentModeScaleAspectFill;
		_backgroundView.alpha = 1;
		fromViewController.view.alpha =1;
	} completion:^(BOOL finished) {
		image.alpha = 1;
		_toImageView.alpha = 1;
		[_backgroundView removeFromSuperview];
		[_fromImageView removeFromSuperview];
		[_context completeTransition:!_context.transitionWasCancelled];
		_context = nil;
	}];
}

@end

