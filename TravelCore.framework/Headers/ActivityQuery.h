//
//  ActivityQuery.h
//  Travel
//
//  Created by Michal Zelinka on 02/02/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/Activity.h>
#import <TravelCore/Activity+ActivityFilter.h>
#import <TravelCore/MapRegionWrapper.h>


@interface ActivityQuery : NSObject

@property (atomic) ActivityType type;
@property (atomic) ActivityFilter filter;   // Private
@property (nonatomic, copy) NSArray<NSString *> *categories;
@property (nonatomic, copy) NSArray<NSString *> *tags;
@property (nonatomic, copy) NSString *parentID;
@property (nonatomic, copy) NSString *tripID;
@property (nonatomic, copy) NSString *userID;
@property (atomic) NSInteger tripDayIndex;
@property (nonatomic, strong) MapRegionWrapper *region;
@property (nonatomic, copy) NSArray<NSString *> *quadKeys;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, strong) NSNumber *minimalTier;
@property (nonatomic, strong) NSNumber *minimalRating;
@property (nonatomic, strong) NSNumber *minimalPrice;
@property (nonatomic, strong) NSNumber *maximalPrice;
@property (nonatomic, strong) NSNumber *minimalCustomerRating;
@property (nonatomic, strong) NSNumber *minimalHotelStarRating;
@property (nonatomic, strong) NSNumber *maximalHotelStarRating;
@property (atomic) BOOL favourites;         // Private
@property (atomic) BOOL customPlaces;       // Private
@property (atomic) BOOL skipOrdering;       // Private
@property (atomic) BOOL skipIndexes;        // Private
@property (atomic) NSUInteger limit;

@end
