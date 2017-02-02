//
//  ActivityDetail.h
//  Tripomatic
//
//  Created by Michal Zelinka on 15/01/14.
//  Copyright (c) 2014 two bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/MapRegionWrapper.h>

@protocol ActivityDetailProtocol <NSObject>

@optional
- (NSDictionary *)asDictionary;

@end

#pragma mark -
#pragma mark Regular activity

@interface ActivityDetail : NSObject <ActivityDetailProtocol>

@property (nonatomic, copy) NSString *activityID;
@property (nonatomic, copy) NSString *extendedInfo;
@property (nonatomic, copy) NSString *originalName;
@property (nonatomic, copy) NSString *openingHours;
@property (nonatomic, copy) NSString *admission;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSString *longDescription;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initFromResponseV2:(NSDictionary *)dictionary;

@end

#pragma mark -
#pragma mark Location activity

@interface LocationDetail : NSObject <ActivityDetailProtocol>

@property (nonatomic, copy) NSString *activityID;
@property (nonatomic, copy) NSNumber *zoomLevel;
@property (nonatomic, strong) MapRegionWrapper *boundingBox;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initFromResponseV2:(NSDictionary *)dictionary;

@end

#pragma mark -
#pragma mark Bookable activity

@interface BookableDetail : NSObject <ActivityDetailProtocol>

@property (nonatomic, copy) NSString *activityID;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *fromActivityID;
@property (nonatomic, copy) NSURL *bookingURL;
@property (nonatomic, copy) NSNumber *rank;
@property (nonatomic, copy) NSArray *salesPoints;
@property (nonatomic, copy) NSString *departureTime;
@property (nonatomic, copy) NSString *longDescription;
@property (nonatomic, copy) NSNumber *savingAmount;
@property (nonatomic, copy) NSNumber *ratingsCount;
@property (nonatomic, copy) NSNumber *ratingsAverage;
@property (nonatomic, copy) NSArray *reviews;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initFromResponseV2:(NSDictionary *)dictionary;

@end

#pragma mark Bookable Review

@interface BookableReview : NSObject

@property (nonatomic, copy) NSString *activityID;
@property (nonatomic, copy) NSDate *publishedDate;
@property (nonatomic, copy) NSNumber *rating;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *review;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;

@end

#pragma mark -
#pragma mark Hotel activity

@interface HotelDetail : NSObject <ActivityDetailProtocol>

@property (nonatomic, copy) NSString *activityID;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSURL *bookingURL;
@property (nonatomic, copy) NSNumber *customerRating;
@property (nonatomic, copy) NSNumber *starRating;
@property (nonatomic, assign) BOOL starRatingIsEstimate;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSNumber *tripsCount;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initFromResponseV2:(NSDictionary *)dictionary;

@end
