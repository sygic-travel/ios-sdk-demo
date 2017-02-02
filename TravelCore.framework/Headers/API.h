//
//  API.h
//  Tripomatic
//
//  Created by Michal Zelinka on 27/09/13.
//  Copyright (c) 2013 two bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/APIConnection.h>

#import <TravelCore/PlanningManager.h>
#import <TravelCore/UserSettings.h>

#import <TravelCore/Activity.h>
#import <TravelCore/Trip.h>
#import <TravelCore/Medium.h>
#import <TravelCore/MapAnnotation.h>
#import <TravelCore/WeatherManager.h>

#define API_PROTOCOL   "https" // Mandatory
#define API_SUBDOMAIN  "api"
#define API_BASE_URL   "sygictraveldata.com"
#define API_VERSION    "v2.2"

typedef NS_ENUM(NSInteger, APIRequestType)
{
	API_REQUEST_UNKNOWN = 0,
	API_REQUEST_CHANGES_GET,
	API_REQUEST_TRIP_GET,
	API_REQUEST_TRIP_NEW,
	API_REQUEST_TRIP_UPDATE,
	API_REQUEST_TRIP_SUBSCRIBE,
	API_REQUEST_TRIP_UNSUBSCRIBE,
	API_REQUEST_TRIP_DELETE,     // Not used (archives instead of deleting --
	API_REQUEST_EMPTY_TRASH,     //           use Empty Trash instead)
	API_REQUEST_ACTIVITY_GET,
	API_REQUEST_ACTIVITY_NEW,
	API_REQUEST_ACTIVITY_UPDATE,
	API_REQUEST_ACTIVITY_DELETE, // Not used yet (use archiving via UPDATE)
	API_REQUEST_BATCH_ACTIVITY_GET,
	API_REQUEST_FEATURES_SEARCH_GET,
	API_REQUEST_RAW_FEATURES_SEARCH_GET,
	API_REQUEST_ITEM_GET,
	API_REQUEST_BATCH_ITEM_GET,
	API_REQUEST_ITEM_TRANSLATION_GET,
	API_REQUEST_MEDIA_GET,
	API_REQUEST_FAVOURITES_GET,
	API_REQUEST_FAVOURITES_ADD,
	API_REQUEST_FAVOURITES_DELETE,
	API_REQUEST_USER_DATA_PUT,
	API_REQUEST_DIRECTIONS_GET,
	API_REQUEST_GEO_SEARCH_GET,
	API_REQUEST_WEATHER_GET,
	API_REQUEST_EXCHANGE_RATES_GET,
	API_REQUEST_CARDS_GET,
	API_REQUEST_USER_INFO_GET,
	API_REQUEST_USER_PURCHASE_PROCESS,
	API_REQUEST_USER_API_KEY_FETCH,
	API_REQUEST_USER_CREDENTIALS_AUTH,
	API_REQUEST_USER_SOCIAL_AUTH,
	API_REQUEST_USER_REGISTER,
	API_REQUEST_USER_RESET_PASSWORD,
	API_REQUEST_CUSTOM_GET,
	API_REQUEST_CUSTOM_POST,
	API_REQUEST_CUSTOM_PUT,
	API_REQUEST_CUSTOM_DELETE,
};

typedef NS_ENUM(NSUInteger, APIRequestState)
{
	APIRequestStateInit = 0,
	APIRequestStatePending,
	APIRequestStateFinished,
};

//
//   Will handle API URLs, connection IDs, ...
//

@interface API : NSObject

@property (nonatomic, copy) NSString *APIKey;
@property (nonatomic, copy, readonly) NSString *defaultAPIKey;
@property (nonatomic, copy, readonly) NSString *hostname;
@property (nonatomic, readonly) BOOL isAlphaEnvironment;

/** Shared sigleton */
+ (API *)sharedAPI;
- (instancetype)init OBJC_UNAVAILABLE("Use [API sharedAPI].");

// Standard supported + custom API calls
- (NSString *)pathForRequestType:(APIRequestType)type;
- (NSString *)pathForRequestType:(APIRequestType)type ID:(NSString *)ID;
- (NSString *)URLStringForPath:(NSString *)path;

@end


@interface APIRequest : NSObject

@property (nonatomic, copy) NSString *APIKey;
//@property (nonatomic, copy) NSString *url;
@property (atomic) APIRequestType type;
@property (atomic) APIRequestState state;
@property (nonatomic) BOOL silent;

@property (nonatomic, readonly) NSString *typeString;


////////////////////
// Predefined requests
////////////////////


////////////////////
// Changes

- (instancetype)initAsChangesRequestSince:(NSTimeInterval)since success:(void (^)(
		NSArray<Trip *> *onlineTrips, NSArray<Activity *> *onlinePlaces,
		NSArray<NSString *> *deletedTripIDs, NSArray<NSString *> *addedFavouriteIDs,
		NSArray<NSString *> *deletedFavouriteIDs, NSArray<ActivityUserData *> *modifiedUserData,
		NSTimeInterval timestamp))success failure:(void (^)())failure;

////////////////////
// Trips

- (instancetype)initAsTripRequestForTripWithID:(NSString *)tripID
	success:(void (^)(Trip *trip))success failure:(void (^)())failure;

- (instancetype)initAsNewTripRequestForTrip:(Trip *)trip
	success:(void (^)(Trip *trip))success failure:(void (^)())failure;

- (instancetype)initAsUpdateTripRequestForTrip:(Trip *)trip
	success:(void (^)(Trip *))success failure:(void (^)(APIError *, Trip *))failure;

- (instancetype)initAsDeleteTripRequestForTripWithID:(NSString *)tripID
	success:(void (^)())success failure:(void (^)())failure DEPRECATED_ATTRIBUTE;

- (instancetype)initAsSubscribeTripRequestForTripWithID:(NSString *)tripID
	success:(void (^)())success failure:(void (^)())failure;

- (instancetype)initAsUnsubscribeTripRequestForTripWithID:(NSString *)tripID
	success:(void (^)())success failure:(void (^)())failure;

- (instancetype)initAsEmptyTrashRequestWithSuccess:(void (^)(NSArray<NSString *> *tripIDs))success failure:(void (^)())failure;

////////////////////
// Activities

- (instancetype)initAsActivityRequestForActivityWithID:(NSString *)activityID
	success:(void (^)(Activity *))success failure:(void (^)())failure;

- (instancetype)initAsNewActivityRequestWithJSONData:(NSString *)jsonData // SSO-TODO: Refactor
	success:(void (^)(Activity *activity))success failure:(void (^)(APIError *error))failure;

- (instancetype)initAsUpdateActivityRequestForActivityWithID:(NSString *)activityID // SSO-TODO: Refactor
	JSONData:(NSString *)jsonData success:(void (^)(Activity *activity))success
	failure:(void (^)(APIError *error))failure;

- (instancetype)initAsBatchActivityRequestForItemIDs:(NSArray<NSString *> *)itemIDs
	success:(void (^)(NSArray<Activity *> *))success failure:(void (^)())failure;

////////////////////
// Features

- (instancetype)initAsFeaturesSearchRequestForSearchTerm:(NSString *)searchTerm
	type:(ActivityType)type filter:(ActivityFilter)filter location:(CLLocation *)location
	success:(void (^)(NSArray<Activity *> *))success failure:(void (^)())failure;

- (instancetype)initAsRawFeaturesSearchRequestForSearchTerm:(NSString *)searchTerm
	type:(ActivityType)type location:(CLLocation *)location
	success:(void (^)(NSArray<NSDictionary *> *))success failure:(void (^)())failure;

////////////////////
// Items

- (instancetype)initAsItemRequestForItemWithID:(NSString *)itemID
	success:(void (^)(Activity *, NSArray<Medium *> *media))success failure:(void (^)())failure;

- (instancetype)initAsBatchItemRequestForItemIDs:(NSArray<NSString *> *)itemIDs
	success:(void (^)(NSArray<Activity *> *))success failure:(void (^)())failure;

- (instancetype)initAsItemTranslationRequestForItemWithID:(NSString *)itemID
	success:(void (^)(NSDictionary *))success failure:(void (^)())failure;

////////////////////
// Media

- (instancetype)initAsMediaRequestForItemWithID:(NSString *)itemID
	success:(void (^)(NSArray<Medium *> *))success failure:(void (^)())failure;

////////////////////
// Favourites

- (instancetype)initAsFavouritesRequestWithSuccess:(void (^)(NSArray<NSString *> *favouriteIDs))success
	failure:(void (^)())failure DEPRECATED_ATTRIBUTE;

- (instancetype)initAsFavouritesAddRequestWithIDs:(NSArray<NSString *> *)IDs
	success:(void (^)())success failure:(void (^)())failure;

- (instancetype)initAsFavouritesDeleteRequestWithIDs:(NSArray<NSString *> *)IDs
	success:(void (^)())success failure:(void (^)())failure;

////////////////////
// User Data

- (instancetype)initAsUserDataPushRequestWithUserData:(NSArray<ActivityUserData *> *)userData
	success:(void (^)())success failure:(void (^)())failure;

////////////////////
// Directions

- (instancetype)initAsDirectionsRequestFromLocation:(CLLocation *)fromLocation
	toLocation:(CLLocation *)toLocation success:(void (^)(DirectionRecord *record))success failure:(void (^)())failure;

////////////////////
// Geographic

- (instancetype)initAsGeoSearchRequestWithSearchTerm:(NSString *)searchTerm
	location:(CLLocation *)location success:(void (^)(NSArray<MapAnnotation *> *))success failure:(void (^)())failure;

////////////////////
// Weather

- (instancetype)initAsWeatherRequestForDestination:(Activity *)destination
	success:(void (^)(NSArray<WeatherRecord *> *records))success failure:(void (^)())failure;

////////////////////
// Exchange Rates

- (instancetype)initAsExchangeRatesRequestWithSuccess:(void (^)(NSDictionary<NSString *, NSNumber *> *))success failure:(void (^)())failure; // SSO-TODO: Basic types

////////////////////
// User session

- (instancetype)initAsUserInfoRequestWithCredentials:(UserCredentials *)credentials
	success:(void (^)(UserInfo *))success failure:(void (^)())failure;

- (instancetype)initAsUserPurchaseProcessRequestWithReceipt:(NSString *)receipt products:(NSArray<NSString *> *)products
	success:(void (^)(UserInfo *))success failure:(void (^)())failure;

- (instancetype)initAsUserAPIKeyFetchRequestWithSuccess:(void (^)(UserInfo *, UserCredentials *))success failure:(void (^)())failure;

- (instancetype)initAsUserCredentialsAuthRequestWithUsername:(NSString *)username password:(NSString *)password
	success:(void (^)(APIResponse *))success failure:(void (^)(APIError *error))failure;

- (instancetype)initAsUserSocialAuthRequestWithFacebookToken:(NSString *)facebookToken googleToken:(NSString *)googleToken
	success:(void (^)(APIResponse *))success failure:(void (^)(APIError *error))failure;

- (instancetype)initAsUserRegisterRequestWithFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password
	success:(void (^)(APIResponse *))success failure:(void (^)(APIError *error))failure;

- (instancetype)initAsUserResetPasswordRequestWithEmail:(NSString *)email
	success:(void (^)())success failure:(void (^)(APIError *error))failure;

////////////////////
// Custom requests

/**
 * Method for easier sending of GET requests by appending just a path
 *
 * @param path     URL path of a request, f.e. '/activity/poi:530' when asking for Activity detail
 * @param success  Success block receiving parsed JSON data in NSDictionary-subclass object
 * @param failure  Failure block
 * @return         API Request instance
 */
- (instancetype)initAsCustomGETRequestWithPath:(NSString *)path
                                     success:(void (^)(id))success failure:(APIConnectionFailureBlock)failure;

/**
 * Method for easier sending of POST requests by appending just a path
 *
 * @param path     URL path of a request, f.e. '/activity/' when submitting new Custom Place
 * @param json     JSON string with data to be included in POST request
 * @param success  Success block receiving parsed JSON response in NSDictionary-subclass object
 * @param failure  Failure block
 * @return         API Request instance
 */
- (instancetype)initAsCustomPOSTRequestWithPath:(NSString *)path
                json:(NSString *)json success:(void (^)(id))success failure:(APIConnectionFailureBlock)failure;

/**
 * Method for easier sending of PUT requests by appending just a path
 *
 * @param path     URL path of a request, f.e. '/activity/c:12903' when submitting Custom Place udpate
 * @param json     JSON string with data to be included in PUT request
 * @param success  Success block receiving parsed JSON response in NSDictionary-subclass object
 * @param failure  Failure block
 * @return         API Request instance
 */
- (instancetype)initAsCustomPUTRequestWithPath:(NSString *)path
               json:(NSString *)json success:(void (^)(id))success failure:(APIConnectionFailureBlock)failure;

/**
 * Method for easier sending of DELETE requests by appending just a path
 *
 * @param path     URL path of a request, f.e. '/activity/c:12903' when submitting Custom Place udpate
 * @param success  Success block receiving parsed JSON response in NSDictionary-subclass object
 * @param failure  Failure block
 * @return         API Request instance
 */
- (instancetype)initAsCustomDELETERequestWithPath:(NSString *)path
                  json:(NSString *)json success:(void (^)(id))success failure:(APIConnectionFailureBlock)failure;

// Actions

- (void)start;
- (void)silentStart;
- (void)cancel;

@end
