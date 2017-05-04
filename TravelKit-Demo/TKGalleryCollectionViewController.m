//
//  TKGalleryCollectionViewController.m
//  Travel
//
//  Created by Marek Stana on 10/25/16.
//  Copyright © 2016 Tripomatic. All rights reserved.
//

#import "TKNavigationController.h"
#import "TKGalleryCollectionViewController.h"
#import "TKGalleryViewController.h"
//#import "VR360VideoController.h"

#import "TKGalleryTransitions.h"

#import "TKGalleryMediumView.h"

#import "UIKit+TravelKit.h"

//#import "TripomaticImageView.h"
//#import <SVIndefiniteAnimatedView.h>


static NSString *photoCellIdentifier = @"GalleryCollectionPhotoCell";


@interface TKGalleryCollectionViewCell ()

@property (nonatomic, strong) UIView *highlightedView;
@property (nonatomic, strong) UIImageView *placeholderImageView;

@end


@implementation TKGalleryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.isAccessibilityElement = YES;
		self.accessibilityIdentifier = @"GalleryCollectionCell";
		self.accessibilityHint = @"Tap to show details";

		_imageView = [[TKPlaceImageView alloc] initWithFrame:self.bounds];
//		_imageView.crossfade = YES;
		[self addSubview:_imageView];

		_highlightedView = [[UIView alloc] initWithFrame:self.bounds];
		_highlightedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_highlightedView.backgroundColor = [UIColor blackColor];
		_highlightedView.alpha = 0;
		[self addSubview:_highlightedView];

		_placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
		_placeholderImageView.contentMode = UIViewContentModeCenter;
		_placeholderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
		_placeholderImageView.hidden = YES;
		[self addSubview:_placeholderImageView];
		_placeholderImageView.fromBottomEdge = _placeholderImageView.fromBottomEdge = 0;

	}

	return self;
}

- (void)setImageForMedium:(TKMedium *)medium
{
//	__weak typeof(self) self_ = self;

	[_imageView setImageForMedium:medium withSize:CGSizeMake(400, 400)];
//	[_tripomaticImageView setMediumImage:medium type:ImageTypeGalleryPreview completion:^(Medium *m) {
//		NSString *imageName =
//			(m.type == MediumTypeVideo360) ? @"gallery_icon-video_360" :
//			(m.type == MediumTypeImage360) ? @"gallery_icon-image_360" :
//			(m.type == MediumTypeVideo)    ? @"gallery_icon-video"     : nil;
//		self_.placeholderImageView.image =
//			(imageName) ? [UIImage imageNamed:imageName] : nil;
//		self_.placeholderImageView.hidden = imageName == nil;
//		self_.backgroundOverlayBottom.hidden = m.type == MediumTypeImage;
//		[indicator removeFromSuperview];
//	}];
}

- (void)setHighlighted:(BOOL)highlighted
{
	_highlightedView.alpha = (highlighted) ? 0.3 : 0;
}

- (void)setSelected:(BOOL)selected
{
	_highlightedView.alpha = (selected) ? 0.3 : 0;
}

- (void)prepareForReuse
{
//	_imageView.image = nil;
	_highlightedView.alpha = 0;
}

@end


@interface TKGalleryCollectionViewController () <UICollectionViewDelegate,
                                                 UICollectionViewDataSource,
                                                 UICollectionViewDelegateFlowLayout,
                                                 UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) TKPlace *place;
@property (nonatomic, strong) NSArray<TKMedium *> *media;

@end


@implementation TKGalleryCollectionViewController

- (instancetype)initWithPlace:(TKPlace *)place media:(NSArray<TKMedium *> *)media
{
	if (self = [super init])
	{
		_place = place;
		_media = media;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor whiteColor];

	self.title = _place.name;

//	NSUInteger itemsPerLine = (isIPad()) ? 4:3;
	NSUInteger itemsPerLine = 3;
//	CGFloat spacing = isIPad()?12:3;
	CGFloat spacing = 3;
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

	CGFloat itemSize = floor((self.view.width-(itemsPerLine-1)*spacing) / itemsPerLine);
	layout.itemSize = CGSizeMake(itemSize, itemSize);

	layout.minimumInteritemSpacing = spacing;
	layout.minimumLineSpacing = spacing;

	_collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];

	[_collectionView registerClass:[TKGalleryCollectionViewCell class] forCellWithReuseIdentifier:photoCellIdentifier];
	_collectionView.backgroundColor = [UIColor clearColor];
	_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
	_collectionView.clipsToBounds = NO;
	_collectionView.alwaysBounceVertical = YES;
	_collectionView.scrollsToTop = YES;
	_collectionView.showsVerticalScrollIndicator = YES;
//	_collectionView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0);
//	_collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(topOffset, 0, 0, 0);
	[self.view addCenteredSubview:_collectionView];

	self.navigationItem.leftBarButtonItem = [UIBarButtonItem closeBarButtonItemWithTarget:self selector:@selector(dismiss)];

//	UIView *topContentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, topOffset)];
//	topContentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//	topContentContainer.backgroundColor = [UIColor whiteColor];
//	topContentContainer.clipsToBounds = NO;
//	[self.view addSubview:topContentContainer];

	[self refreshContent];
}

- (void)refreshContent
{
	[_collectionView scrollRectToVisible:CGRectZero animated:NO];
	[_collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _media.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	TKGalleryCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:photoCellIdentifier forIndexPath:indexPath];
	[cell setImageForMedium:[_media safeObjectAtIndex:indexPath.row]];
	cell.tag = indexPath.row;
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[UIView animateWithDuration:0.25 animations:^{
		[self setNeedsStatusBarAppearanceUpdate];
	}];

	TKMedium *medium = [_media safeObjectAtIndex:indexPath.row];

	if (medium.type == TKMediumTypeVideo360) {
//		VR360VideoController *vc = [[VR360VideoController alloc] initWithMedium:medium];
//
//		[self presentViewController:vc animated:YES completion:^{
//			[_collectionView deselectItemAtIndexPath:indexPath animated:NO];
//		}];
		return;
	}

	TKGalleryViewController *vc = [[TKGalleryViewController alloc] initWithPlace:_place media:_media defaultMedium:medium];
	UINavigationController *nc = [[TKNavigationController alloc] initWithRootViewController:vc];
	nc.transitioningDelegate = self;
	nc.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:nc animated:YES completion:^{
		[_collectionView deselectItemAtIndexPath:indexPath animated:NO];
	}];
}

- (void)dealloc
{
	_collectionView = nil;
	_media = nil;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationSlide;
}


#pragma mark - Actions


- (void)dismiss
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Transitions delegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
	presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{

	TKGalleryPresentTransition *detail = [[TKGalleryPresentTransition alloc] init];

	UICollectionViewCell *undefinedCell = [_collectionView cellForItemAtIndexPath: [_collectionView indexPathsForSelectedItems].firstObject];

	if (![undefinedCell isKindOfClass: [TKGalleryCollectionViewCell class]]) return nil;

	TKGalleryCollectionViewCell *cell = (TKGalleryCollectionViewCell *)undefinedCell;

	if (!cell.imageView.image) return nil;

	detail.fromImageView = cell.imageView;

	return detail;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
	TKGalleryViewController *controller = dismissed.childViewControllers.lastObject ?: self.presentedViewController;

	if (![controller isKindOfClass:[TKGalleryViewController class]]) return nil;
	if (![controller currentImage]) return nil;

	NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[controller currentPage] inSection:0];

	UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
	if (!cell) {
		// This assures to reload the cell when it's not loaded normally
		// - in case that user scrolls to the end of the Gallery with a lot of items inside
		[_collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
		cell = [_collectionView cellForItemAtIndexPath:indexPath];
	}

	if (cell) // Scroll to the cell
		[_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:
			UICollectionViewScrollPositionCenteredVertically animated:NO];

	if (![cell isKindOfClass: [TKGalleryCollectionViewCell class]]) return nil;

	TKGalleryCollectionViewCell *galleryCell = (id)cell;

	if (!galleryCell.imageView.image) return nil;

	TKGalleryDismissTransition *detail = [[TKGalleryDismissTransition alloc] init];
	detail.interactive = controller.interactive;
	controller.interactiveTransition = detail;

	return detail;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
	return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
	TKGalleryDismissTransition *animatorDismiss = (TKGalleryDismissTransition *)animator;
	if (animatorDismiss.interactive)
		return animatorDismiss;

	return nil;
}

@end
