//
//  LoadFeaturesOperation.h
//  Tripomatic
//
//  Created by myf on 09.11.12.
//  Refactored by Michal Zelinka in 2014.
//  Copyright (c) 2014 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TravelCore/ActivityManager.h>

#define FEATURES_LIMIT           500

typedef NS_ENUM(NSUInteger, LoadFeaturesMode) {
	LoadFeaturesModeHybrid = 0,
	LoadFeaturesModeOnline,
	LoadFeaturesModeOffline,
};


@interface FeatureStat : NSObject

@property (nonatomic, copy) NSString *name;
@property (atomic) NSInteger priority;
@property (atomic) NSUInteger count;

+ (instancetype)statFromDictionary:(NSDictionary *)dictionary;

@end


@interface FeatureResultSet : NSObject

@property (nonatomic, copy) NSArray<Activity *> *features;
@property (nonatomic, copy) NSArray<FeatureStat *> *categoryStats;
@property (nonatomic, copy) NSArray<FeatureStat *> *tagStats;

@end


@class LoadFeaturesOperation;
@protocol LoadFeaturesOperationDelegate <NSObject>

@optional
- (void)loadFeaturesOperation:(LoadFeaturesOperation *)operation didFinishWithResultSet:(FeatureResultSet *)resultSet;
- (void)loadFeaturesOperationDidCancel:(LoadFeaturesOperation *)operation;

@end


@interface LoadFeaturesOperation : NSOperation

@property (nonatomic, strong) ActivityQuery *query;
@property (nonatomic, weak) id<LoadFeaturesOperationDelegate> delegate;
@property (atomic, assign) LoadFeaturesMode mode;

- (instancetype)initWithDelegate:(id<LoadFeaturesOperationDelegate>)delegate;

@end
