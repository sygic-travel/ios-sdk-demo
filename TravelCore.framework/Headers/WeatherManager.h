//
//  WeatherManager.h
//  Tripomatic
//
//  Created by Michal Zelinka on 30/09/2014.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WeatherRecord : NSObject

@property (nonatomic, copy) NSString *destinationID;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *updateDate;

@property (atomic) CGFloat temperatureMax;
@property (atomic) CGFloat temperatureMin;

@property (nonatomic, copy) NSString *sunrise;
@property (nonatomic, copy) NSString *sunset;

@property (atomic) NSInteger conditionID;

@property (nonatomic, strong, readonly) NSDate *sunriseDate;
@property (nonatomic, strong, readonly) NSDate *sunsetDate;

@property (nonatomic, readonly) NSInteger conditionIconID;
@property (nonatomic, readonly) NSString *conditionIcon;
@property (nonatomic, readonly) NSString *conditionTitle;
@property (nonatomic, readonly) NSString *conditionDescription;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;

@end


@interface WeatherManager : NSObject

/** Singleton */
+ (WeatherManager *)defaultManager;
- (instancetype)init __attribute__((unavailable("Use [WeatherManager defaultManager].")));

// Weather stuff
- (void)updateWeatherRecordsForDestinationIDs:(NSArray *)destinationIDs;
- (NSArray *)weatherRecordsForDestinationWithID:(NSString *)destinationID;
- (WeatherRecord *)weatherRecordForDestinationWithID:(NSString *)destinationID onDate:(NSDate *)date;
- (void)fetchWeatherRecordsForDestinationWithID:(NSString *)destinationID completion:(void (^)(NSArray *))completion;

@end
