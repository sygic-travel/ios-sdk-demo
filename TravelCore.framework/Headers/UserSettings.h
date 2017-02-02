//
//  UserSettings.h
//  Tripomatic
//
//  Created by Michal Zelinka on 14/02/2014.
//  Copyright (c) 2014 two bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

#define UNIT_SEPARATOR "  "


#pragma mark User Settings string identificators

 // ALL: ABI-EXPORTED

// Database
extern NSString * const kSettingsDatabaseSchemeVersion;
extern NSString * const kSettingsDatabaseDataTimestamp;

// API stuff
extern NSString * const kSettingsUserInfo;
extern NSString * const kSettingsChangesTimestamp;
extern NSString * const kSettingsServerPrefix;
extern NSString * const kSettingsAppStoreCountry;
extern NSString * const kSettingsLastGuidesUpdate;
extern NSString * const kSettingsLastPurchasesUpdate;

// Hint flags
extern NSString * const kSettingsHintItineraryShown;
extern NSString * const kSettingsHintActivityShown;
extern NSString * const kSettingsHintActivitiesShown;

// State attributes
extern NSString * const kSettingsLastOpenedTrip;
extern NSString * const kSettingsLastSignUpHintDate;

// User settings
extern NSString * const kSettingsDistanceUnits;
extern NSString * const kSettingsTemperatureUnits;
extern NSString * const kSettingsCurrencyUnit;
extern NSString * const kSettingsNavigationApp;
extern NSString * const kSettingsSavePhotosToCameraRoll;
extern NSString * const kSettingsResetAppData;

// App-wide flags
extern NSString * const kSettingsLaunchNumber;
extern NSString * const kSettingsIntallationDate;
extern NSString * const kSettingsPushDeviceToken;
extern NSString * const kSettingsWelcomeShowcaseFinished;
extern NSString * const kSettingsLocationAuthRequested;
extern NSString * const kSettingsNotificationsAuthRequested;

// Skobbler update flags
extern NSString * const kSettingsHintMapGuidesUpdateNeeded;
extern NSString * const kSettingsHintMapGuidesUpdateShown;


// Enum of possible measurement units

// ABI-EXPORTED
typedef NS_ENUM(NSInteger, UserDistanceUnits) {
    UserDistanceUnitsDefault = 0,
	UserDistanceUnitsMetric = 1,
    UserDistanceUnitsImperial = 2,
};

// ABI-EXPORTED
typedef NS_ENUM(NSInteger, UserTemperatureUnits) {
	UserTemperatureUnitsDefault = 0,
	UserTemperatureUnitsCelsius = 1,
	UserTemperatureUnitsFahrenheit = 2,
};

// ABI-EXPORTED
typedef NS_ENUM(NSUInteger, UserNavigationAppType) {
	UserNavigationAppDefault = 0,
	UserNavigationAppTripomatic,
	UserNavigationAppAppleMaps,
	UserNavigationAppGoogleMaps,
	UserNavigationAppNavigon,
	UserNavigationAppSygic,
	UserNavigationAppTomTom,
	UserNavigationAppWaze,
};


#pragma mark - User Information


@interface UserInfo : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *APIKey;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic) BOOL premiumAccount;
@property (nonatomic, copy) NSArray *premiumDestinationIDs;
@property (nonatomic, strong) NSDate *premiumExpiration;
@property (nonatomic) BOOL isAnonymous;
@property (nonatomic) BOOL isSSOUser;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)asDictionary;

@end


@interface UserCredentials : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)asDictionary;

@end


#pragma mark - Persistent User Settings


@interface UserSettings : NSObject

// User settings
@property (nonatomic, copy, readonly) NSString *appLanguage;
@property (nonatomic, assign, readonly) UserDistanceUnits distanceUnits;
@property (nonatomic, assign, readonly) UserTemperatureUnits temperatureUnits;
@property (nonatomic, copy, readonly) NSString *currencyUnit;
@property (nonatomic, assign, readonly) UserNavigationAppType navigationApp;
@property (nonatomic, copy, readonly) NSString *serverPrefix;
@property (atomic, readonly) BOOL resetAppData;

// App settings
@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, copy) NSDictionary *userCredentials;
@property (atomic, assign) BOOL premiumEnabled;
@property (nonatomic, copy) NSString *appStoreCountry;
@property (nonatomic, assign) NSTimeInterval changesTimestamp;
@property (nonatomic, strong) NSDate *lastGuidesUpdate;
@property (nonatomic, strong) NSDate *lastPurchasesUpdate;
@property (nonatomic, copy) NSString *lastOpenedTripID;
@property (atomic, readonly) NSInteger launchNumber;
@property (nonatomic, strong) NSDate *lastSignUpHintDate;
@property (nonatomic, strong) NSDate *lastMapOpenDate;
@property (nonatomic, copy, readonly) NSString *lastAppLanguage;
@property (nonatomic, readonly) NSDate *installationDate;
@property (nonatomic, strong) NSDate *lastFBInterstitialAdShowDate;
@property (nonatomic, copy) NSData *pushDeviceToken;

+ (UserSettings *)sharedSettings;
+ (NSUserDefaults *)sharedDefaults;
+ (NSUserDefaults *)sharedGroupDefaults;
- (instancetype)init __attribute__((unavailable("Use [UserSettings sharedSettings].")));

/**
 Reload settings modifiable by user in Settings
 */
- (void)reloadUserSettings;

/**
 Commit settings into system preferences
 */
- (void)commit;

#pragma mark Units formatting

/**
 *  Return duration string formatted according to prepared rules.
 *  @param durationInSeconds Duration interval in seconds
 *  @param singleUnit Declares whether the output should include only highest possible duration unit. Default NO
 *  @param separator String separating duration value and units. Default semi-space
 *  @return Formatted duration string
 */
- (NSString *)formatDuration:(NSTimeInterval)durationInSeconds singleUnit:(BOOL)singleUnit separator:(NSString *)separator;
- (NSString *)formatDuration:(NSTimeInterval)durationInSeconds singleUnit:(BOOL)singleUnit;
- (NSString *)formatDuration:(NSTimeInterval)durationInSeconds;

/**
 *  Return distance string formatted according to selected distance units.
 *  @param distance Given distance in meters
 *  @param separator String separating distance value and units. Default semi-space
 *  @return Formatted distance string
 */
- (NSString *)formatDistance:(CLLocationDistance)distance withSeparator:(NSString *)separator;
- (NSString *)formatDistance:(CLLocationDistance)distance;

/**
 *  Return temperature string formatted according to selected temperature units.
 *  @param temperature Given temperature in Celsius degrees
 *  @param includeUnits Flag whether returned string should include temperature units. Default YES
 *  @param separator String separating temperature value and units. Default semi-space
 *  @return Formatted temperature string
 */
- (NSString *)formatTemperature:(double)temperature withUnits:(BOOL)includeUnits andSeparator:(NSString *)separator;
- (NSString *)formatTemperature:(double)temperature withUnits:(BOOL)includeUnits;
- (NSString *)formatTemperature:(double)temperature;

/**
 *  Return price string formatted according to selected currency units.
 *  @param price Given price in USD
 *  @param rounded Flag controlling whether the sum should be rounded up. Default YES
 *  @return Formatted price string
 */
- (NSString *)formatPrice:(double)price rounded:(BOOL)rounded;
- (NSString *)formatPrice:(double)price;

@end
