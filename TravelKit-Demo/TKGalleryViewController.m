//
//  GalleryViewController.m
//  Tripomatic
//
//  Created by Michal Zelinka on 17/4/2014.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <TravelKit/TravelKit.h>

#import "UIKit+TravelKit.h"

#import "TKGalleryViewController.h"
#import "TKGalleryCollectionViewController.h"
#import "TKVR360VideoController.h"

#import "TKGalleryMediumView.h"
//#import "PageIndicator.h"

#import <objc/runtime.h>

#pragma mark - Private category








#pragma mark - Paging view

@class PagingView;

@protocol PagingViewDelegate <NSObject>
@optional
- (void)pagingViewFrameUpdated:(PagingView *)pagingView;

@end

@interface PagingView : UIScrollView

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (atomic) BOOL autoresizesPages;
@property (nonatomic, weak) id<PagingViewDelegate, UIScrollViewDelegate> delegate;

@end




@implementation PagingView

@dynamic delegate;

- (void)setFrame:(CGRect)frame
{
	BOOL boundsChanged = (frame.size.width != self.width || frame.size.height != self.height);

	NSInteger currentPage = self.contentOffset.x / self.width;

	[super setFrame:frame];
	if (!self.pagingEnabled) return;

	if (!boundsChanged) return;

	self.contentSize = CGSizeMake(_numberOfPages * self.frame.size.width, self.frame.size.height);

	self.contentOffset = CGPointMake(currentPage * self.width, 0);

	if (_autoresizesPages)
		for (UIView *v in self.subviews)
			[v setFrame:CGRectMake([self.subviews indexOfObject:v] * self.width, 0, self.width, self.height)];

	if ([self.delegate respondsToSelector:@selector(pagingViewFrameUpdated:)])
		[self.delegate pagingViewFrameUpdated:self];
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
	_numberOfPages = numberOfPages;
	self.contentSize = CGSizeMake(_numberOfPages * self.frame.size.width, self.frame.size.height);
}

@end





@interface TKGalleryNavigationController : UINavigationController
@end

@implementation TKGalleryNavigationController

- (BOOL)prefersStatusBarHidden
{
	return [self isNavigationBarHidden];
}

@end









@interface TKGalleryViewController () <UIScrollViewDelegate, PagingViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) TKPlace *place;
@property (nonatomic, strong) TKMedium *defaultMedium;
@property (nonatomic, strong) NSArray<TKMedium *> *media;

@property (nonatomic, strong) PagingView *scrollView;
@property (nonatomic, strong) UILabel *attributionLabel;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint lastPoint;

@property (nonatomic, assign) BOOL fullscreen;

@end


#pragma mark - Implementation


@implementation TKGalleryViewController

- (instancetype)initWithPlace:(TKPlace *)place media:(NSArray<TKMedium *> *)media defaultMedium:(TKMedium *)medium
{
	if (self = [super init])
	{
		_place = place;
		_defaultMedium = medium;
		_media = media;
	}

	return self;
}


#pragma mark - View lifecycle


- (void)loadView
{
	object_setClass(self.navigationController, [TKGalleryNavigationController class]);

	[super loadView];

	self.title = _place.name;

	self.view.backgroundColor = [UIColor colorFromRGB:0x131313];
	self.automaticallyAdjustsScrollViewInsets = NO;

	_scrollView = [[PagingView alloc] initWithFrame:self.view.bounds];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_scrollView];
	_scrollView.pagingEnabled = YES;
	_scrollView.autoresizesPages = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.delegate = self;

	[_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTapped:)]];

	_panGesture = [UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(scrollPanned:)];
	_panGesture.delegate = self;
	[_scrollView addGestureRecognizer:_panGesture];

	_mediumViews = @[ ];

	// Add attribution label

	_attributionLabel = [[UILabel alloc] initWithFrame:_scrollView.bounds];
	_attributionLabel.height = 100;
	_attributionLabel.numberOfLines = 0;
	_attributionLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_attributionLabel];
	_attributionLabel.fromBottomEdge = 10;

	// Refresh Gallery content
	[self refreshContent];

	self.transitioningDelegate = self.parentViewController.transitioningDelegate;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.leftBarButtonItem = [UIBarButtonItem
		closeBarButtonItemWithTarget:self selector:@selector(dismiss)];

	self.fullscreen = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
	return _fullscreen && self.view.superview;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationSlide;
}


#pragma mark - Setters


- (void)setPageIndicatorHidden:(BOOL)hidden animated:(BOOL)animated
{
	if (!animated) {
		_attributionLabel.transform = (hidden) ? CGAffineTransformMakeTranslation(0, 8) : CGAffineTransformIdentity;
		_attributionLabel.alpha = (hidden) ? 0:1;

	} else
		[UIView animateWithDuration:0.24 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			_attributionLabel.transform = (hidden) ? CGAffineTransformMakeTranslation(0, 8) : CGAffineTransformIdentity;
			_attributionLabel.alpha = (hidden) ? 0:1;
		} completion:nil];
}


#pragma mark - Getters


- (NSUInteger)currentPage
{
	return MAX(0, MIN(round(_scrollView.contentOffset.x / _scrollView.frame.size.width), _media.count-1));
}

- (UIImage *)currentImage
{
	TKGalleryMediumView *current = [_mediumViews safeObjectAtIndex:[self currentPage]];
	return current.image;
}


#pragma mark - Scrollview delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self updatePageInformation];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self checkDisplayedWithSurrounding];
}

-(CGFloat)maxProgressDistance
{
	CGFloat dist = sqrt ( pow(self.view.frame.size.width, 2) + pow((self.view.frame.size.height), 2) );
	return dist/2;
}

#pragma mark - Actions

-(void) dismiss
{
	_interactive = NO;
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updatePageInformation
{
	NSInteger currentPage = [self currentPage];

	[self updateAttributionWithMedium:[_media safeObjectAtIndex:currentPage]];
	[[_mediumViews safeObjectAtIndex:currentPage-1] checkImageDisplay];
	[[_mediumViews safeObjectAtIndex:currentPage] checkImageDisplay];
	[[_mediumViews safeObjectAtIndex:currentPage+1] checkImageDisplay];

//	if ([ConnectionManager isWifi])
//		[[_mediumViews safeObjectAtIndex:currentPage] playVideo];
}

- (void)checkDisplayedWithSurrounding
{
	NSInteger currentPage = [self currentPage];
	TKMedium *currentMedium = [_media safeObjectAtIndex:currentPage];

	[[_mediumViews safeObjectAtIndex:currentPage-1] resetImageDisplay];
	[[_mediumViews safeObjectAtIndex:currentPage] checkImageDisplay];
	[[_mediumViews safeObjectAtIndex:currentPage+1] resetImageDisplay];

	if (currentMedium.type == TKMediumTypeVideo360)
		[self setFullscreen:NO];
}

- (void)updateAttributionWithMedium:(TKMedium *)medium
{
	NSString *title = medium.title ?: _place.name ?: @"Untitled picture";

	NSRange newLine = [title rangeOfString:@"\n"];
	if (newLine.location != NSNotFound)
		title = [title substringToIndex:newLine.location];

//	NSUInteger titleLimit = (isIPad()) ? 360:150;
	NSUInteger titleLimit = 150;

	if (title.length > titleLimit)
		title = [[[title substringToIndex:titleLimit-2]
				  trimmedString] stringByAppendingString:@"…"];

	NSString *author = medium.author;
	NSString *license = medium.license;
	NSString *provider = medium.provider;

	if (author.length > 45)
		author = [[[author substringToIndex:44]
				   trimmedString] stringByAppendingString:@"…"];

	if ([provider isEqualToString:@"twobits"] ||
	    [provider isEqualToString:@"tripomatic"]) provider = @"Tripomatic";
	else if ([provider isEqualToString:@"wikipedia"]) provider = @"Wikimedia Commons";
	else if ([provider hasPrefix:@"booking"]) { author = nil; provider = @"Booking.com"; }
	else if ([provider isEqualToString:@"google_street_view"]) provider = @"Google Street View";
	else if ([provider isEqualToString:@"user_upload"]) provider = @"User Upload";
	else if ([provider isEqualToString:@"viator"]) { author = nil; provider = @"Viator"; }

	NSMutableString *formattedString = [NSMutableString stringWithString:title];
	if (author) [formattedString appendFormat:@"\n%@: %@", NSLocalizedString(@"Author", @"View label"), author];
	if (provider) [formattedString appendFormat:@"\n%@: %@", NSLocalizedString(@"Source", @"View label"), provider];
	if (license) [formattedString appendFormat:@"\n%@", license];

	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.hyphenationFactor = 1.0f;
	style.lineSpacing = -5;
	style.alignment = NSTextAlignmentLeft;
	style.headIndent = 10.0f;
	style.tailIndent = -16.0f;
	style.firstLineHeadIndent = 10.0f;

	NSMutableAttributedString *str = [[NSMutableAttributedString alloc]
	initWithString:formattedString attributes:@{
		NSParagraphStyleAttributeName: style,
		NSForegroundColorAttributeName: [UIColor whiteColor],
		NSFontAttributeName: [UIFont systemFontOfSize:12],
	}];

	NSRange r = [formattedString rangeOfString:title];
	if (r.location != NSNotFound) [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:r];

	_attributionLabel.attributedText = str;
	_attributionLabel.height = [_attributionLabel expandedSizeOfText].height;
	CGAffineTransform oldTransform = _attributionLabel.transform;
	_attributionLabel.transform = CGAffineTransformIdentity;
	_attributionLabel.fromBottomEdge = 10;
	_attributionLabel.transform = oldTransform;
}

- (void)refreshContent
{
	_scrollView.numberOfPages = _media.count;
	NSMutableArray *views = [NSMutableArray arrayWithCapacity:_media.count];

	CGPoint baseScroll = CGPointZero;

	for (TKMedium *m in _media)
	{
		TKGalleryMediumView *v = [[TKGalleryMediumView alloc] initWithFrame:_scrollView.bounds medium:m];
		v.left = _scrollView.width * [_media indexOfObject:m];
		[self.scrollView addSubview:v];
		[views addObject:v];

		if ([m.ID isEqualToString:_defaultMedium.ID])
			baseScroll = v.frame.origin;
	}

	_mediumViews = views;

	self.scrollView.contentSize = CGSizeMake(_scrollView.numberOfPages * _scrollView.width, _scrollView.height);
	self.scrollView.contentOffset = baseScroll;

	[self updatePageInformation];
}

- (void)setFullscreen:(BOOL)fullscreen
{
	_fullscreen = fullscreen;

	[self.navigationController setNavigationBarHidden:fullscreen animated:YES];
	[self setNeedsStatusBarAppearanceUpdate];
	[self setPageIndicatorHidden:fullscreen animated:YES];
}


#pragma mark - Gesture recognizers


- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gesture
{
	BOOL should = YES;

	TKGalleryMediumView *mediumView = [_mediumViews safeObjectAtIndex:self.currentPage];

	if (mediumView.zoomScale > 1)
		should = NO;

	CGPoint velocity = [gesture velocityInView:_scrollView];

	if (should && fabs(velocity.y) <= fabs(velocity.x))
		should = NO;

	return should;
}

- (void)scrollPanned:(UIPanGestureRecognizer *)gesture
{
	CGPoint currentPoint = [gesture translationInView:_scrollView];
	self.interactiveTransition.movedCenterPoint = currentPoint;
	double dist = sqrt ( pow((_startPoint.x-currentPoint.x), 2) + pow((_startPoint.y-currentPoint.y), 2) );
	CGFloat percentageProgress = ((dist*100)/[self maxProgressDistance])/100;

	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		_interactive = YES;
		self.fullscreen = YES;

		[self dismissViewControllerAnimated:YES completion:nil];
		self.startPoint = [gesture translationInView:self.view];
	}

	if (gesture.state == UIGestureRecognizerStateChanged)
	{
		[self.interactiveTransition updateInteractiveTransition:percentageProgress];
		self.lastPoint = [gesture translationInView:_scrollView];
	}

	if (gesture.state == UIGestureRecognizerStateEnded)
	{
		if (percentageProgress > 0.35 || ABS([gesture velocityInView:_scrollView].y) > 200)
			[self.interactiveTransition finishInteractiveTransition];
		else [self.interactiveTransition cancelInteractiveTransition];

		self.interactiveTransition = nil;
	}
}

- (void)scrollTapped:(UITapGestureRecognizer *)gesture
{
	TKMedium *currentMedium = [_media safeObjectAtIndex:[self currentPage]];

	// Special flow for 360 Video

	if (currentMedium.type == TKMediumTypeVideo360) {
//		VR360VideoController *vc = [[VR360VideoController alloc] initWithMedium:currentMedium];
//		[self presentViewController:vc animated:YES completion:nil];
		return;
	}

	// Special action for Video

	if (currentMedium.type == TKMediumTypeVideo) {
		TKGalleryMediumView *mediumView = [_mediumViews safeObjectAtIndex:[self currentPage]];
		[mediumView playPauseVideo];
	}

	// Decide further behaviour

	CGPoint touchPoint = [gesture locationInView:_attributionLabel];

	// Attribution tapped with valid link
	if (!_fullscreen && [_attributionLabel pointInside:touchPoint withEvent:nil] && currentMedium.originURL)
		[[UIApplication sharedApplication] openURL:currentMedium.originURL];

	// Scroll tapped
	else self.fullscreen = !_fullscreen;
}


#pragma mark - Orientation


//- (BOOL)shouldAutorotate
//{
//	return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//	return UIInterfaceOrientationMaskAllButUpsideDown;
//}

- (void)dealloc
{
	_media = nil;
	_scrollView.delegate = nil;
	_scrollView = nil;
}

@end
