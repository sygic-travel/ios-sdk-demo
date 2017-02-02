//
//  PlanningManager.h
//  Tripomatic
//
//  Created by Marek Štefkovič  on 18/02/15.
//  Copyright (c) 2015 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <TravelCore/Trip.h>


#pragma mark - Definitions

#define kDistanceIdealWalkLimit     5000.0  //     5 kilometers
#define kDistanceMaxWalkLimit      50000.0  //    50 kilometers
#define kDistanceIdealCarLimit   1000000.0  //  1000 kilometers
#define kDistanceMaxCarLimit     2000000.0  //  2000 kilometers
#define kDistanceMinFlightLimit    50000.0  //    50 kilometers

@class DirectionRecord;

typedef NS_ENUM(NSInteger, NavigationDirection) {
	NavigationDirectionInvalid = -1,      // invalid direction
	NavigationDirectionStraightAhead = 0, // direction straight ahead
	NavigationDirectionSlightRight,       // slight right
	NavigationDirectionSlightLeft,        // slight left
	NavigationDirectionLeft,              // direction is left
	NavigationDirectionRight,             // direction is right
	NavigationDirectionHardRight,         // direction is sharp right
	NavigationDirectionHardLeft,          // direction is shart left
	NavigationDirectionUTurn,             //  u-turn
	NavigationDirectionTStreet,           // the street is close to T-street
	NavigationDirectionBifurcation,       // bifurcation interval
	NavigationDirectionIgnoreAngle,       // this contain the max angle that can be ignored in a junction and not to say the advice
	NavigationDirectionRoundabout,        // Roundabout
};

struct DurationExtension {
	NSTimeInterval activityDuration;
	NSTimeInterval trafficDuration;
	DirectionTransportType majorTransport;
};
typedef struct DurationExtension DurationExtension;
typedef void (^DirectionRecordFetcherCompletion)(DirectionRecord *);


#pragma mark - Planning manager

@interface PlanningManager : NSObject

+ (PlanningManager *)defaultManager;
- (instancetype)init __attribute__((unavailable("Use [PlanningManager defaultManager].")));

// Directions stuff
- (DirectionRecord *)directionRecordBetweenLocation:(CLLocation *)firstLocation andLocation:(CLLocation *)secondLocation;
- (DirectionRecord *)estimatedDirectionRecordBetweenLocation:(CLLocation *)firstLocation andLocation:(CLLocation *)secondLocation;


// Durations & Distances stuff
- (NSTimeInterval)totalDurationForDay:(TripDay *)day inTripWithID:(NSString *)tripID;
- (CLLocationDistance)totalDistanceForDay:(TripDay *)day inTripWithID:(NSString *)tripID;

// Activities scheduling stuff
- (NSUInteger)bestPositionForActivity:(Activity *)activity withinActivities:(NSArray *)activities;
- (DurationExtension)durationExtensionWithActivity:(Activity *)activity inDay:(TripDay *)day ofTripWithID:(NSString *)tripID;

// User-customizable Transport stuff
- (DirectionTransportType)preferredTransportTypeFromActivity:(Activity *)fromActivity
	toActivity:(Activity *)toActivity onDay:(TripDay *)tripDay;
- (void)setPreferredTrasportType:(DirectionTransportType)transportType fromActivity:(Activity *)fromActivity
	toActivity:(Activity *)toActivity onDay:(TripDay *)tripDay;

@end


#pragma mark - Direction record

@interface DirectionRecord : NSObject

@property (nonatomic, copy) NSString *coordKey;

@property (atomic) CLLocationDistance airDistance;
@property (atomic) BOOL estimated;

@property (atomic) CLLocationDistance walkDistance;
@property (atomic) CLLocationDistance carDistance;
@property (atomic) CLLocationDistance flyDistance;

@property (atomic) NSTimeInterval walkTime;
@property (atomic) NSTimeInterval carTime;
@property (atomic) NSTimeInterval flyTime;

@property (nonatomic, copy) NSString *walkPolyline;
@property (nonatomic, copy) NSString *carPolyline;
@property (nonatomic, copy) NSString *flyPolyline;

@property (atomic, readonly) DirectionTransportType idealType;
@property (atomic, readonly) CLLocationDistance idealDistance;
@property (atomic, readonly) NSTimeInterval idealTime;
@property (nonatomic, readonly, copy) NSString *idealPolyline;
@property (atomic, readonly) NSArray *possibleTypes;

- (CLLocationDistance)distanceForType:(DirectionTransportType)type;
- (NSTimeInterval)timeForType:(DirectionTransportType)type;

- (CLLocation *)startLocation;
- (CLLocation *)endLocation;

@end


#pragma mark - Direction step

@interface DirectionStep : NSObject

@property (nonatomic, copy) NSString *destinationTitle;
@property (nonatomic, strong) CLLocation *destinationLocation;

@property (atomic) CLLocationDistance remainingDistance;
@property (atomic) NSTimeInterval remainingTime;
@property (atomic) NavigationDirection streetDirection;
@property (atomic) CLLocationDistance streetDirectionDistance;

@end
