//
//  TKToursListViewController.m
//  Travel
//
//  Created by Marek Stana on 10/25/16.
//  Copyright © 2016 Tripomatic. All rights reserved.
//

#import "TKToursListViewController.h"
#import "TKBrowserViewController.h"

#import <TravelKit/TravelKit.h>

#import "UIKit+TravelKit.h"

#import "TKGradientView.h"


#pragma mark -
#pragma mark Collection cell
#pragma mark -


#define kUILabelMaxWidth 260
#define MAIN_LABEL_RECT CGRectMake(18, 19, kUILabelMaxWidth, 20)
#define PADDING 10.0
#define BOTTOM_HEIGHT 40


@interface TKToursPaddingLabel : UILabel

@property (nonatomic) UIEdgeInsets textInsets;

@end


@implementation TKToursPaddingLabel

- (void)setTextInsets:(UIEdgeInsets)textInsets
{
	_textInsets = textInsets;
	[self invalidateIntrinsicContentSize];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
	UIEdgeInsets insets = self.textInsets;
	CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets)
					limitedToNumberOfLines:numberOfLines];

	rect.origin.x    -= insets.left;
	rect.origin.y    -= insets.top;
	rect.size.width  += (insets.left + insets.right);
	rect.size.height += (insets.top + insets.bottom);

	return rect;
}

- (void)drawTextInRect:(CGRect)rect
{
	[super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

- (void)setImageIcon:(UIImage *)image withText:(NSString *)strText withOffset:(float)offset
{
	strText = [@" " stringByAppendingString:strText];
	NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
	attachment.image = image;
	float offsetY = offset; // This can be dynamic with respect to size of image and UILabel
	attachment.bounds = CGRectIntegral( CGRectMake(0, offsetY, attachment.image.size.width, attachment.image.size.height));
	NSMutableAttributedString *attachmentString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
	NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:strText];
	[attachmentString appendAttributedString:myString];
	self.attributedText = attachmentString;
}

@end


@interface TKTourCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TKTour *tour;

@property (nonatomic, strong) UIView *topHolder;
@property (nonatomic, strong) UIView *bottomHolder;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) TKToursPaddingLabel *mainLabel;
@property (nonatomic, strong) TKToursPaddingLabel *ratingLabel;
@property (nonatomic, strong) TKToursPaddingLabel *priceLabel;
@property (nonatomic, strong) TKToursPaddingLabel *durationLabel;
@property (nonatomic, strong) TKGradientView *overlay;

@end


@implementation TKTourCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{

		self.backgroundColor = [UIColor whiteColor];
		self.layer.borderColor = [UIColor colorFromRGB:0xEAEAEA].CGColor;
		self.layer.borderWidth = 1;
		self.layer.cornerRadius = 8;
		self.clipsToBounds = YES;

		// TOP HOLDER

		_topHolder = [[UIView alloc] initWithFrame:self.bounds];
		_topHolder.height = self.bounds.size.height - BOTTOM_HEIGHT;
		_topHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_topHolder.backgroundColor = [UIColor whiteColor];
		[self addSubview:_topHolder];

		_imageView = [[UIImageView alloc] initWithFrame:_topHolder.bounds];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_imageView.clipsToBounds = YES;
		UIImage *placeholder = [UIImage imageNamed:@"activity_list-activities"];
		_imageView.image = placeholder;
		_imageView.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];

		[_topHolder addSubview:_imageView];

		_overlay = [[TKGradientView alloc] initWithFrame:_topHolder.bounds];
		_overlay.height *= 0.4;
		_overlay.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		_overlay.backgroundColor = [UIColor blackColor];
		[_topHolder addSubview:_overlay];
		_overlay.fromBottomEdge = 0;


		// BOTTOM HOLDER

		_bottomHolder = [[UIView alloc] initWithFrame:CGRectMake(0, _topHolder.height, self.bounds.size.width, BOTTOM_HEIGHT)];
		_bottomHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_bottomHolder];

		// Main label
		_mainLabel = [[TKToursPaddingLabel alloc] initWithFrame:CGRectMake(
		   _topHolder.bounds.origin.x,
		   _topHolder.bounds.origin.y + _topHolder.size.height*0.7,
		   _topHolder.size.width,
		   _topHolder.size.height *0.3
	   )];
		_mainLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		_mainLabel.textInsets = UIEdgeInsetsMake(0, 10, 0, 10);
		_mainLabel.font = [UIFont systemFontOfSize:18];
		_mainLabel.textColor = [UIColor whiteColor];
		_mainLabel.backgroundColor = [UIColor clearColor];
		_mainLabel.numberOfLines = 2;
		[_topHolder addSubview:_mainLabel];

		// Price label
		_priceLabel = [[TKToursPaddingLabel alloc] initWithFrame:_topHolder.bounds];
		_priceLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
		_priceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
		_priceLabel.font = [UIFont systemFontOfSize:21];
		_priceLabel.textColor = [UIColor whiteColor];
		_priceLabel.textInsets = UIEdgeInsetsMake(4, 8, 4, 8);
		_priceLabel.textAlignment = NSTextAlignmentCenter;
		_priceLabel.numberOfLines = 2;
		_priceLabel.layer.cornerRadius = 6;
		_priceLabel.clipsToBounds = YES;
		[_topHolder addSubview:_priceLabel];
		_priceLabel.top = _priceLabel.fromRightEdge = 7;

		// Rating label
		_ratingLabel = [[TKToursPaddingLabel alloc] init];
		_ratingLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
		_ratingLabel.font = [UIFont lightSystemFontOfSize:16];
		_ratingLabel.textColor = [UIColor grayColor];
		_ratingLabel.numberOfLines = 1;
		[_bottomHolder addSubview:_ratingLabel];

		// Duration label
		_durationLabel = [[TKToursPaddingLabel alloc] init];
		_durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
		_durationLabel.font = [UIFont lightSystemFontOfSize:16];
		_durationLabel.textColor = [UIColor grayColor];
		_durationLabel.numberOfLines = 1;
		[_bottomHolder addSubview:_durationLabel];
	}

	return self;
}

- (void)setTour:(TKTour *)tour
{
	_tour = tour;

	_mainLabel.text = _tour.title;
	_mainLabel.height = [_mainLabel expandedSizeOfText].height;
	_mainLabel.fromBottomEdge = 6;

	double price = [_tour.price doubleValue];

	_priceLabel.text = (price) ?
		[NSString stringWithFormat:@"$%.0f", price] :
		NSLocalizedString(@"Free", "Price label");

	if (_tour.originalPrice && _tour.originalPrice.floatValue != _tour.price.floatValue)
	{
		NSString *originalPrice = [NSString stringWithFormat:@"\n$%.0f", _tour.originalPrice.doubleValue] ?: @"";
		NSString *discountPrice = _priceLabel.text ?: @"";

		NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];

		[str appendAttributedString:[[NSAttributedString alloc] initWithString:discountPrice
		attributes:@{
			NSFontAttributeName: [UIFont boldSystemFontOfSize:21],
			NSForegroundColorAttributeName: [UIColor whiteColor],
			NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone),
			NSBaselineOffsetAttributeName: @0,
		}]];

		NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		para.lineHeightMultiple = 0.8;
		para.alignment = NSTextAlignmentCenter;

		[str appendAttributedString:[[NSAttributedString alloc] initWithString:originalPrice
		attributes:@{
			NSFontAttributeName: [UIFont systemFontOfSize:16],
			NSForegroundColorAttributeName: [UIColor colorFromRGB:0xFF3D00],
			NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
			NSBaselineOffsetAttributeName: @0,
			NSParagraphStyleAttributeName: para,
		}]];

		_priceLabel.attributedText = str;
	}

	_priceLabel.size = [_priceLabel sizeThatFits:CGSizeMake(250, 400)];
	_priceLabel.fromRightEdge = _priceLabel.top = 7;

	[_bottomHolder.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	UIImageView *starView = nil;
	UIImage *starEmpty = [UIImage imageNamed:@"rating_star-empty"];
	UIImage *starFull = [UIImage imageNamed:@"rating_star-full"];

	int stars = roundf([_tour.rating floatValue]);

	for (uint i = 0; i < 5; i++) {
		starView = [[UIImageView alloc] initWithImage:  i < stars ? starFull : starEmpty ];
		[_bottomHolder addSubview:starView];
		starView.center = CGPointMake(i*starView.size.width+starView.size.width/2.0 + PADDING, _bottomHolder.height/2.0-1);
	}

//	_ratingLabel.text = [NSString stringWithFormat:@"%@", _tour.ratingCount.stringValue];
//	[_ratingLabel sizeToFit];
//	_ratingLabel.center = CGPointMake((starView.width * 5 + PADDING) + _ratingLabel.width/2.0 + PADDING*0.6, _bottomHolder.height/2.0);
//	[_bottomHolder addSubview:_ratingLabel];

	// Set duration
	NSString *stringDuration = _tour.duration;

	UIImage *clockImage = [[UIImage imageNamed:@"activity-header-clock-small"]
		imageTintedWithColor:[UIColor grayColor]];

	[_durationLabel setImageIcon:clockImage withText:stringDuration withOffset:-2];
	[_durationLabel sizeToFit];
	[_bottomHolder addCenteredSubview:_durationLabel];
	_durationLabel.fromRightEdge = PADDING+3;

	_imageView.contentMode = UIViewContentModeCenter;
	__weak typeof (self) weakSelf = self;

	_imageView.image = [UIImage imageNamed:@"activity_list-activities"];
	[_imageView setImageWithURL:_tour.photoURL completion:^(UIImage *i) {

		if (!i) return;

		weakSelf.imageView.contentMode = UIViewContentModeScaleAspectFill;

		CATransition *transition = [CATransition animation];
		transition.duration = .35f;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		transition.type = kCATransitionFade;
		transition.removedOnCompletion = YES;

		if (weakSelf.imageView.layer.animationKeys.count == 0)
			[weakSelf.imageView.layer addAnimation:transition forKey:nil];
  }];
}

- (void)setHighlighted:(BOOL)highlighted
{
	self.backgroundColor = (highlighted) ?
		[UIColor colorWithWhite:0.94 alpha:1] : [UIColor whiteColor];
	self.alpha = (highlighted) ? 0.88:1;
}

@end


#pragma mark -
#pragma mark - View Controller -
#pragma mark -


@interface TKToursListViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
                                         UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray<TKTour *> *displayedTours;

@property (nonatomic, strong) UILabel *statusMessage;
@property (nonatomic, strong) UIImageView *statusImage;
@property (nonatomic, strong) UIView *statusContainer;

@property (atomic) TKToursQuerySorting sortingChoice;

@property (nonatomic, strong) UIAlertController *sortingAlert;

// 3D touch
@property (nonatomic, strong) id<UIViewControllerPreviewing> previewingContext;

@end


@implementation TKToursListViewController


#pragma mark - View lifecycle


- (void)loadView
{
	[super loadView];

	self.title = NSLocalizedString(@"Tours", @"View title");
	self.view.backgroundColor = [UIColor colorFromRGB:0xFAFAFA];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
		[UIImage templateImageNamed:@"navbar_icon-sort"] style:UIBarButtonItemStylePlain
			target:self action:@selector(showSortingOptions)];

	BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

	// View image
	_statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activity_list-activities"]];
	_statusImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

	// View message
	_statusMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width-40, 62)];
	_statusMessage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	_statusMessage.textColor = [UIColor colorWithWhite:.7 alpha:1];
	_statusMessage.backgroundColor = [UIColor clearColor];
	_statusMessage.numberOfLines = 3;
	_statusMessage.textAlignment = NSTextAlignmentCenter;
	_statusMessage.font = [UIFont systemFontOfSize:22];
	_statusMessage.adjustsFontSizeToFitWidth = YES;
	_statusMessage.minimumScaleFactor = 22/26.0;
	_statusMessage.height = [_statusMessage heightForNumberOfLines:2]+20;

	// View status container
	_statusContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(_statusImage.width, _statusMessage.width), 0)];
	_statusContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	_statusContainer.hidden = YES;

	[_statusContainer addCenteredSubview:_statusImage];
	_statusImage.top = 0;

	[_statusContainer addCenteredSubview:_statusMessage];
	_statusMessage.top = _statusImage.bottom;

	_statusContainer.height = _statusImage.bottom;
	[self.view addCenteredSubview:_statusContainer];

	CGFloat margin = isIPad ? 12:8;
	NSInteger itemsPerLine = isIPad ? 3:1;
	CGFloat itemWidth = floorf((self.view.width - (itemsPerLine+1)*margin) / itemsPerLine);

	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	layout.itemSize = CGSizeMake(itemWidth, 260);
	layout.minimumInteritemSpacing = margin;
	layout.minimumLineSpacing = margin;
	layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);

	_collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
	[_collectionView registerClass:[TKTourCollectionViewCell class] forCellWithReuseIdentifier:@"TKTourCell"];

	_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_collectionView.backgroundColor = [UIColor clearColor];
	_collectionView.delegate = self;
	_collectionView.dataSource = self;
	_collectionView.scrollsToTop = YES;
	[self.view insertSubview:_collectionView atIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	if ([self isForceTouchAvailable])
		_previewingContext = [self registerForPreviewingWithDelegate:self sourceView:_collectionView];

	[self fetchData];
}

- (void)fetchData
{
	static NSCache *dataCache = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dataCache = [NSCache new];
		dataCache.countLimit = 7;
	});

	TKToursQuery *query = [TKToursQuery new];
	query.parentID = @"city:1";
	query.sortingType = _sortingChoice;

	NSNumber *cacheKey = @(query.hash);

	// Look for cached data...

	NSArray *tours = [dataCache objectForKey:cacheKey];

	if (tours.count) {
		_displayedTours = tours;
		[self reloadDisplayedData];
		return;
	}

	// ...otherwise ask API for the data

	[[TravelKit sharedKit] toursForQuery:query completion:^(NSArray<TKTour *> *tours, NSError *error) {

		if (error || !tours.count)
		{
			_displayedTours = @[ ];
		}
		else _displayedTours = tours;

		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self reloadDisplayedData];
		}];

	}];
}


#pragma mark - Collection view delegate


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	TKTourCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"TKTourCell" forIndexPath:indexPath];

	cell.tour = [_displayedTours safeObjectAtIndex:indexPath.row];
	cell.tag = indexPath.row;

	return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	_collectionView.hidden = _displayedTours.count == 0;
	_statusContainer.hidden = !_collectionView.isHidden;
//	if ([ConnectionManager isConnected]) {
		_statusMessage.text = NSLocalizedString(@"No tours found\nfor this day", "Empty Tours list message");
//	} else {
//		_statusButton.hidden = YES;
//		_statusMessage.text = NSLocalizedString(@"This content is only available online.", "Empty Tours list message - offline state");
//	}
	return _displayedTours.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	TKTour *tour = [_displayedTours safeObjectAtIndex:indexPath.item];

	if (tour) [self presentTour:tour];
}

- (void)reloadDisplayedData
{
	[_collectionView scrollRectToVisible:CGRectZero animated:NO];
	[_collectionView reloadData];
}


#pragma mark - Sorting


- (void)showSortingOptions
{
	_sortingAlert = [UIAlertController alertControllerWithTitle:
	    NSLocalizedString(@"Reorder Tours by", @"Sorting option heading")
	        message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		_sortingAlert.popoverPresentationController.sourceView = self.view;
		_sortingAlert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
		_sortingAlert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
	}

	[_sortingAlert addAction:[UIAlertAction actionWithTitle:
		NSLocalizedString(@"Cancel", @"Button title") style:UIAlertActionStyleCancel handler:nil]];

	[_sortingAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Rating", @"Filter title")
	  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self updateDisplayedResultsWithSortingType:TKToursQuerySortingRating];
	}]];

	[_sortingAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Price", @"Filter title")
	  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self updateDisplayedResultsWithSortingType:TKToursQuerySortingPrice];
	}]];

	[_sortingAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Popularity", @"Filter title")
	  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self updateDisplayedResultsWithSortingType:TKToursQuerySortingTopSellers];
	}]];

	[self presentViewController:_sortingAlert animated:YES completion:nil];
}

- (void)updateDisplayedResultsWithSortingType:(TKToursQuerySorting)type
{
	_sortingChoice = type;
	[self fetchData];
}


#pragma mark - Tour presentation


- (void)presentTour:(TKTour *)tour
{
	TKBrowserViewController *vc = [self initializeControllerForTour:tour];
	[self commitTourViewController:vc];
}

- (TKBrowserViewController *)initializeControllerForTour:(TKTour *)tour
{
	NSURL *url = tour.URL;

	return [[TKBrowserViewController alloc] initWithURL:url];
}

- (void)commitTourViewController:(TKBrowserViewController *)controller
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:controller];
		nc.modalPresentationStyle = UIModalPresentationPageSheet;
		[self presentViewController:nc animated:YES completion:nil];
	}
	else [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - View controller previewing delegate


- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
	if (self.presentedViewController) return nil;

	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];

	TKTour *tour = [_displayedTours safeObjectAtIndex:indexPath.item];

	if (!tour) return nil;

	previewingContext.sourceRect = [_collectionView cellForItemAtIndexPath:indexPath].frame;

	return [self initializeControllerForTour:tour];
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
	if (![viewControllerToCommit isKindOfClass:[TKBrowserViewController class]])
		return;

	[self commitTourViewController:(id)viewControllerToCommit];
}

@end
