//
//  TKPlace+TravelKit.m
//  TravelKit-Demo
//
//  Created by Michal Zelinka on 04/05/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import "TKPlace+TravelKit.h"

@implementation TKPlace (TravelKit)

+ (NSString *)localisedNameForCategorySlug:(NSString *)categorySlug
{
	NSDictionary *displayNames = @{
		@"sightseeing": NSLocalizedString(@"Sightseeing", @"TravelKit - Category name"),
		@"shopping": NSLocalizedString(@"Shopping", @"TravelKit - Category name"),
		@"eating": NSLocalizedString(@"Restaurants", @"TravelKit - Category name"),
		@"discovering": NSLocalizedString(@"Museums", @"TravelKit - Category name"),
		@"playing": NSLocalizedString(@"Family", @"TravelKit - Category name"),
		@"traveling": NSLocalizedString(@"Transport", @"TravelKit - Category name"),
		@"going_out": NSLocalizedString(@"Nightlife", @"TravelKit - Category name"),
		@"hiking": NSLocalizedString(@"Outdoors", @"TravelKit - Category name"),
		@"sports": NSLocalizedString(@"Sports", @"TravelKit - Category name"),
		@"relaxing": NSLocalizedString(@"Relaxation", @"TravelKit - Category name"),
		@"sleeping": NSLocalizedString(@"Accommodation", @"TravelKit - Category name"),
	};

	return displayNames[categorySlug];
}


- (NSArray<NSString *> *)localisedCategories
{
	NSArray<NSString *> *slugs = self.categories ?: @[ ];

	return [slugs mappedArrayUsingBlock:^id(NSString *slug, NSUInteger idx) {
		return [self.class localisedNameForCategorySlug:slug];
	}];
}

@end
