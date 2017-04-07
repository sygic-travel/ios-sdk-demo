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
	CGFloat fontSize = (size >= 300) ? 192 : (size >= 200) ? 96 : (size >= 100) ? 48 : 36;

	_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:_imageView];

	_categoryLabel = [[UILabel alloc] initWithFrame:self.bounds];
	_categoryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_categoryLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
	_categoryLabel.textAlignment = NSTextAlignmentCenter;
	_categoryLabel.font = [UIFont fontWithName:@"MapMarkers" size:fontSize];
	[self addSubview:_categoryLabel];
}

- (void)setFrame:(CGRect)frame
{
	super.frame = frame;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
	super.contentMode = _imageView.contentMode = contentMode;
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

	else
	[[TravelKit sharedKit] mediaForPlaceWithID:place.ID completion:^(NSArray<TKMedium *> *media, NSError *error) {

		if (!media.count) return;

		[_imageView setImageWithMediumImage:media.firstObject size:size completion:completion];
	}];
}

- (NSString *)iconFontCodeForPlace:(TKPlace *)place
{
	static NSDictionary *iconDictionary = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{

		iconDictionary = @{
			// Categories
			@"discovering": @"\ue900",
			@"sightseeing": @"\ue901",
			@"going_out": @"\ue902",
			@"eating": @"\ue903",
			@"hiking": @"\ue904",
			@"playing": @"\ue905",
			@"sleeping": @"\ue906",
			@"sports": @"\ue907",
			@"other": @"\ue908",
			@"relaxing": @"\ue909",
			@"shopping": @"\ue90a",
			@"traveling": @"\ue90b",
		};

	});

	if (place.level & (TKPlaceLevelCity | TKPlaceLevelRegion | TKPlaceLevelCountry))
		return @"\ue90c";

	NSString *category = place.categories.firstObject;

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

	if (!iconName) iconName = iconDictionary[category] ?: @"\ue908";

	return iconName;
}




@end
