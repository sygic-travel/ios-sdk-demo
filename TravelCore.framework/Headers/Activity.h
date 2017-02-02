//
//  Activity.h
//  Tripomatic
//
//  Created by Ondra Beneš on 7/25/12.
//  Refactored by Michal Zelinka in 4/2014.
//  Copyright (c) 2014 two bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import <TravelCore/Reference.h>
#import <TravelCore/ActivityDetail.h>

@class Activity;

#define ACTIVITY_LOCAL_SUFFIX "_LOCAL"
#define ACTIVITY_NEARBY_LOCATION_TRESHOLD 50000

static const CGFloat kActivityPriceApproxSpan = 10.0;
static const CGFloat kActivityRatingApproxSpan = 0.0;
static const NSUInteger kActivityDisplayableTagsLimit = 32;

typedef NS_OPTIONS(NSUInteger, ActivityType)
{
	kActivityTypeUnknown       = (0),
	kActivityTypePOI           = (1 <<  0),
	kActivityTypeHotel         = (1 <<  1),
	kActivityTypeBookable      = (1 <<  2),
	kActivityTypeTransport     = (1 <<  3),
	kActivityTypeCity          = (1 << 16),
	kActivityTypeRegion        = (1 << 17),
	kActivityTypeCountry       = (1 << 18),
	kActivityTypeContinent     = (1 << 19),
	///////////
	// Modifying types
	kActivityTypeLocal         = (1 << 29),
	kActivityTypeCustom        = (1 << 30),
	kActivityTypeInclusive     = (1 << 31),
	///////////
	///////////
	///////////
	// Legacy types
	kActivityTypeCustomPOI        = (kActivityTypeCustom | kActivityTypePOI),
	kActivityTypeCustomHotel      = (kActivityTypeCustom | kActivityTypeHotel),
	kActivityTypeCustomLocalPOI   = (kActivityTypeCustom | kActivityTypePOI | kActivityTypeLocal),
	kActivityTypeCustomLocalHotel = (kActivityTypeCustom | kActivityTypeHotel | kActivityTypeLocal),
	///////////
	// Grouped types
	kActivityTypeDestination = (kActivityTypeCity | kActivityTypeRegion | kActivityTypeCountry),
	kActivityTypePlace       = (kActivityTypeDestination | kActivityTypePOI | kActivityTypeHotel),
	kActivityTypeAnyPOI      = (kActivityTypeCustomLocalPOI | kActivityTypeInclusive), // POIs + Custom POIs
	kActivityTypeAnyHotel    = (kActivityTypeCustomLocalHotel | kActivityTypeInclusive), // Hotels + Custom Hotels
	kActivityTypeAny         = (kActivityTypeCustom | kActivityTypeLocal | kActivityTypeInclusive), // Wild mask for Regular + Custom
};


@interface Activity : NSObject

@property (nonatomic, copy) NSString *ID NS_SWIFT_NAME(ID);
@property (nonatomic, copy) NSString *name, *suffix;
@property (nonatomic, copy) NSString *marker;
@property (nonatomic, strong) id<ActivityDetailProtocol> detail;
@property (nonatomic, copy) NSArray<NSString *> *categories, *tags;
@property (nonatomic, copy) NSArray<Reference *> *references;
@property (nonatomic, copy) NSArray<NSString *> *parentIDs;
@property (nonatomic, copy) NSArray<Activity *> *parents;
@property (nonatomic, strong) NSDate *modified;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, copy) NSString *quadKey;
@property (nonatomic, strong) NSNumber *tier;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSNumber *duration, *price;
@property (nonatomic, copy) NSString *textDescription, *owner;
@property (atomic, assign) BOOL changed, suggest, deleted;
@property (atomic, assign) BOOL hasPhoto;

@property (nonatomic, readonly) ActivityType type;
@property (nonatomic, readonly) id rawDetail;
@property (nonatomic, readonly) BOOL isPopular;
@property (nonatomic, readonly) NSArray *displayableCategories;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly, copy) NSString *speechSynthesisVoiceCode;

/** Custom init methods */
- (instancetype)initFromResponseV1:(NSDictionary *)dictionary;
- (instancetype)initFromResponseV2:(NSDictionary *)dictionary;
- (instancetype)initFromDatabase:(NSDictionary *)row;

/** Additional info */
- (NSString *)iconName;
- (NSString *)iconFontCode;
- (UIColor *)categoryColor;
- (BOOL)hasValidCoordinate;

- (BOOL)isInLocation:(Activity *)location;
- (BOOL)isInOneOfLocations:(NSArray<Activity *> *)locations;

- (BOOL)hasCategory:(NSString *)categorySlug;
- (BOOL)hasTag:(NSString *)tagName;
- (BOOL)hasFodorsContent;
- (BOOL)needsTranslation;
- (BOOL)hasWikipediaDescription;

- (NSDictionary *)asDictionary;

@end


#pragma mark - Categories


@interface NSString (Activity)

- (ActivityType)typeOfActivityID;
- (NSString *)prefixOfActivityID;

@end

// Include category with filter helpers
#import <TravelCore/Activity+ActivityFilter.h>
