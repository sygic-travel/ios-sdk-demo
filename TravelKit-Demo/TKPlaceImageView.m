//
//  TKPlaceImageView.m
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 06/04/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <TravelKit/TravelKit.h>
#import "TKPlaceImageView.h"
#import "UIKit+TravelKit.h"


@interface TKPlaceImageView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *categoryLabel;

@end


@implementation TKPlaceImageView

- (instancetype)init
{
	if (self = [super init])
		[self tk_initialise];

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
		[self tk_initialise];

	return self;
}

- (void)tk_initialise
{
	CGFloat size = MIN(self.width, self.height);
	CGFloat fontSize =
		(size >= 300) ? 192 :
		(size >= 200) ? 96 :
		(size >= 100) ? 48 :
		(size >= 50) ? 36 :
		(size >= 30) ? 18 : 10;

	_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:_imageView];

	_categoryLabel = [[UILabel alloc] initWithFrame:self.bounds];
	_categoryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	CGFloat alpha = (size > 100) ? 0.2 : 1.0;
	_categoryLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
	_categoryLabel.textAlignment = NSTextAlignmentCenter;
	_categoryLabel.font = [UIFont fontWithName:@"MapMarkers" size:fontSize];
	[self addSubview:_categoryLabel];
}

- (UIImage *)image
{
	return _imageView.image;
}

- (void)setFrame:(CGRect)frame
{
	super.frame = frame;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
	super.contentMode = _imageView.contentMode = contentMode;
}

- (void)setImageForMedium:(TKMedium *)medium withSize:(CGSize)size
{
	[_imageView setImageWithMediumImage:medium size:size completion:nil];
}

- (void)setImageForMedium:(TKMedium *)medium withSize:(CGSize)size completion:(void (^)(UIImage *))completion
{
	[_imageView setImageWithMediumImage:medium size:size completion:completion];
}

- (void)setImageForPlace:(TKPlace *)place withSize:(CGSize)size
{
	if (!place) return;

	__weak typeof(self) ws = self;

	[ws.imageView.layer removeAllAnimations];

	_categoryLabel.text = [self iconFontCodeForPlace:place];
	_categoryLabel.transform = CGAffineTransformIdentity;
	_categoryLabel.alpha = 1.0;
	_imageView.image = nil;
	_imageView.backgroundColor = [UIColor colorFromRGB:place.displayableHexColor];

	void (^completion)(UIImage *) = ^(UIImage *i) {

		if (!i) return;

		[UIView animateWithDuration:.1 animations:^{
			ws.categoryLabel.transform = CGAffineTransformMakeTranslation(0, 16);
			ws.categoryLabel.alpha = 0.0;
		}];

		CATransition *transition = [CATransition animation];
		transition.duration = .35f;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		transition.type = kCATransitionFade;
		transition.removedOnCompletion = YES;

		[ws.imageView.layer addAnimation:transition forKey:@"imageTransition"];
	};

	if (size.width <= 250 && size.height <= 250) {

		NSString *urlString = [NSString stringWithFormat:@"http://media-cdn.sygictraveldata.com/photo/%@", place.ID];
		NSURL *url = [NSURL URLWithString:urlString];

		[_imageView setImageWithURL:url completion:completion];
	}

//	else if (place.detail.mainMedia.count)
//	{
//		[ws.imageView setImageWithMediumImage:place.detail.mainMedia.firstObject size:size completion:completion];
//	}

	else
	[[TravelKit sharedKit] mediaForPlaceWithID:place.ID completion:^(NSArray<TKMedium *> *media, NSError *error) {

		if (!media.count) return;

		[ws.imageView setImageWithMediumImage:media.firstObject size:size completion:completion];
	}];
}

- (NSString *)iconFontCodeForPlace:(TKPlace *)place
{
	static NSDictionary *iconDictionary = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{

		iconDictionary = @{
			// Categories
			@(TKPlaceCategoryDiscovering): @"\ue900",
			@(TKPlaceCategorySightseeing): @"\ue901",
			@(TKPlaceCategoryGoingOut): @"\ue902",
			@(TKPlaceCategoryEating): @"\ue903",
			@(TKPlaceCategoryHiking): @"\ue904",
			@(TKPlaceCategoryPlaying): @"\ue905",
			@(TKPlaceCategorySleeping): @"\ue906",
			@(TKPlaceCategorySports): @"\ue907",
//			@"other": @"\ue908",
			@(TKPlaceCategoryRelaxing): @"\ue909",
			@(TKPlaceCategoryShopping): @"\ue90a",
			@(TKPlaceCategoryTraveling): @"\ue90b",
		};

	});

	if (place.level & (TKPlaceLevelCity | TKPlaceLevelRegion | TKPlaceLevelCountry))
		return @"\ue90c";

	TKPlaceCategory resc = TKPlaceCategoryNone;
	for (TKPlaceCategory c = TKPlaceCategorySightseeing; c <= TKPlaceCategorySleeping; c <<= 1)
		if (c & place.categories)
			resc = c;

//	NSString *marker = place.marker.copy;

	NSString *iconName = nil;

//	while (true) {
//		if (!marker.length) break;
//		iconName = iconDictionary[marker];
//		if (iconName) break;
//		NSRange r = [marker rangeOfString:@":" options:NSBackwardsSearch];
//		if (r.location == NSNotFound) break;
//		marker = [marker substringToPosition:r.location];
//	}

	if (!iconName) iconName = iconDictionary[@(resc)] ?: @"\ue908";

	return iconName;
}

@end
